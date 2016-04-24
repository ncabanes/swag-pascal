(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0060.PAS
  Description: Binary To Hex File Conversion
  Author: JOHN HOWARD
  Date: 11-26-94  05:09
*)

PROGRAM Hex4Bin;
{ Converts hex data file into binary (~64k maximum size) equivalent }
{ 20OCT94 Freeware v2.2  Hex-to-Binary file convertor by John Howard }
{$i DATA4.HEX}
(* layout of DATA4.HEX include file saves 40% compared to Hex_Byte array:
  CONST
       Name = { 'binary' } ;
       { SizeL is equal to FILESIZE(BINARY) DIV 4 }
       HEX_DATA : ARRAY[1..SizeL] OF LONGINT = (
             { i.e. hex data such as $4500A2FF,.. } );
       Size = { FILESIZE(BINARY) MOD 4 } ;
       HEX_PAD : ARRAY[1..Size] OF BYTE = ( { $85,$8E,$05 } );
*)
VAR
   BINARY : FILE;
BEGIN
    WRITELN('Howard International, P.O. Box 34633, NKC, MO 64116 USA');
    WRITELN('20OCT94 Freeware v2.2  Hex-to-Binary (~64k maximum)');
    ASSIGN(BINARY,'binary');
    REWRITE(BINARY,1);
    BLOCKWRITE(BINARY,HEX_DATA,SIZEOF(HEX_DATA));
    IF Size <> 0 THEN
      BLOCKWRITE(BINARY,HEX_PAD,SIZEOF(HEX_PAD));
    CLOSE(BINARY);
    WRITELN('You may rename BINARY to: ', Name);
END.



PROGRAM Bin4Hex;
{ Converts binary file less than ~64k in size into hex data file equivalent }
{ 20OCT94 Freeware v2.2  Binary-to-Hex data convertor by John Howard }
{ Note: This longint approach saves 40% compared to bytes only. }
FUNCTION HexByte(B : Byte) : String;
CONST
  HexDigits : ARRAY[0..15] OF Char = '0123456789ABCDEF';
VAR Temp : String;
BEGIN
  Temp[0] := #2;
  Temp[1] := HexDigits[B SHR 4];
  Temp[2] := HexDigits[B AND $F];
  HexByte := Temp;
END;

FUNCTION HexLong(L : Longint) : String;
CONST
  HexDigits : ARRAY[0..15] OF Char = '0123456789ABCDEF';
VAR Temp : String;
BEGIN
  Temp[0] := #8;
  Temp[1] := HexDigits[(L SHR 28) AND $F];
  Temp[2] := HexDigits[(L SHR 24) AND $F];
  Temp[3] := HexDigits[(L SHR 20) AND $F];
  Temp[4] := HexDigits[(L SHR 16) AND $F];
  Temp[5] := HexDigits[(L SHR 12) AND $F];
  Temp[6] := HexDigits[(L SHR 8) AND $F];
  Temp[7] := HexDigits[(L SHR 4) AND $F];
  Temp[8] := HexDigits[L AND $F];
  HexLong := Temp;
END;

VAR
   Name : STRING;
   BINARY : FILE;
   HEXFILE : TEXT;
   Hex_Byte : BYTE;
   Hex_Long : LONGINT;
   Size : LONGINT;
   i : WORD;
BEGIN
  IF ParamStr(1) = '/?' THEN
    BEGIN
      WRITELN('Howard International, P.O. Box 34633, NKC, MO 64116 USA');
      WRITELN('20OCT94 Freeware v2.2  Binary-to-Hex data convertor');
      WRITELN('Syntax:  bin4hex.exe  [filename]');
      WRITELN('Filename is optional, the default is called BINARY');
      Halt;
    END;
    IF ParamCount = 0 THEN
       Name := 'binary'
    ELSE
       Name := ParamStr(1);
    WRITELN('Looking for file called: ', Name);
    ASSIGN(BINARY,Name);
    FileMode := 0;    { Read Only }
    {$I-}   RESET(BINARY,1);  {$I+}
    IF IOResult <> 0 THEN BEGIN
      WRITELN('File not found.  Try the /? parameter.'); Halt;
    END;
    ASSIGN(HEXFILE,'DATA4.HEX');
    REWRITE(HEXFILE);
    Size := FILESIZE(BINARY) DIV 4;
    WRITELN(HEXFILE, 'CONST Name = ''', Name,''';');
    WRITELN(HEXFILE, '      HEX_DATA : ARRAY[1..', Size,'] OF LONGINT = (');
    BLOCKREAD(BINARY,Hex_Long,SIZEOF(Hex_Long));
    WRITE(HEXFILE, ' $');
    WRITE(HEXFILE,HEXLONG(Hex_Long));
    FOR i := 2 TO Size DO
      BEGIN
        BLOCKREAD(BINARY,Hex_Long,SIZEOF(Hex_Long));
        WRITE(HEXFILE, ',$');
        WRITE(HEXFILE,HEXLONG(Hex_Long));
        IF (i MOD 7 = 0) THEN WRITELN(HEXFILE);   { columns }
      END;
    WRITELN(HEXFILE, ');');
    Size := FILESIZE(BINARY) MOD 4;
    IF Size <> 0 THEN
      BEGIN
         WRITELN(HEXFILE, '     Size = ', Size,';');
         WRITE  (HEXFILE, '     HEX_PAD : ARRAY[1..', Size,'] OF BYTE = ($');
         FOR i := 1 TO Size DO
           BEGIN
             BLOCKREAD(BINARY,Hex_Byte,SIZEOF(Hex_Byte));
             IF i <> 1 THEN WRITE(HEXFILE, ',$');
             WRITE(HEXFILE,HEXBYTE(Hex_Byte));
           END;
         WRITELN(HEXFILE, ');');
      END
    ELSE
      BEGIN
         WRITELN(HEXFILE, '     Size = 0;');
         WRITELN(HEXFILE, '     HEX_PAD : ARRAY[1..1] OF BYTE = (0);');
      END;
    CLOSE(HEXFILE);
    CLOSE(BINARY);
    WRITELN('Your BINARY was converted to DATA4.HEX include file.');
END.


