Unit OwnMouse;

(*
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE
=FE                            Bios mouse unit (Assembler code)          =
      =FE
=FE                            Totally coded by Lunatic/Lucifer          =
      =FE
=FE  If you use this unit, please, give some credits for me, or atleast s=
end   =FE
=FE                copy of your program(or it's source) to lunatic@dlc.fi=
      =FE
=FE                      -=C4=CD FREEWARE SOURCE FROM SWAG'S MOUSE.SWG =CD=
--         =FE
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE
*)

Interface

(* ---------------------- MOUSE PROCEDURES ---------------------------- *)


Procedure GetMouseData(var major,minor,mousetype,irq:byte);{Restores vers=
ion,
                                                            (major.minor)=
,
                                                            type of mouse=
 and
                                                            mouse's IRQ}
Procedure TellAboutMouse; {Textmode ofcourse.. Tells somethin' about your=

                           mouse}
Procedure ShowMouse;           {Show mouse cursor}
Procedure HideMouse;           {Hide mouse cursor}
Procedure SetMOUSEXY(x,y:integer);           {Set's mouse's coordinates t=
o
                                              x,y}
Procedure MouseAREA(x1,y1,x2,y2:integer);           {Set's mouses minimum=
 and
                                                     maximum x,y}
Procedure SetSensitivity(xsens,ysens,dst:integer); {Set mouse sensitivity=
}
Procedure GetSensitivity(var xsens,ysens,dst:integer); {Get sensitivity}
{dst= double speed treshold xsens= xsensitivity ysens= ysensitivity}

(* ---------------------- MOUSE FUNCTIONS ---------------------------- *)


Function MouseInstalled:Boolean; {Returns TRUE if mouse has been installe=
d}
Function Buttons:integer; {Restores number of buttons}
Function MouseLanguage:Integer;                   {Restores the language =
of
                                                   mouse driver..}
Function MouseX:Integer; {Restores Mouse's X vector}
Function MouseY:Integer; {Restores Mouse's Y vector}
Function LeftPressed:Boolean; {Returns true if LeftButton of mouse is pre=
ssed}
Function LeftReleased:Boolean; {Returns true if LeftButton is not pressed=
}
Function RightPressed:Boolean; {Returns true if RightButton has been pres=
sed}
Function RightReleased:Boolean; {Returns true if Rightbutton hasn't been
                                 pressed}


Implementation

Function MouseInstalled:Boolean;
Var inst:Integer;
Begin
Asm
Mov ax, 00h
Int 33h
Mov inst, ax
End;
If inst= $0000 Then MouseInstalled:= True;
If inst= $FFFF then MouseInstalled:= False;
End;

Function Buttons:integer;
var buttonnum:integer;
Begin
Asm
Mov ax, 00h
Int 33h
Mov buttonnum, bx
End;
Buttons:= buttonnum;
End;

Procedure GetMouseData(var major,minor,mousetype,irq:byte);
var v1,v2,mt,i:byte;
Begin
asm
Mov ax, 24h
Int 33h
Mov v1, bh
Mov v2, bl
Mov mt, ch
Mov i, cl
end;
major:= v1;minor:= v2;mousetype:= mt;irq:= i;
End;

Function MouseLanguage:Integer;var kieli:integer;
Begin Asm
Mov ax, 23h
Int 33h
Mov kieli, bx
End;
MouseLanguage:= kieli;
End;

Procedure TellAboutMouse; {Textmode ofcourse..}
var v1,v2,mt,irq:byte;lan:integer;
Begin
GetMouseData(v1,v2,mt,irq);
lan:= MouseLanguage;
Write('Mouse type: ');
If mt= 1 Then WriteLn('BUS mouse');
If mt= 2 Then WriteLn('Serial mouse');
If mt= 3 Then WriteLn('InPort mouse');
If mt= 4 Then WriteLn('PS/2 mouse');
If mt= 5 Then WriteLn('Hewlett Packard mouse');
WriteLn('Version: ',v1,'.',v2);
Write('Mouse IRQ: ');
If irq= 0 Then WriteLn('PS/2') else WriteLn(irq);
Write('Mouse language: ');
if lan= 0 Then WriteLn('english');
if lan= 1 Then WriteLn('french (F)');
if lan= 2 Then WriteLn('dutch (NL)');
if lan= 3 Then WriteLn('german (D)');
if lan= 4 Then WriteLn('swedish (S)');
if lan= 5 Then WriteLn('finnish (SF)');
if lan= 6 Then WriteLn('spanish (E)');
if lan= 7 Then WriteLn('portuguese (P)');
if lan= 8 Then WriteLn('Italian (I)');
End;

Procedure ShowMouse;Assembler;
Asm
Mov ax, 01h
Int 33h
End;

Procedure HideMouse;Assembler;
Asm
Mov ax, 02h
Int 33h
End;

Function MouseX:Integer;
var mx:integer;
Begin Asm
Mov ax, 03h
Int 33h
Mov mx, cx
End; MouseX:= mx; End;

Function MouseY:Integer;
var my:integer;
Begin Asm
Mov ax, 03h
Int 33h
Mov my, dx
End; MouseY:= my; End;

Procedure SetMOUSEXY(x,y:integer);Assembler;
Asm
Mov ax, 04h
Mov cx, x
Mov dx, y
Int 33h
End;

Function LeftPressed:Boolean;
var data:integer;
Begin
Asm
Mov ax, 05h
Mov bx, 0h
Int 33h
or ax, 0
mov data, ax
End;
if data= 1 Then LeftPressed:= True else LeftPressed:= False;
End;

Function LeftReleased:Boolean;
var data:integer;
Begin
Asm
Mov ax, 06h
Mov bx, 0h
Int 33h
or ax, 0
mov data, ax
End;
if data= 0 Then LeftReleased:= True else LeftReleased:= False;
End;

Function RightPressed:Boolean;
var data:integer;
Begin
Asm
Mov ax, 05h
Mov bx, 1h
Int 33h
or ax, 0h
mov data, ax
End;
if data= 2 Then RightPressed:= True else RightPressed:= False;
End;

Function RightReleased:Boolean;
var data:integer;
Begin
Asm
Mov ax, 06h
Mov bx, 1h
Int 33h
or ax, 0
mov data, ax
End;
if data= 0 Then RightReleased:= True else RightReleased:= False;
End;

Procedure MouseAREA(x1,y1,x2,y2:integer);Assembler;
Asm
Mov ax, 07h
Mov cx, x1
Mov dx, x2
Int 33h
Mov ax, 08h
Mov cx, y1
Mov dx, y2
Int 33h
End;

Procedure SetSensitivity(xsens,ysens,dst:integer);Assembler;Asm
Mov ax, 1Ah
Mov bx, xsens
Mov cx, ysens
Mov dx, dst
Int 33h
end;

Procedure GetSensitivity(var xsens,ysens,dst:integer);
var x,y,d:integer;
Begin
Asm
Mov ax,1B
Int 33h
Mov x, bx
Mov y, cx
Mov d, dx
End;
xsens:= x;ysens:= y;dst:= d;
End;
End.
