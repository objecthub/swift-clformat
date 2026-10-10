# Integer directives

Output integers in decimal and other radixes, as roman numerals, or in natural language.

## Decimal (\~D)

**Syntax:** **\~**_mincol,padchar,groupchar,groupcol_**D**

The next argument *arg* is output in decimal radix. *arg* should be an integer, in which case no decimal point is printed. For floating-point numbers which do not represent an integer, a decimal point and a fractional part are output.

*mincol* (default: 0) specifies the minimal "width" of the output of the directive in characters with *padchar* (default: ' ') defining the character that is used to pad the output on the left to make sure it is at least *mincol* characters long.

```swift
try clformat("Number: ~D", args: 8273)
⇒ Number: 8273
try clformat("Number: ~6D", args: 8273)
⇒ Number:   8273
try clformat("Number: ~6,'0D", args: 8273)
⇒ Number: 008273
```

By default, the number is output without grouping separators. *groupchar* specifies which character should be used to separate sequences of *groupcol* digits in the output. Grouping of digits gets enabled with the `:` modifier.

```swift
try clformat("|~10:D|", args: 1734865)
⇒ | 1,734,865|
try clformat("|~10,,'.:D|", args: 1734865)
⇒ | 1.734.865|
```

A sign is output only if the number is negative. With the modifier `@` it is possible to force output also of positive signs. To facilitate the localization of output, function `clformat` supports a parameter `locale:`. Locale-specific output can be enabled by using the `+` modifier.

```swift
try clformat("~+D", locale: Locale(identifier: "de_CH"), args: 14321)
⇒ 14'321
```

## Binary (\~B)

**Syntax:** **\~**_mincol,padchar,groupchar,groupcol_**B**

Binary directive `~B` is just like decimal directive `~D` but it outputs the next argument in binary radix (radix 2) instead of decimal. It uses the space character as the default for *groupchar* and has a default grouping size of 4 as the default for *groupcol*.

```swift
try clformat("bin(~D) = ~B", args: 178, 178)
⇒ bin(178) = 10110010
try clformat("~:B", args: 59701)
⇒ 1110 1001 0011 0101
try clformat("~19,'0,'.:B", args: 31912)
⇒ 0111.1100.1010.1000
```

## Octal (\~O)

**Syntax:** **\~**_mincol,padchar,groupchar,groupcol_**O**

Octal directive `~O` is just like decimal directive `~D` but it outputs the next argument in octal radix (radix 8) instead of decimal. It uses the space character as the default for *groupchar* and has a default grouping size of 4 as the default for *groupcol*.

```swift
try clformat("bin(~D) = ~O", args: 178, 178)
⇒ bin(178) = 262
try clformat("~:O", args: 59701)
⇒ 16 4465
try clformat("~9,'0,',:O", args: 31912)
⇒ 0007,6250
```

## Hexadecimal (\~X)

**Syntax:** **\~**_mincol,padchar,groupchar,groupcol_**X**

Hexadecimal directive `~X` is just like decimal directive `~D` but it outputs the next argument in hexadecimal radix (radix 16) instead of decimal. It uses the colon character as the default for *groupchar* and has a default grouping size of 2 as the default for *groupcol*. With modifier `+`, upper case characters are used for representing hexadecimal digits.

```swift
try clformat("bin(~D) = ~X", args: 9968, 9968)
⇒ bin(9968) = 26f0
try clformat("~:X", args: 999701)
⇒ f:41:15
try clformat("~+X", args: 999854)
⇒ F41AE
```

## Radix (\~R)

**Syntax:** **\~**_radix,mincol,padchar,groupchar,groupcol_**R**

The next argument *arg* is expected to be an integer. It will be output with radix *radix*. *mincol* (default: 0) specifies the minimal "width" of the output of the directive in characters with *padchar* (default: ' ') defining the character that is used to pad the output on the left to make it at least *mincol* characters long.

```swift
try clformat("Number: ~10R", args: 1272)
⇒ Number: 1272
try clformat("Number: ~16,8,'0R", args: 7121972)
⇒ Number: 006cac34
try clformat("Number: ~2R", args: 173)
⇒ Number: 10101101
```

By default, the number is output without grouping separators. *groupchar* specifies which character should be used to separate sequences of *groupcol* digits in the output. Grouping of digits is enabled with the `:` modifier.

```swift
try clformat("~16,8,,':,2:R", args: 7121972)
⇒ 6c:ac:34
try clformat("~2,14,'0,'.,4:R", args: 773)
⇒ 0011.0000.0101
```

A sign is output only if the number is negative. With the modifier `@` it is possible to force output also of positive signs.

If parameter *radix* is not specified at all, then an entirely different interpretation is given. `~R` outputs *arg* as a cardinal number in natural language. The form `~:R` outputs *arg* as an ordinal number in natural language. `~@R` outputs *arg* as a Roman numeral.

```swift
try clformat("~R", args: 572)
⇒ five hundred seventy-two
try clformat("~:R", args: 3)
⇒ 3rd
try clformat("~@R", args: 1272)
⇒ MCCLXXII
```

Whenever output is provided in natural language, English is used as the language by default. By specifying the `+` modifier, it is possible to switch the language to the language of the locale provided to function `clformat`. In fact, modifier `+` plays two different roles: If the given radix is greater than 10, upper case characters are used for representing alphabetic digits. If the radix is omitted, usage of modifier `+` enables locale-specific output determined by the `locale:` parameter of function `clformat`.

```swift
try clformat("~+R", locale: Locale(identifier: "de_DE"), args: 572)
⇒ fünf­hundert­zwei­und­siebzig
try clformat("~10+R", locale: Locale(identifier: "de_CH"), args: 14321)
⇒ 14'321
try clformat("~16R vs ~16+R", args: 900939, 900939)
⇒ dbf4b vs DBF4B
```
