program SphereMap;

{Demo of approximate sphere mapping presented in stereoscopic 3D!}
{January 31/1995 by Wil Barath.  Released to Public Domain}

Uses Hardware;

Const Size=90;
Wait:Word=Size*2;
Var
  Flambe:Array[0..Size*size] of Byte;
  Sec:Array[0..255] of byte;
  Par:Array[0..255] of Byte;

const palette : array [1..768] of byte = (
   8,   0,   0,  12,   0,   0,  17,   0,   0,  22,   0,   0,
  27,   0,   0,  31,   0,   0,  36,   0,   0,  41,   0,   0,
  45,   0,   0,  50,   0,   0,  54,   0,   0,  59,   0,   0,
  64,   0,   0,  68,   0,   0,  73,   0,   0,  77,   0,   0,
  82,   0,   0,  86,   0,   0,  90,   0,   0,  95,   0,   0,
  99,   0,   0, 103,   0,   0, 108,   0,   0, 112,   0,   0,
 116,   0,   0, 120,   0,   0, 124,   0,   0, 128,   0,   0,
 132,   0,   0, 136,   0,   0, 140,   0,   0, 144,   0,   0,
 148,   0,   0, 152,   0,   0, 155,   0,   0, 159,   0,   0,
 162,   0,   0, 166,   0,   0, 169,   0,   0, 173,   0,   0,
 176,   8,   0, 179,  12,   0, 182,  17,   0, 185,  22,   0,
 188,  27,   0, 191,  31,   0, 194,  36,   0, 197,  41,   0,
 200,  45,   0, 202,  50,   0, 205,  54,   0, 208,  59,   0,
 210,  64,   0, 212,  68,   0, 215,  73,   0, 217,  77,   0,
 219,  82,   0, 221,  86,   0, 223,  90,   0, 225,  95,   0,
 226,  99,   0, 228, 103,   0, 230, 108,   0, 231, 112,   0,
 233, 116,   0, 234, 120,   0, 235, 124,   0, 236, 128,   0,
 237, 132,   0, 238, 136,   0, 239, 140,   8, 240, 144,  12,
 241, 148,  17, 241, 152,  22, 242, 155,  27, 242, 159,  31,
 243, 162,  36, 243, 166,  41, 243, 169,  45, 243, 173,  50,
 243, 176,  54, 243, 179,  59, 243, 182,  64, 242, 185,  68,
 242, 188,  73, 241, 191,  77, 241, 194,  82, 240, 197,  86,
 239, 200,  90, 238, 202,  95, 237, 205,  99, 236, 208, 103,
 235, 210, 108, 234, 212, 112, 233, 215, 116, 231, 217, 120,
 230, 219, 124, 228, 221, 128, 227, 223, 132, 225, 225, 136,
 223, 226, 140, 221, 228, 144, 219, 230, 148, 217, 231, 152,
 215, 233, 155, 213, 234, 159, 210, 235, 162, 208, 236, 166,
 205, 237, 169, 203, 238, 173, 200, 239, 176, 197, 240, 179,
 195, 241, 182, 192, 241, 185, 189, 242, 188, 186, 242, 191,
 183, 243, 194, 179, 243, 197, 176, 243, 200, 173, 243, 202,
 170, 243, 205, 166, 243, 208, 163, 243, 210, 159, 242, 212,
 155, 242, 215, 152, 241, 217, 148, 241, 219, 144, 240, 221,
  22,  10, 120,  27,  10, 120,  32,  10, 120,  37,  10, 120,
  41,  10, 120,  46,  10, 120,  51,  10, 120,  55,  10, 120,
  60,  10, 120,  64,  10, 120,  69,  10, 120,  74,  10, 120,
  78,  10, 120,  83,  10, 120,  87,  10, 120,  92,  10, 120,
  96,  10, 120, 100,  10, 120, 105,  10, 120, 109,  10, 120,
 113,  10, 120, 118,  10, 120, 122,  10, 120, 126,  10, 120,
 130,  10, 120, 134,  10, 120, 138,  10, 120, 142,  10, 120,
 146,  10, 120, 150,  10, 120, 154,  10, 120, 158,  10, 120,
 162,  10, 120, 165,  10, 120, 169,  10, 120, 172,  10, 120,
 176,  10, 120, 179,  10, 120, 183,  10, 120, 186,  18, 120,
 189,  22, 120, 192,  27, 120, 195,  32, 120, 198,  37, 120,
 201,  41, 120, 204,  46, 120, 207,  51, 120, 210,  55, 120,
 212,  60, 120, 215,  64, 120, 218,  69, 120, 220,  74, 120,
 222,  78, 120, 225,  83, 120, 227,  87, 120, 229,  92, 120,
 231,  96, 120, 233, 100, 120, 235, 105, 120, 236, 109, 120,
 238, 113, 120, 240, 118, 120, 241, 122, 120, 243, 126, 120,
 244, 130, 120, 245, 134, 120, 246, 138, 120, 247, 142, 120,
 248, 146, 120, 249, 150, 120, 250, 154, 120, 251, 158, 120,
 251, 162, 120, 252, 165, 120, 252, 169, 120, 253, 172, 120,
 253, 176, 120, 253, 179, 120, 253, 183, 120, 253, 186, 120,
 253, 189, 120, 253, 192, 120, 252, 195, 120, 252, 198, 120,
 251, 201, 120, 251, 204, 120, 250, 207, 120, 249, 210, 120,
 248, 212, 120, 247, 215, 120, 246, 218, 120, 245, 220, 120,
 244, 222, 120, 243, 225, 120, 241, 227, 120, 240, 229, 120,
 238, 231, 120, 237, 233, 120, 235, 235, 120, 233, 236, 120,
 231, 238, 120, 229, 240, 120, 227, 241, 120, 225, 243, 120,
 223, 244, 120, 220, 245, 120, 218, 246, 120, 215, 247, 120,
 213, 248, 120, 210, 249, 120, 207, 250, 120, 205, 251, 120,
 202, 251, 120, 199, 252, 120, 196, 252, 120, 193, 253, 120,
 189, 253, 120, 186, 253, 120, 183, 253, 120, 180, 253, 120,
 176, 253, 120, 173, 253, 120, 169, 252, 120, 165, 252, 120,
 162, 251, 120, 158, 251, 120, 154, 250, 120,  32,  20, 120);

  a:Word=$0123;
  b:Word=$4567;
  c:Word=$89ab;

