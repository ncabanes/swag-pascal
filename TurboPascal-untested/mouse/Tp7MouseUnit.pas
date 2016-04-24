(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0018.PAS
  Description: TP7 Mouse Unit
  Author: MARK MILBRATH
  Date: 02-05-94  07:57
*)

Program MouseDemo;   { I just learned this little piece of wizardry }
Uses                 { so I thought I would pass it on -- have fun! }
  Crt,Dos,Drivers;
Type
  CharType=Set Of Char;
Var
  Key:Char; ValidKeys:CharType;
  Button_Status,Mouse_X,Mouse_Y,ButtonPressed,X,Y:Word;
Procedure GetMouse (Var Button_Status,Mouse_X,Mouse_Y:Word;
                                              Monitor:Word);
Var                       { --------------------------------------- }
  Regs:Registers;         { Button_Status     0 = no button pressed }
Begin                     { Mouse_X           X coordinate          }
  Regs.AX:=3;             { Mouse_Y           Y coordinate          }
  Intr($33,Regs);         { Monitor           0 = off  1 = on       }
  Button_Status:=Regs.BX; { Monitor can be set to 1 While coding to }
  Mouse_X      :=Regs.CX; { display Button_Status,   Mouse_X,   and }
  Mouse_Y      :=Regs.DX; { Mouse_Y in the upper-left corner of the }
  If (Monitor=1) Then     { screen                                  }
    Begin                 { --------------------------------------- }
      TextBackGround(7); TextColor(8); GotoXY(1,1);
      Write('             '); GotoXY(1,1);
      Write(Button_Status:2,Mouse_X:5,Mouse_Y:5); Delay(100)
    End
End;
Procedure GetEvent;
Label
  ExitLoop;
Begin
  TextBackGround(0); ClrScr; TextColor(7);
  GotoXY(26,12); Write('Continue? [Y] or [N]? ');
  ValidKeys:=[#89,#78];          { accept only Y or N as valid keys }
  Key:=#255;                     { initialize Key to a nonvalid key }
  Repeat
    While (Not KeyPressed) Do
      Begin
        GetMouse(Button_Status,Mouse_X,Mouse_Y,0);
        Repeat                               { ^  turns monitor off }
          GetMouse(ButtonPressed,X,Y,0) { X & Y are dummy variables }
        Until (KeyPressed) Or (ButtonPressed<>Button_Status);
    { Repeat ^ Until "waits" until a change in Button_Status occurs }
    { this eliminates a "slow" click from being processed as two or }
    { more clicks                                                   }
        If (Button_Status>0) THEN { a mouse button has been pressed }
          Begin { convert mouse clicks into corresponding key codes }
            If      (Mouse_X=288) And (Mouse_Y=88) Then Key:=#89
            Else If (Mouse_X=344) And (Mouse_Y=88) Then Key:=#78;
            If      (Key In ValidKeys)             Then Goto ExitLoop
          End                              { exit the loop if valid }
      End;                                 { key codes are received }
    Key:=Upcase(ReadKey) { get keyboard event if KeyPressed is true }
  Until (Key In ValidKeys);
  ExitLoop: TextBackGround(0); ClrScr; TextColor(7);
  If Key=#89 Then
    Begin
      Randomize;
      X:=Random(61)+10;      { pick a random X column from 10 to 60 }
      Y:=Random(21)+ 3;      { pick a random Y row    from  3 to 23 }
      GotoXY(X,Y);     Write(#177);
      GotoXY(X-5,Y+1); Write('Click here!');
              { the X column and Y row numbers must be converted to }
              { X and Y coordinates by multiplying the column & row }
              { numbers by 8 and then subtracting 8 from that value }
      Repeat  { for example:  column 40, row 10 converts to 312, 72 }
        GetMouse(Button_Status,Mouse_X,Mouse_Y,1)
                                             { ^   turns monitor on }
      Until(Button_Status>0) And (Mouse_X=X*8-8) And (Mouse_Y=Y*8-8);
      GetEvent                   {        ^^^^^               ^^^^^ }
    End;                         { X coordinate        Y coordinate }
  HideMouse; ClrScr
End;
Begin
  InitEvents;
        { sets the "hide counter" to zero and displays mouse cursor }
        { use ShowMouse to decrement the hide counter               }
        { use HideMouse to increment the hide counter               }
        { when hide counter equals zero the mouse cursor is visible }
  GetEvent
End.

