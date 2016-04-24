(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0154.PAS
  Description: Ellipse Routine
  Author: TANI HOSOKAWA
  Date: 11-26-94  04:58
*)

procedure PutPixel(X,Y: word; Color: byte); assembler;
asm
 mov ax,y
 mov bx,x
 xchg ah,al
 add bx,ax
 shr ax,1
 shr ax,1
 add bx,ax
 mov ax,0a000h
 mov es,ax
 mov al,Color
 mov es:[bx],al
end;

procedure Ellipse(X,Y,YRad,XRad: integer; Color: byte);
var
 EX,EY: integer;
 YRadSqr,YRadSqr2,XRadSqr,XRadSqr2,D,DX,DY: longint;
begin
 EX:=0;
 EY:=XRad;
 YRadSqr:=longint(YRad)*YRad;
 YRadSqr2:=2*YRadSqr;
 XRadSqr:=longInt(XRad)*XRad;
 XRadSqr2:=2*XRadSqr;
 D:=XRadSqr-YRadSqr*XRad+YRadSqr div 4;
 DX:=0;
 DY:=YRadSqr2*XRad;
 PutPixel(Y-EY,X,Color);
 PutPixel(Y+EY,X,Color);
 PutPixel(Y,X-YRad,Color);
 PutPixel(Y,X+YRad,Color);
 while (DX<DY) do begin
  if (D>0) then begin
   Dec(EY);
   Dec(DY,YRadSqr2);
   Dec(D,DY);
  end;
  Inc(EX);
  Inc(DX,XRadSqr2);
  Inc(D,XRadSqr+DX);
  PutPixel(Y+EY,X+EX,Color);
  PutPixel(Y+EY,X-EX,Color);
  PutPixel(Y-EY,X+EX,Color);
  PutPixel(Y-EY,X-EX,Color);
 end;
 Inc(D,(3*(YRadSqr-XRadSqr) div 2-(DX+DY)) div 2);
 while (EY>0) do begin
  if(D<0) then begin
   Inc(EX);
   Inc(DX,XRadSqr2);
   Inc(D,XRadSqr+DX);
  end;
  Dec(EY);
  Dec(DY,YRadSqr2);
  Inc(D,YRadSqr-DY);
  PutPixel(Y+EY,X+EX,Color);
  PutPixel(Y+EY,X-EX,Color);
  PutPixel(Y-EY,X+EX,Color);
  PutPixel(Y-EY,X-EX,Color);
 end;
end;
{ little test code }
begin
 asm
  mov ah,0
  mov al,$13
  int 10h
 end;
 Ellipse(50,50,40,20,13);
 Readln;
 asm
  mov ah,0
  mov al,$3
  int 10h
 end;
end.


