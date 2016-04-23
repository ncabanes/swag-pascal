{
 > Does anyone know how to increase the size of the keyboard buffer? I need
 > to be able to pump out more than 16 bytes to the buffer.

This is a resident utility I wrote myself for this purpose.

It has to be loaded in conventional memory (NOT LoadHigh) at an address lower
than $10400, preferrably immediately after Keyb.com.

One warning: there may be programs around (very old XT-programs, or bad
programs), which will try to access the keyboard buffer at it's standard
address $40:$1E. If you use one of these programs, the machine will crash.
}

{*********************************************
 * Installs keyboard buffer of any size      *
 * Usage: bigkey [bufparas]                  *
 * Bufparas: desired size of keyboard buffer *
 *           in paragraphs (16 bytes)        *
 *           default : 10 <-> 79 chars       *
 *                                           *
 * The size of the resident program will be  *
 * 96 bytes + buffer size.                   *
 *                                           *
 * Horst Kraemer  2:2410/121.16@fidonet.org  *
 * 30.06.92                                  *
 *********************************************}

program bigkey;

uses
  dos;

const
  PSPOffset=6;

var
  KeyBufTail  : word absolute $40:$1A;
  KeyBufHead  : word absolute $40:$1C;
  KeyBufStart : word absolute $40:$80;
  KeyBufEnd   : word absolute $40:$82;
  EnvSeg,Dist,BufParas,Code:word;

procedure usage;
begin
  writeln('Usage: bigkey [bufparas]');
  writeln('bufparas: size of buffer in paragraphs (>2)');
  writeln('          default : 10 <-> 79 chars');
  halt(1)
end;

begin
  if paramcount>1 then Usage;
  if paramcount=0 then
    BufParas:=10
  else begin
    val(paramstr(1),BufParas,Code);
    if (Code<>0) or (BufParas<=2) then Usage
  end;

  Dist:=prefixseg+PSPOffset-$40; {Distance BIOS segment <-> start of buffer}

  if Dist+BufParas >= $1000 then begin
    writeln('End of buffer not in BIOS segment');
    Halt(1)
  end
  else
    writeln('Buffer for ',BufParas*8-1,' characters installed');

  Dist:=Dist shl 4; {Offset of buffer relative to BIOS segment}

  asm cli end;
  KeyBufTail  := Dist;
  KeyBufHead  := Dist;
  KeyBufStart := Dist;
  KeyBufEnd   := Dist + BufParas shl 4;
  asm sti end;

  { Free environment and leave only
    keyboard buffer in memory
  }
  swapvectors;
  envseg:=memw[prefixseg:$2c];
  asm
    mov es,envseg
    mov ah,49h
    int 21h
    mov dx,PSPOffset
    add dx,BufParas
    mov ax,3100h
    int 21h
  end;
end.
