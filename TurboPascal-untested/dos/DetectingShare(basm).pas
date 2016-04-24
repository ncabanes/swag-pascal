(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0070.PAS
  Description: Detecting Share (BASM)
  Author: VARIOUS
  Date: 08-24-94  13:56
*)

 { Can one one post some code to check this please.}

{--------------------------------------------------------- Share loaded ? ---}
{ BAS VAN GAALEN }
function share_loaded : boolean; assembler; asm
  mov ax,01000h; int 02fh; xor ah,ah; and al,0ffh; end;

{----------------------------------------------------------------------------}
{ ANDREW EIGUS
INT 2F - SHARE - INSTALLATION CHECK
 AX = 1000h
Return: AL = 00h  not installed, OK to install
        01h  not installed, not OK to install
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

function will return True here and it should not. So this one will work:
}

Function ShareDetected : boolean; assembler;
Asm
  MOV AX,1000h
  INT 2Fh
  CMP AL,0FFh
  JE  @@1
  MOV AL,False
  JMP @@2
@@1:
  MOV AL,True
@@2:
End; { ShareDetected }

{----------------------------------------------------------------------------}
{IAN LIN}

const
 noshareinstall=0;
 nosharenoinstall=1;
 shareinstalled=$ff;

function shareloaded:byte;
assembler; asm
 mov ax,$1000
 int $2f
end;

INT 2F - SHARE - INSTALLATION CHECK
        AX = 1000h
Return: AL = 00h  not installed, OK to install
             01h  not installed, not OK to install
             FFh  installed
BUGS:        values of AL other than 00h put DOS 3.x SHARE into an infinite loop
          (08E9: OR  AL,AL
           08EB: JNZ 08EB) <- the buggy instruction (DOS 3.3)
        values of AL other than described here put PC-DOS 4.00 into the same
          loop (the buggy instructions are the same)
Notes:        supported by OS/2 v1.3+ compatibility box, which always returns AL=FFh
        if DOS 4.01 SHARE was automatically loaded, file sharing is in an
          inactive state (due to the undocumented /NC flag used by the autoload
          code) until this call is made
        DOS 5+ chains to the previous handler if AL <> 00h on entry
        Windows Enhanced mode hooks this call and reports that SHARE is
          installed even when it is not
SeeAlso: AX=1080h,INT 21/AH=52h


