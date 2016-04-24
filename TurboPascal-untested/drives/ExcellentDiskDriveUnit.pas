(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0114.PAS
  Description: Excellent Disk Drive Unit
  Author: WILLIAM FLORAC
  Date: 05-31-96  09:16
*)

unit Drives;
{
	Drives Unit for:
		Getting and setting drive labels.
		Getting and setting drive serial number.
		Testing if a drive is ready.
		Determining the type of drive (hard/3.5/5.25...)
		Return last DOS error status.

  All procedures and functions are protected from DOS critical errors.

	Author: William R. Florac
  Company: FITCO, Verona, WI (wee little company from my house)
	Copyright 1996, FITCO.  All rights reserved.

  1) Users of Drives.pas must accept this disclaimer of warranty:
       This Unit is supplied as is.  The Fitco disclaims all
       warranties, expressed or implied, including, without limitation,
       the warranties of merchantability and of fitness for any purpose.
       Fitco assumes no liability for damages, direct or conse-
       quential, which may result from the use of this Unit."

  2) This Unit is donated to the public as public domain except as
     noted below.

  3) You must copy all Software without modification and must include
     all pages, if the Software is distributed without inclusion in your
     software product. If you are incorporating the Software in
     conjunction with and as a part of your software product which adds
     substantial value, you may modify and include portions of the
     Software.

  4) Fitco retains the copyright for this Unit.  You may not distribute
     the source code (PAS) or its compiled unit (DCU) for profit.

  5) If you do find this Unit handy and you feel guilty
     for using such a great product without paying someone,
     please feel free to send a few bucks ($25) to support further
     development.

  6) This file was formated with tabs set to 2.

	Please forward any comments or suggestions to Bill Florac at:
	 	email: flash@etcconnect.com
		www: http://sumac.etcconnect.com/~fitco/
		mail: FITCO
					209 Jenna Dr
					Verona, WI  53593

	Revision History
		2/28/96
    	1.0 released
}


interface

uses
	SysUtils, WinProcs, WinTypes;

type
  	TDriveStyle = (tUnknown, tNoDrive, t3Floppy, t5Floppy, tFixed, tRFixed,
		tNetwork, tCDROM, tTape);

		PDeviceParams = ^TDeviceParams;
		TDeviceParams = record
			bSpecFunc: 			byte;			{Special functions}
			bDevType: 			byte;			{Device type}
			wDevAttr: 			word;			{Device attributes}
			wCylinders: 		word;			{Number of cylinders}
			bMediaType: 		byte;			{Media type}
{                          Beginning of BIOS parameter block (BPB)}
			wBytesPerSec: 	word;			{Bytes per sector}
			bSecPerClust: 	byte;			{Sectors per cluster}
			wResSectors: 		word;			{Number of reserved sectors}
			bFATs: 					byte;			{Number of FATs}
			wRootDirEnts: 	word;			{Number of root-directory entries}
			wSectors: 			word;			{Total number of sectors}
			bMedia: 				byte;			{Media descriptor}
			wFATsecs: 			word;			{Number of sectors per FAT}
			wSecPerTrack: 	word;			{Number of sectors per track}
			wHeads: 				word;			{Number of heads}
			dwHiddenSecs: 	longInt;	{Number of hidden sectors}
			dwHugeSectors: 	longInt;	{Number of sectors if wSectors == 0}
			reserved: 			array[0..10] of char;
{                          End of BIOS parameter block (BPB)}
		end;

	{parameter block for getting serial number}
	PSerialNumberParams = ^TSerialNumberParams;
	TSerialNumberParams = record
		wInfoLevel: 				word;
		dwDiskSerialNumber: longint;
		caLabel: 						array[0..10] of char;
		baFileSystem: 			array[0..7] of char;
	  end;


	{parameter block to get extened error codes}
	PExtErrorParams = ^TExtErrorParams;
  TExtErrorParams = record
    eCode: 		word;
		eClass: 	word;
		eAction: 	word;
		eLocus: 	word;
		eVolume: 	String;
		end;

	{structure for FCB}
  TEFCB = record
    Flag: 			byte;
    Reserved: 	array [0..4] of char;
    Attribute: 	byte;
    Drive: 			byte;
    Name: 			array [0..7] of char;
    Extension: 	array [0..2] of char;
    Misc: 			array  [0..24] of char;
	end;

