{
 BZ> I was wondering if anyone has, or would mind writing a assembler
 BZ> version of the Mem, MemW, and MemL functions.  Delphi does not
 BZ> include these routines and I would really like to get them back.

here is an asm of mem.. you can modify it for memw and meml.. }

procedure(segment_,offset_: word; variable : byte); assembler;
asm
  mov ax,segment_
  push ax
  mov di,offset_
  pop es
  mov es:byte ptr [di],variable
end;

{Actually, they are built in arrays.  Since pascal does not allow
operator overloading, this is as close as you can get: }

function ReadMem (address : longint) : byte; assembler;
asm
  les di, address;
  mov al, es:[di];
end;

procedure WriteMem (address : longint; val : byte); assembler;
asm
  les di, address;
  mov al, val;
  stosb;
end;

function ReadMemW (address : longint) : word; assembler;
asm
  les di, address;
  mov ax, es:[di];
end;

procedure WriteMemW (address : longint, val : word); assembler;
asm
  les di, address
  mov ax, val;
  stosw;
end;

function ReadMemL (address : longint) : longint; assembler;
asm
  les di, address;
  mov dx, word ptr es:[di];
  mov ax, word ptr es:[di + 1];
end;

procedure WriteMemL (address : longint, val : longint); assembler;
asm
  les di, address;
  mov bx, offset val;
  mov ax, word ptr [bx]
  stosw;
  mov ax, word ptr [bx + 1];
  stosw;
end;

For these, address is segment in high word, offset in low word.  To get
a segment into the high word, shift it left by 8.  For example, to store
the VGA video segment, you would do:
address := $A000 SHL 8;
Then just add the offset:
address := address + youroffset;

You may also use a pointer as the address (Pascal stores pointers in the
proper format).

Mike Phillips
INTERNET:  phil4086@utdallas.edu


GARY KING

PROCEDURE write_byte(segm,offs : word; val : byte);assembler;
asm
mov es,[segm]
mov di,offs
mov al,byte
mov es:[di],al
end;

PROCEDURE write_word(segm,offs,val : word);assembler;
asm
mov es,[segm]
mov di,offs
mov ax,val
mov es:[di],ax
end;

PROCEDURE write_long(segm,offs : word; val : longint);assembler;
asm
mov es,[segm]
db $66; mov di,word ptr offs {converts to : mov edi,dword ptr offs}
db $66; mov ax,word ptr val {converts to : mov eax, dword ptr val}
db $66; mov es:[di],word ptr ax {to : mov es:[edi],dword ptr eax}
end;

see, nothing to it.  no push'es or pop's.  Note : I'm not sure that the
write_long will work, but I'm 99.5% sure it will (I'm not sure if the db $66
converts di to edi or not, but I doubt that is matters...).  Everything else
is guaranteed to work.  The write_long will require a 386 or better to run on,
though.  Note : this can be modified into a putpixel fairly easily.

Gary

