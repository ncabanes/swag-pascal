(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0054.PAS
  Description: Dosemu detection code for Linux
  Author: LIN KE-FONG
  Date: 11-29-96  08:17
*)


{ Here is a small piece of code to detect if you are running under
  a Linux's dosemu dos box.

  Truly definitive version.  .. update !!

  Copyright (C) 1996 Lin Ke-Fong. Donated to public domain.

  Feel free to ask me any questions at:
    * lin.ke-fong@ace.epita.fr
    * ke-fong.lin@nuxes.frmug.net.fr
}

function dosemu_Detect:boolean; assembler;
{ This function use two methods (which are "official") to detect dosemu.

  First if dosemu is present, the BIOS date string at 0xF000:0xFFF5 should
  be "02/25/93". Second interrupt $E6 called with ah = 0 should return $AA55
  in ax register when in a dosemu dos box. Note that interrupt $E6 should
  be "initialized" to point to an IRET instruction since it is often pointed
  on nothing by BIOS.
}

asm
  push ds

{ check for the BIOS date }
  mov  ax,$F000
  mov  ds,ax
  mov  bx,$FFF5

  mov  ax,'20'
  cmp  word ptr [bx],'20'
  jne  @no_dosemu
  cmp  word ptr [bx+2],'2/'
  jne  @no_dosemu
  cmp  word ptr [bx+4],'/5'
  jne  @no_dosemu
  cmp  word ptr [bx+6],'39'
  jne  @no_dosemu

{ initialize interrupt $E6 to an IRET }
  xor  ax,ax
  mov  ds,ax
  mov  bx,$E6 * 4
  les  di,[bx]
  mov  bl,es:[di]
  mov  byte ptr es:[di],$CF { put an iret instruction }

{ call the installation check interrupt (int $E6 with ah = 0) }
  xor  ah,ah
  int  $E6
  mov  es:[di],bl           { restore the old instruction }
  cmp  ax,$AA55
  jne  @no_dosemu

  mov  ax,01h
  jmp  #end

#no_dosemu:
  xor  ax,ax

@end:
  pop  ds
end;


begin
  if dosemu_Detect then
    writeln('Hello dosemu ! and hello Linux !')
  else
    writeln('dosemu > MSDOS 7 :-)');
end.

