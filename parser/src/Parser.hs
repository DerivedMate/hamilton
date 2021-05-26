module Parser where
import Data.Aeson

data ( ToJSON elemT
     , ToJSON operatorT 
     , Ord    operatorT
     , ToJSON modeT
     ) =>
  AST elemT operatorT modeT
  = N0 
  | N1 { el    :: elemT }
  | N2 { mode  :: modeT 
       , item  :: elemT
       }
  | N3 { op    :: operatorT 
       , left  :: AST elemT operatorT modeT
       , right :: AST elemT operatorT modeT
       }
  deriving (Eq, Show)

insertNode :: AST e o m -> AST e o m -> AST e o m
insertNode = undefined

{-
  weights:
  w(/) > w(and) > w(&) > w(with) > w(,) > w(,&)

  Parser:
  Tree, State, val, rest

  RULES:
  1. If val is Part:
    State = append N1(val) to State
  1A. If val is Alias:
    State = append N1(val) to State

  2. If val is connector and Tree == N0:
    Tree = N3[ (val), State, _ ]
  3. If val is connector and w(val) > w(op Tree):
    State = N3[ (val), State, _ ]
  4. If val is connector and w(val) <= w(op Tree):
    Tree = append State to Tree;
    Tree = N3[ (val), Tree, _ ];
    State = N0

  5. If val is Parenthesis Open:
    (P, R) = loop
    State = append State to P
    rest = R 
  6. If val is Parenthesis Close:
    Tree = append State to Tree
    State = N0
    if Tree == N1(a):     -- Mode
      Tree = N2[(a), _]
    return (Tree, rest)

  Append:
  | N3[(op), A, _], B -> N3[(op), A, B]
  | N2[(op), _]   , A -> N2[(op), A]
-}
