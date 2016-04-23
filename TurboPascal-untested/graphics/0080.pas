
{$g+}
program rotationalfield;
{ Source by Bas van Gaalen, Holland, PD }
uses crt,dos;
const
  gseg : word = $a000;
  dots = 459;
  dist : word = 250;
  sintab : array[0..255] of integer = (
    0,3,6,9,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58,60,63,66,68,
    71,74,76,79,81,84,86,88,91,93,95,97,99,101,103,105,106,108,110,111,
    113,114,116,117,118,119,121,122,122,123,124,125,126,126,127,127,127,
    128,128,128,128,128,128,128,127,127,127,126,126,125,124,123,122,122,
    121,119,118,117,116,114,113,111,110,108,106,105,103,101,99,97,95,93,
    91,88,86,84,81,79,76,74,71,68,66,63,60,58,55,52,49,46,43,40,37,34,31,
    28,25,22,19,16,13,9,6,3,0,-3,-6,-9,-13,-16,-19,-22,-25,-28,-31,-34,
    -37,-40,-43,-46,-49,-52,-55,-58,-60,-63,-66,-68,-71,-74,-76,-79,-81,
    -84,-86,-88,-91,-93,-95,-97,-99,-101,-103,-105,-106,-108,-110,-111,
    -113,-114,-116,-117,-118,-119,-121,-122,-122,-123,-124,-125,-126,
    -126,-127,-127,-127,-128,-128,-128,-128,-128,-128,-128,-127,-127,
    -127,-126,-126,-125,-124,-123,-122,-122,-121,-119,-118,-117,-116,
    -114,-113,-111,-110,-108,-106,-105,-103,-101,-99,-97,-95,-93,-91,
    -88,-86,-84,-81,-79,-76,-74,-71,-68,-66,-63,-60,-58,-55,-52,-49,
    -46,-43,-40,-37,-34,-31,-28,-25,-22,-19,-16,-13,-9,-6,-3);
type
  dotrec = record x,y,z : integer; end;
  dotpos = array[0..dots] of dotrec;
var dot : dotpos;

{----------------------------------------------------------------------------}

procedure setpal(col,r,g,b : byte); assembler; asm
  mov dx,03c8h; mov al,col; out dx,al; inc dx; mov al,r
  out dx,al; mov al,g; out dx,al; mov al,b; out dx,al; end;

procedure setvideo(mode : word); assembler; asm
  mov ax,mode; int 10h end;

function esc : boolean; begin
  esc := port[$60] = 1; end;

{----------------------------------------------------------------------------}

procedure init;
var i : word; x,z : integer;
begin
  i := 0;
  z := -100;
  while z < 100 do begin
    x := -100;
    while x < 100 do begin
      dot[i].x := x;
      dot[i].y := -45;
      dot[i].z := z;
      inc(i);
      inc(x,10);
    end;
    inc(z,9);
  end;
  for i := 0 to 63 do setpal(i,0,i,i);
end;

{----------------------------------------------------------------------------}

procedure rotation;
const yst = 1;
var
  xp : array[0..dots] of word;
  yp : array[0..dots] of byte;
  x,z : integer; n : word; phiy : byte;
begin
  asm mov phiy,0; mov es,gseg; cli; end;
  repeat
    asm
      mov dx,03dah
     @l1:
      in al,dx
      test al,8
      jnz @l1
     @l2:
      in al,dx
      test al,8
      jz @l2
    end;
    setpal(0,0,0,10);
    for n := 0 to dots do begin
      asm
        mov si,n
        mov al,byte ptr yp[si]
        cmp al,200
        jae @skip
        shl si,1
        mov bx,word ptr xp[si]
        cmp bx,320
        jae @skip
        shl ax,6
        mov di,ax
        shl ax,2
        add di,ax
        add di,bx
        xor al,al
        mov [es:di],al
       @skip:
      end;

      x := (sintab[(phiy+192) mod 255] * dot[n].x
     {^^^^  ^^^^^^^^^^^^^^^^^^^^^^^^^^ ^ ^^^^^^^^
      9     1                          3 2 }

            - sintab[phiy] * dot[n].z) div 128;
          { ^ ^^^^^^^^^^^^ ^ ^^^^^^^^  ^^^^^^^
            7 4            6 5         8 }

      (*
      asm
        xor ah,ah                      { 1 }
        mov al,phiy
        add al,192
        mov si,ax
        mov ax,word ptr sintab[si]
        mov si,n                       { 2 }
        mov dx,word ptr dot[si].x
        mul dx                         { 3 }
        mov cx,ax
        mov dx,word ptr dot[si].z      { 5 }
        mov al,phiy                    { 4 }
        mov si,ax
        mov ax,word ptr sintab[si]
        mul dx                         { 6 }
        sub cx,ax                      { 7 }
        shr cx,7                       { 8 }
        mov x,cx                       { 9 }
      end;
      *)

      z := (sintab[(phiy+192) mod 255]*dot[n].z+sintab[phiy]*dot[n].x) div 128;
      xp[n] := 160+(x*dist) div (z-dist);
      yp[n] := 100+(dot[n].y*dist) div (z-dist);

      {
      asm
        mov ax,x
        mov dx,dist
        mul dx
        mov dx,z
        sub dx,dist
        div dx
        add ax,160

        (* can't assign ax to xp[n] !? *)

      end;
      }

      asm
        mov si,n
        mov al,byte ptr yp[si]
        cmp al,200
        jae @skip
        shl si,1
        mov bx,word ptr xp[si]
        cmp bx,320
        jae @skip
        shl ax,6
        mov di,ax
        shl ax,2
        add di,ax
        add di,bx
        mov ax,z
        shr ax,3
        add ax,30
        mov [es:di],al
       @skip:
      end;
    end;
    asm inc phiy end;
    setpal(0,0,0,0);
  until esc;
  asm sti end;
end;

{----------------------------------------------------------------------------}

begin
  setvideo($13);
  Init;
  rotation;
  textmode(lastmode);
end.
