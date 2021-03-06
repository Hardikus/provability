module Display where
import Modal
import Data.Map (Map, (!), keys, toAscList)
import qualified Data.Map as Map
import Data.List (transpose)

type Table = [[String]]

padr :: a -> Int -> [a] -> [a]
padr x n xs = xs ++ replicate (n - length xs) x

padl :: a -> Int -> [a] -> [a]
padl x n xs = replicate (n - length xs) x ++ xs

modalBool :: Bool -> String
modalBool True = "⊤"
modalBool False = "⊥"

kripkeTable' :: (Show k, Ord k) => [k] -> Map k [Bool] -> Table
kripkeTable' ks m = listmapToTable ks $ Map.map (map modalBool) m

kripkeTable :: (Show k, Ord k) => Map k [Bool] -> Table
kripkeTable m = kripkeTable' (keys m) m

listmapToTable :: (Show k, Ord k) => [k] -> Map k [String] -> Table
listmapToTable [] _ = []
listmapToTable ks m = header : rows where
  header = "" : "│" : map show ks
  unpaddedCols = map (m !) ks
  cols = map (padr "" $ maximum $ map length unpaddedCols) unpaddedCols
  rows = zipWith addNum [0 :: Int ..] (transpose cols)
  addNum n row = show n : "│" : row

mapToTable :: (Ord k, Show k, Show v) => Map k v -> Table
mapToTable = map (\(k, v) -> [show k, ": ", show v]) . toAscList

displayMap :: (Ord k, Show k, Show v) => Map k v -> IO ()
displayMap = displayTable . mapToTable

squareUp' :: String -> String -> Table -> [[String]]
squareUp' l r rows = map normalizeRow paddedRows where
  paddedRows = map (padr "" $ maxlen rows) rows
  maxlen = foldr (max . length) 0
  normalizeRow = zipWith normalizeCell [0..] where
    normalizeCell i c = l ++ padr ' ' (colwidth i) c ++ r
  colwidth i = maximum [length $ row !! i | row <- paddedRows]

squareUp :: Table -> [[String]]
squareUp = squareUp' " " " "

renderTable :: Table -> String
renderTable table = unlines $ map concat (squareUp table)

displayTable :: Table -> IO ()
displayTable = putStrLn . renderTable

displayKripkeFrames' :: (Show k, Ord k) => [k] -> Map k (ModalFormula k) -> IO ()
displayKripkeFrames' ks = displayTable . kripkeTable' ks . kripkeFrames

displayKripkeFrames :: (Show k, Ord k) => Map k (ModalFormula k) -> IO ()
displayKripkeFrames m = displayKripkeFrames' (keys m) m
