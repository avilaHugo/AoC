parseIntTable :: String -> [[Int]]
parseIntTable content =
    map (map (\x -> read x :: Int)) $ map words $ lines content

predicateSequence :: (Int -> Int -> Bool) -> [Int] -> Bool
predicateSequence predicate xs = foldl1 (&&) $ map (uncurry predicate) $ zip xs (tail xs)

isIncOrDec :: [Int] -> Bool
isIncOrDec xs = foldl1 (||) $ map (\p -> predicateSequence p xs) $ [(<=), (>=)]

isChangingBy :: (Int -> Bool) -> [Int] -> Bool
isChangingBy p xs = foldl1 (&&) $ map (p) $ map (abs . uncurry (-)) $ zip xs (tail xs)

isValidRecord :: [Int] -> Bool
isValidRecord x = isIncOrDec x && isChangingBy (\y -> y > 0 && y <= 3) x

day2Pt1 :: String -> IO ()
day2Pt1 filename = do
    content <- readFile filename
    let result = length $ filter isValidRecord $ parseIntTable content
    print result

