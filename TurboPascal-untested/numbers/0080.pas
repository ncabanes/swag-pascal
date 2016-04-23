{----------------------------------------------------------------------------}
{ NUMERIC CONVERTER                                             version 2.1

  Written by Marco Antonio Alvarado Perez.
  Costa Rica, September 1996.

  Internet: 9500149@ITCR-LI.LI.ITCR.Ac.CR

  About the tool:
    Firstly I wrote the program for curiosity, and then I found it was very
  useful to translate those huge bitmaps that I wanted to insert in the
  source code. Actually, I use a version that reads text files and builts the
  arrays.

  About Turbo Pascal 7.0:
    You can call this program directly from the editor. Insert it as a tool 
  with Options - Tools in the menu bar.

  About the language:    
    I hope you could understand my English. I have source code in Spanish, if 
  you want a copy just send me E-Mail.
}
{----------------------------------------------------------------------------}

PROGRAM NumericConverter;

  CONST
    GreaterDigit = 15;
    Digits : ARRAY [0..GreaterDigit] OF Char = '0123456789ABCDEF';

  FUNCTION DigitToValue (Digit : Char) : Byte;

    VAR
      Index : Byte;

  BEGIN
    Digit := UpCase (Digit);
    Index := GreaterDigit;
    WHILE (Index > 0) AND (Digit <> Digits [Index]) DO Dec (Index);
{unknow digit = 0}
    DigitToValue := Index;
  END;

  FUNCTION PositionValue (Position, Base : Byte) : LongInt;

      VAR
        Value : LongInt;
        Index : Byte;

  BEGIN
    Value := 1;
    FOR Index := 2 TO Position DO Value := Value * Base;
    PositionValue := Value;
  END;

  FUNCTION StringToValue (Str : STRING; Base : Byte) : LongInt;

      VAR
        Value : LongInt;
        Index : Byte;

  BEGIN
    Value := 0;
    FOR Index := 1 TO Length (Str) DO Inc (Value, DigitToValue (Str
      [Index]) * PositionValue (Length (Str) - Index + 1, Base));
    StringToValue := Value;
  END;

  FUNCTION ValueToString (Value : LongInt; Base : Byte) : STRING;

    VAR
      Str : STRING;

  BEGIN

    IF Value = 0 THEN Str := Digits [0] ELSE
    BEGIN
      Str := '';

      WHILE Value > 0 DO
      BEGIN
        Str := Digits [Value MOD Base] + Str;
        Value := Value DIV Base;
      END;

    END;

    ValueToString := Str;
  END;

  PROCEDURE ShowHelp;
  BEGIN
    WriteLn ('CONV - Numeric Converter');
    WriteLn;
    WriteLn ('Written by Marco Antonio Alvarado.');
    WriteLn ('Costa Rica, September 1996.');
    WriteLn;
    WriteLn ('Internet: 9500149@ITCR-LI.LI.ITCR.Ac.CR');
    WriteLn;
    WriteLn ('Use:');
    WriteLn ('  CONV <number> <base of number> <base to convert>');
    WriteLn;
    WriteLn ('Bases:');
    WriteLn ('  B   binary');
    WriteLn ('  O   octal');
    WriteLn ('  D   decimal');
    WriteLn ('  H   hexadecimal');
    WriteLn;
    WriteLn ('Example:');
    WriteLn ('  CONV A000 H D');
  END;

  VAR
    Number : STRING;
    Base : STRING [1];
    BaseNumber : Byte;
    BaseConvert : Byte;

BEGIN
  Number := '0';
  BaseNumber := 10;
  BaseConvert := 10;

  IF ParamCount = 3 THEN
  BEGIN
    Number := ParamStr (1);

    Base := ParamStr (2);
    Base := UpCase (Base [1]);
    IF Base = 'B' THEN BaseNumber := 2;
    IF Base = 'O' THEN BaseNumber := 8;
    IF Base = 'D' THEN BaseNumber := 10;
    IF Base = 'H' THEN BaseNumber := 16;

    Base := ParamStr (3);
    Base := UpCase (Base [1]);
    IF Base = 'B' THEN BaseConvert := 2;
    IF Base = 'O' THEN BaseConvert := 8;
    IF Base = 'D' THEN BaseConvert := 10;
    IF Base = 'H' THEN BaseConvert := 16;

    Write (Number, ' ', ParamStr (2), ' = ');
    WriteLn (ValueToString (StringToValue (Number, BaseNumber), BaseConvert),
      ' ', ParamStr (3));
  END ELSE ShowHelp;

END.

