(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0053.PAS
  Description: Detect Presents of VGA
  Author: SEAN PALMER
  Date: 07-16-93  06:15
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 06-30-93 (16:12)             Number: 28771
From: SEAN PALMER                  Refer#: NONE
  To: JOHN DAILEY                   Recvd: NO
Subj: VGA INFO                       Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
JD>I'm looking for a quick-and-dirty way of checking to see if
JD>a user has VGA capability in text mode.  ie. 50 line mode.
JD> Any help is appreciated.

function vgaPresent:boolean;assembler;asm
 mov ah,$F; int $10; mov oldMode,al;  {save old Gr mode}
 mov ax,$1A00; int $10;    {check for VGA/MCGA}
 cmp al,$1A; jne @ERR;     {no VGA Bios}
 cmp bl,7; jb @ERR;        {is VGA or better?}
 cmp bl,$FF; jnz @OK;
@ERR: xor al,al; jmp @EXIT;
@OK: mov al,1;
@EXIT:
 end;

otherwise you can check the BIOS save data area for number of rows on
screen... the EGA and VGA keep this updated, older adapters don't (they
set it to 0)

you can just leave the screen in the mode it was in already this way.

var
 lastRow:byte absolute $40:$84;    {newer bios only:rows on screen-1}

 * OLX 2.2 * Programming is like sex:  one mistake and you support it

--- Maximus 2.01wb
 * Origin: >>> Sun Mountain BBS <<< (303)-665-6922 (1:104/123)

