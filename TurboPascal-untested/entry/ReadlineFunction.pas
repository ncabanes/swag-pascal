(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0011.PAS
  Description: Readline Function
  Author: RICHARD FURMAN
  Date: 05-25-94  08:20
*)

{
The Readln statement can't really be used here, because this interchange is
taking place in Graphics mode.  I am writing a Graphics application that
does take user input
}
Function KBString:String; {* Gets string from keyboard using Scankey *}
         Var
           bu,X,Inchar:Integer;
           STRBUFF:STRING;
         begin
         STRBUFF := '';
         X:=20;
          Repeat
               Inchar := Scankey;
               IF FK and (Inchar = 60) then
                  Begin
                       Cancel := True;
                       Exit;
                  End;
               setcolor(0);
               setlinestyle (0,0,1);
               Rectangle(15,70,X+5,90);
               setcolor(BLDCLR);
               If Not FK  then outtextxy (x,77,CHR(INCHAR));
               If inchar <> 8 then
                  Begin
                       X := X+ Textwidth(CHR(INCHAR));
                       setcolor(txtclr);
                       Rectangle(15,70,X+5,90);
                  End
               else
               begin
                  setcolor(0);
                  setlinestyle (0,0,1);
                  Rectangle(15,70,X+5,90);
                  x:=x-textwidth(Strbuff[length(strbuff)]);
                  outtextxy(X,77,strbuff[length(strbuff)]);
                  setcolor(txtclr);
                  Rectangle(15,70,x+5,90);
                  Delete(Strbuff,Length(Strbuff),1);
                  setcolor(BLDCLR);
               End;
               If (Not FK) and (Inchar <> 8)  then STRBUFF := STRBUFF +
                                                      CHR(Inchar);
          Until inchar = 13;
         Delete(strBuff,Length(StrBuff),1);
         setcolor(txtclr);
         KBString := STRBUFF;
         End;

This code snippet should give you some ideas on getting user input.  BTW
SCANKEY is a function I wrote to read the keyboard.  You should be able to
use READKEY in its place.  This routine also features the ability to edit
with the backspace key.  I hope it helps.

