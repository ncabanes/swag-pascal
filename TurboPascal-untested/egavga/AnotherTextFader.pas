(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0013.PAS
  Description: Another text fader
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
>I have a copy of the fade Unit and am having problems getting it to work
>correctly. I want to fade my Programs screen on Exit, clear it, and show
>the Dos screen.

Here's a little fade source, there're some change to made if you're using it in
Graphic or Text mode.
}

Uses
  Crt;


Var
  count1, count2 : Integer;
  pal1,pal2 : Array[0..255,0..2] of Byte;


begin

  For count1 := 0 to 255 do           {Get the current palette}
  begin
    Port[$03C7] := count1;
    pal1[count1,0] := Port[$03C9];
    pal1[count1,1] := Port[$03C9];
    pal1[count1,2] := Port[$03C9];
  end;

  Pal2:=Pal1;

  For Count1 := 1 to 255 do           {this will fade the entire palette}
  begin                               {20 must be enough in Text mode}
    For Count2 := 0 to 255 do
    begin
      If Pal2[Count2,0] > 0 then
        Dec(Pal2[Count2,0]);
      If Pal2[Count2,1] > 0 then
        Dec(Pal2[Count2,1]);
      If Pal2[Count2,2] > 0 then
        Dec(Pal2[Count2,2]);
      Port[$03C8] := Count2;
      Port[$03C9] := Pal2[Count2,0];
      Port[$03C9] := Pal2[Count2,1];
      Port[$03C9] := Pal2[Count2,2];
    end;
    Delay(40);         {Change the Delay For a quicker or slower fade}
  end;

  For Count1 := 0 to 255 do   {Restore Original palette}
  begin
    Port[$03C8] := Count1;
    Port[$03C9] := Pal1[Count1,0];
    Port[$03C9] := Pal1[Count1,1];
    Port[$03C9] := Pal1[Count1,2];
  end;

end.


