module GA (
    isValid,
    isAWall,
    isExit,
    isValidMove,
    getRandomInteger,
    sumVectors,
    makeAMove,
    randomMove,
    randomList,
    randomMoves,
    numOfWalls,
    coherentMoves,
    buildIndividuo,
    initPopulation,
    drawMaze,
    drawFittest,
    drawFittestAux,
    clearScreen,
    mutation,
    moveAppend,
    moveFlip,
    moveFlipAux,
    calculateRecursive,
    calculateFitnessIndividual,
    calculateFitness
) where 

-- Generate a random number given a range.
import System.Process as SP
import System.IO.Unsafe
import System.Random
import Data.List

-- Variaveis iniciais
populationSize;
chromossomeSize = mazeSize^2 - numOfWalls maze
mutationChance = 50 --Porcentagem de mutação.

data Individuo = Individuo {fitness :: Integer, moves :: [Char]} deriving (Show)

instance Eq Individuo where
    (i1) == (i2) = fitness i1 == fitness i2

instance Ord Individuo where
    (i1) `compare` (i2) = fitness i2 `compare` fitness i1

-- Funcoes de validacao.
isValid :: (Int, Int) -> Bool
isValid (a, b) = (0 <= a) && (a < mazeSize) && (0 <= b) && (b < mazeSize) 

isAWall :: (Int, Int) -> Bool
isAWall (a, b) = (maze !! a) !! b == wallIcon

isExit :: (Int, Int) -> Bool
isExit (a, b) = isValid (a, b) && (maze !! a) !! b == 'E'

isValidMove :: (Int, Int) -> Bool
isValidMove (x, y) = isValid (x, y) && not (isAWall (x, y))

-- Funcoes de movimento
getRandomInteger :: (Int,Int) -> Int
getRandomInteger (a,b) = unsafePerformIO(randomRIO (a,b))    

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
buildIndividuo :: Individuo
buildIndividuo = newIndividuo
                where
                    fitness = 10^6
                    moves = randomMoves chromossomeSize
                    newIndividuo = Individuo fitness moves

initPopulation :: [Individuo]
initPopulation = [ buildIndividuo | _ <- [1..populationSize]]

-- Funcoes de impressao
drawMaze :: [[Char]] -> IO ()
drawMaze = putStrLn . unlines 

drawFittest :: [[Char]] -> (Int,Int) -> Int -> [[Char]]
drawFittest maze (x,y) size = [[drawFittestAux maze (x,y) (j,i) | i <- [0..size-1]] | j <- [0..size-1]]

drawFittestAux :: [[Char]] -> (Int,Int) -> (Int,Int) -> Char
drawFittestAux maze (x,y) (i,j)
    |x == i && y == j = '*'
    |x /= i || y /= j = (maze !! i) !! j

clearScreen :: IO ()
clearScreen = do
    SP.system "clear"
    return ()

-- Funcoes do algoritmo genetico
mutation :: [Char] -> [Char]
mutation individual
    | prob <= mutationChance && prob <= mutationChance `div` 2  = moveFlip individual (getRandomInteger (1,individualSize-1)) 
    | prob <= mutationChance && prob > mutationChance `div` 2 = moveAppend (reverse individual) (getRandomInteger (1,individualSize `div` 2))
    | otherwise = individual
    where prob = getRandomInteger (1,100)
          individualSize = length individual

moveAppend :: [Char] -> Int -> [Char]
moveAppend individual 0 = reverse individual
moveAppend (x:xs) n = moveAppend ((coherentMoves x) : x : xs) (n-1)

moveFlip :: [Char] -> Int -> [Char]
moveFlip individual rand = [moveFlipAux individual i rand | i <- [0..((length individual)-1)]] 

moveFlipAux :: [Char] -> Int -> Int -> Char
moveFlipAux individual x target
        | x == target = coherentMoves (individual !! x)
        | x /= target = individual !! x

calculateRecursive :: [Char] -> (Int, Int) -> Integer -> [(Int, Int)] -> Integer
calculateRecursive [] _ f _ = f
calculateRecursive (m:ms) (x, y) f visited = 
        let newPos = makeAMove (x, y) m
        in if isExit newPos
            then f*10^6
            else if isValidMove newPos --Movimento valido
            then if newPos `elem` visited 
                then calculateRecursive (ms) newPos (f-500) visited -- Movimento valido e visitado.
                else calculateRecursive (ms) newPos (f-200) (newPos:visited) -- Movimento valido e nao visitado.
            else if newPos `elem` visited --Movimento invalido
                then calculateRecursive (ms) (x, y) (f-700) visited -- Movimento invalido e visitado.
                else calculateRecursive (ms) (x, y) (f-400) (newPos:visited) -- Movimento invalido e nao visitado.

calculateFitnessIndividual :: Individuo -> Integer
calculateFitnessIndividual ind = calculateRecursive (moves ind) spawn (fitness ind) []
                
calculateFitness :: [Individuo] -> [Integer]
calculateFitness xs = [calculateFitnessIndividual x | x <- xs]

groupsChance = [0.5, 0.25, 0.15, 0.08 , 0.02]
groupsArray = initGroupsChance

-- INIT GROUP CHANCE
initGroupsChance :: [Int]
initGroupsChance =
    initGroupsChance' groupsChance [] 1

initGroupsChance' :: [Float] -> [Int] -> Int -> [Int]
initGroupsChance' (chance:groupsChance) groupsArray n =
    initGroupsChance' groupsChance ((replicate (round (chance * 100)) n) ++ groupsArray) (n+1)

initGroupsChance' [] groupsArray _ = groupsArray

quartil = [round $ fromIntegral(populationSize) * 0.01, round $ fromIntegral(populationSize) * 0.25, round $ fromIntegral(populationSize) * 0.4, round $ fromIntegral(populationSize) * 0.75]
groups = [(0, quartil !! 0), ((quartil !! 0) + 1, quartil !! 1), ((quartil !! 1) + 1, quartil !! 2), ((quartil !! 2) + 1, quartil !! 3), ((quartil !! 3) + 1, quartil !! 4)]

crossover :: [Individuo] -> [String] -> Integer -> [Individuo]
crossover newPopulation chromossomeSet n
    | n < populationSize =
        let newMoves = crossoverIndividuo
        in if newMoves `elem` chromossomeSet
            then crossover newPopulation chromossomeSet n 
            else crossover ((Individuo 0 newMoves):newPopulation) (newMoves:chromossomeSet) (n+1)
    | otherwise = newPopulation

crossoverIndividuo =
    let pairL = groups !! ((groupsArray !! getRandomInteger(0, 99)) - 1)
        pairR = groups !! ((groupsArray !! getRandomInteger(0, 99)) - 1)
        l1 = fst pairL
        l2 = snd pairL
        r1 = fst pairR
        r2 = snd pairR
        daddy = moves $ population !! getRandomInteger(l1, r1)
        mommy = moves $ population !! getRandomInteger(l2, r2)
        crossoverPoint = getRandomInteger(1, chromossomeSize)
        halfSon = crossoverMommy 0 crossoverPoint mommy ""
    in crossoverDaddy ((length halfSon) - 1) chromossomeSize daddy halfSon
    --completedSon

crossoverParents crossoverPoint mommy daddy
    if crossoverPoint < length 
        then mommy = [mommy !! x | x <- [0..crossoverPoint]]
        else [mommy !! x | x <- [0..(length mommy - 1)]]
        
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