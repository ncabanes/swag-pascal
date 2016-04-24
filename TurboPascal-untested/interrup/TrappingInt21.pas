(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0009.PAS
  Description: Trapping Int21
  Author: CHRIS PRIEDE
  Date: 08-17-93  08:44
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 07-15-93 (18:15)             Number: 26295
From: CHRIS PRIEDE                 Refer#: 26227
  To: PIERRE DARMON                 Recvd: NO  
Subj: DOS interrupt handler          Conf: (552) R-TP
---------------------------------------------------------------------------
PD>What additional steps need to be taken for $21? I even tried to remove
PD>the clicking part, which boils down to installing a new handler that just
PD>calls the old one. Still no go. What's wrong?

PD>My ultimate goal is to trap file opens (function 3Dh), check the SHAREing
PD>mode used (in AL), modify it if necessary, and execute the old handler.
PD>Doesn't sound like a very complicated thing to do but ... I am stuck.

    Your handler is changing some registers or suffering from some
registers being changed by INT 21. DOS EXEC service trashes everything,
including SS:SP, for example. In my opinion, one can't write a stable
INT 21 handler in Pascal or any other HLL. HLL interrupt handlers are
usable to certain extent, but this is too low level.

    It can be done in BASM, though. We will declare interrupt handler as
simple procedure with no arguments to avoid entry/exit code TP generates
for interrupt handlers. Our handler will force all files to be opened in
Deny Write mode (modify for your needs).


const
  shCompatibility = $00;
  shDenyAll       = $10;
  shDenyWrite     = $20;
  shDenyRead      = $30;
  shDenyNone      = $40;

procedure NewInt21; assembler;
asm
  cmp   ah, 3Dh         {open file?}
  je    @CheckModeAL
  cmp   ah, 6Ch         {DOS 4.0+ extended open?}
  je    @CheckModeBL    {extended takes mode in BX}
  jmp   @Chain

@CheckModeAL:
  and   al, 10001111b     {clear sharing mode bits}
  or    al, shDenyWrite   {set to our mode}
  jmp   @Chain

@CheckModeBL:
  and   bl, 10001111b
  or    bl, shDenyWrite
  jmp   @Chain

@I21:
  DD      0       {temp. var. for old vector -- must be in code seg.}

@Chain:
  push  ds
  push  ax
  mov   ax, SEG @Data
  mov   ds, ax
  mov   ax, WORD PTR OldInt21
  mov   WORD PTR cs:[offset @I21], ax
  mov   ax, WORD PTR OldInt21 +2
  mov   WORD PTR cs:[offset @I21 +2], ax
  pop   ax
  pop   ds
  jmp   DWORD PTR cs:[offset @I21]
end;


    To try this save old vector in a global variable named OldInt21 and
install this handler as usual. It also traps function 6Ch, DOS 4.0+
extended open/create. Very few programs use it, but why not...
---
 * Faster-Than-Light (FTL) ■ Atlanta, GA ■ 404-292-8761/299-3930
 * PostLink(tm) v1.06  FTL (#93) : RelayNet (tm)

