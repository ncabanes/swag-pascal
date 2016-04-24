(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0020.PAS
  Description: Another NICE fader
  Author: CHRIS BEISEL
  Date: 05-28-93  13:39
*)

{
CHRIS BEISEL

Hey Terje, here's some stuff to get you started on some ideas For the
group.  I threw it together it 3 minutes, so it's not much, but the
assembley code isn't bad... here it is:
}

Program palette;

Uses
  Crt;

Const
  vga_segment = $0A000;
  fade_Delay  = 20;

Var
  lcv  : Integer;
  temp : Char;

Procedure video_mode (mode : Byte); Assembler;
Asm
  mov  AH,00
  mov  AL,mode
  int  10h
end;

Procedure set_color (color, red, green, blue : Byte);
begin
  port[$3C8] := color;
  port[$3C9] := red;
  port[$3C9] := green;
  port[$3C9] := blue;
end;

Procedure wait_4_refresh; Assembler;
Label
  wait, retr;
Asm
  mov  DX,3DAh
 wait:  in   AL,DX
  test AL,08h
  jz   wait
 retr:  in   AL,DX
  test AL,08h
  jnz  retr
end;

begin
  ClrScr;
  Writeln('Hey Terje, this is pretty cheezy, but it does show how to wait');
  Writeln('for the vertical screen refresh in assembley, as well as how to');
  Writeln('change colors, too... this isn''t the palette scrolling, but some');
  Writeln('fade Type routines that may come in handy.  The video mode routine');
  Writeln('was also written in assembley (obviously)... well, next I''m going');
  Writeln('to work on zooming (It could be a cool effect).  C''ya L8r. ');
  Writeln(' Press a key...');
  temp := ReadKey;
  video_mode($13);
  lcv := 0;
  Repeat
    While lcv < 63 do
    begin
      wait_4_refresh;
      set_color(0, lcv, lcv, lcv);
      lcv := lcv + 1;
      Delay(fade_Delay);
    end;
    While lcv > 0 do
    begin
      wait_4_refresh;
      set_color(0, lcv, lcv, lcv);
      lcv := lcv - 1;
      Delay(fade_Delay);
    end;
  Until KeyPressed;
  video_mode(3);
end.