Function Qrand:Word; Near ;Assembler;
asm
 Mov ax,a                { generate a pseudorandom   }
  Shl ax,1                { sequence to seed the base }
  Adc ax,2904             { of our great pyre with  }
  Xor ax,$aaaa
  Mov a,ax
 Adc ax,b
  Mov b,ax
  Adc ax,c
  Mov c,ax
end;

Function QRandom(n:Word):Word;near;assembler;
asm
  call Qrand
  Mul  n
  Mov  ax,dx
end;

Procedure SetCGA256Clear;near;Assembler;
asm
  CLD
  mov   ax,13h            { AX:= 13h                  }
  int   10h              { Set Mode 13h (320x200x256)}
  xor   ax,ax             { AX:= 0                    }
  mov   cx,768            { CX:= # of palette entries }
  mov   dx,03C8h          { DX:= VGA Port             }
  mov   si,offset palette { SI:= palette[0]           }
  out   dx,al             { send zero to index port   }
  inc   dx                { inc to write port         }
@l1:
  mov   bl,[si]           { set palette entry         }
  shr   bl,2              { divide by 4               }
  mov   [si],bl           { save entry                }
  outsb                   { and write to port         }
  dec   cx                { CX:= CX - 1               }
  jnz   @l1               { if not done then loop     }
  mov   ax,0a000h       { AX:= segment of VGA base  }
  mov   es,ax             { ES:= AX                   }
  mov   di,0         { DI:= 0  
             }
  mov   cx,32000          { CX:= sizeof(Screen) div 2 }
  xor  ax,ax           { AX:= 0                   
 }
  rep   stosw             { clear every byte on screen to zero  }
end;

Procedure DoInferno;
Var p,d:Word;
Begin
  If wait>0 then Dec(Wait) else
  Begin
    For p:=2 to Size*Pred(size) do
    Begin
      d:=Flambe[p]shl 1+Flambe[p+Pred(size)]+Flambe[p+Succ(size)]+
      Flambe[p+Size]shl 2;
      if d>0 then flambe[p-2]:=Pred(d) shr 3;
    end;
    d:=QRand AND $7f or $20;
    For p:=Size*Pred(size) to Size*size do
    Begin
      If Qrand>$f000 then d:= QRand AND $7f or $20;
      FLambe[p]:=d;
    end;
  end;
end;

procedure CalcCircle(r:Word);
var rr,xx,yy,x,y:Integer; {r *must* be <= 128}
begin
  rr:=r;y:=0;x:=r;rr:=r*r;xx:=rr-x;yy:=0;
  Repeat
    Sec[r-y]:=x;
    Sec[r-x]:=y;
    Sec[r+x]:=y;
    Sec[r+y]:=x;        {chord lengths per sector}
    if xx>(rr-yy) then
    Begin
      Inc(xx,1-x-x);dec(x);
    end;
    Inc(yy,y+y+1);inc(y);
  Until x<y;            {sneaky mix of secant and scaling}
  For x:=0 to r do Par[x div 2]:=(x*2+sec[x]*3) div 5;
  For x:=r to r+r do Par[x div 2]:=(r*6-sec[x]*3+x*2+3) div 5;
end;{}


Procedure SphereMap2(PMAP:Pointer;sx,sy,cx,cy,Shift:Word);
Type SNeaky = Record part1:Byte; Data:Word; Part2:Byte;End;
A = Array[0..64000] of Byte;
PA =^a;

Var loop:Integer;Width,Scale,Image:LongInt;p,x:Word;
Begin
  Inc(LongInt(pMap),Shift);
  For Loop:= 0 to sy do
    Begin
      Width:=Sec[Loop]+1;
      Image:=0;
      p:=(cy-sy shr 1 +Loop)*320+cx-width;
      Inc(width,width);
      scale:=sx;scale:=scale*128 div width;
      For x:=p to p+width do
        Begin
          Mem[$a000:x]:=PA(PMap)^[Par[Sneaky(image).data]];
          Inc(Image,Scale);
        end;
      Inc(Longint(pMap),sx);
    end;
end;

Var lp:Integer;

Begin {Program}
  SetCGA256Clear;
  CalcCircle(Size Div 2);
  For lp:=0 to size * size do Flambe[lp]:=(((lp div size) mod 10) + (lp mod 
10))shl 2;
 Repeat
   DoInferno;
   SphereMap2(@Flambe,Size,Size,100,100,size-(Wait Mod Size));
   SphereMap2(@Flambe,Size,Size,220,100,size-(Wait Mod Size)-10);
  until keypressed;
asm
  mov ax,03h              { AX := 3h                  }
  int 10h                 { restore text mode         }
end;

end.
