! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel quotations sequences
    prettyprint assocs math lists urls factlog.private ;
IN: factlog

HELP: !!
{ $var-description "The cut operator.\nUse the cut operator to suppress backtracking." } ;

HELP: (<)
{ $var-description "A logic predicate. It takes two arguments. It is true if both arguments are evaluated numerically and the first argument is less than the second, otherwise, it is false." } ;

HELP: (=)
{ $var-description "A logic predicate. It unifies two arguments." } ;

HELP: (=<)
{ $var-description "A logic predicate. It takes two arguments. It is true if both arguments are evaluated numerically and the first argument equals or is less than the second, otherwise, it is false." } ;

HELP: (==)
{ $var-description "A logic predicate. It tests for equality of two arguments. Evaluating two arguments, true if they are the same, false if they are different." } ;

HELP: (>)
{ $var-description "A logic predicate. It is true if both arguments are evaluated numerically and the first argument is greater than the second, otherwise, it is false." } ;

HELP: (>=)
{ $var-description "A logic predicate. It is true if both arguments are evaluated numerically and the first argument equals or is greater than the second, otherwise, it is false." } ;

HELP: (\=)
{ $var-description "A logic predicate.  It will be true when such a unification fails. Note that " { $snippet "(\\=)" } " does not actually do the unification." } ;

HELP: (\==)
{ $var-description "A logic predicate. It tests for inequality of two arguments. Evaluating two arguments, true if they are different, false if they are the same." } ;

