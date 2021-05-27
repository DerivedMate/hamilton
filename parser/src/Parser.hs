{-# LANGUAGE OverloadedStrings #-}


module Parser where
import Data.Aeson
import Debug.Trace
import Helpers
import Grammar
import Lexer

data ( ToJSON e
     , ToJSON o 
     , Ord    o
     , ToJSON m
     ) =>
  AST e o m
  = N0
  | N1 { el    :: e }
  | N2 { mode  :: m 
       , item  :: AST e o m
       }
  | N3 { op    :: o 
       , left  :: AST e o m
       , right :: AST e o m
       }
  deriving (Ord, Eq, Show)

instance 
  ( ToJSON e
  , ToJSON o 
  , Ord    o
  , ToJSON m
  ) => ToJSON (AST e o m) where
  toJSON n
    | N0 <- n
    = object [ "node" .= (0 :: Int)]
    | N1 el <- n
    = object [ "node" .= (1 :: Int)
             , "el"   .= el
             ]
    | N2 mode item <- n
    = object [ "node" .= (2 :: Int)
             , "mode" .= mode
             , "item" .= item
             ]
    | N3 op l r <- n
    = object [ "node"  .= (3 :: Int)
             , "op"    .= op
             , "left"  .= l
             , "right" .= r
             ]
 
  toEncoding n
    | N0 <- n
    = pairs ( "node" .= (0 :: Int) )
    | N1 el <- n
    = pairs ( "node" .= (1 :: Int)
           <> "el"   .= el
            )
    | N2 mode item <- n
    = pairs ( "node" .= (2 :: Int)
           <> "mode" .= mode
           <> "item" .= item
            )
    | N3 op l r <- n
    = pairs ( "node"  .= (3 :: Int)
           <> "op"    .= op
           <> "left"  .= l
           <> "right" .= r
            )

type E    = String
type O    = Operator
type M    = Mode
type AST' = AST E O M

appendNode :: AST' -> AST' -> AST'
appendNode a           N0 = a
appendNode N0          a  = a
appendNode (N2 m _)    a  = N2 m a
appendNode (N3 op a _) b  = N3 op a b

(@>) = appendNode

prependNode :: AST' -> AST' -> AST'
prependNode (N3 op _ a) b = N3 op b a
prependNode a           b = appendNode a b

(<@) = prependNode


parse :: [Lexeme] -> (AST', [Lexeme])
parse (val:r) = aux N0 N0 val r
  where
    aux :: AST' -> AST' -> Lexeme -> [Lexeme] 
        -> (AST', [Lexeme])
    aux tree state val r
      {----:
        EOI: Append State to Tree
      :----}
      | EOI    <- val
      = (tree @> state, r)

    aux tree state val r@(val':r')
      {----:
        If val is Part a: 
          Append S(a) to State
      :----}
      | Part a <- val 
      = aux 
        tree 
        (state @> N2 MSpeaker ( N1 a ))
        val'
        r'

      {----:
        If val is Alias a: 
          Append A(a) to State
      :----}
      | Alias a <- val
      = aux
        tree
        (state @> N2 MAlias ( N1 a ))
        val'
        r'

      {----:
        If val is op and ( Tree == N0 or w(op Tree) >= w(val) ):
          Append State to Tree;
          Tree  = N3[ (val), Tree, _ ];
          State = N0
      :----}
      | Just op' <- operatorOfLexeme val
      , tree == N0 
      || (weight . op) tree >= weight op'
      = aux
        (N3 op' ( tree @> state ) N0)
        N0
        val'
        r'
      
      {----:
        If val is op and w(val) > w(op Tree):
          State = N3[ (val), State, _ ]
      :----}
      | Just op' <- operatorOfLexeme val
      , (weight . op) tree < weight op'
      = aux
        tree
        ( N3 op' state N0 )
        val'
        r'

      {----:
        If val is Parenthesis Open:
          (P, R)       = loop
          Tree, State  = { Tree == N0 or [op P is Manner and w(op P) ]
                              then ( prepend (append State to Tree) to P, N0 )
                              else ( Tree, prepend State to P )
                         }
          rest         = R 
      :----}
      | Parenthesis Open <- val
      , (p, val'' : r'') <- aux N0 N0 val' r'
      , insertAll        <- tree == N0 
                         || ( isManner (op p)
                           && (weight . op) p <= (weight . op) tree
                            )
      , (tree', state')  <- if insertAll
                              then (p <@ (tree @> state), N0)
                              else (tree, p <@ state)
      = aux tree' state' val'' r''
      
      {----:
        If val is Parenthesis Close and 
        T'@(append State to Tree) is N(a):
          Tree = N2[(a), _];
          return (Tree, rest)
      :----}
      | Parenthesis Close <- val
      , N2 MSpeaker a     <- tree @> state
      , Just op'          <- operatorOfLexeme (Connector Manner)
      = ( N3 op' N0 a, r )

      {----:
        If val is Parenthesis Close:
          return (append State to Tree, rest)
      :----}
      | Parenthesis Close <- val
      = ( tree @> state, r )
