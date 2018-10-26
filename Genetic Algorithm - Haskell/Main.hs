import GA
import System.Process as SP
import System.IO.Unsafe
import Control.Concurrent


display = do
    putStrLn "#####################################################################################################################"
    putStrLn ".___  ___.      ___      ________   _______         _______.  ______    __      ____    ____  _______ .______      "
    putStrLn "|   \\/   |     /   \\    |       /  |   ____|       /       | /  __  \\  |  |     \\   \\  /   / |   ____||   _  \\     "
    putStrLn "|  \\  /  |    /  ^  \\   `---/  /   |  |__         |   (----`|  |  |  | |  |      \\   \\/   /  |  |__   |  |_)  |    "
    putStrLn "|  |\\/|  |   /  /_\\  \\     /  /    |   __|         \\   \\    |  |  |  | |  |       \\      /   |   __|  |      /     "
    putStrLn "|  |  |  |  /  _____  \\   /  /----.|  |____    .----)   |   |  `--'  | |  `----.   \\    /    |  |____ |  |\\ \\----."
    putStrLn "|__|  |__| /__/     \\__\\ /________||_______|   |_______/     \\______/  |_______|    \\__/     |_______|| _| `._____|"
    putStrLn "\n#####################################################################################################################\n"

    
maze = [['#', '#', '#', '#', '#'],
    ['#', ' ', ' ', ' ', 'E'],
    ['#', ' ', '#', '#', '#'],
    ['#', ' ', ' ', 'S', '#'],
    ['#', '#', '#', '#', '#']]

mazeSize = 5

clearScreen :: IO ()
clearScreen = do
    SP.system "clear"
    return ()

main = do
    display
    putStr "Size of maze: "
    input <- readLn :: IO Int
    let mazeSize = adjustMazeSize input
    
    -- generateMaze terá que retornar uma lista contendo: o labirinto, spawn e exit.
    let maze = generateMaze mazeSize
    --let spawn = findSpawn maze
    --let exit = findExit maze 
    
    putStrLn "Size of Population: "
    populationSize <- readLn :: IO Int

    let tuple = generations 0 initPopulation
    let lastGeneration = fst tuple
    let bestIndivid = snd tuple
    -- Mostra solução do GA.
    showSolution (moves bestIndivid) spawn maze

    let dumbTuple = dumbGeneration 0 initPopulation
    let dumbGeneration = fst dumbTuple;
    let dumbIndivid = snd dumbTuple;
    --Mostra solução do individuo burro.
    showSolution (moves dumbIndivid) spawn maze

-- GERAÇÃO BURRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA QUE NEM TUA MÃE KKKKKKK
dumbGeneration :: Int -> [Individuo] -> (Int, Individuo)
dumbGeneration 1000 population = (1000, head population)
dumbGeneration gen population = do
    let sortedNewPopulation = sort (calculateFitness population)
    putStr (show gen ++ " " ++ unlines [moves (head sortedNewPopulation)])
    let finished = checkFinished sortedNewPopulation
    if finished
        then return (gen, head sortedNewPopulation)
        else dumbGeneration (gen +1) initPopulation
 
-- Vai printando os passos do melhor individuo
showSolution :: [Char] -> (Int,Int) -> [[Char]] -> IO()
showSolution [] (x,y) maze = print (drawFittest maze (x,y) mazeSize)
showSolution [mv:steps] (x,y) maze = do
    print (drawFittest maze (x,y) mazeSize)
    let newPosition = makeAMove (x,y) mv
    in threadDelay 300000 -- Dormir por 0.3 segundos porque recebe o tempo em microsegundos.
       clearScreen
       showSolution steps newPosition maze


limitOfGenerations = 1000

generations :: Int -> [Individuo] -> (Int, Individuo)
generations 1000 population = (1000,head population)
generations gen population = do
    let sortedNewPopulation = sort (calculateFitness population)
    putStr (show gen ++ " " ++ unlines [moves $ head sortedNewPopulation])
    let finished = checkFinished sortedNewPopulation
    if finished
        then return (gen,head sortedNewPopulation)
        else generations (gen + 1) (crossover (sortedNewPopulation))


checkFinished :: [Individuo] -> Bool
checkFinished [] = False
checkFinished (ind:inds) 
    | getFitness ind > 10^8 = True
    | otherwise = False

-- Gera e printa maze
-- Precisa receber o tamanho do labirinto
generateMaze :: Int -> [[Char]]
generateMaze mazeSize = do
        --initVariables
        --let maze = mazeGenerator mazeSize retorna o labirinto.
        drawMaze maze
        putStrLn "Generate new maze?(y/n): "
        resposta <- getLine
        if resposta == "y"
            then generateMaze mazeSize
            else return maze
    
adjustMazeSize :: Int -> Int
adjustMazeSize num | (num <= 2) = 3
                | (num `mod` 2) == 0 = num + 1
                | otherwise = num