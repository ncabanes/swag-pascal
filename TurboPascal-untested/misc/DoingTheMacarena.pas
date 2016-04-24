(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0201.PAS
  Description: Doing the Macarena
  Author: JONAS EMIL M. ENRIQUEZ
  Date: 05-30-97  18:17
*)


program Macarena;
{
 Programmed by: Jonas Emil M. Enriquez (jeme@gsilink.com)
 Based from the text graphics of Buhrnheim (buhrn@DADOSNET.COM.BR)
}
uses crt,dos;
type STR03 = STRING[3];
const Dance : array[1..3,1..16] of STR03 =
    ((' o ', ' o ', ' o ', ' o ', ' o ', ' o ', '<o ', '<o>', ' o>', ' o ', ' o ', ' o ', ' o ', ' o ', ' o ', ' o '),
     ('^|\', '^|^', 'v|^', 'v|v', '|/v', '|X|', ' \|', ' | ', ' \ ', ' x ', '</ ', '<|>', '</>', '<\>', '<)>', ' |\'),
     (' /\', ' >\', '/< ', ' >\', '/< ', ' >\', '/< ', ' >\', '/< ', ' >\', '/< ', ' >\', '/< ', ' >\', ' >>', ' L '));

var x : byte;
    Reg : registers;

procedure Norm_Cursor;
  begin
    Reg.AH := $01;
    Reg.CH := $06;
    Reg.CL := $07;
    intr($10, Dos.registers(Reg));
  end;

procedure Cursor_Off;
  begin
    Reg.AH := $01;
    Reg.CH := $0F;
    Reg.CL := $00;
    intr($10, Dos.registers(Reg));
  end;

begin
  Clrscr;
  Cursor_Off;
  GotoXY(27,14); Write('Mr. Ascii dancing Macarena...');
  repeat
    x := 1;
    repeat
      GotoXY(39,10); Write(Dance[1,x]);
      GotoXY(39,11); Write(Dance[2,x]);
      GotoXY(39,12); Write(Dance[3,x]);
      Delay(500);
      x := x + 1;
    until keypressed or (x>16);
  until keypressed;
  Norm_Cursor;
end.


