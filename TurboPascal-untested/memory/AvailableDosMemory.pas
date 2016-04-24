(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0071.PAS
  Description: Available DOS Memory
  Author: ANDREW EIGUS
  Date: 05-26-95  23:01
*)

{
  From: Andrew Eigus                                 Read: Yes    Replied: No

> Well, the subject says it, how can I get a 65536 Bytes hunk of memory?
> There has to be another way, maybe a dos call or something?

Yes. The following are routines to allocate memory using DOS functions,
the limitation is that HeapMin and HeapMax should be set both to zero like
this: {$M 8192,0,0}

Function DosMaxAvail : longint;
{$IFNDEF ProtectedMode}
assembler;
{ Returns the size of the largest contiguous free memory block
  This function should be called ONLY when both HeapMin/HeapMax
  memory allocation parameters set to zero }
Asm
  mov bx,0FFFFh
  mov ah,48h
  int 21h
  mov ax,bx
  mov bx,16
  mul BX
End;
{$ELSE}
Begin
  DosMaxAvail := GetFreeSpace(0) { uses WinAPI for DPMI }
End; { DosMaxAvail }
{$ENDIF}

Function DosGetMem(Size : longint) : pointer;
{ Creates a dynamic variable of the specified size and returns the pointer
  to it. This function should be called ONLY when both HeapMin/HeapMax
  memory allocation parameters set to zero. This function returns a pointer to
  allocated data buffer which can lie in different segments, or it returns
  a nil pointer if the dos call was unsuccessful; in that case, the
Dos.DosError variable keeps error code }{$IFNDEF ProtectedMode}
assembler;
Asm
@@1:
  mov DosError,0 { uses Dos }
  mov ax,word ptr [Size]
  mov dx,word ptr [Size+2]
  mov cx,16
  div cx
  inc ax
  mov bx,ax
  mov ah,48h
  int 21h
  jnc @@2
  mov DosError,ax { save error code in Dos.DosError variable }
  xor ax,ax { return nil pointer }
@@2:
  mov dx,ax { save segment }
  xor ax,ax { offset allways zero }
End;
{$ELSE}
Begin
  DosGetMem := GlobalAllocPtr(gmem_ZeroInit or gmem_Moveable, Size) { WinAPI }
End; { DosGetMem }
{$ENDIF}

Function DosFreeMem(P : pointer) : integer;
{ Disposes of a given dynamic variable. This function should be called ONLY
  when both HeapMin/HeapMax memory allocation parameters set to zero. This
  function returns non-zero DOS error code if the function failed, or zero
  if the call was successful }
{$IFNDEF ProtectedMode}
assembler;
Asm
  mov DosError,0 { set Dos.DosError to noerror }
  mov es,word ptr [P+2]
  mov ah,49h
  int 21h
  jnc @@1
  mov DosError,ax
End;
{$ELSE}
Begin
  DosFreeMem := GlobalFreePtr(P)
End; { DosFreeMem }
{$ENDIF}

Function DosRegetMem(P : pointer; NewSize : longint) : pointer;
{ Changes the size of an existing memory block. This function should be called
  ONLY when both HeapMin/HeapMax memory allocation parameters set to zero.
  It returns a nil pointer, if the call was unsuccessful, otherwise it returns
  a pointer to reallocated data buffer }
{$IFNDEF ProtectedMode}
assembler;
Asm
@@1:
  mov DosError,0 { using Dos unit still :) }
  mov ax,word ptr [NewSize]
  mov dx,word ptr [NewSize+2]
  mov cx,16
  div cx
  inc ax
  mov bx,ax
  mov ah,4Ah
  int 21h
  jnc @@2
  mov DorError,ax { save error code in DosError }
  xor ax,ax { return a nil pointer }
@@2:
  mov dx,ax
  xor ax,ax
End;
{$ELSE}
Begin
  DosRegetMem := GlobalReallocPtr(P, NewSize, gmem_ZeroInit or gmem_Moveable)
End; { DosRegetMem }
{$ENDIF}

Example:

  {$M 4096,0,0}
  var P : pointer;

  Begin
    P := DosGetMem(128 shl 10); { allocate 128k }
    if P = nil then
      WriteLn('It seems that you haven''t enough memory, eh?')
    else
    begin
      P := DosRegetMem(256 shl 10); { reallocate this block to 256k }
      if P = nil then
        WriteLn('No, 256k is too much! :-)')
    end;
    DosFreeMem(P)
  End.


