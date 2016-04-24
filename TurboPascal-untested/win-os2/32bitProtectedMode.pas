(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0024.PAS
  Description: 32bit Protected Mode
  Author: MORTEN WELINDER
  Date: 05-26-94  07:31
*)

{
>What you *can* do is these things.

>1. You can modify the limit of a selector from $0000FFFF to
>   $xxxxFFFF so assembler code can use 32-bit addressing.
>   Note that you may not change the lower 16-bit of the limit
>   field, or else the DPMI server crashes.

>2. You can compile a 32-bit assembler procedure into your
>   program.  It just needs a tiny (16 byte) wrapper and must
>   reside in the low 64K of a segment (or else interrupts
>   cannot return correctly).  However, the BP linker does
>   not support 32-bit fixups so there are limits as to what
>   you can put into the assembler code.

>3. If you are willing to give up assembler access to BP
>   variables, then you can make a binary image and link
>   that into your program.  Then you can do whatever pleases
>   you in the assembler procedure.

>If there is interrest, I could post an example routine showing
>this.

Three files are needed: a batch file for assembly, an assembler
file with 32-bit code, and a pascal test program.  The test
program is not supposed to do anything useful.

The code is unsupported.  You must know what you're doing.
You'll need the `exe2bin' or `exetobin' utility; you'll need
BP7 (with Turbo Assembler, and you cannot use TP7).  You must
be using Borland's DPMI or some DPMI that supports 32-bit
programs.  Don't even think about running this on a 286.  When
things go wrong it's not my fault.  Don't tell me you know a
better way to get the segment limit, because so do I.

Morten Welinder
terra@diku.dk

{ THE BATCH FILE }
{ CUT HERE }
{***************************************************************************}

@Echo Off
Tasm /M2 /T /L Test32
If Not Exist Test32.Obj Goto End
Tlink /x test32 >Nul
Exe2bin Test32.Exe Test32.Bin
Rem Del Test32.Exe
Del Test32.Obj
:End

{ THE ASSEMBLER PROGRAM }
{ CUT HERE }
{***************************************************************************}

; ---------------------------------------------------------------------------
; Example 32 bit program for use with Borland Pascal 7.0
; ---------------------------------------------------------------------------
Ideal                                  ; (Keep Tasm happy)
P386
Model Use32 Huge,Pascal
Segment Code Use32
Assume  Cs:Code
; ---------------------------------------------------------------------------
Entry0:  Movzx Eax,[Word Esp]          ; Change the stack frame to 32 bits
         Shr   [Dword Esp],16          ; so [Esp+xxx] works as expected.
         Push  Eax
         Jmp   P0
Align 10h
Entry1:  Movzx Eax,[Word Esp]          ; Aligned 10h for speed.
         Shr   [Dword Esp],16
         Push  Eax
         Jmp   P1
Align 10h
Entry2:  Movzx Eax,[Word Esp]          ; Aligned 10h for speed.
         Shr   [Dword Esp],16
         Push  Eax
         Jmp   P2
; etc.
; ---------------------------------------------------------------------------
Align 10h
Proc P0 Far L1:Dword,L2:Dword
         Mov   Eax,[L1]                ; Add the parameters
         Add   Eax,[L2]

         Shld  Edx,Eax,16              ; Output is left in Dx:Ax
         Ret
Endp
; ---------------------------------------------------------------------------
Align 10h
Proc P1 Far
         Push  Ds                      ; Call MsDos from a 32 bit segment
         Mov   Ax,Cs                   ; Never ever perform a software
         Mov   Ds,Ax                   ; interrupt if Ip>=64K!
         Mov   Ah,9
         Mov   Edx,Offset Message
         Int   21h
         Pop   Ds
         Ret

Message  Db    'Hello, 32 bit world!',13,10,'$'
Endp
; ---------------------------------------------------------------------------
Align 10h
Proc P2 Far P:Dword
         Push  Ds
         Xor   Esi,Esi
         Lds   Si,[Small P]
         Mov   Ecx,20000h/4
  @@1:   Mov   [Esi],Esi
         Add   Esi,4
         Loop  @@1
         Pop   Ds
         Ret
Endp
; ---------------------------------------------------------------------------
Ends
End

{ THE TEST PROGRAM }
{ CUT HERE }
{***************************************************************************}

Program   Test;
{ ------------------------------------------------------------------------- }
Uses      Winapi, Dos;
{ ------------------------------------------------------------------------- }
Const     Dpmi_32BitSegment           = $4000;

Type      Dpmi_Descriptor             = Record
            Limit0015                 : Word;
            Base0015                  : Word;
            Base1623                  : Byte;
            Rights                    : Byte;   { 7=Prsnt, 6-5=Dpl, 4=App,  }
                                                { 3-0=Type                  }
            Rights386                 : Byte;   { 7=Gran, 6=Size32, 5=0,    }
                                                { 4=Avail, 3-0=Limit1619    }
            Base2431                  : Byte;
            End;

Var       Sel      : Word;
          Oldright : Word;
          ProcPtr  : Pointer;
          P1       : Function(L1,L2: LongInt): LongInt;
          P2       : Procedure;
          P3       : Procedure(P: Pointer);
          Fil      : File;
          Data     : Pointer;
          Dsel     : Word;
{ ------------------------------------------------------------------------- }
Procedure Dpmi_SetSelectorLimit(Sel: Word; Limit: LongInt); Assembler;
Asm    Mov   Ax,0008H
       Mov   Bx,[Sel]
       Mov   Dx,[Word Ptr Limit]
       Mov   Cx,[Word Ptr Limit+2]
       Int   31H
End;
{ ------------------------------------------------------------------------- }
Procedure Dpmi_GetDescriptor(Sel: Word; Var Buffer: Dpmi_Descriptor); Assembler;
Asm    Mov   Ax,000Bh
       Mov   Bx,[Sel]
       Les   Di,[Buffer]
       Int   31H
End;
{ ------------------------------------------------------------------------- }
Procedure Dpmi_SetDescriptor(Sel: Word; Var Buffer: Dpmi_Descriptor); Assembler;
Asm    Mov   Ax,000Ch
       Mov   Bx,[Sel]
       Les   Di,[Buffer]
       Int   31H
End;
{ ------------------------------------------------------------------------- }
Function  Dpmi_GetAccessRights(Sel: Word): Word; Assembler;
Var       Buffer : Dpmi_Descriptor;
Asm    Mov   Bx,[Sel]
       Push  Bx
       Push  Ss
       Lea   Di,[Buffer]
       Push  Di
       Call  Dpmi_GetDescriptor
       Mov   Ax,[Word Ptr Buffer+5]
End;
{ ------------------------------------------------------------------------- }
Procedure Dpmi_SetAccessRights(Sel: Word; Rights: Word); Assembler;
Var       Buffer : Dpmi_Descriptor;
Asm    Mov   Bx,[Sel]
       Lea   Di,[Buffer]
       Push  Bx
       Push  Ss
       Push  Di
       Push  Bx
       Push  Ss
       Push  Di
       Call  Dpmi_GetDescriptor
       Mov   Ax,[Word Ptr Buffer+5]
       And   Ax,8F00h
       Mov   Bx,[Rights]
       And   Bx,50Ffh
       Or    Ax,Bx
       Mov   [Word Ptr Buffer+5],Ax
       Call  Dpmi_SetDescriptor
End;
{ ------------------------------------------------------------------------- }
Function  Dpmi_GetSelectorLimit(Sel: Word): LongInt; Assembler;
Var       Buffer : Dpmi_Descriptor;
Asm    Mov   Bx,[Sel]
       Push  Bx
       Push  Ss
       Lea   Di,[Buffer]
       Push  Di
       Call  Dpmi_GetDescriptor
       Mov   Dx,[Word Ptr Buffer+6]
       Mov   Ax,[Word Ptr Buffer]
       Test  Dl,80H
       Je    @@3
       Mov   Bx,Ax
       Mov   Cl,4
       Shr   Bx,Cl
       Mov   Cl,12
       Shl   Dx,Cl
       Shl   Ax,Cl
       Or    Dx,Bx
       Or    Ax,0Fffh
       Jmp   @@2
  @@3: And   Dx,0Fh
       Jmp   @@2
  @@1: Mov   Ax,0
       Mov   Dx,0
  @@2:
End;
{ ------------------------------------------------------------------------- }
Function Int2HexN(L: LongInt; N:Integer): String;
Const    Digits : Array[0..15] Of Char = '0123456789ABCDEF';
Var      S : String;
Begin
  S:='';
  While N>0 Do Begin
    S:=Digits[L And $F]+S;
    Dec(N);
    L:=L Shr 4;
  End;
  Int2HexN:=S;
End;
{ -------------------------------------------------------------------------- }


Begin
  Data:=GlobalallocPtr(Gmem_Zeroinit,$20000);
  Dsel:=Seg(Data^);
  Dpmi_SetSelectorLimit(Dsel,$1FFFF);

  GetMem(ProcPtr,$4000);
  Assign(Fil,'Test32.Bin');
  Reset(Fil,1);
  BlockRead(Fil,ProcPtr^,FileSize(Fil));
  Close(Fil);
  LongInt(@P1):=(LongInt(ProcPtr)+0*16);
  LongInt(@P2):=(LongInt(ProcPtr)+1*16);
  LongInt(@P3):=(LongInt(ProcPtr)+2*16);

  Sel:=Seg(ProcPtr^);
  Oldright:=Dpmi_GetAccessRights(Sel);
  Dpmi_SetAccessRights(Sel,(Oldright Or Dpmi_32BitSegment) And $FFF1+$A);

  Writeln('Proc:   ',Int2HexN(Sel,4),':',Int2HexN(Ofs(ProcPtr^),8));
  Writeln('Base:   ',Int2HexN(Getselectorbase(Sel),8));
  Writeln('Limit:  ',Int2HexN(Dpmi_GetSelectorLimit(Sel),8));
  Writeln('Rights: ',Int2HexN(Dpmi_GetAccessRights(Sel),4));
  Writeln;
  Writeln('Data:   ',Int2HexN(Seg(Data^),4),':',Int2HexN(Ofs(Data^),8));
  Writeln('Base:   ',Int2HexN(Getselectorbase(Dsel),8));
  Writeln('Limit:  ',Int2HexN(Dpmi_GetSelectorLimit(Dsel),8));
  Writeln('Rights: ',Int2HexN(Dpmi_GetAccessRights(Dsel),4));
  Writeln;
  Writeln('Ss:Sp:  ',Int2HexN(SSeg,4),':',Int2HexN(SPtr,4));

  Writeln('Result: ',Int2HexN(P1($12345678,$87654321),8));
  P2;
  P3(Data);

  Dpmi_SetAccessRights(Sel,Oldright);
  Dpmi_SetSelectorLimit(Dsel,$FFFF);
  GlobalfreePtr(Data);
End.


