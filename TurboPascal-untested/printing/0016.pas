===========================================================================
 BBS: The Beta Connection
Date: 07-06-93 (15:28)             Number: 1525
From: CHRIS PRIEDE                 Refer#: 1378
  To: PETER KIRKWOOD                Recvd: NO  
Subj: Printer Ready?                 Conf: (232) T_Pascal_R
---------------------------------------------------------------------------
PK>    Any suggestions as to how I can check if a printer is online
PK>and/or ready would be appreciated.

    Interrupt 17h service 02h returns printer status flags. We are
interested in three:

    bit 7 = 1   Ready
    bit 5 = 1   Out of paper
    bit 3 = 1   I/O error


    Bit 7 should be 1 and bits 5, 3 -- 0. You can use the following
BASM routine to check it:

const
  pnLPT1    = 0;
  pnLPT2    = 1;
  pnLPT3    = 2;

function PrinterReady(PN: word): boolean; assembler;
asm
    mov     dx, PN              {printer number goes in DX}
    mov     ah, 02h
    int     17h                 {int. 17h service 02h}
    xor     al, al              {assume false}
    and     ah, 10101000b       {clear all other bits}
    cmp     ah, 10000000b       {ready & not out of paper or error?}
    jne     @Done               {no -- leave result false}
    inc     ax                  {yes -- change to true}
@Done:
end;
---
 * D.W.'s TOOLBOX, Atlanta GA, 404-471-6636
 * PostLink(tm) v1.06  DWTOOLBOX (#1035) : RelayNet(tm)
