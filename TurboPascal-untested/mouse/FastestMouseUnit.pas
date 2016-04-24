(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0046.PAS
  Description: Fastest Mouse unit
  Author: CYBORG@SUPERNEWS.COM
  Date: 08-30-97  10:08
*)

{
here is the fastest mouse unit you will ever find , tell me if its good for
the swag files : }

unit UdiMouse;


interface 
 
uses dos; 
 
var 
  regs:registers; 
  Ins:integer; 
  Left,Right,mx,my:integer; 
  Install:boolean; 
(*****************************************************************************) 
{ checks is a mouse is installed. returns <install:boolean>.                 
} 
(*****************************************************************************)
Procedure CheckInstalled; 
(*****************************************************************************) 
{ initializes the mouse.should always be present in the beginning of the
code.} 
(*****************************************************************************) 
Procedure InitMouse; 
(*****************************************************************************) 
{shows the mouse cursor.should always be present in the beginning of the
code.}
(*****************************************************************************) 
Procedure MouseOnn; 
(*****************************************************************************) 
{ hides the mouse cursor.                                                    
} 
(*****************************************************************************) 
Procedure MouseOff; 
(*****************************************************************************) 
{ returns the mouse position in MX and MY.                                                
} 
(*****************************************************************************) 
Procedure GetMouse; 
(*****************************************************************************) 
{ places the mouse in a certain place.                                       
} 
(*****************************************************************************) 
Procedure SetMouse(X,Y:integer); 
(*****************************************************************************) 
{ true if the left button is pressed.                                        
}
(*****************************************************************************) 
Function  LeftPressed:boolean; 
(*****************************************************************************) 
{ true if the right button is pressed.                                       
} 
(*****************************************************************************) 
Function  RightPressed:boolean; 
(*****************************************************************************) 
{ sets the horizontal range , minimum point and maximum point.               
} 
(*****************************************************************************) 
Procedure HorizRange(Min,Max:integer); 
(*****************************************************************************) 
{ sets the vertical range , minimum and maximum.                             
} 
(*****************************************************************************) 
Procedure VertRange(Min,Max:integer); 
(*****************************************************************************) 
{ sets the mouse sensitivity , horizontal speed and vertical speed.          
}
(*****************************************************************************) 
Procedure SetSens(Horiz,Vert:integer); 
 
implementation 
 
Procedure CheckInstalled; 
 begin 
  asm 
   mov ax,0000h 
   int 33h 
   mov ins,ax 
  end; 
  if ins=0 then install:=false else install:=true; 
 end; 
 
Procedure InitMouse; assembler; 
  asm 
   mov ax,0000h 
   int 33h 
  end;
 
Procedure MouseOnn; ASSEMBLER; 
 asm 
  mov ax,0001h 
  int 33h 
 end; 
 
Procedure MouseOff; ASSEMBLER; 
 asm 
  mov ax,0002h 
  int 33h 
 end; 
 
procedure GetMouse; ASSEMBLER; 
  asm 
   mov ax,0003h 
   int 33h 
   mov mx,cx 
   mov my,dx 
  end;
 
Procedure SetMouse(X,Y:integer); ASSEMBLER; 
  asm 
   mov cx,y 
   mov dx,x 
   mov ax,0004h 
   int 33h 
  end; 
 
Function LeftPressed:boolean; 
 begin 
  LeftPressed:=false; 
  asm 
  mov ax,0003h 
  int 33h 
  and bx,01h 
  mov left,bx 
  end; 
  if Left<>0 then LeftPressed:=true; 
 end;
 
Function RightPressed:boolean; 
 begin 
  RightPressed:=false; 
  asm 
  mov ax,0003h 
  int 33h 
  and bx,02h 
  mov right,bx 
  end; 
  if Right<>0 then RightPressed:=true; 
 end; 
 
Procedure HorizRange(Min,Max:integer);  ASSEMBLER; 
  asm 
  mov cx,min 
  mov dx,max 
  mov ax,0007h 
  int 33h 
  end;
 
Procedure VertRange(Min,Max:integer); ASSEMBLER; 
  asm 
  mov cx,min 
  mov dx,max 
  mov ax,0008h 
  int 33h 
  end; 
 
Procedure SetSens(Horiz,Vert:integer); ASSEMBLER; 
 asm 
  mov bx,horiz 
  mov cx,vert 
  mov ax,001ah 
  int 33h 
 end; 
BEGIN 
 
END. 

