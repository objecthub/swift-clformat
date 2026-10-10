# Layout directives

Control newlines, tabulation, and the justification of text.

## Newline (\~%)

**Syntax:** **\~**_n_**%**

This directive outputs *n* (default: 1) newline characters, thereby terminating the current output line and beginning a new one. No arguments are being consumed. Simply putting *n* newline escape characters `\n` into the control string would also work, but `~%` is often used because it makes the control string look nicer and more consistent.

## Freshline (\~&)

**Syntax:** **\~**_n_**&**

Unless it can be determined that the output is already at the beginning of a line, this directive outputs a newline if *n* > 0. This conditional newline is followed by *n* − 1 newlines, if *n* > 1. Nothing is output if *n* = 0.

## Page separator (\~|)

**Syntax:** **\~**_n_**|**

This directive outputs *n* (default: 1) page separator characters (`"\u{12}"`).

## Tilde (\~\~)

**Syntax:** **\~**_n_**\~**

This directive outputs *n* (default: 1) tilde characters.

## Tabulate (\~T)

**Syntax:** **\~**_colnum,colinc_**T**

This directive will output sufficient spaces to move the cursor to column *colnum* (default: 1). If the cursor is already at or beyond column *colnum*, the directive will output spaces to move the cursor to column *colnum + k × colinc* for the smallest positive integer *k* possible, unless *colinc* (default: 1) is zero, in which case no spaces are output if the cursor is already at or beyond column *colnum*.

If modifier `@` is provided, relative tabulation is performed. In this case, the directive outputs *colrel* spaces and then outputs the smallest non-negative number of additional spaces necessary to move the cursor to a column that is a multiple of *colinc*. For example, the directive `~3,8@T` outputs three spaces and then moves the cursor to a "standard multiple-of-eight tab stop" if not at one already. If the current output column cannot be determined, however, then *colinc* is ignored, and exactly *colrel* spaces are output.

## Line continuation (\~ and a newline)

**Syntax:** **\~**_newline_, **\~:**_newline_, **\~@**_newline_

This directive consumes the newline character that follows the tilde. It makes it possible to break long control strings over several lines. Without modifiers, the newline and the space characters at the beginning of the next line are ignored, so the continuation line can be indented freely. With the `:` modifier, only the newline is ignored and the spaces of the next line are kept. With the `@` modifier, the newline is kept (as if `~%` had been used), and the spaces of the next line are ignored. The combination `:@` is not supported.

```swift
try clformat("one~\n   two~\n   three")
⇒ onetwothree
try clformat("one~:\n   two")
⇒ one   two
try clformat("one~@\n   two")
⇒ one
  two
```

## Justification (\~<…\~>)

**Syntax:** **\~**_mincol,colinc,minpad,padchar,maxcol,elchar_**<**_str_**\~>**

This directive justifies the text produced by processing control string *str* within a field which is at least *mincol* columns wide (default: 0). *str* may be divided up into segments via directive `~;`, in which case the spacing is evenly divided between the text segments.

With no modifiers, the leftmost text segment is left-justified in the field and the rightmost text segment is right-justified. If there is only one text element, it is right-justified. The `:` modifier causes spacing to be introduced before the first text segment. The `@` modifier causes spacing to be added after the last text segment. The *minpad* parameter (default: 0) is the minimum number of padding characters to be output between each segment. Whenever padding is needed, the padding character *padchar* (default: ' ') is used. If the total width needed to satisfy the constraints is greater than *mincol*, then the width used is *mincol + k × colinc* for the smallest possible non-negative integer *k* with *colinc* defaulting to 1.

```swift
try clformat("|~10,,,'.<foo~;bar~>|")
⇒ |foo....bar|
try clformat("|~10,,,'.:<foo~;bar~>|")
⇒ |..foo..bar|
try clformat("|~10,,,'.:@<foo~;bar~>|")
⇒ |..foo.bar.|
try clformat("|~10,,,'.<foobar~>|")
⇒ |....foobar|
try clformat("|~10,,,'.:<foobar~>|")
⇒ |....foobar|
try clformat("|~10,,,'.@<foobar~>|")
⇒ |foobar....|
try clformat("|~10,,,'.:@<foobar~>|")
⇒ |..foobar..|
```

Note that *str* may include format directives. All the clauses in *str* are processed in order. It is the resulting pieces of text that are justified. The `~^` directive may be used to terminate processing of the clauses prematurely, in which case only the completely processed clauses are justified.

If the first clause of a `~<` directive is terminated with `~:;` instead of `~;`, then it is used in a special way. All of the clauses are processed, but the first one is not used in performing the spacing and padding. When the padded result has been determined, then, if it fits on the current line of output, it is output, and the text for the first clause is discarded. If, however, the padded text does not fit on the current line, then the text segment for the first clause is output before the padded text. The first clause ought to contain a newline (such as a `~%` directive). The first clause is always processed, and so any arguments it refers to will be used. The decision is whether to use the resulting segment of text, not whether to process the first clause. If the `~:;` has a prefix parameter *n*, then the padded text must fit on the current line with *n* character positions to spare to avoid outputting the first clause’s text.

For example, the control string in the following example can be used to print a list of items separated by comma without breaking items over line boundaries, beginning each line with `;;`. The prefix parameter 1 in `~1:;` accounts for the width of the comma that will follow the justified item if it is not the last element in the list, or the period if it is. If `~:;` has a second prefix parameter, like below, then it is used as the width of the line, overriding the line width as specified by `clformat`'s `linewidth:` parameter (default: 80).

The output begins and ends with a newline character:

```swift
try clformat("~%;; ~{~<~%;; ~1,30:; ~S~>~^,~}.~%",
             args: ["first line", "second", "a long third line",
                    "fourth", "fifth"])
⇒ ;;  "first line", "second",
  ;;  "a long third line",
  ;;  "fourth", "fifth".
```

If there is only one text segment *str* and parameter *maxcol* is provided and the length of the output of *str* is exceeding *maxcol*, then the output is truncated at width *maxcol - 1* and the ellipsis character *elchar* (default: '…') is inserted at the end.