DriveLabel = string[11];

  {my exception class}
	EDriveException = Class(Exception);

const
     {$I strings}  { can be found at the END of this module !}

{standard calls}
function DriveReady(wDrive: word): boolean;
{Tests to see if a drive is ready.  (floppy there and door closed)}

function GetDriveLabel(wDrive: word): string;
function SetDriveLabel(wDrive: word; s: string): boolean;
{Gets and sets drive label}

function GetDriveSerialNumber(wDrive: word): LongInt;
function SetDriveSerialNumber(wDrive: word; SerialNumber: LongInt): boolean;
{Gets and sets drive serial number}

function GetDefaultDrive: word;
{Returns current default drive}

function GetDriveStyle(wDrive: word): TDriveStyle;
{Returns the drive style (hard, 3-1/2, 5-1/4...)}

procedure GetExtendedErrorInfo(ep: PExtErrorParams);
{Gets the parameters for the last DOS error.  Useful after a DriveReady failure.}

{other calls}
function IsCDROMDrive(wDrive: word): boolean;
function WriteDriveSNParam(wDrive: word; psnp: PSerialNumberParams): boolean;
function ReadDriveSNParam(wDrive: word; psnp: PSerialNumberParams): boolean;
function GetDeviceParameters(wDrive: word; var dp: TDeviceParams): boolean;


implementation

{determins if the drive is ready w/o critical errors enabled}
function DriveReady(wDrive: word): boolean;
var
  OldErrorMode: Word;
begin
	{turn off errors}
  OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
	try
		if DiskSize(wDrive) = -1
		then result := false
		else result := true;
  finally
		{turn on errors}
		SetErrorMode(OldErrorMode);
	end;

end;

{get drive parameters w/o drive access}
function GetDeviceParameters(wDrive: word; var dp: TDeviceParams): boolean;
begin
	result := TRUE;      {Assume success}
   asm
			push ds
      mov  bx, wDrive
      mov  ch, 08h      {Device category--must be 08h}
      mov  cl, 60h      {MS-DOS IOCTL Get Device Parameters}
      lds  dx, dp
      mov  ax, 440Dh
      int  21h
      jnc  @gdp_done     {CF SET if error}
      mov  result, FALSE
   @gdp_done:
      pop  ds
	end;
end;

{gets last error message from DOS}
procedure GetExtendedErrorInfo(ep: PExtErrorParams);
var
	tCode: word;
	tClass: byte;
	tAction: byte;
	tLocus: byte;
