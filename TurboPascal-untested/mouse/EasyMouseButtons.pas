(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0026.PAS
  Description: Easy Mouse Buttons
  Author: CJ CLIFFE
  Date: 02-28-95  09:53
*)

{

   This Unit is for Adding Buttons Easily to the screen, then checking to
   See if they were hit or not...


   Like so:

     CJ Cliife * Shareware Overload BBS (613)382-1924 & (613)382-8503
                 Voice: (613)382-4194
}

{ THE MOUSER UNIT and a DEMO is at the end of this unit ... SST }

Unit BUTTUNIT;   (* 1995 CJ Cliffe *)

Interface
Uses Mouser, Crt;

Var
  butts : Array [1..1500] Of String [20];          { Up to 1500 Buttons }
  buttx : Array [1..1500] Of ShortInt;             { Can Be used at the }
  butty : Array [1..1500] Of ShortInt;             { Same time on screen}
  buttx1: Array [1..1500] Of ShortInt;
  butty1: Array [1..1500] Of ShortInt;


Procedure Addbutt (butname1: String; X1, Y1, X2, Y2: Integer);{ Add a Button on
the screen, at top left x1,y1, and bottom right x2,y2} {    Spots can be exact,
because the numbers a trimmed to fit..        }


Function  Checkbutt (butname2: String): Boolean;
{  Simple, Check to see if a button is pressed! }


Procedure InitButtons;
{Used before each time a new screen of buttons is brought up}


Procedure StopButtons;
{ Hides The mouse away from sight}

