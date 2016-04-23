{
From: Frans@frp.idn.nl (Frans Postma)

> Does anyone know of some Pascal source code to increase the
> size of the  keyboard buffer?

Following unit enlarges keyboard buffer to hold 127 characters (max) and
you can stuff a string in it (max. length 127 chars) and that string will
be executed after your program has ended.
}
Unit frp_key;
{keyboard unit}
{$V-,R-,S-}

{ Written by Frans Postma
             Fido: 2:282/500.17
             Internet: frans@frp.idn.nl (preferred)
                    OR frp@fahp425y.med.rug.nl

 I don't promise this unit will work, only that it will consume some
 diskspace. If you happen to find some bugs, feel free to mail me..

 You use this unit at your own risc.
 This unit is hereby placed in the Public Domain.

 ...and that's enough legal bla-bla :-) Enjoy.
}

{$IFDEF DPMI}
  Yell! Do Not compile With DPMI!! Not tested yet!!!
  (It should work with DPMI though, just didn't test/need it)
{$ENDIF}

{ How to stuff 127 characters into the keyboardbuffer.
    Since the normal keyboardbuffer only stores 15 characters, we need to
    get ourselves a new (larger) buffer. Therefore we relocate the current
    buffer to adress $0134 (max. size then becomes 127 since every
    character needs two bytes). We do that by changing the pointers to the
    keyboardbuffer. Those pointers are at $0080 and $0082 resp. , change
    those and all should work...}

Interface

Type BufSize = 0..127;

Procedure PutBuffer (stx: String);
Function  GetBufSize: BufSize;
Procedure SetBufSize (Size: BufSize);
Procedure ClearBuffer;

Implementation

Const Segm    = $0040; { segment adress of HeadPtn etc. }
      OldAdr  = $001E;
      HeadPtn = $001A;
      TailPtn = $001C;
      NewAdr  = $0134; {adress of the new extended keyboardbuffer}
      BegBuf  = $0080; {these two ptr point to the start/end of the}
      EndBuf  = $0082; {keyboardbuffer}

Var Buffer: Word;

Procedure ClearBuffer;
{Make start/end equal, dirty trick to clear the buffer}

Begin
  MemW [Segm: TailPtn] := Buffer;
  MemW [Segm: HeadPtn] := Buffer
End;

Procedure SetBufSize (Size: BufSize);
{ This procedure sets the size of the keyboard-buffer, max. = 127 }
{ If you manage to set it bigger then 127, you'll overwrite God knows what}
{   so that's NOT recommended :-) }

Begin
  Case Size Of
    1..15: Buffer := OldAdr; {no need to change here}
    16..127: Buffer := NewAdr;
  End;
  MemW [Segm: BegBuf] := Buffer;
  MemW [Segm: EndBuf] := Buffer + (2 * Size) + 2;
  ClearBuffer; {since we changed it, we must clean it up}
End;

Function GetBufSize: BufSize;

Begin
  GetBufSize := ( (MemW [Segm: EndBuf] - MemW [Segm: BegBuf] ) Div 2) - 1 End;


Procedure PutBuffer (stx: String);
{ This procedure puts the given string into the keyboard-buffer. If there's
  no room in the buffer for the entire string, only part of string is copied
  (no overflow will occur, it'll simple stop copying)
}

Var i, j, avail: Byte; {avail is 0..127, so byte is enough}

Begin
  i := 1; j := 0;
  avail := GetBufSize;
  While (i <= Length (stx) ) And (i < Avail) Do
  Begin
    Mem [Segm: Buffer + j] := Ord (stx [i] ); {put keycode}
    Mem [Segm: Buffer + j + 1] := 0;          {ignore scancode}
    Inc (i);
    j := j + 2;
  End;
  Dec (i); {we entered i-1 keys into the stack}
  MemW [Segm: TailPtn] := Buffer + (i * 2); {update pointer stuff}
  MemW [Segm: HeadPtn] := Buffer
End;

Begin {unit}
{ since this part is auto-executed when you run your program you might wish
  to leave it out }
  SetBufSize (127); {set buffer to max}
End.


