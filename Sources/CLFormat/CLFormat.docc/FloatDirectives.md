# Floating-point directives

Output floating-point numbers in fixed, exponential, and monetary formats.

## Fixed float (\~F)

**Syntax:** **\~**_w,d,k,overchar,padchar,groupchar,groupcol_**F**

The next argument *arg* is output as a floating-point number in a fixed format (ideally without exponent) of exactly *w* characters, if *w* is specified. First, leading *padchar* characters (default: ' ') are output, if necessary, to pad the field on the left. If *arg* is negative, then a minus sign is printed. If *arg* is not negative, then a plus sign is printed if and only if the `@` modifier was specified. Then a sequence of digits, containing a single embedded decimal point, is printed. If parameter *d* is provided, then exactly *d* decimal places are output. This represents the magnitude of the value of *arg* times 10ᵏ, rounded to *d* fractional digits. There are no leading zeros, except that a single zero digit is output before the decimal point if the printed value is less than 1.0, and this single zero digit is not output after all if *w = d* + 1.

If it is impossible to print the value in the required format in a field of width *w*, then one of two actions is taken: If the parameter *overchar* is specified, then *w* copies of this character are printed. If *overchar* is omitted, then the scaled value of *arg* is printed using more than *w* characters.

If the width parameter *w* is omitted, then the output is of variable width and a value is chosen for *w* in such a way that no leading padding characters are needed and exactly *d* characters will follow the decimal point. For example, the directive `~,2F` will output exactly two digits after the decimal point and as many as necessary before the decimal point.

If *d* is omitted, then there is no constraint on the number of digits to appear after the decimal point. A value is chosen for *d* in such a way that as many digits as possible may be printed subject to the width constraint imposed by *w* and the constraint that no trailing zero digits may appear in the fraction, except that if the fraction is zero, then a single zero digit should appear after the decimal point if permitted by the width constraint.

If *w* is omitted, then if the magnitude of *arg* is so large (or, if *d* is also omitted, so small) that more than 100 digits would have to be printed, then *arg* is output using exponential notation instead.

The `~F` directive also supports grouping of the integer part of *arg*; this can be enabled via the `:` modifier. *groupchar* (default: ',') specifies which character should be used to separate sequences of *groupcol* (default: 3) digits in the integer part of the output. If locale-specific settings should be used, the `+` modifier needs to be set.

```swift
try clformat("~F", args: 123.1415926)
⇒ 123.1415926
try clformat("~8F", args: 123.1415926)
⇒ 123.1416
try clformat("~8,,,'-F", args: 123.1415926)
⇒ 123.1416
try clformat("~8,,,'-F", args: 123456789.12)
⇒ --------
try clformat("~8,,,,'0F", args: 123.14)
⇒ 00123.14
try clformat("~8,3,,,'0F", args: 123.1415926)
⇒ 0123.142
try clformat("~,4F", args: 123.1415926)
⇒ 123.1416
try clformat("~,2@F", args: 123.1415926)
⇒ +123.14
try clformat("~,2,-2@F", args: 314.15926)
⇒ +3.14
try clformat("~,2:F", args: 1234567.891)
⇒ 1,234,567.89
try clformat("~,2,,,,'',3:F", args: 1234567.891)
⇒ 1'234'567.89
```

## Exponential float (\~E)

**Syntax:** **\~**_w,d,e,k,overchar,padchar,expchar_**E**

The next argument *arg* is output as a floating-point number in an exponential format of exactly *w* characters, if *w* is specified. Parameter *d* is the number of digits to print after the decimal point, *e* is the number of digits to use when printing the exponent, and *k* is a scale factor that defaults to 1.

