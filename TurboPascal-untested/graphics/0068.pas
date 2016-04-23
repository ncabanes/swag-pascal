UNIT GrStuff;       {  Misc Graphic Functions, Last Updated  Nov 11/93 }
                    {  Copyright (C), Greg Estabrooks, 1993            }

INTERFACE
(***********************************************************************)

FUNCTION MonitorType :BYTE;               {  Determines Monitor In Use  }
PROCEDURE SetVidMode( Mode :BYTE );       {  Set video mode             }
PROCEDURE SetPage( Page :BYTE );          {  Set current screen page    }
PROCEDURE BiosPutPix( Col,Page :BYTE;X,Y :WORD ); { Plot pixel at X,Y   }
FUNCTION TSeng :BOOLEAN;        {  Determine if graph card a TSENG labs }
FUNCTION GetVideoMode :BYTE;
                      {  Routine to determine current video mode        }
PROCEDURE Set80x30Mode;
PROCEDURE DrawBar( X1,Y1,X2,Y2 :WORD; Color :BYTE );
PROCEDURE SetColor( Color2Set, Red, Green, Blue :BYTE );
PROCEDURE GetColor( Color2Get :BYTE; VAR Red,Green,Blue :BYTE );

IMPLEMENTATION
(***********************************************************************)
FUNCTION MonitorType :BYTE; ASSEMBLER;
                           {  Determines Type of Monitor In Use.        }
ASM
  Mov AH,$1A                    {  Function Determine Display Code      }
  Mov AL,0                      {  AL,0 = Read Code  AL,1 = Set Code    }
  Int $10                       {  Call Dos                             }
  Mov AL,BL;                    {  Move result to proper register       }
        {  0 - no Display       4 - Ega Standard Color     7 - VGA MONO }
        {  1 - MDA              5 - Ega MonoChrome         8 - VGA      }
        {  2 - CGA              6 - PGA                                 }
END;{MonitorType}

PROCEDURE SetVidMode( Mode :BYTE ); ASSEMBLER;
                {  Routine to set video mode                            }
ASM
  Mov AH,00                     {  Function to set mode                 }
  Mov AL,Mode                   {  Mode to change to                    }
  Int $10                       {  Call dos                             }
END;{SetVidMode}

PROCEDURE SetPage( Page :BYTE ); ASSEMBLER;
                {  Routine to change screen pages                       }
ASM
  Mov AH,$05                    {  Function to change pages             }
  Mov AL,Page                   {  Page to change to                    }
  Int $10                       {  Call dos                             }
END;{SetPage}

PROCEDURE BiosPutPix( Col,Page :BYTE; X,Y :WORD ); ASSEMBLER;
                {  Routine to plot a pixel on the screen using INT 10h. }
ASM
  Mov AH,$0C                    {  Function to plot a pixel             }
  Mov AL,Col                    {  Color to make it                     }
  Mov BH,Page;                  {  Page to write it to                  }
  Mov CX,X                      {  Column to put it at                  }
  Mov DX,Y                      {  Row to place it                      }
  Int $10                       {  call dos                             }
END;{BiosPutPix}

FUNCTION TSeng :BOOLEAN;
                {  Routine to determine if Graphics card is a TSENG labs}
VAR
        Old,New :BYTE;
BEGIN
  Old := Port[$3CD];            {  Save original card register value    }
  Port[$3CD] := $55;            {  change it                            }
  New := Port[$3CD];            {  read in new value                    }
  Port[$3CD] := Old;            {  restore old value                    }
  TSENG := ( New = $55 );       {  if value same as what we sent (TRUE) }
END;

FUNCTION GetVideoMode :BYTE; ASSEMBLER;
                      {  Routine to determine current video mode        }
ASM
  Mov AX,$0F00                  {  SubFunction Return Video Info        }
  Int $10                       {  Call Dos                             }
END;{GetVideoMode}

PROCEDURE Set80x30Mode;
VAR CrtcReg:ARRAY[1..8] OF WORD;
    Offset :WORD;
    I,Data :BYTE;
BEGIN
  CrtcReg[1]:=$0C11;           {Vertical Display End (unprotect regs. 0-7)}
  CrtcReg[2]:=$0D06;           {Vertical Total}
  CrtcReg[3]:=$3E07;           {Overflow}
  CrtcReg[4]:=$EA10;           {Vertical Retrace Start}
  CrtcReg[5]:=$8C11;           {Vertical Retrace End (& protect regs. 0-7)}
  CrtcReg[6]:=$DF12;           {Vertical Display Enable End}
  CrtcReg[7]:=$E715;           {Start Vertical Blanking}
  CrtcReg[8]:=$0616;           {End Vertical Blanking}

  MemW[$0040:$004C]:=8192;     {Change page size in bytes}
  Mem[$0040:$0084]:=29;        {Change page length}
  Offset:=MemW[$0040:$0063];   {Base of CRTRC}
  ASM
    Cli                        {Clear Interrupts}
  END;

  FOR I:=1 TO 8 DO
    PortW[Offset]:=CrtcReg[i]; {Load Registers}

  Data:=PORT[$03CC];
  Data:=Data AND $33;
  Data:=Data OR $C4;
  PORT[$03c2]:=Data;
  ASM
   Sti                         {Set Interrupts}
   Mov AH,12h                  {Select alternate printing routine}
   Mov BL,20h
   Int 10h
  END;
END; {Of Procedure}

PROCEDURE DrawBar( X1,Y1,X2,Y2 :WORD; Color :BYTE );
                   { Bar drawing routine. Specifically set up for mode  }
                   { 13h. Much faster than the BGI one.                 }
VAR
   Row     :WORD;
BEGIN
  FOR Row := Y1 TO Y2 DO
    FillChar(MEM[$A000:(320*Row)+X1],X2-X1,Color);
END;


PROCEDURE SetColor( Color2Set, Red, Green, Blue :BYTE );
                    { Routine to Change the palette value of Color2Set. }
BEGIN
    PORT[$3C8] := Color2Set;
    PORT[$3C9] := Red;
    PORT[$3C9] := Green;
    PORT[$3C9] := Blue;
END;

PROCEDURE GetColor( Color2Get :BYTE; VAR Red,Green,Blue :BYTE );
                    { Routine to determine the Palette value of Color2Get}
BEGIN
    PORT[$3C8] := Color2Get;
    Red := PORT[$3C9];
    Green := PORT[$3C9];
    Blue := PORT[$3C9];
END;

BEGIN
END.