Function Leftpushed: Boolean;
{Same as Leftpressed from MOUSE.PAS, but don't have to call up MOUSE.PAS}

Function Rightpushed: Boolean;
{Same as Rightpressed from MOUSE.PAS, but don't have to call up MOUSE.PAS}



Implementation


Procedure Addbutt (butname1: String; X1, Y1, X2, Y2: Integer);Var Cur: Integer;
Begin
  Cur := 0;
  Repeat
    Inc (cur);
  Until (Cur = 1500) Or (butts [Cur] = ' ');
  If Cur = 1500 Then
  Begin
    Write ('Button Limit Exceeded!', #7, #7, #7);
    Delay (2000);
    Halt;
  End;
  butts [cur] := Butname1;
  buttx [cur] := X1 - 1;
  butty [cur] := Y1 - 1;
  buttx1 [cur] := X2 + 1;
  butty1 [cur] := Y2 + 1;
End;



Function Checkbutt (butname2: String): Boolean;   {Check to see if mouse is}
Var                                               {   On top of a button   }
  curx, cury: Integer;                            { If so, then Checkbutt  }
  cou: Integer;                                   {         is True        } Begin
  Cou := 0;
  Checkbutt := False;
  cury := getmousex;
  curx := getmousey;
  Inc (curx);                                   {Compensate to match Screen}
  Inc (cury);
  Repeat
    Inc (cou);
  Until (Cou = 1500) Or (butts [cou] = butname2);
  If cou = 1500 Then                           {Button was not there at all}
  Begin
    Checkbutt := False;
    Exit;
  End;
  If  (curx > butty [cou] )                      {Check to see if mouse is on}
      And (cury > buttx [cou] )                  {        the button,        }
      And (curx < butty1 [cou] )
      And (cury < buttx1 [cou] )
  Then Checkbutt := True;
End;

Var setit: Integer;


Procedure InitButtons;
Begin
  Resetmouse;
  MouseWindow (0, 0, 79, 24);              { Keep Mouse Within Screen Limits }
  For setit := 1 To 1500 Do
  Begin
    butts [setit] := ' ';                  {Reset All Buttons}
    buttx [setit] := 0;
    butty [setit] := 0;
    buttx1 [setit] := 0;
    butty1 [setit] := 0;
  End;
  Showmouse;
End;


Procedure StopButtons;
Begin                              {Put the little Squeaker out of it's}
  Hidemouse;                       {              Misery               } End;


Function Leftpushed: Boolean;
Begin
  Leftpushed := False;
  If Leftpressed Then Leftpushed := True;
End;


Function Rightpushed: Boolean;
Begin
  Rightpushed := False;
  If Rightpressed Then Rightpushed := True;
End;



Begin
  If Not Mouseinstalled Then
  Begin
    TextColor (7);
    TextBackground (0);
    ClrScr;
    WriteLn (' This program reqires a mouse, please install your mouse driver ');
    WriteLn (' before running it... ');
    Halt;
  End;
End.

{ ---------------------------   MOUSER  UNIT  ------------------------ }

{This is some really GOOD stuff,  Bravo Bas! }
Unit mouser;
{ Mouseunit for textmode. by Bas van Gaalen, Holland. }
{      Slight Additions/Removals by CJ Cliffe         }

Interface

Const
  mtypes : Array [0..4] Of String [6] = ('bus', 'serial', 'inport', 'ps/2', 'hp');
  
Var
  buttons : Word;
  verhi, verlo, mousetype : Byte;
  driverinstalled : Boolean;
  
Function mouseinstalled : Boolean;
Procedure resetmouse;
Procedure getmouseversion;
Procedure showmouse;
Procedure hidemouse;
Function getmousex : Byte;
Function getmousey : Byte;
Function leftpressed : Boolean;
Function rightpressed : Boolean;
Procedure mousewindow (X1, Y1, X2, Y2 : Byte);


Implementation


Function mouseinstalled : Boolean; Assembler; Asm
  XOr AX, AX
  Int 33h
  cmp AX, - 1
  je @skip
  XOr AL, AL
  @skip:
End;

Procedure resetmouse; Assembler;
Asm
  XOr AX, AX
  Int 33h
  cmp AX, - 1
  jne @skip
  mov driverinstalled, True
  mov buttons, BX
  @skip:
End;

Procedure getmouseversion; Assembler;
Asm
  mov AX, 24h
  Int 33h
  mov verhi, BH
  mov verlo, BL
  mov mousetype, CH
End;

Procedure showmouse; Assembler;
Asm
  mov AX, 1
  Int 33h
End;

Procedure hidemouse; Assembler;
Asm
  mov AX, 2
  Int 33h
End;

Function getmousex : Byte; Assembler;
Asm
  mov AX, 3
  Int 33h
  ShR CX, 1
  ShR CX, 1
  ShR CX, 1
  mov AX, CX
End;

Function getmousey : Byte; Assembler;
Asm
  mov AX, 3
  Int 33h
  ShR DX, 1
  ShR DX, 1
  ShR DX, 1
  mov AX, DX
End;

Function leftpressed : Boolean; Assembler;
Asm
  mov AX, 3
  Int 33h
  And BX, 1
  mov AX, BX
End;

Function rightpressed : Boolean; Assembler;
Asm
  mov AX, 3
  Int 33h
  And BX, 2
  mov AX, BX
End;

Procedure mousewindow (X1, Y1, X2, Y2 : Byte); Assembler;
Asm
  mov AX, 7
  XOr CH, CH
  XOr DH, DH
  mov CL, X1
  ShL CX, 1
  ShL CX, 1
  ShL CX, 1
  mov DL, X2
  ShL DX, 1
  ShL DX, 1
  ShL DX, 1
  Int 33h
  mov AX, 8
  XOr CH, CH
  XOr DH, DH
  mov CL, Y1
  ShL CX, 1
  ShL CX, 1
  ShL CX, 1
  mov DL, Y2
  ShL DX, 1
  ShL DX, 1
  ShL DX, 1
  Int 33h
End;

End.


{ -----------------------   PROGRAM DEMO ---------------------------- }

Uses Crt, Buttunit;


Var Finished: Boolean;

Procedure DrawButts;
Begin
  ClrScr;
  Initbuttons;
  Addbutt ('mybutt1', 20, 20, 28, 20);              {Easy Button Set-Up}
  Addbutt ('mybutt2', 20, 21, 28, 21);
  Addbutt ('mybutt3', 20, 22, 28, 22);
  Addbutt ('quit',     1,  4,  8,  6);             {Buttons can be Any Size}
  TextColor (15);
  GotoXY (1, 1);
  Write ('[ ]  #1   [ ] #2    [ ] #3    ');
  GotoXY (20, 20);
  TextBackground (1); TextColor (15);
  Write (#221, 'Button1', #222);
  GotoXY (20, 21);
  TextBackground (2); TextColor (15);
  Write (#221, 'Button2', #222);
  GotoXY (20, 22);
  TextBackground (3); TextColor (15);
  Write (#221, 'Button3', #222);
  TextBackground (1); TextColor (15);
  GotoXY (1, 4);
  WriteLn (#219, #223, #223, #223, #223, #223, #223, #219);
  WriteLn (#221, ' Quit ', #222);
  WriteLn (#219, #220, #220, #220, #220, #220, #220, #219);
  TextBackground (0);
End;



Procedure Checkbutts;
Begin
  If Checkbutt ('mybutt1') Then
  Begin
    GotoXY (2, 1);
    TextColor (Random (8) + 8);
    Write (#254);
  End;
  If Checkbutt ('mybutt2') Then
  Begin
    GotoXY (12, 1);
    TextColor (Random (8) + 8);
    Write (#254);
  End;
  If Checkbutt ('mybutt3') Then
  Begin
    GotoXY (22, 1);
    TextColor (Random (8) + 8);
    Write (#254);
  End;
  If Checkbutt ('quit') Then Finished := True;
  Delay (200);
End;


Begin
  Drawbutts;
  Repeat
    Repeat
    Until LeftPushed;
    Checkbutts;
  Until Finished;
End.

