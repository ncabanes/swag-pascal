{
Sadly, the 3d.zip file was corrupt again.  Please use my programs here and
generate a DATA.HEX include file.  Your post had lines that were uneven and
obviously missing data.  An include file made by ZIP2HEX will be even and
verifiable.  HEX2ZIP will create the original binary file renamed BINARY.ZIP.
I noticed your zip file was less than 20k and its source code contents were
over 100k.  The include file will always be four times the size of the zip due
to formatting with commas and dollar symbols.  A smarter version should use
LONGINTS instead of BYTES to gain a 60% savings.
{ These programs can be added to SWAG }
PROGRAM Hex2Zip;
{ Converts hex data file less than 64k in size into binary equivalent }
{ 1994 Freeware v1.2  Hex-to-Binary file convertor by John Howard }
{$i DATA.HEX}
(*  layout of DATA.HEX include file is
  CONST
       { Size is equal to FILESIZE(BINARY) }
       HEX_DATA : ARRAY[1..Size] OF BYTE = (
             { i.e. hex data such as $00,$A2,$FF,.. } );
*)
VAR
   BINARY : FILE;
BEGIN
    ASSIGN(BINARY,'BINARY.ZIP');
    REWRITE(BINARY,1);
    BLOCKWRITE(BINARY,HEX_DATA,SIZEOF(HEX_DATA));
    CLOSE(BINARY);
    WRITELN('Data was converted to your file called BINARY.ZIP');
END.

PROGRAM Zip2Hex;
{ Converts binary file less than 64k in size into hex data file equivalent }
{ 1994 Freeware v1.2  Binary-to-Hex data convertor by John Howard }

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

VAR
   BINARY : FILE;
   HEXFILE : TEXT;
   Hex_Byte : BYTE;
   Size : LONGINT;
   i : WORD;
BEGIN
  IF ParamStr(1) = '?' THEN
    BEGIN
      WRITELN('Howard International, P.O. Box 34633, NKC, MO 64116 USA');
      WRITELN('1994 Freeware v1.2  Binary-to-Hex data convertor');
      WRITELN('Syntax:  zip2hex.exe  [filename]');
      WRITELN('Filename is optional, the default is BINARY.ZIP');
      Halt;
    END;

    IF ParamCount = 0 THEN
       ASSIGN(BINARY,'BINARY.ZIP')
    ELSE
       ASSIGN(BINARY,ParamStr(1));

    RESET(BINARY,1);
    ASSIGN(HEXFILE,'DATA.HEX');
    REWRITE(HEXFILE);

    Size := FILESIZE(BINARY);
    WRITELN(HEXFILE, 'CONST HEX_DATA : ARRAY[1..', Size,'] OF BYTE = (');

    BLOCKREAD(BINARY,Hex_Byte,SIZEOF(Hex_Byte));
    WRITE(HEXFILE, ' $');
    WRITE(HEXFILE,HEXBYTE(Hex_Byte));
    FOR i := 2 TO Size DO
      BEGIN
        BLOCKREAD(BINARY,Hex_Byte,SIZEOF(Hex_Byte));
        WRITE(HEXFILE, ',$');
        WRITE(HEXFILE,HEXBYTE(Hex_Byte));
        IF (i MOD 16 = 0) THEN WRITELN(HEXFILE);
      END;
    WRITELN(HEXFILE, ');');

    CLOSE(HEXFILE);
    CLOSE(BINARY);
    WRITELN('Your BINARY ZIP was converted to DATA.HEX include file.');
END.

