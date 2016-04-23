{
> I'm programming in BP 7.0 and would like to know how one can read/write
> some clusters, sectors and boot records from a disk (hard or flop).

You need the dos interrupts $25 and $26. But, they have a quirk, they don't
pop off the flags register (which is stored by the INT instruction).
Also, you need to know which calling method you need, with 16 bit or 32 bit
cluster numbers.
}
{ Some proc's to read/write sectors, PD by Arne de Bruijn }
uses Dos,Strings;
type
 JmpRec=record       { The starting jump in the bootsector }
  Code:byte; { $E9 XX XX / $EB XX XX}
  case byte of
   0:(Adr1:byte; NOP:byte);
   1:(Adr2:word);
 end;
 BpbRec=record       { The Bios Data Block (returned by DOS, and stored in }
BytesPSec:word;    { the bootsector }  SecPClus:byte;
  ResSec:word;
  NrFATs:byte;
  NrROOT:word;
  TotalSec:word;
  MDB:byte;
  SecPFAT:word;
  SecPSpoor:word;
  NrHead:word;
  HidSec32:longint;
  TotalSec32:longint;
 end;
 BootSec=record      { The bootsector format in DOS }
  JmpCode:JmpRec;
  Name:array[0..7] of char; { Isn't meaningfull at all, just FORMAT prg name }
  Bpb:BpbRec;
 end;
 BootSecP=^BootSec;
var
 BigPart:boolean;                 { 32-bit sectors? }
 Drive:byte;                      { which drive are we using }
 ROOTSec,FATSec,DataSec:longint;  { Some starting sectors }
 FAT12:boolean;                   { 12-bit FAT? }
 LastSecNo:longint;               { Save last sector number... }
 LastError:word;                  { ... and error code for error report }

function ReadSec(SecNo:longint; var Buf):boolean; assembler;
{ Read a sector using DOS int 25h }
{ Parameters: }
{  SecNo   Sector number to read }
{  Buf     Your buffer to receive the data (512 bytes will be stored here, }
{          make sure you have enough space allocated!) }
{ Returns TRUE if success, else FALSE }
{ Uses global boolean BigPart to choose between 16-bit (false) and }
{ 32-bit (true) sector number calling }
{ Uses global byte Drive to choose the drive to read from. 0=A:, 1=B: etc. }
var
 ParBuf:array[0..9] of byte;
 { Buffer to hold parameters on 32-bit sector call: }
 {  ofs size         meaning }
 {   0   4 (longint) sectornumber }
 {   4   2 (word)    number of sectors to read (set to 1 in this proc.) }
 {   6   4 (pointer) address of buffer }
asm
 { Copy sectornumber to global var for error report }
 mov ax,word ptr [SecNo]
 mov word ptr [LastSecNo],ax
 mov ax,word ptr [SecNo+2]
 mov word ptr [LastSecNo+2],ax
 push ds                { Store DS register (needs to be preserved in TP/BP) }
 mov al,Drive           { Load Drive no. from global var (DS points still to }
                        { data segment }
 push ax                { Store it on stack }
 cmp BigPart,0          { Must we use 32-bit calling? }
 jne @DoBig             { Yes -> goto @DoBig,  No -> continue with 16-bit }
 lds bx,Buf             { Load address of buffer (Buf) }
 mov cx,1               { Number of sectors to read }
 mov dx,word ptr [SecNo] { Get number of sector to read (SecNr) }
 jmp @DosRead           { goto @DosRead, skip the 32-bit part }
@DoBig:
 cld                    { Store forwards in parameter buffer }
 mov ax,ss              { Load address of parameter buffer (ParBuf) }
 mov es,ax
 mov ds,ax
 lea di,ParBuf          { Still loading... }
 mov bx,di              { Save offset of parameter buffer in BX }
 mov ax,word ptr [SecNo] { Get number of sector to read (lo 16-bit part) }
 stosw {Lo SecNr}       { Store in our buffer }
 mov ax,word ptr [SecNo+2] { Get number of sector to read (hi 16-bit part) }
 stosw {Hi SecNr}       { Store in buffer }
 mov ax,1               { Sectors to read }
 stosw                  { Store in buffer }
 mov ax,word ptr [Buf]  { Get offset of buffer (Buf) }
 stosw {Offset Buffer}  { Store in buffer }
 mov ax,word ptr [Buf+2] { Get segment of buffer (Buf) }
 stosw {Segment Buffer} { Store in buffer }
 mov cx,-1              { Indicate use of 32-bit calling }
@DosRead:               { Actual interrupt calling starts }
 pop ax                 { Get drive number from stack }
 push bp                { Save BP (must be preserved in TP/BP) }
 int 25h                { DOS function: read sector(s) }
 mov al,1               { Assume success (TRUE, ordinal 1) }
 sbb al,0               { Subtract one if carry flag high (set on error by
                        { DOS) }
 popf                   { Get flags back DOS had forgotten to do }
 pop bp                 { Get BP back }
 pop ds                 { Get DS back }
 mov LastError,ax       { Save the errorcode in global var for errorreporting }
end;                    { Return to caller, al contains return code }
                        { (0=FALSE, 1=TRUE) }

function WriteSec(SecNo:longint; var Buf):boolean; assembler;
{ Same as above, but WRITES a sector with contents of Buf }
{ USE WITH CAUNTION! YOU CAN DESTROY IMPORTANT DATA WITH THIS! }
{ (not commented, is exactly the same as ReadSec, only uses INT 26h } { instead
of INT 25h) }var
 ParBuf:array[0..9] of byte;
asm
 mov ax,word ptr [SecNo]
 mov word ptr [LastSecNo],ax
 mov ax,word ptr [SecNo+2]
 mov word ptr [LastSecNo+2],ax
 push ds
 mov al,Drive
 push ax
 cmp BigPart,0
 jne @DoBig
 lds bx,Buf
 mov cx,1
 mov dx,word ptr [SecNo]
 jmp @DosRead
@DoBig:
 cld
 mov ax,ss
 mov es,ax
 mov ds,ax
 lea di,ParBuf
 mov bx,di
 mov ax,word ptr [SecNo]
 stosw {Lo SecNr}
 mov ax,word ptr [SecNo+2]
 stosw {Hi SecNr}
 mov ax,1
 stosw {Aantal Sectors}
 mov ax,word ptr [Buf]
 stosw {Offset Buffer}
 mov ax,word ptr [Buf+2]
 stosw {Segment Buffer}
 mov cx,-1
@DosRead:
 pop ax
 push bp
 int 26h
 mov al,1
 sbb al,0
 popf
 pop bp
 pop ds
 mov LastError,ax
end;

procedure DiskRError;
begin
 WriteLn('Error reading disk! Sector:',LastSecNo,' Errorcode:',LastError);
 Halt(1);
end;

var
 Bpb:BpbRec; { Global copy of Bios Parameter block, for ClusToSec }

function ClusToSec(C:word):longint;
{ Convert clusternumber to sector number, because the cluster is often bigger }
{ than one sector, you need to read multiple succeeding sectors to read the }
{ whole cluster (number of sectors in a cluster is in BPB (BPB.SecPClus)) }
{ Uses global BpbRec Bpb and global longint DATASec }
begin
 ClusToSec:=((C-2)*Bpb.SecPClus)+DATASec;
end;


const
 SizeBpb=SizeOf(BpbRec);
 { Needed for assembly part, AFAIK you can't get the size of a structure }
 { (record) in an asm..end; block (shame on you, Borland (or on me :-) )) }
var
 Buf:pointer;
 S:string[1]; { To store driveletter }
 I:byte;
begin
 I:=0;
 asm
  mov ax,3000h   { Get DOS version }
  int 21h
  cmp al,3
  jb @BadDos
  ja @DosOk
  cmp ah,20
  jae @DosOk
 @BadDos:        { Lower than 3.2? }
  mov I,1        { Set flag }
 @DosOk:
 end;
 if I=1 then
  begin WriteLn('Sorry, need DOS version 3.2 or higher!'); Halt(1); end;
 if ParamCount=0 then
  begin
   WriteLn(ParamStr(0),' <driveletter>');
   Halt(1);
  end;
 S:=ParamStr(1);
 case UpCase(S[1]) of
  'A'..'Z':;
 else
  begin
   WriteLn('Bad drive!');
   Halt(1);
  end;
 end;
 Drive:=Ord(UpCase(S[1]))-65;
 GetMem(Buf,512);
 asm
  push ds                   { Copy DS }
  pop es                    { to ES }
  push ds                   { Save DS }
  mov ax,440dh              { DOS function 44h (IOCTL), subfunction 0Dh }
                            { (blockdriver control) }
  mov bl,Drive              { Driveno. }
  inc bl                    { Incrase by 1 (0=default, 1=A:) }
  mov cx,860h               { subsubfunction 860h (get information) }
  lds dx,Buf                { Load address of buffer where to store result }
  int 21h                   { Call DOS subfunction }
  mov al,1                  { Assume error }
  jc @EndR                  { Got error? Yes -> goto @EndR }
  mov si,dx                 { Set SI on offset parameterblock }
  mov al,2                  { Assume floppy }
  cmp byte ptr [si+1],5     { Is it a harddisk? }
  jne @EndR                 { No -> goto @EndR }
  mov cx,SizeBpb            { Get size of BPB record }
  add si,7                  { Starts at offset 7 in DOS parameter block }
  lea di,Bpb                { Get address of our global BPB block }
  cld                       { Store forwards }
  rep movsb                 { Copy BPB from DOS to ours }
  xor al,al                 { No errors }
 @EndR:                     { AL contains errorcode: 0=no err., 1=DOS err, }
                            { 2=it's a floppy (need something special) }
  pop ds                    { Restore DS }
  mov I,al                  { Save result }
 end;
 case I of
  0:BigPart:=Bpb.TotalSec=0; { It's a harddisk, 16-bit field is 0 for 32-bit }
                             { access }   1:                         { Error
from DOS, report }   begin
    WriteLn('Can''t get parameter block for drive ',chr(Drive+65),'!');
    Halt(1);
   end;
  2:                         { It's a floppy. DOS' bpb is only right }
                             { for the largest disk size, so we need to read }
                             { it ourself }
   begin
    BigPart:=false;          { No 32-bit sectors on floppies }
    if not ReadSec(0,Buf^) then  { Read bootsector (sector 0) }
     DiskRError;                     { Show error if we got one }
    Bpb:=BootSecP(Buf)^.Bpb;       { Copy BPB }
   end;
 end;
 with Bpb do  {Store some handy information for accessing the disk ourself }
  begin
   FATSec:=ResSec;                     { Starting FAT sector }
   ROOTSec:=FATSec+(NrFATs*SecPFAT);   { Starting ROOT directory sector }
   DATASec:=ROOTSec+(NrROOT shr 4);    { Starting DATA sector }
   if not BigPart then                 { Is it a 12-bit FAT? }
    FAT12:=((TotalSec-DATASec) div SecPClus)<4087 { Yes if less than 4087 sec}
   else
    FAT12:=false;                      { Not with 32-bit sectors }
  end;
 FreeMem(Buf,512);
 { do what you want }
end.
