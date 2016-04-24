(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0098.PAS
  Description: IDE Hard Drive Specs 2
  Author: ARNE DE.BRUIJN
  Date: 05-26-95  23:09
*)

{
> Has anyone any ideas how to interrogate an IDE drive to get
> its setup parameters

{ Read IDE drive info, Arne de Bruijn, 1994, PD }
{ Information from 'Alles over PC Hardware' by Hans-Peter Messmer }

{$G+}

uses Dos;
var
 Buffer:pointer;
{ Buffer filled with following information (word offsets):
  0 configuration:
    bit 0 reserved
        1 1=hard-sector drive
        2 1=soft-sector drive
        3 1=RLL/ARLL format
        4 1=headswitchdelay is 15 ms
        5 1=less currency mode implented
        6 1=hard disk
        7 1=exchangable medium (mostly CD-ROM drive)
        8 1=internal datatransfer <5 Mbit/s
        9 1=internal datatransfer between 5 and 10 Mbit/s
       10 1=internal datatransfer >10 Mbit/s
       11 1=rotation speed toleration >0,5% (notebook)
       12-15 reserved
  1 no of physical cylinders
  2 reserved
  3 no of heads
  4 no of not-formatted bytes per physical sector
  5 no of not-formatted bytes per sector
  6 no of physical sectors
  7-9 reserved for manufacturer
 10-19 ASCII serial number
 20 buffertype (01h one-directional, 02h bi-directional, 03h=cache buffer)
 21 buffersize/512
 22 no of ECC bytes transferred at read/writelong cmds
 23-26 ASCII controller-firmware ID
 27-46 ASCII modelnumber
 47 bit 0..7 no of sectors between two interrupts, bit 8..15 reserved
 48 bit 0: 1=32 bit-I/O, 0 no 32 bit-I/O, bit 1..7 reserved
 49 bit 0..7 reserved, bit 8: 1=DMA, 0=no DMA, bit 9: 1=LBA, 0=no LBA
 50 reserved
 51 bit 0..7 reserved, bit 8..15 PIO cyclus time
    (0=600ns, 1=380ns, 2=240ns, 3=180ns)
 52 bit 0..7 reserved, bit 8..15 DMA cyclus time
    (0=960ns, 1=380ns, 2=240ns, 3=150ns)
 53 reserved
 54 no of logical cylinders
 55 no of logical heads
 56 no of logical sectors per track
 57-58 Bytes per logical sector
 59 bit 0..7 no of sectors
 60-61 addressable sectors in LBA mode
 62 single DMA: bit 0..7=supported modes, bit 8..15=active modes
 63 multiple DMA: bit 0..7=supported modes, bit 8..15=active modes
 64-127 reserved
 128-159 manufacturer specific
 160-255 reserved
}
 GotData:boolean;

function SwitchChars(var X; Len:byte):string; assembler;
{ Returns Len bytes from X, each word swapped }
asm
 push ds
 les di,@Result
 xor ah,ah
 mov al,Len
 mov cx,ax
 shl al,1
 stosb
 jcxz @NoCopy
 lds si,X
@Copy:
 lodsw
 xchg al,ah
 stosw
 loop @Copy
@NoCopy:
 pop ds
end;

procedure HDInt; interrupt;
{ Interrupt called when data is ready }
begin
 if Port[$1f7] and 8<>0 then
  begin
   asm
    mov dx,1f0h
    les di,Buffer
    mov cx,256
    rep insw            { Get 256 words (512 bytes) }
   end;
   GotData:=true;
  end;
 Port[$a0]:=$20;        { Send EOI to PIC 2 }
 Port[$20]:=$20;        { Send EOI to PIC 1 }
end;

type
 AWord=array[0..32766] of word;
var
 Timer:longint absolute $40:$6c;
 Slave:boolean;
 LastTimer,T:byte;
 OldInt:pointer;
 OldPic1M,OldPic2M:byte;
begin
 Slave:=false; { True is check for slave, false check for master }
 GetMem(Buffer,512);
 T:=2;         { Wait 2 clock ticks }
 while (Port[$1f7] and $c0<>$40) and (T>0) do
  if byte(Timer)<>LastTimer then begin Dec(T); LastTimer:=byte(Timer); end;
 if Port[$1f7] and $c0<>$40 then
  begin
   WriteLn('Timeout 1!');
   Halt(1);
  end;
 GetIntVec($76,OldInt);   { Set interrupt (IRQ 14 = int $76) }
 SetIntVec($76,@HDInt);
 OldPic1M:=Port[$21]; OldPic2M:=Port[$a1]; { Save PIC masks }
 Port[$21]:=OldPic1M and (not 4);   { Enable IRQ 14 }
 Port[$a1]:=OldPic2M and (not 64);
 GotData:=false;
 Port[$1f6]:=$a0+byte(Slave)*16;    { Send drive no }
 Port[$1f7]:=$EC;                   { Send command code }
 T:=3;
 while (not GotData) and (T>0) do
  if byte(Timer)<>LastTimer then begin Dec(T); LastTimer:=byte(Timer); end;
 Port[$21]:=OldPic1M; Port[$a1]:=OldPic2M; { Restore PIC masks }
 SetIntVec($76,OldInt);   { Restore interrupt }
 if not GotData then
  begin
   WriteLn('Timeout 2!');
   Halt(1);
  end;
 WriteLn('Heads:',AWord(Buffer^)[3],' Cylinders:',AWord(Buffer^)[1],
  ' Sectors:',AWord(Buffer^)[6]);
 WriteLn('Serial number:',SwitchChars(AWord(Buffer^)[10],10));
 WriteLn('Controller firmware ID:',SwitchChars(AWord(Buffer^)[23],4));
 WriteLn('Modelnumber:',SwitchChars(AWord(Buffer^)[27],20));
 Port[$1F6]:=$a0+byte(Slave)*16;
 FreeMem(Buffer,512);
end.

