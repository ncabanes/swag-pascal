(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0058.PAS
  Description: ASM Bit Functions
  Author: WILLIAM BARATH
  Date: 11-26-94  05:09
*)

(***********************************************************************
 BitFuncs: Bit manipulation TPU, (C) September 1994 by William Barath
       Free for use in commercial and non-commercial software.
          Compile with $s-,g+ and optional word alignment
(**********************************************************************)
Unit BitFuncs; Interface
Const Bits:array[0..7] of Byte = ($1,$2,$4,$8,$10,$20,$40,$80);
Procedure SetBitA(var a;Bit:Word);
Procedure ClearBitA(var a;Bit:Word);
Procedure InvertBitA(var a;Bit:Word);
Function  GetBitA(var a;Bit:Word):Boolean;
Procedure SetBit(var a;Bit:Word);
Procedure ClearBit(var a;Bit:Word);
Procedure InvertBit(var a;Bit:Word);
Function  GetBit(a:Byte;Bit:Word):Boolean;
Implementation
Procedure SetBitA(var a;Bit:Word);assembler;
asm
  Les di,a              {get variable reference}
  Mov si,bit            {get bit offset}
  Mov bx,si             {index into memory with bit Div 8}
  And si,07h            {and index into 'bits' with bit Mod 8}
  Shr bx,03h
        Mov al,Byte(Bits[si]) {get the bit mask}
  Or  es:[di+bx],al     {read, modify, and write back the data}
end;
Procedure ClearBitA(var a;Bit:Word);assembler;
asm
  Les di,a
  Mov si,bit
  Mov bx,si
  And si,07h
  Shr bx,03h
  Mov al,Byte(Bits[si])
  Not al                {invert the bit mask}
  And es:[di+bx],al     {mask off the selected bit}
end;
Procedure InvertBitA(var a;Bit:Word);assembler;
asm
  Les di,a
  Mov si,bit
  Mov bx,si
  And si,07h
  Shr bx,03h
  Mov al,Byte(Bits[si])
  Xor es:[di+bx],al     {invert the selected bit}
end;
Function GetBitA(var a;Bit:Word):Boolean;assembler;
asm
  Les di,a
  Mov si,bit
  Mov bx,si
  And si,07h
  Shr bx,03h
  Mov al,Byte(Bits[si])
  And al,es:[di+bx]     {return the selected bit without writing}
end;
Procedure SetBit(var a;Bit:Word);assembler;
asm
  Les di,a              {get variable reference}
  Mov si,bit            {get bit offset}
  Mov al,Byte(Bits[si]) {get the bit mask}
  Or  es:[di],al        {read, modify, write...}
end;
Procedure ClearBit(var a;Bit:Word);assembler;
asm
  Les di,a
  Mov si,bit
  Mov al,Byte(Bits[si])
  Not al
  And es:[di],al
end;
Procedure InvertBit(var a;Bit:Word);assembler;
asm
  Les di,a
  Mov si,bit
  Mov al,Byte(Bits[si])
  Xor es:[di],al
end;
Function GetBit(a:byte;Bit:Word):Boolean;assembler;
asm
  Mov al,a              {expect the data on the stack}
  Mov si,bit            {get the bit index}
  And al,Byte(Bits[si]) {mask data with bitmask and return it}
end;
end.

