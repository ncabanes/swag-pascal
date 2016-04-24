(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0046.PAS
  Description: Is DISK Ready ??
  Author: BRAIN PAPE
  Date: 10-28-93  11:30
*)

{===========================================================================
Date: 10-03-93 (00:14)
From: BRIAN PAPE
Subj: disk ready
---------------------------------------------------------------------------
Does anyone know if there is any better (and FASTER!) way to tell if a
disk drive is ready?  I wrote a function yesterday to do that by calling
the BIOS Read Track interrupt.  The only problem is that it has to
actually read from the disk, and it is rather slow, especially on slower
computers.

Here is my code: }

{ NOTE :

          Added a BOOLEAN function and added Reset DRIVE  GDAVIS 10/15/93}

USES CRT;

VAR
   Buf : ARRAY[0..512] OF BYTE;  { Buffer MUST be outside }

function diskstatus(drive:byte):byte; assembler;  { drive is A=0, B=1 etc}
asm
  cmp  drive,26
  jb   @driveok
  mov  drive,0   { if drive isn't between 0 and 25, make it 0 (for A:) }
  @driveok:

  mov  ax, seg buf
  mov  es, ax
  mov  bx, offset buf

  mov  ah, 02      { read disk sectors }
  mov  al, 1       { number of sectors to transfer }
  mov  ch, 1       { track number }
  mov  cl, 1       { sector number }
  mov  dh, 1       { head number }
  mov  dl, drive   { drive number (0=A, 3=C, or 80h=C, 81h=D) }
  int  13h

  mov  bl,0    { assume drive is ready }
  jnc  @done   { carry set if unsuccessfull (i.e. disk is not ready) }
  mov  bl,ah
  jmp  @done

  { take out the above two lines to make this just check
    for disk ready/not ready }

  and  ah,$80
  jz   @done   { error was something other than disk not ready }
  mov  bl,false{ disk wasn't ready. store result }
  @done:

  mov  ax,$0000  { reset drive }
  INT  13H

  xor  ax,ax   { shut off disk drive quickly }
  mov  es,ax
  mov  ax,440h
  mov  di,ax
  mov  byte ptr es:[di],01h

  mov  al,bl   { retrieve result }
end;  { diskstatus }


function diskready(drive:CHAR):BOOLEAN; assembler;
asm
  cmp  drive,'a'
  jb   @isupcase  { make it UPPER case }
  sub  drive,20H
  @isupcase:
  cmp  drive,'Z'
  jb   @driveok
  mov  drive,'A'  { if drive isn't between 'A' and 'Z', make it A) }
  @driveok:
  mov  ax, seg buf
  mov  es, ax
  mov  bx, offset buf

  mov  ah, 02  { read disk sectors }
  mov  al, 1   { number of sectors to transfer }
  mov  ch, 1   { track number }
  mov  cl, 1   { sector number }
  mov  dh, 1   { head number }

  mov        dl, drive
  sub        dl, 'A'     { subtract ORD of 'A' }

  {mov  dl, drive   { drive number (0=A, 3=C, or 80h=C, 81h=D) }
  int  13h

  mov  bl,true { assume drive is ready }
  and  ah,$80
  jz   @done   { error was something other than disk not ready }
  mov  bl,false{ disk wasn't ready. store result }
  @done:

  mov  ax,$0000  { reset drive }
  INT  13H

  xor  ax,ax   { shut off disk drive quickly }
  mov  es,ax
  mov  ax,440h
  mov  di,ax
  mov  byte ptr es:[di],01h

  mov  al,bl   { retrieve result }
end;  { diskready }

BEGIN
ClrScr;
WriteLn(DiskStatus(0));
WriteLn(DiskReady('a'));  { case ain't significant }
readkey;
END.
