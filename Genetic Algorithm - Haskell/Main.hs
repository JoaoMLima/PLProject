import GA
import System.Process as SP
import System.IO.Unsafe
import Control.Concurrent
import Data.List


display = do
    putStrLn "#####################################################################################################################"
    putStrLn ".___  ___.      ___      ________   _______         _______.  ______    __      ____    ____  _______ .______      "
    putStrLn "|   \\/   |     /   \\    |       /  |   ____|       /       | /  __  \\  |  |     \\   \\  /   / |   ____||   _  \\     "
    putStrLn "|  \\  /  |    /  ^  \\   `---/  /   |  |__         |   (----`|  |  |  | |  |      \\   \\/   /  |  |__   |  |_)  |    "
    putStrLn "|  |\\/|  |   /  /_\\  \\     /  /    |   __|         \\   \\    |  |  |  | |  |       \\      /   |   __|  |      /     "
    putStrLn "|  |  |  |  /  _____  \\   /  /----.|  |____    .----)   |   |  `--'  | |  `----.   \\    /    |  |____ |  |\\ \\----."
    putStrLn "|__|  |__| /__/     \\__\\ /________||_______|   |_______/     \\______/  |_______|    \\__/     |_______|| _| `._____|"
    putStrLn "\n#####################################################################################################################\n"


clearScreen :: IO ()
clearScreen = do
    SP.system "clear"
    return ()

main = do
    display
    putStr "Size of maze: "
    input <- readLn :: IO Int
    let mazeSize = adjustMazeSize input

    let mazeTuple = unsafePerformIO (generateMaze mazeSize) 
    let maze = getMaze mazeTuple
    let mazeDist = getmazeDists mazeTuple
    let spawn = getSpawn mazeTuple

    let chromossomeSize = (mazeSize^2) - numOfWalls maze
    
    --putStrLn "Size of Population: "
    --let populationSize <- readLn :: IO Int

    generations 0 (initPopulation chromossomeSize) mazeTuple chromossomeSize

    threadDelay 3000000

    dumbGeneration 0 (initPopulation chromossomeSize) mazeTuple chromossomeSize


-- GERAÇÃO BURRAAAAA
dumbGeneration :: Int -> [Individuo] -> (([[Char]], [[Int]]),((Int, Int), (Int, Int))) -> Int -> IO()
dumbGeneration 100 population mazeTuple _ = showSolution (moves (head population)) (getSpawn mazeTuple) (getMaze mazeTuple)
dumbGeneration gen population mazeTuple chromossomeSize = do
    putStr "And now watch the dumb algorithm"
    threadDelay 3000000
    clearScreen
    let sortedNewPopulation = sort (calculateFitness population mazeTuple)
    putStr (show gen ++ " " ++ unlines [moves (head sortedNewPopulation)])
    let finished = checkFinished sortedNewPopulation
    if finished
        then showSolution (moves (head sortedNewPopulation)) (getSpawn mazeTuple) (getMaze mazeTuple)
        else dumbGeneration (gen+1) (initPopulation chromossomeSize) mazeTuple chromossomeSize
 
-- Vai printando os passos do melhor individuo
showSolution :: [Char] -> (Int,Int) -> [[Char]] -> IO()
showSolution [] (x,y) maze = putStrLn (drawMaze $ drawFittest maze (x,y) (length maze))
showSolution (mv:steps) (x,y) maze = do
    putStrLn (drawMaze $ drawFittest maze (x,y) (length maze))
    let newPosition = makeAMove (x,y) mv
    threadDelay 300000
    clearScreen
    if isValidMove newPosition maze
        then showSolution steps newPosition maze
        else showSolution steps (x,y) maze 


getExit :: (([[Char]], [[Int]]),((Int, Int), (Int, Int))) -> (Int,Int)
getExit mazeTuple = snd (snd mazeTuple)

getSpawn :: (([[Char]], [[Int]]),((Int, Int), (Int, Int))) -> (Int,Int)
getSpawn mazeTuple = fst (snd mazeTuple)

getmazeDists :: (([[Char]], [[Int]]),((Int, Int), (Int, Int))) -> [[Int]]
getmazeDists mazeTuple = snd (fst mazeTuple)

getMaze :: (([[Char]], [[Int]]),((Int, Int), (Int, Int))) -> [[Char]] 
getMaze mazeTuple = fst (fst mazeTuple)

