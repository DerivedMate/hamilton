module Parser where
import Data.Aeson

data ( ToJSON elemT
     , ToJSON operatorT 
     , Ord    operatorT
     ) =>
  AST elemT operatorT 
  = N0 
  | N1 { elem  :: elemT }
  | N3 { op    :: operatorT 
       , left  :: AST elemT operatorT
       , right :: AST elemT operatorT
       }
  deriving (Eq, Show)

insertNode :: AST e o -> AST e o -> AST e o
insertNode = undefined

