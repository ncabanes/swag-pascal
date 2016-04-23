

{-  Yet another implementation (part of my own library): }
{-  Built-in assembler used                              }

const
 hex : array[0..$F of Char;

function Byte2Hex( B : Byte) : String; assembler;
asm
 les di,@Result
 mov al,2
 stosb
 mov bl,B
 xor bh,bh
 mov dl,bl
 shr bl,1
 shr bl,1
 shr bl,1
 shr bl,1
 mov al,byte ptr hex[bx]
 mov bl,dl
 and bl,$F
 mov ah,byte ptr hex[bx]
 stosw
end;

function Word2Hex( W : Word) : String; assembler;
asm
 les di,@Result
 mov al,4
 stosb
 mov bx,W
 mov dx,bx
 mov bl,bh
 xor bh,bh
 mov cl,4
 shr bx,cl
 mov al,byte ptr hex[bx]
 mov bl,dh
 and bx,$F
 mov ah,byte ptr hex[bx]
 stosw
 mov bl,dl
 xor bh,bh
 mov cl,4
 shr bx,cl
 mov al,byte ptr hex[bx]
 mov bl,dl
 and bx,$F
 mov ah,byte ptr hex[bx]
 stosw
end;

function Long2Hex( L : LongInt) : String; assembler;
asm
 les di,@Result
 mov al,8
 stosb
 mov bx,word ptr L[2]
 mov bl,bh
 xor bh,bh
 mov cl,4
 shr bx,cl
 mov al,byte ptr hex[bx]
 stosb
 mov bx,word ptr L[2]
 mov bl,bh
 and bx,$F
 mov al,byte ptr hex[bx]
 stosb
 mov bx,word ptr L[2]
 xor bh,bh
 mov cl,4
 shr bx,cl
 mov al,byte ptr hex[bx]
 stosb
 mov bx,word ptr L[2]
 and bx,$F
 mov al,byte ptr hex[bx]
 stosb
 mov bx,word ptr L
 mov bl,bh
 xor bh,bh
 mov cl,4
 shr bx,cl
 mov al,byte ptr hex[bx]
 stosb
 mov bx,word ptr L
 mov bl,bh
 and bx,$F
 mov al,byte ptr hex[bx]
 stosb
 mov bx,word ptr L
 xor bh,bh
 mov cl,4
 shr bx,cl
 mov al,byte ptr hex[bx]
 stosb
 mov bx,word ptr L
 and bx,$F
 mov al,byte ptr hex[bx]
 stosb
end;

{-  But most reasonable way   (for Word parameter)        }
{-  Note: You must declare DRIVERS unit in USES statement }

function HexWord( W : Word) : String;
var
 p : array[0..0] of LongInt;
 s : String;
begin
 p[0] := W;
 FormatStr(s, '%04x', p);
 HexWord := s;
end;

{-  Example for CRC16 (You can simple expand it for 32): }

function CRC16_To_Str( CRC : Word) : String;
const
 hex : array[0..$F] of Char = '0123456789ABCDEF';
var
 s : String;
begin
 s[0] := #4;                 {- length of string }
 s[1] := Hex[CRC div $1000];
 s[2] := Hex[(CRC mod $1000) div $100];
 s[3] := Hex[(CRC mod $100) div $10];
 s[4] := Hex[CRC mod $10];
 CRC16_To_Str := s;
end;
