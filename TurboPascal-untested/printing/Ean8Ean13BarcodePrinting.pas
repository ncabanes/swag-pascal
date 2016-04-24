(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0041.PAS
  Description: EAN-8 & EAN-13 Barcode printing
  Author: ROHIT GUPTA
  Date: 02-28-95  09:48
*)

{ This unit writes EAN-8 and EAN-13 barcodes to an Epson, IBM Pro or HP
  Laser compatible printers. It has been tested on a variety of printers
  and works well.  The barcodes generated were able to be read by at least
  one brand of bar code reader.

By Rohit Gupta

You may use this as you see fit.

}

{$R-,B+,S-,I+,N-,D-,L-,Y-}
{$M $4000,$4000,$8000}

UNIT BarCode;


INTERFACE


CONST
     PrnPosn = 5;  { Print Offset Column }

TYPE
    EAN_13  = STRING [13];

    Printer_Type = (Epson, Ibm, Laser);


PROCEDURE Print_BarCode
          (VAR Lst    : TEXT;
               Typ    : Printer_Type;
               Code   : EAN_13;
               NLines : INTEGER);


IMPLEMENTATION


FUNCTION Num (Arg : INTEGER) : STRING;
VAR
   St : STRING [20];
BEGIN
     STR (Arg,St);
     Num := St;
END;


PROCEDURE Print_BarCode (VAR Lst  : TEXT;   Typ    : Printer_Type;
                             Code : EAN_13; NLines : INTEGER);

CONST
     Max_Code_Len = 2*3 + 5 + 7*12;  { For 12 digit bar code }

     ESC = #27;


TYPE
    Bar_Position = (Left,Centre,Right);
    One_Dig      = STRING [7];
    Buffer       = ARRAY [1..1024] OF CHAR;


VAR
   LCode     : EAN_13;   { Local Copy, padded & checked }
   Seg_Size,             { Left/Right Segment Size      }
   Code_Len,             { Size of BarCode in digits    }
   Bar_Len,              { Size of Barcode in bar units }
   Bytes,                { Bytes per bar unit           }
   Line_Len,             { Line Length in Gfx Mode      }
   Mult      : INTEGER;  { Number of Lines per char line}

   Full_Code : STRING [Max_Code_Len];

   PBuffer   : ^Buffer;
   Posn      : INTEGER;  { Buffer Position }


PROCEDURE Rationalise_Code;
VAR
   I : INTEGER;
BEGIN
     IF LENGTH (Code) > 8
     THEN Seg_Size := 6
     ELSE Seg_Size := 4;

     Code_Len := Seg_Size * 2;

     LCode := Code;
     FOR I := LENGTH(LCode)+1 TO Code_Len-1  { Pad with Leading Zeros }
     DO LCode := '0' + LCode;

     Bar_Len := 2*3 + 5 + 7*Code_Len;
             {  LRG   CG  CODE }
END;


PROCEDURE Calc_Check_Digit;
VAR
   I, C1 : INTEGER;
BEGIN
     IF Code_Len <> LENGTH(LCode)+1  { If already there, assume ok }
     THEN EXIT;

     C1 := 0;
     FOR I := Seg_Size DOWNTO 1
     DO INC (C1,ORD(LCode[I*2-1])-$30);
     C1 := C1 * 3;
     FOR I := Seg_Size-1 DOWNTO 1
     DO INC (C1,ORD(LCode[I*2])-$30);

     LCode := LCode + CHR (((10-(C1 MOD 10)) MOD 10) +$30);
END;


PROCEDURE Guard (Which : Bar_Position);
VAR
   Dig : One_Dig;
BEGIN
     CASE Which OF
          Centre : Dig := '01010';
          ELSE     Dig := '101';
     END;
     Full_Code := Full_Code + Dig;
END;


FUNCTION DigA (Arg : EAN_13) : One_Dig;
VAR
   Dig : One_Dig;
   I   : INTEGER;
