(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0009.PAS
  Description: Pickable Litebar Menu
  Author: GORDY FRENCH
  Date: 05-31-96  09:16
*)

{
>Here's some neat lightbars that I made.  REALLY easy to use, pretty
>simple.
>Feel free to use it, like I care.. Just don't yell at me fer what it
>does. }

Program lite;

Uses crt;

Type

 literec = Record   {Litebar config rec}
              choices: Integer;
              menu: Array [1..25] Of String;
              othercolor, barcolor: Integer;
            End;

Function litebar (lite: literec): Integer;
(*
Procedure HideCursor; Assembler;
Asm
  MOV   AX, $0100         {Hides cursor}
  MOV   CX, $2607
  Int   $10
End;
Procedure ShowCursor; Assembler;
Asm
  MOV   AX, $0100
  MOV   CX, $0506         {Unhides cursor}
  Int   $10
End;
*)
Label ack, stop;
Var
  on: Integer;
  X, Y: Integer;
  key: Char;          {Various vars}
  okey: Byte;
  lastone: Integer;
  litesize: Integer;

Begin
  {hidecursor;}
  X := WhereX;   {Record starting positions}
  Y := WhereY;
  TextColor (lite. othercolor);  {Change color}
  TextBackground (0);            {Change background}
  litesize := 0;
  For on := 1 To lite. choices Do Begin  {This for loop writes the options.}
    GotoXY (X, Y + on - 1);
    WriteLn (lite. menu [on] );
    If Length (lite. menu [on] ) > litesize Then litesize := Length
(lite. menu [on] );
  End;

  For on := 1 To lite. choices Do Begin  {This for loop makes the >lightbar}
    If Length (lite. menu [on] ) < litesize Then Begin {the same >length}
      Repeat
        lite. menu [on] := lite. menu [on] + ' ';
      Until Length (lite. menu [on] ) >= litesize;
    End;
  End;
  on := 1;
  lastone := 999;
  Repeat   {Main loop}
    If lastone <> 999 Then Begin  {redraw last option (reset background}
    GotoXY (X, Y + lastone - 1);
      TextBackground (0);
      WriteLn (lite. menu [lastone] );
    End;
    GotoXY (X, Y + on - 1);         {go to option}
    TextBackground (lite. barcolor); {change color}
    WriteLn (lite. menu [on] );  {rewrite current option (background)}
    ack: Repeat key := ReadKey Until key In [#13, #0];  {get a key}
    If key = #0 Then Begin  {was it extended? process it.}
      okey := Ord (ReadKey);
      If (okey = 72) Then Begin  {up}
        If on = 1 Then Begin lastone := on; on := lite. choices End
Else If on <> 1 Then Begin lastone := on; Dec (on); End;
      End
      Else If (okey = 80) Then Begin {down}
        If on = lite. choices Then Begin lastone := on; on := 1 End
Else If (on < lite. choices) Then Begin lastone := on;
          Inc (on);
        End;
      End Else Goto ack;
      Continue;
    End Else
      If key = #13 Then Goto stop Else  {enter}
        If key = ' ' Then If on = lite. choices Then on := 1 Else If
on < lite. choices Then Dec (on) Else
          Goto ack;
  Until 5 < 4; {loop.}
  stop:  {end it}
  litebar := on;  {tell us what they picked}
  {ShowCursor;}  {turn cursor back on}
End;

Var picked: Integer;
    litecfg: literec;
Begin
  TextBackground (0); {Reset backround}
  ClrScr;
  GotoXY (4, 4); {where is menu going to be?}
  litecfg. choices := 4;  {set choices}
  litecfg. menu [1] := 'Player Editor';     {--\               }
  litecfg. menu [2] := 'Software Editor';   {  |____set choices}
  litecfg. menu [3] := 'CPU Editor';        {  |               }
  litecfg. menu [4] := 'Quit';              {--/               }
  litecfg. othercolor := 3;  {Set foreground color}
  litecfg. barcolor := 1;    {Set background color}
  picked := litebar (litecfg);  {Run the lightbars!}
  TextBackground (0);   {change background back (req'd)}
  ClrScr; {clear it}
  WriteLn ('You picked number ', picked, ', which is ', litecfg. menu[picked], '.');
  {/\   Tell them what they did   /\}
End.

