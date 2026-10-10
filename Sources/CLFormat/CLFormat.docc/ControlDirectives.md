# Control directives

Navigate arguments, process control strings recursively, convert case, and select or repeat parts of a control string.

## Ignore argument (\~\*)

**Syntax:** **\~**_n_**\***

The next *n* (default: 1) arguments are ignored. If the `:` modifier is provided, arguments are "ignored backwards", i.e. `~:*` backs up in the list of arguments so that the argument last processed will be processed again. `~n:*` backs up *n* arguments. When within a `~{` construct, the ignoring (in either direction) is relative to the list of arguments being processed by the iteration.

The form `~n@*` is an "absolute goto" rather than a "relative goto": the directive goes to the *n*-th argument, where 0 means the first one. *n* defaults to 0 for this form, so `~@*` goes back to the first argument. Directives after a `~n@*` will take arguments in sequence beginning with the one gone to. When within a `~{` construct, the "goto" is relative to the list of arguments being processed by the iteration.

## Indirection (\~?)

**Syntax:** **\~?**

The next argument *arg* must be a string, and the one after it *lst* must be a sequence (e.g. an array). Both arguments are consumed by the directive. *arg* is processed as a format control string, with the elements of the list *lst* as the arguments. Once the recursive processing of the control string has been finished, then processing of the control string containing the `~?` directive is resumed.

```swift
try clformat("~? ~D", args: "(~A ~D)", ["Foo", 5], 7)
⇒ (Foo 5) 7
try clformat("~? ~D", args: "(~A ~D)", ["Foo", 5, 14], 7)
⇒ (Foo 5) 7
```

Note that in the second example, three arguments are supplied to the control string `"(~A ~D)"`, but only two are processed and the third is therefore ignored.

With the `@` modifier, only one argument is directly consumed. The argument must be a string. It is processed as part of the control string as if it had appeared in place of the `~@?` directive, and any directives in the recursively processed control string may consume arguments of the control string containing the `~@?` directive.

```swift
try clformat("~@? ~D", args: "(~A ~D)", "Foo", 5, 7)
⇒ (Foo 5) 7
try clformat("~@? ~D", args: "(~A ~D)", "Foo", 5, 14, 7)
⇒ (Foo 5) 14
```

## Conversion (\~(…\~))

**Syntax:** **\~(**_str_**\~)**

The contained control string *str* is processed, and what it produces is subject to a conversion. Without the `+` modifier, a *case conversion* is performed. `~(` converts every uppercase character to the corresponding lowercase character, `~:(` capitalizes all words, `~@(` capitalizes just the first word and forces the rest to lowercase, and `~:@(` converts every lowercase character to the corresponding uppercase character. In the following example, `~@(` is used to cause the first word produced by `~R` to be capitalized:

```swift
try clformat("~@(~R~) error~:P", args: 0)
⇒ Zero errors
try clformat("~@(~R~) error~:P", args: 1)
⇒ One error
try clformat("~@(~R~) error~:P", args: 23)
⇒ Twenty-three errors
```

If the `+` modifier is provided together with the `:` modifier, all characters corresponding to named XML entities are being converted into named XML entities. If modifier `@` is added, then only those characters are converted which conflict with XML syntax. The modifier combination `+@` converts the output by stripping off all diacritics. Modifier `+` only will escape characters such that the result can be used as a Swift string literal.

```swift
try clformat("~+:(~A~)", args: "© 2021–2023 TÜV")
⇒ &copy; 2021&ndash;2023 T&Uuml;V
try clformat("~+:@(~A~)", args: "<a href=\"t.html\">© TÜV</a>")
⇒ &lt;a href=&quot;t.html&quot;&gt;© TÜV&lt;/a&gt;
try clformat("~+@(~A~)", args: "épistèmê")
⇒ episteme
try clformat("~+(~A~)", args: "Hello \"World\"\n")
⇒ Hello \"World\"\n
```

## Conditional (\~\[…\~\])

**Syntax:** **\~\[**_str₀_**\~;**_str₁_**\~;…\~;**_strₙ_**\~\]**

This is a set of control strings, called clauses, one of which is chosen and used. The clauses are separated by `~;` and the construct is terminated by `~]`.

*Without default:*  From a conditional directive `~[`*str₀*`~;`*str₁*`~;…~;`*strₙ*`~]`, the *arg*-th clause is selected, where the first clause is number 0. If a prefix parameter is given as `~n[`, then the parameter *n* is used instead of an argument. This is useful only if the parameter is specified by `#`, to dispatch on the number of arguments remaining to be processed. If *arg* or *n* is out of range, then no clause is selected and no error is signaled. After the selected alternative has been processed, the control string continues after the `~]`.

*With default:*  Whenever the directive has the form `~[`*str₀*`~;`*str₁*`~;…~:;`*default*`~]`, i.e. the last clause is separated via `~:;`, then the conditional directive has a default clause which gets performed whenever no other clause could be selected.

*Optional selector:*  Whenever the directive has the form `~:[`*none*`~;`*some*`~]` the *none* control string is chosen if *arg* is `nil`, otherwise the *some* control string is chosen.

*Boolean selector:*  Whenever the directive has the form `~+[`*false*`~;`*true*`~]` the *false* control string is chosen if *arg* is the boolean value `false`, otherwise the *true* control string is chosen.

