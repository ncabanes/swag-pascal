(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0080.PAS
  Description: English Number Strings
  Author: GAYLE DAVIS
  Date: 01-27-94  17:33
*)

{
   Converts REAL number to ENGLISH strings
   GAYLE DAVIS 1/21/94
   Amounts up to and including $19,999,999.99 are supported.
   If you write amounts larger than that, you don't need a computer !!
   ======================================================================
   Dedicated to the PUBLIC DOMAIN, this software code has been tested and
   used under BP 7.0/DOS and MS-DOS 6.2.
}

USES CRT;

{CONST
     Dot : CHAR = #42;

VAR
    SS : STRING;
    AA : REAL;}

FUNCTION EnglishNumber (Amt : REAL) : STRING;

TYPE
  Mword = STRING [10];
  Amstw = STRING [80];  {for function TenUnitToWord output}

CONST
  NumStr : ARRAY [0..27] OF Mword =
         ('', 'ONE ', 'TWO ', 'THREE ', 'FOUR ', 'FIVE ', 'SIX ', 'SEVEN ',
          'EIGHT ','NINE ', 'TEN ', 'ELEVEN ', 'TWELVE ', 'THIRTEEN ',
          'FOURTEEN ', 'FIFTEEN ', 'SIXTEEN ', 'SEVENTEEN ', 'EIGHTEEN ',
          'NINETEEN ', 'TWENTY ', 'THIRTY ', 'FORTY ', 'FIFTY ', 'SIXTY ',
          'SEVENTY ', 'EIGHTY ', 'NINETY ');
VAR
  {S               : STRING;}
  Temp            : REAL;
  DigitA, DigitB  : INTEGER;
  Ams             : STRING;
  Ac              : STRING [2];

FUNCTION TenUnitToWord (TeUn : INTEGER) : Amstw;
         { convert tens and units to words }
  BEGIN
    IF TeUn < 21 THEN TenUnitToWord := NumStr [TeUn]
      ELSE TenUnitToWord := NumStr [TeUn DIV 10 + 18] + NumStr [TeUn MOD 10];
  END; {function TenUnitToWord}

BEGIN

  { Nothing bigger than 20 million }
  IF (Amt > 20000000.0) OR (Amt <= 0.0) THEN
    BEGIN
      EnglishNumber := '';  {null string if out of range}
      EXIT;
    END;
  { Convert 1,000,000 decade }
  Ams := '';
  DigitA := TRUNC (Amt / 1E6);
  IF DigitA > 0 THEN Ams := Ams + NumStr [DigitA] + 'MILLION ';
  Temp := Amt - DigitA * 1E6;

  { Convert 100,000, 10,000, 1,000 decades }

  DigitA := TRUNC (Temp / 1E5);         {extract 100,000 decade}
  IF DigitA > 0 THEN Ams := Ams + NumStr [DigitA] + 'HUNDRED ';
  Temp := Temp - DigitA * 1E5;
  DigitB := TRUNC (Temp / 1000);        {extract sum of 10,000 and 1,000 decades}
  Ams := Ams + TenUnitToWord (DigitB);
  IF ( (DigitA > 0) OR (DigitB > 0) ) THEN Ams := Ams + 'THOUSAND ';

  {Convert 100, 10, unit decades}

  Temp := Temp - DigitB * 1000.0;
  DigitA := TRUNC (Temp / 100);          {extract 100 decade}
  IF DigitA > 0 THEN Ams := Ams + NumStr [DigitA] + 'HUNDRED ';
  DigitB := TRUNC (Temp - DigitA * 100.0);  {extract sum of 10 and unit decades}
  Ams := Ams + TenUnitToWord (DigitB);

  {Convert cents to form XX/100}

  IF INT (Amt) > 0.0 THEN Ams := Ams + 'AND ';
  DigitA := ROUND ( (FRAC (Amt) * 100) );
  IF DigitA > 0 THEN
    BEGIN
      STR (DigitA : 2, Ac);
      IF Ac [1] = ' ' THEN Ac [1] := '0';
      Ams := Ams + Ac + '/100'
    END
  ELSE Ams := Ams + 'NO/100';

  EnglishNumber := Ams + ' Dollars';

END;

BEGIN
ClrScr;
WriteLn(EnglishNumber (1234.55));
WriteLn(EnglishNumber (991234.55));
WriteLn(EnglishNumber (19891234.55));
Readkey;
END.