generations :: Int -> [Individuo] -> (([[Char]], [[Int]]),((Int, Int), (Int, Int))) -> Int -> IO()
generations 100 population mazeTuple _ = showSolution (moves (head population)) (getSpawn mazeTuple) (getMaze mazeTuple)
generations gen population mazeTuple chromossomeSize = do
    let sortedNewPopulation = sort (calculateFitness population mazeTuple)
    putStr (show gen ++ " " ++ unlines [moves $ head sortedNewPopulation])
    let finished = checkFinished sortedNewPopulation
    if finished
        then showSolution (moves (head sortedNewPopulation)) (getSpawn mazeTuple) (getMaze mazeTuple)
        else generations (gen + 1) (crossover sortedNewPopulation [] [] 0 chromossomeSize) mazeTuple chromossomeSize


checkFinished :: [Individuo] -> Bool
checkFinished [] = False
checkFinished (ind:inds) 
    | (fitness ind) > (10^8) = True
    | otherwise = False

                          

-- Gera e printa maze
generateMaze :: Int -> IO (([[Char]], [[Int]]),((Int, Int), (Int, Int)))
generateMaze mazeSize = do
        let tuple = mazeGenerator mazeSize
        let maze = getMaze tuple
        let mazeDist = getmazeDists tuple
        let spawn = getSpawn tuple
        let exit = getExit tuple

        putStrLn (drawMaze maze)
        putStrLn "Generate new maze?(y/n): "
        resposta <- getLine
        if resposta == "y"
            then generateMaze mazeSize
            else return ((maze,mazeDist),(spawn,exit)) :: IO (([[Char]], [[Int]]),((Int, Int), (Int, Int)))
    
adjustMazeSize :: Int -> Int
adjustMazeSize num | (num <= 2) = 3
                | (num `mod` 2) == 0 = num + 1
                | otherwise = num

--Apenas uma implementacao do operador ternário
ter :: Int -> a -> a -> a
ter i a b = if (i == 0) then b else a 

--Operacoes em matrizes e listas
generateMatrix :: Int -> Int -> t -> [[t]]
generateMatrix n m c = replicate n (replicate m c)

--Troca um elemento da matriz m: m[i][j] = c e retorna a nova matriz
changeMatrix :: Int -> Int -> t -> [[t]] -> [[t]]
changeMatrix i j c m
    | i == 0 = [changeList j c (head m)] ++ tail m
    | otherwise = [head m] ++ (changeMatrix (i-1) j c (tail m))

--Troca um elemento da lista l: l[i] = c e retorna a nova lista
changeList :: Int -> t -> [t] -> [t]
changeList i c l
    | i == 0 = [c] ++ tail l
    | otherwise = [head l] ++ changeList (i-1) c (tail l)

-- Funcoes de aleatoriedade

randomRange :: Int -> Int -> Int -> Int
randomRange start end step = 
    (((getRandomInteger(1,2000000000) `mod` (end - start + 1)) `quot` step) * step) + start

--Gera uma ordem aleatoria para uma sequencia de tamanho n
genShuffledSequence :: Int -> [Int]
genShuffledSequence n = genShuffledSequenceRecursion [0..n-1]

genShuffledSequenceRecursion :: [Int] -> [Int]
genShuffledSequenceRecursion l = 
    if (l == []) then []
    else let n = getRandomInteger(0, (length l)-1) in
        let newL = changeList n (head l) l in [l !! n] ++ genShuffledSequenceRecursion (tail newL)

--Gera um labirinto aleatório de tamanho n x n
--Retorna: Matriz maze, Matriz dists.
mazeGenerator :: Int -> (([[Char]], [[Int]]),((Int, Int), (Int, Int)))
mazeGenerator n =
    let x = randomRange 1 (n-1) 2
        y = getRandomInteger(0, 1) * (n-1)
        s = getRandomInteger(0, 1)
    in let
        coords = ((ter s x y, ter s y x), (ter s x (ter y (y-1) 1), ter s (ter y (y-1) 1) x))
        spawn = (randomRange 1 (n-1) 2, randomRange 1 (n-1) 2)
    in let maze = changeMatrix (fst (snd coords)) (snd (snd coords)) ' ' (changeMatrix (fst (fst coords)) (snd (fst coords)) 'E' (generateMatrix n n '#'))
    in let recur = generateMazeRecursion (fst (snd coords)) (snd (snd coords)) maze (generateMatrix n n 0) 1
    --in (([['A']], [[0]]), ((1, 1), (1, 1)))
    in ((changeMatrix (fst spawn) (snd spawn) 'S' (fst recur), (snd recur)), (spawn, fst coords))