First, leading *padchar* (default: ' ') characters are output, if necessary, to pad the output on the left. If *arg* is negative, then a minus sign is printed. If *arg* is not negative, then a plus sign is printed if and only if the `@` modifier was specified. Then a sequence of digits, containing a single embedded decimal point, is output. The form of this sequence of digits depends on the scale factor *k*. If *k* is zero, then *d* digits are printed after the decimal point, and a single zero digit appears before the decimal point. If *k* is positive, then it must be strictly less than *d* + 2 and *k* significant digits are printed before the decimal point, and *d − k* + 1 digits are printed after the decimal point. If *k* is negative, then it must be strictly greater than *−d*. A single zero digit appears before the decimal point and after the decimal point, first *−k* zeros are output followed by *d + k* significant digits.

Following the digit sequence, the exponent is output following character *expchar* (default: 'E') and the sign of the exponent, i.e. either the plus or the minus sign. The exponent consists of *e* digits representing the power of 10 by which the fraction must be multiplied to properly represent the rounded value of *arg*.

If it is impossible to print the value in the required format in a field of width *w*, then one of two actions is taken: If the parameter *overchar* is specified, then *w* copies of this character are printed instead of *arg*. If *overchar* is omitted, then *arg* is printed using more than *w* characters, as many more as may be needed. If *d* is too small for the specified *k* or *e* is too small, then a larger value is used for *d* or *e* as may be needed.

If the *w* parameter is omitted, then the output is of variable width and a value is chosen for *w* in such a way that no leading padding characters are needed.

```swift
try clformat("~E", args: 31.415926)
⇒ 3.1415926E+1
try clformat("~,5E", args: 0.0003141592)
⇒ 3.14159E-4
try clformat("~,4,2E", args: 0.0003141592)
⇒ 3.1416E-04
try clformat("~9E", args: 31.415926)
⇒ 3.1416E+1
try clformat("~10,3,,,,'#E", args: 31.415926)
⇒ ##3.142E+1
try clformat("~10,4,,3,,'#E", args: 31.415926)
⇒ #314.16E-1
try clformat("~7,3,2,,'-E", args: 31.415926)
⇒ -------
try clformat("~10,4,,4,,'#@E", args: 31.415926)
⇒ +3141.6E-2
```

## General float (\~G)

**Syntax:** **\~**_w,d,e,k,overchar,padchar,expchar_**G**

The next argument *arg* is output as a floating-point number in either fixed-format or exponential notation as appropriate. The format in which to print *arg* depends on the magnitude (absolute value) of *arg*. Let *n* be an integer such that 10ⁿ⁻¹ ≤ *arg* < 10ⁿ. If *arg* is zero, let *n* be 0. Let *ee* equal *e* + 2, or 4 if *e* is omitted. Let *ww* equal *w* − *ee*, or nil if *w* is omitted. If *d* is omitted, first let *q* be the number of digits needed to print *arg* with no loss of information and without leading or trailing zeros; then let *d* equal *max(q, min(n, 7))*. Let *dd* equal *d − n*.

If 0 ≤ *dd* ≤ *d*, then *arg* is output as if by the format directives:

`~ww,dd,,overchar,padcharF~ee@T`

Note that the scale factor *k* is not passed to the `~F` directive. For all other values of *dd*, *arg* is printed as if by the format directive:

`~w,d,e,k,overchar,padchar,expcharE`

In either case, an `@` modifier is specified to the `~F` or `~E` directive if and only if one was specified to the `~G` directive.

```swift
try clformat("|~G|", args: 712.72)
⇒ |712.72    |
try clformat("|~12G|", args: 712.72)
⇒ |  712.72    |
try clformat("|~9,2G|~9,3,2,3G|~9,3,2,0G|", args: 0.031415, 0.031415, 0.031415)
⇒ |  3.14E-2|314.2E-04|0.314E-01|
try clformat("|~9,2G|~9,3,2,3G|~9,3,2,0G|", args: 0.314159, 0.314159, 0.314159)
⇒ | 0.31    |0.314    |0.314    |
try clformat("|~9,2G|~9,3,2,3G|~9,3,2,0G|", args: 3.14159, 3.14159, 3.14159)
⇒ |  3.1    | 3.14    | 3.14    |
try clformat("|~9,2G|~9,3,2,3G|~9,3,2,0G|", args: 314.159, 314.159, 314.159)
⇒ |  3.14E+2|  314    |  314    |
try clformat("|~9,2G|~9,3,2,3G|~9,3,2,0G|", args: 3141.59, 3141.59, 3141.59)
⇒ |  3.14E+3|314.2E+01|0.314E+04|
```

