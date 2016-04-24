(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0114.PAS
  Description: Set Border Colors
  Author: PATRICK ROBERTS
  Date: 08-24-94  13:31
*)


program Demo_4_SWAG;
var
  old_border : integer; { used in main body of program }
  Rnd_border : integer;

(****************************************************************************)
procedure Set_Border(color:byte); { Written by Pat Roberts 1994 }
begin
 asm
  mov ah,10h     { This subroutine sets the color value stored in the }
  mov al,01h     { overscan register of the current palette from the }
  mov BH,Color   { Bios thru int 10h . Assumes EGA\VGA }
  int 10h
 end;
end;

(****************************************************************************)
function Get_Border:byte; { Written by Pat Roberts 1994 }
begin
 asm
  mov ah,10h      { This subroutine reads the color value stored in the }
  mov al,08h      { overscan register of the current palette from the }
  int 10h         { Bios thru int 10h. Assumes EGA\VGA }
  mov @result,bH  { result is byte(BL) not a integer(BX) }
 end;
end;

(******************************Main******************************************)
begin
 Randomize;
 old_border := get_border;
 writeln(' Old border color was ',old_border);
 Rnd_border := ((random(7)+1));
 set_border(rnd_border);
 writeln(' Get_Border reports color ',get_border); readln; end.
end.

