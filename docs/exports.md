# AST
## Mode
Compiles to strings.
```hs
data Mode 
  = MSpeaker 
  | MAlias
```

## Connector
```hs
data Connector
  = Comma
  | Amp
  | ComAmp
  | Slash
  | Semicolon
  | Except 
  | With 
  | And 
  | Manner
```
## Operator
```hs
data Operator 
  = Operator { name   :: Connector
             , weight :: Int
             }
```
Ref.:
1. [Connector](#connector)


## AST Internal
```hs
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

type AST' = AST String Operator Mode
```
Ref.:
1. [Operator](#operator)
2. [Mode](#mode)  


## AST Compiled
All node types can be differentiated through their common property - `node :: Int`, such that:
```
  Ni { ... } -> { node : i, ... }
```
  
```ts
interface N0 
  { node : 0 }

interface N1 
  { node : 1
  , el   : String
  }

interface N2
  { node : 2
  , mode : Mode
  , item : AST
  }

interface N3 
  { node  : 3
  , op    : Operator
  , left  : AST
  , right : AST
  }

type AST 
  = N0 | N1 | N2 | N3
```
Ref.:
1. [Operator](#operator)
2. [Mode](#mode)   


# Lyrics
## Line
```hs
data Line
  = Line { speakers :: AST'
         , text     :: [String]
         }
```
Ref.:
1. [AST](#ast-compiled)


## Song
```hs
data Song = 
  Song { title  :: String
       , lyrics :: [Line]
       , origin :: String
       , i      :: Int
       }
```  

Ref.:
1. [Line](#line) 
