(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0092.PAS
  Description: Keyboard Stuffer
  Author: TOM CARROLL
  Date: 11-26-94  05:08
*)


Program StuffKeyboardBuffer;

Uses Crt,Dos;

Var
       Name : String;

Procedure Stuffit(DChar:Char);
Begin
     asm
        mov ah,05h
        mov ch,1
        mov cl, DChar
        int 16h
     end;
end;

Procedure StuffKeyboard(D : String);
Var
       l : Integer;

Begin
   for l:=1 to length(d) do
       StuffIt(D[l]);
End;

Begin
       Clrscr;
       Write('Enter your name : ');
       StuffKeyboard('Robbie Flynn');
       Readln(Name);
       Writeln('Your name is : ',Name);
End.

