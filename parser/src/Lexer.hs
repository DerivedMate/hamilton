module Lexer where
import Data.List
import Data.Char
import Data.Maybe
import Helpers
import Control.Applicative
import Grammar

combineLexemes :: Lexeme -> Lexeme -> Maybe Lexeme
combineLexemes (Part a) (Part b)  
  = Just (Part ( a <> " " <> b ))
  
combineLexemes p q
  | (Alias a, Alias b) <- (p, q)
  = f a b
  | (Alias a, Part  b) <- (p, q)
  = f a b
  | (Part  a, Alias b) <- (p, q)
  = f a b
  where f a b = Just (Alias ( a <> " " <> b ))
  
combineLexemes (Connector Comma) (Connector Amp) 
  = Just ( Connector ComAmp )
combineLexemes _ _ 
  = Nothing  

lexemeOfString :: String -> Lexeme
lexemeOfString s = 
  (   Connector   <$> check cDict 
  <|> Parenthesis <$> check pDict
  <|> Alias       <$> check aDict
  ) ?> Part s
  where 
    check = lookup $ toLower <$> s
    cDict = [ ( "except", Except    )
            , ( "with"  , With      )
            , ( "and"   , And       )
            , ( ","     , Comma     )
            , ( "/"     , Slash     )
            , ( "&"     , Amp       )
            , ( ",&"    , ComAmp    )
            , ( ":"     , Semicolon )
            ]
    pDict = [ ( "("     , Open      )
            , ( ")"     , Close     )
            ]
    aDict = [ "both"
            , "company"
            , "full company"
            , "men"
            , "all men"
            , "women"
            , "all women"
            , "ensemble"
            , "ensemble 1"
            , "ensemble 2"
            ] `zip` repeat s

lex' :: String -> Maybe (Lexeme, String)
lex' s
  | (l, r) : _ <- p
  , not (null l)
  = Just (lexemeOfString l, r)
  | otherwise
  = Nothing
  where p = lex s

lexer :: String -> [Lexeme]
lexer s 
  | Just (prev0, r0) <- lex' s
  = aux prev0 r0 []
  | otherwise
  = [EOI]
  where
    aux :: Lexeme -> String -> [Lexeme] -> [Lexeme]
    aux prev r agr
      | Just (l, r') <- cl
      , Just l'      <- combineLexemes prev l
      = aux l' r' agr
      | Just (l, r') <- cl
      = aux l r' (prev : agr)
      | otherwise
      = reverse (EOI : prev : agr)
      where 
        cl = lex' r