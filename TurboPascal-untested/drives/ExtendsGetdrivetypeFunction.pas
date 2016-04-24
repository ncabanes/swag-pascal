(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0103.PAS
  Description: Extends GetDriveType Function
  Author: K. CAMPBELL
  Date: 09-04-95  11:00
*)


{ ###################################################################

	Extends the Windows function GetDriveType()
	and provides the same function for Dos...

	This code by: K Campbell CompuServe [100064,1751]

	Some sections hacked out of code by:

		Dr. Peter Below CIS [100113.1101]

	&

		Extended GetDriveType for Windows 3.0/3.1.
		Code ported from the C in Microsoft PSS document Q105922.
		by	Doug Wegscheid 3/22/94.

	No warrenties given! (Don't blame them, blame me.)

	Note:

	1)		this uses the convention: Drive 1 = A and not Drive 0 = A
			which the original GetDriveType() uses!!!

	2)		works OK with CDRoms and RAMDisks, but I can't test on a
			network (as I'm not on one!) If you use it on a networked
			drive or a removable drive, let me know if it works!

	This code is released to the public domain!
################################################################### }

unit TestDrive;

interface

{$IFDEF WINDOWS}
uses	WinProcs, WinDos, Strings;

{$ELSE}
uses	Dos, Strings;

{$ENDIF}

const	dt_NotFound		= 0; 			{ Not detected }
		dt_Removable	= 1;        { Unknown removable type }
		dt_HardDisk    = 2;        { Standard hard disk }
		dt_Networked	= 3;        { Remote drive on a network }
		dt_CDRom		 	= 4;        { CD Rom drive }
		dt_Floppy     	= 5;        { Floppy drive }
		dt_RAMDisk    	= 6;        { RAM disk }

type	DeviceParams = record
			bSpecFunc	: byte;			{ Special functions }
			bDevType	: byte;				{ Device type }
			wDevAttr	: word;     		{ Device attributes }
			wCylinders	: word;			{ Number of cylinders }
			bMediaType	: byte;			{ Media type }
												{ Beginning of BIOS parameter block (BPB) }
			wBytesPerSec	: word;		{ Bytes per sector }
			bSecPerClust	: byte;		{ Sectors per cluster }
			wResSectors	: word;     	{ Number of reserved sectors }
			bFATs		: byte;        	{ Number of FATs }
			wRootDirEnts	: word;  	{ Number of root-directory entries }
			wSectors	: word;        	{ Total number of sectors }
			bMedia	: byte;        	{ Media descriptor }
			wFATsecs	: word;        	{ Number of sectors per FAT }
			wSecPerTrack	: word;  	{ Number of sectors per track }
			wHeads	: word;        	{ Number of heads }
			dwHiddenSecs	: longint;  { Number of hidden sectors }
			dwHugeSectors	: longint;  { Number of sectors if wSectors == 0 }
												{ End of BIOS parameter block (BPB) }
		end;

function GetDeviceParameters(Drive : word ; var dp : DeviceParams) : boolean;
function GetDriveTypeEx(D : byte) : byte;
function IsCDRomDrive(D : Byte) : boolean;

implementation


function GetDeviceParameters(Drive : word ; var dp : DeviceParams) : boolean;

{$IFDEF WINDOWS}
var Reg : TRegisters;

{$ELSE}
var Reg : Registers;

{$ENDIF}

begin
	FillChar(Reg, SizeOf(Reg), #0);			{ clean up registers to avoid GPF }
	Reg.ax := $440D;								{ IOCTL }
	Reg.ch := $08;									{ block device }
	Reg.cl := $60;									{ get device parameters }
	Reg.bx := Drive;								{ 1 = A:, 2 = B:, etc... }
	Reg.ds := seg(dp);
	Reg.dx := ofs(dp);
	MSDos(Reg);
	GetDeviceParameters := (Reg.flags and fCarry) = 0
end;


function GetDriveTypeEx(D : byte) : byte;

{$IFNDEF WINDOWS}
var	Reg : Registers;

{$ENDIF}

var   Result, uType : byte;
		dp	: DeviceParams;

begin
	Result := dt_NotFound;
	FillChar (dp, SizeOf(dp), #0);	{ clear the DPB }

{$IFDEF WINDOWS}
	uType := GetDriveType(D - 1);		{ make a rough guess }

{$ELSE}
	uType := 0;
	FillChar(Reg, SizeOf(Reg), #0);
	Reg.ax := $4408;          					{ IOCTL is drive changeable function }
	Reg.bl := D;
	MSDos(Reg);
	if (fCarry and Reg.Flags) <> 0 then
	{ error, check error code in ax }
	begin
		{ Driver does not support this call, so guess as a hard disk }
		if Reg.ax = 1 then uType := 3;
	end
	else
	begin
		if Reg.ax = 0 then						{ media changeable, floppy, WORM or MO }
			uType := 2
		else              						{ else hard disk, ramdisk or CD-ROM }
			uType := 3;
	end;
	{ check if drive is remote }
	Reg.ax := $4409;  							{ IOCTL is redirected device function }
	Reg.bl := D;
	MSDos(Reg);
	if (not ((fCarry and Reg.Flags) <> 0)) and (Reg.dx = $1000) then uType := 4;

{$ENDIF}
	case uType of
		2 :	{ Removable }
			{	0=320/360kb floppy, 1=1.2Mb, 2=720kb, 3=8" single density,
				4=8" double density, 7=1.44Mb, 8=optical, 9=2.88Mb.}
			if GetDeviceParameters(D, dp) and (dp.bDevType in [0..4,7,9]) then
				Result := dt_Floppy
			else
				Result := dt_Removable;
		3 :	{ Fixed }
			if GetDeviceParameters(D, dp) and (dp.bDevType = 5) then
				Result := dt_HardDisk
			else
				Result := dt_RAMDisk;
		4 :   { Remote }
			if IsCDRomDrive(D) then
				Result := dt_CDRom
			else
				Result := dt_Networked;
	end;
	GetDriveTypeEx := Result;
end;


{ Returns TRUE if Drive is a CD-ROM drive, FALSE if it isn't.}
function IsCDRomDrive(D : Byte) : boolean;

{$IFDEF WINDOWS}
var Reg : TRegisters;

{$ELSE}
var Reg : Registers;

{$ENDIF}

begin
	FillChar(Reg, SizeOf(Reg), #0);
	Reg.ax := $150B;			{ MSCDEX installation check }
	Reg.cx := (D - 1);		{ D: 1 = A:, 2 = B:, etc... }
	Intr ($2F, Reg);			{ do it }
	IsCDRomDrive := (Reg.bx = $ADAD) and (Reg.ax <> 0);
end;


end.
