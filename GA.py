from random import random,randint,shuffle,choice,sample
from sys import setrecursionlimit
from time import sleep
from os import system
setrecursionlimit = 10000

######################### Funcoes de validacao #########################
def isValid(x,y):
	if 0 < x < mazeSize[0]-1 and 0 < y < mazeSize[1]-1:
		return True
	return False

def isAWall(x,y):
	return maze[x][y] == wallIcon 

########################################################################

################### Informacoes/Funcoes do labirinto ###################
# Algoritmo de Gilmar n está fazendo labirintos bonitinhos, talvez eu tenha copiado algo errado
def generateMaze():
	x,y = randint(1,mazeSize[0]-1),(mazeSize[1]-1)*(randint(1,mazeSize[1]-1)&1)
	coords = [(x,x),(y, mazeSize[1]-2 if y else 1)]
	shuffle(coords)
	spawn,exit = (coords[0][1],coords[1][1]),(coords[0][0],coords[1][0])
	maze[exit[0]][exit[1]] = 'E'
	maze[spawn[0]][spawn[1]] = 'S'
	generateMazeRecursive(spawn[0],spawn[1])
	return spawn,exit

def generateMazeRecursive(x,y):
	pairs = [(1,0),(0,1),(-1,0),(0,-1)]
	shuffle(pairs)
	for i in xrange(4):
		if isValid(y+2*pairs[i][0],x+pairs[i][1]) and isAWall(y+pairs[i][0],x+pairs[i][1]):
			maze[y+pairs[i][0]][x+pairs[i][1]] = maze[y+2*pairs[i][0]][x+2*pairs[i][1]] = ' '
			generateMazeRecursive(y+2*pairs[i][0],x+2*pairs[i][1])

mazeSize = (5,5) # line/column
wallIcon = '#'
maze = [
['#','#','#','#','#'],
['#','S','#',' ','E'],
['#',' ','#',' ','#'],
['#',' ',' ',' ','#'],
['#','#','#','#','#']
]
spawn,exit = (1,1),(1,4)
#maze = [[wallIcon]*mazeSize[1] for i in xrange(mazeSize[0])]
#spawn,exit = generateMaze()
numOfWalls = sum([maze[i].count(wallIcon) for i in xrange(mazeSize[0])])

def drawMaze(maze):
	slp = 0.3
	for i in xrange(mazeSize[0]):
		separator = " "
		if not i or i == mazeSize[0]-1:
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
	return isValid(newPoint[0],newPoint[1]) and not isAWall(newPoint[0],newPoint[1])

directions = ['U','D','L','R']
moves = {'U':(-1,0),'D':(1,0),'L':(0,-1),'R':(0,1)}

######################  Informacoes/Funcoes do GA ######################
populationSize = 100
chromossomeSize = mazeSize[0]*mazeSize[1] - numOfWalls
population = [element for element in enumerate([[""]*populationSize for j in xrange(populationSize)])]
individualsFitness = {}
mutationChance = 0.2

# Grupos do fitness
quartil = [populationSize*0.25,populationSize*0.5,populationSize*0.75]
groups = {1:(0,quartil[0]),
		  2:(quartil[0]+1,quartil[1]),
		  3:(quartil[1]+1,quartil[2]),
		  4:(quartil[2]+1,populationSize-1)}
groupsChance = [0.5,0.25,0.15,0.1]
groupsArray = [1]*(int(groupsChance[0]*100)) + [2]*(int(groupsChance[1]*100)) + [3]*(int(groupsChance[2]*100)) + [4]*(int(groupsChance[3]*100))


def calculateFitness():
	""" A funcao fitness eh calculada a partir de 3 principios:
	1 - Cada passo dado recebe uma penalizacao de 0.05 pontos (Retirado para testar se estava influenciando negativamente)
	2 - Cada choque com a parede recebe um penalizacao de 2.0 pontos
	3 - Cada vez que um individuo volta a uma posicao ja visitada ele recebe uma penalizacao de 1.2 pontos

	Individuos que nao se movem ,ou seja, que tem fitness igual a 0 sao automaticamente excluidos.
	Individuos que acham a saida tem fitness positivo.
	"""
	for index in xrange(populationSize):
		individual = population[index][1]
		startPoint = spawn
		fitness = 0
		visited = set()

		for move in individual:
			if move:
				if isValidMove(startPoint,move):
					startPoint = makeAMove(startPoint,move)
				else:
					fitness -= 3

				if startPoint in visited:
					fitness -= 1.5
				else:
					visited.add(startPoint)

				if startPoint == exit:
					fitness = abs(fitness)
					break

		if fitness == 0:
			fitness = -10000

		individualsFitness[index] = fitness

def getFitness(index):
	return individualsFitness[index]
 
def sortByFitness():
	population.sort(key = lambda pop : abs(individualsFitness[pop[0]]))

def getFittest():
	sortByFitness()
	return population[0][1]

def initPopulation():
	for index in xrange(populationSize):
		counter = 0
		for move in xrange(randint(1,chromossomeSize)):
			population[index][1][counter] = choice(directions)
			counter += 1

def crossOver():
	newPopulation = []
	cromossomesSet = set()

	for i in xrange(populationSize/2):
		validSon = False
		while not validSon:
			l1,r1 = groups[choice(groupsArray)]
			l2,r2 = groups[choice(groupsArray)]

			daddy = population[randint(l1,r1)]
			mommy = population[randint(l2,r2)]

			first,second = sample([daddy,mommy],2)
			first,second = list("".join(first[1])),list("".join(second[1]))
			crossOverPoint = randint(0,chromossomeSize) 
			son = first[:crossOverPoint] + second[crossOverPoint:]

			mutation(son)
			newPopulation.append((i,son))

			# Fiz isso daqui pra ver se melhorava o caso de ficar repetindo os movimentos dentro de uma populacao, mas acho que se
			# resolver o problema do fitness isso daqui n vai ter serventia 
			sonString = "".join(son)
			if sonString not in cromossomesSet:
				cromossomesSet.add(sonString)
				validSon = True

	return newPopulation

def mutation(cromossome):
	if mutationChance > random():
		cromossome[randint(0,len(cromossome)-1)] = choice(directions)

def drawFittestMoves(fittest,generation):
	drawMaze(mazeCopy)
	for direction in fittest:
		move = moves[direction]
		mazeCopy[move[0]][move[1]] = 'M'
		system('cls||clear')
		drawMaze(mazeCopy)
		sleep(0.3)
	sleep(1)

# Outra tentativa de evitar que as respostas ficassem se repetindo, metade da populacao eh obtida por crossover
# e a outra metade eh tirada do cu 
def randomPopulation():
	newPopulation = []
	for index in xrange(populationSize/2):
		counter = 0
		individ = []
		for move in xrange(randint(1,chromossomeSize)):
			individ.append(choice(directions))
		newPopulation.append((index,individ))
	return newPopulation

########################################################################

drawMaze(maze)
initPopulation()
fittest = generation = fittestFitness = 0
count = 0
print chromossomeSize

# Esse count eh soh para efeitos de teste
while count < 10 and fittestFitness <= 0:
	calculateFitness()
	fittest = getFittest()
	fittestFitness = getFitness(population[0][0])
	# print population[0][1] == fittest

	print "Generation %i Fittest Fitness = %f" %(generation,fittestFitness)
	print fittest
	print

	population = crossOver()+randomPopulation()
	
	generation += 1
	count +=1


