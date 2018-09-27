from random import random,randint,shuffle,choice,sample,randrange
from sys import setrecursionlimit,stdout
from time import sleep, time
from os import system
setrecursionlimit = 100000


write = stdout.write
######################### Funcoes de validacao #########################
def isValid(x,y):
	if 0 <= x < mazeSize and 0 <= y < mazeSize:
		return True
	return False

def isAWall(x,y):
	return maze[x][y] == wallIcon 

########################################################################

################### Informacoes/Funcoes do labirinto ###################
# Algoritmo de Gilmar totalmente corrigido pelo proprio, gera um labirinto chamado maze de tamanho sizeXsize
# uma matriz chamada mazeDists de tamanho sizeXsize que possui as distancias de cada ponto para a saida.
def generateMaze(mazeSize):
	x,y = randrange(1,mazeSize, 2),(mazeSize-1)*randint(0, 1)
	coords = [(x,x),(y, y-1 if y else 1)]
	shuffle(coords)
	dfsStart, exit, spawn = (coords[0][1], coords[1][1]), (coords[0][0],coords[1][0]), (randrange(1, mazeSize, 2), randrange(1, mazeSize, 2))
	maze[dfsStart[0]][dfsStart[1]] = ' '
	maze[exit[0]][exit[1]] = 'E'
	mazeDists[exit[0]][exit[1]] = 0
	generateMazeRecursive(dfsStart[0],dfsStart[1],1)
	maze[spawn[0]][spawn[1]] = 'S'
	return spawn,exit

def generateMazeRecursive(y,x,dist):
	mazeDists[y][x] = dist
	pairs = [(1,0),(0,1),(-1,0),(0,-1)]
	shuffle(pairs)
	for i in xrange(4):
		if isValid(y+2*pairs[i][0],x+2*pairs[i][1]) and isAWall(y+2*pairs[i][0],x+2*pairs[i][1]):
			maze[y+pairs[i][0]][x+pairs[i][1]] = maze[y+2*pairs[i][0]][x+2*pairs[i][1]] = ' '
			mazeDists[y+pairs[i][0]][x+pairs[i][1]] = dist+1
			generateMazeRecursive(y+2*pairs[i][0],x+2*pairs[i][1], dist+2)

def drawMaze(maze):
	slp = 0
	for i in xrange(mazeSize):
		separator = " "
		if not i or i == mazeSize-1:
			separator = wallIcon
		print separator.join(maze[i])
		sleep(slp)

########################################################################

################### Informacoes/Funcoes de movimento ###################
def vectorSum(point,direction):
	return (point[0]+direction[0],point[1]+direction[1])

def makeAMove(point,direction):
	return vectorSum(point,moves[direction])

def isValidMove(point,direction):
	newPoint = vectorSum(point,moves[direction])
	return isValid(newPoint[0],newPoint[1]) and not (isAWall(newPoint[0],newPoint[1]))


directions = ['U','D','L','R']
moves = {'U':(-1,0),'D':(1,0),'L':(0,-1),'R':(0,1)}
coherentMoves = {'U':['U','L','R'],'D':['D','L','R'],'R':['R','D','U'],'L':['L','D','U']}

######################  Informacoes/Funcoes do GA ######################

def calculateFitness():
	""" A funcao fitness eh calculada a partir de 3 principios:
	1 - Cada passo dado recebe uma penalizacao de 0.05 pontos (Retirado para testar se estava influenciando negativamente)
	2 - Cada choque com a parede recebe um penalizacao de 2.0 pontos
	3 - Cada vez que um individuo volta a uma posicao ja visitada ele recebe uma penalizacao de 1.0 pontos
	Individuos que nao se movem ,ou seja, que tem fitness igual a 0 tem o fitness reduzido drasticamente .
	Individuos que acham a saida tem o fitness aumentado drasticamente.
	"""
	for k in xrange(populationSize):
		individual = population[k][1]
		startPoint = spawn
		fitness = fitnessConstant
		visited = set([spawn])

		for move in individual:
			if move is not None:
				if isValidMove(startPoint,move):
					startPoint = makeAMove(startPoint,move)
					fitness += 10
				else:
					fitness -= 200

				if startPoint in visited:
					fitness -= 300
				else:
					visited.add(startPoint)

				if startPoint == exit:
					fitness *= fitnessConstant
					break

		if not individual:
			fitness = -fitnessConstant
		
		## Mudei
		fitness -= mazeDists[startPoint[0]][startPoint[1]]*1000

		individualsFitness[k] = fitness

def getFitness(index):
	return individualsFitness[index]
 
def sortByFitness():
	population.sort(key = lambda pop : (individualsFitness[pop[0]],-len(pop[1])), reverse = True)

def getFittest():
	sortByFitness()
	return population[0][1]

## Mudei
def initPopulation():
	for index in xrange(populationSize):
		counter = 0
		for move in xrange(randint(1,chromossomeSize)):
			if move:population[index][1][counter] = choice(coherentMoves[population[index][1][counter-1]])
			else: population[index][1][counter] = choice(directions)
			counter += 1

