(*
  Category: SWAG Title: JOYSTICK ROUTINES
  Original name: 0019.PAS
  Description: OOP Joystick Module
  Author: AD RIEDIJK
  Date: 08-30-96  09:36
*)

(*                             A Joystick Unit !
------------------------------------------------------------------------------
This unit will also Detect Your Joystick. if it's detected then you'll have
to init the Joystick by turning the joystick in all directions and when done
press a button , And whala your joystick works I Hope!

See My sample program under the Unit code.

You may modify this code as muts as you want but , please give me a
credit,thanks !
Have a question or suggestions please tel me : E-mail riedijk@pi.net

By Ad Riedijk .
  *)

Unit JoyStick;

interface
Const GamePortAddr = $200;
      MaxCount = 500;
      JUPDOWN=2;
      JLEFTRIGHT=1;



type TJoyStick = Object
      {there is not a range checking}
      Xas,Yas:integer;{those will be updated when joyup or down left right
are  called}
      XSpeed,YSpeed:byte;{the increment of xas=xas+xspeed and yas:=yas+yspeed}
      minX,minY,maxX,maxY:integer;
      Function JoystickStatus (Mask : Byte) : Integer;
      Function JoyUp:boolean;
      Function JoyDown:boolean;
      Function JoyLeft:boolean;
      Function JoyRight:boolean;
      Function JoyButton1:boolean;
      Function JoyButton2:boolean;
      Function JoyButtonPressreleased1:boolean;
      Function JoyButtonPressreleased2:boolean;
      Function InitJoyStick:boolean;
      function DetectJoystick:boolean;
    end;


implementation

uses crt;{for the delay}

Function TJoyStick.JoystickStatus (Mask : Byte) : Integer;
Var Counter : Integer;
    p:byte;
begin
  port[gameportaddr]:=0;{just write someting too the gameport}
  counter:=maxcount;
  repeat
   dec(counter);
  until (counter=0) or (port[gameportaddr] and mask<>mask);
  JoystickStatus := MaxCount - Counter;
  Delay (2);
end;

Function TJoyStick.JoyUp:boolean;
begin
 if   (JoyStickStatus(JUPDOWN) <= minY+10) then
      begin
       JoyUp:=true;
       dec(Yas,Yspeed);
      end
       else JoyUp:=false;
end;

Function TJoyStick.JoyDown:boolean;
begin
 if   (JoyStickStatus(JUPDOWN) >= maxY-10) then
      begin
        JoyDown:=true;
        inc(Yas,Yspeed);
      end
         else JoyDown:=false;
end;

Function TJoyStick.JoyLeft:boolean;
begin
 if   (JoyStickStatus(JLeftRight) <= minx+10) then
      begin
        JoyLeft:=true;
        dec(Xas,Xspeed);
      end
         else JoyLeft:=false;
end;

Function TJoyStick.JoyRight:boolean;
begin
 if   (JoyStickStatus(JLeftRight) >= maxx-10) then
      begin
        JoyRight:=true;
        inc(Xas,Xspeed);
      end
         else JoyRight:=false;
end;


Function TJoyStick.JoyButton1:boolean;
begin
if not (port[Gameportaddr] and 16 = 16) then  JoyButton1:=true else
JoyButton1:=false;
end;


Function TJoyStick.JoyButton2:boolean;
begin
if not (port[Gameportaddr] and 32 = 32) then JoyButton2:=true else
JoyButton2:=false;
end;

Function TJoystick.JoyButtonPressreleased1:boolean;
begin
if joybutton1 then
begin
  joybuttonpressreleased1:=true;
  repeat
  until  not joybutton1;
end else   joybuttonpressreleased1:=false;
end;

Function TJoystick.JoyButtonPressreleased2:boolean;
begin
if joybutton2 then
begin
  joybuttonpressreleased2:=true;
  repeat
  until  not joybutton2;
end else   joybuttonpressreleased2:=false;

end;

Function TJoyStick.InitJoyStick :boolean;
var JMaxX,JMaxY,JMinY,JMinX:integer;
begin
    if detectJoystick then
    begin
     Initjoystick:=true;
     XSpeed:=1;
     YSpeed:=1;
     XAS:=0;
     YAS:=0;
     minX:=JoystickStatus (JLEFTRIGHT);
     maxX:=JoystickStatus (JLEFTRIGHT);
     minY:=JoystickStatus (JUPDOWN);
     maxY:=JoystickStatus (JUPDOWN);
  repeat
     JminX:=JoystickStatus (JLEFTRIGHT);
     if JminX  < minx then minx:=Jminx;
     JmaxX:=JoystickStatus (JLEFTRIGHT);
     if JmaxX > maxX then maxX:=JmaxX;

     JminY:=JoystickStatus (JUPDOWN);
     if JminY  < minY then minY:=JminY;
     JmaxY:=JoystickStatus (JUPDOWN);
     if JmaxY > maxY then maxY:=JmaxY;
     if not detectJoystick  then initjoystick:=false;
  until JoyButton1 or  JoyButton2 or (not detectJoystick);
  end else      Initjoystick:=false;
end;


Function TJoyStick.detectJoystick:boolean;
begin
if Joystickstatus(1) = Maxcount then detectJoystick:=false else
                                  detectJoystick:=true;
end;

end.

{ ---------------------   DEMO PROGRAM  ----------------------- }

Program Joytest;

uses crt,dos,joystick;

var Joy:TJoyStick;

begin
  clrscr;
  writeln('please move  your Joystick in all directions and when done press
a button ');
  if not Joy.InitJoyStick then  {Try this : when initjoystick runs just un
plug the joystick}
  begin
    writeln('Error no Joystick !');
    halt(0);
  end;
  clrscr;
  Writeln('Move the Joystick up and down  and left and right');
  writeln('Push a button A or B  to Quit');
  delay(200);
  repeat
    if Joy.JoyLeft then begin gotoxy(10,10);write(#17);  end else
     if Joy.JoyRight then begin gotoxy(10,10);write(#16);  end else
                              begin gotoxy(10,10);write(#254);end;

      if Joy.JoyUp then begin gotoxy(10,11);write(#30);  end else
       if Joy.JoyDown then begin gotoxy(10,11);write(#31);  end else
                                  begin gotoxy(10,11);write(#254);  end;
     delay(200);
  until   joy.JoyButtonPressreleased1 or joy.JoyButtonPressreleased2;
end.


