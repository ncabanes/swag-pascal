(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0057.PAS
  Description: Lim EMS Library
  Author: ANDREW EIGUS
  Date: 08-24-94  13:34
*)

{This unit is a kit to EMS functions.}

Unit EMSLib;
{ Copyright (c) 1994 by Andrew Eigus            FidoNet: 2:5100/33 }
{ LIM EMS Interface V1.01 for Turbo Pascal version 7.0 }

(*
  Material used:
    Interrupt List V1.02 (WindowBook) (c) 1984-90 Box Company, Inc.
    Tech Help V4.50
*)

{$X+} { Enable extended syntax }
{$G+} { Enable 286 instructions }

interface

const

  PageSize = 16384;  { EMS Page size: 16384 bytes }

  { LIM EMS 3+ function numbers }

  EGetPageFrame  = $41;
  EGetPageCount  = $42;
  EAllocPages    = $43;
  EMapPages      = $44;
  EReleasePages  = $45;
  EGetVersion    = $46;

  { LIM EMS functions result codes }

  emsrOk            = $00; { Function successful }
  emsrNotInitd      = $01; { EMS not installed }
  emsrIntrnlError   = $80; { Internal error }
  emsrHardwareMalf  = $81; { Hardware malfunction }
  emsrBadHandle     = $83; { Invalid handle }
  emsrBadFunction   = $84; { Undefined function requested }
  emsrNoMoreHandles = $85; { No more handles available }
  emsrMapContError  = $86; { Error in save or restore of mapping context }
  emsrMorePagesPhys = $87; { More pages requested than physically exist }
  emsrMorePagesCurr = $88; { More pages requested than currently available }
  emsrZeroPages     = $89; { Zero pages requested }
  emsrBadPageLogNum = $8A; { Invalid page logical number }
  emsrBadPagePhyNum = $8B; { Invalid page physical number }

function EMS_Setup : boolean;
function EMS_GetVersion(var Version : byte) : byte;
function EMS_GetMemAvail(var FreeMem : word) : byte;
function EMS_AllocEMB(var Handle, PageSeg : word; Pages : word) : byte;
function EMS_FreeEMB(Handle : word) : byte;
function EMS_MapPages(Handle, LogicalPage : word; PhysicalPage : byte) : byte;

function EMS_GetErrorMsg(ErrorCode : byte) : string;

implementation

const
  DOS = $21; { DOS interrupt number }
  EMS = $67; { EMS interrupt number }

var
  EMSInitd : boolean;

