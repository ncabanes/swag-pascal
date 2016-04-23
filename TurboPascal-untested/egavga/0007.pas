{
 Here is some code to try For Text fading on a vga...
 by Sean Palmer
}

Const
  tableReadIndex    = $3C7;
  tableWriteIndex   = $3C8;
  tableDataRegister = $3C9;

Procedure setColor(color, r, g, b : Byte); Assembler;
Asm {set DAC color}
  mov dx, tableWriteIndex;
  mov al, color;
  out dx, al;
  inc dx;
  mov al, r;
  out dx, al;
  mov al, g;
  out dx, al;
  mov al, b;
  out dx, al;
end; {Write index now points to next color}

Function getColor(color : Byte) : LongInt; Assembler;
Asm {get DAC color}
  mov dx, tableReadIndex;
  mov al, color;
  out dx, al;
  add dx, 2;
  cld;
  xor bh, bh;
  in al, dx;
  mov bl, al;
  in al, dx;
  mov ah, al;
  in al, dx;
  mov dx, bx;
end; {read index now points to next color}

