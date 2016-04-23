{
FRANCOIS THUNUS

> Would it be possible to throw a [Ctrl-Alt-Del] into the keyboard buffer,
> causing Smartdrv to Write its data and warm boot the computer? if so, any
> ideal how a person would do this?

trap keyboard info
if ctr-alt-del then begin
            check For smrtdrv
            if smrtdrv then flush cache
            reboot
            end;

Flush cache: (was posted here but since it is more than a month old, i guess
it's ok to repost ?):
}

Unit SfeCache;
{

Max Maischein                                  Sunday,  7.03.1993
2:249/6.17                                         Frankfurt, GER

This  Unit  implements   an   automatic   flush   For   installed
Write-behind caches like SmartDrive and PC-Cache. It's  based  on
cache detection code by Norbert Igl, I added the calls  to  flush
the buffers. The stuff is only tested For SMARTDRV.EXE, the  rest
relies on Norbert and the INTERRUP.LST from Ralf Brown.

Al says : "Save early, save often !"

The Unit exports one  Procedure,  FlushCache,  this  flushes  the
first cache found. It  could  be  good  to  flush  everything  on
Program termination, since users are likely to switch  off  their
computers directly upon Exit from the Program.

This piece of code is donated to the public domain, but I request
that, if you use this code, you mention me in the DOCs somewhere.
                                                           -max
}
Interface

Implementation

Uses
  Dos;

Const
  AktCache : Byte = 0;

Type
  FlushProc = Procedure;

Var
  FlushCache : FlushProc;

Function SmartDrv_exe : Boolean;
Var
  Found : Boolean;
begin
  Found := False;
  Asm
    push    bp
    stc
    mov     ax, 4A10h
    xor     bx, bx
    int     2Fh
    pop     bp
    jc      @NoSmartDrive
    cmp     ax, 0BABEh
    jne     @NoSmartDrive
    mov     Found, True
   @NoSmartDrive:
  end;
  SmartDrv_exe := Found;
end;

Function SmartDrv_sys : Boolean;
Var
  F  : File;
  B  : Array[0..$27] of Byte; { return Buffer }
  OK : Boolean;
Const
  S = SizeOf( B );
begin
  SmartDrv_sys := False;
  OK := False;
  { -------Check For SmartDrv.SYS----------- }
  Assign(f,'SMARTAAR');
  {$I-}
  Reset( F );
  {$I+}
  if IoResult <> 0 then
    Exit; { No SmartDrv }
  FillChar( B, Sizeof(B), 0 );
  Asm
    push    ds
    mov     ax, 4402h
    mov     bx, TextRec( F ).Handle
    mov     cx, S
    mov     dx, seg B
    mov     ds, dx
    mov     dx, offset B
    int     21h
    jc      @Error
    mov     OK, 1
   @Error:
    pop     ds
  end;
  close(f);
  SmartDrv_sys := OK;
end;

Function CompaqPro : Boolean;
Var
  OK : Boolean;
begin
  CompaqPro := False;
  OK := False;
  Asm
    mov     ax, 0F400h
    int     16h
    cmp     ah, 0E2h
    jne     @NoCache
    or      al, al
    je      @NoCache
    cmp     al, 2
    ja      @NoCache
    mov     OK, 1
   @NoCache:
  end;
  CompaqPro := OK;
end;

Function PC6 : Boolean;   { PCTools v6, v5 }
Var
  OK : Boolean;
begin
  PC6 := False;
  OK := False;
  Asm
    mov     ax, 0FFA5h
    mov     cx, 01111h
    int     16h
    or      ch, ch
    jne     @NoCache
    mov     OK, 1
   @NoCache:
  end;
  PC6 := OK;
end;

Function PC5 : Boolean;
Var
  OK : Boolean;
begin
  PC5 := False;
  OK := False;
  Asm
    mov     ax, 02BFFh
    mov     cx, 'CX';
    int     21h
    or      al, al
    jne     @NoCache
    mov     ok, 1
   @NoCache:
  end;
  PC5 := OK;
end;

Function HyperDsk : Boolean;   { 4.20+ ... }
Var
  OK : Boolean;
begin
  Hyperdsk := False;
  OK := False;
  Asm
    mov     ax, 0DF00h
    mov     bx, 'DH'
    int     02Fh
    cmp     al, 0FFh
    jne     @NoCache
    cmp     cx, 05948h
    jne     @NoCache
    mov     OK, 1
   @NoCache:
  end;
  HyperDSK := OK;
end;

Function QCache : Boolean;
Var
  OK : Boolean;
begin
  QCache := False;
  OK := False;
  Asm
    mov     ah, 027h
    xor     bx, bx
    int     013h
    or      bx, bx
    je      @NoCache
    mov     OK, 1
   @NoCache:
  end;
  QCache := OK;
end;

Procedure FlushSD_sys; Far;
Var
  F : File;
  B : Byte;
begin
  Assign(F, 'SMARTAAR');
  Reset(F);
  B := 0;
  Asm
    push    ds
    mov     ax, 04403h
    mov     bx, FileRec(F).Handle
    mov     cx, 1
    int     21h
    pop     ds
  end;
end;

Procedure FlushSD_exe; Far; Assembler;
Asm
  mov     ax, 04A10h
  mov     bx, 1
  int     2Fh
end;

Procedure FlushPC6; Far; Assembler;
Asm
  mov     ax, 0F5A5h
  mov     cx, -1
  int     16h
end;

Procedure FlushPC5; Far; Assembler;
Asm
  mov     ah, 0A1h
  mov     si, 04358h
  int     13h
end;

Procedure FlushNoCache; Far;
begin
end;

begin
  if SmartDrv_exe then
    FlushCache := FlushSD_exe
  else
  if SmartDrv_sys then
    FlushCache := FlushSD_sys
  else
  if PC6 then
    FlushCache := FlushPC6
  else
  if PC5 then
    FlushCache := FlushPC5
  else
    FlushCache := FlushNoCache;

  FlushCache;
end.
