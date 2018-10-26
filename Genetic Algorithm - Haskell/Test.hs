import GA

-- Tamanho do filho é determinado pelo chromossomeSize e o tamanho dos pais
chromossomeSize = 8
ind1 = Individuo (10^6) "LDDRULUR"
ind2 = Individuo (10^6) "DUURRLUU"
ind3 = Individuo (10^6) "ULLDDRRL"
ind4 = Individuo (10^6) "DDUULLLU"
ind5 = Individuo (10^6) "UDDDUULL"
ind6 = Individuo (10^6) "DDDLUEEE"
ind7 = Individuo (10^6) "LLUDUURR"
ind8 = Individuo (10^6) "UUULLLLL"
ind9 = Individuo (10^6) "LLUDRRRR"
ind10 = Individuo (10^6) "LLUUDDRR"
population = [ind1, ind2, ind3, ind4, ind5, ind6, ind7, ind8, ind9, ind10]

crossoverIndividuoTeste :: [Individuo] -> Int -> String
crossoverIndividuoTeste population chromossomeSize =
    -- GROUPS = (0, 10), (11, 250), (251, 400), (401, 750), (751, 1000) IN POPULATION = 1000
    let pairL = groups !! ((groupsArray !! 0) - 1) -- 5)
        pairR = groups !! ((groupsArray !! 68) - 1)-- 1)
        l1 = fst pairL -- (751)
        l2 = snd pairL -- (1000)
        r1 = fst pairR -- (0)
        r2 = snd pairR -- (10)
        daddy = moves $ population !! 5 -- (751, 0)
        mommy = moves $ population !! 2 -- (1000, 10)
        crossoverPoint = getRandomInteger(1, chromossomeSize)
        --halfSon = crossoverMommy 0 crossoverPoint mommy ""
    in -- crossoverDaddy ((length halfSon) - 1) chromossomeSize daddy halfSon
        crossoverParents crossoverPoint mommy daddy chromossomeSize
    --completedSon

crossoverParentsTest :: Int -> [Char] -> [Char] -> Int -> [Char]
crossoverParentsTest crossoverPoint mommy daddy chromossomeSize = 
    let pointLessThanMommy = crossoverPoint < length mommy
        pointLessThanDaddy = length daddy <= chromossomeSize    
    in case (pointLessThanMommy, pointLessThanDaddy) of
        (True, True) ->  [mommy !! x | x <- [0..(crossoverPoint - 1)]] ++ [if y == crossoverPoint then coherentMoves $ mommy !! (crossoverPoint - 1) else daddy !! y | y <- [crossoverPoint..((length daddy) - 1)]]
        (True, False) -> [mommy !! x | x <- [0..(crossoverPoint - 1)]] ++ [if y == crossoverPoint then coherentMoves $  mommy !! (crossoverPoint - 1) else daddy !! y | y <- [crossoverPoint..(chromossomeSize-1)]]
        (False, True) -> [mommy !! x | x <- [0..(length mommy - 1)]] ++ [if y == crossoverPoint then coherentMoves $ (last mommy) else daddy !! y | y <- [crossoverPoint..(length daddy - 1)]]
        (False, False) -> [mommy !! x | x <- [0..(length mommy - 1)]] ++ [if y == crossoverPoint then coherentMoves $  mommy !! (crossoverPoint - 1) else daddy !! y | y <- [crossoverPoint..(chromossomeSize-1)]]


main = do
    let mommy = moves ind1
    let daddy = moves ind2
    -- OUTPUT: LDD_RLUU
    putStrLn $ crossoverParentsTest 3 mommy daddy chromossomeSize
    print $ crossoverIndividuoTeste population 8
    putStrLn $ crossoverParentsTest 3 (moves ind2) (moves ind5) chromossomeSize