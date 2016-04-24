(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0088.PAS
  Description: Positive or negative integer into binary
  Author: JAMES LO
  Date: 01-02-98  07:34
*)

PROGRAM DECBINCNV;

USES crt;

{//////////////////////////////////////////////////////////////////////////////
  AUTHOR    : Lo Ching Chin James (950208778)
  COURSE    : CIS101 - Introduction to Computer and Computer Programming
  ASSIGN    : CW3A.PAS
  DATE      : 20 Nov 1997
  COPYRIGHT : JAMES LO NOVEMBER 1997, HONG KONG

  This program provides function to :

  1. Convert a positive or negative integer into binary string.
  2. Convert a binary string into a positive or negative integer.
  3. Convert a real number to binary string.
  4. Convert a binary string to real number.

  Input :

  User select appropriate options and input data such as no. of bytes, binary
  strings or integers to perform conversion.

  Output :

  Systems will display the results depending on what task has been performed.

///////////////////////////////////////////////////////////////////////////////}


CONST

    i_LowLimit       = 1;  { Define the lower limit of choice value }
    i_HighLimit      = 5;  { Define the higher limit of the choice value }
    i_1Byte          = 1;  { Define the value for 1 byte }
    i_2Byte          = 2;  { Define the value for 2 bytes }
    i_NoOfBit        = 8;  { Define the number of bits per byte }
    i_Base2          = 2;  { Define base 2 value }
    i_8ExpStartBit   = 2;  { Define the starting bit of exponent real num 8 bit }
    i_8ExpEndBit     = 4;  { Define the ending bit of exponent real num 8 bit }
    i_8ManStartBit   = 5;  { Define the starting bit mantissa of real num 8 bit }
    i_8ManEndBit     = 8;  { Define the ending bit mantissa of real num 8 bit }
    i_16ExpStartBit  = 2;  { Define the starting bit exponent of real num 16 bit }
    i_16ExpEndBit    = 6;  { Define the ending bit exponent of real num 16 bit }
    i_16ManStartBit  = 7;  { Define the starting bit mantissa of real num 16 bit }
    i_16ManEndBit    = 16; { Define the ending bit mantissa of real num 16 bit }
    i_8BitExpInd     = 4;  { Define the 8 bit indicator }
    i_16BitExpInd    = 16; { Define the 16 bit indicator }
    r_8posbinary     = 7.5;  {Define real number limit for 8 bit}
    r_16posbinary    = 32736.0; {Define real number limit for 16 bit}
    i_MultipleOfByte = 2;    {Define the mutiple of bits per byte}
    s_ZeroString     = '0';  {Define '0' string}
    s_OneString      = '1';  {Define '1' string}
    i_OKIOResult     = 0;    {Define good I/O result}
    s_Space          = ' ';  {Define space value}
    r_OneHalf        = 0.5;  {Define one half value}
    i_NegativeOne    = -1;
    i_PositiveOne    =  1;

TYPE

    bit_string       = ARRAY[1..i_NoOfBit * i_MultipleOfByte] OF Char;

VAR

    s_Response     : char;       {Define a char for response}
    i_Choice       : integer;    {Define choice variable}
    i_Byte,i_Bit   : integer;    {Define byte and bit variable}
    i_integer      : Longint;    {Define variable for integer input}
    r_RealNum      : Real;       {Define variable for real number input }
    s_string       : bit_string; {Define variable for converted string}
    s_dummy        : char;       {Define dummy variable for enter key}
    i_LowRange,
    i_HighRange    : LONGINT;    {Define variable for hi and low integers}
    r_LowRange,
    r_HighRange    : REAL;       {Define variable for hi and low real number}


{////////////////////////////////////////////////////////////////////////////
 TRIM() - this function trims trailing space.
////////////////////////////////////////////////////////////////////////////}
FUNCTION TRIM(inStr:STRING):STRING;

BEGIN

    WHILE (inStr[LENGTH (inStr)] = ' ') DO
        inStr := COPY (inStr, 1, LENGTH (inStr ) - 1);
    WHILE (inStr[1] = ' ') DO
          DELETE (inStr, 1, 1);
    TRIM := inStr

END; {TRIM}


{/////////////////////////////////////////////////////////////////////////////
 Press any key to continue procedure
/////////////////////////////////////////////////////////////////////////////}
PROCEDURE PRESSKEY;

BEGIN

    WRITE('Press any key to continue ...');

END;


{/////////////////////////////////////////////////////////////////////////////
 Raise X to power Y
/////////////////////////////////////////////////////////////////////////////}
FUNCTION RAISEPOWER(base,exponent:INTEGER): LONGINT;

VAR

     i_temp, i : LONGINT;

BEGIN

     i_temp := 1;

     FOR i := 1 TO exponent DO
         i_temp := i_temp * i_base2;

     RAISEPOWER := i_temp;

END; {RAISEPOWER}


{////////////////////////////////////////////////////////////////////////////
 Print bit string to screen
////////////////////////////////////////////////////////////////////////////}
PROCEDURE BIT_STRING_PRINT(VAR b:bit_string; nbit:INTEGER);

VAR

     i    : INTEGER;

BEGIN

     FOR i := 1 TO nbit DO
         WRITE (b[i]);

END; {BIT_STRING_PRINT}


{////////////////////////////////////////////////////////////////////////////
 Set bit value of '0' or '1' based on passed parameter value
////////////////////////////////////////////////////////////////////////////}
PROCEDURE BIT_STRING_SETBIT(VAR b:bit_string; nth:INTEGER; value:INTEGER);

VAR

     s  : STRING[1];

BEGIN

     STR(value,s);
     b[nth] := s[1];

END; {BIT_STRING_SETBIT}


{////////////////////////////////////////////////////////////////////////////
 Fill in '0's to the trailing space
////////////////////////////////////////////////////////////////////////////}
PROCEDURE BIT_STRING_ZERO(VAR b:bit_string; i_frvalue:INTEGER; i_tovalue: INTEGER);

VAR

     i : integer;

BEGIN

      FOR i := i_frvalue TO i_tovalue DO
           b[i] := s_ZeroString;

END; {BIT_STRING_ZERO}


{////////////////////////////////////////////////////////////////////////////
 Reverse bit string order e.g. '00100000' --> '00000100'
////////////////////////////////////////////////////////////////////////////}
PROCEDURE BIT_STRING_REVERSE(VAR b:bit_string; value:INTEGER);

VAR

    i,j        : INTEGER;
    tmp_string : bit_string;

BEGIN

     j := 0;
     FOR i := value DOWNTO 1 DO   { Reverse the order }
         BEGIN
            INC(j);
            tmp_string[j] := b[i];
         END;

     FOR i := 1 TO value DO       { Move from temp array to actual array }
         BEGIN
            b[i] := tmp_string[i];
         END;

END; {BIT_STRING_REVERSE}


{////////////////////////////////////////////////////////////////////////////
 2's complement routine e.g. '00100000' --> '11100000'
////////////////////////////////////////////////////////////////////////////}
PROCEDURE BIT_STRING_2COM(VAR b:bit_string; nbit:INTEGER);

VAR

    b_finish   : boolean;
    j, i       : INTEGER;

BEGIN

      FOR i := nbit DOWNTO 1 DO  { Reverse the bit '0' to '1' or vice versa }
          IF b[i] = s_ZeroString THEN
             b[i] := SUCC(b[i])
          ELSE
             b[i] := PRED(b[i]);

      b_finish  := FALSE;
      j := nbit;

      REPEAT

         BEGIN
            IF b[j] = s_ZeroString THEN
               BEGIN
                   b[j] := SUCC(b[j]);
                   b_finish := TRUE;    { Exit from this loop }
               END
            ELSE
               BEGIN
                   b[j] := PRED(b[j]);
               END;
            DEC(j);                     { Decrease from right to left }
         END;

      UNTIL b_finish;

END; {BIT_STRING_2COM}


{////////////////////////////////////////////////////////////////////////////
 To copy the string into the array
////////////////////////////////////////////////////////////////////////////}
PROCEDURE BIT_STRING_COPY(s_inString        : STRING;
                         i_ExpStart,i_ExpEnd: INTEGER;
                          VAR b             : bit_string);


VAR

      j, i : INTEGER;

BEGIN

      j := 1 ;
      FOR i := i_ExpStart TO i_ExpEnd DO
          BEGIN
             b[i] := s_inString[j];
             INC(j);
          END

END; {BIT_STRING_COPY}


{////////////////////////////////////////////////////////////////////////////
 Routine to chop off zeros in extreme left in order to get the first 1
////////////////////////////////////////////////////////////////////////////}
PROCEDURE STRING_CHOPOFF_ZERO(VAR s_inString: STRING;
                              VAR i_expvalue: INTEGER);

VAR

      tmp_string : String;
      i, j       : INTEGER;

BEGIN

       i := 1;
       i_expvalue := 0;
       tmp_string := '';

       WHILE s_inString[i] <> s_OneString DO
         BEGIN
              INC(i_expvalue);
              INC(i);
         END;

       j := i;
       tmp_string := COPY(s_instring, j, LENGTH(s_inString) - i + 1);
       s_inString := tmp_String;

END;


{////////////////////////////////////////////////////////////////////////////
 Calculate no. of bits based on byte number
////////////////////////////////////////////////////////////////////////////}
FUNCTION GETBITNO(i_byte:INTEGER): INTEGER;

BEGIN

     IF i_byte = 1 THEN
        GETBITNO := i_NoOFBit
     ELSE
        GETBITNO := i_NoOFBit * i_MultipleOfByte;

END; {GETBITNO}


{////////////////////////////////////////////////////////////////////////////
 Capture number of bytes
////////////////////////////////////////////////////////////////////////////}
PROCEDURE GETBYTENO(i_1B,i_2B          : INTEGER;
                    VAR i_RByte, i_RBit: INTEGER);

VAR

      i_Number,i_X,i_Y   : INTEGER;

BEGIN

      REPEAT

            GOTOXY(1,11);
            WRITE  ('Enter how many bytes ','(1 Byte = ',i_NoOfBit, ' bits) (',i_1B:1,' or ',i_2B:1,') : ');
            i_X := WHEREX;
            i_Y := WHEREY;
            {$I-}
            TEXTCOLOR(YELLOW);
            READLN (i_Number);
            TEXTCOLOR(WHITE);
            {$I+}
            IF (IORESULT <> i_OKIOResult) OR (i_Number < i_1B) OR (i_Number > i_2B) THEN
               BEGIN
                 GOTOXY(i_X,i_Y);
                 CLREOL;
               END
            ELSE
               BEGIN
                 i_RByte := i_Number;
                 i_RBit  := GETBITNO(i_Number);
               END

      UNTIL (IORESULT = i_OKIOResult) AND (i_Number >= i_1B) AND (i_Number <= i_2B)

END; {GETBYTENO}


{/////////////////////////////////////////////////////////////////////////////
 Get user input a integer number
/////////////////////////////////////////////////////////////////////////////}
PROCEDURE GETNUMBER(i_Low,i_High  : INTEGER;
                    VAR i_Number  : LONGINT;
                    VAR b_OverFlow: BOOLEAN);

VAR

     i_X,i_Y, i_IORESULT   : INTEGER;

BEGIN

      REPEAT

          b_OverFlow := FALSE;
          GOTOXY(1,12);
          WRITE  ('Enter a positive or negative integer: ');
          i_X := WHEREX;
          i_Y := WHEREY;
          {$I-}
          TEXTCOLOR(YELLOW);
          READLN (i_Number);
          TEXTCOLOR(WHITE);
          {$I+}
          i_ioresult := IORESULT;
          IF (i_Number < i_Low) OR (i_Number > i_High) THEN
             BEGIN
                b_OverFlow := TRUE;    { Set this flag to true for overflow }
                GOTOXY(1,13);
                TEXTCOLOR(LIGHTRED+BLINK);
                WRITELN('Error: Data overflow. Range is ',i_Low, ' to ', i_High,' for ',i_Byte, ' byte(s).');
                TEXTCOLOR(WHITE);
             END;
          IF (i_IORESULT <> i_OKIOResult) THEN
             BEGIN
                GOTOXY(1,13);
                TEXTCOLOR(LIGHTRED+BLINK);
                WRITE('Error: Accepts only positive or negative integer.');
                TEXTCOLOR(WHITE);
                s_dummy := READKEY;
                GOTOXY(1,13);
                CLREOL;
                GOTOXY(i_X,i_Y);
                CLREOL;
             END;
      UNTIL (i_IORESULT = i_OKIOResult)


END; {GETNUMBER}


{/////////////////////////////////////////////////////////////////////////////
 Get user input a integer number
/////////////////////////////////////////////////////////////////////////////}
PROCEDURE GETREALNUM(r_Low,r_High  : REAL;
                     VAR r_Number  : REAL;
                     VAR b_OverFlow: BOOLEAN);

VAR

     i_X,i_Y, i_IORESULT   : INTEGER;

BEGIN

      REPEAT

          b_OverFlow := FALSE;
          GOTOXY(1,12);
          WRITE  ('Enter a positive or negative real number : ');
          i_X := WHEREX;
          i_Y := WHEREY;
          {$I-}
          TEXTCOLOR(YELLOW);
          READLN (r_Number);
          TEXTCOLOR(WHITE);
          {$I+}
          i_IORESULT := IORESULT;
          IF (r_Number < r_Low) OR (r_Number > r_High) THEN
             BEGIN
                b_OverFlow := TRUE;
                GOTOXY(1,13);
                TEXTCOLOR(LIGHTRED+BLINK);
                WRITELN('Error: Data overflow, range is ',r_Low:5:4,' to ',r_High:5:4,' for ',i_Byte, ' byte(s).');
                TEXTCOLOR(WHITE);
             END;

          IF (i_IORESULT <> i_OKIOResult) THEN
             BEGIN
                GOTOXY(1,13);
                WRITE('Error: Accepts only real number.');
                s_dummy := READKEY;
                GOTOXY(1,13);
                CLREOL;
                GOTOXY(i_X,i_Y);
                CLREOL;
             END;

      UNTIL (i_IORESULT = i_OKIOResult)

END; {GETREALNUM}


{//////////////////////////////////////////////////////////////////////////////
 Process calculate integer to binary
//////////////////////////////////////////////////////////////////////////////}
PROCEDURE CALINTBIN(i_Num: LONGINT; i_Bit :INTEGER; VAR b:bit_string;
                    b_OFFlag:BOOLEAN);

VAR

       i_quotient,i_remainder, i, j, k  : INTEGER;
       s                                : String[1];
       tmp_string, bin_string           : bit_string;
       i_absnum                         : LONGINT;

BEGIN

       FOR j := 1 TO i_bit DO    { Initialize array }
          BEGIN
             tmp_string[j] := s_Space;
             bin_string[j] := s_Space;
          END;

       i := 0;
       i_absnum := ABS(i_num);
       WHILE (i_absnum <> 0) DO   { IF number is 10, the base 2 is 0101 }
          BEGIN
             i_quotient := i_absnum DIV i_MultipleOfByte;
             i_remainder:= i_absnum MOD i_MultipleOfByte;
             i_absnum := i_quotient;
             INC(i);
             BIT_STRING_SETBIT(tmp_string,i,i_remainder);
          END;

       k := i + 1;   { Should add 1 here for next bit }
       BIT_STRING_ZERO(tmp_string, k, i_bit); { Fill in '0' }

       { At this point, the bit pattern is filled with '0's but in reverse
         order.  e.g.  4 ---> '00100000', should be '00000100'.
         So, we have to reverse it. }

       BIT_STRING_REVERSE(tmp_string,i_bit); { Reverse the bit pattern }

       bin_string := tmp_string;
       { At this point, the bit pattern is in proper order }

       IF i_num < 0  THEN   { Input number is a negative number }
          BEGIN
             BIT_STRING_2COM(bin_string,i_bit);  {Get the 2's complement}
             b := bin_string;
          END
       ELSE
          b := bin_string;

      IF b_OFFlag THEN   {If the number inputed is overflow }
         IF i_num < 0 THEN
            b[1] := s_OneString   {Set to '1'}
         ELSE
            b[1] := s_ZeroString; {Set to '0'}


END; {CALINTBIN}


{/////////////////////////////////////////////////////////////////////////////
 Binary to decimal
/////////////////////////////////////////////////////////////////////////////}
FUNCTION BINTODEC (s_binary:STRING):INTEGER;

VAR

     j              : integer;  { Define counter }
     i_value        : LONGINT;  { Define converted binary to decimal value }

BEGIN

     i_value := 0;

     FOR j := LENGTH(TRIM(s_binary)) DOWNTO 2 DO
         { Not downto 1 because 1 is a sign bit }
         BEGIN
              IF s_binary[j] = s_OneString THEN
                  i_value := i_value + TRUNC(EXP(((LENGTH(TRIM(s_binary)) - j) * LN(i_Base2) )))
              ELSE
                  i_value := i_value + 0;
         END;

     IF s_binary[1] = s_OneString THEN    {Input number is a negative value}
        BINTODEC := i_value - RAISEPOWER(i_Base2,i_bit - i_PositiveOne)
     ELSE
        BINTODEC := i_value;

END; {BINTODEC}


{/////////////////////////////////////////////////////////////////////////////
 Binary to integer routine
/////////////////////////////////////////////////////////////////////////////}
PROCEDURE BINTOINT;

VAR

     i,j,i_X,i_Y      : integer;
     b_okay           : boolean;
     s_binary         : String;

BEGIN

     GETBYTENO(i_1Byte,i_2Byte,i_Byte,i_Bit);

     REPEAT

         BEGIN

           b_okay := TRUE;
           s_binary := '';
           GOTOXY(1,12);
           WRITE ('Please enter a binary string in ',i_Bit, ' bit format : ');
           i_X := WHEREX;
           i_Y := WHEREY;
           CLREOL;
           TEXTCOLOR(YELLOW);
           READLN (s_binary);
           TEXTCOLOR(WHITE);
           FOR i := LENGTH(TRIM(s_binary)) DOWNTO i_PositiveOne DO
               IF NOT (s_binary[i] = s_ZeroString) AND NOT (s_binary[i] = s_OneString) THEN
                   BEGIN
                        b_okay := FALSE;
                        GOTOXY(i_X,i_Y);
                        CLREOL;
                   END
         END

     UNTIL b_okay AND (LENGTH(TRIM(s_binary)) = (i_Bit));

     WRITE  ('"', s_binary, '" binary string represents integer value : ');
     TEXTCOLOR(YELLOW);
     WRITE(BINTODEC(s_binary));
     TEXTCOLOR(WHITE);
     WRITELN('.');

END; {BINTOINT}


{////////////////////////////////////////////////////////////////////////////
 Integer to binary conversion
////////////////////////////////////////////////////////////////////////////}
PROCEDURE INTTOBIN;

VAR

      b_OFlowFlag : BOOLEAN;

BEGIN

      GETBYTENO(i_1Byte,i_2Byte,i_Byte,i_Bit);
      i_LowRange  := RAISEPOWER(i_Base2,i_Bit - i_PositiveOne) * i_NegativeOne;
      i_HighRange := RAISEPOWER(i_Base2,i_Bit - i_PositiveOne) - i_PositiveOne;
      GETNUMBER(i_LowRange,i_HighRange,i_Integer,b_OFlowFlag);
      WRITE (i_integer,' will be stored in ',i_byte, ' byte(s) as : ');
      WRITE('"');
      TEXTCOLOR(YELLOW);
      CALINTBIN(i_integer,i_Bit,s_string,b_OFlowFlag);  { Integer to binary routine }
      BIT_STRING_PRINT(s_string,i_bit);   { Print binary string }
      TEXTCOLOR(WHITE);
      WRITE('".');
      WRITELN;

END; {INTTOBIN}


{///////////////////////////////////////////////////////////////////////////
 Calculate exponent value
///////////////////////////////////////////////////////////////////////////}
FUNCTION CALEXP(s:Char; p:INTEGER):REAL;

VAR

      r_value   : REAL;
      i_errcode : INTEGER;
      i,j       : INTEGER;

BEGIN

      VAL(s,i,i_errcode);
      r_value := 1.0;

      FOR j := 1 TO p DO
          r_value := r_value * r_OneHalf;

      CALEXP := r_value * i;

END;  {CALEXP}


{/////////////////////////////////////////////////////////////////////////////
 Calculate the exponent value of the bit string to real numbers
/////////////////////////////////////////////////////////////////////////////}
FUNCTION CALEXPVAL(s_bitchar:Char; i: INTEGER): INTEGER;

VAR

      i_bitcharval,i_expval,i_errcode : INTEGER;

BEGIN

      i_expval := 0;
      i_bitcharval := 0;
      VAL(s_bitchar,i_bitcharval,i_errcode);
      i_expval := TRUNC(EXP(i * LN (i_base2)));

      CALEXPVAL := i_bitcharval * i_expval;
      { bit value (e.g. '1' -> 1 * 2 ^ i value }

END; {CALEXPVAL}


{/////////////////////////////////////////////////////////////////////////////
 Calculate exponent value of the bit string to real number
/////////////////////////////////////////////////////////////////////////////}
FUNCTION GETEXPVAL(s_binary:STRING;
                   i_start,i_end,i_expvalue:INTEGER):INTEGER;

VAR

      r_temp  : INTEGER;
      j,i     : INTEGER;

BEGIN

      r_temp := 0;
           j := 0;  {Starting point}

      FOR i:= i_end DOWNTO i_start DO

          BEGIN
             r_temp := r_temp + CALEXPVAL(s_binary[i],j);
             INC(j);
          END;

      GETEXPVAL := r_temp - i_expvalue;  { value of the exponent - 4 or 16 }

END; {GETEXPVAL}


{/////////////////////////////////////////////////////////////////////////////
 Calculate mantissa value of the bit string to real number
/////////////////////////////////////////////////////////////////////////////}
FUNCTION GETMANVAL(s_binary:STRING;i_start,i_end:INTEGER):REAL;

VAR

      r_temp  : REAL;
      j,i     : INTEGER;

BEGIN

      r_temp := 0.0;

      j := 1;
      FOR i:= i_start TO i_end DO
          BEGIN
               r_temp := r_temp + CALEXP(s_binary[i],j);
               INC(j);
          END;

      GETMANVAL := r_temp;

END;  {GETMANVAL}


{/////////////////////////////////////////////////////////////////////////////
 This function calculates parameter value in real type and return also in real
 type but in base 2
/////////////////////////////////////////////////////////////////////////////}
FUNCTION REMAINBASE2(r_fractionValue:REAL):STRING;

VAR

      s_base2value                        : STRING;
      r_temp, r_fraction                  : REAL;
      i, j, i_string, icode, i_divisor    : INTEGER;
      s_temp_string                       : String[1];
      s_string                            : String;

BEGIN

      r_fraction := r_fractionValue;
      i          := 0;
      s_string   := '';
      r_temp     := 0;

      REPEAT
           BEGIN
             r_temp        := r_fraction * i_MultipleOfByte;
             STR(TRUNC(r_temp),s_temp_string);
             s_string      := s_string + s_temp_string;
             r_fraction    := r_temp - TRUNC(r_temp);
             INC(i);
           END
      UNTIL r_fraction = 0.0;

      {At this point, the s_string contains e.g. 01 Base 2 for 0.25 value}
      s_base2value := s_string;
      REMAINBASE2 := s_base2value;

END;


{//////////////////////////////////////////////////////////////////////////////
 Process calculate integer to binary
//////////////////////////////////////////////////////////////////////////////}
PROCEDURE INTBASE2(i_Num: LONGINT;  VAR i_exponent:INTEGER;
                                    VAR bin_string:STRING);

VAR

       i_quotient,i_remainder, p,
       j, k, i_intBase2, icode          : INTEGER;
       s                                : String[1];
       tmp_string                       : String;
       i_absnum                         : LONGINT;

BEGIN

       i_exponent := 0;
       i_absnum := ABS(i_num);
       tmp_string := '';
       bin_string := '          '; 
       WHILE (i_absnum <> 0) DO
       { IF number is 10, the base 2 is 0101, if number is 0 then it will
         skip this part }
          BEGIN
             i_quotient := i_absnum DIV i_MultipleOfByte;
             i_remainder:= i_absnum MOD i_MultipleOfByte;
             i_absnum := i_quotient;
             STR(i_remainder,s);
             tmp_string := tmp_string + s;
             INC(i_exponent);
          END;

       { At this point, the string value in tmp_string is in reverse order
         so we have to reverse back it}

       IF ABS(i_num) <> 0 THEN
          BEGIN
              p := i_exponent;
              FOR j := 1 TO p DO
              BEGIN
                 bin_string[j] := tmp_string[p];
                 DEC(p);
              END
          END
       ELSE
          BEGIN
             i_exponent := 0;
             bin_string := s_ZeroString;
          END


END; {INTBASE2}


{/////////////////////////////////////////////////////////////////////////////
 Copy temporary bit string to the final bit string
/////////////////////////////////////////////////////////////////////////////}
PROCEDURE BIT_STRING_SETMAN(s_inString:STRING;
                            i_nBit    :INTEGER;
                            VAR b     :bit_string);

VAR

     i_StartBit, i_EndBit, i, j, k, q, p : INTEGER;

BEGIN

      IF i_nBit = i_NoOfBit THEN
         BEGIN
            i_StartBit := i_8ManStartBit ;
            i_EndBit   := i_8ManEndBit   ;
         END
      ELSE
         BEGIN
            i_StartBit := i_16ManStartBit ;
            i_EndBit   := i_16ManEndBit   ;
         END;

      j := i_EndBit - i_StartBit + 1;   { j refers to no. of bit for mantissa }
      k := i_StartBit;
      IF LENGTH(TRIM(s_inString)) > j THEN
         BEGIN
            WRITELN('Note: Round off error.');
            FOR i := 1 TO j DO    { How many times to fill the s_InString }
            BEGIN
               b[k] := s_InString[i];
               INC(k);
            END
         END
      ELSE
         FOR i := 1 TO LENGTH(TRIM(s_inString)) DO    { How many times to fill the s_InString }
         BEGIN
             b[k] := s_InString[i];
             INC(k);
         END;


      { If there is available space to fill in, we have to do the following
        routine, e.g. if the input is 16 bit the storage for 2.25 is like
        this for mantissa:
                    16 bit
        +-------------------------------+
        | | | | | | |1|0|0|1| | | | | | |
        +-------------------------------+
                     |       | | | | | | ----> these should be filled with '0'
                     +----Start of mantissa
      }

      q := k;
      p := LENGTH(TRIM(s_inString));

      IF p < (i_EndBit - i_StartBit + i_PositiveOne) THEN
      { To check whether any zero to fill }

         BEGIN
           BIT_STRING_ZERO(b,q,i_EndBit);
         END

END; {BIT_STRING_SETMAN}


{/////////////////////////////////////////////////////////////////////////////
 To set the bit string for exponent value
/////////////////////////////////////////////////////////////////////////////}
PROCEDURE BIT_STRING_SETEXP(i_exponent:INTEGER;
                            c_Sign    :CHAR;
                            i_Bit     :INTEGER;
                            VAR b     :bit_string);

VAR

    k, i, p, q, r, t, u, w, y, z, x, i_dummy : INTEGER;
    s_rtnstring,s_finalString, tmp_string    : STRING;

BEGIN

       s_finalstring := '';

       IF i_Bit = i_NoOfBit THEN
          BEGIN
             q := i_8BitExpInd;          { q is excess 4 }
             t := i_8ExpStartBit;
             u := i_8ExpEndBit;
             w := i_8ExpEndBit - i_8ExpStartBit;
          END
       ELSE
          BEGIN
             q := i_16BitExpInd;         { q in excess 16 }
             t := i_16ExpStartBit;
             u := i_16ExpEndBit;
             w := i_16ExpEndBit - i_16ExpStartBit;
          END;

       IF i_exponent = 0 THEN { Logically meant, no need to do with the exponent }
          BEGIN
              p := q;
              INTBASE2(p,i_dummy,s_rtnstring);
          END
       ELSE
          BEGIN
              IF c_Sign = '+' THEN
                 p := i_exponent + q
              ELSE
                 p := i_exponent * i_NegativeOne + q;
              INTBASE2(p,i_dummy,s_rtnstring);
          END;

       tmp_string := TRIM(s_rtnString);
       x := LENGTH(tmp_string);

       IF x < w + 1 THEN
          BEGIN
            y  := ( w + 1 ) - x;
            FOR z := 1 TO y DO
              s_finalString := s_finalString + s_ZeroString;
          END;

       s_finalString := s_finalString + tmp_string;

       {At this point, we have already the string for exponent side and ready
        to put it into the final bit string array }

       BIT_STRING_COPY(s_finalstring,t,u,b);

END; {BIT_STRING_SETEXP}


{///////////////////////////////////////////////////////////////////////////
 Real to bin
///////////////////////////////////////////////////////////////////////////}
PROCEDURE CALREALBIN (r_inputReal   :REAL;
                     i_Bit          :INTEGER;
                     b_OFFlag       :BOOLEAN;
                     VAR s_outstring:bit_string);

VAR

    r_RealNumInBase2 : REAL;
    r_ABSValNum      : REAL;
    r_remain         : REAL;
    s_remainBase2    : STRING;
    s_totvalBase2    : STRING;
    s_intBase2       : STRING;
    i_intBase2       : INTEGER;
    icode            : INTEGER;
    i_exponent       : INTEGER;
    i_expvalue       : INTEGER;
    i,ierrcode,j,k   : INTEGER;
    bin_string       : bit_string;
    i_totexpval,q    : INTEGER;
    i_dummy,i_loop   : INTEGER;
    c_Sign           : CHAR;

    { Fractional value in base 2, e.g. 6.25 (base 10) --> 110.01 (base 2) }

BEGIN

    r_ABSValNum   := ABS(r_inputReal);      { Get the absolute value}
    r_remain      := r_ABSValNum - TRUNC(r_ABSValNum); { e.g. 6.25 - 6.0 = .25 }

    IF r_ABSValNum < r_OneHalf THEN  { Check the inputed value in absolute value }
       c_Sign := '-'
    ELSE
       c_Sign := '+';

    s_remainBase2 := REMAINBASE2(r_remain);    { 0.25 Base 10 --> '01' }
    INTBASE2(TRUNC(r_ABSValNum), i_exponent, s_intBase2);  {6 Base 10 --> '110' }
    s_intBase2 := TRIM(s_intBase2);

    IF s_intBase2 = s_ZeroString THEN       { if the integer part is 0 }
       s_totvalBase2 := s_remainBase2 { '01' = '01' }
    ELSE
       s_totvalBase2 := s_intBase2 + s_remainBase2; { '110'+'01' = '11001' }

    {At this point, there are cases which the s_totvalbase2 string will
     start with '0....'. e.g. 0.4 base10 with be 0.01100110011... in base 2,
     so we must chop off the first 0 until the first bit is 1}

    STRING_CHOPOFF_ZERO(s_totvalBase2, i_expvalue);
    { i_expvalue is exponent to the right }

    FOR i := 1 TO i_Bit DO            { Initialize the final bit string }
       bin_string[i] := s_Space;

    IF i_exponent = 0 THEN
       i_exponent := i_expvalue;

    BIT_STRING_SETMAN(s_totvalBase2,i_Bit,bin_string);
    { To copy the bit string value of mantissa e.g. 6.25 ,
      the mantissa is '11001'}

    BIT_STRING_SETEXP(i_exponent,c_Sign,i_Bit,bin_string);
    { To set the exponent bit string e.g. 6.25 , the exponent bit string is
      '111' because '111' is 3 in excess 4 notation }

    { So, at this point, the bit string for 6.25 is '01111100' for 8 bit or
      '0100111100000000' for 16 bit }

    IF r_inputReal < 0 THEN
       bin_string[1] := s_OneString
    ELSE
       bin_string[1] := s_ZeroString;

    IF b_OFFlag THEN
       WRITELN('Note: The inputed real value has been overflowed.');

    s_outstring := bin_string;

END; {CALREALBIN}


{/////////////////////////////////////////////////////////////////////////////
 Convert real number to binary string
/////////////////////////////////////////////////////////////////////////////}
PROCEDURE REALTOBIN;

VAR

      r_realposval, r_realnegval  : REAL;
      b_OverFlow                  : BOOLEAN;
      s_binString                 : bit_String;

BEGIN

      GETBYTENO(i_1Byte,i_2Byte,i_Byte,i_Bit);
      IF i_Bit = i_NoOfBit THEN
          BEGIN
            r_realposval :=  1.0 * r_8posbinary;
            r_realnegval := -1.0 * r_8posbinary;
          END
      ELSE
          BEGIN
            r_realposval :=  1.0 * r_16posbinary;
            r_realnegval := -1.0 * r_16posbinary;
          END;

      r_LowRange  := r_realnegval;
      r_HighRange := r_realposval;

      GETREALNUM(r_LowRange,r_HighRange,r_RealNum,b_Overflow);
      WRITE (r_RealNum:5:5,' will be stored in ',i_byte, ' byte(s) as : ');
      WRITE('"');
      TEXTCOLOR(YELLOW);
      CALREALBIN(r_RealNum,i_Bit,b_OverFlow,s_binstring);  { Real Integer to binary routine }
      BIT_STRING_PRINT(s_binstring,i_bit);   { Print binary string }
      TEXTCOLOR(WHITE);
      WRITE('".');
      WRITELN;

END; {REALTOBIN}


{/////////////////////////////////////////////////////////////////////////////
 Binary to real number calculation
/////////////////////////////////////////////////////////////////////////////}
FUNCTION BINTOREALNUM(s_binary:STRING;  i_Bit:INTEGER):REAL;

VAR

      i,j, r_num : REAL;
      k,l        : INTEGER;
      m          : LONGINT;

BEGIN

       r_num := 0;

       IF i_Bit = i_NoOfBit THEN  { No. of bits per bytes }

          BEGIN

             k := i_8BitExpInd;     {4 for 8 bit, 16 for 16 bit}
             l := GETEXPVAL(s_binary,i_8ExpStartBit,i_8ExpEndBit,k);
             m := RAISEPOWER(i_base2,ABS(l));

             IF l < 0 THEN
                i := 1.0 / m
             ELSE
                i := m;

             j := GETMANVAL(s_binary,i_8ManStartBit,i_8ManEndBit);

          END

       ELSE

          BEGIN
             k := i_16BitExpInd;    {16}
             l := GETEXPVAL(s_binary,i_16ExpStartBit,i_16ExpEndBit, k);
             m := RAISEPOWER(i_base2,ABS(l));

             IF l < 0 THEN  { If l is negative }
                i := 1.0 / m
             ELSE
                i := m;

             j := GETMANVAL(s_binary,i_16ManStartBit,i_16ManEndBit);
          END;

       r_num := i * j;   { Exponent * mantissa }

       IF s_binary[1] = s_OneString THEN { Negative }
          r_num := r_num * i_NegativeOne;

       BINTOREALNUM := r_num;

END; {BINTOREALNUM}


{/////////////////////////////////////////////////////////////////////////////
 Binary string to real number
/////////////////////////////////////////////////////////////////////////////}
PROCEDURE BINTOREAL;

VAR

     b_okay      : boolean;
     s_binary    : string;
     i_X,i_Y, i  : INTEGER;
     r_realnum   : REAL;

BEGIN

     GETBYTENO(i_1Byte,i_2Byte,i_Byte,i_Bit);

     REPEAT

         BEGIN

           b_okay := TRUE;
           s_binary := '';
           GOTOXY(1,12);
           WRITE ('Please enter a binary string in ',i_Bit, ' bit format : ');
           i_X := WHEREX;
           i_Y := WHEREY;
           CLREOL;
           TEXTCOLOR(YELLOW);
           READLN (s_binary);
           TEXTCOLOR(WHITE);
           FOR i := LENGTH(TRIM(s_binary)) DOWNTO 1 DO
                  IF NOT (s_binary[i] = s_ZeroString) AND NOT (s_binary[i] = s_OneString) THEN
                      BEGIN
                            b_okay := FALSE;
                            GOTOXY(i_X,i_Y);
                            CLREOL;
                      END

         END

     UNTIL (b_okay = TRUE) AND (LENGTH(TRIM(s_binary)) = (i_Bit));

     r_realnum := BINTOREALNUM(s_binary,i_Bit);

     WRITE ('"', s_binary, '" binary string represents real number : ');
     TEXTCOLOR(YELLOW);
     WRITE(r_realnum:6:13);
     TEXTCOLOR(WHITE);
     WRITELN('.');

END; {BINTOREALNUM}


{/////////////////////////////////////////////////////////////////////////////
 Make appropriate choice from the options
/////////////////////////////////////////////////////////////////////////////}
PROCEDURE MAKECHOICE;

BEGIN

      CASE i_choice OF

          1: INTTOBIN;
          2: BINTOINT;
          3: REALTOBIN;
          4: BINTOREAL;

      END;

END; {MAKECHOICE}


{////////////////////////////////////////////////////////////////////////////
 Get what option the user wants
////////////////////////////////////////////////////////////////////////////}
PROCEDURE GETCHOICE(i_LoLimit,i_HiLimit:INTEGER;
                    VAR     i_getChoice:INTEGER);

VAR

       i_X,i_Y      : INTEGER;  { Local variable for x,y coordinate value }

BEGIN

       REPEAT

           GOTOXY(1,10);
           WRITE('Enter your choice (',i_LowLimit:1,' - ',i_HighLimit:1,') : ');
           i_X := WHEREX;
           i_Y := WHEREY;
           {$I-}
           TEXTCOLOR(YELLOW);
           READLN(i_getChoice);
           TEXTCOLOR(WHITE);
           {$I+}
           IF (IORESULT <> i_OKIOResult) OR (i_choice < i_LoLimit) OR
              (i_choice > i_HiLimit) THEN
              GOTOXY(i_X,i_Y);
              CLREOL;

       UNTIL (IORESULT = i_OKIOResult) AND
             (i_choice >= i_LoLimit) AND
             (i_choice <= i_HiLimit)

END; {GETCHOICE}


{/////////////////////////////////////////////////////////////////////////////
 Displays the main menu for user to choose
/////////////////////////////////////////////////////////////////////////////}
PROCEDURE DISPMENU;

BEGIN

    CLRSCR;
    WRITELN ('              +--------------------------------------------------+');
    WRITELN ('              |  << BASE 10/BASE 2 NUMBER CONVERSION PROGRAM >>  |');
    WRITELN ('              |      1. Integer Number ---> Binary  String       |');
    WRITELN ('              |      2. Binary  String ---> Integer Number       |');
    WRITELN ('              +--------------------------------------------------+');
    WRITELN ('              |      3. Real    Number ---> Binary  String       |');
    WRITELN ('              |      4. Binary  String ---> Real    Number       |');
    WRITELN ('              |      5. Quit                                     |');
    WRITELN ('              +--------------------------------------------------+');

END; {DISPMENU}


{/////////////////////////////////////////////////////////////////////////////
 Main Pogram
/////////////////////////////////////////////////////////////////////////////}
BEGIN

     TEXTCOLOR(WHITE);
     TEXTBACKGROUND(BLUE);

     REPEAT

         CLRSCR;
         DISPMENU;                                    { Display heading }
         GETCHOICE(i_LowLimit,i_HighLimit,i_Choice);  { Get choice option }
         IF i_Choice < i_highLimit THEN
            BEGIN
                MAKECHOICE;                           { Make a choice }
                PRESSKEY;
                s_response := READKEY;
            END;

     UNTIL (i_choice = i_highlimit)

END. {MAIN PROGRAM}