HELP: ;;
{ $var-description "Is used to represent disjunction. The code below it has the same meaning as the code below it.
"
{ $code
  "Gh { Gb1 Gb2 Gb3 ;; Gb4 Gb5 ;; Gb6 } rule" }
""
{ $code
  "Gh { Gb1 Gb2 Gb3 } rule"
  "Gh { Gb4 Gb5 } rule:
Gh { Gb6 } rule" }
} ;

HELP: =:=
{ $values
    { "quot1" quotation } { "quot2" quotation }
    { "goal" logic-goal }
}
{ $description "Each of the two quotations takes an environment and returns a value. " { $snippet "=:=" } " returns the internal representation of the goal which returns t if values returned by these quotations are same.\n" { $snippet "=:=" } " is intended to be used in a quotation. If there is a quotation in the definition of rule, factlog uses the internal definition of the goal obtained by calling it." } ;

HELP: =\=
{ $values
    { "quot1" quotation } { "quot2" quotation }
    { "goal" logic-goal }
}
{ $description "Each of the two quotations takes an environment and returns a value. " { $snippet "=\\=" } " returns the internal representation of the goal which returns t if values returned by these quotations are not same.\n" { $snippet "=\\=" } " is intended to be used in a quotation. If there is a quotation in the definition of rule, factlog uses the internal definition of the goal obtained by calling it." } ;

HELP: items>list
{ $values
    { "seq" sequence }
    { "factlog-list" cons-pair }
}
{ $description "Create a factlog list using sequence elements. The last element is the " { $snippet "cdr" } " of the last " { $link cons-pair } " that makes up the factlog list." } ;


HELP: LOGIC-PREDS:
{ $description "Creates a new logic predicate for every token until the ;." }
{ $syntax "LOGIC-PREDS: preds... ;" }
{ $examples
  { $code
    "USE: factlog"
    "LOGIC-PREDS: cato mouseo ;"
    ""
    "{ cato Tom } fact"
    "{ mouseo Jerry } fact"
  }
} ;

HELP: LOGIC-VARS:
{ $description "Creates a new logic variable for every token until the ;." }
{ $syntax "LOGIC-VARS: vars... ;" }
{ $examples
  { $example
    "USE: factlog"
    "LOGIC-PREDS: mouseo ;"
    "LOGIC-VARS: X Y ;"
    ""
    "{ mouseo Jerry } fact"
    "{ mouseo X } query"
    "{ H{ { X Jerry } } }"
  }
} ;

HELP: L(
{ $description "Marks the beginning of a literal list of factlog. Literal factlog lists are terminated by ). Permits dotted pair notation." }
{ $syntax "L( elements... )
L( elements... . element )" }
{ $examples
  { $example "L( 1 2 3 )" }
  { $example "L( 4 5 6 . 7 )" }
} ;

HELP: \+
{ $var-description "Express negation. \\+ acts on the goal immediately following it.\n" }
{ $examples
  { $example
    "USE: factlog"
    "LOGIC-PREDS: cato mouseo creatureo ;"
    "LOGIC-VARS: X Y ;"
    "SYMBOLS: Tom Jerry Nibbles ;"
    ""
    "{ cato Tom } fact"
    "{ mouseo Jerry } fact"
    "{ mouseo Nibbles } fact"
    "{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule"
    ""
    "LOGIC-PREDS: likes-cheeseo dislikes-cheeseo ;"
    ""
    "{ likes-cheeseo X } { mouseo X } rule"
    "{ dislikes-cheeseo Y } {
    { creatureo Y }
    \\+ { likes-cheeseo Y }
    } rule"
    "{ dislikes-cheeseo Jerry } query"
    "{ dislikes-cheeseo Tom } query"
    "f\nt"
  }
} ;

HELP: __
{ $var-description "An anonymous logic variable.\nUse in place of a regular logic variable when you do not need its name and value." } ;

HELP: appendo
{ $var-description "A logic predicate. Add a new element to the beginning of the list." } ;

HELP: callback
{ $values
    { "head" array } { "quot" quotation }
}
{ $examples
  { $example "LOGIC-PREDS: N_>_0 ;
{ N_>_0 N } [ N of 0 > ] callback" }
}
{ $description "Set the quotation to be called. Such quotations take an environment which holds the binding of logic variables, and returns t or " { $link f } " as a result of execution. To retrieve the values of logic variables in the environment, use " { $link of } " or " { $link at } "." }
{ $see-also callbacks } ;

HELP: callbacks
{ $values
    { "defs" array }
}
{ $examples
  { $example "LOGIC-PREDS: N_>_0  N2_is_N_-_1  F_is_F2_*_N ;
{
    { { N_>_0 N } [ N of 0 > ] }
    { N2_is_N_-_1 N2 N } [ dup N of 1 - N2 unify ] }
    { F_is_F2_*_N F F2 N } [ dup [ F2 of ] [ N of ] bi * F unify ] }
} callbacks" }
}
{ $description "To collectively register a plurality of " { $link callback } "s." }
{ $see-also callback } ;


HELP: car
{ $values
    { "cons-pair" cons-pair }
    { "car" "the first item in the " { $link factlog-list } }
}
{ $description "Returns car of the " { $link cons-pair } "." }
{ $see-also cdr cons-pair } ;

HELP: cdr
{ $values
    { "cons-pair" cons-pair }
    { "cdr" "the rest items in the factlog-list" }
}
{ $description "Returns cdr of the " { $link cons-pair } "." }
{ $see-also car cons-pair } ;

HELP: clear-pred
{ $values
    { "pred" "a logic predicate" }
}
{ $description "Clears all the definition information for the given logic predicate" }
{ $examples
  { $example
    "USE: factlog"
    "LOGIC-PREDS: mouseo ;"
    "SYMBOLS: Jerry Nibbles ;"
    "LOGIC-VARS: X ;"
    ""
    "{ mouseo Jerry } fact"
    "{ mouseo Nibbles } fact"
    ""
    "{ mouseo X } query"
    ""
    "mouseo clear-pred"
    "{ mouseo X } query"
    "{ H{ { X Jerry } } H{ { X Nibbles } } }\nf"
  }
}
{ $see-also retract retract-all } ;

HELP: conco
{ $var-description "A logic predicate. Concatenate two lists." } ;

HELP: cons
{ $values
    { "cons-car" object } { "cons-cdr" object }
    { "cons-pair" cons-pair }
}
{ $description "Constructs a "{ $link cons-pair } "." }
{ $see-also uncons cons-pair } ;

HELP: cons-pair
{ $class-description "Cons cells that make up the list of factlog." }
{ $see-also cons uncons POSTPONE: L( } ;

HELP: fact
{ $values
    { "head" "an array representing a goal" }
}
{ $description "Registers the fact to the end of the logic predicate that is in the head." }
{ $examples
  { $code
    "USE: factlog"
    "LOGIC-PREDS: cato mouseo ;"
    "SYMBOLS: Tom Jerry ;"
    "{ cato Tom } fact"
    "{ mouseo Jerry } fact"
  }
}
{ $see-also fact* facts } ;

HELP: fact*
{ $values
    { "head" "an array representing a goal" }
}
{ $description "Registers the fact to the beginning of the logic predicate that is in the head." }
{ $see-also fact facts } ;

HELP: factlog-list
{ $class-description { $link cons-pair } " or " { $link NIL } } ;

HELP: facts
{ $values
    { "defs" array }
}
{ $description "Registers these facts to the end of the logic predicate that is in the head." }
{ $examples
  { $code
    "USE: factlog"
    "LOGIC-PREDS: cato mouseo ;"
    ""
    "{ { cato Tom } { mouseo Jerry } } facts"
  }
}
{ $see-also fact fact* } ;

HELP: failo
{ $var-description "A built-in logic predicate. { " { $snippet "failo" } " } is a goal that is always " { $link f } "." }
{ $see-also trueo } ;

HELP: is
{ $values
    { "quot" quotation } { "dist" "a logic predicate" }
    { "goal" logic-goal }
}
{ $description "Takes a quotation and a logic variable to be unified. Each of the two quotations takes an environment and returns a value. " { $snippet "is" } " returns the internal representation of the goal.\n" { $snippet "is" } " is intended to be used in a quotation. If there is a quotation in the definition of rule, factlog uses the internal definition of the goal obtained by calling it." } ;

HELP: lengtho
{ $var-description "A logic predicate. Instantiate the length of the list." } ;

HELP: list>array
{ $values
    { "list" cons-pair }
    { "array" array }
}
{ $description "Convert a factlog list recursively into an array. If the cdr of the " { $link cons-pair } " is not " { $link cons-pair } " or " { $link NIL } ", the value is not included in the generated array." } ;

HELP: listo
{ $var-description "A logic predicate. Takes a single argument and checks to see if it is a list." } ;

HELP: membero
{ $var-description "A logic predicate for the relationship an element is in a list." } ;

HELP: NIL
{ $description "This represents an empty list " { $snippet "L( )" } "." }
{ $see-also POSTPONE: L( } ;

HELP: nlo
{ $var-description "A logic predicate. Print line breaks." }
{ $see-also writeo writenlo } ;

HELP: nonvaro
{ $var-description "A logic predicate. { " { $snippet "nonvaro" } " } takes a single argument and is true if its argument is not a logic variable or is a concrete logic variable." }
{ $see-also varo } ;

HELP: notrace
{ $description "Stop tracing." }
{ $see-also trace } ;

HELP: query
{ $values
    { "goal-def/defs"  "a goal def or an array of goal defs" }
    { "bindings-array/success?" "anser" }
}
{ $description
  "Inquire about the order of goals. The general form of a query is:

    { G1 G2 ... Gn } query

This G1, G2, ... Gn is a conjunction. When all of them are satisfied, it becomes " { $link t } ".

If there is only one goal, you can use its abbreviation.

    G1 query

When you query with logic variable(s), you will get the answer for the logic variable(s). For such queries, an array of hashtables with logic variables as keys is returned.
"
}
{ $examples
  { $example
    "USE: factlog"
    "LOGIC-PREDS: cato mouseo creatureo ;"
    "LOGIC-VARS: X Y ;"
    "SYMBOLS: Tom Jerry Nibbles ;"
    ""
    "{ cato Tom } fact"
    "{ mouseo Jerry } fact"
    "{ mouseo Nibbles } fact"
    ""
    "{ cato Tom } query"
    "{ { cato Tom } { cato Jerry } } query"
    "{ mouseo X } query"
    ""
    "t\nf\n{ H{ { X Jerry } } H{ { X Nibbles } } }"
  }
}
{ $see-also query-n } ;

HELP: query-n
{ $values
    { "goal-def/defs" "a goal def or an array of goal defs" } { "n/f" "the highest number of responses" }
    { "bindings-array/success?" "anser" }
}
{ $description "The version of " { $link query } " that limits the number of responses. Specify a number greater than or equal to 1.
If " { $link f } " is given instead of a number as " { $snippet "n/f" } ", there is no limit to the number of answers. That is, the behavior is the same as " { $link query } "." }
{ $see-also query } ;

HELP: retract
{ $values
    { "head-def" "a logic predicate" }
}
{ $description "Removes the first definition that matches the given head information." }
{ $see-also retract-all clear-pred } ;

HELP: retract-all
{ $values
    { "head-def" "a logic predicate" }
}
{ $description "Removes all definitions that match a given head goal definition." }
{ $see-also retract clear-pred } ;

HELP: rule
{ $values
    { "head" "an array representing a goal" } { "body" "an array of goals or a goal" }
}
{ $description "Registers the rule to the end of the logic predicate that is in the head." }
{ $see-also rule* rules } ;

HELP: rule*
{ $values
    { "head" "an array representing a goal" } { "body" "an array of goals or a goal" }
}
{ $description "Registers the rule to the beginnung of the logic predicate that is in the head." }
{ $see-also rule rules } ;

HELP: rules
{ $values
  { "defs" "an array of rules" }
}
{ $description "Registers these rules to the end of the logic predicate that is in these heads." }
{ $see-also rule rule* } ;

HELP: trace
{ $description "Start tracing." }
{ $see-also notrace } ;

HELP: trueo
{ $var-description "A logic predicate. { " { $snippet "trueo" } " } is a goal that is always " { $link t } "." }
{ $see-also failo } ;

HELP: uncons
{ $values
    { "cons-pair" cons-pair }
    { "car" object } { "cdr" object }
}
{ $description "Explode pairs of the cons cell." }
{ $see-also cons cons-pair } ;


HELP: unify
{ $values
    { "cb-env" callback-env } { "x" object } { "y" object }
    { "success?" boolean }
}
{ $description "Unifies the two following the environment in that environment." } ;

HELP: varo
{ $var-description "A logic predicate. " { $snippet "varo" } "takes a argument and is true if it is a logic variable with no value." }
{ $see-also nonvaro } ;

HELP: writenlo
{ $var-description "A logic predicate. print a single sequence or string and return a new line." }
{ $see-also writeo nlo } ;

HELP: writeo
{ $var-description "A logic predicate. print a single sequence or string of characters." }
{ $see-also writenlo nlo } ;

ARTICLE: "factlog" "factlog"
{ $vocab-link "factlog" }
" is an embedded language that runs on "{ $url "https://github.com/factor/factor" "Factor" } " with the capabilities of a subset of Prolog.

It is an extended port from tiny_prolog and its descendants, " { $url "https://github.com/preston/ruby-prolog" "ruby-prolog" } ".

"
{ $code
"USE: factlog

LOGIC-PREDS: cato mouseo creatureo ;
LOGIC-VARS: X Y ;
SYMBOLS: Tom Jerry Nibbles ;" }
"
In factlog, words that represent relationships are called " { $strong "logic predicates" } ". Use " { $link \ LOGIC-PREDS: } " to declare the predicates you want to use. " { $strong "Logic variables" } " are used to represent relationships. use " { $link \ LOGIC-VARS: } " to declare the logic variables you want to use.

In the above code, logic predicates end with the character 'o', which is a convention borrowed from miniKanren and so on, and means relation. This is not necessary, but it is useful for reducing conflicts with the words of, the parent language, Factor. We really want to write them as: " { $snippet "cat°" } ", " { $snippet "mouse°" } " and " { $snippet "creature°" } ", but we use 'o' because it's easy to type.

" { $strong "Goals" } " are questions that factlog tries to meet to be true. To represent a goal, write an array with a logic predicate followed by zero or more arguments. factlog converts such definitions to internal representations.

    { LOGIC-PREDICATE ARG1 ARG2 ... }
    { LOGIC-PREDICATE }

We will write factlog programs using these goals.
"
{ $code
"{ cato Tom } fact
{ mouseo Jerry } fact
{ mouseo Nibbles } fact"
}
"
The above code means that Tom is a cat and Jerry and Nibbles are mice. Use " { $link fact } " to describe the " { $strong "facts" } ".
"
{ $example
"{ cato Tom } query"
"t"
}
"
The above code asks, \"Is Tom a cat?\". We said,\"Tom is a cat.\", so the answer is " { $link t } ". The general form of a query is:

    { G1 G2 ... Gn } query

The parentheses are omitted because there was only one goal to be satisfied earlier, but here is an example of two goals:
"
{ $example
"{ { cato Tom } { cato Jerry } } query"
"f"
}
"
Tom is a cat, but Jerry is not declared a cat, so " { $link f } " is returned in response to this query.

If you query with logic variable(s), you will get the answer for the logic variable(s). For such queries, an array of hashtables with logic variables as keys is returned.
"
{ $example
"{ mouseo X } query"
"{ H{ { X Jerry } } H{ { X Nibbles } } }"
}
"
The following code shows that if something is a cat, it's a creature. Use " { $link rule } " to write " { $strong "rules" } ".
"
{ $code
  "{ creatureo X } { cato X } rule"
}
"
According to the rules above, \"Tom is a creature.\" is answered to the following questions:
"
{ $example
"{ creatureo Y } query"
"{ H{ { Y Tom } } }"
}
"
The general form of " { $link rule } " is:

    Gh { Gb1 Gb2 ... Gbn } rule

This means " { $snippet "Gh" } " when all goals of " { $snippet "Gb1" } ", " { $snippet "Gb2" } ", ..., " { $snippet "Gbn" } " are met. This " { $snippet "Gb1 Gb2 ... Gbn" } " is a " { $strong "conjunction" } ".
"
{ $example
"LOGIC-PREDS: youngo young-mouseo ;

{ youngo Nibbles } fact

{ young-mouseo X } {
    { mouseo X }
    { youngo X }
} rule

{ young-mouseo X } query"
"{ H{ { X Nibbles } } }"
}
"
This " { $snippet "Gh" } " is called " { $strong "head" } " and the " { $snippet "{ Gb 1Gb 2... Gbn }" } " is called " { $strong "body" } ".

Facts are rules where its body is an empty array. So, the form of " { $link fact } " is:

    Gh fact

Let's describe that mice are also creatures.
"
{ $example
"{ creatureo X } { mouseo X } rule

{ creatureo X } query"
"{ H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } }"
}
"
To tell the truth, we were able to describe at once that cats and mice were creatures by doing the following.
"
{ $code
"LOGIC-PREDS: creatureo ;

{ creatureo Y } {
    { cato Y } ;; { mouseo Y }
} rule"
}
"
" { $link ;; } " is used to represent " { $strong "disjunction" } ". The code below it has the same meaning as the code below it.

    Gh { Gb1 Gb2 Gb3 ;; Gb4 Gb5 ;; Gb6 } rule

    Gh { Gb1 Gb2 Gb3 } rule
    Gh { Gb4 Gb5 } rule
    Gh { Gb6 } rule

factlog actually converts the disjunction in that way. You may need to be careful about that when deleting definitions that you registered using " { $link rule } ", etc.

You can use " { $link query-n } " to limit the number of answers to a query. Specify a number greater than or equal to 1.
"
{ $example
"{ creatureo Y } 2 query-n"
"{ H{ { Y Tom } } H{ { Y Jerry } } }"
}
"
Use " { $link \+ } " to express " { $strong "negation" } ". " { $link \+ } " acts on the goal immediately following it.
"
{ $example
"LOGIC-PREDS: likes-cheeseo dislikes-cheeseo ;

{ likes-cheeseo X } { mouseo X } rule

{ dislikes-cheeseo Y } {
    { creatureo Y }
    \\+ { likes-cheeseo Y }
} rule"
"{ dislikes-cheeseo Jerry } query"
"{ dislikes-cheeseo Tom } query"
"f\nt"
}
"
Other creatures might also like cheese...

You can also use sequences, lists, and tuples as goal definition arguments.

Note that the list used by factlog is specific to factlog and not " { $vocab-link "lists" } " vocabulary list bundled with Factor. A list is created by a chain of " { $link cons-pair } " tuples, but it can be written using the special syntax " { $link \ L( } ".

"
{ $example
  "L( Tom Jerry Nibbles )"
  "L( Tom Jerry Nibbles )"
}
"
The syntax of list descriptions allows you to describe \"head\" and \"tail\" of a list.

    L( HEAD . TAIL )
    L( ITEM1 ITEM2 ITEM3 . OTHERS )

You can also write a quotation that returns an argument as a goal definition argument.

    [ Tom Jerry Nibbles L( ) cons cons cons ]

When written as an argument to a goal definition, the following lines have the same meaning as above:

    L( Tom Jerry Nibbles )
    L( Tom Jerry Nibbles . L( ) ]
    [ { Tom Jerry Nibbles NIL } " { $link items>list } " ]

Such quotations are called only once when converting the goal definitions to internal representations.

"{ $link membero } " is a built-in logic predicate for the relationship an element is in a list.
"
{ $example
  "SYMBOL: Spike
{ membero Jerry L( Tom Jerry Nibbles ) } query
{ membero Spike [ Tom Jerry Nibbles L( ) cons cons cons ] } query"
"t\nf"
}
"
Recently, they moved into a small house. The house has a living room, a dining room and a kitchen. Well, humans feel that way. Each of them seems to be in their favorite room.
"
{ $code
"TUPLE: house living dining kitchen in-the-wall ;
LOGIC-PREDS: houseo ;

{ houseo T{ house { living Tom } { dining f } { kitchen Nibbles } { in-the-wall Jerry } } } fact"
}
"
Don't worry about not mentioning the bathroom.

Let's ask who is in the kitchen.
"
{ $example
"{ houseo T{ house { living __ } { dining __ } { kitchen X } { in-the-wall __ } } } query"
"{ H{ { X Nibbles } } }"
}
"
These two consecutive underbars are called " { $strong "anonymous logic variables" } ". Use in place of a regular logic variable when you do not need its name and value.

It seems to be meal time. What do they eat?
"
{ $code
"LOGIC-PREDS: is-ao consumeso ;
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
} rules"
}
"
Here, " { $link facts } " and " { $link rules } " are used. They can be used for successive facts or rules.

Let's ask what Jerry consumes.
"
{ $example
"{ { consumeso Jerry X } { is-ao Y X } } query"
"{
    H{ { X milk } { Y fresh-milk } }
    H{ { X cheese } { Y Emmentaler } }
}"
}
"
Well, what about Tom?
"
{ $example
"{ { consumeso Tom X } { is-ao Y X } } query"
"{
    H{ { X milk } { Y fresh-milk } }
    H{ { X mouse } { Y Jerry } }
    H{ { X mouse } { Y Nibbles } }
}"
}
"
This is a problematical answer. We have to redefine " { $snippet "consumeso" } ".
"
{ $code
"LOGIC-PREDS: consumeso ;

{ consumeso X milk } {
    { is-ao X mouse } ;;
    { is-ao X cat }
} rule

{ consumeso X cheese } { is-ao X mouse } rule
{ consumeso Tom mouse } { !! f } rule
{ consumeso X mouse } { is-ao X cat } rule"
}
"
We wrote about Tom before about common cats. What two consecutive exclamation marks represent is called a " { $strong "cut" } " operator. Use the cut operator to suppress " { $strong "backtracking" } ".

The next letter " { $link f } " is an abbreviation for goal { " { $link failo } " } using the built-in logic predicate " { $link failo } ". { " { $link failo } " } is a goal that is always " { $link f } ". Similarly, there is a goal { " { $link trueo } " } that is always " { $link t } ", and its abbreviation is " { $link t } ".

By these actions, \"Tom consumes mice.\" becomes false and suppresses the examination of general eating habits of cats.
"
{ $example
"{ { consumeso Tom X } { is-ao Y X } } query"
"{ H{ { X milk } { Y fresh-milk } } }"
}
"
It's OK. Let's check a cat that is not Tom.
"
{ $example
"SYMBOL: a-cat
{ is-ao a-cat cat } fact

{ { consumeso a-cat X } { is-ao Y X } } query"
"{
    H{ { X milk } { Y fresh-milk } }
    H{ { X mouse } { Y Jerry } }
    H{ { X mouse } { Y Nibbles } }
}"
}
"
Jerry, watch out for the other cats.

So far, we've seen how to define a logic predicate with " { $link fact } ", " { $link rule } ", " { $link facts } ", and " { $link rules } ". Each time you use those words for a logic predicate, information is added to it.

You can clear these definitions with " { $link clear-pred } " for a logic predicate.
"
{ $example
"cato clear-pred
mouseo clear-pred
{ creatureo X } query"
"f"
}
"
" { $link fact } " and " { $link rule } " add a new definition to the end of a logic predicate, while " { $link fact* } " and " { $link rule* } " add them first. The order of the information can affect the results of a query.
"
{ $example
"{ cato Tom } fact
{ mouseo Jerry } fact
{ mouseo Nibbles } fact*

{ mouseo Y } query

{ creatureo Y } 2 query-n"
"{ H{ { Y Nibbles } } H{ { Y Jerry } } }\n{ H{ { Y Tom } } H{ { Y Nibbles } } }"
}
"
While " { $link clear-pred } " clears all the definition information for a given logic predicate, " { $link retract } " and " { $link retract-all } " provide selective clearing.

" { $link retract } " removes the first definition that matches the given head information.
"
{ $example
"{ mouseo Jerry } retract
{ mouseo X } query"
"{ H{ { X Nibbles } } }"
}
"
On the other hand, " { $link retract-all } " removes all definitions that match a given head goal definition. Logic variables, including anonymous logic variables, can be used as goal definition arguments in " { $link retract } " and " { $link retract-all } ". A logic variable match any argument.
"
{ $example
"{ mouseo Jerry } fact
{ mouseo X } query

{ mouseo __ } retract-all
{ mouseo X } query"
"{ H{ { X Nibbles } } H{ { X Jerry } } }\nf"
}
"
let's have them come back.
"
{ $example
"{ { mouseo Jerry } { mouseo Nibbles } } facts
{ creatureo X } query"
"{ H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } } }"
}
"
Logic predicates that take different numbers of arguments are treated separately. The previously used " { $snippet "cato" } " took one argument. Let's define " { $snippet "cato" } " that takes two arguments.
"
{ $example
"SYMBOLS: big small a-big-cat a-small-cat ;

{ cato big a-big-cat } fact
{ cato small a-small-cat } fact

{ cato X } query
{ cato X Y } query
{ creatureo X } query"
"{ H{ { X Tom } } }\n{ H{ { X big } { Y a-big-cat } } H{ { X small } { Y a-small-cat } } }\n{ H{ { X Tom } } H{ { X Jerry } } H{ { X Nibbles } }" }
"
If you need to identify a logic predicate that has a different " { $strong "arity" } ", that is numbers of arguments, express it with a slash and an arity number. For example, " { $snippet "cato" } " with arity 1 is " { $snippet "cato/1" } ", " { $snippet "cato" } " with arity 2 is " { $snippet "cato/2" } ". But, note that factlog does not recognize these names.

" { $link clear-pred } " will clear all definitions of any arity. If you only want to remove the definition of a certain arity, you should use " { $link retract-all } " with logic variables.
"
{ $example
"{ cato __ __ } retract-all
{ cato X Y } query"
"{ cato X } query"
"f\n{ H{ { X Tom } } }"
}
"
You can " { $strong "trace" } " factlog's execution. The word to do this is " { $link trace } ".

The word to stop tracing is " { $link notrace } ".

Thank you, old friends. I was able to explain most of the functions of factlog with fun. Have a good time together with fun fights. See you.

Here is a Prolog definition for the factorial predicate " { $snippet "factorial" } ".

factorial(0, 1).
factorial(N, F) :- N > 0, N2 is N - 1, factorial(N2, F2), F is F2 * N.

Let's think about how to do the same thing with factlog. It is mostly the following code, but is surrounded by backquotes where it has not been explained.
"
{ $code
"USE: factlog

LOGIC-PREDS: factorialo ;
LOGIC-VARS: N N2 F F2 ;

{ factorialo 0 1 } fact
{ factorialo N F } {
    `N > 0`
    `N2 is N - 1`
    { factorialo N2 F2 }
    `F is F2 * N`
} rule"
}
"
Within these backquotes are comparisons, calculations, and assignments (to be precise, " { $strong "unifications" } "). factlog has a mechanism to call Factor code to do these things. Here are some example.

    LOGIC-PREDS: N_>_0  N2_is_N_-_1  F_is_F2_*_N ;

    { N_>_0 N } [ N of 0 > ] callback

    { N2_is_N_-_1 N2 N } [ dup N of 1 - N2 unify ] callback

    { F_is_F2_*_N F F2 N } [ dup [ F2 of ] [ N of ] bi * F unify ] callback

Use " { $link callback } " to set the quotation to be called. Such quotations take an " { $strong "environment" } " which holds the binding of logic variables, and returns " { $link t } " or " { $link f } " as a result of execution. To retrieve the values of logic variables in the environment, use " { $link of } " or " { $link at } ".

The word " { $link unify } " unifies the two following the environment in that environment.

Now we can rewrite the definition of factorialo to use them.
"
{ $code
"USE: factlog

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

{ F_is_F2_*_N F F2 N } [ dup [ N of ] [ F2 of ] bi * F unify ] callback"
}
"
Let's try " { $snippet "factorialo" } ".
"
{ $example
"{ factorialo 0 F } query"
"{ H{ { F 1 } } }"
}
{ $example
"{ factorialo 1 F } query"
"{ H{ { F 1 } } }"
}
{ $example
"{ factorialo 10 F } query"
"{ H{ { F 3628800 } } }"
}
"
factlog has features that make it easier to meet the typical requirements shown here.

There are the built-in logic predicates " { $link (<) } ", " { $link (>) } ", " { $link (>=) } ", and " { $link (=<) } " to compare numbers. There are also " { $link (==) } " and " { $link (\==) } " to test for equality and inequality of two arguments.

The word " { $link is } " takes a quotation and a logic variable to be unified. The quotation takes an environment and returns a value.  And " { $link is } " returns the internal representation of the goal. " { $link is } " is intended to be used in a quotation. If there is a quotation in the definition of " { $link rule } ", factlog uses the internal definition of the goal obtained by calling it.

If you use these features to rewrite the definition of " { $snippet "factorialo" } ":
"
{ $code
"USE: factlog

LOGIC-PREDS: factorialo ;
LOGIC-VARS: N N2 F F2 ;

{ factorialo 0 1 } fact
{ factorialo N F } {
    { (>) N 0 }
    [ [ N of 1 - ] N2 is ]
    { factorialo N2 F2 }
    [ [ [ F2 of ] [ N of ] bi * ] F is ]
} rule"
}
"
Use the built-in logic predicate " { $link (=) } " for unification that does not require processing with a quotation. " { $link (\=) } " will be true when such a unification fails. Note that " { $link (\=) } " does not actually do the unification.

" { $link varo } " takes a argument and is true if it is a logic variable with no value. On the other hand, " { $link nonvaro } " is true if its argument is not a logic variable or is a concrete logic variable.

Now almost everything about factlog is explained.
"
;

ABOUT: "factlog"
