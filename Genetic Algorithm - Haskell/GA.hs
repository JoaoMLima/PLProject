-- Generate a random number given a range.
import System.Process as SP
import System.IO.Unsafe
import System.Random
import Data.List

-- Variaveis iniciais
populationSize = 40;
chromossomeSize = mazeSize^2 - numOfWalls maze
mazeSize = 5
wallIcon = '#'
spawn = (3,3)
exit = (4,1)
maze = [['#', '#', '#', '#', '#'],
        ['#', ' ', ' ', ' ', 'E'],
        ['#', ' ', '#', '#', '#'],
        ['#', ' ', ' ', 'S', '#'],
        ['#', '#', '#', '#', '#']]

data Individuo = Individuo {fitness :: Integer, moves :: [Char]} deriving (Show)

instance Eq Individuo where
    (i1) == (i2) = fitness i1 == fitness i2

instance Ord Individuo where
    (i1) `compare` (i2) = fitness i1 `compare` fitness i2

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