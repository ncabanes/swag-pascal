(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0103.PAS
  Description: DOS Environment handling
  Author: ROBERT B. CLARK
  Date: 05-31-96  09:16
*)

{ ENVIRON.PAS                                            Revision 1.00 }
{ Written 4 Nov 1994 by Robert B. Clark <rclark@iquest.net>            }
{ ──────────────────────────────────────────────────────────────────── }
{ A collection of DOS environment routines for Turbo Pascal v4.0.      }
{ Requires DOS v3.0+.  Tested on 486/P5 MS-DOS 5/6.22/NW 3.11          }
{                                                                      }
{ Donated to the public domain 17 Jan 96 by Robert B. Clark.           }
{ May be included in SWAG if so desired.                               }
{                                                                      }
{ WARNING:  High-ASCII line-drawing characters are used in the Shell() }
{           function near the end of this listing. Use the appropriate }
{           emulation for your printer if you print this code.         }
{                                                                      }
{ Last updated: 04 Apr 95                                              }
{ ──────────────────────────────────────────────────────────────────── }

UNIT Environ;  { SEE DEMO AT THE BOTTOM ! }
{$B+ Boolean short-circuit
  D- No debug information
  S- No stack overflow checking
  R- Range checking off
  V- VAR string length checking off
  I- I/O checking off }

INTERFACE

Uses Dos
{$IFDEF UseLib} ,Files    { For FNStrip(), MAXPATHLEN and fileSpecType }
{$ENDIF}        ;

{ ──────────────────────Start personal lib interface────────────────── }
{$IFNDEF UseLib   Definitions from my FILES.TPU unit }

CONST MAXPATHLEN   = 64;
TYPE  fileSpecType = string[MAXPATHLEN];

{$ENDIF}
{ ──────────────────────End personal lib functions──────────────────── }

CONST MAX_EVAR_LEN  = 127;      { Maximum environment variable length }
      MAX_EVAR_BLEN = 32768;    { Maximum size of environment block }

TYPE evarType    = string[MAX_EVAR_LEN];
     envSizeType = 0..32768;
     MCBType     = record
         BlockID   : byte;
         OwnerPSP  : word;
         ParentPSP : word;
         BlockSize : longint;
         OwnerName : string[8];
         MCB_Seg   : word;
         MCB_Ofs   : word
     end;

VAR   MASTER_MCB      : MCBType;
      MASTER_ENVSEG,
      CURRENT_ENVSEG  : word;
      COMSPEC         : evarType;      { Value of COMSPEC evar }
      PROGRAMNAME     : fileSpecType;  { Name of executing program }
{ ──────────────────────────────────────────────────────────────────── }

FUNCTION  EnvSize(envSeg: word): envSizeType;
FUNCTION  MaxEnvSize(envSeg: word): envSizeType;
FUNCTION  GetEnv(evar:evarType; envSeg: word): evarType;
PROCEDURE DelEnv(evar:evarType; envSeg: word);
FUNCTION  GetFirstMCB: word;
PROCEDURE InitMCBType(var mcb: MCBType);
PROCEDURE ReadMCB(var mcb: MCBType; var last, root: boolean);
PROCEDURE FindRootEnv(var mcb: MCBType);
FUNCTION  PutEnv(evar,value: evarType; envSeg: word): boolean;
PROCEDURE AllocateBlock(var blockSize: longint; var segment: word);
FUNCTION  DeallocateBlock(segment: word): boolean;
FUNCTION  Shell(prompt: evarType): integer;

{$IFNDEF UseLib   Normally in Files.TPU }
FUNCTION FNStrip(s: fileSpecType; specifier: byte): fileSpecType;
{$ENDIF}
{ ──────────────────────────────────────────────────────────────────── }

IMPLEMENTATION

{ ──────────────────────Start personal lib implementation───────────── }
{$IFNDEF UseLib   Functions from my FILES.TPU unit }

FUNCTION FNStrip(s: fileSpecType; specifier: byte): fileSpecType;
{ Extracts (strips) specific portions of a fully-qualified filename.
  The specifier is the sum of the desired portions:

                       Bit
                     76543210               Dec
                     .......x  Extension     1
                     ......x.  Basename      2
                     .....x..  Path          4
                     ....x...  Disk letter   8

  A specifier of 0 is same as a specifier of 15 (all parts returned). }

var j,len,lastSlash, lastDot: integer;
    disk: string[2];
    path,temp: fileSpecType;
    baseName: string[8];
    ext: string[4];

