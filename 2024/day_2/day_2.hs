parseIntTable :: String -> [[Int]]
parseIntTable content =
    map (map (\x -> read x :: Int)) $ map words $ lines content

toPairs :: [Int] -> [(Int, Int)]
toPairs xs = zip xs $ tail xs

checkIsSorted :: (Int -> Int -> Bool) -> [Int] -> [Bool]
checkIsSorted pred xs = map (uncurry pred) $ toPairs xs

checkDiff :: (Int -> Bool)-> [Int] -> [Bool]
checkDiff pred xs = map (pred . abs . uncurry (-)) $ toPairs xs

applyFilters :: [Int] -> [[Bool]]
applyFilters xs = map (\x -> x xs) [checkIsSorted (<=), checkIsSorted (>=), checkDiff (\x -> (0 < x) && (x <= 3))]

part1Filter :: [Int] -> Bool
part1Filter xs = (\[a, b, c] -> (a || b) && c) $ (map and . applyFilters) xs

removeNth :: Int -> [a] -> [a]
removeNth n xs = take n xs ++ drop (n + 1) xs

errorFilter :: Int -> [Int] -> Bool
errorFilter _ [] = False
errorFilter x xs
    | part1Filter (removeNth x xs) = True
    | x >= (length xs) = False
    | otherwise = errorFilter (x+1) xs

-- Solve day 2 pt 1 
day2Pt1 :: String -> IO ()
day2Pt1 filename = do
    content <- readFile filename
    let result = sum $ map fromEnum $ map part1Filter $ parseIntTable content
    print result

-- Solve day 2 pt 2
day2Pt2 :: String -> IO ()
day2Pt2 filename = do
    content <- readFile filename
    let result = sum $ map (fromEnum . (errorFilter (-1))) $ parseIntTable content
    print result

