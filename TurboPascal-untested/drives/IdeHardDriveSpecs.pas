(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0097.PAS
  Description: IDE Hard Drive Specs
  Author: IVAN HAMILTON
  Date: 05-26-95  23:08
*)

{
> Has anyone any ideas how to interrogate an IDE drive to get its
> setup parameters, ie. number of cylinders, heads and sectors, as
> some of the more recent BIOS's seem to be able to do?

 The code below identifies some of the params. Actually, it identifies
 most of what you'd ever need.
 Theres only one catch. The main program checks the letter given on the
 command line using a function:
 DriveValid(Drive: Char; var Drv: Byte): Boolean; assembler;
 This returns the numeric equivalent of the Drive character into Drv and
 returns true/false if the Drive is Valid. The trick is the validity check
 is done by DOS. Meaning that on my machine, my second drive, a HPFS drive
 won't show up unless I stick something like Drive=3 (Second HDD) and
 disable the DriveValid check. I hope this helps.

}

(*******************************************************************
    idediag
    shows characteristics of IDE hard disks.
    Public Domain by Paolo Bevilacqua, Rome.
    Rewritten from C to Turbo Pascal 7.0 by Ivan Peev, Sofia.
    You can add more disk type to the idetypes[]
    table, and distribuite freely.
********************************************************************)

const
{ read/write }
   HDC_DATA    = $01F0;
   HDC_ERROR   = $01F1;
   HDC_SECCOU  = $01F2;
   HDC_SECNUM  = $01F3;
   HDC_CYLLOW  = $01F4;
   HDC_CYLHIGH = $01F5;
   HDC_SDH     = $01F6;

{ read }
   HDC_STATUS  : Word = $01F7;
   HDC_ALTSTA  = $03F6;

{ write }
   HDC_COMMAND = $01F7;
   HDC_FIXED   = $03F6;

{ commands }
   HDC_COMMAND_RESTORE = $10;
   HDC_COMMAND_SEEK    = $70;
   HDC_COMMAND_READ    = $20;
   HDC_COMMAND_WRITE   = $30;
   HDC_COMMAND_FORMAT  = $50;
   HDC_COMMAND_READVER = $90;
   HDC_COMMAND_DIAG    = $90;
   HDC_COMMAND_SETPAR  = $91;
   HDC_COMMAND_WRSTACK = $E8;
   HDC_COMMAND_RDSTACK = $E4;
   HDC_COMMAND_READPAR = $EC;
   HDC_COMMAND_POWER   = $E0;

   HDC_FIXED_IRQ       = $02;
   HDC_FIXED_RESET     = $04;

   HDC_STATUS_ERROR    = $01;
   HDC_STATUS_INDEX    = $02;
   HDC_STATUS_ECC      = $04;
   HDC_STATUS_DRQ      = $08;
   HDC_STATUS_COMPLETE = $10;
   HDC_STATUS_WRFAULT  = $20;
   HDC_STATUS_READY    = $40;
   HDC_STATUS_BUSY     = $80;

type
   TIdeTypes = record
      Cylinders,
      Heads,
      Sectors: Word;
      Name: String[38];
   end;

   PIdeInfo = ^TIdeInfo;
   TIdeInfo = record
      genconf,
      fixcyls,
      remcyls,
      heads,
      bytetrack,                     { bytes per track }
      bytesector,                    { bytes per sector }
      sectors,	                     { sectors per track }
      byteisg,	                     { bytes intesector gap }
      byteplo,	                     { bytes in sync }
      worduniq: Word;                { words unique status }
      serial: array[1..20] of Char;
      contype,                       { controller type }
      bufsiz,	                     { buffer size in 512 byte blocks }
      byteecc: Word;	             { ECC bytes trasferred in read/write long }
      firmware: array[1..8] of Char; { firmware revision }
      model: array[1..40] of Char;   { model ID }
      secsint,	                     { number of sectors transferred per
interrupt }      dblword,	                     { double word transfer flag }
      writepro: Word;                { write protect }
   end;

