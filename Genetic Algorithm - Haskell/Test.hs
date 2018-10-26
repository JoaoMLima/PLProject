import GA

-- Tamanho do filho é determinado pelo chromossomeSize e o tamanho dos pais
ind1 = Individuo (10^6) "LDDRULUR"
ind2 = Individuo (10^6) "DUURRLUU"

-- groups = [(0, 10), (11, 250), (251, 400), (401, 750), (751, 1000)]
--groupsArray = [5,5,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,
--1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]

-- crossover _ newPopulation _ populationSize _ =  

crossoverTest :: [Individuo] -> [Individuo] -> Int -> Int -> [Individuo]
crossoverTest population newPopulation n chromossomeSize
    | n < populationSize =
        let newMoves = crossoverIndividuoTest population chromossomeSize 
        in crossoverTest population ((Individuo (10^6) (mutation newMoves)):newPopulation) (n+1) chromossomeSize
    | otherwise = newPopulation

crossoverIndividuoTest :: [Individuo] -> Int -> [Char]
crossoverIndividuoTest population chromossomeSize =
    let pairL = groups !! ((groupsArray !! getRandomInteger(0, 99)) - 1)
        pairR = groups !! ((groupsArray !! getRandomInteger(0, 99)) - 1)
        l1 = fst pairL
        l2 = snd pairL
        r1 = fst pairR
        r2 = snd pairR
        daddy = moves $ population !! getRandomInteger(l1, l2)
        mommy = moves $ population !! getRandomInteger(r1, r2)
        crossoverPoint = getRandomInteger(1, chromossomeSize)
    in crossoverParentsTest crossoverPoint mommy daddy chromossomeSize

crossoverParentsTest :: Int -> [Char] -> [Char] -> Int -> [Char]
crossoverParentsTest crossoverPoint mommy daddy chromossomeSize = 
    let pointLessThanMommy = crossoverPoint < length mommy
        pointLessThanDaddy = length daddy <= chromossomeSize    
    in case (pointLessThanMommy, pointLessThanDaddy) of
        (True, True) ->  [mommy !! x | x <- [0..(crossoverPoint - 1)]] ++ [if y == crossoverPoint then coherentMoves $ mommy !! (crossoverPoint - 1) else daddy !! y | y <- [crossoverPoint..((length daddy) - 1)]]
        (True, False) -> [mommy !! x | x <- [0..(crossoverPoint - 1)]] ++ [if y == crossoverPoint then coherentMoves $  mommy !! (crossoverPoint - 1) else daddy !! y | y <- [crossoverPoint..(chromossomeSize-1)]]
        (False, True) -> [mommy !! x | x <- [0..(length mommy - 1)]] ++ [if y == crossoverPoint then coherentMoves $ (last mommy) else daddy !! y | y <- [crossoverPoint..(length daddy - 1)]]
        (False, False) -> [mommy !! x | x <- [0..(length mommy - 1)]] ++ [if y == crossoverPoint then coherentMoves $  mommy !! (crossoverPoint - 1) else daddy !! y | y <- [crossoverPoint..(chromossomeSize-1)]]

jumpOfCat :: [Individuo] -> [Individuo] -> Int -> [Individuo]
jumpOfCat population newPopulation chromossomeSize = 
    let newMoves = crossoverIndividuoTest population chromossomeSize
    in (Individuo (10^6) newMoves):newPopulation

main = do
    let mommy = moves ind1
    let daddy = moves ind2

    putStrLn (crossoverIndividuoTest (initPopulation 5) 5)
    --print $ jumpOfCat myPopulation [] 5
    -- let myCross = jumpOfCat (initPopulation 5) [] 5
    -- OUTPUT: LDD_RLUU
    putStrLn $ crossoverParentsTest 3 mommy daddy 8
    putStrLn $ crossoverParentsTest 10 "DUURLRUDLR" "L" 10