BEGIN
     FOR I := 1 TO LENGTH (Arg)
     DO BEGIN
        CASE Arg[I] OF
             '9' : Dig := '0001011';
             '8' : Dig := '0110111';
             '7' : Dig := '0111011';
             '6' : Dig := '0101111';
             '5' : Dig := '0110001';
             '4' : Dig := '0100011';
             '3' : Dig := '0111101';
             '2' : Dig := '0010011';
             '1' : Dig := '0011001';
             ELSE  Dig := '0001101';
        END;
        Full_Code := Full_Code + Dig;
     END;
END;


PROCEDURE DigB (Arg : EAN_13);
VAR
   Dig : One_Dig;
   I   : INTEGER;
BEGIN
     FOR I := 1 TO LENGTH (Arg)
     DO BEGIN
        CASE Arg[I] OF
             '9' : Dig := '0010111';
             '8' : Dig := '0001001';
             '7' : Dig := '0010001';
             '6' : Dig := '0111001';
             '5' : Dig := '0111001';
             '4' : Dig := '0011101';
             '3' : Dig := '0100001';
             '2' : Dig := '0011011';
             '1' : Dig := '0110011';
             ELSE  Dig := '0100111';
        END;
        Full_Code := Full_Code + Dig;
     END;
END;


PROCEDURE DigC (Arg : EAN_13);
VAR
   Dig : One_Dig;
   I   : INTEGER;
BEGIN
     FOR I := 1 TO LENGTH (Arg)
     DO BEGIN
        CASE Arg[I] OF
             '9' : Dig := '1110100';
             '8' : Dig := '1001000';
             '7' : Dig := '1000100';
             '6' : Dig := '1010000';
             '5' : Dig := '1001110';
             '4' : Dig := '1011100';
             '3' : Dig := '1000010';
             '2' : Dig := '1101100';
             '1' : Dig := '1100110';
             ELSE  Dig := '1110010';
        END;
        Full_Code := Full_Code + Dig;
     END;
END;


PROCEDURE Compose_Code;
BEGIN
     Full_Code := '';
     Guard (Left);
     DigA  (COPY(LCode,1,Seg_Size));
     Guard (Centre);
     DigC  (COPY(LCode,Seg_Size+1,Seg_Size*2));
     Guard (Right);
END;


