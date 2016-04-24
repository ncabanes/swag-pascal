(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0121.PAS
  Description: Assembler to get String Length
  Author: VARIOUS
  Date: 02-21-96  21:04
*)

{
 JP> How do you get the length of a string using assembler? I've tried
 JP> this, but it doesn't work. I was told the first two bytes hold the
 JP> string length. Is this correct?
}

function len(s : string) : byte; assembler;
asm
  les di,s
  mov al,es:byte ptr [di]
end;

or this:

function len(s : string) : byte; assembler;
asm
  push ds
  lds si,s
  mov al,byte ptr [si]
  pop ds
end;

{PETER LOUWEN,Re: Assembler to get leng}

FUNCTION Len1(CONST Str: STRING): byte; ASSEMBLER;
ASM push ds
    lds si, Str   { -- DS:SI now holds @Str. }
    lodsb         { -- AL := (DS:SI)^.       }
    pop ds
END;

FUNCTION Len2(CONST Str: STRING): byte; ASSEMBLER;
ASM les di, Str         { -- ES:DI now holds @Str. }
    mov al, es:[di]     { -- AL := (ES:DI)^.       }
END;

The second method is slightly faster on my machine.

