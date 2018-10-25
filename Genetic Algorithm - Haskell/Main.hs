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

    let population = initPopulation
    print "2"

limitOfGenerations = 1000

generations :: Int -> Bool -> Bool
generations 1000 _ = False
generations gen _ = do
    putStr (show gen ++ " ")
    let sortedNewPopulation = sortByfitness (calculateFitness population)
    let individualsWhoFinished = finished sortedNewPopulation
    

finished :: [Individuo] -> [Individuo]
finished [] [] = []
finished (ind:inds) | (getFitness ind) > 10^8 = [ind] ++ finished inds
                    | otherwise = finished inds

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

