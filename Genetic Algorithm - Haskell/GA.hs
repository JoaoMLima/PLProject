module GA where 

-- Generate a random number given a range.
import System.Process as SP
import System.IO.Unsafe
import System.Random
import Data.List

-- Variaveis iniciais
mutationChance = 50 --Porcentagem
wallIcon = '#'
populationSize = 1000
--spawn = (3,3)
--exit = (4,1)
--maze = [['#', '#', '#', '#', '#'],
--        ['#', ' ', ' ', ' ', 'E'],
--        ['#', ' ', '#', '#', '#'],
--        ['#', ' ', ' ', 'S', '#'],
--        ['#', '#', '#', '#', '#']]

--mazeDists = [[-1,-1,-1,-1,-1],
--             [-1,3,2,1,0],
--             [-1,4,-1,-1,-1],
--            [-1,5,6,7,-1],
--             [-1,-1,-1,-1,-1]]

--population = initPopulation

data Individuo = Individuo {fitness :: Int, moves :: [Char]} deriving (Show)

instance Eq Individuo where
    (i1) == (i2) = fitness i1 == fitness i2

instance Ord Individuo where
    (i1) `compare` (i2) = fitness i2 `compare` fitness i1

-- Funcoes de validacao.
isValid :: (Int, Int) -> [[Char]] -> Bool
isValid (a, b) m = (0 <= a) && (a < length m) && (0 <= b) && (b < length m) 

isAWall :: (Int, Int) -> [[Char]] -> Bool
isAWall (a, b) m = (m !! a) !! b == wallIcon

isExit :: (Int, Int) -> [[Char]] -> Bool
isExit (a, b) m = (isValid (a, b) m) && (m !! a) !! b == 'E'

isValidMove :: (Int, Int) -> [[Char]] -> Bool
isValidMove (x, y) m = (isValid (x, y) m) && not (isAWall (x, y) m)

-- Funcoes de movimento
getRandomInteger :: (Int,Int) -> Int
getRandomInteger (a,b) = unsafePerformIO (randomRIO (a,b))