const
   IdesInDataBase = 17;

   IdeTypes: array[1..IdesInDataBase] of TIdeTypes =
   ((Cylinders:667;  Heads:4;  Sectors:33; Name:'Fujitsu M2611T (42.9 MB)'),
    (Cylinders:667;  Heads:8;  Sectors:33; Name:'Fujitsu M2612T (85.9 MB)'),
    (Cylinders:667;  Heads:12; Sectors:33; Name:'Fujitsu M2613T (128.9 MB)'),
    (Cylinders:667;  Heads:16; Sectors:33; Name:'Fujitsu M2614T (171.9 MB)'),
    (Cylinders:782;  Heads:2;  Sectors:27; Name:'Western Digital WD93024-A (20.6 MB)'),
    (Cylinders:782;  Heads:4;  Sectors:27; Name:'Western Digital WD93044-A (41.2 MB)'),
    (Cylinders:845;  Heads:3;  Sectors:35; Name:'Toshiba MK232FC (45.4 MB'),
    (Cylinders:845;  Heads:7;  Sectors:35; Name:'Toshiba MK234FC (106 MB'),
    (Cylinders:965;  Heads:5;  Sectors:17; Name:'Quantum ProDrive 40AT (40 MB)'),
    (Cylinders:965;  Heads:10; Sectors:17; Name:'Quantum ProDrive 80AT (80 MB)'),
    (Cylinders:1050; Heads:2;  Sectors:40; Name:'Teac SD-340 (41 MB)'),
    (Cylinders:776;  Heads:8;  Sectors:33; Name:'Conner CP-3104 (100 MB)'),
    (Cylinders:745;  Heads:4;  Sectors:28; Name:'Priam 3804M (40.7 MB)'),
    (Cylinders:980;  Heads:10; Sectors:17; Name:'Western Digitial Caviar AC280 (81 MB)'),
    (Cylinders:560;  Heads:6;  Sectors:26; Name:'Seagate ST157A (42 MB)'),
    (Cylinders:732;  Heads:8;  Sectors:35; Name:'ALPS ELECTRIC Co.,LTD. DR311C (102 MB)'),
    (Cylinders:0;    Heads:0;  Sectors:0;  Name:''));

type
   parray = ^tarray;
   tarray = array[1..256] of Word;

var
   secbuf: parray;
   drive: Byte;
   drv: String[1];

procedure printinfo;

var
   id: TIdeInfo;
   capacity: Word;
   types: String;
   i: Integer;

   function zo(const value: Byte): String;
   begin
      if Boolean(value) then
         zo := ''
      else
         zo := 'not';
   end;

   function ToStr(value: LongInt): String;
   var
      S: String;
   begin
      Str(value, S);
      ToStr := S;
   end;

   function ConvertHex(Value: Word): String;

   const
      hexTable: array[0..15] of Char = '0123456789ABCDEF';

   begin
      ConvertHex := hexTable[Hi(Value) shr 4] + hexTable[Hi(Value) and $f] +
                    hexTable[Lo(Value) shr 4] + hexTable[Lo(Value) and $f];
   end;

   procedure SwapBytes(var Source, Dest; Len: Byte); assembler;
   asm
       push  ds

       lds   si, Source
       les   di, Dest
       mov   cl, len
       xor   ch, ch

   @1: mov   ax, ds:[si]
       xchg  ah, al
       mov   es:[di], ax
       inc   si
       inc   si
       inc   di
       inc   di
       loop  @1

       pop    ds
   end;

