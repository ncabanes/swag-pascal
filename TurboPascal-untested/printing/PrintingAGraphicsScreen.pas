(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0052.PAS
  Description: Printing a graphics screen
  Author: NICO DESMEDT
  Date: 05-31-96  09:16
*)

{
> > I've got some source (a unit) for printing a graphic screen on a HP and
> > Epson compatibles. If youre printer can emulate these 2 printers than
> > you can use this. There are maybe some other folks interested in the
> > source. Just ask for it, i'll send it to you the other day (only in the
> > week, not on weekends).

{----------------BEGIN OF PASCAL SOURCE---------------------------------}

UNIT GRPRINT;

INTERFACE

Uses CRT,DOS,GRAPH;

Type PrinterTypen = (HP,EPSON);

Const PrinterType: PrinterTypen = HP;

Var PRN: Text;

Procedure DrukVenster(AchterGrondKleur,DichtHeid: Word);
{;Procedure PrintScreen(BackColor,Resolution: Word); (translated)}

IMPLEMENTATION

Const ESC = #27;

Var   AKleur,Breedte,Hoogte: Word;
      ViewPort: ViewportType;
      Intro: String[10];

Function NulFunctie(Rec: TextRec): Integer; FAR;
Begin
  NulFunctie := 0;
end;

Function UitVoerNaarPrinter(VAR Rec: TextRec): Integer; FAR;
Var Regs: Registers;
    Wijzer: Word;

Begin
  With Rec do
    Begin
      Wijzer := 0;
      Regs.AH := 16;
      While (Wijzer < BufPos) and (Regs.AH and 16 = 16) do
        Begin
          Regs.AH := 0;
          Regs.AL := Ord(BufPtr^[Wijzer]);
          Regs.DX := UserData[1];
          Intr($17,Regs);
          INC(Wijzer);
        end; { WHILE }
      BufPos := 0;
      If Regs.AH and 16 = 16 then
         UitVoerNaarPrinter := 0
      Else
         If Regs.AH and 32 = 32 then
            UitVoerNaarPrinter := 159
         Else
            UitVoerNaarPrinter := 160;
    end; { WITH }
end;

Procedure InitHP(DichtHeid: Integer);
Const CursorPositie: String = '5';
Var PuntenPerInch: String[3];

 Begin
   Case DichtHeid of
     1: PuntenPerInch := '75';
     2: PuntenPerInch := '100';
     3: PuntenPerInch := '150';
     4: PuntenPerInch := '300';
     Else PuntenPerInch := '100';
   end; { CASE }
   Write(PRN,ESC+'E');
   Write(PRN,ESC+'*t'+PuntenPerInch+'R');
   Write(PRN,ESC+'&a'+CursorPositie+'C');
   Write(PRN,ESC+'*r1A');
 end;

 Procedure InitEpson(DichtHeid: Integer);
 Var RegelAfstand: String[10];
 Begin
   RegelAfstand := #27+'3'+#24;
   Case DichtHeid of
     1: Intro := #27+'K';
     2: Intro := #27+'L';
     3: Intro := #27+'Y';
     4: Intro := #27+'Z';
     Else Intro := #27+'L';
   end; { CASE }
   Write(PRN,RegelAfStand);
 end;

 Procedure SluitHp;
 Begin
   Write(PRN,ESC+'*rB');
   Write(PRN,ESC+'E');
 end;

 Procedure SluitEpson;
 Begin
   Write(PRN,#12);
   Write(PRN,#27+'@');
 end;

 Procedure HPAfdruk(DichtHeid: Word);
 Var RegelLengte: String[2];
     i: Integer;

 Procedure PuntenLijn(Y: Word);
 Var Regel: String;
     Basis: Word;
     BitNr,ByteNr,DataByte: Byte;
     Kleur: Word;

 Begin
   Regel := Intro;
   For ByteNr := 0 to Breedte do
     Begin
       DataByte := 0;
       Basis := 8 * ByteNr;
       For BitNr := 0 to 7 do
         Begin
           Kleur := GetPixel(BitNr+Basis,Y);
           If Kleur <> AKleur then
              DataByte := DataByte + 128 SHR BitNr;
         end; { FOR }
       Regel := Regel + Chr(DataByte);
     end; { FOR }
   Write(PRN,Regel);
 end;

 Begin { HPAfdruk }
   GetViewSettings(ViewPort);
   With ViewPort do
     Begin
       Breedte := (X2+1)-X1;
       Hoogte := (Breedte-7) div 8;
     end; { WITH }
   Str(Breedte+1,RegelLengte);
   Intro := ESC+'*b'+RegelLengte+'W';
   InitHp(DichtHeid);
   For i := 0 to Hoogte +1 do
     PuntenLijn(i);
   SluitHp;
 end;

 Procedure EpAfdruk(DichtHeid: Word);
 Var X,Y,YOfs: Integer;
     BitGegevens,Bits: Byte;
     Kleur: Byte;

 Begin
   GetViewSettings(ViewPort);
   With ViewPort do
     Begin
       Hoogte := Y2-Y1;
       Breedte := X2+1-X1;
     end; { WITH }
   InitEpson(DichtHeid);
   Y := 0;
   While Y < Hoogte do
     Begin
       Write(PRN,Intro,Chr(Lo(Breedte)),Chr(Hi(Breedte)));
       For X := 0 to Breedte - 1 do
         Begin
           BitGegevens := 0;
           If Y + 7 <= Hoogte then
              Bits := 7
           Else
              Bits := Hoogte - Y;
           For YOfs := 0 to Bits do
             Begin
               Kleur := GetPixel(X,YOfs+Y);
               If Kleur <> AKleur then
                  BitGegevens := BitGegevens + 128 SHR YOfs;
             end; { FOR }
           Write(PRN,Chr(BitGegevens));
         end; { FOR }
       Writeln(PRN);
       INC(Y,8);
     end; { WHILE }
   SluitEpson;
 end;

 Procedure DrukVenster(AchterGrondKleur,DichtHeid: Word);
 Begin
   AKleur := AchterGrondKleur;
   CASE PrinterType of
     HP:    HPAfdruk(DichtHeid);
     EPSON: EpAfdruk(DichtHeid);
   end; { CASE }
 end;

 Begin { GrPrint }
   With TextRec(PRN) do
     Begin
       Mode := FmOutPut;
       BufSize := SizeOf(Buffer);
       BufPtr := @Buffer;
       BufPos := 0;
       OpenFunc := @NulFunctie;
       InOutFunc := @UitVoerNaarPrinter;
       FlushFunc := @UitVoerNaarPrinter;
       CloseFunc := @UitVoerNaarPrinter;
       UserData[1] := 0;
     end; { WITH }
 end.

 ------------------END OF PASCAL SOURCE-----------------------------

First set PrinterType to HP or EPSON, then call 'DrukVenster' with the
backgroundcolor and resolution. This routine prints the current viewport.

