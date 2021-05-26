module LexerV2 where
import Data.List
import Data.Char
import Data.Maybe
import Helpers
import Control.Applicative
import Grammar

combineLexemes :: Lexeme -> Lexeme -> Maybe Lexeme
combineLexemes (Part a) (Part b)  
  = Just (Part ( a <> " " <> b ))
combineLexemes (Connector Comma) (Connector Amp) 
  = Just ( Connector ComAmp )
combineLexemes _ _ 
  = Nothing  

lexemeOfString :: String -> Lexeme
lexemeOfString s = 
  ( Connector <$> check dict 
              <|> check pDict
  ) ?> Part s
  where 
    s'    = toLower <$> s
    check = lookup s'
    dict  = [ ("except", Except   )
            , ("with"  , With     )
            , ("and"   , And      )
            , ("both"  , Both     )
            , (","     , Comma    )
            , ("/"     , Slash    )
            , ("&"     , Amp      )
            , (",&"    , ComAmp   )
            , (":"     , Semicolon)
            ]
    pDict = [ ("(", Parenthesis Open )
            , (")", Parenthesis Close)
            ]

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
  = []
  where
    aux :: Lexeme -> String -> [Lexeme] -> [Lexeme]
    aux prev r agr
      | Just (l, r') <- cl
      , Just l'      <- combineLexemes prev l
      = aux l' r' agr
      | Just (l, r') <- cl
      = aux l r' (prev:agr)
      | otherwise
      = reverse (prev:agr)
      where 
        cl = lex' r