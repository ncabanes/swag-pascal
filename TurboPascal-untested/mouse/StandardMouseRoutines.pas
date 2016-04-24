(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0030.PAS
  Description: Standard Mouse Routines
  Author: BJARKE VIKSOE
  Date: 09-04-95  10:54
*)

UNIT MOUSE;
{
	Mouse
	- by Bjarke Viksoe

	One of the standard "hey, I can handle the mouse, too" units.
}


INTERFACE

function InitMouse : boolean;
{Initialize mouse to its default values for current screenmode.
 Mouse is turned off.
 Returns TRUE if mouse is present.}
function MouseDriverPresent : boolean;
{Returns TRUE if there were a mouse driver out there...}
procedure MouseOn;
{Turns mouse image on}
procedure MouseOff;
{Turns mouse image off}
procedure MouseInfo(VAR x,y : integer; VAR lb,rb : boolean);
{Get information about current x- and y-positions.
 Also return info about current status of mouse buttons}
function LeftButton : boolean;
{Retuns TRUE if left mouse button is pressed}
function RightButton : boolean;
{Retuns TRUE if right mouse button is pressed}
procedure LastButtonPress(button : integer; VAR x,y : integer);
{Returns last x/y mouse pos when 'button' was pressed}
procedure LastButtonRelease(button : integer; VAR x,y : integer);
{Returns last x/y mouse pos when 'button' was released}
procedure SetMousePos(x,y : integer);
{Set mouse position on screen...}
procedure SetMouseWindow(x1,y1,x2,y2 : integer);
{Set mouse window limit}
procedure SetMouseImage(hotx,hoty : integer; Image : pointer);
{Change mouse pointer image.
 "Hot?" ranges from -16 to 16
 "Image" is 16 words of mask + 16 words of image}
procedure ReadMouseMotionCounters(VAR x,y : integer);
{Read mouse's motion counters}
procedure DefineMouseRatio(h,v : word);
{Change mouse Mickey/pixel ratio}


IMPLEMENTATION

function InitMouse : boolean; assembler;
asm
	xor	ax,ax
	int	$33
	not	ax
	xor	ax,1
	and	ax,1
end;

function MouseDriverPresent : boolean; assembler;
asm
	mov	ax,$21 {try to reset mouse}
	int	$33
	cmp	ax,-1
	je		@found
	mov	ax,$0	{not there. might be bad driver version... try setup mouse}
	int	$33
	push	ax
	mov	ax,$2	{quickly hide it again}
	int	$33
	pop	ax
@found:
	inc	ax
	xor	ax,1
end;

procedure MouseOn; assembler;
asm
	mov	ax,$0001
	int	$33
end;

procedure MouseOff; assembler;
asm
	mov	ax,$0002
	int	$33
end;

procedure MouseInfo(VAR x,y : integer; VAR lb,rb : boolean); assembler;
asm
	mov	ax,$0003
	int	$33
	les	si,x
	mov	[es:si],cx
	les	si,y
	mov	[es:si],dx

	mov	ax,bx
	and	al,1
	les	si,lb
	mov	[es:si],al
	shr	bl,1
	and	bl,1
	les	si,rb
	mov	[es:si],bl
end;

function LeftButton : boolean; assembler;
asm
	mov	ax,3
	int	$33
	mov	ax,bx
	and	ax,1
end;

function RightButton : boolean; assembler;
asm
	mov	ax,3
	int	$33
	mov	ax,bx
	shr	ax,1
	and	ax,1
end;

procedure LastButtonPress(button : integer; VAR x,y : integer); assembler;
asm
	mov	ax,5
	mov	bx,button
	int	$33
	les	di,x
	mov	[es:di],cx
	les	di,y
	mov	[es:di],dx
end;

procedure LastButtonRelease(button : integer; VAR x,y : integer); assembler;
asm
	mov	ax,6
	mov	bx,button
	int	$33
	les	di,x
	mov	[es:di],cx
	les	di,y
	mov	[es:di],dx
end;

procedure SetMousePos(x,y : integer); assembler;
asm
	mov	ax,$0004
	mov	cx,x
	mov	dx,y
	int	$33
end;

procedure SetMouseWindow(x1,y1,x2,y2 : integer); assembler;
asm
	mov	ax,$0007
	mov	cx,x1
	mov	dx,x2
	int	$33
	mov	ax,$0008
	mov	cx,y1
	mov	dx,y2
	int	$33
end;

procedure SetMouseImage(hotx,hoty : integer; Image : pointer); assembler;
asm
	mov	ax,$0009
	mov	bx,hotx
	mov	cx,hoty
	les	dx,Image
	int	$33
end;

procedure DefineMouseRatio(h,v : word); assembler;
asm
	mov	ax,$000F
	mov	cx,h
	mov	dx,v
	int	$33
end;

procedure ReadMouseMotionCounters(VAR x,y : integer); assembler;
asm
	mov	ax,$000B
	int	$33
	les	di,x
	mov	[es:di],cx
	les	di,y
	mov	[es:di],dx
end;


end.

