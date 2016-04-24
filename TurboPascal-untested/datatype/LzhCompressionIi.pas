(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0038.PAS
  Description: LZH Compression II
  Author: ANDREW EIGUS
  Date: 11-22-95  13:28
*)

Unit LZSSUnit;
{
   LZSSUNIT - Compress and uncompress unit using LZ77 algorithm for
   Borland (Turbo) Pascal version 7.0.

   Assembler Programmer: Andy Tam, Pascal Conversion: Douglas Webb,
   Unit Conversion and Dynamic Memory Allocation: Andrew Eigus.

   Public Domain version 1.02, last changed on 30.11.94.
   Target platforms: DOS, DPMI, Windows.

   Written by Andrew Eigus (aka: Mr. Byte) of:
   Fidonet: 2:5100/33,
   Internet: aeigus@fgate.castle.riga.lv, aeigus@kristin.cclu.lv.
}

interface

{#Z+}
{ This unit is ready for use with Dj. Murdoch's ScanHelp utility which
  will make a Borland .TPH file for it. }
{#Z-}

const
  LZRWBufSize     = 8192; { Read buffer size }

{#Z+}
  N           = 4096;  { Bigger N -> Better compression on big files only. }
  F           = 18;
  Threshold   = 2;
  Nul         = N * 2;
  InBufPtr    : word = LZRWBufSize;
  InBufSize   : word = LZRWBufSize;
  OutBufPtr   : word = 0;
{#Z-}

type
{#X TWriteProc}{#X LZSquash}{#X LZUnsquash}

  TReadProc = function(var ReadBuf; var NumRead : word) : word;
  { This is declaration for custom read function. It should read
    #LZRWBufSize# bytes from ReadBuf. The return value is ignored. }

{#X TReadProc}{#X LZSquash}{#X LZUnsquash}
  TWriteProc = function(var WriteBuf; Count : word; var NumWritten : word) :
word;  { This is declaration for custom write function. It should write
    Count bytes into WriteBuf and return number of actual bytes written
    into NumWritten variable. The return value is ignored. }

{#Z+}
  PLZRWBuffer = ^TLZRWBuffer;
  TLZRWBuffer = array[0..LZRWBufSize - 1] of Byte; { file buffers }

  PLZTextBuf = ^TLZTextBuf;
  TLZTextBuf = array[0..N + F - 2] of Byte;

  PLeftMomTree = ^TLeftMomTree;
  TLeftMomTree = array[0..N] of Word;
  PRightTree = ^TRightTree;
  TRightTree = array[0..N + 256] of Word;

const
  LZSSMemRequired = SizeOf(TLZRWBuffer) * 2 +
    SizeOf(TLZTextBuf) + SizeOf(TLeftMomTree) * 2 + SizeOf(TRightTree);
{#Z-}

function LZInit : boolean;
{ This function should be called before any other compression routines
  from this unit - it allocates memory and initializes all internal
  variables required by compression procedures. If allocation fails,
  LZInit returns False, this means that there isn't enough memory for
  compression or decompression process. It returns True if initialization
  was successful. }
{#X LZDone}{#X LZSquash}{#X LZUnsquash}

procedure LZSquash(ReadProc : TReadProc; WriteProc : TWriteProc);
{ This procedure is used for compression. ReadProc specifies custom
  read function that reads data, and WriteProc specifies custom write
  function that writes compressed data. }
{#X LZUnsquash}{#X LZInit}{#X LZDone}

procedure LZUnSquash(ReadProc : TReadProc; WriteProc : TWriteProc);
{ This procedure is used for decompression. ReadProc specifies custom
  read function that reads compressed data, and WriteProc specifies
  custom write function that writes decompressed data. }
{#X LZSquash}{#X LZInit}{#X LZDone}

procedure LZDone;
{ This procedure should be called after you finished compression or
  decompression. It deallocates (frees) all memory allocated by LZInit.
  Note: You should always call LZDone after you finished using compression
  routines from this unit. }
{#X LZInit}{#X LZSquash}{#X LZUnsquash}

implementation

var
  Height, MatchPos, MatchLen, LastLen : word;
  TextBufP : PLZTextBuf;
  LeftP, MomP : PLeftMomTree;
  RightP : PRightTree;
  CodeBuf : array[0..16] of Byte;
  LZReadProc : TReadProc;
  LZWriteProc : TWriteProc;
  InBufP, OutBufP : PLZRWBuffer;
  Bytes : word;
  Initialized : boolean;

Function LZSS_Read : word;    { Returns # of bytes read }
Begin
  LZReadProc(InBufP^, Bytes);
  LZSS_Read := Bytes;
End; { LZSS_Read }

Function LZSS_Write : word;  { Returns # of bytes written }
Begin
  LZWriteProc(OutBufP^, OutBufPtr, Bytes);
  LZSS_Write := Bytes
End; { LZSS_Write }

Procedure Getc; assembler;
Asm
{
  getc : return a character from the buffer
          RETURN : AL = input char
                   Carry set when EOF
}
              push    bx
              mov     bx, inBufPtr
              cmp     bx, inBufSize
              jb      @getc1
              push    cx
              push    dx
              push    di
              push    si
              call    LZSS_Read
              pop     si
              pop     di
              pop     dx
              pop     cx
              mov     inBufSize, ax
              or      ax, ax
              jz      @getc2               { ; EOF }
              xor     bx, bx
  @getc1:
              PUSH    DI
              LES     DI,[InBufP]
              MOV     AL,BYTE PTR [ES:DI+BX]
              POP     DI
              inc     bx
              mov     inBufPtr, bx
              pop     bx
              clc                         { ; clear the carry flag }
              jmp     @end
  @getc2:     pop     bx
              stc                         { ; set carry to indicate EOF }
  @end:
End; { Getc }

Procedure Putc; assembler;
{
  putc : put a character into the output buffer
             Entry : AL = output char
}
Asm
              push    bx
              mov     bx, outBufPtr
              PUSH    DI
              LES     DI,[OutBufP]
              MOV     BYTE PTR [ES:DI+BX],AL
              POP     DI
              inc     bx
              cmp     bx, LZRWBufSize
              jb      @putc1
              mov     OutBufPtr,LZRWBufSize   { Just so the flush will work. }
              push    cx
              push    dx
              push    di
              push    si
              call    LZSS_Write
              pop     si
              pop     di
              pop     dx
              pop     cx
              xor     bx, bx
  @putc1:     mov     outBufPtr, bx
              pop     bx
End; { Putc }

Procedure InitTree; assembler;
{
  initTree : initialize all binary search trees.  There are 256 BST's, one
             for all strings started with a particular character.  The
             parent is tree K is the node N + K + 1 and it has only a
             right child
}
Asm
      cld
      push    ds
      pop     es
      LES     DI,[RightP]
{      mov     di,offset right}
      add     di, (N + 1) * 2
      mov     cx, 256
      mov     ax, NUL
      rep     stosw
      LES     DI,[MomP]
{      mov     di, offset mom}
      mov     cx, N
      rep     stosw
End; { InitTree }


Procedure Splay; assembler;
{
  splay : use splay tree operations to move the node to the 'top' of
           tree.  Note that it will not actual become the root of the tree
           because the root of each tree is a special node.  Instead, it
           will become the right child of this special node.

             ENTRY : di = the node to be rotated
}
Asm
  @Splay1:
              PUSH    BX
              LES     BX,[MomP]
              MOV     SI,[ES:BX+DI]
              POP     BX
{              mov     si, [Offset Mom + di]}
              cmp     si, NUL           { ; exit if its parent is a special
node }              ja      @Splay4
              PUSH    DI
              LES     DI,[MomP]
              ADD     DI,SI
              MOV     BX,[ES:DI]
{              mov     bx, [Offset Mom + si]}
              POP     DI
              cmp     bx, NUL           { ; check if its grandparent is special
}              jbe     @Splay5           { ; if not then skip }
              PUSH    BX
              LES     BX,[LeftP]
              CMP     DI,[ES:BX+SI]
              POP     BX
{              cmp     di, [Offset Left + si]} { ; is the current node is a
left child ? }              jne     @Splay2
              PUSH    BX
              LES     BX,[RightP]
              MOV     DX,[ES:BX+DI]
{              mov     dx, [Offset Right + di]}    { ; perform a left zig
operation }              LES     BX,[LeftP]
              MOV     [ES:BX+SI],DX
{              mov     [Offset Left + si], dx}
              LES     BX,[RightP]
              MOV     [ES:BX+DI],SI
              POP     BX
{              mov     [Offset Right + di], si}
              jmp     @Splay3
  @Splay2:
              PUSH    BX
              LES     BX,[LeftP]
              MOV     DX,[ES:BX+DI]
{              mov     dx, [Offset Left + di]}     { ; perform a right zig }
              LES     BX,[RightP]
              MOV     [ES:BX+SI],DX
{              mov     [Offset Right + si], dx}
              LES     BX,[LeftP]
              MOV     [ES:BX+DI],SI
              POP     BX
{              mov     [Offset Left + di], si}
  @Splay3:
              PUSH    SI
              LES     SI,[RightP]
              MOV     [ES:SI+BX],DI
              POP     SI
{              mov     [Offset Right + bx], di}
              xchg    bx, dx
              PUSH    AX
              MOV     AX,BX
              LES     BX,[MomP]
              ADD     BX,AX
              MOV     [ES:BX],SI
              LES     BX,[MomP]
              MOV     [ES:BX+SI],DI
              LES     BX,[MomP]
              MOV     [ES:BX+DI],DX
              MOV     BX,AX
              POP     AX
{              mov     [Offset Mom + bx], si
              mov     [Offset Mom + si], di
              mov     [Offset Mom + di], dx}
  @Splay4:    jmp     @end
  @Splay5:
              PUSH    DI
              LES     DI,[MomP]
              MOV     CX,[ES:DI+BX]
              POP     DI
{              mov     cx, [Offset Mom + bx]}
              PUSH    BX
              LES     BX,[LeftP]
              CMP     DI,[ES:BX+SI]
              POP     BX
{              cmp     di, [Offset Left + si]}
              jne     @Splay7
              PUSH    DI
              LES     DI,[LeftP]
              CMP     SI,[ES:DI+BX]
              POP     DI
{              cmp     si, [Offset Left + bx]}
              jne     @Splay6
              PUSH    AX
              MOV     AX,DI
              LES     DI,[RightP]
              ADD     DI,SI
              MOV     DX,[ES:DI]
{              mov     dx, [Offset Right + si]   } { ; perform a left zig-zig
operation }              LES     DI,[LeftP]
              MOV     [ES:DI+BX],DX
{              mov     [Offset Left + bx], dx}
              xchg    bx, dx
              LES     DI,[MomP]
              MOV     [ES:DI+BX],DX
{              mov     [Offset Mom + bx], dx}
              LES     DI,[RightP]
              ADD     DI,AX
              MOV     BX,[ES:DI]
{              mov     bx, [Offset Right + di]}
              LES     DI,[LeftP]
              ADD     DI,SI
              MOV     [ES:DI],BX
              LES     DI,[MomP]
              MOV     [ES:DI+BX],SI
{              mov     [Offset Left +si], bx
              mov     [Offset Mom + bx], si}
              mov     bx, dx
              LES     DI,[RightP]
              ADD     DI,SI
              MOV     [ES:DI],BX
              LES     DI,[RightP]
              ADD     DI,AX
              MOV     [ES:DI],SI
{              mov     [Offset Right + si], bx
              mov     [Offset Right + di], si}
              LES     DI,[MomP]
              MOV     [ES:DI+BX],SI
              LES     DI,[MomP]
              ADD     DI,SI
              STOSW
              MOV     DI,AX
              POP     AX
{              mov     [Offset Mom + bx], si
              mov     [Offset Mom + si], di}
              jmp     @Splay9
  @Splay6:
              PUSH    AX
              MOV     AX,SI
              LES     SI,[LeftP]
              ADD     SI,DI
              MOV     DX,[ES:SI]
{              mov     dx, [Offset Left + di]}     { ; perform a left zig-zag
operation }              LES     SI,[RightP]
              MOV     [ES:SI+BX],DX
{              mov     [Offset Right + bx], dx}
              xchg    bx, dx
              LES     SI,[MomP]
              MOV     [ES:SI+BX],DX
{              mov     [Offset Mom + bx], dx}
              LES     SI,[RightP]
              ADD     SI,DI
              MOV     BX,[ES:SI]
{              mov     bx, [Offset Right + di]}
              LES     SI,[LeftP]
              ADD     SI,AX
              MOV     [ES:SI],BX
{              mov     [Offset Left + si], bx}
              LES     SI,[MomP]
              MOV     [ES:SI+BX],AX
{              mov     [Offset Mom + bx], si}
              mov     bx, dx
              LES     SI,[LeftP]
              ADD     SI,DI
              MOV     [ES:SI],BX
{              mov     [Offset Left + di], bx}
              LES     SI,[RightP]
              ADD     SI,DI
              MOV     [ES:SI],AX
{              mov     [Offset Right + di], si}
              LES     SI,[MomP]
              ADD     SI,AX
              MOV     [ES:SI],DI
{              mov     [Offset Mom + si], di}
              LES     SI,[MomP]
              MOV     [ES:SI+BX],DI
              MOV     SI,AX
              POP     AX
{              mov     [Offset Mom + bx], di}
              jmp     @Splay9
  @Splay7:
              PUSH    DI
              LES     DI,[RightP]
              CMP     SI,[ES:DI+BX]
              POP     DI
{              cmp     si, [Offset Right + bx]}
              jne     @Splay8
              PUSH    AX
              MOV     AX,SI
              LES     SI,[LeftP]
              ADD     SI,AX
              MOV     DX,[ES:SI]
{              mov     dx, [Offset Left + si]}     { ; perform a right zig-zig
}              LES     SI,[RightP]
              MOV     [ES:SI+BX],DX
{              mov     [Offset Right + bx], dx}
              xchg    bx, dx
              LES     SI,[MomP]
              MOV     [ES:SI+BX],DX
{              mov     [Offset Mom + bx], dx}
              LES     SI,[LeftP]
              ADD     SI,DI
              MOV     BX,[ES:SI]
{              mov     bx, [Offset Left + di]}
              LES     SI,[RightP]
              ADD     SI,AX
              MOV     [ES:SI],BX
{              mov     [Offset Right + si], bx}
              LES     SI,[MomP]
              MOV     [ES:SI+BX],AX
{              mov     [Offset Mom + bx], si}
              mov     bx, dx
              LES     SI,[LeftP]
              ADD     SI,AX
              MOV     [ES:SI],BX
{              mov     [Offset Left + si], bx}
              LES     SI,[LeftP]
              ADD     SI,DI
              MOV     [ES:SI],AX
{              mov     [Offset Left + di], si}
              LES     SI,[MomP]
              MOV     [ES:SI+BX],AX
{              mov     [Offset Mom + bx], si}
              LES     SI,[MomP]
              ADD     SI,AX
              MOV     [ES:SI],DI
{              mov     [Offset Mom + si], di}
              MOV     SI,AX
              POP     AX
              jmp     @Splay9
  @Splay8:
              PUSH    AX
              MOV     AX,SI
              LES     SI,[RightP]
              ADD     SI,DI
              MOV     DX,[ES:SI]
{              mov     dx, [Offset Right + di]}    { ; perform a right zig-zag
}              LES     SI,[LeftP]
              MOV     [ES:SI+BX],DX
{              mov     [Offset Left + bx], dx}
              xchg    bx, dx
              LES     SI,[MomP]
              MOV     [ES:SI+BX],DX
{              mov     [Offset Mom + bx], dx}
              LES     SI,[LeftP]
              ADD     SI,DI
              MOV     BX,[ES:SI]
{              mov     bx, [Offset Left + di]}
              LES     SI,[RightP]
              ADD     SI,AX
              MOV     [ES:SI],BX
{              mov     [Offset Right + si], bx}
              LES     SI,[MomP]
              MOV     [ES:SI+BX],AX
{              mov     [Offset Mom + bx], si}
              mov     bx, dx
              LES     SI,[RightP]
              ADD     SI,DI
              MOV     [ES:SI],BX
{              mov     [Offset Right + di], bx}
              LES     SI,[LeftP]
              ADD     SI,DI
              MOV     [ES:SI],AX
{              mov     [Offset Left + di], si}
              LES     SI,[MomP]
              ADD     SI,AX
              MOV     [ES:SI],DI
              LES     SI,[MomP]
              MOV     [ES:SI+BX],DI
{              mov     [Offset Mom + si], di
              mov     [Offset Mom + bx], di}
              MOV     SI,AX
              POP     AX
  @Splay9:    mov     si, cx
              cmp     si, NUL
              ja      @Splay10
              PUSH    DI
              LES     DI,[LeftP]
              ADD     DI,SI
              CMP     BX,[ES:DI]
              POP     DI
{              cmp     bx, [Offset Left + si]}
              jne     @Splay10
              PUSH    BX
              LES     BX,[LeftP]
              MOV     [ES:BX+SI],DI
              POP     BX
{              mov     [Offset Left + si], di}
              jmp     @Splay11
  @Splay10:
              PUSH    BX
              LES     BX,[RightP]
              MOV     [ES:BX+SI],DI
              POP     BX
{              mov     [Offset Right + si], di}
  @Splay11:
              PUSH    BX
              LES     BX,[MomP]
              MOV     [ES:BX+DI],SI
              POP     BX
{              mov     [Offset Mom + di], si}
              jmp     @Splay1
  @end:
End; { SPlay }



Procedure InsertNode; assembler;
{
  insertNode : insert the new node to the corresponding tree.  Note that the
               position of a string in the buffer also served as the node
               number.
             ENTRY : di = position in the buffer
}
Asm
              push    si
              push    dx
              push    cx
              push    bx
              mov     dx, 1
              xor     ax, ax
              mov     matchLen, ax
              mov     height, ax
              LES     SI,[TextBufP]
              ADD     SI,DI
              MOV     AL,BYTE PTR [ES:SI]
{             mov     al, byte ptr [Offset TextBuf + di]}
              shl     di, 1
              add     ax, N + 1
              shl     ax, 1
              mov     si, ax
              mov     ax, NUL
              PUSH    BX
              LES     BX,[RightP]
              MOV     WORD PTR [ES:BX+DI],AX
{              mov     word ptr [Offset Right + di], ax}
              LES     BX,[LeftP]
              MOV     WORD PTR [ES:BX+DI],AX
              POP     BX
{              mov     word ptr [Offset Left + di], ax}
  @Ins1:inc     height
              cmp     dx, 0
              jl      @Ins3
              PUSH    DI
              LES     DI,[RightP]
              ADD     DI,SI
              MOV     AX,WORD PTR [ES:DI]
              POP     DI
{              mov     ax, word ptr [Offset Right + si]}
              cmp     ax, NUL
              je      @Ins2
              mov     si, ax
              jmp     @Ins5
  @Ins2:
              PUSH    BX
              LES     BX,[RightP]
              MOV     WORD PTR [ES:BX+SI],DI
{              mov     word ptr [Offset Right + si], di}
              LES     BX,[MomP]
              MOV     WORD PTR [ES:BX+DI],SI
              POP     BX
{              mov     word ptr [Offset Mom + di], si}
              jmp     @Ins11
  @Ins3:
              PUSH    BX
              LES     BX,[LeftP]
              ADD     BX,SI
              MOV     AX,WORD PTR [ES:BX]
              POP     BX
{              mov     ax, word ptr [Offset Left + si]}
              cmp     ax, NUL
              je      @Ins4
              mov     si, ax
              jmp     @Ins5
  @Ins4:
              PUSH    BX
              LES     BX,[LeftP]
              ADD     BX,SI
              MOV     WORD PTR [ES:BX],DI
{              mov     word ptr [Offset Left + si], di}
              LES     BX,[MomP]
              ADD     BX,DI
              MOV     WORD PTR [ES:BX],SI
              POP     BX
{              mov     word ptr [Offset Mom + di], si}
              jmp     @Ins11
  @Ins5:      mov     bx, 1
              shr     si, 1
              shr     di, 1
              xor     ch, ch
              xor     dh, dh
  @Ins6:
              PUSH    SI
              LES     SI,[TextBufP]
              ADD     SI,DI
              MOV     DL,BYTE PTR [ES:SI+BX]
              POP     SI
              PUSH    DI
              LES     DI,[TextBufP]
              ADD     DI,SI
              MOV     CL,BYTE PTR [ES:DI+BX]
              POP     DI
{              mov     dl, byte ptr [Offset Textbuf + di + bx]
              mov     cl, byte ptr [Offset TextBuf + si + bx]}
              sub     dx, cx
              jnz     @Ins7
              inc     bx
              cmp     bx, F
              jb      @Ins6
  @Ins7:      shl     si, 1
              shl     di, 1
              cmp     bx, matchLen
              jbe     @Ins1
              mov     ax, si
              shr     ax, 1
              mov     matchPos, ax
              mov     matchLen, bx
              cmp     bx, F
              jb      @Ins1
  @Ins8:
              PUSH    CX
              LES     BX,[MomP]
              MOV     AX,WORD PTR [ES:BX+SI]
{              mov     ax, word ptr [Offset Mom + si]}
              LES     BX,[MomP]
              MOV     WORD PTR [ES:BX+DI],AX
{              mov     word ptr [Offset Mom + di], ax}
              LES     BX,[LeftP]
              MOV     CX,WORD PTR [ES:BX+SI]
{              mov     bx, word ptr [Offset Left + si]}
              LES     BX,[LeftP]
              MOV     WORD PTR [ES:BX+DI],CX
{              mov     word ptr [Offset Left + di], bx}
              LES     BX,[MomP]
              ADD     BX,CX
              MOV     WORD PTR [ES:BX],DI
{              mov     word ptr [Offset Mom + bx], di}
              LES     BX,[RightP]
              MOV     CX,WORD PTR [ES:BX+SI]
{              mov     bx, word ptr [Offset Right + si]}
              LES     BX,[RightP]
              MOV     WORD PTR [ES:BX+DI],CX
{              mov     word ptr [Offset Right + di], bx}
              LES     BX,[MomP]
              ADD     BX,CX
              MOV     WORD PTR [ES:BX],DI
{              mov     word ptr [Offset Mom + bx], di}
              LES     BX,[MomP]
              MOV     CX,WORD PTR [ES:BX+SI]
{              mov     bx, word ptr [Offset Mom + si]}
              MOV     BX,CX
              POP     CX
              PUSH    DI
              LES     DI,[RightP]
              CMP     SI,WORD PTR [ES:DI+BX]
              POP     DI
{              cmp     si, word ptr [Offset Right + bx]}
              jne     @Ins9
              PUSH    SI
              LES     SI,[RightP]
              MOV     WORD PTR [ES:SI+BX],DI
              POP     SI
{              mov     word ptr [Offset Right + bx], di}
              jmp     @Ins10
  @Ins9:
              PUSH    SI
              LES     SI,[LeftP]
              MOV     WORD PTR [ES:SI+BX],DI
              POP     SI
{              mov     word ptr [Offset Left + bx], di}
  @Ins10:
              PUSH    DI
              LES     DI,[MomP]
              ADD     DI,SI
              MOV     WORD PTR [ES:DI],NUL
              POP     DI
{              mov     word ptr [Offset Mom + si], NUL}
  @Ins11:     cmp     height, 30
              jb      @Ins12
              call    Splay
  @Ins12:     pop     bx
              pop     cx
              pop     dx
              pop     si
              shr     di, 1
End; { InsertNode }


Procedure DeleteNode; assembler;
{
   deleteNode : delete the node from the tree

            ENTRY : SI = position in the buffer
}
Asm
              push    di
              push    bx
              shl     si, 1
              PUSH    DI
              LES     DI,[MomP]
              ADD     DI,SI
              CMP     WORD PTR [ES:DI],NUL
              POP     DI
{              cmp     word ptr [Offset Mom + si], NUL}   { ; if it has no
parent then exit }              je      @del7
              PUSH    DI
              LES     DI,[RightP]
              ADD     DI,SI
              CMP     WORD PTR [ES:DI],NUL
              POP     DI
{              cmp     word ptr [Offset Right + si], NUL} { ; does it have
right child ? }              je      @del8
              PUSH    BX
              LES     BX,[LeftP]
              MOV     DI,WORD PTR [ES:BX+SI]
              POP     BX
{              mov     di, word ptr [Offset Left + si] }  { ; does it have left
child ? }              cmp     di, NUL
              je      @del9
              PUSH    SI
              LES     SI,[RightP]
              ADD     SI,DI
              MOV     AX,WORD PTR [ES:SI]
              POP     SI
{              mov     ax, word ptr [Offset Right + di]}  { ; does it have
right grandchild ? }              cmp     ax, NUL
              je      @del2                             { ; if no then skip }
  @del1:      mov     di, ax                            { ; find the rightmost
node in }              PUSH    SI
              LES     SI,[RightP]
              ADD     SI,DI
              MOV     AX,WORD PTR [ES:SI]
              POP     SI
{              mov     ax, word ptr [Offset Right + di] } { ;   the right
subtree }              cmp     ax, NUL
              jne     @del1
              PUSH    CX
              MOV     CX,SI
              LES     SI,[MomP]
              ADD     SI,DI
              MOV     BX,WORD PTR [ES:SI]
{              mov     bx, word ptr [Offset Mom + di] }   { ; move this node as
the root of }              LES     SI,[LeftP]
              ADD     SI,DI
              MOV     AX,WORD PTR [ES:SI]
{              mov     ax, word ptr [Offset Left + di]}   { ;   the subtree }
              LES     SI,[RightP]
              MOV     WORD PTR [ES:SI+BX],AX
{              mov     word ptr [Offset Right + bx], ax}
              xchg    ax, bx
              LES     SI,[MomP]
              MOV     WORD PTR [ES:SI+BX],AX
{              mov     word ptr [Offset Mom + bx], ax}
              LES     SI,[LeftP]
              ADD     SI,CX
              MOV     BX,WORD PTR [ES:SI]
{              mov     bx, word ptr [Offset Left + si]}
              LES     SI,[LeftP]
              ADD     SI,DI
              MOV     WORD PTR [ES:SI],BX
{              mov     word ptr [Offset Left + di], bx}
              LES     SI,[MomP]
              MOV     WORD PTR [ES:SI+BX],DI
{              mov     word ptr [Offset Mom + bx], di}
              MOV     SI,CX
              POP     CX
  @del2:
              PUSH    CX
              MOV     CX,SI
              LES     SI,[RightP]
              ADD     SI,CX
              MOV     BX,WORD PTR [ES:SI]
{              mov     bx, word ptr [Offset Right + si]}
              LES     SI,[RightP]
              ADD     SI,DI
              MOV     WORD PTR [ES:SI],BX
{              mov     word ptr [Offset Right + di], bx}
              LES     SI,[MomP]
              MOV     WORD PTR [ES:SI+BX],DI
              MOV     SI,CX
              POP     CX
{              mov     word ptr [Offset Mom + bx], di}
  @del3:
              PUSH    CX
              MOV     CX,DI
              LES     DI,[MomP]
              ADD     DI,SI
              MOV     BX,WORD PTR [ES:DI]
{              mov     bx, word ptr [Offset Mom + si]}
              LES     DI,[MomP]
              ADD     DI,CX
              MOV     WORD PTR [ES:DI],BX
{              mov     word ptr [Offset Mom + di], bx}
              MOV     DI,CX
              POP     CX
              PUSH    DI
              LES     DI,[RightP]
              CMP     SI,WORD PTR [ES:DI+BX]
              POP     DI
{              cmp     si, word ptr [Offset Right + bx]}
              jne     @del4
              PUSH    SI
              LES     SI,[RightP]
              MOV     WORD PTR [ES:SI+BX],DI
              POP     SI
{              mov     word ptr [Offset Right + bx], di}
              jmp     @del5
  @del4:
              PUSH    SI
              LES     SI,[LeftP]
              MOV     WORD PTR [ES:SI+BX],DI
              POP     SI
{              mov     word ptr [Offset Left + bx], di}
  @del5:
              PUSH    DI
              LES     DI,[MomP]
              ADD     DI,SI
              MOV     WORD PTR [ES:DI],NUL
              POP     DI
{              mov     word ptr [Offset Mom + si], NUL}
  @del7:      pop     bx
              pop     di
              shr     si, 1
              jmp     @end;
  @del8:
              PUSH    BX
              LES     BX,[LeftP]
              MOV     DI,WORD PTR [ES:BX+SI]
              POP     BX
{              mov     di, word ptr [Offset Left + si]}
              jmp     @del3
  @del9:
              PUSH    BX
              LES     BX,[RightP]
              MOV     DI,WORD PTR [ES:BX+SI]
              POP     BX
{              mov     di, word ptr [Offset Right + si]}
              jmp     @del3
  @end:
End; { DeleteNode }


Procedure Encode; assembler;
Asm
              call    initTree
              xor     bx, bx
              mov     [Offset CodeBuf + bx], bl
              mov     dx, 1
              mov     ch, dl
              xor     si, si
              mov     di, N - F
  @Encode2:   call    getc
              jc      @Encode3
              PUSH    SI
              LES     SI,[TextBufP]
              ADD     SI,DI
              MOV     BYTE PTR [ES:SI+BX],AL
              POP     SI
{              mov     byte ptr [Offset TextBuf +di + bx], al}
              inc     bx
              cmp     bx, F
              jb      @Encode2
  @Encode3:   or      bx, bx
              jne     @Encode4
              jmp     @Encode19
  @Encode4:   mov     cl, bl
              mov     bx, 1
              push    di
              sub     di, 1
  @Encode5:   call    InsertNode
              inc     bx
              dec     di
              cmp     bx, F
              jbe     @Encode5
              pop     di
              call    InsertNode
  @Encode6:   mov     ax, matchLen
              cmp     al, cl
              jbe     @Encode7
              mov     al, cl
              mov     matchLen, ax
  @Encode7:   cmp     al, THRESHOLD
              ja      @Encode8
              mov     matchLen, 1
              or      byte ptr codeBuf, ch
              mov     bx, dx
              PUSH    SI
              LES     SI,[TextBufP]
              ADD     SI,DI
              MOV     AL,BYTE PTR [ES:SI]
              POP     SI
{              mov     al, byte ptr [Offset TextBuf + di]}
              mov     byte ptr [Offset CodeBuf + bx], al
              inc     dx
              jmp     @Encode9
  @Encode8:   mov     bx, dx
              mov     al, byte ptr matchPos
              mov     byte ptr [Offset Codebuf + bx], al
              inc     bx
              mov     al, byte ptr (matchPos + 1)
              push    cx
              mov     cl, 4
              shl     al, cl
              pop     cx
              mov     ah, byte ptr matchLen
              sub     ah, THRESHOLD + 1
              add     al, ah
              mov     byte ptr [Offset Codebuf + bx], al
              inc     bx
              mov     dx, bx
  @Encode9:   shl     ch, 1
              jnz     @Encode11
              xor     bx, bx
  @Encode10:  mov     al, byte ptr [Offset CodeBuf + bx]
              call    putc
              inc     bx
              cmp     bx, dx
              jb      @Encode10
              mov     dx, 1
              mov     ch, dl
              mov     byte ptr codeBuf, dh
  @Encode11:  mov     bx, matchLen
              mov     lastLen, bx
              xor     bx, bx
  @Encode12:  call    getc
{              jc      @Encode14}
              jc      @Encode15
              push    ax
              call    deleteNode
              pop     ax
              PUSH    DI
              LES     DI,[TextBufP]
              ADD     DI,SI
              stosb
              POP     DI
{              mov     byte ptr [Offset TextBuf + si], al}
              cmp     si, F - 1
              jae     @Encode13
              PUSH    DI
              LES     DI,[TextBufP]
              ADD     DI,SI
              MOV     BYTE PTR [ES:DI+N],AL
              POP     DI
{              mov     byte ptr [Offset TextBuf + si + N], al}
  @Encode13:  inc     si
              and     si, N - 1
              inc     di
              and     di, N - 1
              call    insertNode
              inc     bx
              cmp     bx, lastLen
              jb      @Encode12
(*  @Encode14:  sub     printCount, bx
              jnc     @Encode15
              mov     ax, printPeriod
              mov     printCount, ax
              push    dx                 { Print out a period as a sign. }
              mov     dl, DBLARROW
              mov     ah, 2
              int     21h
              pop     dx *)
  @Encode15:  cmp     bx, lastLen
              jae     @Encode16
              inc     bx
              call    deleteNode
              inc     si
              and     si, N - 1
              inc     di
              and     di, N - 1
              dec     cl
              jz      @Encode15
              call    insertNode
              jmp     @Encode15
  @Encode16:  cmp     cl, 0
              jbe     @Encode17
              jmp     @Encode6
  @Encode17:  cmp     dx, 1
              jb      @Encode19
              xor     bx, bx
  @Encode18:  mov     al, byte ptr [Offset Codebuf + bx]
              call    putc
              inc     bx
              cmp     bx, dx
              jb      @Encode18
  @Encode19:
End; { Encode }

Procedure Decode; assembler;
Asm
              xor     dx, dx
              mov     di, N - F
  @Decode2:   shr     dx, 1
              or      dh, dh
              jnz     @Decode3
              call    getc
              jc      @Decode9
              mov     dh, 0ffh
              mov     dl, al
  @Decode3:   test    dx, 1
              jz      @Decode4
              call    getc
              jc      @Decode9
              PUSH    SI
              LES     SI,[TextBufP]
              ADD     SI,DI
              MOV     BYTE PTR [ES:SI],AL
              POP     SI
{              mov     byte ptr [Offset TextBuf + di], al}
              inc     di
              and     di, N - 1
              call    putc
              jmp     @Decode2
  @Decode4:   call    getc
              jc      @Decode9
              mov     ch, al
              call    getc
              jc      @Decode9
              mov     bh, al
              mov     cl, 4
              shr     bh, cl
              mov     bl, ch
              mov     cl, al
              and     cl, 0fh
              add     cl, THRESHOLD
              inc     cl
  @Decode5:   and     bx, N - 1
              PUSH    SI
              LES     SI,[TextBufP]
              MOV     AL,BYTE PTR [ES:SI+BX]
              ADD     SI,DI
              MOV     BYTE PTR [ES:SI],AL
              POP     SI
{              mov     al, byte ptr [Offset TextBuf + bx]
              mov     byte ptr [Offset TextBuf + di], al}
              inc     di
              and     di, N - 1
              call    putc
              inc     bx
              dec     cl
              jnz     @Decode5
              jmp     @Decode2
  @Decode9:
End; { Decode }

Function LZInit : boolean;
Begin
  if Initialized then Exit;
  LZInit := False;
  New(InBufP);
  New(OutBufP);
  New(TextBufP);
  New(LeftP);
  New(MomP);
  New(RightP);
  Initialized := (InBufP <> nil) and (OutBufP <> nil) and
    (TextBufP <> nil) and (LeftP <> nil) and (MomP <> nil) and (RightP <> nil);
  if Initialized then LZInit := True else
  begin
    Initialized := True;
    LZDone
  end
End; { LZInit }

Procedure LZDone;
Begin
  if Initialized then
  begin
    Dispose(InBufP);
    Dispose(OutBufP);
    Dispose(RightP);
    Dispose(MomP);
    Dispose(LeftP);
    Dispose(TextBufP);
    Initialized := False
  end
End; { LZDone }

Procedure LZSquash;
Begin
  if Initialized then
  begin
    InBufPtr := LZRWBufSize;
    InBufSize := LZRWBufSize;
    OutBufPtr := 0;
    Height := 0;
    MatchPos := 0;
    MatchLen := 0;
    LastLen := 0;

    FillChar(TextBufP^, SizeOf(TLZTextBuf), 0);
    FillChar(LeftP^, SizeOf(TLeftMomTree), 0);
    FillChar(MomP^, SizeOf(TLeftMomTree), 0);
    FillChar(RightP^, SizeOf(TRightTree), 0);
    FillChar(CodeBuf, SizeOf(CodeBuf), 0);

    LZReadProc := ReadProc;
    LZWriteProc := WriteProc;

    Encode;
    LZSS_Write
  end
End; { LZSquash }

Procedure LZUnSquash;
Begin
  if Initialized then
  begin
    InBufPtr := LZRWBufSize;
    InBufSize := LZRWBufSize;
    OutBufPtr := 0;
    FillChar(TextBufP^, SizeOf(TLZTextBuf), 0);

    LZReadProc := ReadProc;
    LZWriteProc := WriteProc;

    Decode;
    LZSS_Write
  end
End; { LZUnSquash }

{$IFDEF Windows}
Function HeapFunc(Size : word) : integer; far; assembler;
Asm
  MOV AX,1
End; { HeapFunc }
{$ENDIF}

Begin
{$IFDEF Windows}
  HeapError := @HeapFunc;
{$ENDIF}
  Initialized := False
End. { LZSSUNIT }








Program LZSSDemo;
{ Copyright (c) 1994 by Andrew Eigus   Fidonet: 2:5100/33 }
{ Demonstrates the use of LZSSUnit (LZSSUNIT.PAS), Public Domain }

uses LZSSUnit;

var InFile, OutFile : file;

Function ToUpper(S : string) : string; assembler;
Asm
  PUSH DS
  CLD
  LDS SI,S
  LES DI,@Result
  LODSB
  STOSB
  XOR AH,AH
  XCHG AX,CX
  JCXZ @@3
@@1:
  LODSB
  CMP AL,'a'
  JB  @@2
  CMP AL,'z'
  JA  @@2
  SUB AL,20h
@@2:
  STOSB
  LOOP @@1
@@3:
  POP DS
End; { ToUpper }

Function ReadProc(var ReadBuf; var NumRead : word) : word; far;
Begin
  BlockRead(InFile, ReadBuf, LZRWBufSize, NumRead);
  Write(#13, FilePos(InFile), ' -> ')
End; { ReadProc }

Function WriteProc(var WriteBuf; Count : word; var NumWritten : word) : word;
far;Begin
  BlockWrite(OutFile, WriteBuf, Count, NumWritten);
  Write(FilePos(OutFile), #13)
End; { WriteProc }

Begin
  if ParamCount < 2 then
  begin
    WriteLn('Usage: LZSSDEMO <inputfile> <outputfile> [unsquash]');
    Halt(1)
  end;
  if not LZInit then
  begin
    WriteLn('Not enough memory');
    Halt(8)
  end;
  Assign(InFile, ParamStr(1));
  Reset(InFile, 1);
  if IOResult = 0 then
  begin
    Assign(OutFile, ParamStr(2));
    Rewrite(OutFile, 1);
    if IOResult = 0 then
    begin
      if ToUpper(ParamStr(3)) =  'UNSQUASH' then
        LZUnSquash(ReadProc, WriteProc)
      else
        LZSquash(ReadProc, WriteProc);
      Close(OutFile)
    end else WriteLn('Cannot create output file');
    Close(InFile)
  end else WriteLn('Cannot open input file');
  LZDone;
  WriteLn
End.


{
So boys and girls...

Here is just a ritual doc file, couz i hate to write READMEs! ;)
Okay, LZSSUNIT.PAS is my source unit for Borland (Turbo) Pascal for
implementation of LZSS (LZ77) compression algorithm in your programs.
It is designed to work with all three DOS, DPMI and Windows platforms
of Borland Pascal 7.0. Extremely clear example to show the use of this
unit and very easy implementation.

One note: I figured out that it compresses and decompresses files faster
and better! than the similar Microsoft COMPRESS/EXPAND utilities used by slow
Microsoft Setup program. Microsoft COMPRESS uses the same algo, however.

The source code provided is all Public Domain and thus no charge is
required for the author. Use at your own risk and modify as you wish.
I have am also not against of putting it in the new SWAG, eh Gayle?

Thanks send to:

Mr. Byte of TR/-\NC3T3CHN0PH0BiA
SysOp of AndRew's BBS  * +371-2-559777
Fidonet: 2:5100/33
Internet: aeigus@fgate.castle.riga.lv, aeigus@kristin.cclu.lv

If you still love the source so much, you are still welcome to send
some "support" fee to:

Andrew Eigus
Heinrichstr. 76
CH-8005 Zurich
}