## Dollars float (\~$)

**Syntax:** **\~**_d,n,w,padchar,curchar,groupchar,groupcol_**$**

The next argument *arg* is output as a floating-point number in a fixed-format notation that is particularly well suited for outputting monetary values. Parameter *d* (default: 2) defines the number of digits to print after the decimal point. Parameter *n* (default: 1) defines the minimum number of digits to print before the decimal point. Parameter *w* (default: 0) is the minimum total width of the output.

First, padding and the sign are output. If *arg* is negative, then a minus sign is printed. If *arg* is not negative, then a plus sign is printed if and only if the `@` modifier was specified. If the `:` modifier is used, the sign appears before any padding, and otherwise after the padding. If the number of characters, including the sign and a potential currency symbol is below width *w*, then character *padchar* (default: ' ') is used for padding the number in front of the integer part such that the overall output has *w* characters. After the padding, the currency symbol *curchar* is inserted, if available, followed by *n* digits representing the integer part of *arg*, prefixed by the right amount of '0' characters. If either parameter *groupchar* or *groupcol* is provided, the integer part is output in groups of *groupcol* characters (default: 3) separated by *groupchar* (default: ','). After the integer part, a decimal point is output followed by *d* digits of fraction, properly rounded.

If the magnitude of *arg* is so large that the integer part of *arg* cannot be output with at most *n* characters, then more characters are generated, as needed, and the total width might overrun as well.

For cases where a simple currency symbol is not sufficient, it is possible to use a numeric currency code as defined by ISO 4217 for parameter *curchar*. For positive codes, the shortest currency symbol is being used. For negative currency codes, the corresponding alphabetic code (ignoring the sign) is being used. Struct ``Currency`` provides a convenient way to access currency codes.

By specifying the `+` modifier, it is possible to enable locale-specific output of the monetary value using the locale provided to function `clformat`. In this case, also the currency associated with this locale is being used.

```swift
try clformat("~$", args: 4930.351)
⇒ 4930.35
try clformat("~3$", args: 4930.351)
⇒ 4930.351
try clformat("~,6$", args: 4930.351)
⇒ 004930.35
try clformat("~,6,12,'_$", args: 4930.351)
⇒ ___004930.35
try clformat("~,6,12,'_@$", args: 4930.351)
⇒ __+004930.35
try clformat("~,6,12,'_@:$", args: 4930.351)
⇒ +__004930.35
try clformat("~,6,12,'_,'€$", args: 4930.351)
⇒ __€004930.35
try clformat("~,6,12,'_,'€@$", args: 4930.351)
⇒ _+€004930.35
try clformat("~,,,,,,3$", args: 4930.351)
⇒ 4,930.35
try clformat("~,6,,,,,3$", args: 4930.351)
⇒ 004,930.35
try clformat("~,,,,208$", args: 1234.567)
⇒ kr 1234.57
try clformat("~,,,,-208$", args: 1234.567)
⇒ DKK 1234.57
try clformat("~+$", locale: Locale(identifier: "de_CH"), args: 4930.351)
⇒ CHF 4930.35
try clformat("~,,,,,,3+$", locale: Locale(identifier: "en_US"), args: 4930.351)
⇒ $4,930.35
try clformat("~,6,14,'_,,,3+$", locale: Locale(identifier: "de_DE"), args: 4930.351)
⇒ __004.930,35 €
```
