module Games where
import Modal
import Programs

data FiveOrTen = Ten | Five deriving (Eq, Ord, Read, Enum)
instance Show FiveOrTen where
  show Ten = "10"
  show Five = "5"

fiveAndTen :: ModalProgram FiveOrTen FiveOrTen
fiveAndTen Five = Var Five
fiveAndTen Ten = Var Ten


data NewcombAction = OneBox | TwoBox deriving (Eq,Ord,Read,Enum)
instance Show NewcombAction where
  show OneBox = "1"
  show TwoBox = "2"
data NewcombOutcome = MillionThousand | Million | Thousand | Naught
  deriving (Eq,Ord,Show,Read,Enum)

onebox, twobox :: ModalFormula NewcombAction
onebox = Var OneBox
twobox = Neg onebox

newcomb :: Int -> ModalProgram NewcombAction NewcombOutcome
newcomb k MillionThousand = twobox %^      boxk k onebox
newcomb k Million         = onebox %^      boxk k onebox
newcomb k Thousand        = twobox %^ Neg (boxk k onebox)
newcomb k Naught          = onebox %^ Neg (boxk k onebox)


data AorB = A | B deriving (Eq,Ord,Show,Read,Enum)
data GoodOrBad = Good | Bad deriving (Eq,Ord,Show,Read,Enum)

doesA, doesB :: ModalFormula AorB
doesA = Var A
doesB = Neg doesA

aGame :: Int -> ModalProgram AorB GoodOrBad
aGame k Good = boxk k doesA
aGame k Bad  = Neg (boxk k doesA)

bGame :: Int -> ModalProgram AorB GoodOrBad
bGame k Good = boxk k doesB
bGame k Bad  = Neg (boxk k doesB)


data Strangeverse = StrangeTen | StrangeFive | StrangeZero deriving (Eq,Ord,Show,Read,Enum)
data Strangeact = Alpha | Beta deriving (Eq,Ord,Show,Read,Enum)

doesAlpha, doesBeta :: ModalFormula Strangeact
doesAlpha = Var Alpha
doesBeta  = Neg doesAlpha

strangeverse :: Int -> ModalProgram Strangeact Strangeverse
strangeverse k StrangeTen  = doesAlpha %^ boxk k doesBeta
strangeverse _ StrangeFive = doesBeta
strangeverse k StrangeZero = doesAlpha %^ Neg (boxk k doesBeta)


main :: IO ()
main = do
  print $ evalUDT 0 fiveAndTen Five
  putStrLn ""
  putStrLn "In Newcomb's problem, if the predictor uses a box to predict"
  putStrLn "the agent's action, UDT takes whatever its default action was:"
  print $ evalUDT 0 (newcomb 0) OneBox
  print $ evalUDT 0 (newcomb 0) TwoBox
  putStrLn ""
  putStrLn "This is the modal formula that's true if UDT one-boxes:"
  print $ udt 0 (newcomb 0) OneBox OneBox
  putStrLn ""
  putStrLn "These are the modal formulas for UDT in the newcomb problem:"
  print $ progToMap $ udt 0 (newcomb 0) OneBox
  where evalUDT level univ = evalProgram . udt level univ