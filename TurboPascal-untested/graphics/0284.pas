
Unit OwnGraph;

(*
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE
=FE                           Bios graphic unit (Assembler code)         =
      =FE
=FE                            Totally coded by Lunatic/Lucifer          =
      =FE
=FE  If you use this unit, please, give some credits for me, or atleast s=
end   =FE
=FE                copy of your program(or it's source) to lunatic@dlc.fi=
      =FE
=FE                     -=C4=CD FREEWARE SOURCE FROM SWAG'S GRAPHIC.SWG =CD=
--        =FE
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=FE=
=FE=FE=FE
*)

Interface

{-- Procedures --}

Procedure SetMODE(mode:byte); {Set video mode}
Procedure CurSIZE(top,bottom:byte); {Set cursor's size}
Procedure GotoXY(x,y,p:byte); {Move cursor to x,y (p= page) point}
Procedure ShowPage(p:byte); {Shows p page}
Procedure GetPAL(var r,g,b:byte;c:integer); {Gets Red, Green and Blue
                                             values of color c to r g and=
 b}
Procedure SetPAL(r,g,b:byte;c:integer); {Sets color c to red, green and b=
lue
                                         values to r,g and b}
Procedure ScrollUP(columns,attribute,y1,x1,y2,x2:Byte);{Scroll active pag=
e up}
Procedure ScrollDown(columns,attribute,y1,x1,y2,x2:Byte);
                                                     {Scroll active page =
down}
Procedure ReadXY(x,y,p:byte;var cha:char;var attrib:byte);
                {Reads attribute (attrib) and charachter (cha) from x,y f=
rom
                 page p}
Procedure PutPixel(x,y:integer;c,p:byte); {Plots a pixel to x,y with c co=
lor
                                           to p page}
Procedure GetSCRInfo(var mode,page:byte); {Saves screen mode to mode and
                                           active page to page}
Procedure ShowCursor; {Shows cursor}
Procedure HideCursor; {Hides cursor}

{-- Functions --}

Function ReadChXY(x,y,p:byte):Char; {Returns charachter from x,y from pag=
e p}
Function GetMode:Byte;var mode:byte; {Returns active video mode}
Function GetPage:Byte;var page:byte; {Returns active video page}
Function WhereX(p:byte):byte; {Returns cursor's x position from page p}
Function WhereY(p:byte):byte; {Returns cursor's y position from page p}
Function GetPixel(x,y:integer;p:byte):byte;{Returns pixel's color from pa=
ge p
                                            and from x,y position}

Implementation

Procedure ShowCursor;Assembler;
Asm
Mov ax, 0100h
Mov cx, 0506h
Int 10h
End;

Procedure HideCursor;Assembler;
Asm
Mov ax, 0100h
Mov cx, 2607h
Int 10h
End;

Procedure SetMODE(mode:byte);Begin
Asm;
mov ah,00h
mov al,mode
int 10h
end;end;

Procedure CurSIZE(top,bottom:byte);Assembler;
Asm
mov ah,01h
mov ch, top
mov cl, bottom
int 10h
end;

Procedure GotoXY(x,y,p:byte);Assembler;
Asm
Mov ah, 02h
Mov bh, p
Mov dh, y
Mov dl, x
Int 10h
End;

Function WhereX(p:byte):byte;var x:byte;
Begin Asm
Mov ah, 03h
Mov bh, p
Int 10h
Mov x, dl
End;WhereX:= x;End;

Function WhereY(p:byte):byte;var y:byte;
Begin Asm
Mov ah, 03h
Mov bh, p
Int 10h
Mov y, dl
End;WhereY:= y;End;

Procedure ShowPage(p:byte);Assembler; Asm
Mov ah, 05h
Mov al, p
Int 10h
End;

Procedure GetPAL(var r,g,b:byte;c:integer);
var r2,g2,b2:byte;
Begin
Asm
Mov ah, 10h
Mov al, 15h
Mov bx, c
Int 10h
Mov r2,dh
Mov g2,ch
Mov b2,cl
End;
r:= r2;b:= b2;g:= g2;
End;

Procedure SetPAL(r,g,b:byte;c:integer);Assembler;
Asm
Mov ah, 10h
Mov al, 10h
Mov bx, c
Mov dh, r
Mov ch, g
Mov cl, b
Int 10h
End;

Procedure ScrollUP(columns,attribute,y1,x1,y2,x2:Byte);Assembler;
Asm
Mov ah, 06h
Mov al, columns
Mov bh, attribute
Mov ch, y1
Mov cl, x1
Mov dh, y2
Mov dl, x2
Int 10h
End;

Procedure ScrollDown(columns,attribute,y1,x1,y2,x2:Byte);Assembler;
Asm
Mov ah, 07h
Mov al, columns
Mov bh, attribute
Mov ch, y1
Mov cl, x1
Mov dh, y2
Mov dl, x2
Int 10h
End;

Function ReadChXY(x,y,p:byte):Char;var x2,y2,ch:byte;Begin
x2:= WhereX(p);y2:= WhereY(p);
GotoXY(x,y,p);
Asm
Mov ah, 08h
mov bh, p
Int 10h
Mov ch, al
End;
GotoXY(x2,y2,p);
ReadChXY:= chr(ch);
End;

Procedure ReadXY(x,y,p:byte;var cha:char;var attrib:byte);
var x2,y2,ch,att:byte;Begin
x2:= WhereX(p);y2:= WhereY(p);
GotoXY(x,y,p);
Asm
Mov ah, 08h
mov bh, p
Int 10h
Mov att, ah
Mov ch, al
End;
GotoXY(x2,y2,p);
cha:= chr(ch);attrib:= att;
End;

Procedure PutPixel(x,y:integer;c,p:byte);Assembler;
Asm
Mov ah, 0Ch
Mov al, c
Mov bh, p
Mov cx, x
Mov dx, y
Int 10h
End;

Function GetPixel(x,y:integer;p:byte):byte;var c:byte;
Begin
Asm
Mov ah, 0Dh
Mov bh, p
Mov cx, x
Mov dx, y
Int 10h
Mov c, al
End;
GetPixel:= c;
End;

Function GetMode:Byte;var mode:byte;Begin
Asm
Mov ah, 0Fh
Int 10h
Mov mode, al
End;
GetMode:= Mode;
End;

Function GetPage:Byte;var page:byte;Begin
Asm
Mov ah, 0Fh
Int 10h
Mov page, bh
End;
GetPage:= Page;
End;

Procedure GetSCRInfo(var mode,page:byte);var m,p:byte;
Begin
Asm
Mov ah, 0Fh
Int 10h
Mov m, al
Mov p, bh
End;
mode:= m;page:= p;
End;

End.
