Unit Joystick;
Interface
 Uses Crt;

 { Joystick Interface For Turbo Pascal V. 4.0 and above
   Public Domain, November 1989 by
   JonSoft Technologies Inc.
   (C) 1989 JonSoft Technologies Inc. }

Const
 centX : Byte=80;
 centY : Byte=40;
 Joyst : Boolean=True;

Procedure FastInitJS;
Procedure BetterInitJS( range : Byte );
Function joy_X : Byte;
Function joy_Y : Byte;
Function button_1 : Byte;
Function button_2 : Byte;
Function Horiz : shortint;
Function Vert : shortint;


Implementation

Const
 rangexm : Byte=25;
 rangeym : Byte=20;
 rangexp : Byte=25;
 rangeyp : Byte=25;

Function joy_X : Byte;
  Var
    x : Word;
  begin
    x := 0;
    Port[$201] := $ff;
    While Port[$201] and $1=1 do Inc(x);
    joy_X := x;
  end;

Function joy_Y : Byte;
  Var
    y : Word;
  begin
    y := 0;
    Port[$201] := $0;
    While Port[$201] and $2=2 do Inc(y);
    joy_Y := y;
  end;

Procedure FastInitJs;
  begin
    centX := joy_X;
    centY := joy_Y;
  end;

Function button_1 : Byte;
  begin
    button_1 := ((Port[$201] and $10) Xor $10) ShR 4;
  end;

Function button_2 : Byte;
  begin
    button_2 := ((Port[$201] and $20) Xor $20) ShR 5;
  end;

Procedure BetterInitJs(range : Byte);
  Var
(*    Ch : Char; *)
    uprjoyX, uprjoyY, centrjoyX, centrjoyY, lowrjoyX, lowrjoyY : Byte;

begin
 WriteLN('Are you using a joystick? (Button = yes, RETURN = no)');
 Repeat
  if button_1+button_2 > 0 then Joyst := True;
  if KeyPressed then Joyst := False;
 Until (button_1+button_2 > 0) or KeyPressed;
 if Joyst = True then begin
  Repeat Until button_1+button_2 = 0;
  WriteLN('Move joystick to UPPER RIGHT corner and press a button.');
  Repeat Until button_1+button_2 > 0;
  uprjoyX := joy_X;
  uprjoyY := joy_Y;
  Repeat Until button_1+button_2 = 0;
  WriteLN('Move joystick to CENTER and press a button.');
  Repeat Until button_1+button_2 > 0;
  centrjoyX := joy_X;
  centrjoyY := joy_Y;
  centX := centrjoyX;
  centY := centrjoyY;
  Repeat Until button_1+button_2 = 0;
  WriteLN('Move joystick to LOWER LEFT CorNER and press a button.');
  Repeat Until button_1+button_2 > 0;
  lowrjoyX := joy_X;
  lowrjoyY := joy_Y;
  rangexm := (centrjoyX-uprjoyX) div range;
  rangexp := (lowrjoyX-centrjoyX) div range;
  rangeym := (centrjoyY-uprjoyY) div range;
  rangeyp := (lowrjoyY-centrjoyY) div range;
 end;
end;

Function Horiz : shortint;
  begin
    if joy_X<centX-rangexm then Horiz := -1
    else if joy_X > centX+rangexp then Horiz := 1
    else Horiz := 0;
  end;

Function Vert : shortint;
  begin
    if joy_Y<centY-rangeym then Vert := -1
    else if joy_Y > centY+rangeyp then Vert := 1
    else Vert := 0;
  end;

end.
