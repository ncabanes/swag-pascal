(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0070.PAS
  Description: VGA Palette Setting!
  Author: ERIC MILLER
  Date: 08-25-94  09:10
*)

{
From: mysticm@ephsa.sat.tx.us (Eric Miller)

> first everything seemed to work out fine. Then I noticed that only
> palettes 0 (black) to 8 (white) changed OUTCLUDING palette 7 (brown).
> Colors beyond 8 (-> 15) didn't change.
>  So where's the problem? Have I understood something wrong?
>  All help will be _grrrrreatly_ appreciated!!!!

  No, you're just uninformed.  On VGA+ cards, you have to
256 palette entries.  In 16 color text mode, the first sixteen
of these entries aren't mapped to the 16 attributes like you
would expect.  The latter half are mapped down aways,
attribute 15 being palette 63, for example.  I wonder if this
is some offset from EGA days...looks like it.

 Anyways, here is some code to help...you have to get a
table from the video bios that gives you the 16 palette numbers
for the text attributes, and the palette number for the border color.
}
PROGRAM Text_Fade;
{$G+ , $N+ }
Uses Crt, Dos;
 
TYPE
  TDacTable = array[0..16] of Byte;
  { 0..15 - dac registers for text palette }
  {    16 - border register ?              }
 
VAR
  DacTable: TDacTable;
  CRTAddress, StatusReg: word;
 
PROCEDURE InitDAC(VAR T: TDacTable);
VAR
  Regs: Registers;
BEGIN
  Regs.AX := $1009;
  Intr($10, Regs);
  T := TDacTable(Ptr(Regs.ES, Regs.DX)^);
END;
 
PROCEDURE waitvsync; assembler;
ASM
  MOV DX,StatusReg
 
    @WaitNotVSyncLoop:
    in   al,dx
    and  al,8
    jnz  @WaitNotVSyncLoop
  @WaitVSyncLoop:
    in   al,dx
    and  al,8
    jz   @WaitVSyncLoop
end;
 
PROCEDURE SetTextColor(C, R, G, B: Byte;
                       T: TDacTable);
BEGIN
  C := DacTable[C];
  ASM
    MOV DX, 968
    MOV AL, C
    OUT DX, AL
    INC DX
    MOV AL, R
    OUT DX, AL
    MOV AL, G
    OUT DX, AL
    MOV AL, B
    OUT DX, AL
  END;
END;
 
 
PROCEDURE SetVGA3(C, R, G, B: Byte);
BEGIN
  C := DacTable[C];
  Port[968] := C;
  Port[969]  := R; Port[969] := G; Port[969] := B;
END;
 
VAR V, C: byte;

     
 
BEGIN
 
 IF ODD(port[$3CC])
  THEN CRTAddress:=$3D4
  ELSE CRTAddress:=$3B4;
 StatusReg:=CRTAddress+6;
 
 InitDac(DacTable);
 TextAttr := $07;
 ClrScr;
 
 TextAttr := $17;
 Writeln('Funky VGA palette setting, dood!');
 TextAttr := $71;
 Writeln('Funky VGA palette setting, dood!');
 
 WHILE NOT Keypressed DO
 BEGIN
 FOR V := 63 DOWNTO 0 DO
   BEGIN
     SetTextColor(1, V, 63-V, V, DacTable);
     SetTextColor(7, 63-V, V, 63-V, DacTable);
     IF V MOD 2 = 0 THEN waitvsync;
   END;
 FOR V := 0 TO 63 DO
   BEGIN
     SetVGA3(1, V, 63-V, V);
     SetVGA3(7, 63-V, V, 63-V);
     IF V MOD 2 = 0 THEN waitvsync;
   END;
 end;

 WHILE Readkey <> #13 DO;
  textmode(lastmode);
END.


