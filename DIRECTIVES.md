#  CLFormat Directives

<table>
<thead>
  <tr><th>Directive</th><th>Explanation</th></tr>
</thead>
<tbody>
<tr valign="top">
  <td><b>~a</b><br/><b>~A</b></td>
  <td>
  <p><i>ASCII:</i>&nbsp;&nbsp;<b>~<i>mincol,colinc,minpad,padchar,maxcol,elchar</i>A</b></p>
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
  <p><i>WRITE:</i>&nbsp;&nbsp;<b>~<i>mincol,colinc,minpad,padchar,maxcol,elchar</i>W</b></p>
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
  <p><i>SOURCE:</i>&nbsp;&nbsp;<b>~<i>mincol,colinc,minpad,padchar,maxcol,elchar</i>S</b></p>
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
  <p><i>CHARACTER:</i>&nbsp;&nbsp;<b>~C</b></p>
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
  <p><i>DECIMAL:</i>&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>D</b></p>
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
  <p><i>BINARY:</i>&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>B</b></p>
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
  <p><i>OCTAL:</i>&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>O</b></p>
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
  <p><i>HEXADECIMAL:</i>&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>X</b></p>
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
  <p><i>RADIX:</i>&nbsp;&nbsp;<b>~<i>radix,mincol,padchar,groupchar,groupcol</i>R</b></p>
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
  <p><i>FIXED-FORMAT FLOAT:</i>&nbsp;&nbsp;<b>~<i>w,d,k,overchar,padchar,groupchar,groupcol</i>F</b></p>
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
  <p>If <i>w is omitted, then if the magnitude of <i>arg</i> is so large (or, if <i>d</i> is
     also omitted, so small) that more than 100 digits would have to be printed, then <i>arg</i>
     is output using exponential notation instead.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>123.1415926</tt><br />
     &nbsp;&nbsp;<tt>clformat("~8F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>123.1416</tt><br />
     &nbsp;&nbsp;<tt>clformat("~8,,,'-F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>123.1416</tt><br />
     &nbsp;&nbsp;<tt>clformat("~8,,,'-F", args: 123456789.12)</tt> &DoubleLongRightArrow; <tt>--------</tt><br />
     &nbsp;&nbsp;<tt>clformat("~8,,,,'0F", args: 123.14)</tt> &DoubleLongRightArrow; <tt>00123.14</tt><br />
     &nbsp;&nbsp;<tt>clformat("~8,3,,,'0F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>0123.142</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,4F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>123.1416</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,2@F", args: 123.1415926)</tt> &DoubleLongRightArrow; <tt>+123.14</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,2,-2@F", args: 314.15926)</tt> &DoubleLongRightArrow; <tt>+3.14</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,2,-2@F", args: 314.15926)</tt> &DoubleLongRightArrow; <tt>+3.14</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,2:F", args: 1234567.891)</tt> &DoubleLongRightArrow; <tt>1,234,567.89</tt><br />
     &nbsp;&nbsp;<tt>clformat("~,2,,,,'',3:F", args: 1234567.891)</tt> &DoubleLongRightArrow; <tt>1'234'567.89</tt><br />
  </td>
</tr>
</tbody>
</table>