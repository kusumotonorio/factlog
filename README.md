# logica

logica is an embedded language that runs on Factor with the capabilities of a subset of Prolog.

## Usage

```
USE: logica

LOGIC-PREDS: cato mouseo creatureo ;
LOGIC-VARS: X Y ;
SYMBOLS: Tom Jerry Nibbles ;
```
In logica, words that represent relationships are called **predicates**. Use `LOGIC-PREDS:` to declare the predicates you want to use. **Variables** are used to represent relationships. use `LOGIC-VARS:` to declare the variables you want to use.

In the above code, predicates end with the character `o`, which is a convention borrowed from miniKanren and so on, and means relation. This is not necessary, but it is useful for reducing conflicts with the words of, the parent language, Factor. We really want to write them as: `cat°`, `mouse°` and `creature°`, but we use `o` because it's easy to type.

**Goals** are questions that logica tries to meet to be true. To represent a goal, write an array with a predicate followed by zero or more arguments. logica converts such definitions to internal representations.
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
The above code means that Tom is a cat and Jerry and Nibbles are mice. Use `semper` to describe the **facts**.

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
The following code shows that if something is a cat, it's a creature. Use `si` to write **rules**.
```
{ creatureo X } { cato X } si
```
According to the rules above, "Tom is a creature." is answered to the following questions:
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
To tell the truth, we were able to describe at once that cats and mice were creatures by doing the following.
```
LOGIC-PREDS: creatureo ;

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
Use `non` to indicate **negation**. `non` acts on the goal immediately following it.
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
You can also write a quotation that returns an argument as a goal definition argument.
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
Such quotations are called only once when converting the goal definitions to internal representations.

`membero` is a built-in predicate for the relationship an element is in a list.
```
{ membero Jerry L{ Tom Jerry Nibbles } } query .
⟹ t

SYMBOL: Spike
{ membero Spike [ Tom Jerry Nibbles +nil+ cons cons cons ] } query .
⟹ f
```
Recently, they moved into a small house. The house has a living room, a dining room and a kitchen. Well, humans feel that way. Each of them seems to be in their favorite room.
```
TUPLE: house living dining kitchen in-the-wall ;
LOGIC-PREDS: houseo ;

{ houseo T{ house { living Tom } { dining f } { kitchen Nibbles } { in-the-wall Jerry } } } semper
```
Don't worry about not mentioning the bathroom.

Let's ask who is in the kitchen.
```
{ houseo T{ house { living __ } { dining __ } { kitchen X } { in-the-wall __ } } } query .
⟹ { H{ { X Nibbles } } }
```
These two consecutive underbars are called **anonymous variables**. Use in place of a regular variable when you do not need its name and value.

It seems to be meal time. What do they eat?

```
LOGIC-PREDS: is-ao consumeo ;
SYMBOLS: mouse cat milk cheese fresh-milk Emmentaler ;

{ is-ao Tom cat } semper
{ is-ao Jerry mouse } semper
{ is-ao Nibbles mouse } semper
{ is-ao fresh-milk milk } semper
{ is-ao Emmentaler cheese } semper

{ consumeo X milk } {
    { is-ao X mouse } vel
    { is-ao X cat }
} si
{ consumeo X cheese } { is-ao X mouse } si
{ consumeo X mouse } { is-ao X cat } si
```
Let's ask what Jerry consumes.
```
{ { consumeo Jerry X } { is-ao Y X } } query .
⟹ {
        H{ { X milk } { Y fresh-milk } }
        H{ { X cheese } { Y Emmentaler }
    }
```
Well, what about Tom?
```
{ { consumeo Tom X } { is-ao Y X } } query .
⟹ {
        H{ { X milk } { Y fresh-milk } }
        H{ { X mouse } { Y Jerry } }
        H{ { X mouse } { Y Nibbles } }
    }
```
This is a problematical answer. We have to redefine `consumeo`.
```
LOGIC-PREDS: consumeo ;

{ consumeo X milk } {
    { is-ao X mouse } vel
    { is-ao X cat }
} si

{ consumeo X cheese } { is-ao X mouse } si
{ consumeo Tom mouse } { !! f } si 
{ consumeo X mouse } { is-ao X cat } si
```
I wrote about Tom before about common cats. What two consecutive exclamation marks represent is called a **cut operator**. Use the cut operator to suppress backtracking.

The next letter `f` is an abbreviation for goal `{ failo }` using the built-in predicate `failo`. `{ failo }` is a goal that is always `f`. Similarly, there is a goal `{ trueo }` that is always `t`, and its abbreviation is `t`.

By these actions, "Tom consumes mice." becomes false and suppresses the examination of general eating habits of cats.
```
{ { consumeo Tom X } { is-ao Y X } } query .
⟹ { H{ { X milk } { Y fresh-milk } } }
```
It's OK. Let's check a cat that is not Tom.
```
SYMBOL: a-cat
{ is-ao a-cat cat } semper

{ { consumeo a-cat X } { is-ao Y X } } query .
⟹ {
        H{ { X milk } { Y fresh-milk } }
        H{ { X mouse } { Y Jerry } }
        H{ { X mouse } { Y Nibbles } }
    }
```