begin
   disk:=''; path:=''; baseName:='';
   ext:=''; temp:='';
   specifier:=specifier and $0f;       { Strip high bits }
   {TrueName(s);}                      { Canonize filespec }
   len:=Length(s);
   if (specifier=0) or (specifier=15) then   { Return full name }
   begin
      FNStrip:=s;
      exit
   end;

   lastSlash:=0; lastDot:=0; j:=len;
   while (lastSlash=0) and (j>0) do  { Get lastSlash & lastDot indices }
   begin
      if s[j]='\' then lastSlash:=j;
      if (lastDot=0) and (s[j]='.') then lastDot:=j;
      dec(j)
   end;

   if (len>0) and (s[2] in [':','\']) then disk:=s[1]+s[2];
   if (lastSlash>0) then
   begin
      if (disk<>'') then j:=3 else j:=1;
      path:=Copy(s,j,lastSlash-j+1)
   end;
   if (lastDot > lastSlash) then j:=lastDot-1 else j:=len;
   baseName:=Copy(s,lastSlash+1,j-lastSlash);
   if (lastDot>0) then ext:=Copy(s,lastDot,len-lastDot+1);

   if (specifier and 8) >0 then temp:=temp+disk;
   if (specifier and 4) >0 then temp:=temp+path;
   if (specifier and 2) >0 then temp:=temp+baseName;
   if (specifier and 1) >0 then temp:=temp+ext;

   FNStrip:=temp
end; {FNStrip}

{$ENDIF}
{ ──────────────────────End personal lib implementation─────────────── }

FUNCTION EnvSize(envSeg: word): envSizeType;
{ Returns current size of environment segment 'envSeg' NOT INCL 2nd 00.}
var i: envSizeType;
begin
   i:=0;
   while (Mem[envSeg:i] <> 0) or (Mem[envSeg:i+1] <> 0) and
      (i<MAX_EVAR_BLEN) do Inc(i);
   EnvSize:=i+1
end; {EnvSize}


FUNCTION MaxEnvSize(envSeg: word): envSizeType;
{ Returns maximum size of environment segment 'envSeg' by reading the
  word at offset 03 in its preceding MCB paragraph. }
begin
   MaxEnvSize:=MemW[envSeg-1:$003]*16  { size in bytes }
end; {MaxEnvSize}


type pType=^char;

procedure IncPtr(var p: pType);         { Increment evar char pointer }
begin
   p:=Ptr(seg(p^),ofs(p^)+1)
end;


function MatchEvar(evar: evarType; var p: pType): boolean;
{ Returns true if "evar" matches environment string data exactly (case-
  sensitive). If found, p points to the '=' char after the evar name. }
var i: integer;

begin
   for i:=1 to length(evar) do
   begin
      if p^ <> evar[i] then    { Mismatch; exit and return false }
      begin
         MatchEvar:=false;
         exit
      end;
      IncPtr(p)               { OK so far; increment pointer }
   end;
   MatchEvar:=p^='='          { True if p points to '=' }
end; {MatchEvar}


FUNCTION GetEnv(evar:evarType; envSeg: word): evarType;
{ Returns value of environment string 'evar' in the 'envSeg' segment.
  If 'evar' does not exist, returns an empty string. Note that the match
  is case-sensitive in order to accomodate the infamous "windir"
  environment string. }

var done : boolean;
    p    : pType;
    i    : integer;
    s    : evarType;

begin {GetEnv}
   p:=ptr(envSeg,0);                    { Point to start of evar block }
   i:=0; done:=false; s[0]:=#0;

   while (p^ <> chr(0)) and not done do   { while not EOBlock }
   begin
      if MatchEvar(evar,p) then
      begin
         IncPtr(p);                          { Skip past '=' char }
         while (p^ <> chr(0)) and (i<MAX_EVAR_LEN) do
         begin                               { Read chars into s until }
            Inc(i);                          { end of ASCIIZ string }
            s[i]:=p^;
            IncPtr(p)
         end;
         s[0]:=chr(i);              { Store string length byte }
         done:=true                 { Exit condition--we're done! }
      end else
      begin
         while (p^ <> chr(0)) do    { No match; skip to end of ASCIIZ }
            IncPtr(p);
         IncPtr(p)                  { Advance pointer to next string }
      end;
   end; {while}
   GetEnv := s
end; {GetEnv}


PROCEDURE DelEnv(evar:evarType; envSeg: word);
{ Removes environment variable 'evar' from environment table at
 'envSeg'. }

var found     : boolean;
    p         : pType;
    i         : integer;
    s         : evarType;
    b0,b1,len : word;

begin {DelEnv}
   p:=ptr(envSeg,0);                    { Point to start of evar table }
   i:=0; found:=false; s[0]:=#0;

   while (p^ <> chr(0)) and not found do
   begin
      if MatchEvar(evar,p) then
      begin
         b1:=ofs(p^)-length(evar);  { First byte of evar (dest)}
         while(p^ <> chr(0)) do
            IncPtr(p);
         IncPtr(p);
         b0:=ofs(p^);               { Next evar (start) }
         len:=EnvSize(envSeg)-b0+1; { Length of region }
         if (len>0) then begin
            Move(Mem[envSeg:b0],Mem[envSeg:b1],len)
         end
         else begin
            FillChar(Mem[envSeg:b1],2,0)
         end;
         found:=true
      end else
      begin
         while (p^ <> chr(0)) do    { No match; skip to end of ASCIIZ }
            IncPtr(p);
         IncPtr(p)                  { Advance pointer to next string }
      end;
   end; {while}
end; {DelEnv}


FUNCTION GetFirstMCB: word;
{ Get segment address of first MCB using the undocumented DOS
  Interrupt 21/52 Get List of Lists. }
var r: Registers;
begin
   r.AH:=$52;
   MsDos(r);   { Get List of Lists in ES:BX; 1st MCB seg is at [BX-2] }
   GetFirstMCB:=MemW[r.ES:r.BX-2]
end; {GetFirstMCB}


PROCEDURE InitMCBType(var mcb: MCBType);
{ Resets MCB record data to zero; segment to that of the first MCB }
begin
   with mcb do begin
      MCB_Seg := GetFirstMCB;
      MCB_Ofs := 0;
      BlockID := 0;
      OwnerPSP:= 0;
      ParentPSP:=0;
      BlockSize:=0;
      OwnerName[0]:=chr(0)
   end;
end; {InitMCBType}


PROCEDURE ReadMCB(var mcb: MCBType; var last, root: boolean);
{ Collects info about the MCB pointed to by mcb_seg:mcb_ofs.
  'last' will be true if this is the last MCB in the chain;
  'root' will be true if this MCB's owner is the same as the PSP owner.}

var p : ^MCBType;
    i : integer;

begin {ReadMCB}
   p:=Ptr(seg(mcb),ofs(mcb));
   with mcb do
   begin
      blockID  := Mem[MCB_Seg:MCB_Ofs];     { Block type = 'M' or 'Z' }
      p^.ownerPSP:=MemW[MCB_Seg:MCB_Ofs+1]; { PSP segment of MCB owner }
      parentPSP:= MemW[ownerPSP:$0016];     { Parent/self PSP segment }
      blockSize:= MemW[MCB_Seg:MCB_Ofs+3];  { Size of MCB in paragraphs}

      for i:=$08 to $0f do ownerName[i-7]:=Chr(Mem[MCB_Seg:MCB_Ofs+i]);
      ownerName[0]:=chr(8);            { DOS v4.0+ }

      last := blockID <> $4D;          { True if this is the last MCB }
      root := (parentPSP = ownerPSP)   { True if this is the root MCB }
   end; {with}
end; {ReadMCB}


PROCEDURE FindRootEnv(var mcb: MCBType);
{ Walks the MCB chain until root environment is found (MCB owner =
  parent_id). Returns the segment of that process' environment in the
  MCB record. }

var last,root : boolean;
    offset    : longint;
    block     : integer;
begin
   InitMCBType(mcb);
   block:=0;
   repeat
      ReadMCB(mcb,last,root);
      Inc(block);
      if not root then
      begin
        offset := mcb.MCB_Ofs+16+(mcb.BlockSize*16);
        mcb.MCB_Ofs := offset mod $10000;
        mcb.MCB_Seg := mcb.MCB_Seg + (offset div $10000)
     end;
   until root or (block>100)  { Til root found or 100 blocks examined }
end; {FindRootEnv}


FUNCTION PutEnv(evar,value: evarType; envSeg: word): boolean;
{ Put environment variable 'evar' into environment segment 'envSeg'
  and give it the value 'value'. If 'value' is null, effect is same as
  if DelEnv() was called. Returns true if successful. }

var len, origLen, i     : integer;
    maxSize, currentSize: envSizeType;
    s: evarType;
begin
   s:=evar+'='+value+chr(0)+chr(0);   { Make evar string }
   len:=length(s);                    { Length includes terminal 0000 }
   origLen:=length(GetEnv(evar,envSeg))+length(evar)+2;
   currentSize:=EnvSize(envSeg);
   maxSize:=MaxEnvSize(envSeg);

   if (currentSize-origLen+len > maxSize) then
   begin
      PutEnv:=false;                { Insufficient space }
      exit
   end;

   DelEnv(evar,envSeg);             { Delete evar if exists }
   if value[0]=chr(0) then begin    { Empty evar value string }
      PutEnv:=true;                 { Same as calling DelEnv() }
      exit
   end;
   currentSize:=EnvSize(envSeg);

   for i:=1 to length(s) do      { Write string to environment }
      Mem[envSeg:currentSize-1+i] :=ord(s[i]);
   PutEnv:=true
end; {PutEnv}


function GetProgramName: fileSpecType;
{ Returns fully-qualified filespec of the currently-executing program.
  This function should be called before any PutEnv() operations.
  Req. DOS v3.0+ }

var envSeg: word;
    p: ^char;
    i: integer;
    s: string;
begin
   envSeg:=MemW[PrefixSeg:$002C];    { PSP:002C == environment segment }
   p:=Ptr(envSeg,EnvSize(envSeg)+3); { Points to 1st char of filename }
   i:=0;                             
   while (p^ <> chr(0)) and (i<MAXPATHLEN) do   { Read filename chars }
   begin
      Inc(i);
      s[i]:=p^;
      p:=Ptr(seg(p^),ofs(p^)+1)
   end;
   s[0]:=chr(i);
   GetProgramName:=s
end; {GetProgramName}


PROCEDURE AllocateBlock(var blockSize: longint;
                       var segment: word);
{ Allocates 'blockSize' bytes (rounded up to nearest paragraph) of
  memory. If there is insufficient free memory available, ALL free
  memory will be appropriated. The returned value 'segment' will be the
  initial segment of the allocated block. }

var regs: Registers;
    para: longint;

begin
   para := blockSize div 16;     { Requested paragraphs of memory }
   if (blockSize mod 16) > 0 then para:=para+1;
   with regs do
   begin
      AH := $48;    { Int 21/48 - Allocate Memory  }
      BX := para;   { Returns NC if ok, AX=segment; otherwise CY }
      MsDos(regs);  { If CY, AX=7 MCB destroyed, 8=insuff memory }
      para:=BX;     { BX=largest available block }
      blockSize:=para*16;   { Return adjusted block size in bytes }
      if Flags and FCarry <> 0 then  { Allocation error }
         AllocateBlock(blockSize,segment)
      else
      begin
         segment:=AX    { Segment of allocated memory block }
      end;
   end;
end; {AllocateBlock}


FUNCTION DeallocateBlock(segment: word): boolean;
{ Releases a block of memory reserved by Int 21/48 to the DOS pool.
  Returns true if no error. }

var regs: Registers;

begin
   with regs do
   begin
      AH := $49;      { Int 21/49 - Release Memory  }
      ES := segment;  { Returns NC if ok, otherwise CY set and   }
      MsDos(regs);    { AX=7 MCB destroyed, 9=invalid MCB address }
   end;
   DeallocateBlock:=not (regs.Flags and FCarry <> 0);
end; {DeallocateBlock}


FUNCTION Shell(prompt: evarType): integer;
{ Invokes an OS command shell with custom prompt string.  In order to
  make enough room for a custom prompt evar, a new environment block for
  this process is created, assigned to the current PSP, and is then
  inherited by the child COMSPEC process.  If the prompt is null, the
  default prompt "[progname] $p$g" will be used.

  Returns the DOS error code from the Exec function:

              0 = No error
              2 = File not found
              3 = Path not found
              5 = Access denied
              6 = Invalid handle
              8 = Not enough memory
             10 = Invalid environment
             11 = Invalid format
             18 = No more files
}
var ShellEnvSeg        : word;
    len                : envSizeType;
    bytesRequested     : longint;
    rcode              : integer;

begin
   if prompt='' then
      prompt:='['+FNStrip(PROGRAMNAME,2)+'] ' +
         GetEnv('PROMPT',CURRENT_ENVSEG);
   ShellEnvSeg:=0;
   if COMSPEC<>'' then
   begin
      len := EnvSize(CURRENT_ENVSEG)+1;
      bytesRequested := len + Length(prompt)+8;
      AllocateBlock(bytesRequested,ShellEnvSeg);
      Move(Mem[CURRENT_ENVSEG:0], Mem[ShellEnvSeg:0], len);
      MemW[PrefixSeg:$002c] := ShellEnvSeg;
      if not PutEnv('PROMPT',prompt,ShellEnvSeg) then
         writeln(#10#13#7'*** Insufficient environment space ',
            'for custom prompt!');

      writeln;
               {  Yes, this is ugly.  Sorry. :-) }
writeln(
'╔══╡ DOS Shell ╞═════════════════════════════════════════════════════╗');
writeln(
'║                                                                    ║');
writeln(
'║    You are in a temporary DOS Shell.  Do not load any resident     ║');
writeln(
'║   programs (such as PRINT or DOSKEY) while you are in this shell.  ║');
writeln(
'║                                                                    ║');
writeln(
'║       When done, type EXIT┘ to return to your application.        ║');
writeln(
'║                                                                    ║');
writeln(
'╚════════════════════════════════════════════════════════════════════╝');

      Exec(COMSPEC,''); rcode:=DosError;       { Needs 64k to load }
      MemW[PrefixSeg:$002C]:=CURRENT_ENVSEG;   { Restore original env }

      if not DeAllocateBlock(ShellEnvSeg) then
      begin
         writeln(#7'*** Memory deallocation problem. Aborting....');
         halt(7)
      end;
   end {if comspec}
   else rcode:=-1;
   Shell:=rcode
end; {Shell}
{ ───────────────────────────────────────────────────────────────────── }
{
   Initialize public variables:

      MASTER_MCB        Root memory control block record
      MASTER_ENVSEG     Segment of master environment block
      CURRENT_ENVSEG    Segment of current process' environment block
      COMSPEC           String set to value of "COMSPEC" evar.
      PROGRAMNAME       Fully-qualified name of executing program.
}
BEGIN
   FindRootEnv(MASTER_MCB);
   MASTER_ENVSEG := MemW[MASTER_MCB.OwnerPSP:$002c];
   CURRENT_ENVSEG := MemW[PrefixSeg:$002C];
   COMSPEC:=GetEnv('COMSPEC',MASTER_ENVSEG);
   PROGRAMNAME := GetProgramName
END. {unit}

{ -------------------------  DEMO ---------------------- }

(***********************************************************************
   Walk Memory Control Block chain                Version 1.00

   Demonstration of Environ.TPU (and other stuff too, I guess).
   Written Jan 17 1996 Robert B. Clark <rclark@iquest.net>

   Donated to the public domain; inclusion in SWAG freely permitted.

   Usage: WALKMCB [evar] [new_value]
   =================================
   If 'evar' is not specified, WALKMCB simply demonstrates how to walk
   the MCB chain.

   If 'evar' _is_ specified, WALKMCB displays the master environment
   value of 'evar' and sets the current value of 'evar' to 'new_value.'
   It then demonstrates the shell to DOS function Shell() so that you
   may verify the changed environment variable by typing SET at the
   shelled command line.

   Note that the 'evar' argument IS case-sensitive, to accomodate the
   infamous "windir" evar Microsoft foisted upon us.
   ********************************************************************)

Program WalkMCB;

{$M 8096,0,1024}          { Stack, min heap, max heap}
{$DEFINE DispMCB}         { Display MCBs while walking }

Uses Dos, Environ         { FOUND IN DOS.SWG ! }
{$IFDEF UseLib}   ,Convert,Global   { Hex conversions, various }
{$ELSE}           ,Crt
{$ENDIF}          ;

CONST  CREDIT      = ' v1.00 Written Jan 17 1996 Robert B. Clark';
(**********************************************************************)
{$IFNDEF UseLib}     { Selected functions from personal units }

(* KeyBd.TPU *)

PROCEDURE ClearKeybd;
inline($FA/             { cli               ; Disable interrupts     }
       $33/$C0/         { xor ax,ax         ; Head/tail keybuf ptrs  }
       $8E/$C0/         { mov es,ax         ; at 40:001A and 40:001C }
       $26/$A0/$1A/$04/ { es mov al,b[041a] ; Head ptr in AL         }
       $26/$A2/$1C/$04/ { es mov b[041c],al ; Now tail=head          }
       $FB);            { sti               ; Reenable interrupts    }
{ClearKeybd}

(* Convert.TPU *)

FUNCTION HexByte(b:byte):string;
{ Converts decimal to hexadecimal byte string }
const hexDigits: array [0..15] of char = '0123456789ABCDEF';
begin
  HexByte:=hexDigits[b shr 4] + hexDigits[b and $F]
end; {HexByte}


FUNCTION HexWord(w:word): string;
{ Converts decimal to hexadecimal word string }
begin
  HexWord:=HexByte(hi(w)) + HexByte(lo(w))
end; {HexWord}


FUNCTION HexDWord(w:longint): string;
{ Converts decimal to hexadecimal doubleword string. }
begin
  if (w<0) then w:=w-$10000;
  HexDWord:=HexWord(w div 65536)  + HexWord(w mod 65536)
end; {HexDWord}

(* Global.TPU *)

PROCEDURE SetRedirect(var infile,outfile: string);
{ Sets Input/Output to DOS STDIN/OUT routines. }
begin
   Assign(Output,outFile);        { Set up for STDOUT output }
   Rewrite(Output);
   Assign(Input,inFile);          { Set up for STDIN input }
   Reset(Input)
end; {SetRedirect}


FUNCTION CurSize:word;
{ Returns current size of cursor. The high byte is the beginning scan
  line; the low byte is the ending scan line. }
var regs: Registers;

begin
   with regs do           { Get current cursor size }
   begin
      AH:=$03;            { Want BIOS Int 10h/3, Read Cursor Pos/Size }
      BH:=$00;            { Video page number }
      Intr($10,regs);     { BH=page #, CX=beg/end scan line, DX=row/col}
      CurSize:=CX
   end;
end; {CurSize}


PROCEDURE Cursor_OnOff(on:boolean);
{ Toggles the cursor on and off. }
var regs: Registers;
    sbeg:byte;

begin
  sbeg:=hi(CurSize);                 { Get starting scan row }
  if (on) then sbeg:=sbeg and $df    { Toggle bit 5 }
  else sbeg:=sbeg or $20;

  with regs do
  begin
    AH:=$01;                  { Want BIOS Int 10h/1 Set cursor size }
    CH:=sbeg;                 { Beginning cursor scan line }
    CL:=lo(CurSize);          { Ending cursor scan line }
    Intr($10,regs)
  end;
end; {Cursor_OnOff}


PROCEDURE Pause;
{ Simply waits for the user to press [Enter] while displaying a
  spinning cursor. Invalid keypresses cause a tone to sound.
  The keyboard buffer is cleared upon entry and exit. }

   procedure Tone(hz,duration:word);
   { Produces tone at 'hz' frequency and of 'duration' ms }
   begin
      Sound(hz); Delay(duration); NoSound
   end; {Tone}

const cursor: array[0..6] of char = '-\|/-\|';
var   okChar: boolean;
           c: char;
       i,x,y: shortint;

begin
   Cursor_OnOff(false);
   write(#10#13'Press Enter'#17#217' to continue... ');
   x:=WhereX; y:=WhereY;
   ClearKeybd; okChar:=false;
   repeat
      inc(i); i:=i mod 7;
      write(cursor[i]); gotoxy(x,y);
      Delay(55);
      if KeyPressed then
      begin
         c:=ReadKey; if c=#0 then c:=ReadKey;  { Toss extended byte }
         if c=chr(13) then okChar:=true
         else Tone(2000,100)
      end;
   until okChar;
   gotoxy(1,y); ClrEol; gotoXY(1,y);
   ClearKeybd; Cursor_OnOff(true);
end; {Pause}

{$ENDIF}  (* End of unit functions from personal libs *)

(* ******************************************************************* *)
procedure DisplayMCB(mcb: MCBType; block_num: integer);
begin
   with mcb do
   begin
      writeln('MCB Block #',block_num:3,': Address ',HexWord(MCB_Seg),
         ':', HexWord(MCB_Ofs), '   Absolute: ',
         HexDWord(MCB_Seg*16+MCB_Ofs));
      write('   Block Type    : ',HexByte(blockID),'   (');
      if (blockID<>$4D) and (blockID<>$5A) then
         writeln('ERROR)')
      else
         writeln(chr(blockID),')');
      write('   PSP of Owner  : ',HexWord(ownerPSP));
      if ownerPSP=0 then      write(' (free)')
      else if ownerPSP=8 then write(' (DOS) ')
      else write('       ');
      writeln(' Owner: ',ownerName);   { Garbage if DOS <4.0 }
      writeln('   PSP PARENT_ID : ',HexWord(parentPSP));
      writeln('   ENVSEG        : ',HexWord(MemW[ownerPSP:$002c]));
      writeln('   Size of MCB   : ',HexWord(blockSize),' paragraphs (',
         blockSize*16,' bytes).');
      writeln
   end;
end; {DisplayMCB}


procedure WalkChain(var mcb: MCBType);
{ Walks the MCB chain until block type is no longer 4D (M).}
var last,root : boolean;
    offset    : longint;
    block     : integer;
begin
   InitMCBType(mcb);
   block:=0;
   repeat
      ReadMCB(mcb,last,root);
      Inc(block);
{$IFDEF DispMCB}
      DisplayMCB(mcb,block);
{$ENDIF}
      if not last then
      begin
         offset := mcb.MCB_Ofs+16+(mcb.BlockSize*16);
         mcb.MCB_Ofs := offset mod $10000;
         mcb.MCB_Seg := mcb.MCB_Seg + (offset div $10000)
      end;
   until last
end; {WalkChain}


procedure Header(walk:boolean);
begin
   writeln;
   if walk then
   begin
      writeln('WALK MEMORY CONTROL BLOCK CHAIN');
      writeln('===============================')
   end
   else begin
      writeln('ENVIRONMENT MANIPULATION AND THE DOS SHELL');
      writeln('===========================================')
   end;

   writeln('Current PSP (PrefixSeg) is ',HexWord(PrefixSeg));
   writeln('The parent PSP segment  is ',HexWord(MemW[prefixSeg:$0016]));
   writeln('The environment segment is ',HexWord(CURRENT_ENVSEG));
   writeln;
end; {Header}


procedure GetParms(var p1,p2: evarType);
{ Get command line parameters 1 and 2 }
var i:integer;
begin
   p1:=''; p2:='';
   p1:=ParamStr(1);
   i:=2;
   while ParamStr(i) <> '' do    { Param 2 is concatenated p2, p3, ... }
   begin
      p2:=p2 + ParamStr(i);
      if ParamStr(i+1) <> '' then p2:=p2+' ';
      Inc(i)
   end;
end;
(**************************************************************************)
var
    mcb : MCBType;
    walk: boolean;
    x   : integer;
    evar,value: evarType;
    prompt: evarType;
    infile,outfile: string;

begin {main}
   infile:=''; outfile:='';
   SetRedirect(infile,outfile);  { Use STDIN/OUT }
   GetParms(evar,value);
   prompt:='$e[1m['+FNStrip(PROGRAMNAME,2)+'] $e[0m$p$g';
   walk:=evar='';
   Header(walk);

   if walk then
   begin
      WalkChain(mcb);
      writeln('The last MCB in the chain is at ',
         HexWord(mcb.MCB_Seg),':', HexWord(mcb.MCB_Ofs),'.');
   end
   else begin
      writeln('The master (root) Memory Control Block is at ',
         HexWord(MASTER_MCB.MCB_Seg),':',
         HexWord(MASTER_MCB.MCB_Ofs),'.');
      writeln('The root environment is at ',HexWord(MASTER_ENVSEG),
         ':0000 and its maximum size is ',MaxEnvSize(MASTER_ENVSEG),
         ' bytes.');
      writeln('The master environment size is ',
         EnvSize(MASTER_ENVSEG),' bytes.');
      writeln('Current environment (',HexWord(CURRENT_ENVSEG),
         ') size is ',EnvSize(CURRENT_ENVSEG),' bytes.');

      writeln('Master  : ',evar,'="', GetEnv(evar,MASTER_ENVSEG),'"');
      writeln('Current : ',evar,'="', GetEnv(evar,CURRENT_ENVSEG),'"');
      if not PutEnv(evar,value,CURRENT_ENVSEG) then
         writeln(#10#13#7'*** Insufficient environment space!');
      writeln('After   : ',evar,'="', GetEnv(evar,CURRENT_ENVSEG),'"');

      Pause;
      x:=Shell(''); {prompt);}   { Try both }
      writeln; writeln('Shell() returned DOS code ',x)
   end;
   writeln(FNStrip(PROGRAMNAME,2),CREDIT)
end.

