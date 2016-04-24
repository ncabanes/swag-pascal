(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0018.PAS
  Description: Raw Speaker Support
  Author: MARK LEWIS
  Date: 06-08-93  08:27
*)

(*
===========================================================================
 BBS: Canada Remote Systems
Date: 05-31-93 (17:52)             Number: 24475
From: MARK LEWIS                   Refer#: NONE
  To: CHARLES LUMIA                 Recvd: NO
Subj: PC SPEAKER AND RAW SO          Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
 > Do you know how to send stuff to a PC speaker, I can't even find
 > the port # for it OR how to output any data through it?

try this on for size ... these are three TP 6.0 Assembler routines that "mimic"
the same ones that come in TP's CRT unit. DELAY was given to me by Sean Palmer
(thanks sean! it works as advertised -=B-) and the other two i hacked out
myself...

procedure delay(ms : word); Assembler;
{ms is the number of milliseconds to delay. 1000ms = 1second}
*)

asm
  mov ax,1000
  mul ms
  mov cx,dx
  mov dx,ax
  mov ah,$86
  int $15
end;

procedure sound( hertz : word); Assembler;
{hertz is the sound frequency to send to the speaker port}

asm
  MOV    BX,SP
  MOV    BX,&hertz
  MOV    AX,34DDh
  MOV    DX,0012h
  CMP    DX,BX
  JNB    @J1
  DIV    BX
  MOV    BX,AX
  IN     AL,61h
  TEST   AL,03h
  JNZ    @J2
  OR     AL,03h
  OUT    61h,AL
  MOV    AL,-4Ah
  OUT    43h,AL
@J2:
  MOV    AL,BL
  OUT    42h,AL
  MOV    AL,BH
  OUT    42h,AL
@J1:
end;

procedure nosound; Assembler;
{turns the speaker off}
asm
  IN     AL,61h
  AND    AL,0FCh
  OUT    61h,AL
end;


