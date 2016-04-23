
{
checking for drive ready?

Here's something that I fiddled arround. It is still noisy but
thought you may want to see it.
}

uses
 Crt, Dos;

function DriveReady(Drive : Byte) : Boolean; assembler;
{ a=0, b=1, etc.  Shouldn't work at all on hard drives !! }
var
 Buffer : array[1..512] of Byte;
 N      : Byte;

asm
 mov [N],3         { retry 3 times }
@10:
 mov ax,$0401
 mov cx,$0001
 mov dh,$00
 mov dl,[Drive]
 push ss
 pop es
 lea bx,[Buffer]
 int $13
 mov al,FALSE
 jnc @20
 dec [N]
 jnz @10
 jmp @30
@20:
 or ah,ah
 jnz @30
 mov al,TRUE
@30:
end;

begin
 ClrScr;
 repeat
  writeln(^G'Drive Ready = ', DriveReady(0));
  Mem[$40:$40]:=255;
  Delay(2000);
 until (KeyPressed);
 Mem[$40:$40]:=1;  { shut motors }
end.