generateMazeRecursion :: Int -> Int -> [[Char]] -> [[Int]] -> Int -> ([[Char]], [[Int]])
generateMazeRecursion x y m d dist = 
    let d0 = changeMatrix x y dist d
        moves = [(1, 0), (0, 1), (-1, 0), (0, -1)]
        ordem = genShuffledSequence 4
        p1x = (x + 2 * (fst (moves !! (ordem !! 0))), x + (fst (moves !! (ordem !! 0))))
        p1y = (y + 2 * (snd (moves !! (ordem !! 0))), y + (snd (moves !! (ordem !! 0))))
        p2x = (x + 2 * (fst (moves !! (ordem !! 1))), x + (fst (moves !! (ordem !! 1))))
        p2y = (y + 2 * (snd (moves !! (ordem !! 1))), y + (snd (moves !! (ordem !! 1))))
        p3x = (x + 2 * (fst (moves !! (ordem !! 2))), x + (fst (moves !! (ordem !! 2))))
        p3y = (y + 2 * (snd (moves !! (ordem !! 2))), y + (snd (moves !! (ordem !! 2))))
        p4x = (x + 2 * (fst (moves !! (ordem !! 3))), x + (fst (moves !! (ordem !! 3))))
        p4y = (y + 2 * (snd (moves !! (ordem !! 3))), y + (snd (moves !! (ordem !! 3))))
    in let v1 = ((isValid (fst p1x, fst p1y) m) && (isAWall (fst p1x, fst p1y) m))
    in let
        m1 = if v1 then (changeMatrix (fst p1x) (fst p1y) ' ' (changeMatrix (snd p1x) (snd p1y) ' ' m)) else m
        d1 = if v1 then (changeMatrix (snd p1x) (snd p1y) (dist+1) d0) else d0
    in let recur1 = if v1 then generateMazeRecursion (fst p1x) (fst p1y) m1 d1 (dist+2) else (m1, d1)
    in let v2 = ((isValid (fst p2x, fst p2y) (fst recur1)) && (isAWall (fst p2x, fst p2y) (fst recur1)))
    in let
        m2 = if v2 then (changeMatrix (fst p2x) (fst p2y) ' ' (changeMatrix (snd p2x) (snd p2y) ' ' (fst recur1))) else fst recur1
        d2 = if v2 then (changeMatrix (snd p2x) (snd p2y) (dist+1) (snd recur1)) else (snd recur1)
        r1 = if v2 then (r1+2) else r1
    in let recur2 = if v2 then generateMazeRecursion (fst p2x) (fst p2y) m2 d2 (dist+2) else (m2, d2)
    in let v3 = ((isValid (fst p3x, fst p3y) (fst recur2)) && (isAWall (fst p3x, fst p3y) (fst recur2)))
    in let
        m3 = if v3 then (changeMatrix (fst p3x) (fst p3y) ' ' (changeMatrix (snd p3x) (snd p3y) ' ' (fst recur2))) else fst recur2
        d3 = if v3 then (changeMatrix (snd p3x) (snd p3y) (dist+1) (snd recur2)) else (snd recur2)
    in let recur3 = if v3 then generateMazeRecursion (fst p3x) (fst p3y) m3 d3 (dist+2) else (m3, d3)
    in let v4 = ((isValid (fst p4x, fst p4y) (fst recur3)) && (isAWall (fst p4x, fst p4y) (fst recur3)))
    in let
        m4 = if v4 then (changeMatrix (fst p4x) (fst p4y) ' ' (changeMatrix (snd p4x) (snd p4y) ' ' (fst recur3))) else fst recur3
        d4 = if v4 then (changeMatrix (snd p4x) (snd p4y) (dist+1) (snd recur3)) else (snd recur3)
    in if v4 then generateMazeRecursion (fst p4x) (fst p4y) m4 d4 (dist+2) else (m4, d4)