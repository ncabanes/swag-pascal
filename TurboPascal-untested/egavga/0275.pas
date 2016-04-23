
{ Display EGA palette (works only on VGA), Arne de Bruijn, Public Domain }
function EgaPal(I:byte):byte; assembler;
asm
 mov dx,3dah
 in al,dx         { Clear 3c0h flipflop }
 mov dl,0c0h      { Set port no to 3c0h }
 mov al,I
 out dx,al        { Write palette no to read, turns off screen }
 inc dx           { Port 3c1h }
 in al,dx         { Read color }
 push ax          { Save }
 mov dl,0dah      { Again clear flipflop }
 in al,dx
 mov dl,0c0h
 mov al,32        { And turn on screen }
 out dx,al
 pop ax           { Restore color }
end;

var
 I:byte;
begin
 for I:=0 to 15 do
  WriteLn(I:2,'. ',EgaPal(I));
end.
