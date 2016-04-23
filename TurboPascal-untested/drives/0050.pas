{
MAYNARD PHILBROOK

> How can I look With a pascal-Program(I have TP7.0)in the boot-sector
> of a disk and change them?
}

Uses
  Dos;

Var
 Sector : Array [1..512] of Byte;
 Regs   : Registers;

Function Read_Boot_Sector(Var Drive : Byte) : Boolean;
begin
  With Regs do
  begin
    AH := $02;      { Function Number Read_Sector }
    AL := 1;        { Number of Sectors to Read }
    CH := 1;        { Cylender Number, Upper 2  Bits used For HD }
    CL := 0;        { Bios use Zero base Numbers here }
    DH := 0;        { Head Number or Side 0 = side 1 }
    DL := Drive;    { 0 = A:, 1 := B: Floppys, Add $80 For Fisk Disk }
    ES := Seg(Sector);  { Pass the Address of Buffer }
    BX := Ofs(Sector);
    Intr($13, Regs);    { Call Bios Int ); }
    if Flags and $01 <> 0 Then
      Read_Boot_Sector := False
    else
      Read_Boot_Sector := True;
  end;
end;

begin
  if Read_Boot_Sector(0) Then
    WriteLn(' Got it ')
  else
    WriteLn(' Disk Error in reading ');
end.
