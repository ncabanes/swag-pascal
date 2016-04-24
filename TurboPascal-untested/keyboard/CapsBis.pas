(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0088.PAS
  Description: Caps
  Author: ANDREW EIGUS
  Date: 11-26-94  05:08
*)

{
 JA> Does anyone have some code to turn the capslock, numlock and scrolllock
 JA> keys on and off?

Yes.

>cut here

{$X+}{$G+}
Program SmallToggleDemo;
{ Written by Andrew Eigus of 2:5100/33, no int 16h, direct memory operations;
  Public Domain; Released for SWAG!!! }

uses Crt;

const
  { Lock keys (lk) constants }

  lkScrollLock = $10; { Scroll Lock toggle key }
  lkNumLock    = $20; { Num Lock toggle key }
  lkCapsLock   = $40; { Caps Lock toggle key }
  lkInsMode    = $80; { Insert toggle key }

Function KbdGetFlags : word; near; assembler;
{ Returns keyboard status word at 0040:0017 }
Asm
  mov es,Seg0040
  mov ax,es:[0017h]
End; { KbdGetFlags }

Function GetLockState(LockKey : byte) : boolean; assembler;
{ Returns the status of Scroll, Caps, Num and Insert modes }
Asm
  call KbdGetFlags
  and al,LockKey
End; { GetLockState }

Procedure ToggleLockState(LockKey : byte; State : boolean); assembler;
{ Toggles Scroll, Caps, Num and Insert modes }
Asm
  cli
  call KbdGetFlags
  or  State,False
  jz  @@1
  or  al,LockKey       { turn state on }
  jmp @@2
@@1:
  test al,LockKey
  jz  @@4
  xor al,LockKey
@@2:
  mov byte ptr es:[0017h],al { set new state }
  cmp LockKey,lkInsMode
  je  @@4                { don't have a LED for Insert :) }
  mov ah,al
  mov dx,60h
  mov al,0EDh
  out dx,al
  mov cx,2000h
@@3:
  loop @@3               { delay ~10ms+ }
  mov al,ah
  shr al,4
  out dx,al              { turn LED on/off }
@@4:
  sti
End; { ToggleLockState }

Begin
  repeat
    ToggleLockState(lkNumLock, not GetLockState(lkNumLock));
    Delay(100);
    ToggleLockState(lkCapsLock, not GetLockState(lkCapsLock));
    Delay(100);
    ToggleLockState(lkScrollLock, not GetLockState(lkScrollLock));
    Delay(100)
  until KeyPressed;
  ReadKey;
  ToggleLockState(lkNumLock, False);
  ToggleLockState(lkCapsLock, False);
  ToggleLockState(lkScrollLock, False)
End.