Function EMS_Setup; assembler;
{ EMM Installation check }
const DeviceDriver : PChar = 'EMMXXXX0';
Asm
  MOV EMSInitd,False
  PUSH DS
  MOV AX,3D02h        { DOS function to open the device as file }
  LDS DX,DeviceDriver
  INT DOS
  POP DS
  JC  @@1
  PUSH AX             { store device handle to close the file afterwards }
  MOV AX,4407h        { DOS function to test device status }
  INT DOS
  MOV EMSInitd,AL
  POP BX
  MOV AH,3Eh          { close the file using it's handle in BX }
  INT DOS
@@1:
  MOV AL,EMSInitd
End; { EMS_Setup }

Function EMS_GetVersion; assembler;
{ Get Expanded Memory Manager version number }
Asm
  MOV AL,emsrNotInitd
  CMP EMSInitd,False  { If library not initialized by EMS_Setup }
  JE  @@1             { then exit }
  MOV AH,EGetVersion  { Get EMS version }
  INT EMS
  LES DI,Version
  MOV [ES:DI],AL      { Store version number }
  MOV AL,AH           { Store result byte }
@@1:
End; { EMS_GetVersion }

Function EMS_GetMemAvail; assembler;
{ Returns free memory in FreeMem parameter }
Asm
  MOV AL,emsrNotInitd
  CMP EMSInitd,False
  JE  @@1
  MOV AH,EGetPageCount
  INT EMS
  SHL BX,4            { Got in pages, convert to K-bytes }
  LES DI,FreeMem
  MOV [ES:DI],BX      { Store memory available in K-Bytes }
  MOV AL,AH           { Store result byte }
@@1:
End; { EMS_GetMemAvail }

Function EMS_AllocEMB; assembler;
{ Allocates specified number of 16 K-byte pages and returns handle number in
  Handle parameter. Page frame segment address stored in PageSeg. To access
  data, use the following function:
     DataPtr := Ptr(PageSeg, PhysicalPageNumber * PageSize) }
Asm
  MOV AL,emsrNotInitd
  CMP EMSInitd,False
  JE  @@2
  MOV AH,EGetPageFrame
  INT EMS
  CMP AH,0
  JNE @@1
  LES DI,PageSeg      { Store page frame segment }
  MOV [ES:DI],BX
  MOV BX,Pages
  MOV AH,EAllocPages
  INT EMS
  LES DI,Handle
  MOV [ES:DI],DX      { Store handle number }
@@1:
  MOV AL,AH           { Return result code }
@@2:
End; { EMS_AllocEMB }

Function EMS_FreeEMB; assembler;
{ Deallocates (releases) allocated expanded memory }
Asm
  MOV AL,emsrNotInitd
  CMP EMSInitd,False
  JE  @@1
  MOV AH,EReleasePages
  MOV DX,Handle
  INT EMS
  MOV AL,AH           { Return result code }
@@1:
End; { EMS_FreeEMB }

Function EMS_MapPages; assembler;
{ Maps a logical page number at physical page number }
Asm
  MOV AL,emsrNotInitd
  CMP EMSInitd,False
  JE  @@1
  MOV AH,EMapPages
  MOV DX,Handle
  MOV BX,LogicalPage
  MOV AL,PhysicalPage
  INT EMS
  MOV AL,AH
@@1:
End; { EMS_MapPages }

Function EMS_GetErrorMsg;
{ Get an error message according to ErrorCode }
Begin
  case ErrorCode of
    emsrNotInitd:      EMS_GetErrorMsg := 'EMM not initialized';
    emsrIntrnlError:   EMS_GetErrorMsg := 'Internal error';
    emsrHardwareMalf:  EMS_GetErrorMsg := 'Hardware malfunction';
    emsrBadHandle:     EMS_GetErrorMsg := 'Invalid block handle';
    emsrBadFunction:   EMS_GetErrorMsg := 'Function not implemented';
    emsrNoMoreHandles: EMS_GetErrorMsg := 'No more handles available';
    emsrMapContError:  EMS_GetErrorMsg := 'Error in save or restore of ' +
'mapping context';
    emsrMorePagesPhys: EMS_GetErrorMsg := 'More pages requested than ' +
'physically exist';
    emsrMorePagesCurr: EMS_GetErrorMsg := 'More pages requested than ' +
'currently available';
    emsrZeroPages:     EMS_GetErrorMsg := 'Zero pages requested';
    emsrBadPageLogNum: EMS_GetErrorMsg := 'Invalid page logical number';
    emsrBadPagePhyNum: EMS_GetErrorMsg := 'Invalid page physical number';
    else EMS_GetErrorMsg := 'Unknown error'
  end
End; { EMS_GetErrorMsg }

Begin
  EMSInitd := False
End. { EMSLib }

{ --------------------------   DEMO --------------------------------- }

Program EMSLibDemo;
{ Copyright (c) 1994 by Andrew Eigus                  FidoNet: 2:5100/33 }
{ LIM EMS Interface V1.01 for Turbo Pascal version 7.0 demonstration program }

(*
  Tested on IBM 486 SX 33Mhz with 4MB RAM with the following configuration:
        HIMEM.SYS  (MS-DOS 6.2 XMS memory manager)
        EMM386.EXE (MS-DOS 6.2 EMS memory manager)

  If any bugs occur in your system while running this demo,
  please inform me:

 AndRew's BBS Phone: 003-712-559777 (Riga, Latvia) 24h 2400bps
 Voice Phone:     003-712-553218
 FidoNet:     2:5100/33
 E-Mail:      aeigus@fgate.castle.riga.lv
*)

{$X+}{$R-} { Enable extended syntax }

uses EMSLib;

type TMsg = array[1..13] of Char;

const
  Message1 : TMsg = 'First string ';
  Message2 : TMsg = 'Second string';

var
  Version : byte;
  FreeMemory, Handle, SegAddr, I : word;
  P : pointer;

Function Hex(Num : longint; Places : byte) : string;
const HexTab : array[0..15] of Char = '0123456789ABCDEF';
var
  HS : string[8];
  Digit : byte;
Begin
  HS[0] := Chr(Places);
  for Digit := Places downto 1 do
  begin
    HS[Digit] := HexTab[Num and $0000000F];
    Num := Num shr 4
  end;
  Hex := HS
End; { Hex }

Function Check(Result : byte; Func : string) : byte;
Begin
  if Result <> emsrOk then
    WriteLn(Func, ' returned ',
      Hex(Result, 2), 'h (', Result, '): ', EMS_GetErrorMsg(Result));
  Check := Result
End; { Check }

Procedure PrintFreeMemory;
Begin
  WriteLn;
  if Check(EMS_GetMemAvail(FreeMemory), 'EMS_GetMemAvail') = emsrOk then
    WriteLn('EMS memory available: ', FreeMemory, ' KB');
  WriteLn
End; { PrintFreeMemory }

Begin
  WriteLn('LIM EMS Library V1.01 Demonstration program by Andrew Eigus'#10);
  if EMS_Setup then
  begin
    if Check(EMS_GetVersion(Version), 'EMS_GetVersion') = emsrOk then
      WriteLn('EMS driver version ',
        Version shr 4, '.', Version shr 8, ' detected');
    PrintFreeMemory;
    if FreeMemory = 0 then Halt(8);
    if Check(EMS_AllocEMB(Handle, SegAddr, 1), 'EMS_AllocEMB') = emsrOk then
    begin
      WriteLn('Message1: ', Message1);
      WriteLn('Message2: ', Message2);
      WriteLn('16 KB (one page) of EMS allocated. Linear address: ',
        Hex(SegAddr, 8), 'h');
      PrintFreeMemory;
      WriteLn('Transferring Message1 to EMS...');
      for I := 0 to SizeOf(TMsg) - 1 do
        EMS_MapPages(Handle, I, 0);
      P := Ptr(SegAddr, 0);
      Move(Message1, P^, SizeOf(TMsg));
      WriteLn('Transferring Message1 from EMS to Message2...');
      Move(P^, Message2, SizeOf(TMsg));
      WriteLn('Message1: ', Message1);
      WriteLn('Message2: ', Message2);
      if Check(EMS_FreeEMB(Handle), 'EMS_FreeEMB') = emsrOk then
      begin
        WriteLn('Memory deallocated (released). ');
        PrintFreeMemory
      end
    end
  end else
    WriteLn('EMM386 manager not installed.');
End.

