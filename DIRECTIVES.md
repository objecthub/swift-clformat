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
<tr valign="top">
  <td><b>~&#42;</b></td>
  <td>
  <p>IGNORE ARGUMENT:&nbsp;&nbsp;<b>~<i>n</i>&#42;</b></p>
  <p>The next <i>n</i> (default: 1) arguments are ignored. If the <tt>:</tt> modifier is provided,
     arguments are "ignored backwards", i.e. <tt>~:&#42;</tt> backs up in the list of arguments
     so that the argument last processed will be processed again. <tt>~n:&#42;</tt> backs up
     <i>n</i> arguments. When within a <tt>~{</tt> construct, the ignoring (in either direction)
     is relative to the list of arguments being processed by the iteration.</p>
  <p>The form <tt>~n@&#42;</tt> is an "absolute goto" rather than a "relative goto": the directive
     goes to the <i>n</i>-th argument, where 0 means the first one. <i>n</i> defaults to 0 for this
     form, so <tt>~@&#42;</tt> goes back to the first argument. Directives after a <tt>~n@&#42;</tt>
     will take arguments in sequence beginning with the one gone to. When within a <tt>~{</tt>
     construct, the "goto" is relative to the list of arguments being processed by the
     iteration.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~?</b></td>
  <td>
  <p>INDIRECTION:&nbsp;&nbsp;<b>~?</b></p>
  <p>The next argument <i>arg</i> must be a string, and the one after it <i>lst</i> must be
     a sequence (e.g. an array). Both arguments are consumed by the directive. <i>arg</i>
     is processed as a format control string, with the elements of the list <i>lst</i> as the
     arguments. Once the recursive processing of the control string has been finished, then
     processing of the control string containing the <tt>~?</tt> directive is resumed.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~? ~D", args: "(~A ~D)", ["Foo", 5], 7)</tt>
       &DoubleLongRightArrow; <tt>(Foo 5) 7</tt><br />
     &nbsp;&nbsp;<tt>clformat("~? ~D", args: "(~A ~D)", ["Foo", 5, 14], 7)</tt>
       &DoubleLongRightArrow; <tt>(Foo 5) 7</tt></p>
  <p>Note that in the second example, three arguments are supplied to the control string
    <tt>"(~A ~D)"</tt>, but only two are processed and the third is therefore ignored.</p>
  <p>With the <tt>@</tt> modifier, only one argument is directly consumed. The argument must
     be a string. It is processed as part of the control string as if it had appeared in place
     of the <tt>~@?</tt> directive, and any directives in the recursively processed control
     string may consume arguments of the control string containing the <tt>~@?</tt> directive.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~@? ~D", args: "(~A ~D)", "Foo", 5, 7)</tt>
       &DoubleLongRightArrow; <tt>(Foo 5) 7</tt><br />
     &nbsp;&nbsp;<tt>clformat("~@? ~D", args: "(~A ~D)", "Foo", 5, 14, 7)</tt>
       &DoubleLongRightArrow; <tt>(Foo 5) 14</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~(&mldr;~)</b></td>
  <td>
  <p>CONVERSION:&nbsp;&nbsp;<b>~(<i>str</i>~)</b></p>
  <p>The contained control string <i>str</i> is processed, and what it produces is subject to
     a conversion. Without the <tt>+</tt> modifier, a <i>case conversion</i> is performed.
     <tt>~(</tt> converts every uppercase character to the corresponding lowercase character,
     <tt>~:(</tt> capitalizes all words, <tt>~@(</tt> capitalizes just the first word and
    forces the rest to lowercase, and <tt>~:@(</tt> converts every lowercase character to the
    corresponding uppercase character. In the following example, <tt>~@(</tt> is used to cause
    the first word produced by <tt>~R</tt> to be capitalized:</p>
  <p>&nbsp;&nbsp;<tt>clformat("~@(~R~) error~:P", args: 0)</tt>
       &DoubleLongRightArrow; <tt>Zero errors</tt><br />
     &nbsp;&nbsp;<tt>clformat("~@(~R~) error~:P", args: 1)</tt>
       &DoubleLongRightArrow; <tt>One error</tt><br />
     &nbsp;&nbsp;<tt>clformat("~@(~R~) error~:P", args: 23)</tt>
       &DoubleLongRightArrow; <tt>Twenty-three errors</tt></p>
  <p>If the <tt>+</tt> modifier is provided together with the <tt>:</tt> modifier,
     all characters corresponding to named XML entities are being converted into
     names XML entities. If modifier <tt>@</tt> is added, then only those characters
     are converted which conflict with XML syntax. The modifier combination <tt>+@</tt>
     converts the output by stripping off all diacritics. Modifier <tt>+</tt> only will
     escape characters such that the result can be used as a Swift string literal.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~+:(~A~)", args: "© 2021–2023 TÜV")</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>&amp;copy; 2021&amp;ndash;2023 T&amp;Uuml;V</tt><br />
     &nbsp;&nbsp;<tt>clformat("~+:@(~A~)", "&lt;a href=&quot;t.html&quot;&gt;© TÜV&lt;/a&gt;")</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>&amp;lt;a href=&amp;quot;t.html&amp;quot;&amp;gt;© TÜV&amp;lt;/a&amp;gt;</tt><br />
     &nbsp;&nbsp;<tt>clformat("~+@(~A~)", "épistèmê")</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>episteme</tt><br />
     &nbsp;&nbsp;<tt>clformat("~+(~A~)", "Hello \"World\"\n")</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>Hello \"World\"\n</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~&#91;&mldr;~&#93;</b></td>
  <td>
  <p>CONDITIONAL:&nbsp;&nbsp;<b>~&#91;<i>str<sub>0</sub></i>~;<i>str<sub>1</sub></i>~;&mldr;~;<i>str<sub>n</sub></i>~&#93;</b></p>
  <p>This is a set of control strings, called clauses, one of which is chosen and used. The
     clauses are separated by <tt>~;</tt> and the construct is terminated by <tt>~]</tt>.</p>
  <p><i>Without default:</i>&nbsp; From a conditional directive ~&#91;<i>str<sub>0</sub></i>~;<i>str<sub>1</sub></i>~;&mldr;~;<i>str<sub>n</sub></i>~&#93;,
     the <i>arg</i>-th clause is selected,
     where the first clause is number 0. If a prefix parameter is given as <tt>~n&#91;</tt>,
     then the parameter <i>n</i> is used instead of an argument. This is useful only if the
     parameter is specified by <tt>#</tt>, to dispatch on the number of arguments remaining
     to be processed. If <i>arg</i> or <i>n</i> is out of range, then no clause is selected
     and no error is signaled. After the selected alternative has been processed, the control
     string continues after the <tt>~&#93;</tt>.</p>
  <p><i>With default:</i>&nbsp; Whenever the directive has the form
     ~&#91;<i>str<sub>0</sub></i>~;<i>str<sub>1</sub></i>~;&mldr;~:;<i>default</i>~&#93;, i.e.
     the last clause is separated via <tt>~:;</tt>, then the conditional directive has a
     default clause which gets performed whenever no other clause could be selected.</p>
  <p><i>Optional selector:</i>&nbsp; Whenever the directive has the form
     ~:&#91;<i>none</i>~;<i>some</i>~&#93; the <i>none</i> control string is chosen if
     <i>arg</i> is <tt>nil</tt>, otherwise the <i>some</i> control string is chosen.</p>
  <p><i>Boolean selector:</i>&nbsp; Whenever the directive has the form
     ~+&#91;<i>false</i>~;<i>true</i>~&#93; the <i>false</i> control string is chosen if
     <i>arg</i> is the boolean value <tt>false</tt>, otherwise the <i>some</i> control
     string is chosen.</p>
  <p><i>Selector test:</i>&nbsp; Whenever the directive has the form
     ~@&#91;<i>true</i>~&#93;, the next argument <i>arg</i> is tested for being
     non-<tt>nil</tt>. If <i>arg</i> is not <tt>nil</tt>, then the argument is not used up
     by the <tt>~@&#91;</tt> directive but remains as the next one to be processed, and the one
     clause <i>true</i> is processed. If <i>arg</i> is <tt>nil</tt>, then the argument is
     used up, and the clause is not processed. The clause therefore should normally use
     exactly one argument, and may expect it to be non-<tt>nil</tt>.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~{&mldr;~}</b></td>
  <td>
  <p>ITERATION:&nbsp;&nbsp;<b>~<i>n</i>{<i>str</i>~}</b></p>
  <p>The iteration directive is used to control how a sequence is output. Thus, the next
     argument <i>arg</i> should be a sequence which is used as a list of arguments as if for
     a recursive call to <tt>clformat</tt>. The string <i>str</i> is used repeatedly as
     the control string until all elements from <i>arg</i> are consumed. Each iteration
     can absorb as many elements of <i>arg</i> as it needs. For instance, if <i>str</i>
     uses up two arguments by itself, then two elements of <i>arg</i> will get used up
     each time around the loop. If before any iteration step the sequence is empty, then the
     iteration is terminated. Also, if a prefix parameter <i>n</i> is given, then there
     will be at most <i>n</i> repetitions of processing of <i>str</i>. Finally, the
     <tt>~^</tt> directive can be used to terminate the iteration prematurely. If the
     iteration is terminated before all the remaining arguments are consumed, then any
     arguments not processed by the iteration remain to be processed by any directives following
     the iteration construct.</p>
  <p>&nbsp;&nbsp;<tt>clformat("Winners:~{ ~A~}.", args: ["Fred", "Harry", "Jill"])</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>Winners: Fred Harry Jill.</tt><br />
     &nbsp;&nbsp;<tt>clformat("Winners: ~{~#[~;~A~:;~A, ~]~}.", args: ["Fred", "Harry", "Jill"])</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>Winners: Fred, Harry, Jill.</tt><br />
     &nbsp;&nbsp;<tt>clformat("Pairs:~{ &lt;~A,~S&gt;~}.", args: ["A", 1, "B", 2, "C", 3])</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>Pairs: &lt;A, 1&gt; &lt;B, 2&gt; &lt;C, 3&gt;.</tt></p>
  <p><tt>~:<i>n,m</i>{<i>str</i>~}</tt> is similar, but the argument should be a list of sublists.
     At each repetition step (capped by <i>n</i>), one sublist is used as the list of arguments
     for processing <i>str</i> with an iteration cap of <i>m</i>. On the next repetition, a new
     sublist is used, whether or not all elements of the last sublist had been processed.<p>
  <p>&nbsp;&nbsp;<tt>clformat("Pairs:~:{ &lt;~A,~S&gt;~}.", args: [["A", 1], ["B", 2], ["C", 3]])</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>Pairs: &lt;A, 1&gt; &lt;B, 2&gt; &lt;C, 3&gt;.</tt></p>
  <p><tt>~@{<i>str</i>~}</tt> is similar to <tt>~{<i>str</i>~}</tt>, but instead of using
     one argument that is a sequence, all the remaining arguments are used as the list
     of arguments for the iteration.</p>
  <p>&nbsp;&nbsp;<tt>clformat("Pairs:~@{ &lt;~A,~S&gt;~}.", args: "A", 1, "B", 2, "C", 3)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>Pairs: &lt;A, 1&gt; &lt;B, 2&gt; &lt;C, 3&gt;.</tt></p>
  <p><tt>~:@{<i>str</i>~}</tt> combines the features of <tt>~:{<i>str</i>~}</tt> and
     <tt>~@{<i>str</i>~}</tt>. All the remaining arguments are used, and each one must be a
     sequence. On each iteration, the next argument is used as a list of arguments to <i>str</i>.</p>
  <p>&nbsp;&nbsp;<tt>clformat("Pairs:~:@{ &lt;~A,~S&gt;~}.", args: ["A", 1], ["B", 2], ["C", 3])</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>Pairs: &lt;A, 1&gt; &lt;B, 2&gt; &lt;C, 3&gt;.</tt></p>
  <p>Terminating the repetition directive with <tt>~:}</tt> instead of <tt>~}</tt> forces
     <i>str</i> to be processed at least once, even if the initial sequence is empty. However,
     it will not override an explicit prefix parameter of zero. If <i>str</i> is empty, then an
     argument is used as <i>str</i>. It must be a string and precede any arguments
     processed by the iteration.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~&lt;&mldr;~&gt;</b></td>
  <td>
  <p>JUSTIFICATION:&nbsp;&nbsp;
     <b>~<i>mincol,colinc,minpad,padchar,maxcol,elchar</i>&lt;<i>str</i>~&gt;</b></p>
  <p>This directive justifies the text produced by processing control string <i>str</i> within
     a field which is at least <i>mincol</i> columns wide (default: 0). <i>str</i> may be
     divided up into segments via directive <tt>~;</tt>, in which case the spacing is evenly
     divided between the text segments.</p>
  <p>With no modifiers, the leftmost text segment is left-justified in the field and the
     rightmost text segment is right-justified. If there is only one text element, it is
     right-justified. The <tt>:</tt> modifier causes spacing to be introduced before the
     first text segment. The <tt>@</tt> modifier causes spacing to be added after the last
     text segment. The <i>minpad</i> parameter (default: 0) is the minimum number of padding
     characters to be output between each segment. Whenever padding is needed, the padding
     character <i>padchar</i> (default: ' ') is used. If the total width needed to satisfy the
     constraints is greater than <i>mincol</i>, then the width used is
     <i>mincol + k &times; colinc</i> for the smallest possible non-negative integer <i>k</i>
     with <i>colinc</i> defaulting to 1.</p>
  <p>&nbsp;&nbsp;<tt>clformat("|~10,,,'.&lt;foo~;bar~&gt;|")</tt>
       &DoubleLongRightArrow; <tt>|foo....bar|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~10,,,'.:&lt;foo~;bar~&gt;|")</tt>
       &DoubleLongRightArrow; <tt>|..foo..bar|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~10,,,'.:@&lt;foo~;bar~&gt;|")</tt>
       &DoubleLongRightArrow; <tt>|..foo.bar.|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~10,,,'.&lt;foobar~&gt;|")</tt>
       &DoubleLongRightArrow; <tt>|....foobar|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~10,,,'.:&lt;foobar~&gt;|")</tt>
       &DoubleLongRightArrow; <tt>|....foobar|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~10,,,'.@&lt;foobar~&gt;|")</tt>
       &DoubleLongRightArrow; <tt>|foobar....|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~10,,,'.:@&lt;foobar~&gt;|")</tt>
       &DoubleLongRightArrow; <tt>|..foobar..|</tt></p>
  <p>Note that <i>str</i> may include format directives. All the clauses in <i>str</i> are
     processed in order. It is the resulting pieces of text that are justified. The <tt>~^</tt>
     directive may be used to terminate processing of the clauses prematurely, in which case
     only the completely processed clauses are justified.</p>
  <p>If the first clause of a <tt>~&lt;</tt> directive is terminated with <tt>~:;</tt> instead
     of <tt>~;</tt>, then it is used in a special way. All of the clauses are processed, but
     the first one is not used in performing the spacing and padding. When the padded result
     has been determined, then, if it fits on the current line of output, it is output, and
     the text for the first clause is discarded. If, however, the padded text does not fit
     on the current line, then the text segment for the first clause is output before the
     padded text. The first clause ought to contain a newline (such as a <tt>~%</tt> directive).
     The first clause is always processed, and so any arguments it refers to will be used.
     The decision is whether to use the resulting segment of text, not whether to process the
     first clause. If the <tt>~:;</tt> has a prefix parameter <i>n</i>, then the padded text
     must fit on the current line with <i>n</i> character positions to spare to avoid
     outputting the first clause’s text.</p>
  <p>For example, the control string in the following example can be used to print a list
     of items separated by comma without breaking items over line boundaries, beginning
     each line with <tt>;;</tt>. The prefix parameter 1 in <tt>~1:;</tt> accounts for the width
     of the comma that will follow the justified item if it is not the last element in the list,
     or the period if it is. If <tt>~:;</tt> has a second prefix parameter, like below, then it
     is used as the width of the line, overriding the line width as specified by
     <tt>clformat</tt>'s <tt>linewidth:</tt> parameter (default: 80).</p>
  <p>&nbsp;&nbsp;<tt>clformat("~%;; ~{~&lt;~%;; ~1,30:; ~S~&gt;~^,~}.~%",</tt><br />
     &nbsp;&nbsp;<tt>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;args: ["first line", "second", "a long third line",</tt><br />
     &nbsp;&nbsp;<tt>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"fourth", "fifth"])</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow;&nbsp;<tt> </tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<tt>;;  "first line", "second",</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<tt>;;  "a long third line",</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<tt>;;  "fourth", "fifth".</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<tt> </tt></p>
  <p>If there is only one text segment <i>str</i> and parameter <i>maxcol</i> is provided and
     the length of the output of <i>str</i> is exceeding <i>maxcol</i>, then the output is
     truncated at width <i>maxcol - 1</i> and the ellipsis character <i>elchar</i>
     (default: '&hellip;') is inserted at the end.<p>
  </td>
</tr>
<tr valign="top">
  <td><b>~^</b></td>
  <td>
  <p>UP AND OUT:&nbsp;&nbsp;<b>~^</b></p>
  <p><i>Continue:</i>&nbsp; The <tt>~^</tt> directive is an escape construct. If there are no more
     arguments remaining to be processed, then the immediately enclosing <tt>~{</tt> or
     <tt>~&lt;</tt> directive is terminated. If there is no such enclosing directive, then
     the entire formatting operation is terminated. In the case of <tt>~&lt;</tt>, the
     formatting is performed, but no more segments are processed before doing the justification.
     The <tt>~^</tt> directive should appear only at the beginning of a <tt>~&lt;</tt> clause,
     because it aborts the entire clause it appears in, as well as all following clauses.
     <tt>~^</tt> may appear anywhere in a <tt>~{</tt> construct.</p>
  <p>&nbsp;&nbsp;<tt>clformat("Done.~^ ~D warning~:P.~^ ~D error~:P.")</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>Done.</tt><br />
     &nbsp;&nbsp;<tt>clformat("Done.~^ ~D warning~:P.~^ ~D error~:P.", args: 3)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>Done. 3 warnings.</tt><br />
     &nbsp;&nbsp;<tt>clformat("Done.~^ ~D warning~:P.~^ ~D error~:P.", args: 1, 5)</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>Done. 1 warning. 5 errors.</tt></p>
  <p>If the directive has the form <tt>~<i>n</i>^</tt>, then termination occurs if <i>n</i>
     is zero. If the directive has the form <tt>~<i>n,m</i>^</tt>, termination occurs if the
     value of <i>n</i> equals the value of <i>m</i>. If the directive has the form
     <tt>~<i>n,m,o</i>^</tt>, termination occurs if <i>n</i> &le; <i>m</i> &le; <i>o</i>.
     Of course, this is useless if all the prefix parameters are literals. At least one of
     them should be a <tt>#</tt> or a <tt>v</tt> parameter.</p>
  <p><i>Break:</i>&nbsp; If <tt>~^</tt> is used within a <tt>~:{</tt> directive, then it merely
     terminates the current iteration step because in the standard case, it tests for
     remaining arguments of the current step only and the next iteration step commences
     immediately. To terminate the entire iteration process, use <tt>~:^</tt>.
     <tt>~:^</tt> may only be used if the directive it would terminate is <tt>~:{</tt> or
     <tt>~:@{</tt>. The entire iteration process is terminated if and only if the sublist
     that is supplying the arguments for the current iteration step is the last sublist (in
     the case of terminating a <tt>~:{</tt> directive) or the last argument to that call to
     format (in the case of terminating a <tt>~:@{</tt> directive).</p>
  <p>Note that while <tt>~^</tt> is equivalent to <tt>~#^</tt> in all circumstances,
     <tt>~:^</tt> is not equivalent to <tt>~#:^</tt> because the latter terminates the entire
     iteration if and only if no arguments remain for the current iteration step, as opposed
     to no arguments remaining for the entire iteration process.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~:{/~A~^ &mldr;~}",</tt><br />
     &nbsp;&nbsp;<tt>&nbsp;&nbsp;args: [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]])</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>/hot &mldr;/hamburger/ice &mldr;/french &mldr;</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:{/~A~:^ &mldr;~}",</tt><br />
     &nbsp;&nbsp;<tt>&nbsp;&nbsp;args: [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]])</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>/hot &mldr;/hamburger &mldr;/ice &mldr;/french</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:{/~A~#:^ &mldr;~}",</tt><br />
     &nbsp;&nbsp;<tt>&nbsp;&nbsp;args: [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]])</tt><br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>/hot &mldr;/hamburger</tt></p>
  </td>
</tr>
</tbody>
</table>
