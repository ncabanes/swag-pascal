
Program Fade;         { Fades to Black, Clears the screen and restores palet }

Uses Crt, DOS;

Const SizeOfPal = 255;    { Size of palette to be altered...255 works in all}
      UpLim     = Sizeofpal + 1; { <256 cols modes. }

Type Pal = Record
             Red, Green, Blue : Byte; { Red, Green and Blue Colour Registers }
           End;
  FullPal = Record
              Data : Array [0..SizeOfPal] Of Pal;
            End;                          { This is basically a full palette }

Procedure GetPalette (Var Hello : Fullpal);    { Returns the current Palette }
  { uses BIOS }
Var Regs: Registers;
Begin
  With Regs Do
  Begin
    AX := $1017;      { Get Block Of Color Registers }
    BX := 0;          { First Colour register to be changed is 0 - black }
    CX := Uplim;      { Change <UpLim> registers }
    ES := Seg (Hello);{ Segment address of Hello }
    DX := Ofs (Hello);{ Offset address of Hello -> DX }
  End;
  Intr ($10, Regs);   { Call video interrupt (get palette -> Hello) } End; {GetPalette }
Procedure WritePalette (Var Hello : Fullpal);
    { Writes to screen passed palette }
Var Regs: Registers;
Begin
  With Regs Do
  Begin
    ES := Seg (Hello);
    AX := $1012; { Write block of color registers }
    BX := 0;     { Everything else is basically the same as GetPallette }
    CX := Uplim;
    DX := Ofs (Hello);
  End;
  Intr ($10, Regs);
End; { WritePalette }

Procedure Sync;
Var CRTC : Word;
Begin
  CRTC := Memw [$40:$63];  { get CRTC address }
  If CRTC <> 0 Then        { in case no video controller/fn not supported }
  Begin
    CRTC := CRTC + 6; { set address to register including retrace signal. }
    Repeat Until (port [crtc] And 8) = 0;
    Repeat Until (port [crtc] And 8) = 8;
  End;
End;

Var
  Saved, Nyar  : Fullpal;
  C, Q         : Byte;
  Cls          : String;
  Regs         : Registers;

Begin
  GetPalette (Saved);
  Move (Saved, Nyar, SizeOf (Fullpal) );

  For Q := 63 Downto 1 Do Begin
    For C := 0 To SizeOfPal Do Begin
      With Nyar. Data [c] Do Begin
        Dec (Red);    If Red   > 63 Then Red   := 0;
        Dec (Green);  If Green > 63 Then Green := 0;
        Dec (Blue);   If Blue  > 63 Then Blue  := 0;
      End; { With Nyar.Data[c] }
    End; { For C := 0 To SizeOfPal }
    Sync;
    WritePalette (Nyar);
  End; { For Q:=63 DownTo 1 }

  Cls := '`[40m';

  With Regs do
    Begin
    AH := $40;        { Write to DOS File Handle }
    BX := 1;          { Standard Output }
    CX := 5;          { 5 bytes }
    DS := Seg(Cls);   { Segment of CLS }
    DX := ofs(Cls);   { Offset of CLS[1] }
    End;
  MSDos(Regs);
  TextAttr := TextAttr And 15;
  ClrScr;
  With Regs do
    Begin
    AX := $1001;
    BH := 0;
    End;
  Intr($10,Regs);
  Writepalette (Saved);
End.
