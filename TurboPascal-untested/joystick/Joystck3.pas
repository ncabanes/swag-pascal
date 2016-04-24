(*
  Category: SWAG Title: JOYSTICK ROUTINES
  Original name: 0003.PAS
  Description: JOYSTCK3.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{
to whomever sent me a message concerning joystick support, I apologize that I
cannot send this message to you directly (message Pointers were screwed up on m
end, and I lost your message), but here is both my source For a Unit and a
sample Program.  First I'd like to say that my Unit may be somewhat inComplete.
have only a Single joystick port, so reading of two ports is impossible.  For
this reason, I'd like to ask any and all to make suggestions, and modifications
so that I, and all Programmers, may have a Complete Unit.  Also, remarks have
not been added to the Program, if an explanation is needed, please feel free to
ask...I'd be more than happy to give explanations For my work.  Anyhows, here i
is...
}
Unit Joystick;

Interface

Function JoystickExists : Boolean;
Function JoystickPosX : Integer;
Function JoystickPosY : Integer;
Function JoystickButtonA : Boolean;
Function JoystickButtonB : Boolean;

Implementation

Uses Crt, Dos;

Const GamePortAddr = $200;
     MaxCount = 500;

Function JoystickStatus (Mask : Byte) : Integer;
Var Counter : Integer;
Label Read;
begin
  Asm
  mov cx,MaxCount
  mov dx,GamePortAddr
  mov ah,Mask
  out dx,al
  read:
     in al,dx
     test al,ah
     loopnz read
  mov counter,cx
  end;
  JoystickStatus := MaxCount - Counter;
  Delay (2);
end;

Function JoystickPosX : Integer;
begin
  JoystickPosX := JoystickStatus (1);
end;

Function JoystickPosY : Integer;
begin
  JoystickPosY := JoystickStatus (2);
end;

Function JoystickButtonA : Boolean;
begin
  JoystickButtonA := (Port [GamePortAddr] and 16) = 0;
end;

Function JoystickButtonB : Boolean;
begin
  JoystickButtonB := (Port [GamePortAddr] and 32) = 0;
end;

Function JoystickExists : Boolean;
Var Regs : Registers;
begin
  JoystickExists := not ((JoystickPosX = 0) and (JoystickPosY = 0));
end;

end.


Program JoyTest;

Uses Crt, Dos, AniVGA, Joystick;

Var XMin, XMax, YMin, YMax,
   XRange, YRange,
   X, Y,
   PosX, PosY,
   Bullet1X, Bullet1Y,
   Bullet2X, Bullet2Y : Integer;
   Shooting1, Shooting2 : Boolean;
   ShootNext : Boolean;

Procedure CalibrateJoystick (Var XMin, XMax, YMin, YMax : Integer);
begin
  Write ('Press joystick to upper left corner and press button one...');
  Repeat Until JoystickButtonA;
  XMin := JoystickPosX;
  YMin := JoystickPosY;
  Writeln ('OK.');
  Repeat Until not JoystickButtonA;
  Write ('Press joystick to lower right corner and press button two...');
  Repeat Until JoystickButtonB;
  XMax := JoystickPosX;
  YMax := JoystickPosY;
  Writeln ('OK.');
  Repeat Until not JoystickButtonB;
end;

Procedure AnimateShip;
begin
  X := JoystickPosX - XMin;
  if (X <= XRange div 3) then
     Dec (PosX, 3)
  else if (X > XRange * 2 div 3) then
     Inc (PosX, 3);
  Y := JoystickPosY - YMin;
  if (Y <= YRange div 3) then
     Dec (PosY, 3)
  else if (Y > YRange * 2 div 3) then
     Inc (PosY, 3);
  SpriteX [0] := PosX;
  SpriteY [0] := PosY;
end;

Procedure AnimateBullets;
begin
  if Shooting1 then
     if (Bullet1Y < 0) then
        Shooting1 := False
     else
        Dec (Bullet1Y, 8)
  else
     begin
        Bullet1X := PosX + 3;
        Bullet1Y := PosY + 14;
     end;
  if Shooting2 then
     if (Bullet2Y < 0) then
        Shooting2 := False
    else
        Dec (Bullet2Y, 8)
  else
     begin
        Bullet2X := PosX + 30;
        Bullet2Y := PosY + 14;
     end;
  SpriteX [1] := Bullet1X;
  SpriteY [1] := Bullet1Y;
  SpriteX [2] := Bullet2X;
  SpriteY [2] := Bullet2Y;
end;

begin
  if JoystickExists and (LoadSprite ('SHIP1.COD', 1) = 1) and
     (LoadSprite ('BULLET.COD', 2) = 1) then
     begin
        ClrScr;
        CalibrateJoystick (XMin, XMax, YMin, YMax);
        ClrScr;
        InitGraph;
        SpriteN [0] := 1;
        SpriteN [1] := 2;
        SpriteN [2] := 2;
        PosX := 160;
        PosY := 160;
        Shooting1 := False;
        XRange := XMax - XMin;
        YRange := YMax - YMin;
        ShootNext := Boolean (0);
        While not (JoystickButtonA and JoystickButtonB) do
           begin
              if JoystickButtonA and not JoystickButtonB then
                 if not Shooting1 and ShootNext then
                    begin
                       Bullet1X := PosX + 3;
                       Bullet1Y := PosY + 14;
                       Shooting1 := True;
                       ShootNext := False;
                    end
                 else if not Shooting2 and not ShootNext then
                    begin
                       Bullet2X := PosX + 30;
                       Bullet2Y := PosY + 14;
                       Shooting2 := True;
                       ShootNext := True;
                    end;
              While JoystickButtonA do
                 begin
                    AnimateShip;
                    AnimateBullets;
                    Animate;
                 end;
              AnimateShip;
              AnimateBullets;
              Animate;
           end;
        CloseRoutines;
     end
  else
     Writeln ('Game card not installed.');
end.
{
I apologize For giving you an example that Uses another Unit.  if need be, this
Program can be easily modified to provide a successful example.  Hope this
helps, and I hope my Programming is not toO bad.
}
