{
MARCO MILTENBURG

> One cannot seek in a Text File...

Sure you can... For Dos, TextFiles are Really the same things as Typed
Files, so why don't ask Dos ;-) ?  Try this one. F is a TextFile and n is the
File-offset.
}

Procedure tSeek(Var f : Text; n : LongInt); Assembler;
Asm
  push  DS
  push  BP

  lds   SI, f
  lodsw                            { handle }
  mov   BX, AX

  mov   CX, Word ptr [BP+8]
  mov   DX, Word ptr [BP+6]

  mov   AX, 4200h              {AL = 2, AH = 42}
  int   21h

  les   DI, f
  mov   AX, DI
  add   AX, 8
  mov   DI, AX

  lodsw                            { mode }
  lodsw                            { bufsize }
  mov   CX, AX                      { CX = number of Bytes to read }
  lodsw                            { private }
  lodsw                            { bufpos  }
  lodsw                            { bufend  }
  lodsw                            { offset of Pointer to Textbuf }
  mov   DX, AX                      { DX = offset of Textbuf }
  lodsw
  mov   DS, AX                      { DS = segment of Textbuf }
  mov   AH, 3Fh
  int   21h
  push  AX                         { Save AX on stack }

  les   DI, f                       { ES:DI points to f }
  mov   AX, DI                      { Move Pointer to position 8 }
  add   AX, 8
  mov   DI, AX

  mov   AX, 0                       { Bufpos = 0 }
  stosw
  pop   AX                         { Bufend = number of Bytes read }
  stosw

  pop   BP
  pop   DS
end; { tSeek }