begin
   id := PIdeInfo(secbuf)^;

   { get disk type by characteristics }
   i := 1;
   while IdeTypes[i].Cylinders <> 0 do
      Begin
	 if (IdeTypes[i].cylinders = id.fixcyls) and
	    (IdeTypes[i].heads = id.heads) and
	    (IdeTypes[i].sectors = id.sectors) then
            Begin
               types := IdeTypes[i].name;
               break;
            end;
         inc(i);
      end;

   { unknown disk }
   if (IdeTypes[i].cylinders = 0) then
      Begin
         types := 'Unknown ';

         { calculate capacity in MB }
	 capacity := (LongInt(id.fixcyls) * id.heads * id.sectors) div 2048;
         types := types + ToStr(capacity);
         types := types + ' Mbytes';
      end;

   { swap bytes in ASCII fields except for WD disks }

   if (i <> 4) and (i <> 5) then
      Begin
         SwapBytes(id.serial, id.serial, 10);
         SwapBytes(id.firmware, id.firmware, 4);
         SwapBytes(id.model, id.model, 20);
      end;

   WriteLn('Informations for drive ', drive-2, ', ', types);
   WriteLn('Drive ID ', ConvertHex(id.genconf));
   WriteLn(id.fixcyls, ' fixed cylinders, ', id.remcyls, ' removables');
   WriteLn(id.heads, ' heads, ', id.sectors, ' sectors');
   WriteLn('Serial number: ', id.serial);
   WriteLn('Controller firmware: ', id.firmware);
   WriteLn('Controller model: ', id.model);
   WriteLn(id.bytetrack, ' bytes per track, ', id.bytesector, ' per sector');
   WriteLn(id.byteisg, ' bytes of intersector gap, ', id.byteplo, ' of sync');
   WriteLn('Controller type ', id.contype, ', buffer ', id.bufsiz div 2, 'KBytes');
   WriteLn(id.byteecc, ' bytes of ECC, ', id.secsint, ' sector(s) transferred per interrupt');
   WriteLn('Double word transfer ', zo(id.dblword), ' allowed, ', zo(id.writepro), 'write protected.');
end;

procedure readsect; assembler;
asm
{ poll DRQ }
@1: mov   dx, HDC_STATUS
    in    al, dx
    and   al, HDC_STATUS_BUSY
    or    al, al
    jne   @1

{ read up sector }
    mov   cx, 256
    mov   dx, HDC_DATA
    les   di, secbuf
@2: in    ax, dx
    mov   es:[di], ax
    inc   di
    inc   di
    loop  @2
end;

function DriveValid(Drive: Char; var Drv: Byte): Boolean; assembler;
asm
    mov   ah, 19h      { Save the current drive in BL }
    int   21h
    mov   bl, al
    mov   dl, Drive    { Select the given drive }
    sub   dl, 'A'
    les   di, DRV
    mov   es:[di], dl
    mov   ah, 0Eh
    int   21h
    mov   ah, 19h      { Retrieve what DOS thinks is current }
    int   21h
    mov   cx, 0        { Assume false }
    cmp   al, dl       { Is the current drive the given drive? }
    jne   @1
    mov   cx, 1        { It is, so the drive is valid }
    mov   dl, bl       { Restore the old drive }
    mov   ah, 0eh
    int   21h
@1: xchg  ax, cx       { Put the return value into AX }
end;

function CurDisk: Byte; assembler;
{ Returns current drive }
asm
    mov   ah, 19h
    int   21h
end;

begin
   if ParamCount > 0 then
      Begin
         drv := ParamStr(1);
         drv[1] := UpCase(drv[1]);
         if not DriveValid(drv[1], Drive) or not (drv[1] in ['C'..'Z']) then
            Begin
               WriteLn('There isn''t such drive or drive invalid!');
               Halt(1);
            end;
      end
   else
      drive := CurDisk;

   { disable interrupt from drive }
   Port[HDC_FIXED] := HDC_FIXED_IRQ;

   { set up task file parameter }
   Port[HDC_SDH] := $A0 + (drive shl 4);

   { issue read parameters }
   Port[HDC_COMMAND] := HDC_COMMAND_READPAR;

   GetMem(secbuf, SizeOf(secbuf));

   { read up sector }
   readsect;

   { print out info }
   printinfo;

   FreeMem(secbuf, SizeOf(secbuf));
end.

