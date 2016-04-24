(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0038.PAS
  Description: Text Fader
  Author: RON CZARNIK
  Date: 05-28-93  13:39
*)

{ RON CZARNIK }

Unit TXTFADE;

Interface

Procedure TextFadeIn(Speed : Integer);
Procedure TextFadeOut(Speed : Integer);

Implementation
Uses
  Dos, Crt;

Type
  DacType = Array[1..256,1..3] of Byte;

Var
  dac1,
  dac2   : DacType;
  x, y,
  i, erg,
  gesamt : Word;


Procedure Read_DACs(Var Dac : DacType);
Var
  r : Registers;
begin
  r.ax := $1017;
  r.bx := 0;
  r.cx := 256;
  r.es := SEG(Dac);
  r.dx := Ofs(Dac);
  Intr($10, r);
end;

Procedure Write_DACs(Dac : DacType);
Var
  r : Registers;
begin
 r.ax := $1012;
 r.bx := 0;
 r.cx := 256;
 r.es := seg(Dac);
 r.dx := Ofs(Dac);
 Intr($10, r);
end;

{ fade....}
Procedure TextFadeOut(Speed : Integer);
begin;
  Repeat
    erg := 0;
    For x := 1 to 256 do
      For y := 1 to 3 do
      begin
        if dac2[x, y] > 0 then
          DEC(dac2[x, y]);
        erg := erg + dac2[x, y];
      end;
    Write_Dacs(dac2);
    Delay(Speed);
  Until erg = 0;
end;

{ restore....fades also}
Procedure TextFadeIn(Speed : Integer);
begin;
  Repeat
    erg := 0;
    For x := 1 to 256 do
      For y := 1 to 3 do
      begin
       if dac2[x, y] < dac1[x, y] then
         INC(dac2[x,y]);
       erg := erg + dac2[x, y];
      end;
    Write_Dacs(dac2);
    Delay(Speed);
  Until (erg = gesamt) or (KeyPressed);
  Write_Dacs(dac1);
end;

begin
  Read_Dacs(dac1);
  dac2 := dac1;
  gesamt := 0;
  For x := 1 to 256 do
    For y := 1 to 3 do
      gesamt := gesamt + dac1[x, y];

end.

