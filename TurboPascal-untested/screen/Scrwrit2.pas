(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0012.PAS
  Description: SCRWRIT2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

{
 SO> Got a question For you all out there..... How the heck can I Write a
 SO> Character  into the bottom right corner of a Window without the Window
 SO> scrolling?
 SO>
 SO> if anyone knows some way to keep the Write command from Forwarding the
 SO> cursor  position Pointer, that would be fine enough For me.....

Sean, here is a way to do it without resorting to poking the screen.
}

{$A+,B+,D+,E-,F+,G-,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V-,X+,Y+}
{$M 8192,0,0}

Uses
  Crt;
Var
  index1, Index2: Byte;

begin
  ClrScr;

{******************************************
 First Write top line of bordered display
******************************************}

  Write ('╔');                     {Write top Left Corner}
  For Index1 := 1 to 78 do         {Write top Horizontal line }
    Write ('═');
  Write ('╗');                     {Write top Right Corner}

{*******************************************
 Now Write Bottom line of bordered display
*******************************************}

  Write ('╚');                     {Write Bottom Left Corner}
  For Index1 := 1 to 78 do         {Write Bottom horizontal line}
    Write ('═');
  Write ('╝');                     {Write Bottom Right Corner}

{********************************************************************
 Now inSERT 23 lines of Left&Right bordered display, pushing bottom
 line down as we do
********************************************************************}

  For Index1 := 1 to 23 do begin   { Repeat 23 times }
    GotoXY (1, 2);                 {Move cursor back to Col 1, Line 2}
    InsLine;                       {Insert blank line (Scroll Text down)}
    Write ('║');                   {Write Left border vertical caracter}
    For Index2 := 1 to 78 do       {Write 78 spaces}
      Write (' ');
    Write ('║');                   {Write Right border vertical caracter}
  end;

{***********************************************************
 I added this so the Program would pause For a key. This way
 it will allow you to see that it does not scroll up since
 the cursor never Writes to position 25,80
***********************************************************}

  Asm                              {Assembler code to flush keyboard}
    mov Ax, 0C00h;
    Int 21h;
  end;
  ReadKey ;                        {Wait For a keypress}

end.

{
BTW, this was written, Compiled and Tested in BP 7.0 but should work in
TP 4.0 and up if you remove the Assembler stuff.
}
