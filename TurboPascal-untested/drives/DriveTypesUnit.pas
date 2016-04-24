(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0094.PAS
  Description: Drive Types Unit
  Author: ANDREW EIGUS
  Date: 02-28-95  09:57
*)


{$S-,R-,I-,X+}
unit DrvTypes;
{ drive types }

interface

const
  dtError      = $00; { Bad drive }
  dtFixed      = $01; { Fixed drive }
  dtRemovable  = $02; { Removeable (floppy) drive }
  dtRemote     = $03; { Remote (network) drive }
  dtCDROM      = $04; { MSCDEX V2.00+ driven CD-ROM drive }
  dtDblSpace   = $05; { DoubleSpace compressed drive }
  dtSUBST      = $06; { SUBST'ed drive }
  dtStacker4   = $07; { Stacker 4 compressed drive }
  dtRAM        = $08; { RAM drive }

function GetDriveType(Drive : Byte) : Byte;

implementation

type
 ControlBlk25 = record { control block for INT 25 extended call }
   StartSector : LongInt; { start sector to read }
   Count     : Word;    { number of sectors to read }
   BufferOffs  : Word;    { data buffer offset }
   BufferSeg   : Word;    { data buffer segment }
         end;
const
  checkABforStacker : boolean = False;

function checkStacker4( Drive : Byte ) : Boolean; assembler;
{ returns True if Drive is Stacker 4 compressed volume, False otherwise.
  This also may return True with previous versions of Stacker - I didn't
  check it. /Bobby Z. 29/11/94 }
var CB   : ControlBlk25;
    Boot : array[1..512] of Byte;
asm
 push ds
 mov al,Drive
 or checkABforStacker,0 { check A: & B: for Stacker volume? }
 jnz @@1
 cmp al,1
 ja @@1
 sub al,al
 jmp @@Q
@@1:
 push ss
 pop ds
 lea bx,CB
 sub ax,ax
 mov word ptr ds:ControlBlk25[bx].StartSector,ax
 mov word ptr ds:ControlBlk25[bx].StartSector[2],ax
 mov word ptr ds:ControlBlk25[bx].Count,1
 lea dx,Boot
 mov word ptr ds:ControlBlk25[bx].BufferOffs,dx
 mov word ptr ds:ControlBlk25[bx].BufferSeg,ds
 mov al,Drive
 sub cx,cx
 dec cx
 mov si,sp
 int 25h
 cli
 mov sp,si
 sti
 pushf
 lea si,Boot
 add si,1F0h  { Stacker signature CD13CD14CD01CD03 should }
 sub al,al  { appear at offset 1F0 of boot sector.      }
 popf
 jc @@Q  { was error reading boot sector - assume    }
    { not Stacker drive                         }
 cmp word ptr ds:[si],13CDh
 jnz @@Q
 cmp word ptr ds:[si][2],14CDh
 jnz @@Q
 cmp word ptr ds:[si][4],01CDh
 jnz @@Q
 cmp word ptr ds:[si][6],03CDh
 jnz @@Q
 mov al,1
@@Q:
 pop ds
end;

function GetDriveType; assembler;
{ Detects the type of a specified drive. Drive is a drive number, where
  0=default (current) drive, 1=drive A, 2=B, ... This function will return
  one of the dtXXX-constants.

  Note: Function will work under DOS version 3.1 or later

  THIS CODE IS PUBLIC DOMAIN

  Written by Mr. Byte, 12/08/94
  Additions and fixes by Bobby Z., 29/11/94
  RAM drive check code by Janis Smits, 07/12/94 }
asm
 cmp Drive,0
 jne @@1
 mov ah,19h    { get active drive number in al }
 int 21h
 inc al
 mov Drive,al
@@1:
 mov ax,1500h  { check for CD-ROM v2.00+ }
 sub bx,bx
 int 2Fh
 or bx,bx
 jz @@2
 mov ax,150Bh
 sub ch,ch
 mov cl,Drive
 int 2Fh
 cmp bx,0ADADh
 jne @@2
 or ax,ax
 jz @@2
 mov bl,dtCDROM
 jmp @@7
@@2:
 mov ax,4409h     { check for SUBST'ed drive }
 mov bl,Drive
 int 21h
 jc @@9
 test dh,10000000b
 jz @@9
 mov bl,dtSUBST
 jmp @@7
@@9:
 mov ax,4A11h  { check for DoubleSpace drive }
 mov bx,1
 mov dl,Drive
 dec dl
 int 2Fh
 sub cl,cl     { mov cl,False }
 or ax,ax     { is DoubleSpace loaded? }
 jnz @@3
 cmp dl,bl     { if a host drive equal to compressed, then get out... }
 je @@3
 test bl,10000000b { bit 7=1: DL=compressed,BL=host
                                    =0: DL=host,BL=compressed }
 jz @@3       { so avoid host drives, assume host=fixed :) }
 inc dl
 cmp Drive,dl
 jne @@3
 mov bl,dtDblSpace
 jmp @@7
@@3:
 mov ax,4409h     { check for remote drive }
 mov bl,Drive
 int 21h
 jc @@5
 and dx,1000h     { this is correct way to check if drive is remote
          one, Andrew. Your version didn't work...
          /Bobby Z., 29/11/94 }
 jz @@4
 mov bl,dtRemote
 jmp @@7
@@4:
 mov al,Drive     { check for Stacker 4 volume }
 or al,al
 jz @@getDrv
 dec al
@@goStac:
 push ax
 call checkStacker4
 or al,al
 jz @@8
 mov bl,dtStacker4
 jmp @@7
@@8:
 mov ax,4408h     { check for fixed (hard) drive }
 mov bl,Drive
 int 21h
 jc @@5
 or al,al
 jz @@6
 push ds           { check for RAM drive }
 mov ax,ss
 mov ds,ax
 mov si,sp
 sub sp,28h       { allocate 28h bytes on stack }
 mov dx,sp
 mov ax,440Dh     { generic IOCTL }
 mov cx,860h      { get device parameters }
 mov bl,Drive
 int 21h          { RAMDrive and VDISK don't support this command }
 mov sp,si
 pop ds
 mov bl,dtRAM
 jc  @@7
 mov bl,dtFixed
 jmp @@7
@@5:
 sub bl,bl     { mov bl,dtError cuz dtError=0 }
 jmp @@7
@@getDrv:
 mov ah,19h
 int 21h
 jmp @@goStac
@@6:
 mov bl,dtRemovable   { else - removeable media }
@@7:
 mov al,bl
end; { GetDriveType }

end.

{ --------------------- TEST PROGRAM --------------------------}
{$S-,I-,R-,X+}
uses DrvTypes;

var C : Char;

function FloppyDrives : byte; assembler;
asm
        int 11h
        test al,00000001b
        jz  @@1
{$IFOPT G+}
        shr al,6
{$ELSE}
        mov cl,6
        shr al,cl
{$ENDIF}
        and al,3
        inc al
        retn
@@1:
        xor al,al
end;

begin
 WriteLn('Drive Map  Version 1.1  Written by Andrew Eigus and Bobby Z.'#13#10);
 for C := 'A' to 'Z' do
  case GetDriveType(Byte(C)-Byte('A')+1) of
   dtCDROM: WriteLn('Drive ', C, ': is CD-ROM drive');
   dtSUBST: WriteLn('Drive ',C,': is SUBST''ed drive');
   dtRAM: WriteLn('Drive ', C, ': is RAM drive');
   dtRemote: WriteLn('Drive ', C, ': is remote (network) drive');
   dtFixed: WriteLn('Drive ', C, ': is local hard drive');
   dtRemovable:
   if (Byte(C) - Byte('A') + 1) in [1..FloppyDrives] then WriteLn('Drive ',C, ': is removable (floppy) drive');
   dtDblSpace: WriteLn('Drive ', C, ': is DoubleSpace compressed drive');
   dtStacker4: WriteLn('Drive ', C, ': is ','Stacker 4 compressed drive');
   end;
end.

