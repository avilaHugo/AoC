import System.Environment
import Data.List (sort, group)
import qualified Data.Map.Strict as M
import Data.Maybe

-- Load this on ghci and pass the input file path as arguments
-- Ex: ghci> day1Pt1 "/path/to/input/file.txt"
createMap :: (Ord a) => [a] -> M.Map a Int
createMap xs = M.fromList $ map (\x -> (head x, length x)) $ group $ sort xs

lookupZeroDefault :: Int -> M.Map Int Int -> Int
lookupZeroDefault x d = fromMaybe 0 (M.lookup x d)

day1Pt1 :: String -> IO ()
day1Pt1 filename = do
    content <- readFile filename
    let rows = map (map read . words) (lines content) :: [[Int]]
        column1 = sort $ map head rows
        column2 = sort $ map (head . tail) rows
        differences = map abs $ zipWith (-) column2 column1
    print $ sum differences

day1Pt2 :: String -> IO ()
day1Pt2 filename = do
    content <- readFile filename
    let rows = map (map read . words) (lines content) :: [[Int]]
        numbers_col = sort $ map head rows
        freqs_col = createMap $ map (head . tail) rows
        similarities = map (\x -> (x * (lookupZeroDefault x freqs_col))) numbers_col
    print $ sum similarities
