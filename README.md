# factlog

factlog is an embedded language that runs on [Factor](https://github.com/factor/factor) with the capabilities of a subset of Prolog.

The library that does this is an extended port from tiny_prolog and its descendants, [ruby-prolog](https://github.com/preston/ruby-prolog).

## Usage

```
USE: logic

LOGIC-PREDS: cato mouseo creatureo ;
LOGIC-VARS: X Y ;
SYMBOLS: Tom Jerry Nibbles ;
```
In factlog, words that represent relationships are called **logic predicates**. Use `LOGIC-PRED:` or `LOGIC-PREDS:` to declare the predicates you want to use. **Logic variables** are used to represent relationships. use `LOGIC-VAR:` or `LOGIC-VARS:` to declare the logic variables you want to use.

In the above code, logic predicates end with the character `o`, which is a convention borrowed from miniKanren and so on, and means relation. This is not necessary, but it is useful for reducing conflicts with the words of, the parent language, Factor. We really want to write them as: `cat°`, `mouse°` and `creature°`, but we use `o` because it's easy to type.

**Goals** are questions tried to meet to be true. To represent a goal, write an array with a logic predicate followed by zero or more arguments. Such definitions are coverted to internal representations.
```
{ LOGIC-PREDICATE ARG1 ARG2 ... }
{ LOGIC-PREDICATE }
```
We will write factlog programs using these goals.

```
{ cato Tom } fact
{ mouseo Jerry } fact
{ mouseo Nibbles } fact
```
The above code means that Tom is a cat and Jerry and Nibbles are mice. Use `fact` to describe the **facts**.

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

If you query with logic variable(s), you will get the answer for the logic variable(s). For such queries, an array of hashtables with logic variables as keys is returned.
```
{ mouseo X } query .
⟹ { H{ { X Jerry } } H{ { X Nibbles } } }
```
The following code shows that if something is a cat, it's a creature. Use `rule` to write **rules**.
```
{ creatureo X } { cato X } rule
```
According to the rules above, "Tom is a creature." is answered to the following questions:
```
{ creatureo Y } query .
⟹ { H{ { Y Tom } } }
```
The general form of `rule` is:
```
Gh { Gb1 Gb2 ... Gbn } rule
```
This means `Gh` when all goals of `Gb1`, `Gb2`, ..., `Gbn` are met. This `Gb1 Gb2 ... Gbn` is a **conjunction**.
```
LOGIC-PREDS: youngo young-mouseo ;

{ youngo Nibbles } fact

{ young-mouseo X } {
    { mouseo X }
    { youngo X }
} rule

{ young-mouseo X } query .
⟹ { H{ { X Nibbles } } }

```
This `Gh` is called **head** and the `{ Gb 1Gb 2... Gbn }` is called **body**.

Facts are rules where its body is an empty array. So, the form of `fact` is:
```
Gh fact
```
Let's describe that mice are also creatures.

```
{ creatureo X } { mouseo X } rule

{ creatureo X } query .
⟹ { H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } }
```
To tell the truth, we were able to describe at once that cats and mice were creatures by doing the following.
```
LOGIC-PRED: creatureo

{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule
```
`;;` is used to represent **disjunction**. The following two forms are equivalent:
```
Gh { Gb1 Gb2 Gb3 ;; Gb4 Gb5 ;; Gb6 } rule
```
```
Gh { Gb1 Gb2 Gb3 } rule
Gh { Gb4 Gb5 } rule
Gh { Gb6 } rule
```
The disjunction is actually converted in that way. You may need to be careful about that when deleting definitions that you registered using `rule`, etc.

You can use `nquery` to limit the number of answers to a query. Specify a number greater than or equal to 1.
```
{ creatureo Y } 2 nquery .
⟹ { H{ { Y Tom } } H{ { Y Jerry } } }
```
Use `\+` to express **negation**. `\+` acts on the goal immediately following it.
```
LOGIC-PREDS: likes-cheeseo dislikes-cheeseo ;

{ likes-cheeseo X } { mouseo X } rule

{ dislikes-cheeseo Y } {
    { creatureo Y }
    \+ { likes-cheeseo Y }
} rule

{ dislikes-cheeseo Jerry } query .
⟹ f
{ dislikes-cheeseo Tom } query .
⟹ t
```
Other creatures might also like cheese...

You can also use sequences, lists, and tuples as goal definition arguments.

The syntax of list descriptions allows you to describe "head" and "tail" of a list.
```
L{ HEAD . TAIL }
L{ ITEM1 ITEM2 ITEM3 . OTHERS }
```
You can also write a quotation that returns an argument as a goal definition argument.
```
[ Tom Jerry Nibbles L{ } cons cons cons ]
```
When written as an argument to a goal definition, the following lines have the same meaning as above:
```
L{ Tom Jerry Nibbles }
L{ Tom Jerry Nibbles . L{ } )
[ { Tom Jerry Nibbles } >list ]
```
Such quotations are called only once when converting the goal definitions to internal representations.

`membero` is a built-in logic predicate for the relationship an element is in a list.
```
USE: lists

{ membero Jerry L{ Tom Jerry Nibbles } } query .
⟹ t

SYMBOL: Spike
{ membero Spike [ Tom Jerry Nibbles L{ } cons cons cons ] } query .
⟹ f
```
Recently, they moved into a small house. The house has a living room, a dining room and a kitchen. Well, humans feel that way. Each of them seems to be in their favorite room.
```
TUPLE: house living dining kitchen in-the-wall ;
LOGIC-PRED: houseo

{ houseo T{ house { living Tom } { dining f } { kitchen Nibbles } { in-the-wall Jerry } } } fact
```
Don't worry about not mentioning the bathroom.

Let's ask who is in the kitchen.
```
{ houseo T{ house { living __ } { dining __ } { kitchen X } { in-the-wall __ } } } query .
⟹ { H{ { X Nibbles } } }
```
These two consecutive underbars are called **anonymous logic variables**. Use in place of a regular logic variable when you do not need its name and value.

It seems to be meal time. What do they eat?

```
LOGIC-PREDS: is-ao consumeso ;
SYMBOLS: mouse cat milk cheese fresh-milk Emmentaler ;

{
    { is-ao Tom cat }
    { is-ao Jerry mouse }
    { is-ao Nibbles mouse }
    { is-ao fresh-milk milk }
    { is-ao Emmentaler cheese }
} facts

{
    {
        { consumeso X milk } {
            { is-ao X mouse } ;;
            { is-ao X cat }
        }
    }
    { { consumeso X cheese } { is-ao X mouse } }
    { { consumeso X mouse } { is-ao X cat } }
} rules
```
Here, `facts` and `rules` are used. They can be used for successive facts or rules.

Let's ask what Jerry consumes.
```
{ { consumeso Jerry X } { is-ao Y X } } query .
⟹ {
        H{ { X milk } { Y fresh-milk } }
        H{ { X cheese } { Y Emmentaler } }
    }
```
Well, what about Tom?
```
{ { consumeso Tom X } { is-ao Y X } } query .
⟹ {
        H{ { X milk } { Y fresh-milk } }
        H{ { X mouse } { Y Jerry } }
        H{ { X mouse } { Y Nibbles } }
    }
```
This is a problematical answer. We have to redefine `consumeso`.
```
LOGIC-PRED: consumeso

{ consumeso X milk } {
    { is-ao X mouse } ;;
    { is-ao X cat }
} rule

{ consumeso X cheese } { is-ao X mouse } rule
{ consumeso Tom mouse } { !! f } rule
{ consumeso X mouse } { is-ao X cat } rule
```
We wrote about Tom before about common cats. What two consecutive exclamation marks represent is called a **cut** operator. Use the cut operator to suppress **backtracking**.

The next letter `f` is an abbreviation for goal `{ failo }` using the built-in logic predicate `failo`. `{ failo }` is a goal that is always `f`. Similarly, there is a goal `{ trueo }` that is always `t`, and its abbreviation is `t`.

By these actions, "Tom consumes mice." becomes false and suppresses the examination of general eating habits of cats.
```
{ { consumeso Tom X } { is-ao Y X } } query .
⟹ { H{ { X milk } { Y fresh-milk } } }
```
It's OK. Let's check a cat that is not Tom.
```
SYMBOL: a-cat
{ is-ao a-cat cat } fact

{ { consumeso a-cat X } { is-ao Y X } } query .
⟹ {
        H{ { X milk } { Y fresh-milk } }
        H{ { X mouse } { Y Jerry } }
        H{ { X mouse } { Y Nibbles } }
    }
```
Jerry, watch out for the other cats.

So far, we've seen how to define a logic predicate with `fact`, `rule`, `facts`, and `rules`. Each time you use those words for a logic predicate, information is added to it.

You can clear these definitions with `clear-pred` for a logic predicate.
```
cato clear-pred
mouseo clear-pred
{ creatureo X } query .
⟹ f
```
`fact` and `rule` add a new definition to the end of a logic predicate, while `fact*` and `rule*` add them first. The order of the information can affect the results of a query.
```
{ cato Tom } fact
{ mouseo Jerry } fact
{ mouseo Nibbles } fact*

{ mouseo Y } query .
⟹ { H{ { Y Nibbles } } H{ { Y Jerry } } }

{ creatureo Y } 2 nquery .
⟹ { H{ { Y Tom } } H{ { Y Nibbles } } }
```
While `clear-pred` clears all the definition information for a given logic predicate, `retract` and `retract-all` provide selective clearing.

`retract` removes the first definition that matches the given head information.
```
{ mouseo Jerry } retract
{ mouseo X } query .
⟹ { H{ { X Nibbles } } }
```
On the other hand, `retract-all` removes all definitions that match a given head goal definition. Logic variables, including anonymous logic variables, can be used as goal definition arguments in `retract` and `retract-all`. A logic variable match any argument.
```
{ mouseo Jerry } fact
{ mouseo X } query .
⟹ { H{ { X Nibbles } } H{ { X Jerry } } }

{ mouseo __ } retract-all
{ mouseo X } query .
⟹ f
```
let's have them come back.
```
{ { mouseo Jerry } { mouseo Nibbles } } facts
{ creatureo X } query .
⟹  { H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } }
```
Logic predicates that take different numbers of arguments are treated separately. The previously used `cato` took one argument. Let's define `cato` that takes two arguments.
```
SYMBOLS: big small a-big-cat a-small-cat ;

{ cato big a-big-cat } fact
{ cato small a-small-cat } fact

{ cato X } query .
⟹ { H{ { X Tom } } }

{ cato X Y } query .
⟹ {
       H{ { X big } { Y a-big-cat } }
       H{ { X small } { Y a-small-cat } }
    }

{ creatureo X } query .
⟹ { H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } }
```
If you need to identify a logic predicate that has a different **arity**, that is numbers of arguments, express it with a slash and an arity number. For example, `cato` with arity 1 is `cato/1`, `cato` with arity 2 is `cato/2`. But, note that `logic` vocab does not recognize these names.

`clear-pred` will clear all definitions of any arity. If you only want to remove the definition of a certain arity, you should use `retract-all` with logic variables.
```
{ cato __ __ } retract-all
{ cato X Y } query .
⟹ f

{ cato X } query .
⟹ { H{ { X Tom } } }
```
You can **trace** `logic` vocab's execution. The word to do this is `trace`.
```
trace
{ creatureo Tom } query .
⟹ in: { creatureo Tom }
        Unification of T{ logic-goal { args { Tom } } } and T{ logic-goal
                                                                { pred
                                                                    T{ logic-pred
                                                                        { name "creatureo" }
                                                                        { defs
                                                                            V{
                                                                                {
                                                                                    ~circularity~
                                                                                    {
                                                                                        T{ logic-goal
                                                                                            { pred ~logic-pred~ }
                                                                                            { args ~array~ }
                                                                                        }
                                                                                    }
                                                                                }
                                                                                {
                                                                                    T{ logic-goal
                                                                                        { pred ~logic-pred~ }
                                                                                        { args ~array~ }
                                                                                    }
                                                                                    {
                                                                                        T{ logic-goal
                                                                                            { pred ~logic-pred~ }
                                                                                            { args ~array~ }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                { args { X } }
                                                            }
        Unification of Tom and X
        ==> Success

    ==> Success

   in: { cato X }
        Unification of T{ logic-goal { args { Tom } } } and T{ logic-goal
                                                                { pred
                                                                    T{ logic-pred
                                                                        { name "cato" }
                                                                        { defs V{ { ~circularity~ { } } } }
                                                                    }
                                                                }
                                                                { args { Tom } }
                                                            }
            Unification of Tom and Tom
            ==> Success

        ==> Success
   ...
   t
```
The word to stop tracing is `notrace`.
```
notrace
{ creatureo Tom } query .
⟹ t
```
Thank you, old friends. I was able to explain most of factlog with fun. Have a good time together with fun fights. See you.

Here is a Prolog definition for the factorial predicate `factorial`.
```
factorial(0, 1).
factorial(N, F) :- N > 0, N2 is N - 1, factorial(N2, F2), F is F2 * N.
```
Let's think about how to do the same thing with factlog. It is mostly the following code, but is surrounded by backquotes where it has not been explained.
```
USE: logic

LOGIC-PRED: factorialo
LOGIC-VARS: N N2 F F2 ;

{ factorialo 0 1 } fact
{ factorialo N F } {
    `N > 0`
    `N2 is N - 1`
    { factorialo N2 F2 }
    `F is F2 * N`
} rule
```
Within these backquotes are comparisons, calculations, and assignments (to be precise, **unifications**). `logic` vocab has a mechanism to call Factor code to do these things. Here are some examples.
```
LOGIC-PREDS: N_>_0  N2_is_N_-_1  F_is_F2_*_N ;

{ N_>_0 N } [ N of 0 > ] callback

{ N2_is_N_-_1 N2 N } [ dup N of 1 - N2 unify ] callback

{ F_is_F2_*_N F F2 N } [ dup [ F2 of ] [ N of ] bi * F unify ] callback
```
Use `callback` to set the quotation to be called. Such quotations take an **environment** which holds the binding of logic variables, and returns `t` or `f` as a result of execution. To retrieve the values of logic variables in the environment, use `of `or `at`.

The word `unify` unifies the two following the environment in that environment.

Now we can rewrite the definition of factorialo to use them.
```
USE: logic

LOGIC-PREDS: factorialo N_>_0  N2_is_N_-_1  F_is_F2_*_N ;
LOGIC-VARS: N N2 F F2 ;

{ factorialo 0 1 } fact
{ factorialo N F } {
    { N_>_0 N }
    { N2_is_N_-_1 N2 N }
    { factorialo N2 F2 }
    { F_is_F2_*_N F F2 N }
} rule

{ N_>_0 N } [ N of 0 > ] callback

{ N2_is_N_-_1 N2 N } [ dup N of 1 - N2 unify ] callback

{ F_is_F2_*_N F F2 N } [ dup [ N of ] [ F2 of ] bi * F unify ] callback
```
Let's try `factorialo`.
```
{ factorialo 0 F } query .
⟹ { H{ { F 1 } } }

{ factorialo 1 F } query .
⟹ { H{ { F 1 } } }

{ factorialo 10 F } query .
⟹ { H{ { F 3628800 } } }
```
factlog has features that make it easier to meet the typical requirements shown here.

There are the built-in logic predicates `(<)`, `(>)`, `(>=)`, and `(=<)` to compare numbers. There are also `(==)` and `(\==)` to test for equality and inequality of two arguments.

The word `is` takes a quotation and a logic variable to be unified. The quotation takes an environment and returns a value.  And `is` returns the internal representation of the goal. `is` is intended to be used in a quotation. If there is a quotation in the definition of `rule`, `logic` vocab uses the internal definition of the goal obtained by calling it.

If you use these features to rewrite the definition of `factorialo`:
```
USE: logic

LOGIC-PRED: factorialo
LOGIC-VARS: N N2 F F2 ;

{ factorialo 0 1 } fact
{ factorialo N F } {
    { (>) N 0 }
    [ [ N of 1 - ] N2 is ]
    { factorialo N2 F2 }
    [ [ [ F2 of ] [ N of ] bi * ] F is ]
} rule
```
Use the built-in logic predicate `(=)` for unification that does not require processing with a quotation. `(\=)` will be true when such a unification fails. Note that `(\=)` does not actually do the unification.

`varo` takes a argument and is true if it is a logic variable with no value. On the other hand, `nonvaro` is true if its argument is not a logic variable or is a concrete logic variable.

Now almost everything about factlog is explained.
