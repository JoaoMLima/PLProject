-- Generate a random number given a range.
import System.IO.Unsafe
import System.Random
import Data.List

mazeSize = 5
wallIcon = '#'
maze = [['#', '#', '#', '#', '#'],
        ['#', ' ', ' ', ' ', 'E'],
        ['#', ' ', '#', '#', '#'],
        ['#', ' ', ' ', 'S', '#'],
        ['#', '#', '#', '#', '#']]

getRandomInteger :: (Int, Int) -> Int
getRandomInteger (a, b) = unsafePerformIO (randomRIO (a, b))

isValid :: (Integer, Integer) -> Bool
isValid (a, b) = (0 <= a) && (a < mazeSize) && (0 <= b) && (b < mazeSize) 

isAWall :: (Int, Int) -> Bool
isAWall (a, b) = (maze !! a) !! b == wallIcon

sumVectors :: (Num a) => (a, a) -> (a, a) -> (a, a)  
sumVectors (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

numOfWalls :: [[Char]] -> Int
--numOfWalls maze = sum [[1 | icon <- line, isAWall icon ]| line <- maze]
numOfWalls xxs = sum [sum [1 | x <- xs, x == '#' ]| xs <- xxs]

getMove 'U' = (-1, 0)
getMove 'D' = (1, 0)
getMove 'L' = (0, -1)
getMove 'R' = (0, 1)

randomMove :: Char
randomMove
    | num == 1 = 'U'
    | num == 2 = 'D'
    | num == 3 = 'L'
    | num == 4 = 'R'
    where
        num = getRandomInteger(1, 4)

randomMoves :: Integer -> [Char]
randomMoves size = [randomMove | _ <- [1..size]]

cromossomeSize :: Integer
cromossomeSize = mazeSize^2 - numOfWalls maze - 1

data Individuo = Individuo {fitness :: Integer, moves :: [Char]} deriving (Show)

buildIndividuo :: Individuo
buildIndividuo = newIndividuo
                where
                    fitness = 10^6
                    moves = randomMoves cromossomeSize
                    newIndividuo = Individuo fitness moves

initPopulation :: [Individuo]
initPopulation = [ buildIndividuo | _ <- [1..40]]