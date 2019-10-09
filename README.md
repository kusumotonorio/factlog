# logica

logica is a subset-Prolog-like DSL running on Factor.


## Usage

```
USE: logica

LOGIC-PREDS: cato mouseo creatureo ;
LOGIC-VARS: X Y ;
SYMBOLS: Tom Jerry Nibbles ;
```
Use `LOGIC-PREDS:` to declare the predicates you want to use. And, use `LOGIC-VARS:` to declare the variables you want to use. The predicates end with the character `o`, which is a convention borrowed from miniKanren and so on, and means relations. This is not necessary, but it is useful for reducing conflicts with the words of, the parent language, Factor. We really want to write them as: `cat°`, `mouse°` and `creature°`, but we use `o` because it's easy to type.

To represent a goal with logica, write an array with a predicate followed by zero or more arguments.
```
{ PREDICATE ARG1 ARG2 ... }
{ PREDICATE }
```
We will write logica programs using these goals.

```
{ cato Tom } semper
{ mouseo Jerry } semper
{ mouseo Nibbles } semper
```
The above code means that Tom is a cat and Jerry and Nibbles are mice. Use `semper` to describe the facts.

```
{ cato Tom } query .
⟹ t
```
The above code asks, "Is Tom a cat?". We said,"Tom is a cat.", so the answer is `t`. The general form of a query is: 
```
{ G1 G2 ... Gn } query
```
The parentheses are omitted because there was only one goal to be satisfied earlier, but here is an example of two goals:
```
{ { cato Tom } { cato Jerry } } query .
⟹ f
```
Tom is a cat, but Jerry is not declared a cat, so `f` is returned in response to this query.

If you query with variable(s), you will get the answer for the variable(s). For such queries, an array of hashtables with variables as keys is returned.
```
{ mouseo X } query .
⟹ { H{ { X Jerry } } H{ { X Nibbles } } }
```
The following code shows that if something is a cat, it's an creature. Use `si` to write rules.
```
{ creatureo X } { cato X } si
```
According to the rules above, "Tom is an creature." is answered to the following questions:
```
{ creatureo Y } query .
⟹ { H{ { Y Tom } } }
```
The general form of `si` is:
```
Gh { Gb1 Gb2 ... Gbn } si
```
This means Gh when all goals of Gb1, Gb2, ..., Gbn are met.
```
LOGIC-PREDS: youngo young-mouseo ;

{ youngo Nibbles } semper

{ young-mouseo X } {
    { mouseo X }
    { youngo X }
} si

{ young-mouseo X } query .
⟹ { H{ { X Nibbles } } }

```

Let's describe that mice are also creatures.

```
{ creatureo X } { mouseo X } si

{ creatureo X } query .
⟹ { H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } }
```
As a matter of fact, we were able to describe at once that cats and mice were creatures by doing the following.
```
{ creatureo Y } {
    { cato Y } vel { mouseo Y }
} si
```
The code below it has the same meaning as the code below it.
```
Gh { Gb1 Gb2 Gb3 vel Gb4 Gb5 vel Gb6 } si
```
```
Gh { Gb1 Gb2 Gb3 } si
Gh { Gb4 Gb5 } si
Gh { Gb6 } si
```

You can use `query-n` to limit the number of answers to a query. Specify a number greater than or equal to 1.
```
{ creatureo Y } 2 query-n .
⟹ { H{ { Y Tom } } H{ { Y Jerry } } }
```
Use `non` to indicate negation. `non` acts on the goal immediately following it.
```
LOGIC-PREDS: likes-cheeseo dislikes-cheeseo ;

{ likes-cheeseo X } { mouseo X } si
{ dislikes-cheeseo Y } {
    { creatureo Y }
    non { likes-cheeseo Y }
} si

{ dislikes-cheeseo Jerry } query .
⟹ f
{ dislikes-cheeseo Tom } query .
⟹ t
```
Other creatures might also like cheese...

You can also use sequences, lists, and tuples as goal definition arguments. The list in Factor is created by a chain of `cons-state` tuples, but you can use a special syntax in logica to describe it.
```
L{ Tom Jerry Nibbles } .
⟹ L{ Tom Jerry Nibbles }
```
The syntax of list descriptions allows you to describe "head" and "tail".
```
L{ HEAD || TAIL }
L{ ITEM1 ITEM2 ITEM3 || OTHERS }
```
You can also write a quotation that returns a single term as a goal definition argument.
```
USE: lists
[ Tom Jerry Nibbles +nil+ cons cons cons ]
```
When written as an argument to a goal definition, the following lines have the same meaning as above:
```
L{ Tom Jerry Nibbles }
L{ Tom Jerry Nibbles || +nil+ }
[ { Tom Jerry Nibbles } >list ]
```
`membero` is a built-in predicate for the relationship an element is in a list.
```
{ membero Jerry L{ Tom Jerry Nibbles } query .
⟹ t

SYMBOL: Spike
{ membero Spike [ Tom Jerry Nibbles +nil+ cons cons cons ] } query .
⟹ f
```
Recently, they moved into a small house. The house has a living room, dining room and kitchen. Well, humans feel that way. Each of them seems to be in their favorite room.
```
TUPLE: house living dining kitchen in-the-wall ;
LOGIC-PREDS: houseo ;
SYMBOL: nobody

{ houseo T{ house { living Tom } { dining nobody } { kitchen Nibbles } { in-the-wall Jerry } } } semper
```
Let's ask who is in the kitchen.
```
{ houseo T{ house { living __ } { dining __ } { kitchen X } { in-the-wall __ } } } query .
```
These two consecutive underbars are called anonymous variables. Use in place of a regular variable when you do not need a name or value.
```
{ houseo T{ house { living __ } { dining __ } { kitchen X } { in-the-wall __ } } } query .
⟹ { H{ { X Nibbles } } }
```
