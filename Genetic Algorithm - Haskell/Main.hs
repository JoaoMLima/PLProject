import GA
import System.Process as SP
import System.IO.Unsafe

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
    
    generate True
    
    putStrLn "Size of Population: "
    populationSize <- readLn :: IO Int

    let oPai = generations initPopulation
    print ""

limitOfGenerations = 1000

generations :: Int -> [Individuo] -> [Individuo]
generations 1000 _ = []
generations gen population = do
    putStr (show gen ++ " ")
    let sortedNewPopulation = sortByFitness (calculateFitness population)
    let finished = isFinished sortedNewPopulation
    if finished
        then return [head sortedNewPopulation]
        else generations (gen + 1) crossover (sortedNewPopulation)

-- [moves idv | idv <- sort $ population]



isFinished :: [Individuo] -> Bool
isFinished [] = False
isFinished (ind:inds) | getFitness ind > 10^8 = True
                      | otherwise = False


getFitness :: Individuo -> Integer
getFitness (Individuo fitness _) = fitness

generate gen =
    let numOfWall = mazeSize * mazeSize
    in if gen == True
        then do
            --initVariables
            --mazeGenerator
            drawMaze maze
            putStrLn "Generate new maze?(y/n): "
            resposta <- getLine
            if resposta == "y"
                then generate True
                else return False
        else return False

adjustMazeSize :: Int -> Int
adjustMazeSize num | (num <= 2) = 3
                   | (num `mod` 2) == 0 = num + 1
                   | otherwise = num

