(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0081.PAS
  Description: Faded Writer text effect
  Author: SALVATORE MESCHINI
  Date: 01-02-98  07:33
*)

Program FWriter;

(* Converted from C by Salvatore Meschini. Freeware source code. *)

Uses Crt;

procedure CursorOff; assembler;
asm
  MOV   DX,03D4H        { CRTC index register }
  MOV   AL,0AH          { select register 0Ah }
  OUT   DX,AL
  INC   DX              { CRTC data register }
  IN    AL,DX           { get status }
  OR    AL,20H          { bit 5 = 1 (Cursor off) }
  OUT   DX,AL
end;

Procedure FadedWrite(message:string;row:byte);
 const colors:array [1..8] of byte=(11,9,1,9,3,11,15,7); 
 var x,y:byte;
 begin
  for x:=1 to 8 do message:=message+' '; {Add spaces to the end of message}
  for x:=1 to length(message) do         {Main cycle}
   begin
    textcolor(colors[1]);
    gotoxy(x,row);
    write(message[x]);
    for y:=1 to 8 do
      begin
        if x>y then
            begin
             textcolor(colors[y]);
             gotoxy(x-y,row);
             write(message[x-y]);
            end;
          delay(10); {Increment/decrement delay according your PC speed, or
                      get a machine independent delay}
      end;
   end;
  if row>24 then begin gotoxy(1,1); delline; gotoxy(1,25); end else
  gotoxy(1,row+1);
 end;

begin
clrscr;
cursoroff; {Turn Cursor Off}
{Use a fadedwrite for each row!}
fadedwrite('Hello from Salvatore Meschini (http://www.ermes.it/mesk) !!!',1);
fadedwrite('Contact me at smeschini@ermes.it',2);
fadedwrite('Don''t forget to get the "File Formats Encyclopedia 2.0" from',3);
fadedwrite('SWAG distribution site (http://www.gdsoft.com/swag/downloads.html',4);
fadedwrite('See you...Please support the SWAG archive!',5);
end.

