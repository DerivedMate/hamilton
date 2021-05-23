# Notes
[notes](./notes.md)
# Conjunction
## Harmonic
This type of conjunction is used to denote multiple speakers singing at the same time. For instance:  

> [(Right Hand Man)](https://youtu.be/0JR0ApUALOQ?t=41)  
> [ HAMILTON/BURR/MULLIGAN/LAURENS/LAFAYETTE ]  
> Rise up!

or when Laurens, and Mulligan accompany Washington; the two sing the same lines, in harmony, yet they intertwine with Washington:  

> [(History Has Its Eyes on You)](https://youtu.be/-nmqQlW-sMo?t=24)  
> [ WASHINGTON & LAURENS/MULLIGAN ]  
> Knowing history has its eyes on me **(Whoa…)**  
> **Whoa…**  
> **Whoa…**  
> **Yeah**  
  
```
  [ <speaker>/<speaker> ] 
    => Conj.Harm[ Speaker[S0] , Speaker[S1] ]

  [ <speaker> & <speaker>/<speaker> ]
    => Conj.Dist[ Speaker[S0] , Conj.Harm[Speaker[S1], Speaker[S2]] ]
```


## Distinguishable
First type of use can be heard in *"Alexander Hamilton"* where the majority is sung by just one speaker (George Washington), yet certain parts are boosted by a side agent - the Company  

> [(Alexander Hamilton)](https://youtu.be/VhinPd5RRJw?t=108)   
> [ GEORGE WASHINGTON & COMPANY, BOTH ]   
> Moved in with a cousin, the cousin committed suicide   
> Left him with nothin' but ruined pride, something new inside   
> A voice saying   
> **“Alex, you gotta fend for yourself.”**   
> He started retreatin' and readin' every treatise on the shelf   

And later in the same song for Burr and the Company: (*just company*, **both**)

> [ BURR & COMPANY, BOTH ]   
> There would have been nothin’ left to do   
> For someone less astute   
> He woulda been dead or destitute   
> Without a cent of restitution   
> Started workin', clerkin' for his late mother's landlord   
> Tradin’ sugar cane and rum and all the things he can’t afford   
> **Scammin'** for every book he can get his hands on   
> **Plannin'** for the future see him now as he stands on (*ooh*)   
> The bow of a ship headed for a new land   
> In New York you can be a new man   

Then, in *Right Hand Man* the two ensembles intertwine:

> [(Right Hand Man)](https://youtu.be/GTGz0--02C4?t=15)   
> [ENSEMBLE 1 & ENSEMBLE 2]   
> Thirty-two thousand troops in New York harbor   
> Thirty-two thousand troops in New York harbor   
> When they surround our troops!   
> They surround our troops!   
> They surround our troops!   
> They surround our troops!   
> When they surround our troops!   

And then the ensemble intertwines with Washington in a distinguishable manner: (**(ensemble)**)
> [(Right Hand Man)](https://youtu.be/0JR0ApUALOQ?t=65)  
> [WASHINGTON & ENSEMBLE]   
> We are outgunned **(What?)**   
> Outmanned **(What?)**   
> Outnumbered  
> Outplanned **(Buck, buck, buck, buck, buck!)**  
> We gotta make an all out stand  
> Ayo, I'm gonna need a right-hand man  
> **(Buck, buck, buck, buck, buck!)**  

It can therefore be concluded that this conjunction denotes multiple speakers intertwining in a distinguishable manner.

```
  [ <speaker> & <speaker> ]
    => Conj.Harm[ Speaker[S0], Speaker[S1] ]

  [ <speaker> & <speaker>/<speaker> ]
    => Conj.Dist[ Speaker[S0] , Conj.Harm[Speaker[S1], Speaker[S2]] ]
```

## Both
Although used only twice in the whole musical, it denotes that the conjunction is both harmonic, and distinguishable. That is to say, both types are mixed in the same line: (**both**)

> [(Alexander Hamilton)](https://youtu.be/VhinPd5RRJw?t=108)  
> [ GEORGE WASHINGTON & COMPANY, BOTH ]  
> Moved in with a cousin, the cousin committed suicide  
> Left him with nothin' but ruined pride, something new inside  
> A voice saying  
> **“Alex, you gotta fend for yourself.”**  
> He started retreatin' and readin' every treatise on the shelf  

```
  [<speaker> & <speaker>, BOTH]
    => Conj.Both[ Speaker[S0] , Speaker[S1] ]
```

# Exclusion
> [(Alexander Hamilton)](https://youtu.be/VhinPd5RRJw?t=105)   
> FULL COMPANY **EXCEPT** HAMILTON (whispering)   
> And Alex got better but his mother went quick

```
  [ <speaker> EXCEPT <speaker> ]
```

# Mode
> [(Alexander Hamilton)](https://youtu.be/VhinPd5RRJw?t=105)   
> FULL COMPANY EXCEPT HAMILTON **(whispering)**   
> And Alex got better but his mother went quick
```
  [ <speaker> (mode) ]
```