(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0211.PAS
  Description: Hardware Scrolling
  Author: ARNE DE.BRUIJN
  Date: 05-26-95  23:08
*)

{
> You can't scroll bits with pageflips, you can, however, do a hardware
> pixel by pixel scroll (pixel panning).

{ Example for hardware scroll, Arne de Bruijn, 1994, PD }
uses Graph,Crt;

procedure SetStart(X,Y:word); assembler;
asm
 mov dx,3dah          { Port $3DA }
 in al,dx             { Read = clear $3C0 to index }
 mov dl,0c0h          { Port $3C0 }
 mov al,33h           { Index $13 = Horiz Pixel Panning, +$20 = enable disp }
 out dx,al            { Send index }
 mov bx,X             { Calculate pixel number (lower 3 bits) }
 mov al,bl
 and al,7
 out dx,al            { Send pixel number }
 mov ax,80
 mul Y                { Offset is Y*80+(X div 8) }
 shr bx,1
 shr bx,1
 shr bx,1             { bx shr 3, is bx div 8 }
 add bx,ax
 mov dx,03d4h         { Port $3D4 }
 mov al,0ch           { Index $0C, high start }
 mov ah,bh            { Data  high byte of BX, is high byte of offset }
 out dx,ax            { Send to VGA }
 inc ax               { Index $0D, low start }
 mov ah,bl            { Data  low byte of BX, is low byte of offset }
 out dx,ax            { Send to VGA }
end;

procedure SetWidth(B:byte); assembler;
asm
 mov dx,3d4h          { Port $3D4 }
 mov al,13h           { Index $13, set display memory width }
 mov ah,B             { Data  B   }
 out dx,ax            { Send to VGA }
end;

var
 SX,SY,I:word;
 gd,gm:integer;
 a:char;
begin
 gd:=vga; gm:=vgahi;
 InitGraph(gd,gm,'e\bp\bgi'); { Init BGI and VGA to 640x480x16 }
 asm
  mov ax,0dh          { Change VGA to 320x200x16 to show scrolling }
  int 10h             { (BGI still thinks 640x480x16, so we can scroll) }
 end;
 SetWidth(40);           { Set video display memory width at 640 }
 for I:=0 to 100 do
  begin
   SetColor(Random(16));
   Line(Random(640),Random(480),Random(640),Random(480));
  end;
 SX:=0; SY:=0;
 repeat
  SetStart(SX,SY);
  a:=readkey;
  case a of
   #0:
    case readkey of
     #75:if SX>0 then Dec(SX);
     #77:if SX<639 then Inc(SX);
     #72:if SY>0 then Dec(SY);
     #80:if SY<479 then Inc(SY);
    end;
  end;
 until A=#27;
 CloseGraph;
end.

