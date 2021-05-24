module Lexer where

data Enclosing = Open 
               | Close 
               deriving (Eq, Show)

data Keyword = Except 
             | With 
             | And 
             | Both 
             deriving (Eq, Show)

data Token = Part String
           | Parenthesis Enclosing
           | Key Keyword
           | Comma
           | Amp
           | Slash
           | Semicolon 
           deriving (Eq, Show)

{----:
  Check if th given char can constitute a Part
:----}
isWordy :: Char -> Bool
isWordy c = c `elem` ['A'..'Z'] <> ['a'..'z'] <> ['0'..'9']

{----:
  Converts a lowercase string to a keyword
:----}
keywordOfString :: String -> Maybe Keyword
keywordOfString "except" = Just Except
keywordOfString "with"   = Just With
keywordOfString "and"    = Just And
keywordOfString "both"   = Just Both
keywordOfString _        = Nothing


tokenOfChar :: Char -> Token
tokenOfChar '(' = Parenthesis Open
tokenOfChar ')' = Parenthesis Close
tokenOfChar '&' = Amp
tokenOfChar '/' = Slash
tokenOfChar ':' = Semicolon
tokenOfChar c
  | isWordy c = Part [c]
  -- Purposefully left to throw errors in debugging

resolve :: Maybe Token -> Char -> [Token] -> (Maybe Token, [Token])
resolve (Just (Part p)) ' ' tokens = (Just $ Part (p <> " "), tokens)
resolve p ' ' tokens               = (p, tokens)

resolve Nothing c tokens = (Just t, tokens)
    where t = tokenOfChar c

resolve (Just p) c tokens = 
    case (p, t) of
      (Part pp, Part tt)   -> (Just $ Part (pp <> tt), tokens) -- Join parts
      (Part pp, Semicolon) -> (Nothing, tokens)                -- Skip labels
      (Part _ , _)         -> (Just t, p:tokens)               -- End Parts
      


  where t = tokenOfChar c

lex :: String -> [Token]
lex (c:cs) = aux Nothing c cs []
  where
    aux = undefined