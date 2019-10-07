# logica

logica is a Prolog subset DSL running on Factor.


## Usage

```
USE: logica

LOGIC-PREDS: cat mouse animal ;
LOGIC-VARS: X Y ;
SYMBOLS: Tom Jerry Nibbles ;
```

```
{ cat Tom } semper
{ mouse Jerry } semper
{ mouse Nibbles } semper
```

```
{ cat Tom } query .
t
```
```
{ cat Jerry } query .
f
```

```
{ mouse X } query .
{ H{ { X Jerry } } H{ { X Nibbles } } }
```

```
{ animal X } { cat X } si
```

```
{ animal Y } query .
{ H{ { Y Tom } } }
```

```
{ animal X } {
    { mouse X }
} si
```

```
{ animal Y } {
    { cat Y } vel { mouse Y }
} si
```

```
{ animal X } query .
{ H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } }
```


```
{ animal Y } 2 query-n .
{ H{ { Y Tom } } H{ { Y Jerry } } }
```