sumVectors :: (Num a) => (a, a) -> (a, a) -> (a, a)  
sumVectors (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

makeAMove :: (Int, Int) -> Char -> (Int, Int)
makeAMove (x, y) m =
    let move = getMove m
    in sumVectors (x, y) move

randomMove :: Int -> Char
randomMove num 
    | num == 0 = 'U'
    | num == 1 = 'D'
    | num == 2 = 'L'
    | num == 3 = 'R'

randomList :: Int -> [Int]
randomList size = [getRandomInteger (0,3) | _ <- [1..size]]

randomMoves :: Int -> [Char]
randomMoves n = map randomMove (randomList n)

-- Funcoes auxiliares
numOfWalls :: [[Char]] -> Int
numOfWalls xxs = sum [sum [1 | x <- xs, x == wallIcon ]| xs <- xxs]

coherentMoves :: Char -> Char
coherentMoves move
        | move == 'D' = ['D','R','L'] !! (getRandomInteger (0,2))
        | move == 'U' = ['U','R','L'] !! (getRandomInteger (0,2))
        | move == 'R' = ['R','D','U'] !! (getRandomInteger (0,2))
        | move == 'L' = ['L','D','U'] !! (getRandomInteger (0,2))

getMove 'U' = (-1, 0)
getMove 'D' = (1, 0)
getMove 'L' = (0, -1)
getMove 'R' = (0, 1)

-- Funcoes de inicializacao
buildIndividuo :: Int -> Individuo
buildIndividuo chromossomeSize = newIndividuo
                where
                    fitness = 10^6
                    moves = randomMoves chromossomeSize
                    newIndividuo = Individuo fitness moves

initPopulation :: Int -> [Individuo]
initPopulation chromossomeSize = [ (buildIndividuo chromossomeSize) | _ <- [1..populationSize]]

-- Funcoes de impressao
drawMaze :: [[Char]] -> [Char]
drawMaze [] = ""
drawMaze (x:xs) = x ++ "\n" ++ (drawMaze xs)

drawFittest :: [[Char]] -> (Int,Int) -> Int -> [[Char]]
drawFittest maze (x,y) size = [[drawFittestAux maze (x,y) (j,i) | i <- [0..size-1]] | j <- [0..size-1]]

drawFittestAux :: [[Char]] -> (Int,Int) -> (Int,Int) -> Char
drawFittestAux maze (x,y) (i,j)
    |x == i && y == j = '*'
    |x /= i || y /= j = (maze !! i) !! j


-- Funcoes do algoritmo genetico
mutation :: [Char] -> [Char]
mutation individual
    | prob <= mutationChance && prob <= mutationChance `div` 2  = moveFlip individual (getRandomInteger (1,half(half individualSize)))
    | prob <= mutationChance && prob > mutationChance `div` 2 = moveAppend (reverse individual) (getRandomInteger (1,individualSize `div` 2))
    | otherwise = individual
    where prob = getRandomInteger (1,100)
          individualSize = length individual

moveAppend :: [Char] -> Int -> [Char]
moveAppend individual 0 = reverse individual
moveAppend (x:xs) n = moveAppend ((coherentMoves x) : x : xs) (n-1)

moveFlip :: [Char] -> Int -> [Char]
moveFlip individual n  | n == 0 = individual
                        | otherwise = moveFlip [moveFlipAux individual i (getRandomInteger (0,(length individual) -1)) | i <- [0..((length individual)-1)]] (n-1)

moveFlipAux :: [Char] -> Int -> Int -> Char
moveFlipAux individual x target
        | x == target = coherentMoves (individual !! x)
        | x /= target = individual !! x

calculateRecursive :: [Char] -> (([[Char]], [[Int]]),((Int, Int), (Int, Int))) -> Int -> [(Int, Int)] -> Int
calculateRecursive [] ((maze, mazeDists), (position,exit)) f visited = 
    f - (((mazeDists !! (fst position)) !! (snd position)) * 10000)
calculateRecursive (m:ms) ((maze, mazeDists), (position,exit)) f visited = 
        let newPos = makeAMove position m
        in if isExit newPos maze
            then f*10^6
            else if isValidMove newPos maze--Movimento valido
            then if newPos `elem` visited 
                then calculateRecursive (ms) ((maze,mazeDists), (newPos,exit)) (f-500) visited -- Movimento valido e visitado.
                else calculateRecursive (ms) ((maze,mazeDists), (newPos,exit)) (f-200) (newPos:visited) -- Movimento valido e nao visitado.
            else if newPos `elem` visited --Movimento invalido
                then calculateRecursive (ms) ((maze,mazeDists), (position,exit)) (f-700) visited -- Movimento invalido e visitado.
                else calculateRecursive (ms) ((maze,mazeDists), (position,exit)) (f-400) (newPos:visited) -- Movimento invalido e nao visitado.

calculateFitnessIndividual :: Individuo -> (([[Char]], [[Int]]),((Int, Int), (Int, Int))) -> Int
calculateFitnessIndividual ind tuple = calculateRecursive (moves ind) tuple (fitness ind) []
                
calculateFitness :: [Individuo] -> (([[Char]], [[Int]]),((Int, Int), (Int, Int))) -> [Individuo]
calculateFitness xs tuple = [Individuo (calculateFitnessIndividual x tuple) (moves x) | x <- xs]

groupsChance = [0.5, 0.25, 0.15, 0.08 , 0.02]
groupsArray = initGroupsArray
groups = [(0, 10), (11, 250), (251, 400), (401, 750), (751, 1000)]


-- INIT GROUP CHANCE
initGroupsArray :: [Int]
initGroupsArray =
    initGroupsArray' groupsChance [] 1

initGroupsArray' :: [Float] -> [Int] -> Int -> [Int]
initGroupsArray' (chance:groupsChance) groupsArray n =
    initGroupsArray' groupsChance ((replicate (round (chance * 100)) n) ++ groupsArray) (n+1)

initGroupsArray' [] groupsArray _ = groupsArray

{-
quartil = [round $ fromIntegral(populationSize) * 0.01, round $ fromIntegral(populationSize) * 0.25, round $ fromIntegral(populationSize) * 0.4, round $ fromIntegral(populationSize) * 0.75]
groups = [(0, quartil !! 0), ((quartil !! 0) + 1, quartil !! 1), ((quartil !! 1) + 1, quartil !! 2), ((quartil !! 2) + 1, quartil !! 3), ((quartil !! 3) + 1, quartil !! 4)]
-}
crossover :: [Individuo] -> [Individuo] -> [String] -> Int -> Int -> [Individuo]
crossover population newPopulation chromossomeSet n chromossomeSize
    | n < populationSize =
        let newMoves = crossoverIndividuo population chromossomeSize
        --in if newMoves `elem` chromossomeSet
            --then crossover population newPopulation chromossomeSet n chromossomeSize 
        in crossover population ((Individuo (10^6) (mutation newMoves)):newPopulation) (newMoves:chromossomeSet) (n+1) chromossomeSize
    | otherwise = newPopulation



crossoverIndividuo :: [Individuo] -> Int -> [Char]
crossoverIndividuo population chromossomeSize =
    let pairL = (groups !! ((groupsArray !! 90) - 1))
        pairR = (groups !! ((groupsArray !! 45) - 1))
        l1 = fst pairL
        l2 = snd pairL
        r1 = fst pairR
        r2 = snd pairR
        daddy = moves (population !! getRandomInteger(l1, l2))
        mommy = moves (population !! getRandomInteger(r1, r2))
    in crossoverParents mommy daddy chromossomeSize

half :: Int -> Int
half x = floor $ fromIntegral(x) / 2

crossoverParents :: [Char] -> [Char] -> Int -> [Char]
crossoverParents mommy daddy chromossomeSize = 
    let halfMommy = [mommy !! x | x <- [0..half((length mommy) - 1)]]
        halfDaddy = [daddy !! y | y <- [(half (length mommy))..((length daddy)-1)]]
        son = halfMommy ++ halfDaddy
    in [son !! x | x <- [0..(chromossomeSize - 1)]]


{-
crossoverParents :: Int -> [Char] -> [Char] -> Int -> [Char]
crossoverParents crossoverPoint mommy daddy chromossomeSize = 
    let pointLessThanMommy = crossoverPoint < length mommy
        pointLessThanDaddy = length daddy <= chromossomeSize    
    in case (pointLessThanMommy, pointLessThanDaddy) of
        (True, True) ->  [mommy !! x | x <- [0..(crossoverPoint - 1)]] ++ [if y == crossoverPoint then coherentMoves $ mommy !! (crossoverPoint - 1) else daddy !! y | y <- [crossoverPoint..((length daddy) - 1)]]
        (True, False) -> [mommy !! x | x <- [0..(crossoverPoint - 1)]] ++ [if y == crossoverPoint then coherentMoves $  mommy !! (crossoverPoint - 1) else daddy !! y | y <- [crossoverPoint..(chromossomeSize-1)]]
        (False, True) -> [mommy !! x | x <- [0..(length mommy - 1)]] ++ [if y == crossoverPoint then coherentMoves $ (last mommy) else daddy !! y | y <- [crossoverPoint..(length daddy - 1)]]
        (False, False) -> [mommy !! x | x <- [0..(length mommy - 1)]] ++ [if y == crossoverPoint then coherentMoves $  mommy !! (crossoverPoint - 1) else daddy !! y | y <- [crossoverPoint..(chromossomeSize-1)]]

-}

{-
crossoverMommy crossoverPoint mommy
    | crossoverPoint < length mommy = [mommy !! x | x <- [0..crossoverPoint]]
    | otherwise = [mommy !! x | x <- [0..(length mommy - 1)]]


crossoverMommy :: Int -> Int -> String -> String -> String
crossoverMommy _ _ [] son = son
crossoverMommy n crossoverPoint (move:mommy) son
    | n < crossoverPoint = crossoverMommy (n+1) crossoverPoint mommy (son ++ [move])
    | otherwise = son

-- n = length son

crossoverDaddy :: Int -> Int -> String -> String -> String
crossoverDaddy _ _ [] son = son
crossoverDaddy n crossoverPoint (move:daddy) son
    | n == crossoverPoint = crossoverDaddy (n+1) crossoverPoint daddy (son ++ [coherentMoves $ last son])
    | n < chromossomeSize = crossoverDaddy (n+1) crossoverPoint daddy (son ++ [move])
    | otherwise = son
-}