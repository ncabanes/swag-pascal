(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0045.PAS
  Description: Send  graphics images to Epson
  Author: SWAG SUPPORT TEAM
  Date: 05-27-95  10:33
*)


{
433: PRINTING GRAPHICS TO AN EPSON COMPATIBLE PRINTER
   Pascal   All       TI-09/30/94


Printing Graphics to a Epson compatible printer.  Printing your graphic
screens created with the BGI Graphics format to Epson compatible printers.

  PRODUCT  :  Pascal                                 NUMBER  :  433
  VERSION  :  All
       OS  :  DOS
     DATE  :  September 30, 1994                       PAGE  :  1/1

    TITLE  :  PRINTING GRAPHICS TO AN EPSON COMPATIBLE PRINTER
 }
{ The  following example routines are public domain programs }

{ that have  been uploaded to our Forum on CompuServe.  As a }
{ courtesy to our users that  do not have  immediate  access }
{ to  CompuServe,  Technical   Support   distributes   these }
{ routines free of charge.                                   }
{                                                            }
{ However, because these routines are public domain programs,}
{ not developed  by Borland International,  we are unable to }
{ provide any  Technical  Support or  assistance using these }

{ routines. If you need assistance  using  these   routines, }
{ or   are   experiencing difficulties,  we  recommend  that }
{ you log onto CompuServe  and request  assistance  from the }
{ Forum members that developed  these routines.              }

Unit GraphPRN;

{ This  unit is  designed to send  graphics images  to Epson }
{ Compatible  and  late  model  IBM  ProPrinter  Dot  Matrix }
{ printers.  It takes the  image from  the currently  active }
{ Viewport, determined  by  a call  to  GetViewSettings, and }

{ transfers that image to the printer.                       }

Interface

Uses Dos, Graph;     { Used to get the Image from the Screen }

Var
   LST : Text;

Procedure HardCopy (Gmode: Integer);
{ Procedure HardCopy prints the current ViewPort    }
{   To an IBM or Epson compatible graphics printer. }
{                                                   }
{ Valid Gmode numbers are :                         }
{     -4 to -1 for Epson and IBM Graphic Printers   }

{      0 to 7  for Epson Printers                   }

Implementation

Procedure HardCopy {Gmode: Integer};

Const
   Bits : Array [0..7] of Byte = (128,64,32,16,8,4,2,1);


Var
    X,Y,YOfs        : Integer;   { Screen  location variables }
    BitData,MaxBits : Byte;      { Number of Bits to transfer }
    Vport           : ViewPortType;{Used to get view settings }
    Height, Width   : Word;      { Size of image  to transfer }
    HiBit, LoBit    : Char;      {     Char size of image     }

    LineSpacing,                 { Additional  Info for  dump }
    GraphixPrefix   : String[10];{      "        "   "     "  }

Begin
  LineSpacing   := #27+'3'+#24; { 24/216 inch line spacing    }
  Case Gmode Of
       -1: GraphixPrefix := #27+'K'; { Std. Density           }
       -2: GraphixPrefix := #27+'L'; { Double Density         }
       -3: GraphixPrefix := #27+'Y'; { Dbl. Density Dbl. Speed}
       -4: GraphixPrefix := #27+'Z'; { Quad. Density          }

     0..7: GraphixPrefix := #27+'*'+Chr(Gmode);{ 8-Pin Bit Img}
    Else
     Exit;                           { Invalid Mode Selection }
  End;
  GetViewSettings( Vport );          { Get  size  of image to }
  Height := Vport.Y2 - Vport.Y1;     { be printed             }
  Width  := ( Vport.X2 + 1 ) - Vport.X1;
  HiBit := Chr(Hi(Width));           {Translate sizes to char }
  LoBit := Chr(Lo(Width));           { for  output to printer }
  Write( LST, LineSpacing );

  Y := 0;
  While Y < Height Do
  Begin
     Write( LST,GraphixPrefix,LoBit,HiBit );
     For X := 0 to Width-1 Do
     Begin
        BitData := 0;
        If y + 7 <= Height
          Then MaxBits := 7
        Else
          MaxBits := Height - Y;
        For YOfs := 0 to MaxBits do
        Begin
         If GetPixel( X, YOfs+Y ) > 0
           Then BitData := BitData or Bits[YOfs];
        End;
        Write( LST, Chr(BitData) );
     End;
     WriteLn ( LST );

     Inc(Y,8);
  End;
End;

{$F+}

{      LSTNoFunction performs a NUL operation for a Reset or  }
{ Rewrite on LST (Just in case)                               }

Function LSTNoFunction( Var F: TextRec ): integer;
Begin
  LSTNoFunction := 0;                    { No error           }
end;

{      LSTOutputToPrinter sends the output to the Printer     }
{ port number stored in the first byte of the UserData area   }
{ of the Text Record.                                         }


Function LSTOutputToPrinter( Var F: TextRec ): integer;
var
  Regs: Registers;
  P : word;
begin
  With F do
  Begin
    P := 0;
    Regs.AH := 16;
    While (P < BufPos) and ((regs.ah and 16) = 16) do
    Begin
      Regs.AL := Ord(BufPtr^[P]);
      Regs.AH := 0;
      Regs.DX := UserData[1];
      Intr($17,Regs);
      Inc(P);
    end;
    BufPos := 0;
  End;
  if (Regs.AH and 16) = 16 then
    LSTOutputToPrinter := 0              { No error           }

   else
     if (Regs.AH and 32 ) = 32 then
       LSTOutputToPrinter := 159         { Out of Paper       }
   else
       LSTOutputToPrinter := 160;        { Device write Fault }
End;

{$F-}

{      AssignLST both sets up the LST text file record as     }
{ would ASSIGN, and initializes it as would a RESET.  It also }
{ stores the Port number in the first Byte of the UserData    }
{ area.                                                       }

Procedure AssignLST( Port:Byte );

Begin
  With TextRec(LST) do
    begin
      Handle      := $FFF0;
      Mode        := fmOutput;
      BufSize     := SizeOf(Buffer);
      BufPtr      := @Buffer;
      BufPos      := 0;
      OpenFunc    := @LSTNoFunction;
      InOutFunc   := @LSTOutputToPrinter;
      FlushFunc   := @LSTOutputToPrinter;
      CloseFunc   := @LSTOutputToPrinter;
      UserData[1] := Port - 1;  { We subtract one because }
  end;                          { Dos Counts from zero.   }

end;



Begin
   AssignLST( 1 );           { Sets output printer to LPT1 by }
                             { default.  Change this value to }
                             { a 2 to select LPT2.            }
End.                         { Note: BIOS only handles LPT1   }
                                            {      and      LPT2.
}


DISCLAIMER: You have the right to use this technical information
subject to the terms of the No-Nonsense License Statement that

you received with the Borland product to which this information
pertains.
PACHXA296:PACHXA296