begin
  asm
		push ds
		push bp
  	mov  bx, 0
  	mov  ah, 59h
    int  21h
		mov	 tCode, ax
		mov	 tClass, bh
    mov	 tAction, bl
		mov	 tLocus, ch
		pop  bp
		pop  ds
	end;
  ep^.eCode := tCode;
	ep^.eClass := tClass;
	ep^.eAction := tAction;
	ep^.eLocus := tLocus;
	ep^.eVolume := '?'; {don't support this for now}
end;

{get volume serial number for a drive:  0=default, 1=A...}
{returns -1 if unable to read}
function GetDriveSerialNumber(wDrive: word): LongInt;
var
	snp: TSerialNumberParams;
begin
	snp.dwDiskSerialNumber := 0;
	if ReadDriveSNParam(wDrive, @snp)
	then Result := snp.dwDiskSerialNumber
	else Result := -1;
end;


{set volume serial number for a drive:  0=default, 1=A... }
{returns true if it was sucessful}
function SetDriveSerialNumber(wDrive: word; SerialNumber: LongInt): boolean;
var
	snp: TSerialNumberParams;
begin
	result := false;
	{get current parameters}
	if ReadDriveSNParam(wDrive, @snp) then begin
		{change serial number}
		snp.dwDiskSerialNumber := SerialNumber;
		{and write back out}
		if WriteDriveSNParam(wDrive, @snp) then result := true;
	end;
end;

{Write Drive parameters: 0=default, 1=A...}
{Note: wDrive and psnp are treate as var with assembler directive}
{This interupt does NOT generate a critical error!}
function WriteDriveSNParam(wDrive: word; psnp: PSerialNumberParams): boolean; assembler;
asm
	push ds           {ds might get changed so save it}
	mov  bx, wDrive
  mov  al, 01h
	mov  ah, 69h
  lds  dx, psnp
  int  21h
  jnc  @no_error    {CF SET if error}
	xor	 ax,ax				{set false}
  jmp	 @exit
@no_error:
  mov	ax, 1					{set true}
@exit:
	pop	ds						{restore ds}
end;

{Read Drive parameters: 0=default, 1=A...}
{Note: wDrive and psnp are treate as var with assembler directive}
{This interupt does NOT generate a critical error!}
function ReadDriveSNParam(wDrive: word; psnp: PSerialNumberParams): boolean; assembler;
asm
	push ds
	mov  bx, wDrive
  mov  al, 00h
	mov  ah, 69h
  lds  dx, psnp
  int  21h
  jnc  @no_error    	{CF SET if error}
	xor	 ax,ax		{set false}
  jmp	 @exit
@no_error:
  mov	ax, 1			{set true}
@exit:
	pop	ds
end;

{sets the label of the drive specified: wDrive: 0=default 1=A...}
{returns true if it was sucessful}
function SetDriveLabel(wDrive: word; s: string): boolean;
const
		EFCB: TEFCB = (
	    Flag: $FF;                          	{ Extended FCB Flag }
      Reserved: (#0,#0,#0,#0,#0);           { Reserved}
      Attribute: $08;                       { Volume Label Attribute}
      Drive: 2;                             { Drive Identifier}
      Name: '????????';  										{ File Name}
      Extension: '???';                     { File Extension}
      Misc: (#0, #0, #0, #0, #0,            { Misc. Info filled by DOS}
        ' ',' ',' ',' ',' ',' ',' ',' ',  	{ Misc. Info filled by DOS}
        ' ',' ',' ',                      	{ Misc. Info filled by DOS}
        #0, #0, #0, #0, #0, #0, #0, #0, #0  { Misc. Info filled by DOS}
				)
      );
var
	Ps: pchar;
	err: integer;
	x: integer;

begin
	{abort if drive not ready}
	if not DriveReady(wDrive) then begin
		result := false;
		exit;
	end;
	{assume ok}
	result := true;

	{default things that change in constant varaiable}
	EFCB.Name := '????????';
	EFCB.Extension := '???';
	EFCB.Drive := wDrive;

	{See if it exist using a FCB}
	asm
		{Check to see;  if the volume label exists}
		{point DTA to ourself}
		mov	 dx,offset EFCB
		mov	 ah,1Ah
		int  21h
		{point to default FCB}
   	mov  dx, offset EFCB
    mov  ah, 11h
    int  21h
		{Exit if label is not present}
    cmp  al, 0
    jne  @exit
		{Else delete the volume label}
    mov  dx, offset EFCB
    mov  ah, 013h
    int  21h
    or	 al,al
		jz	@exit
		mov	result, 0
  @exit:
	end;

	if not result then exit;

	{if string is empty, then just erase}
	if length(s) = 0 then exit;
	{format string}
	for x := length(s) + 1 to 11  do s[x] := ' ';
	s[0] := char(11);
	{add drive letter!}
  if wdrive = 0
	then s := '\' + s + #0
	else s := chr(64+wdrive) + ':\' + s + #0;
	ps := @s[1];

	{on now make new one it!}
	asm
		push ds
    lds  dx, ps
    mov  cx, faVolumeID
    mov  ah,3Ch
    int  21h
    {CF set if error}
    jnc  @noerror
    mov  result, FALSE
		jmp	 @exit
  @noerror:
		{close file ax = handle}
		mov  bx,ax
		mov	 ah,3Eh
		int	 21h
  @exit:
  	pop  ds
	end
end;

{Get label from drive.  0=default, 1=A...}
{return string of 11 character or "NO NAME" if not found}
function GetDriveLabel(wDrive: word): string;
const
	pattern: string[6] = 'c:\*.*';
var
	sr: TsearchRec;
  OldErrorMode: Word;
  DotPos: Byte;
begin
	{get default drive}
	if wDrive = 0
	then wDrive := GetDefaultDrive
	else dec(wDrive);

	{switch out drive letter}
	pattern[1] := char(65 + wDrive);

	{stop errors and try}
  OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
	try
		if FindFirst(Pattern, faVolumeID, sr) = 0 then begin
      Result := sr.Name;
      DotPos := Pos('.', Result);
      if DotPos <> 0 then Delete(Result, DotPos, 1);
	  end
		else result := 'NO NAME'
  finally
		{restore errorsa}
		SetErrorMode(OldErrorMode);
  end;
end;

function GetDefaultDrive: word; assembler;
asm
	mov	ah, 19h 			{convert default to real}
	int	21h
	xor	ah, ah				{clear hi byte}
end;

{Determine id drive is a CDROM, 0=default, 1=A ...}
function IsCDROMDrive(wDrive: word): boolean; assembler;
var
	wTempDrive: word;
asm
	mov	ax, wDrive
	or  ax, ax
	jnz	@not_default
	mov	ah, 19h 			{convert default to drive}
	int	21h
	xor	ah, ah
	mov wTempDrive, ax
	jmp	@test_it
@not_default: 			{zero base it}
	dec	ax
	mov wTempDrive, ax
@test_it:
	mov ax, 1500h     {first test for presence of MSCDEX}
  xor bx, bx
  int 2fh
  mov ax, bx        {MSCDEX is not there if bx is zero}
	or  ax, ax        {so return FALSE}
	jz  @no_mscdex
	mov ax, 150bh     {MSCDEX driver check API}
	mov cx, wTempDrive    {...cx is drive index}
	int 2fh
	or 	ax, ax
@no_mscdex:
end;

{returns drive type}
{read BOIS not drive so floppy does not have to be in drive}
{I don't have all types of drive so not all could be tested}
function GetDriveStyle(wDrive: word): TDriveStyle;
var
	x: word;
	wTempDrive: word;
	dp: TDeviceParams;
begin
	{convert default to drive}
	if wDrive = 0
	then wTempDrive := GetDefaultDrive
	else wTempDrive := wDrive - 1;
	x := GetDriveType(wTempDrive);

	{get types}
	case x of
	drive_Removable: begin
		dp.bSpecFunc := 0; {need to clear this}
		if GetDeviceParameters(wDrive,dp) then begin
			case dp.bDevType of
			0,1: result := t5floppy;		{320K/360K/1.2M}
			2,7,9: result := t3floppy;	{720K/1.44M/2.88M}
			5: result := tRFixed;     	{yes a removable fixed drive!}
			6: result := tTape;         {tape}
      else result := tUnknown;
			end;
		end
		else result := tUnknown;
	end;
  drive_Fixed:
		if IsCDROMDrive(wDrive)
		then result := tCDROM
		else result := tFixed;
 	drive_Remote:
		if IsCDROMDrive(wDrive) {I think this is possible on a network!}
		then result := tCDROM
		else result := tNetWork;
	else result := tUnknown;
	end;
end;

end. {of unit}

{ ----------------   STRINGS.PAS  ---------------------------------}
{ CUT }

{string constants for drives.pas}

{The error class may be one of the following}
 	eClassStr: array[0..$0D] of string = (
{OK											}'OK',
{ERRCLASS_OUTRES (01h)	}'Out of resource, such as storage.',
{ERRCLASS_TEMPSIT (02h)	}'Not an error, temporary situation (file or record lock)',
{ERRCLASS_AUTH (03h)		}'Authorization problem.',
{ERRCLASS_INTRN (04h)		}'Internal error in system.',
{ERRCLASS_HRDFAIL (05h)	}'Hardware failure.',
{ERRCLASS_SYSFAIL (06h)	}'System software failure (missing or incorrect configuration files).',
{ERRCLASS_APPERR (07h)	}'Application error.',
{ERRCLASS_NOTFND (08h)  }'File or item not found.',
{ERRCLASS_BADFMT (09h)  }'File or item with an invalid format or type.',
{ERRCLASS_LOCKED (0Ah)  }'Interlocked file or item.',
{ERRCLASS_MEDIA (0Bh)   }'Wrong disk in drive, bad spot on disk, or other storage-medium problem.',
{ERRCLASS_ALREADY (0Ch) }'Existing file or item.',
{ERRCLASS_UNK (0Dh)	 	  }'Unknown.');

{*The suggested action may be one of the following:}
 	eActionStr: array[0..$07] of string = (
{OK											}'OK',
{ERRACT_RETRY (01h)			}'Retry immediately.',
{ERRACT_DLYRET (02h)		}'Delay and retry.',
{ERRACT_USER (03h)			}'Bad user input, get new values.',
{ERRACT_ABORT (04h)			}'Terminate in an orderly manner.',
{ERRACT_PANIC (05h)			}'Terminate immediately.',
{ERRACT_IGNORE (06h)		}'Ignore the error.',
{ERRACT_INTRET (07h)		}'Remove the cause of the error (to change disks, for example) and then retry.');

{The error location may be one of the following:}
eLocusStr: array[0..$05] of string = (
{OK											}'OK',
{ERRLOC_UNK (01h)				}'Unknown',
{ERRLOC_DISK (02h)			}'Random-access device, such as a disk drive',
{ERRLOC_NET (03h)				}'Network',
{ERRLOC_SERDEV (04h)		}'Serial device',
{ERRLOC_MEM (05h)				}'Memory');

{MS DOS error codes}
eDosErrorStr: array[0..$5A] of string = (
{0000h  non error} 'OK',
{0001h}	'ERROR_INVALID_FUNCTION',
{0002h}	'ERROR_FILE_NOT_FOUND',
{0003h}	'ERROR_PATH_NOT_FOUND',
{0004h}	'ERROR_TOO_MANY_OPEN_FILES',
{0005h}	'ERROR_ACCESS_DENIED',
{0006h}	'ERROR_INVALID_HANDLE',
{0007h}	'ERROR_ARENA_TRASHED',
{0008h}	'ERROR_NOT_ENOUGH_MEMORY',
{0009h}	'ERROR_INVALID_BLOCK',
{000Ah}	'ERROR_BAD_ENVIRONMENT',
{000Bh}	'ERROR_BAD_FORMAT',
{000Ch}	'ERROR_INVALID_ACCESS',
{000Dh}	'ERROR_INVALID_DATA',
{000Eh} 'Reserved',
{000Fh}	'ERROR_INVALID_DRIVE',
{0010h}	'ERROR_CURRENT_DIRECTORY',
{0011h}	'ERROR_NOT_SAME_DEVICE',
{0012h}	'ERROR_NO_MORE_FILES',
{0013h}	'ERROR_WRITE_PROTECT',
{0014h}	'ERROR_BAD_UNIT',
{0015h}	'ERROR_NOT_READY',
{0016h}	'ERROR_BAD_COMMAND',
{0017h}	'ERROR_CRC',
{0018h}	'ERROR_BAD_LENGTH',
{0019h}	'ERROR_SEEK',
{001Ah}	'ERROR_NOT_DOS_DISK',
{001Bh}	'ERROR_SECTOR_NOT_FOUND',
{001Ch}	'ERROR_OUT_OF_PAPER',
{001Dh}	'ERROR_WRITE_FAULT',
{001Eh}	'ERROR_READ_FAULT',
{001Fh}	'ERROR_GEN_FAILURE',
{0020h}	'ERROR_SHARING_VIOLATION',
{0021h}	'ERROR_LOCK_VIOLATION',
{0022h}	'ERROR_WRONG_DISK',
{0023h}	'ERROR_FCB_UNAVAILABLE',
{0024h}	'ERROR_SHARING_BUFFER_EXCEEDED',
{0025h}	'ERROR_CODE_PAGE_MISMATCHED',
{0026h}	'ERROR_HANDLE_EOF',
{0027h}	'ERROR_HANDLE_DISK_FULL',
{0028h} 'Reserved',
{0029h} 'Reserved',
{002Ah} 'Reserved',
{002Bh} 'Reserved',
{002Ch} 'Reserved',
{002Dh} 'Reserved',
{002Eh} 'Reserved',
{002Fh} 'Reserved',
{0030h} 'Reserved',
{0031h} 'Reserved',
{0032h}	'ERROR_NOT_SUPPORTED',
{0033h}	'ERROR_REM_NOT_LIST',
{0034h}	'ERROR_DUP_NAME',
{0035h}	'ERROR_BAD_NETPATH',
{0036h}	'ERROR_NETWORK_BUSY',
{0037h}	'ERROR_DEV_NOT_EXIST',
{0038h}	'ERROR_TOO_MANY_CMDS',
{0039h}	'ERROR_ADAP_HDW_ERR',
{003Ah}	'ERROR_BAD_NET_RESP',
{003Bh}	'ERROR_UNEXP_NET_ERR',
{003Ch}	'ERROR_BAD_REM_ADAP',
{003Dh}	'ERROR_PRINTQ _FULL',
{003Eh}	'ERROR_NO_SPOOL_SPACE',
{003Fh}	'ERROR_PRINT_CANCELLED',
{0040h}	'ERROR_NETNAME_DELETED',
{0041h}	'ERROR_NETWORK_ACCESS_DENIED',
{0042h}	'ERROR_BAD_DEV_TYPE',
{0043h}	'ERROR_BAD_NET_NAME',
{0044h}	'ERROR_TOO_MANY_NAMES',
{0045h}	'ERROR_TOO_MANY_SESS',
{0046h}	'ERROR_SHARING_PAUSED',
{0047h}	'ERROR_ERROR_REQ _NOT_ACCEP',
{0048h}	'ERROR_REDIR_PAUSED',
{0049h} 'Reserved',
{004Ah} 'Reserved',
{004Bh} 'Reserved',
{004Ch} 'Reserved',
{004Dh} 'Reserved',
{004Eh} 'Reserved',
{004Fh} 'Reserved',
{0050h}	'ERROR_FILE_EXISTS',
{0051h}	'ERROR_DUP_FCB',
{0052h}	'ERROR_CANNOT_MAKE',
{0053h}	'ERROR_FAIL_I24',
{0054h}	'ERROR_OUT_OF_STRUCTURES',
{0055h}	'ERROR_ALREADY_ASSIGNED',
{0056h}	'ERROR_INVALID_PASSWORD',
{0057h}	'ERROR_INVALID_PARAMETER',
{0058h}	'ERROR_NET_WRITE_FAULT',
{0059h}	'Function not supported on Network',
{005Ah}	'ERROR_SYS_COMP_NOT_LOADED');

cDriveStr: array[0..8] of string = (
			'Unknown',
			'NoDrive',
			'3-1/2" floppy',
			'5-1/4" floppy',
		 	'hard',
			'removable hard',
			'network',
			'CD ROM',
      'tape');

