Type
   RW_toKEN = Record
      token_str :String[9];
      token_cod :toKEN_CODE;
   end;

   RW_Type = Array[0..9] of RW_toKEN;
   RWT_PTR = ^RW_Type;

Const
   NULL = '';

   Rw_2  :RW_Type = ((token_str : 'do'; token_cod : tdo),
                     (token_str : 'if'; token_cod : tif),
                     (token_str : 'in'; token_cod : tin),
                     (token_str : 'of'; token_cod : tof),
                     (token_str : 'or'; token_cod : tor),
                     (token_str : 'to'; token_cod : tto),
                     (token_str : NULL; token_cod : NO_toKEN),
                     (token_str : NULL; token_cod : NO_toKEN),
                     (token_str : NULL; token_cod : NO_toKEN),
                     (token_str : NULL; token_cod : NO_toKEN)
                    );

    ...the difference being the explicit declaration of the Constant
    Record fields. (I'm used to Array Constants, not Record
    Constants - I was unaware of the requirement)

    PARSinG NUMBERS

    Now we'll concentrate on parsing Integer and Real numbers.

    The Pascal definition of a number begins With an UNSIGNED
    Integer. An unsigned Integer consists of one or more consecutive
    DIGITS. The simplest Form of a number token is an unsigned
    Integer:

    1 9 120 12654

    A number token can also be an unsigned Integer (the whole part)
    followed by a fraction part. A fraction part consists of a
    decimal point followed by an unsigned Integer, such as:

    123.45 0.9987564

    These numbers have whole parts 123 and 0 respectively, and
    fraction parts .45 and .9987564 respectively.

    A number token can also be a whole part followed by an EXPONENT
    part. An exponent part consists of an "E" (or "e") followed by
    an unsigned Integer. An optional exponent sign, + or -, can
    appear between the letter and the first exponent digit.
    Examples:

    134e2  2E99 123e-45 73623E+4

    Finally, a number token can be a whole part followed by a
    fraction part and an exponent part, in that order:

    2.3498E7 0.00034e-66

    I arbitrarily limit the number of digits to 20, and the exponent
    value from -37 to +37 - the exact value necessary to limit this
    value is dependant on how Real values are represented on the
    Computer.

    The "get_number" Function is likely to be the biggest Function
    in your scanner, but it should be relatively straighForward to
    code...in light of what has already been done With the scanner/
    tokenizer module, and the definition of a number.

    EXERCISE #1

    Write the get_number Function to parse Integers and Real
    numbers.

    You will need to add the following Types and Variables to your
    global data segment:

    Type  { add "Real"s to list... }

    LITERAL_Type = (Integer_LIT, Real_LIT, String_LIT);

    LITERAL_REC = Record
       Case lType:LITERAL_Type of
          Integer_LIT: (ivalue :Integer);
          Real_LIT   : (rvalue :Real   );
          String_LIT : (svalue :String );
    end;

    Var

    digit_count :Word;
    count_error :Boolean;

--------------     PART 2     ---------------------------------------

    The rest of this post will cover two simple topics - parsing
    Strings inside quotes, and parsing comments.

    PARSinG COMMENTS {}

    The Compiler should ignore the input between two curly braces
    ({}), and the curly braces themselves. My scanner is written so
    the entire comment is replace by a Single blank (" "), although
    you could possibly Write the scanner so that comments are
    _totally_ ignored.

    EXERCISE #2:

    Integrate COMMENT detection into the get_Char routine, so that
    when your Character fetching routine will ignore comments and
    pass a blank when a comment is encountered, skipping the comment
    entirely For the next fetch.

    Make sure that the routine keeps reading Until the right curly
    brace is detected, even past the end-of-line. if the end-of-File
    is encountered beFore the right curly brace is found, an
    "unexpected end" error should be generated.

    PARSinG StringS (QUOTES) ''

    The quote Character delimits Strings, any Character between the
    Strings is ignored by the Compiler, except to stored as a String
    LITERAL. if you wish a ' (quote) to be included in the literal,
    and extra ' must precede it.

    One possible tricky area is the {} (comment) Character. You must
    be careful not to inadvertently trigger the comment routine within
    the quote routine While reading a String, otherwise you will
    have a BUG.

    EXERCISE #3:

    Add a quote routine to the get_token routine within your module,
    to fetch Strings, as a LITERAL IDENTifIER when the QUOTE
    Character is detected.

    The following mods to your Types are required:

    Eof_Char = #$7F;

Type
  Char_CODE  = (LETTER, DIGIT, QUOTE, SPECIAL, Eof_CODE);

 {  The following code init's the Character maping table:  }

Var
   ch :Byte;
begin
   For ch := 0 to 255 do
      Char_table[ch] := SPECIAL;
   For ch := ord('0') to ord('9') do
      Char_table[ch] := DIGIT;

   For ch := ord('A') to ord('Z') do
      Char_table[ch] := LETTER;
   For ch := ord('a') to ord('z') do
      Char_table[ch] := LETTER;

   Char_table[ord(Eof_Char)] := Eof_CODE;

   Char_table[39] := QUOTE;
end;

    ----------------------------------------------------------------

    PLEASE, please let me know what you think about these posts,
    even if they're negative - I want to have some feedback on the
    difficulties, and whether or not people are having trouble
    following the material - I _can_ be more concise at the cost of
    being more verbose - if it's needed!

    if you are having problems With your source code, and want me to
    do a detailed examination of your code, expecially if it's
    written in a language other than Pascal, send me email via the
    Internet - to avoid "carpet bombing" the conference with
    undesired material.


    NEXT POST:

    Error codes, and putting your code to the test - our first
    utility (other than the lister) : a source Program Compactor
    (not cruncher).

    FUTURE POSTS:

    - Review and (hopefully) a status report from "students"
    - Symbol table
    - YA utility (cross - referencer)
    - YA utility (source Program CRUNCHer)
    - YA utility (source Program UNcruncher)
    - Parsing simple expressions
    - Utility : CALC, using infix-to-postfix conversions and stack
      ops.
    - Parsing statements
    - Utility: Pascal syntax checker part I
    - Parsing declarations (Var, Type, etc)
      incl's: much improved (and much more Complex) symbol table
    - Utility: Declarations analyzer.
    - Syntax Checker part II
    - Parsing Program, Procedure, and Function declarations
      (routines).
    - Syntax checker Part III

    - Review and discussion?
