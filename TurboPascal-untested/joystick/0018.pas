unit ujoy;

interface

Function JOYPRESENT:Boolean;
Procedure JOYINFO(var X1,Y1,X2,Y2:integer; var buttons:byte);

implementation

Function JOYPRESENT:Boolean;

var b:byte;
Begin
  b:=0;
  asm
    mov ah,$84
    mov dx,0
    int 15h
    jnc @prs
    mov b,$ff
    @prs:
  end;
  joypresent:=b=0;
End;
(*  Buttons AND 16 = 0 dann ist 1. Knopf vom 1.Joy gedrueckt *)
(*  Buttons AND 32 = 0 dann ist 2. Knopf vom 1.Joy gedrueckt *)
(*  Buttons AND 64 = 0 dann ist 1. Knopf vom 2.Joy gedrueckt *)
(*  Buttons AND 128= 0 dann ist 2. Knopf vom 2.Joy gedrueckt *)
Procedure JOYINFO(var X1,Y1,X2,Y2:integer; var buttons:byte);
var x1b,y1b,x2b,y2b:integer;
    bs:byte;
Begin
  asm
    mov dx,0
    mov ah,$84
    int 15h
    mov bs,al

    mov dx,1
    mov ah,$84
    int 15h
    mov x1b,ax
    mov y1b,bx
    mov x2b,cx
    mov y2b,dx
  end;
  x1:=x1b;
  y1:=y1b;
  x2:=x2b;
  y2:=y2b;
  buttons:=bs;
End;

end.







--------------------- cut ----------





end of mail





