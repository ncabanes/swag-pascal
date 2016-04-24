(*
  Category: SWAG Title: DESQVIEW ROUTINES
  Original name: 0003.PAS
  Description: Time SLICES for OS/2 & DV
  Author: FRED COHEN
  Date: 11-26-93  18:18
*)

{
From: FRED COHEN
      Time Slices...

looking for routines for giving up time slices to
various multi-taskers, mainly DV and OS/2.  Please either
post them if they are small enough, or tell me where I can

You will need turbo pascal 6.0+ for this to compile.  It is easy to
convert over to regular pascal though.
}

Const

  MDOS = 0;  { DOS               }
  OS2  = 1;  { OS/2 is installed }
  WIN  = 2;  { Windoze           }
  DV   = 3;  { DesqView          }

Var

  Ops            : Byte;    { Operating System OS/2/DOS/WIN/DV}


PROCEDURE giveslice; Assembler; {Gives up remainder of clock cycle
                                 under dos, windows, os/2 }
  asm
    CMP ops,MDos { Compare to DOS }
    JE @MSDOS    { Jump if = }
    CMP ops,Dv   { Compare to Desqview }
    JE @DESQVIEW { Jump if = }
    CMP ops, Win { Compare to Windows }
    JE @WINOS2   { Jump if = }
    CMP ops, OS2 { Compart OS/2 }
    JE @WINOS2   { Jump if = }
    JMP @NONE    { None found, Jump to End }


 @MSDOS:
    INT 28h   { Interupt 28h }
    JMP @NONE { Jump to the end }

 @DESQVIEW:
    MOV ax,1000h { AX = 1000h }
    INT 15h      { Call Interupt 15h }
    JMP @NONE    { Jump to the end }

 @WINOS2:
    MOV AX, 1680h { AX = 1680h }
    INT 2Fh       { Call Interupt 2Fh for Win-OS/2 TimeSlice }

 @NONE:

end; {GiveSlice}

{***********}

PROCEDURE checkos; Assembler;
{ Currently Supports DesqView, Microsoft Windows and IBM's OS/2 }

asm
  mov ops, MDos { Default DOS }
  mov ah, 30h   { AH = 30h }
  int 21h  { dos version }
  cmp al, 14h
  jae @IBMOS2 { Jump if >= to 20 }


  mov ax,2B01h
  mov cx,4445h
  mov dx,5351h
  int 21h { Desqview Installed? }
  cmp al, 255
  jne @DesqView { Jump if AL <> 255 }

  mov ax,160Ah
  int 2Fh { Windows Install?}
  cmp ax, 0h
  je @Windows { If = Jump to Windows }
  jmp @Finish { Nothing found, go to the end }

@IBMOS2:
  mov Ops, Os2  { Set OS Value }
  jmp @Finish

@DesqView:
  mov ops, Dv   { Set OS Value }
  jmp @Finish

@Windows:
  mov ops, win  { Set OS Value }
  jmp @Finish

@FINISH:
end; { checkos }

{***********  MORE  ********}

procedure GiveTimeSlice;  ASSEMBLER;
asm     { GiveTimeSlice }
  cmp   MultiTasker, DesqView
  je    @DVwait
  cmp   MultiTasker, Windows
  je    @WinOS2wait
  cmp   MultiTasker, OS2
  je    @WinOS2wait
  cmp   MultiTasker, NetWare
  je    @Netwarewait
  cmp   MultiTasker, DoubleDOS
  je    @DoubleDOSwait

@Doswait:
  int   $28
  jmp   @WaitDone

@DVwait:
  mov   AX, $1000
  int   $15
  jmp   @WaitDone

@DoubleDOSwait:
  mov   AX, $EE01
  int   $21
  jmp   @WaitDone

@WinOS2wait:
  mov   AX, $1680
  int   $2F
  jmp   @WaitDone

@Netwarewait:
  mov   BX, $000A
  int   $7A

@WaitDone:
end;    { TimeSlice }


