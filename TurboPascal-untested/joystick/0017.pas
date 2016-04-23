Program JoyTest;
uses
   crt;

var
   ch:char;
   x1,y1,x2,y2:word;

Function JoyExist:boolean;
var
   temp:byte;
begin
   asm
      mov ah,84h
      mov dx,00h
      int 15h
      mov temp,al
   end;
   if temp=0 then JoyExist:=false
   else JoyExist:=true;
end;

Function JoyX:word;
var
   temp:word;
begin
   asm
      mov ah,84h
      mov dx,01h
      int 15h
      mov temp,ax
   end;
   JoyX:=temp;
end;

Function JoyY:word;
var
   temp:word;
begin
   asm
      mov ah,84h
      mov dx,01h
      int 15h
      mov temp,bx
   end;
   JoyY:=temp;
end;

Function JoyBtn1:boolean;
var
   temp:byte;
begin
   asm
      mov ah,84h
      mov dx,00h
      int 15h
      mov temp,al;
   end;
   if temp and 16 = 16 then JoyBtn1:=false
      else JoyBtn1:=true;
end;

Function JoyBtn2:boolean;
var
   temp:byte;
begin
   asm
      mov ah,84h
      mov dx,00h
      int 15h
      mov temp,al;
   end;
   if temp and 32 = 32 then JoyBtn2:=false
      else JoyBtn2:=true;
end;

Procedure JoyCalibrate;

begin

   writeln('Move Joystick to upper-left, and press a button...');
   repeat
      x1:=JoyX;
      y1:=JoyY;
   until JoyBtn1 or JoyBtn2;
   repeat until not JoyBtn1 or JoyBtn2;
   writeln('Move Joystick to lower-right, and press a button...');
   repeat
      x2:=JoyX;
      y2:=JoyY;
   until JoyBtn1 or JoyBtn2;

end;

begin {Main Program}
   clrscr;
   if not joyexist then begin
      writeln('No joystick');
      halt;
   end;
   joycalibrate;
   write(#10#13,'Range is from (',x1,',',y1,') to (',x2,',',y2,')');
   ch:=readkey;
end.