def crossOver():
	newPopulation = []
	cromossomesSet = set()

	for i in xrange(populationSize):
		# Uma forma alternativa de contornar os casos de convergencia prematura eh impedir que solucoes iguais coexistam
		# soh que garantir isso eh bem custoso.
		sonIsValid = False
		while not sonIsValid:
			son = []
			l1,r1 = groups[choice(groupsArray)]
			l2,r2 = groups[choice(groupsArray)]

			daddy = population[randint(l1,r1)][1]
			mommy = population[randint(l2,r2)][1]

			if not l1 and l2:
				daddy = filter(lambda x: x is not None, daddy)
				for _ in xrange(chromossomeSize/2):
					if not _: daddy.append(choice(directions))
					else: daddy.append(choice(coherentMoves[daddy[-1]]))
				son = daddy

			elif not l2 and l1:
				mommy = filter(lambda x: x is not None, mommy)
				for _ in xrange(chromossomeSize/2):
					if not _: mommy.append(choice(directions))
					else: mommy.append(choice(coherentMoves[mommy[-1]]))
				son = mommy

			else:
				first,second = sample([daddy,mommy],2)
				crossOverPoint = randint(1,chromossomeSize) 
				
				for k in xrange(crossOverPoint):
					if k < len(first):
						if first[k] is None: 
							crossOverPoint = k
							break
						son.append(first[k])
						

				for j in xrange(crossOverPoint,chromossomeSize):
					if j < len(second):
						if second[j] is None: break
						#Mudei
						if j == crossOverPoint: son.append(choice(coherentMoves[son[-1]]))
						else: son.append(second[j])

			sonString = ''.join(son)
			if sonString not in cromossomesSet:
				sonIsValid = True
				cromossomesSet.add(sonString)

		mutation(son)
		newPopulation.append((i,son))


	return newPopulation

## Mudei
def mutation(cromossome):
	if mutationChance > random() and cromossome:
		if random() > 0.6:
			for i in xrange(randint(1,chromossomeSize/2)):
				if cromossome: cromossome.append(choice(coherentMoves[cromossome[-1]]))
				else : cromossome.append(choice(directions))
		else:
			for i in xrange(randint(1,chromossomeSize)):
				idx = randint(0,len(cromossome)-1)
				if idx: cromossome[idx] = choice(coherentMoves[cromossome[idx-1]])
				else: cromossome[idx] = choice(directions)

def drawFittestMoves(fittest,generation):
	drawMaze(maze)
	mazeCopy = maze
	move = spawn
	for direction in fittest:
		if direction is not None and isValidMove(move,direction): 
			mazeCopy[move[0]][move[1]] = ' '
			move = makeAMove(move,direction)
			if move == exit: break
			mazeCopy[move[0]][move[1]] = 'M'
			system('cls||clear')
			drawMaze(mazeCopy)
			print "Generation %i Fittest Fitness = %.0f" %(generation,fittestFitness%fitnessConstant)
			sleep(0.3)
			
	sleep(1)

########################################################################
print('''
----------------------------------------------------------
#################### - MAZER SOLVER - ####################
----------------------------------------------------------
''')

mazeSize = int(raw_input('Size of maze?') or '15')

#mazeSize = 15 # line/column
wallIcon = '#'

while(True):
	maze = [[wallIcon]*mazeSize for i in xrange(mazeSize)]
	mazeDists = [[-1]*mazeSize for i in xrange(mazeSize)]

	spawn,exit = generateMaze(mazeSize)
	drawMaze(maze)

	genNew = raw_input("Generate new maze?(y/n) ")
	if(genNew.strip() == 'n'):
		break


numOfWalls = sum([maze[i].count(wallIcon) for i in xrange(mazeSize)])

populationSize = int(raw_input('Size of population: ') or '1000')

#populationSize = 1000
chromossomeSize = mazeSize ** 2 - numOfWalls -1
population = [(i,[None]*chromossomeSize) for i in xrange(populationSize)]
individualsFitness = [-1]*populationSize
mutationChance = 0.4
fitnessConstant = 10e6

# Grupos do fitness
quartil = [populationSize*0.01,populationSize*0.25,populationSize*0.4,populationSize*0.75]
groups = {1:(0,quartil[0]),
		  2:(quartil[0]+1,quartil[1]),
		  3:(quartil[1]+1,quartil[2]),
		  4:(quartil[2]+1,quartil[3]),
		  5:(quartil[3]+1,populationSize-1)}
groupsChance = [0.5,0.25,0.15,0.08,0.02]
groupsArray = [1]*(int(groupsChance[0]*100)) + [2]*(int(groupsChance[1]*100)) + [3]*(int(groupsChance[2]*100)) + [4]*(int(groupsChance[3]*100))

initPopulation()
fittest = generation = fittestFitness = 0
count = 0
finalists = []


startTime = time()

# Esse count eh soh para efeitos de teste
while count < 20000 and len(finalists) < 5:
	calculateFitness()
	fittest = getFittest()
	fittestFitness = getFitness(population[0][0])

	if fittestFitness > fitnessConstant:
		finalists.append(fittest)
	print len(finalists)

	population = crossOver()
	
	generation += 1
	count +=1
	
	print 'Solving','.'*(generation%5)
	sleep(0.5)
	system('cls||clear')

endTime = time()

exec_time = endTime-startTime
finalists.sort(key = lambda x: len(x))

fittest = finalists[0]

sleep(1)
drawFittestMoves(fittest,generation)
print("Time Executation: %.2f seconds" %(exec_time))
input()