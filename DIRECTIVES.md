#  CLFormat Directives

The formatting directives supported by the _CLFormat_ framework are based on the directives
specified in [Common Lisp the Language, 2nd Edition](https://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node1.html)
by Guy L. Steele Jr. Some directives have been extended to meet today's formatting requirements
(e.g. to support localization) and to achieve a natural embedding in Swift. All extensions were
introduced in a way to not impact backward compatibility. 

<table>
<thead>
  <tr><th>Directive</th><th>Explanation</th></tr>
</thead>
<tbody>
<tr valign="top">
  <td><b>~a</b><br/><b>~A</b></td>
  <td>
  <p>ASCII:&nbsp;&nbsp;<b>~<i>mincol,colinc,minpad,padchar,maxcol,elchar</i>A</b></p>
  <p>The next argument <i>arg</i> is output without escape characters. In particular, if <i>arg</i>
     is a string, its characters will be output verbatim. If <i>arg</i> is nil, it will be output as
     <tt>nil</tt>. If <i>arg</i> is not nil, then the formatter will attempt to convert <i>arg</i>
     using one of the following properties (tried in the order as listed below) into a string that
     is output:</p>
  <ol>
     <li>If <i>arg</i> implements protocol <tt>CLFormatConvertible</tt> then property
        <tt>clformatDebugDescription</tt> will be output.</li>
     <li>If <i>arg</i> implements protocol <tt>CustomStringConvertible</tt> then property
         <tt>description</tt> will be output.</li>
     <li>String interpolation is used to turn <i>arg</i> into a string.
   </ol>
  <p><i>mincol</i> (default: 0) specifies the minimal "width" of the output of the directive
     in characters, <i>maxcol</i> (default: &infin;) specifies the maximum width. <i>padchar</i>
     (default: ' ') defines the character that is used to pad the output to make sure it is at
     least <i>mincol</i> characters long. By default, the output is padded on the right with
     at least <i>minpad</i> (default: 0) copies of <i>padchar</i>. Padding characters are then
     inserted <i>colinc</i> (default: 1) characters at a time until the total width is at
     least <i>mincol</i>. Padding is capped such that the output never exceeds <i>maxcol</i>
     characters. If, without padding, the output is already longer than <i>maxcol</i>, the
     output is truncated at width <i>maxcol - 1</i> and the ellipsis character <i>elchar</i>
     (default: '&hellip;') is inserted at the end.<p>
  <p>Modifier <tt>:</tt> enables debugging output, i.e. the following sequence of properties of
     <i>arg</i> are considered for generating the output:</p>
  <ol>
     <li>If <i>arg</i> implements protocol <tt>DebugCLFormatConvertible</tt> then property
         <tt>clformatDebugDescription</tt> will be output.</li>
     <li>If <i>arg</i> implements protocol <tt>CustomDebugStringConvertible</tt> then property
         <tt>debugDescription</tt> will be output.</li>
     <li>The properties as listed above are tried to generate the output.
  </ol>
  <p>Modifier <tt>@</tt> enables padding on the left to right-align the output.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~w</b><br/><b>~W</b></td>
  <td>
  <p>WRITE:&nbsp;&nbsp;<b>~<i>mincol,colinc,minpad,padchar,maxcol,elchar</i>W</b></p>
  <p>The next argument <i>arg</i> is output without escape characters just as if it was
     printed via Swift's <tt>print</tt> function. If <i>arg</i> is nil, it will be output as
     <tt>nil</tt>. If <i>arg</i> is not nil, then the formatter will attempt to convert <i>arg</i>
     using one of the following properties (tried in the order as listed below) into a string that
     is output:</p>
  <ol>
     <li>If the <tt>:</tt> modifier was provided and <i>arg</i> implements protocol
         <tt>CustomDebugStringConvertible</tt> then property <tt>debugDescription</tt> will
         be output.</li>
     <li>If <i>arg</i> implements protocol <tt>CustomStringConvertible</tt> then property
         <tt>description</tt> will be output.</li>
     <li>String interpolation is used to turn <i>arg</i> into a string.
   </ol>
  <p>Parameters <i>mincol</i> (default: 0), <i>colinc</i> (default: 1), <i>minpad</i> (default: 0),
     <i>padchar</i> (default: ' '), <i>maxcol</i> (default: &infin;), and
     <i>elchar</i> (default: '&hellip;') are used just as described for the <i>ASCII directive</i>
     <tt>~A</tt>. Modifier <tt>:</tt> enables debugging output. Modifier <tt>@</tt> enables
     padding on the left to right-align the output.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~s</b><br/><b>~S</b></td>
  <td>
  <p>SOURCE:&nbsp;&nbsp;<b>~<i>mincol,colinc,minpad,padchar,maxcol,elchar</i>S</b></p>
  <p>The next argument <i>arg</i> is output with escape characters. In particular, if <i>arg</i>
     is a string, double-quotes delimit the characters of the string. If <i>arg</i> is a character,
     single-quotes delimit the character. If <i>arg</i> is nil, it will be output as
     <tt>nil</tt>. For all other values, the formatter will attempt to convert <i>arg</i>
     using one of the following properties (tried in the order as listed below) into a string that
     is output:</p>
  <ol>
     <li>If the <tt>:</tt> modifier was provided and <i>arg</i> implements protocol
         <tt>DebugCLFormatConvertible</tt> then property <tt>clformatDebugDescription</tt> will
         be output.</li>
     <li>If the <tt>:</tt> modifier was provided and <i>arg</i> implements protocol
         <tt>CustomDebugStringConvertible</tt> then property <tt>debugDescription</tt> will
         be output.</li>
     <li>If <i>arg</i> implements protocol <tt>CLFormatConvertible</tt> then property
         <tt>clformatDescription</tt> will be output.</li>
     <li>If <i>arg</i> implements protocol <tt>CustomStringConvertible</tt> then property
         <tt>description</tt> will be output.</li>
     <li>String interpolation is used to turn <i>arg</i> into a string.
  </ol>
  <p>Parameters <i>mincol</i> (default: 0), <i>colinc</i> (default: 1), <i>minpad</i> (default: 0),
     <i>padchar</i> (default: ' '), <i>maxcol</i> (default: &infin;), and
     <i>elchar</i> (default: '&hellip;') are used just as described for the <i>ASCII directive</i>
     <tt>~A</tt>. Modifier <tt>:</tt> enables debugging output. Modifier <tt>@</tt> enables
     padding on the left to right-align the output.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~c</b><br/><b>~C</b></td>
  <td>
  <p>CHARACTER:&nbsp;&nbsp;<b>~C</b></p>
  <p>The next argument <i>arg</i> should be a character. Directive <tt>~C</tt> outputs <i>arg</i>
     in a form dependent on the modifiers used. Without any modifiers, <i>arg</i> is output as
     if the character was used in a string.<p>     
  <p>If the <tt>@</tt> modifier is provided, a representation based on <i>Unicode scalars</i>
     is chosen. Without further modifiers, 
     <i>arg</i> is output using Swift's Unicode scalar escape syntax <tt>\u{...}</tt> so that
     the result can be used within a Swift string literal. By adding the <tt>+</tt> modifier,
     the result is automatically surrounded by double-quotes. The modifier combination <tt>@:</tt>
     will lead to <i>arg</i> being output as Unicode code points. The combination <tt>@:+</tt>
     will output <i>arg</i> as a sequence of Unicode scalar property names, separated by comma.</p>
  <p>If the <tt>:</tt> modifier is used (without <tt>@</tt>), a representation of <i>arg</i>
     for the usage in XML documents is chosen. By default, a Unicode-based XML character encoding
     is used, unless <tt>:</tt> is combined with <tt>+</tt>, in which case the character is
     represented as a XML named character entity when possible, otherwise, the character is
     output in raw form.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~C", args: "A")</tt> &DoubleLongRightArrow; <tt>A</tt><br />
     &nbsp;&nbsp;<tt>clformat("~@C", args: "A")</tt> &DoubleLongRightArrow; <tt>\u{41}</tt><br />
     &nbsp;&nbsp;<tt>clformat("~@+C", args: "A")</tt> &DoubleLongRightArrow; <tt>"\u{41}"</tt><br />
     &nbsp;&nbsp;<tt>clformat("~@:C", args: "©")</tt> &DoubleLongRightArrow; <tt>U+00A9</tt><br />
     &nbsp;&nbsp;<tt>clformat("~@:+C", args: "©")</tt> &DoubleLongRightArrow; <tt>COPYRIGHT SIGN</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:C", args: "©")</tt> &DoubleLongRightArrow; <tt>&#038;#xA9;</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:+C", args: "©")</tt> &DoubleLongRightArrow; <tt>&#038;copy;</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~d</b><br/><b>~D</b></td>
  <td>
  <p>DECIMAL:&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>D</b></p>
  <p>The next argument <i>arg</i> is output in decimal radix. <i>arg</i> should be an integer,
     in which case no decimal point is printed. For floating-point numbers which do not represent
     an integer, a decimal point and a fractional part are output.</p>
  <p><i>mincol</i> (default: 0) specifies the minimal "width" of the output of the directive
     in characters with <i>padchar</i> (default: ' ') defining the character that is used to
     pad the output on the left to make sure it is at least <i>mincol</i> characters long.</p>
  <p>&nbsp;&nbsp;<tt>clformat("Number: ~D", args: 8273)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;8273</tt><br />
     &nbsp;&nbsp;<tt>clformat("Number: ~6D", args: 8273)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;&nbsp;&nbsp;8273</tt><br />
     &nbsp;&nbsp;<tt>clformat("Number: ~6,'0D", args: 8273)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;008273</tt></p>
  <p>By default, the number is output without grouping separators. <i>groupchar</i> specifies
     which character should be used to separate sequences of <i>groupcol</i> digits in the
     output. Grouping of digits gets enabled with the <tt>:</tt> modifier.</p>
  <p>&nbsp;&nbsp;<tt>clformat("|~10:D|", args: 1734865)</tt> &DoubleLongRightArrow; <tt>|&nbsp;1,734,865|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~10,,'.:D|", args: 1734865)</tt> &DoubleLongRightArrow; <tt>|&nbsp;1.734.865|</tt></p>
  <p>A sign is output only if the number is negative. With the modifier <tt>@</tt> it is possible
     to force output also of positive signs. To facilitate the localization of output, function
     <tt>clformat</tt> supports a parameter <tt>locale:</tt>. Locale-specific
     output can be enabled by using the <tt>+</tt> modifier.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~+D", locale: Locale(identifier: "de_CH"), args: 14321)</tt> &DoubleLongRightArrow; <tt>14'321</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~b</b><br/><b>~B</b></td>
  <td>
  <p>BINARY:&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>B</b></p>
  <p>Binary directive <tt>~B</tt> is just like decimal directive <tt>~D</tt> but it outputs
     the next argument in binary radix (radix 2) instead of decimal. It uses the space character
     as the default for <i>groupchar</i> and has a default grouping size of 4 as the default for
     <i>groupcol</i>.</p>
  <p>&nbsp;&nbsp;<tt>clformat("bin(~D) = ~B", args: 178, 178)</tt> &DoubleLongRightArrow; <tt>bin(178) = 10110010</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:B", args: 59701)</tt> &DoubleLongRightArrow; <tt>1110 1001 0011 0101</tt><br />
     &nbsp;&nbsp;<tt>clformat("~19,'0,'.:B", args: 31912)</tt> &DoubleLongRightArrow; <tt>0111.1100.1010.1000</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~o</b><br/><b>~O</b></td>
  <td>
  <p>OCTAL:&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>O</b></p>
  <p>Octal directive <tt>~O</tt> is just like decimal directive <tt>~D</tt> but it outputs
     the next argument in octal radix (radix 8) instead of decimal. It uses the space character
     as the default for <i>groupchar</i> and has a default grouping size of 4 as the default for
     <i>groupcol</i>.</p>
  <p>&nbsp;&nbsp;<tt>clformat("bin(~D) = ~O", args: 178, 178)</tt> &DoubleLongRightArrow; <tt>bin(178) = 262</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:O", args: 59701)</tt> &DoubleLongRightArrow; <tt>16 4465</tt><br />
     &nbsp;&nbsp;<tt>clformat("~9,'0,',:O", args: 31912)</tt> &DoubleLongRightArrow; <tt>0007,6250</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~x</b><br/><b>~X</b></td>
  <td>
  <p>HEXADECIMAL:&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>X</b></p>
  <p>Hexadecimal directive <tt>~X</tt> is just like decimal directive <tt>~D</tt> but it outputs
     the next argument in hexadecimal radix (radix 16) instead of decimal. It uses the colon character
     as the default for <i>groupchar</i> and has a default grouping size of 2 as the default for
     <i>groupcol</i>. With modifier <tt>+</tt>, upper case characters are used for representing
     hexadecimal digits.</p>
  <p>&nbsp;&nbsp;<tt>clformat("bin(~D) = ~X", args: 9968, 9968)</tt> &DoubleLongRightArrow; <tt>bin(9968) = 26f0</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:X", args: 999701)</tt> &DoubleLongRightArrow; <tt>f:41:15</tt><br />
     &nbsp;&nbsp;<tt>clformat("~+X", args: 999854)</tt> &DoubleLongRightArrow; <tt>F41AE</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~r</b><br/><b>~R</b></td>
  <td>
  <p>RADIX:&nbsp;&nbsp;<b>~<i>radix,mincol,padchar,groupchar,groupcol</i>R</b></p>
  <p>The next argument <i>arg</i> is expected to be an integer. It will be output with radix
     <i>radix</i>. <i>mincol</i> (default: 0) specifies the minimal "width" of
     the output of the directive in characters with <i>padchar</i> (default: ' ') defining the
     character that is used to pad the output on the left to make it at least <i>mincol</i>
     characters long.</p>
  <p>&nbsp;&nbsp;<tt>clformat("Number: ~10R", args: 1272)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;1272</tt><br />
     &nbsp;&nbsp;<tt>clformat("Number: ~16,8,'0R", args: 7121972)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;006cac34</tt><br />
     &nbsp;&nbsp;<tt>clformat("Number: ~2R", args: 173)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;10101101</tt></p>
  <p>By default, the number is output without grouping separators. <i>groupchar</i> specifies
     which character should be used to separate sequences of <i>groupcol</i> digits in the
     output. Grouping of digits is enabled with the <tt>:</tt> modifier.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~16,8,,':,2:R", args: 7121972)</tt> &DoubleLongRightArrow; <tt>6c:ac:34</tt><br />
     &nbsp;&nbsp;<tt>clformat("~2,14,'0,'.,4:R", args: 773)</tt> &DoubleLongRightArrow; <tt>0011.0000.0101</tt></p>
  <p>A sign is output only if the number is negative. With the modifier <tt>@</tt> it is possible
     to force output also of positive signs.</p>
  <p>If parameter <i>radix</i> is not specified at all, then an entirely different interpretation
     is given. <tt>~R</tt> outputs <i>arg</i> as a cardinal number in natural language. The form
     <tt>~:R</tt> outputs <i>arg</i> as an ordinal number in natural language. <tt>~@R</tt>
     outputs <i>arg</i> as a Roman numeral.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~R", args: 572)</tt> &DoubleLongRightArrow; <tt>five hundred seventy-two</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:R", args: 3)</tt> &DoubleLongRightArrow; <tt>3rd</tt><br />
     &nbsp;&nbsp;<tt>clformat("~@R", args: 1272)</tt> &DoubleLongRightArrow; <tt>MCCLXXII</tt></p>
  <p>Whenever output is provided in natural language, English is used as the language by default.
     By specifying the <tt>+</tt> modifier, it is possible to switch the language to the language
     of the locale provided to function <tt>clformat</tt>.
     In fact, modifier <tt>+</tt> plays two different roles: If the given radix is greater than 10,
     upper case characters are used for representing alphabetic digits. If the radix is omitted, 
     usage of modifier <tt>+</tt> enables locale-specific output determined by the <tt>locale:</tt>
     parameter of function <tt>clformat</tt>.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~+R", locale: Locale(identifier: "de_DE"), args: 572)</tt> <br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>fünf­hundert­zwei­und­siebzig</tt> <br />
     &nbsp;&nbsp;<tt>clformat("~10+R", locale: Locale(identifier: "de_CH"), args: 14321)</tt> <br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>14'321</tt> <br />
     &nbsp;&nbsp;<tt>clformat("~16R vs ~16+R", args: 900939, 900939)</tt> <br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>dbf4b vs DBF4B</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~f</b><br/><b>~F</b></td>
  <td>
  <p>FIXED FLOAT:&nbsp;&nbsp;<b>~<i>w,d,k,overchar,padchar,groupchar,groupcol</i>F</b></p>
  <p>The next argument <i>arg</i> is output as a floating-point number in a fixed format
     (ideally without exponent) of exactly <i>w</i> characters, if <i>w</i> is specified.
     First, leading <i>padchar</i> characters (default: ' ') are output, if necessary, to
     pad the field on the left. If <i>arg</i> is negative, then a minus sign is printed.
     If <i>arg</i> is not negative, then a plus sign is printed if and only if the <tt>@</tt>
     modifier was specified. Then a sequence of digits, containing a single embedded decimal
     point, is printed. This represents the magnitude of the value of <i>arg</i> times
     10<sup><i>k</i></sup>, rounded to <i>d</i> fractional digits. There are no leading
     zeros, except that a single zero digit is output before the decimal point if the
     printed value is less than 1.0, and this single zero digit is not output after all
     if <i>w = d</i> + 1.</p>
  <p>If it is impossible to print the value in the required format in a field of width <i>w</i>,
     then one of two actions is taken: If the parameter <i>overchar</i> is specified, then
     <i>w</i> copies of this character are printed. If <i>overchar</i> is omitted, then the
     scaled value of <i>arg</i> is printed using more than <i>w</i> characters.</p>
  <p>If the width parameter <i>w</i> is omitted, then the output is of variable width and a
     value is chosen for <i>w</i> in such a way that no leading padding characters are needed
     and exactly <i>d</i> characters will follow the decimal point. For example, the directive
     <tt>~,2F</tt> will output exactly two digits after the decimal point and as many as
     necessary before the decimal point.</p>
  <p>If <i>d</i> is omitted, then there is no constraint on the number of digits to appear after
     the decimal point. A value is chosen for <i>d</i> in such a way that as many digits as
     possible may be printed subject to the width constraint imposed by <i>w</i> and the
     constraint that no trailing zero digits may appear in the fraction, except that if the
     fraction is zero, then a single zero digit should appear after the decimal point if
     permitted by the width constraint.</p>
  <p>If <i>w</i> is omitted, then if the magnitude of <i>arg</i> is so large (or, if <i>d</i> is
     also omitted, so small) that more than 100 digits would have to be printed, then <i>arg</i>
     is output using exponential notation instead.</p>
  <p>The <tt>~F</tt> directive also supports grouping of the integer part of <i>arg</i>; this can
     be enabled via the <tt>:</tt> modifier. <i>groupchar</i> (default: ',') specifies which
     character should be used to separate sequences of <i>groupcol</i> (default: 3) digits in
     the integer part of the output. If locale-specific settings should be used, the
     <tt>+</tt> modifier needs to be set.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>123.1415926</tt><br />
     &nbsp;&nbsp;<tt>clformat("~8F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>123.1416</tt><br />
     &nbsp;&nbsp;<tt>clformat("~8,,,'-F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>123.1416</tt><br />
     &nbsp;&nbsp;<tt>clformat("~8,,,'-F", args: 123456789.12)</tt> &DoubleLongRightArrow; <tt>--------</tt><br />
     &nbsp;&nbsp;<tt>clformat("~8,,,,'0F", args: 123.14)</tt> &DoubleLongRightArrow; <tt>00123.14</tt><br />
     &nbsp;&nbsp;<tt>clformat("~8,3,,,'0F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>0123.142</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,4F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>123.1416</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,2@F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>+123.14</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,2,-2@F", args: 314.15926)</tt> &DoubleLongRightArrow; <tt>+3.14</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,2:F", args: 1234567.891)</tt> &DoubleLongRightArrow; <tt>1,234,567.89</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,2,,,,'',3:F", args: 1234567.891)</tt> &DoubleLongRightArrow; <tt>1'234'567.89</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~e</b><br/><b>~E</b></td>
  <td>
  <p>EXPONENTIAL FLOAT:&nbsp;&nbsp;<b>~<i>w,d,e,k,overchar,padchar,expchar</i>E</b></p>
  <p>The next argument <i>arg</i> is output as a floating-point number in an exponential format
     of exactly <i>w</i> characters, if <i>w</i> is specified. Parameter <i>d</i> is the number
     of digits to print after the decimal point, <i>e</i> is the number of digits to use when
     printing the exponent, and <i>k</i> is a scale factor that defaults to 1.</p>
  <p>First, leading <i>padchar</i> (default: ' ') characters are output, if necessary, to pad
     the output on the left. If <i>arg</i> is negative, then a minus sign is printed. If <i>arg</i>
     is not negative, then a plus sign is printed if and only if the <tt>@</tt> modifier was
     specified. Then a sequence of digits, containing a single embedded decimal point, is output.
     The form of this sequence of digits depends on the scale factor <i>k</i>. If <i>k</i> is
     zero, then <i>d</i> digits are printed after the decimal point, and a single zero digit
     appears before the decimal point. If <i>k</i> is positive, then it must be strictly less
     than <i>d</i> + 2 and <i>k</i> significant digits are printed before the decimal point,
     and <i>d − k</i> + 1 digits are printed after the decimal point. If <i>k</i> is negative,
     then it must be strictly greater than <i>−d</i>. A single zero digit appears before the
     decimal point and after the decimal point, first <i>−k</i> zeros are output followed
     by <i>d + k</i> significant digits.</p>
  <p>Following the digit sequence, the exponent is output following character <i>expchar</i>
     (default: 'E') and the sign of the exponent, i.e. either the plus or the minus sign.
     The exponent consists of <i>e</i> digits representing the power of 10 by which the
     fraction must be multiplied to properly represent the rounded value of <i>arg</i>.</p>
  <p>If it is impossible to print the value in the required format in a field of width <i>w</i>,
     then one of two actions is taken: If the parameter <i>overchar</i> is specified, then
     <i>w</i> copies of this character are printed instead of <i>arg</i>. If <i>overchar</i>
     is omitted, then <i>arg</i> is printed using more than <i>w</i> characters, as many more
     as may be needed. If <i>d</i> is too small for the specified <i>k</i> or <i>e</i> is
     too small, then a larger value is used for <i>d</i> or <i>e</i> as may be needed.<p>
  <p>If the <i>w</i> parameter is omitted, then the output is of variable width and a value
     is chosen for <i>w</i> in such a way that no leading padding characters are needed.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~E", args: 31.415926)</tt> &DoubleLongRightArrow; <tt>3.1415926E+1</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,5E", args: 0.0003141592)</tt> &DoubleLongRightArrow; <tt>3.14159E-4</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,4,2E", args: 0.0003141592)</tt> &DoubleLongRightArrow; <tt>3.1416E-04</tt><br />
     &nbsp;&nbsp;<tt>clformat("~9E", args: 31.415926)</tt> &DoubleLongRightArrow; <tt>3.1416E+1</tt><br />
     &nbsp;&nbsp;<tt>clformat("~10,3,,,,'#E", args: 31.415926)</tt> &DoubleLongRightArrow; <tt>##3.142E+1</tt><br />
     &nbsp;&nbsp;<tt>clformat("~10,4,,3,,'#E", args: 31.415926)</tt> &DoubleLongRightArrow; <tt>#314.16E-1</tt><br />
     &nbsp;&nbsp;<tt>clformat("~7,3,2,,'-E", args: 31.415926)</tt> &DoubleLongRightArrow; <tt>-------</tt><br />
     &nbsp;&nbsp;<tt>clformat("~10,4,,4,,'#@E", args: 31.415926)</tt> &DoubleLongRightArrow; <tt>+3141.6E-2</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~g</b><br/><b>~G</b></td>
  <td>
  <p>GENERAL FLOAT:&nbsp;&nbsp;<b>~<i>w,d,e,k,overchar,padchar,expchar</i>G</b></p>
  <p>The next argument <i>arg</i> is output as a floating-point number in either fixed-format or
     exponential notation as appropriate. The format in which to print <i>arg</i> depends on the
     magnitude (absolute value) of <i>arg</i>. Let <i>n</i> be an integer such that 10<sup>n−1</sup>
     &le; <i>arg</i> &lt; 10<sup>n</sup>. If <i>arg</i> is zero, let <i>n</i> be 0. Let <i>ee</i>
     equal <i>e</i> + 2, or 4 if <i>e</i> is omitted. Let <i>ww</i> equal <i>w</i> − <i>ee</i>,
     or nil if <i>w</i> is omitted. If <i>d</i> is omitted, first let <i>q</i> be the number of
     digits needed to print <i>arg</i> with no loss of information and without leading or trailing
     zeros; then let <i>d</i> equal <i>max(q, min(n, 7))</i>. Let <i>dd</i> equal <i>d − n</i>.<p>
  <p>If 0 &le; <i>dd</i> &le; <i>d</i>, then <i>arg</i> is output as if by the format directives:<br />
     &nbsp;&nbsp;&nbsp;&nbsp;<tt>~ww,dd,,overchar,padcharF~ee@T</tt><br />
     Note that the scale factor <i>k</i> is not passed to the <tt>~F</tt> directive. For all other
     values of <i>dd</i>, <i>arg</i> is printed as if by the format directive:<br />
     &nbsp;&nbsp;&nbsp;&nbsp;<tt>~w,d,e,k,overchar,padchar,expcharE</tt><br />
     In either case, an <tt>@</tt> modifier is specified to the <tt>~F</tt> or <tt>~E</tt>
     directive if and only if one was specified to the <tt>~G</tt> directive.</p>
  <p>&nbsp;&nbsp;<tt>clformat("|~G|", args: 712.72)</tt> &DoubleLongRightArrow; <tt>|712.72&nbsp;&nbsp;&nbsp;&nbsp;|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~12G|", args: 712.72)</tt> &DoubleLongRightArrow; <tt>|&nbsp;&nbsp;712.72&nbsp;&nbsp;&nbsp;&nbsp;|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~9,2G|~9,3,2,3G|~9,3,2,0G|", args: 0.031415, 0.031415, 0.031415)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>|&nbsp;&nbsp;3.14E-2|314.2E-04|0.314E-01|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~9,2G|~9,3,2,3G|~9,3,2,0G|", args: 0.314159, 0.314159, 0.314159)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>|&nbsp;0.31&nbsp;&nbsp;&nbsp;&nbsp;|0.314&nbsp;&nbsp;&nbsp;&nbsp;|0.314&nbsp;&nbsp;&nbsp;&nbsp;|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~9,2G|~9,3,2,3G|~9,3,2,0G|", args: 3.14159, 3.14159, 3.14159)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>|&nbsp;&nbsp;3.1&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;3.14&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;3.14&nbsp;&nbsp;&nbsp;&nbsp;|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~9,2G|~9,3,2,3G|~9,3,2,0G|", args: 314.159, 314.159, 314.159)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>|&nbsp;&nbsp;3.14E+2|&nbsp;&nbsp;314&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;314&nbsp;&nbsp;&nbsp;&nbsp;|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~9,2G|~9,3,2,3G|~9,3,2,0G|", args: 3141.59, 3141.59, 3141.59)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>|&nbsp;&nbsp;3.14E+3|314.2E+01|0.314E+04|</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~$</b></td>
  <td>
  <p>DOLLARS FLOAT:&nbsp;&nbsp;<b>~<i>d,n,w,padchar,curchar,groupchar,groupcol</i>$</b></p>
  <p>The next argument <i>arg</i> is output as a floating-point number in a fixed-format notation
     that is particularly well suited for outputting monetary values. Parameter <i>d</i>
     (default: 2) defines the number of digits to print after the decimal point. Parameter
     <i>n</i> (default: 1) defines the minimum number of digits to print before the decimal
     point. Parameter <i>w</i> (default: 0) is the minimum total width of the output.</p>
  <p>First, padding and the sign are output. If <i>arg</i> is negative, then a minus sign is
     printed. If <i>arg</i> is not negative, then a plus sign is printed if and only if the
     <tt>@</tt> modifier was specified. If the <tt>:</tt> modifier is used, the sign appears
     before any padding, and otherwise after the padding. If the number of characters, including
     the sign and a potential currency symbol is below width <i>w</i>, then character
     <i>padchar</i> (default: ' ') is used for padding the number in front of the integer
     part such that the overall output has <i>w</i> characters. After the padding,
     the currency symbol <i>curchar</i> is inserted, if available, followed by <i>n</i>
     digits representing the integer part of <i>arg</i>, prefixed by the right amount
     of '0' characters. If either parameter <i>groupchar</i> or <i>groupcol</i> is provided,
     the integer part is output in groups of <i>groupcol</i> characters (default: 3) separated by
     <i>groupchar</i> (default: ','). After the integer part, a decimal point is output
     followed by <i>d</i> digits of fraction, properly rounded.</p>
  <p>If the magnitude of <i>arg</i> is so large that the integer part of <i>arg</i> cannot be
     output with at most <i>n</i> characters, then more characters are generated, as needed,
     and the total width might overrun as well.</p>
  <p>For cases where a simple currency symbol is not sufficient, it is possible to use a
     numeric currency code as defined by ISO 4217 for parameter <i>curchar</i>. For positive
     codes, the shortest currency symbol is being used. For negative currency codes, the
     corresponding alphabetic code (ignoring the sign) is being used. Struct
     <a href="https://github.com/objecthub/swift-clformat/blob/main/Sources/CLFormat/Currency.swift">Currency</a>
     provides a conventient way to access currency codes.</p>
  <p>By specifying the <tt>+</tt> modifier, it is possible to enable locale-specific output
     of the monetary value using the locale provided to function <tt>clformat</tt>. In this
     case, also the currency associated with this locale is being used.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~$", args: 4930.351)</tt> &DoubleLongRightArrow; <tt>4930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~3$", args: 4930.351)</tt> &DoubleLongRightArrow; <tt>4930.351</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,6$", args: 4930.351)</tt> &DoubleLongRightArrow; <tt>004930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,6,12,'&lowbar;$", args: 4930.351)</tt> &DoubleLongRightArrow; <tt>&lowbar;&lowbar;&lowbar;004930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,6,12,'&lowbar;@$", args: 4930.351)</tt> &DoubleLongRightArrow; <tt>&lowbar;&lowbar;+004930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,6,12,'&lowbar;@:$", args: 4930.351)</tt> &DoubleLongRightArrow; <tt>+&lowbar;&lowbar;004930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,6,12,'&lowbar;,'€$", args: 4930.351)</tt> &DoubleLongRightArrow; <tt>&lowbar;&lowbar;€004930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,6,12,'&lowbar;,'€@$", args: 4930.351)</tt> &DoubleLongRightArrow; <tt>&lowbar;+€004930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,,,,,,3$", args: 4930.351)</tt> &DoubleLongRightArrow; <tt>4,930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,6,,,,,3$", args: 4930.351)</tt> &DoubleLongRightArrow; <tt>004,930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,,,,208$", args: 1234.567)</tt> &DoubleLongRightArrow;
       <tt>kr&nbsp;1234.57</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,,,,-208$", args: 1234.567)</tt> &DoubleLongRightArrow;
       <tt>DKK&nbsp;1234.57</tt><br />
     &nbsp;&nbsp;<tt>clformat("~+$", locale: Locale(identifier: "de_CH"), args: 4930.351)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>CHF&nbsp;4930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,,,,,,3+$", locale: Locale(identifier: "en_US"), args: 4930.351)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>$4,930.35</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,6,14,'&lowbar;,,,3+$", locale: Locale(identifier: "de_DE"), args: 4930.351)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>&lowbar;&lowbar;004.930,35&nbsp;€</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~%</b></td>
  <td>
  <p>NEWLINE:&nbsp;&nbsp;<b>~<i>n</i>%</b></p>
  <p>This directive outputs <i>n</i> (default: 1) newline characters, thereby
     terminating the current output line and beginning a new one. No arguments are being
     consumed. Simply putting <i>n</i> newline escape characters <tt>\n</tt> into the control
     string would also work, but <tt>~%</tt> is often used because it makes the control string
     look nicer and more consistent.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~&</b></td>
  <td>
  <p>FRESHLINE:&nbsp;&nbsp;<b>~<i>n</i>&</b></p>
  <p>Unless it can be determined that the output is already at the beginning of a line,
     this directive outputs a newline if <i>n</i> > 0. This conditional newline is followed
     by <i>n</i> − 1 newlines, it <i>n</i> > 1. Nothing is output if <i>n</i> = 0.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~|</b></td>
  <td>
  <p>PAGE SEPARATOR:&nbsp;&nbsp;<b>~<i>n</i>|</b></p>
  <p>This directive outputs <i>n</i> (default: 1) page separator characters (<tt>"\u{12}"</tt>).</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~&#126;</b></td>
  <td>
  <p>TILDE:&nbsp;&nbsp;<b>~<i>n</i>~</b></p>
  <p>This directive outputs <i>n</i> (default: 1) tilde characters.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~p</b><br/><b>~P</b></td>
  <td>
  <p>PLURAL:&nbsp;&nbsp;<b>~P</b></p>
  <p>Depending on the next argument <i>arg</i>, which is expected to be an integer value, a
     different string is output. If <i>arg</i> is not equal to 1, a lowercase <tt>s</tt> is
     output. If <i>arg</i> is equal to 1, nothing is output.</p>
  <p>If the <tt>:</tt> modifier is provided, the last argument is used instead for <i>arg</i>.
     This is useful after outputting a number using <tt>~D</tt>. With the <tt>@</tt> modifier,
     <tt>y</tt> is output if <i>arg</i> is 1, or <tt>ies</tt> if it is not.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~D tr~:@P/~D win~:P", args: 7, 1)</tt>
       &DoubleLongRightArrow; <tt>7 tries/1 win</tt><br />
     &nbsp;&nbsp;<tt>clformat("~D tr~:@P/~D win~:P", args: 1, 0)</tt>
       &DoubleLongRightArrow; <tt>1 try/0 wins</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~t</b><br/><b>~T</b></td>
  <td>
  <p>TABULATE:&nbsp;&nbsp;<b>~<i>colnum,colinc</i>T</b></p>
  <p>This directive will output sufficient spaces to move the cursor to column <i>colnum</i>
     (default: 1). If the cursor is already at or beyond column <i>colnum</i>, the directive
     will output spaces to move the cursor to column <i>colnum + k &times; colinc</i> for the
     smallest positive integer <i>k</i> possible, unless <i>colinc</i> (default: 1) is zero,
     in which case no spaces are output if the cursor is already at or beyond column
     <i>colnum</i>.</p>
  <p>If modifier <tt>@</tt> is provided, relative tabulation is performed. In this case, the
     directive outputs <tt>colrel</tt> spaces and then outputs the smallest non-negative
     number of additional spaces necessary to move the cursor to a column that is a multiple
     of <i>colinc</i>. For example, the directive <tt>~3,8@T</tt> outputs three spaces and then
     moves the cursor to a "standard multiple-of-eight tab stop" if not at one already. If the
     current output column cannot be determined, however, then <i>colinc</i> is ignored, and
     exactly <i>colrel</i> spaces are output.</p>
  </td>
</tr>
</tbody>
</table>
