(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0118.PAS
  Description: Display all scan codes for keyboard
  Author: SCOTT TUNSTALL
  Date: 03-04-97  13:18
*)

{
NAME      : SHOWKEYS.PAS

AUTHOR    : SCOTT TUNSTALL B.Sc

CR. DATE  : 8th July 1996


This program shows the Up/Down status of all keys on keyboard,
so you can determine what key has what scancode.

ESC = Exit (If by any chance you're wondering what the
Scancode value of ESC is, it's 1)


--------------------------------------------------------------
}

{ NWKBDINT is in June 96's KEYBOARD.SWG, author of the
  program is Scott Tunstall.
}


Uses NWKBDINT,CRT;

var x,y: byte;

Begin
     hookkeyboardint;
     textmode(CO80);
     repeat
           For y:=0 to 7 do
               For x:=0 to 15 do
                   begin
                   gotoxy((x*4)+1,(y*2)+1);
                   textcolor(WHITE);
                   write((y * 16) + x);
                   gotoxy((x*4)+1,(y * 2) + 2);

                   if keydown[(y*16) + x] Then
                      begin
                      textcolor(LIGHTGREEN);    { Highlight the key }
                      write('DN')
                      end
                   else
                       begin
                       textcolor(RED);
                       write('UP');
                       end;
               end;

     until keydown[1];  { ESC }
     unhookkeyboardint;

End.