*Selector test:*  Whenever the directive has the form `~@[`*true*`~]`, the next argument *arg* is tested for being non-`nil`. If *arg* is not `nil`, then the argument is not used up by the `~@[` directive but remains as the next one to be processed, and the one clause *true* is processed. If *arg* is `nil`, then the argument is used up, and the clause is not processed. The clause therefore should normally use exactly one argument, and may expect it to be non-`nil`.

## Iteration (\~{…\~})

**Syntax:** **\~**_n_**{**_str_**\~}**

The iteration directive is used to control how a sequence is output. Thus, the next argument *arg* should be a sequence which is used as a list of arguments as if for a recursive call to `clformat`. The string *str* is used repeatedly as the control string until all elements from *arg* are consumed. Each iteration can absorb as many elements of *arg* as it needs. For instance, if *str* uses up two arguments by itself, then two elements of *arg* will get used up each time around the loop. If before any iteration step the sequence is empty, then the iteration is terminated. Also, if a prefix parameter *n* is given, then there will be at most *n* repetitions of processing of *str*. Finally, the `~^` directive can be used to terminate the iteration prematurely. If the iteration is terminated before all the remaining arguments are consumed, then any arguments not processed by the iteration remain to be processed by any directives following the iteration construct.

```swift
try clformat("Winners:~{ ~A~}.", args: ["Fred", "Harry", "Jill"])
⇒ Winners: Fred Harry Jill.
try clformat("Winners: ~{~#[~;~A~:;~A, ~]~}.", args: ["Fred", "Harry", "Jill"])
⇒ Winners: Fred, Harry, Jill.
try clformat("Pairs:~{ <~A,~S>~}.", args: ["A", 1, "B", 2, "C", 3])
⇒ Pairs: <A,1> <B,2> <C,3>.
```

`~:n,m{str~}` is similar, but the argument should be a list of sublists. At each repetition step (capped by *n*), one sublist is used as the list of arguments for processing *str* with an iteration cap of *m*. On the next repetition, a new sublist is used, whether or not all elements of the last sublist had been processed.

```swift
try clformat("Pairs:~:{ <~A,~S>~}.", args: [["A", 1], ["B", 2], ["C", 3]])
⇒ Pairs: <A,1> <B,2> <C,3>.
```

`~@{str~}` is similar to `~{str~}`, but instead of using one argument that is a sequence, all the remaining arguments are used as the list of arguments for the iteration.

```swift
try clformat("Pairs:~@{ <~A,~S>~}.", args: "A", 1, "B", 2, "C", 3)
⇒ Pairs: <A,1> <B,2> <C,3>.
```

`~:@{str~}` combines the features of `~:{str~}` and `~@{str~}`. All the remaining arguments are used, and each one must be a sequence. On each iteration, the next argument is used as a list of arguments to *str*.

```swift
try clformat("Pairs:~:@{ <~A,~S>~}.", args: ["A", 1], ["B", 2], ["C", 3])
⇒ Pairs: <A,1> <B,2> <C,3>.
```

Terminating the repetition directive with `~:}` instead of `~}` forces *str* to be processed at least once, even if the initial sequence is empty. However, it will not override an explicit prefix parameter of zero. If *str* is empty, then an argument is used as *str*. It must be a string and precede any arguments processed by the iteration.

## Up and out (\~^)

**Syntax:** **\~^**

*Continue:*  The `~^` directive is an escape construct. If there are no more arguments remaining to be processed, then the immediately enclosing `~{` or `~<` directive is terminated. If there is no such enclosing directive, then the entire formatting operation is terminated. In the case of `~<`, the formatting is performed, but no more segments are processed before doing the justification. The `~^` directive should appear only at the beginning of a `~<` clause, because it aborts the entire clause it appears in, as well as all following clauses. `~^` may appear anywhere in a `~{` construct.

```swift
try clformat("Done.~^ ~D warning~:P.~^ ~D error~:P.")
⇒ Done.
try clformat("Done.~^ ~D warning~:P.~^ ~D error~:P.", args: 3)
⇒ Done. 3 warnings.
try clformat("Done.~^ ~D warning~:P.~^ ~D error~:P.", args: 1, 5)
⇒ Done. 1 warning. 5 errors.
```

If the directive has the form `~n^`, then termination occurs if *n* is zero. If the directive has the form `~n,m^`, termination occurs if the value of *n* equals the value of *m*. If the directive has the form `~n,m,o^`, termination occurs if *n* ≤ *m* ≤ *o*. Of course, this is useless if all the prefix parameters are literals. At least one of them should be a `#` or a `v` parameter.

*Break:*  If `~^` is used within a `~:{` directive, then it merely terminates the current iteration step because in the standard case, it tests for remaining arguments of the current step only and the next iteration step commences immediately. To terminate the entire iteration process, use `~:^`. `~:^` may only be used if the directive it would terminate is `~:{` or `~:@{`. The entire iteration process is terminated if and only if the sublist that is supplying the arguments for the current iteration step is the last sublist (in the case of terminating a `~:{` directive) or the last argument to that call to format (in the case of terminating a `~:@{` directive).

Note that while `~^` is equivalent to `~#^` in all circumstances, `~:^` is not equivalent to `~#:^` because the latter terminates the entire iteration if and only if no arguments remain for the current iteration step, as opposed to no arguments remaining for the entire iteration process.

```swift
try clformat("~:{/~A~^ ...~}",
             args: [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]])
⇒ /hot .../hamburger/ice .../french ...
try clformat("~:{/~A~:^ ...~}",
             args: [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]])
⇒ /hot .../hamburger .../ice .../french
try clformat("~:{/~A~#:^ ...~}",
             args: [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]])
⇒ /hot .../hamburger
```