PROCEDURE Init_Buffer;
BEGIN
     NEW (PBuffer);
     FILLCHAR (PBUffer^,SIZEOF(PBuffer^),#0);
     Posn := 0;

     CASE Typ OF
          Epson : BEGIN
                       Bytes    := 3*3; { 3 pixels x 24 pins }
                       Line_Len := 3*Bar_Len;
                       Mult     := 1;
                  END;
          Ibm   : BEGIN
                       Bytes    := 4;     { 4 pixels X 8 pins }
                       Line_Len := 4*Bar_Len;
                       Mult     := 1;
                  END;
          ELSE    BEGIN
                       Bytes    := 0;     { 5 pixels }
                       Line_Len := (5*Bar_Len +7) DIV 8;
                       Mult     := 37 * NLines;
                       NLines   := 1;
                  END;
     END;
END;


PROCEDURE Send_Preamble;
VAR
   St : STRING [20];
BEGIN
     IF NLines <> 1
     THEN BEGIN
          CASE Typ OF
               Epson : St := ESC+'0';
               Ibm   : St := ESC+'3'#24;
               ELSE    St := ESC+'&l8D';
          END;
          WRITE (Lst,St);
     END;
END;


PROCEDURE Send_Postamble;
BEGIN
     IF NLines <> 1
     THEN IF Typ = Laser
          THEN WRITE (Lst,ESC,'&l6D')
          ELSE WRITE (Lst,ESC,'2');
END;


PROCEDURE Send_Buffer;
VAR
   I : INTEGER;
BEGIN
     CASE Typ OF
          Epson : WRITE (Lst,ESC,'*'#$27,CHR(Line_Len MOD 256),CHR(Line_Len DIV 256));
          Ibm   : WRITE (Lst,ESC,'Z',CHR(Line_Len MOD 256),CHR(Line_Len DIV 256));
          ELSE    WRITE (Lst,ESC,'*t300R',ESC,'*r1A',ESC,'*b',Line_Len,'W');
     END;

     FOR I := 1 TO Posn
     DO WRITE (Lst,PBuffer^[I]);

     CASE Typ OF
          Laser : WRITE (Lst, ESC, '*rB');
     END;
END;


PROCEDURE Compose_Buffer;
VAR
   I   : INTEGER;
   Bar : CHAR;
   Blk,
   Spc : STRING [12];

PROCEDURE Add (St : STRING);
BEGIN
     MOVE (St[1],PBuffer^[Posn+1],LENGTH (St));
     INC (Posn,LENGTH (St));
END;

VAR
   Frag, Len : INTEGER;

PROCEDURE Add_Frag (B : BYTE);
BEGIN
     Frag := (Frag SHL 5) OR (B AND $1F);
     INC (Len,5);
     IF Len >= 8
     THEN BEGIN
          Add (CHR (Frag SHR (Len-8)));
          DEC (Len,8);
     END;
END;

PROCEDURE Add_Bar (Bar : CHAR);
BEGIN
     IF Typ = Laser        { 1-dot-line at a time }
     THEN BEGIN
          IF Bar = '0'
          THEN Add_Frag (0)
          ELSE Add_Frag ($1F);
     END
     ELSE BEGIN            { 8/24-dot-lines at a time }
          IF Bar = '0'
          THEN Add (Spc)
          ELSE Add (Blk);
     END;
END;

BEGIN
     Frag := 0;
     Len  := 0;

     Blk := '';             { Compose the unit stripes }
     Spc := '';
     FOR I := 1 TO Bytes
     DO BEGIN
        Blk := Blk + #$FF;
        Spc := Spc + #$00;
     END;

     FOR I := 1 TO LENGTH (Full_Code)  { Compose Bars }
     DO Add_Bar (Full_Code [I]);

     IF Typ = Laser
     THEN WHILE Posn < Line_Len
          DO Add_Bar ('0')
END;


VAR
   I,J : INTEGER;

BEGIN

     Rationalise_Code;
     Calc_Check_Digit;
     Compose_Code;
     Init_Buffer;
     Compose_Buffer;

     Send_Preamble;

     FOR I := 1 TO NLines
     DO BEGIN
        WRITE (Lst,'':PrnPosn);
        FOR J := 1 TO Mult
        DO BEGIN
           Send_Buffer;
        END;
        WRITELN (Lst);
     END;

     Send_Postamble;
     WRITELN (Lst,'':PrnPosn+2,LCode); WRITELN (Lst);
END;


END.

{ ----------------------    TEST PROGRAM  ---------------------------------- }

USES
    Crt, Barcode, Printer;


VAR
{  Lst : TEXT;}
   Ch  : CHAR;
   Typ : Printer_Type;

BEGIN
     WRITELN;
     WRITELN ('Bar Code Test');
     WRITELN;

     WRITE ('Select Printer Type (E=Epson, I=IbmPro, L=HPLaser) ');

     Ch := UPCASE (READKEY);

     CASE Ch OF
          'L' : Typ := Laser;
          'I' : Typ := Ibm;
          'E' : Typ := Epson;
          ELSE EXIT;
     END;

{    ASSIGN (Lst,'TEST');
     REWRITE (Lst);}

     Print_BarCode (Lst,Typ,'1234567',    1);
     Print_BarCode (Lst,Typ, '9876543',   1);
     Print_BarCode (Lst,Typ,'12345678901',1);

     Print_BarCode (Lst,Typ,'1234567',    2);
     Print_BarCode (Lst,Typ, '9876543',   2);
     Print_BarCode (Lst,Typ,'12345678901',2);

     WRITE (Lst,#$0C);

{    CLOSE (Lst);}
END.


