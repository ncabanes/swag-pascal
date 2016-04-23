
{+------------------------------------------------------------
 | Unit Drives
 |
 | Version: 2.0  Last modified: 02/27/95, 21:49:56
 | Author : P. Below  CIS [100113,1101]
 | Project: Common utilities
 | Units required (only for the Implementation section):
 |   DOS: Dos (Borland)
 |	 Windows: Win31 (Borland), WinDOS (Borland), Wintypes (Borland),
 |            WinProcs (Borland), DMPI (own);
 | Description:
 |   This Unit collects routines to gather information about
 |	 the disk drives on a system in both DOS and Windows. You can
 |	 build a drive map with a single procedure call. In addition
 |	 to drive type checking the volume name, serial number, and
 |	 FAT type for local fixed disks or the netshare name for 
 |	 networked drives are also retrieved.
 |	 Low-level routines for all the subfunctions involved in 
 |	 building the drive map are exported, too. You can thus get
 |	 the media info or disk paramter block for floppy disk or other
 |	 removable media drives "by hand", if necessary. 
 |	 Most of the low level stuff uses DOS IOCTL functions, even
 |	 for the Windows version ( GetDriveType is just to limited ).
 |	 CD-ROM identification uses the MSCDEX int 2Fh interface.
 |
 |	 This Unit has been checked under real mode DOS and Windows
 |	 (Win 3.1, WfWg 3.11, Win NT 3.5 ) but _not_ under protected
 |		mode DOS (DPMI)!
 | Copyright (C) 1994,1995 by Peter Below 
 |   This code is released to the public domain, use it as you see fit
 |	 in your own programs (at your own risk, of course) but you should
 |	 include a note of the origin of this code in your program.
 +------------------------------------------------------------}
Unit Drives;

Interface

Const
  DRIVE_CDROM = 5;
  DRIVE_RAM   = 6;

  Min_DriveNums = 1;  (* drive a: *)
  Max_DriveNums = 26; (* drive z: *) 
Type
  TDriveTypes = ( FLOPPY, HARDDISK, REMAPPED, REMOTE, CD_ROM,
                  RAMDISK, INVALID );
  TDTypeSet   = SET OF TDriveTypes;
  TDriveNums  = Min_DriveNums..Max_DriveNums;
                (* range A: To Z: of drive letters *)
  TDriveSet   = SET OF TDriveNums; 
  TDeviceName = ARRAY [0..127] OF CHAR;
  TDiskInfo   = Record (* this is a DOS structure used by GetMediaID
                          but modified to allow for asciiz strings *)
                  InfoLevel: WORD;
                  serialNo: LongInt;
                  volName : ARRAY [0..11] OF CHAR;
                  FATType : ARRAY [0..8] OF CHAR;
                End;
  TDriveInfo  = Record
                  Flags: TDTypeSet;
                  Case Boolean OF
                    TRUE:  (* For network drives *)
                      (DevName: TDeviceName);
                    FALSE: (* For all other drives *)
                      (Info: TDiskInfo);
                End;
  TDriveMap   = ARRAY [TDriveNums] OF TDriveInfo;
  PDriveMap   = ^TDriveMap;

  LP_DPB = ^DPB;  
  DPB = Record  (* Disk Parameter Block as per MSDOS Programmer's Reference *)
    dpbDrive       : BYTE;
    dpbUnit        : BYTE;
    dpbSectorSize  : WORD;
    dpbClusterMask : BYTE;
    dpbClusterShift: BYTE;
    dpbFirstFAT    : WORD;
    dpbFATCount    : BYTE;
    dpbRootEntries : WORD;
    dpbFirstSector : WORD;
    dpbMaxCluster  : WORD;
    dpbFATSize     : WORD;
    dpbDirSector   : WORD;
    dpbDriverAddr  : Pointer;
    dpbMedia       : BYTE;
    dpbFirstAccess : BYTE;
    dpbNextDPB     : LP_DPB;
    dpbNextFree    : WORD;
    dpbFreeCnt     : WORD;
  End;

Procedure MyGetDriveType( n: TDriveNums; Var f: TDTypeSet );
Procedure GetDriveInfo( n: TDriveNums; Var di: TDriveInfo );
Procedure BuildDriveMap( Var DMap: TDriveMap    );

Function MSCDexIsloaded: Boolean;
Function DriveIsCDROM( n: TDriveNums ): Boolean;
Function DriveIsRamdisk( n: TDriveNums ): Boolean;
Function GetDiskParameterBlock( drive: TDriveNums ): LP_DPB;
Function GetLastdrive: TDriveNums;

{ the following functions map directly to DOS IOCTL calls }
Function MediumIsRemovable( n: TDriveNums ): TDriveTypes;
Function DriveIsRemote( n: TDriveNums ): Boolean;
Function DriveIsRemapped( n: TDriveNums ): Boolean;
Function GetMediaID ( Drive: Word; Var info: TDiskInfo ): Boolean;
Function GetDriveMapping( n: TDriveNums ): TDriveNums;
Procedure MapLogicalDrive( n: TDriveNums );

Implementation

Uses Strings,
{$IFDEF WINDOWS}
 Win31, WinDOS, Wintypes, WinProcs, DMPI;
{$ELSE}
 DOS;
{$ENDIF}

{************************************************************
 * Function MediumIsRemovable
 *
 * Parameters:
 *	n: the drive number to check, 1= A:, 2=B: etc.
 * Returns:
 *	one of the three drive types INVALID, FLOPPY or HARDDISK
 * Description:
 *	This function uses DOS IOCTL function $4408 to check a drive
 *	for removable media. It can also be used to check for a drives
 *	existance.
 *	Should work for DOS, Windows, and DPMI.
 *
 *Created: 02/26/95 20:49:03 by P. Below
 ************************************************************}
Function MediumIsRemovable( n: TDriveNums ): TDriveTypes;
  Var
  	res: Word;
  Begin
  	asm
		  mov ax, $4408  	(* IOCTL is drive changeable function *)
			mov bl, n
{$IFDEF WINDOWS}
      call Dos3Call
{$ELSE}
      int $21
{$ENDIF}
			mov res, ax
			{ Our handling of the result makes the following asumptions here:
			  If the function succeeds (carry flag clear), the return in ax
				will be 0 for removable and 1 for fixed medium.
				If the function fails (carry flag set), the error code in ax
				will be 1, if the device driver does not know how to handle the
				function (in which case we assume a fixed disk, also ax=1, safe bet 
				according to MS docs) or it will be $F, if the drive is invalid. 
			 }
		End; { asm }
		Case res Of
			0: MediumIsRemovable := FLOPPY;
			1: MediumIsRemovable := HARDDISK
		Else
		  MediumIsRemovable := INVALID;
		End; { Case }
  End; (* BasicDriveType *)

{************************************************************
 * Function DriveIsRemote
 *
 * Parameters:
 *	n: the drive number to check, 1= A:, 2=B: etc.
 * Returns:
 *	TRUE, if the drive is remote, FALSE if it is local or invalid.
 * Description:
 *	This function uses DOS IOCTL function $4409 to check whether 
 *	a drive is remote or local.
 *	Should work for DOS, Windows, and DPMI.
 *
 *Created: 02/26/95 21:12:32 by P. Below
 ************************************************************}
Function DriveIsRemote( n: TDriveNums ): Boolean; Assembler;
 	Asm
	  mov ax, $4409  	(* IOCTL is drive remote function *)
		mov bl, n
{$IFDEF WINDOWS}
    call Dos3Call
{$ELSE}
    int $21
{$ENDIF}
		mov ax, False   (* assume error, in which case we return false *) 
		jc @error
		and dx, $1000  (* remote drives have bit 12 set *)
		jz @error
		inc ax
	@error:
  End; (* DriveIsRemote *)

{************************************************************
 * Function DriveIsRemapped
 *
 * Parameters:
 *	n: the drive number to check, 1= A:, 2=B: etc.
 * Returns:
 *	TRUE, if the drive can be remapped, FALSE if not or if it is invalid.
 * Description:
 *	This function uses DOS IOCTL function $440E to check whether 
 *	a drive can be remapped.
 *	Should work for DOS, Windows, and DPMI.
 *
 *Created: 02/26/95 21:21:46 by P. Below
 ************************************************************}
Function DriveIsRemapped( n: TDriveNums ): Boolean; Assembler;
  Asm
	  mov ax, $440E  	(* IOCTL get logical drive mapping function *)
		mov bl, n
{$IFDEF WINDOWS}
    call Dos3Call
{$ELSE}
    int $21
{$ENDIF}
		jc @error
		cmp al, 0       (* if carry not set, ax returns last drive number *)
		je @error       (* of the mapped drive, or 0, if the block device has *)
		mov ax, True    (* only one drive assigned to it.  *)
		jmp @done
	@error:
	  mov ax, false
	@done:
  End; (* DriveIsRemapped *)

{************************************************************
 * Function GetDriveMapping
 *
 * Parameters:
 *	n: the drive number to check, 1= A:, 2=B: etc.
 * Returns:
 *	The logical drive number the drive is mapped to, or the number
 *	passed in n, if the drive is not mapped or is invalid.
 * Description:
 *	This function uses DOS IOCTL function $440E to check whether 
 *	a drive is remapped.
 *	Should work for DOS, Windows, and DPMI.
 * Error Conditions:
 *	none
 *Created: 02/26/95 21:21:46 by P. Below
 ************************************************************}
Function GetDriveMapping( n: TDriveNums ): TDriveNums; Assembler;
  Asm
	  mov ax, $440E  	(* IOCTL get logical drive mapping function *)
		mov bl, n
{$IFDEF WINDOWS}
    call Dos3Call
{$ELSE}
    int $21
{$ENDIF}
		jc @error				(* if no error *)
		or  al, al      (* check return, 0 means not remapped *)
		jnz @done       (* if remapped, return mapped drive number *)
	@error:
	  mov al, n       (* else return original drive number *)
    xor ah, ah
	@done:
  End; (* GetDriveMapping *)

{************************************************************
 * Procedure MapLogicalDrive
 *
 * Parameters:
 *	n: the physical drive number to map, 1= A:, 2=B: etc.
 * Description:
 *	Uses DOS IOCTL function $440F to map the physical drive
 *	passed to the next logical drive number the block device
 *	driver supports. Does nothing for drives that are not
 *	mappable or invalid.
 *	Use it with n=1 to map the floppy drive on a single floppy
 *	system between A: and B:, use GetDriveMapping to check the
 *	current mapping.
 *	Should work for DOS, Windows, and DPMI.
 *
 *Created: 02/26/95 21:51:34 by P. Below
 ************************************************************}
Procedure MapLogicalDrive( n: TDriveNums ); assembler;
  Asm
     mov AX, $440F
     mov BL, n
{$IFDEF WINDOWS}
     call Dos3Call
{$ELSE}
     int $21
{$ENDIF}
  End ;

Type
  TMediaID = Record  (* This is the MS-DOS original MediaID structure *)
    wInfoLevel: WORD;
    dwSerialNumber: LongInt;
    VolLabel: ARRAY [0..10] of Char;
    FileSysType: ARRAY [0..7] of Char;
  End;
  PMediaID = ^TMediaID;

{************************************************************
 * Function GetMediaID 
 *
 * Parameters:
 *	Drive: 0 = default drive, 1 =A: etc.
 *	Info : Record to receive the media id info, filled with 0
 *	       if function fails.
 * Returns:
 *	True if successful, False if error. 
 * Description:
 *	This function uses DOS IOCTL function $440D, subfunction $0866
 *	to read the media ID record from the disks bootsector. For 
 *	Windows, this requires use of DPMI.
 *	Works for DOS and Windows, not tested for DPMI!
 *
 *Created: 02/26/95 21:44:02 by P. Below
 ************************************************************}
{$IFDEF WINDOWS}
 (*************************************************************************
 / GetMediaID() - Windows version
 /
 / Get Media ID by simulating an Int 21h, AX=440Dh, CX=0866h in real mode.
 / Setup RealModeReg To contain a real mode pointer To a MediaID structure
 /************************************************************************)
Function GetMediaID ( Drive: Word; Var info: TDiskInfo ): Boolean;
  Var
    RealModeReg: TRealModeReg;
    dwGlobalDosBuffer: LongInt;
    lpRMMediaID: PMediaID;
  Begin
    GetMediaID := FALSE;
    FillChar( info, Sizeof( info ), 0 );
    { Get a real mode addressable buffer For the MediaID structure }

    dwGlobalDosBuffer := GlobalDosAlloc(sizeof(TMediaID));
    If (dwGlobalDosBuffer <> 0) Then Begin

      { Now initialize the real mode register structure }
      FillChar(RealModeReg, sizeof(RealModeReg), 0);
      RealModeReg.rmEAX := $440D;           { IOCTL For Block Device }
      RealModeReg.rmEBX := LongInt(Drive);  { 0 = default, 1 = A, 2 = B, etc. }
      RealModeReg.rmECX := $0866;           { Get Media ID }
      RealModeReg.rmDS  := HIWORD(dwGlobalDosBuffer);  { *real mode segment* }

      { Now simulate the real mode interrupt }
      If RealInt($21, RealModeReg) and        { int simulation ok?}
         ((RealModeReg.rmCPUFlags and $0001)=0) { carry clear? }
      Then Begin
         lpRMMediaID := PMEDIAID( MakeLong(0, LOWORD(dwGlobalDosBuffer)));
         info.InfoLevel := lpRMMediaID^.wInfoLevel;
         info.serialNo  := lpRMMediaID^.dwSerialNumber;
         StrMove( info.volName, lpRMMediaID^.VolLabel, 11 );
         StrMove( info.FATType, lpRMMediaID^.FileSysType, 8 );
         GetMediaID := TRUE;
      End;

      GlobalDosFree(LOWORD(dwGlobalDosBuffer));
    End;
  End;
{$ELSE}
 (*************************************************************************
  | GetMediaID() - DOS version
  |
  |Get Media ID using Int 21h, AX=440Dh, CX=0866h in real mode.
  |WARNING! Assumes DOS-Version > 4.0!
  ************************************************************************)
Function GetMediaID ( Drive: Word; Var info: TDiskInfo ): Boolean;
  Label error;
  Var
    MediaID: TMediaID;
  Begin
    GetMediaID := FALSE;
    FillChar( info, Sizeof( info ), 0 );
		asm
		  push ds
		  mov ax, $440D;  { IOCTL For Block Device }
			mov bx, Drive;  { 0 = default, 1 = A, 2 = B, etc. }
      mov cx, $0866;  { Get Media ID }
			mov dx, ss      { point ds:dx at MediaID }
			mov ds, dx
			lea dx, MediaID
			int $21
			pop ds
			jc  error
		End;
    info.InfoLevel := MediaID.wInfoLevel;
    info.serialNo  := MediaID.dwSerialNumber;
    StrMove( @info.volName, @MediaID.VolLabel, 11 );
    StrMove( @info.FATType, @MediaID.FileSysType, 8 );
    GetMediaID := TRUE;
	error:
  End;
{$ENDIF}


{************************************************************
 * Function MSCDExIsLoaded
 *
 * Parameters:
 *	none
 * Returns:
 *	True, if MSCDEX is loaded, False otherwise
 * Description:
 *	Uses the MSCDEX Int $2F interface, function $00.
 *	Should work for DOS, Windows, and DPMI.
 *
 *Created: 02/26/95 21:55:17 by P. Below
 ************************************************************}
Function MSCDExIsLoaded: Boolean; assembler;
  Asm
    mov AX, $1500   (* MSCDEX installed check *)
    xor BX, BX
    int $2F
    xor ax, ax      (* set default return value To false *)
    or  BX, BX      (* returns bx <> 0 If MSCDEX installed *)
    jz  @no_mscdex
    mov al, TRUE
  @no_mscdex:
  End;

{************************************************************
 * Function DriveIsCDROM
 *
 * Parameters:
 *	n: the drive number to check, 1= A:, 2=B: etc.
 * Returns:
 *	True, if the drive is a CD-ROM, False otherwise.
 * Description:
 *	Uses the MSCDEX Int $2F interface, function $0B.
 *	It is not necessary to check for the presence of
 *	MSCDEX first.
 *	Should work for DOS, Windows, and DPMI.
 *
 *Created: 02/26/95 21:57:06 by P. Below
 ************************************************************}
Function DriveIsCDROM( n: TDriveNums ): Boolean; assembler;
  Asm
    mov ax, $150B (* MSCDEX check drive Function *)
    mov cl, n
    xor ch, ch
    dec cx        (* 0 = A: etc.*)
		xor bx, bx
    int $2F
		cmp bx, $ADAD (* is MSCDEX present? *) 
		jne @no_cdrom
    or  ax, ax
    jz  @no_cdrom
    mov ax, True
		jmp @done
  @no_cdrom:
	  mov ax, False
	@done:
  End;

{$IFDEF WINDOWS}
Procedure Beautify( s: PChar );
  (* internal procedure, remove a dot from the volume name,
     padd to 11 chars with blanks *)
  Var
    p: PChar;
    i: Integer;
  Begin
    p := StrScan( s, '.' );
    If p <> nil Then
      StrMove( p, p+1, 4 );

    (* padd To 11 chars with blanks *)
    i := StrLen( s );
    While i < 11 Do Begin
      StrCat( s, ' ' );
      INC(i);
    End;
  End ;
{$ELSE}
Procedure Beautify( Var s: string );
  (* internal procedure, remove a dot from the volume name,
     padd to 11 chars with blanks *)
  Var
    i: Integer;
  Begin
    i := Pos( '.', s );
    If i <> 0 Then
      Delete( s, i, 1 );

    (* padd To 11 chars with blanks *)

    While Length(s) < 11 Do
      s:= s + ' ';
  End ;
{$ENDIF}

{************************************************************
 * Procedure GetNetworkShareName  [ NOT EXPORTED! ]
 *
 * Parameters:
 *	n: the drive number, 1= A:, 2=B: etc.,  should be a network drive!
 *	name: array of char to take the device name
 * Description:
 *	This is a internal helper procedure, it does not check its 
 *  parameters. name will return an empty string, if the drive is
 *	not a network drive.
 *
 *Created: 02/26/95 22:07:49 by P. Below
 ************************************************************}
Procedure GetNetworkShareName( n: TDriveNums; Var name: TDeviceName );
  Var
    Param: ARRAY [0..16] OF CHAR;
{$IFNDEF WINDOWS}
    Buf  : ARRAY [0..16] OF CHAR;
{$ENDIF}
    i    : Integer;
  Begin
    Param[0] := Chr( n - 1 + Ord('A'));
    Param[1] := ':';
    Param[2] := #0;
    name [0] := #0;

{$IFDEF WINDOWS}
    i := Sizeof( name );
    WNetGetConnection( @Param, @name, @i );
{$ELSE}
    { for plain DOS we need a bit of work, using int 21h, function 5F02h,
      "Get Assign-List Entry". This entails a search thru the list of all
      entries. }
		asm
			push ds
			push es
			push si
			push di
		  sub bx, bx   		{ bx holds the list index, starts with 0 }
			mov ax, ss	 		{ point ds:si at Buf }
			mov ds, ax
			lea si, Buf
			les di, name 		{ point es:di at name }
		@next:
		  sub cx, cx
		  mov ax, $5F02  	{ dos get redirection list entry function }
			push bx        	{ save current index }
			push bp        	{ Network Interrupts sez: dx,bp destroyed! }
			int $21
			pop bp
			jc  @error
			{ we have an entry, compare its local name in Buf with the drive 
			  name in Param, but only if the type returned in bl is 4 (disk drive)}
			cmp bl, 4
			pop bx					{ restore index }
			jne @next_bx  	{ try next if no disk drive }
			mov ax, [ si ]	{ else get drive letter + colon from Buf }
			cmp ax, word ptr Param  { and compare to Param }
			je  @done       { if equal, exit }
		@next_bx:					{ else try next index }
			inc bx
			jmp @next
		@error:
		  pop bx         { no match found or network not installed, clean  }
		  mov byte ptr es:[di], 0  { saved index from stack and return name='' }
		@done:
		  pop di				 { restore all saved registers }
			pop si
			pop es
			pop ds
		End;  { Asm }
{$ENDIF}
  End ;

{************************************************************
 * Procedure GetDiskInfo
 *
 * Parameters:
 *	n: the drive number, 1= A:, 2=B: etc.
 *	info: record to take the drive info
 * Description:
 *	Calls GetMediaID to read the info block from the disk boot
 *	sector, then searches for the volume name. Will return with
 *	a serial number of 0, if GetMediaID is not supported or the
 *	drive is invalid or contains no disk.
 *
 *Created: 02/26/95 22:11:35 by P. Below
 ************************************************************}
Procedure GetDiskInfo( n: TDriveNums; Var info: TDiskInfo );
  Var fake: Boolean;
{$IFDEF WINDOWS}
      oldsettings: Word;
{$ENDIF}
  Procedure DoItOldStyle;
    Var
{$IFDEF WINDOWS}
      dinfo: TSearchRec;
      s: ARRAY [0..fsFilename] of Char;
{$ELSE}
      dinfo: SearchRec;
      s: PathStr;
{$ENDIF}
    Begin
{$IFDEF WINDOWS}
      StrCopy(s, '@:\*.*' );
      s[0] := CHR( Ord( s[0] ) + n );
      FindFirst( s, faVolumeID , dinfo );
      If DosError = 0 Then Begin
        Beautify( dinfo.Name );
        StrCopy( info.volName, dinfo.Name );
      End;
      If fake Then Begin
        StrCopy( info.FATType, 'FAT12   ');
        info.serialNo := 0;
      End;
{$ELSE}
      s := '@:\*.*';
      s[1] := CHR( Ord( s[1] ) + n );
      FindFirst( s, VolumeID , dinfo );
      If DosError = 0 Then Begin
        Beautify( dinfo.Name );
        StrPCopy( info.volName, dinfo.Name );
      End;
      If fake Then Begin
        StrPCopy( info.FATType, 'FAT12   ');
        info.serialNo := 0;
      End;
{$ENDIF}
    End ;
  Begin
		FillChar( info, Sizeof( info ), 0 );
{$IFDEF WINDOWS}
    oldsettings := SetErrorMode( SEM_FAILCRITICALERRORS );
{$ENDIF}
    (* check the DOS version  *)
    If Lo( DosVersion ) >= 4 Then
      fake := NOT GetMediaID( n, info )
    Else
      fake := TRUE;
    (* we get the volume label thru the old-style method of directory
       search because pre-DOS 5.x may not have it in the boot sector
       and even later versions may either not have it (If the disk was
       formatted by something other than DOS Format) or it may have been
       changed with LABEL, which does not change the boot sector entry!
    *)
    DoItOldStyle;
{$IFDEF WINDOWS}
    SetErrorMode( oldsettings );
{$ENDIF}
  End ;

{************************************************************
 * Procedure GetDriveName
 *
 * Parameters:
 *	n: the drive number, 1= A:, 2=B: etc.
 *	di: a drive info record that MUST have its flags field 
 *	    already filled by MyGetDriveType!
 * Description:
 *	Tries to obtain the volume info or netshare name for the
 *	passed drive. Default names are used of the info cannot be
 *	safely obtained because the drive handles removable media.
 *
 *Created: 02/26/95 22:22:28 by P. Below
 ************************************************************}
Procedure GetDriveName( n: TDriveNums; Var di: TDriveInfo );
  Begin
    FillChar( di.Info, SIZEOF( di.Info ), 0 );
    If INVALID IN di.Flags Then
      di.DevName[0] := #0
    Else
      If (FLOPPY IN di.Flags) OR (CD_ROM IN di.Flags) Then
      (* don't try To get the volume name For removable media *)
        If (REMOTE IN di.Flags) Then
          StrCopy(di.DevName, ' -UNKNOWN- ')
        Else
          StrCopy(di.Info.volName,' -UNKNOWN- ')

      Else
       If (REMOTE IN di.Flags) Then Begin
         GetNetworkShareName( n, di.DevName );
         If di.DevName[0] = #0 Then
           StrCopy(di.DevName, ' -NETWORK- ')

       End
       Else
         GetDiskInfo( n, di.Info )
  End;

{************************************************************
 * Function GetDiskParameterBlock
 *
 * Parameters:
 *	n: the drive number, 1= A:, 2=B: etc.
 * Returns:
 *	a pointer to the disk parameter bloc, or Nil, if the function
 *	fails.
 * Description:
 *	Uses DOS int $21, function $32. This function fails in network
 *	drives and it tries to actually read the disk. So If you try to
 *	use it on drive that handles removable media, make preparations
 *	to trap critical errors! 
 *
 *Created: 02/26/95 22:33:14 by P. Below
 ************************************************************}
Function GetDiskParameterBlock( drive: TDriveNums ): LP_DPB; Assembler;
  (* return a far pointer to the requested drives disk parameter block.
     This call is appearendly supported by the windows dos extender,
     we get a valid selector back in ds. *)
  Asm
      push ds
      mov DL, drive
      mov AH, $32
{$IFDEF WINDOWS}
      call Dos3Call
{$ELSE}
      int $21
{$ENDIF}
      cmp AL, $0FF
      jne @valid
      (* run into an error somewhere, return nil *)
      xor ax, ax
			mov dx, ax
      jmp @done
    @valid:
      mov ax, bx
      mov dx, ds
    @done:
      pop ds
  End;

{************************************************************
 * Function DriveIsRamdisk
 *
 * Parameters:
 *	n: the drive number, 1= A:, 2=B: etc. MUST be a fixed disk!
 * Returns:
 *	True, if the disk in question has only one FAT copy, False
 *	otherwise.
 * Description:
 *	Tries to read the disks parameter block and checks the number
 *	of FATs present. One FAT is taken to be a sign for a RAM disk.
 *	This check is not bomb-proof! 
 * Error Conditions:
 *	If you call this function for a drive handling removable media,
 *	be prepared to trap critical errors!
 *
 *Created: 02/26/95 22:35:42 by P. Below
 ************************************************************}
Function DriveIsRamdisk( n: TDriveNums ): Boolean;
  Var
    pDPB: LP_DPB;
  Begin
    DriveIsRamdisk := FALSE;
    pDPB := GetDiskParameterBlock( n );
    If pDPB <> NIL Then
      If pDPB^.dpbFATCount = 1 Then
        DriveIsRamdisk := TRUE;
  End;

{************************************************************
 * Procedure MyGetDriveType
 *
 * Parameters:
 *	n: the drive number, 1= A:, 2=B: etc. 
 *	f: set of flags that describes the drive filled by this procedure
 * Description:
 *	Tries to determine for the specified drive, whether it is valid,
 *	holds removable media, is remote, remapped, a CD-ROM or RAM-disk.
 *
 *Created: 02/26/95 22:48:32 by P. Below
 ************************************************************}
Procedure MyGetDriveType( n: TDriveNums; Var f: TDTypeSet );
  Var
    dt: word;
  Begin
    f := [];
    Include( f, MediumIsRemovable( n ));
		If ( n=2 ) and DriveIsRemapped( 1 ) Then Begin
		  Include( f, REMAPPED );
		End; { If }
		If not ( INVALID In f ) Then Begin
		  If DriveIsRemote( n ) Then
			  Include( f, REMOTE );
	    If (REMOTE IN f) and DriveIsCDROM( n ) Then
	      Include( f, CD_ROM );
	    If ([HARDDISK, CD_ROM, REMOTE] * f)= [HARDDISK] Then
	      If DriveIsRamdisk( n ) Then
          Include( f, RAMDISK );
		End; { If }
  End;

{************************************************************
 * Procedure GetDriveInfo
 *
 * Parameters:
 *	n: the drive number, 1= A:, 2=B: etc. 
 *	di: record to take the drive type and volume/netshare info
 * Description:
 *	Uses other routines in this Unit do obtain info on the drive
 *	in question. 
 *
 *Created: 02/26/95 22:53:43 by P. Below
 ************************************************************}
Procedure GetDriveInfo( n: TDriveNums; Var di: TDriveInfo );
  Begin
    MyGetDriveType( n, di.Flags );
    GetDriveName( n, di );
  End;

{************************************************************
 * Procedure BuildDriveMap
 *
 * Parameters:
 *	DMap: array of TDriveInfo records to take the info on all
 *	      drives on the system.
 * Description:
 *	Uses other routines from this Unit to build a map of all
 *	drives on the system with drive letters in the range 
 *	A..Z ( logical drives 1..26 ). The map contains for each
 *	drive a set of flags describing the drive type and also,
 *  if the drive is valid and does not handle removable media,
 *	the media id info ( volume name, serial number, FAT type ) or
 *	netshare name.
 *
 *Created: 02/26/95 22:55:50 by P. Below
 ************************************************************}
Procedure BuildDriveMap( Var DMap: TDriveMap );
  Var
    n : TDriveNums;
  Begin
    (* build a drive properties map For all possible drives.
       CAVEAT! DR-DOS 6.x has a bug that will fail IOCTL calls For
               drive letters > P:! (Thank's To Ray Tackett [76416,276]
               For this info) *)
    For n := Min_DriveNums To Max_DriveNums Do Begin
      MyGetDriveType( n, DMap[n].Flags );
      GetDriveName( n, DMap[n] );
		End;
  End ;

{************************************************************
 * Function GetLastdrive
 *
 * Parameters:
 *	none
 * Returns:
 *	the logical drive number ( 1=A: etc. ) for the last valid
 *	drive on the system.
 * Description:
 *	Uses DOS int $21, function $0E. On some systems this may just
 *	return the LASTDRIVE setting in CONFIG.SYS!
 *
 *Created: 02/26/95 22:59:12 by P. Below
 ************************************************************}
Function GetLastdrive: TDriveNums; assembler;
	asm
	  mov ah, $19   (* get current drive *)
		int $21
	  mov ah, $E    (* set current To same *)
		mov dl, al
		int $21       (* al returns highest valid drivenumber, 1=A: etc. *)
		sub ah, ah
  End;

End.

{ -------------------------   DEMO PROGRAM  ------------------- }

Program DTest;

{$IFDEF WINDOWS}
Uses Drives, WinCRT, Strings;
{$ELSE}
Uses Drives, Strings;
{$ENDIF}

Type
	TypesArray = Array [TDriveTypes] Of String[ 8 ];
Const
	TypeNames: TypesArray =
	  ( 'FLOPPY', 'HARDDISK','REMAPPED','REMOTE','CD_ROM',
      'RAMDISK','INVALID' );
Var
	n: TDriveNums;
	Map: TDriveMap;
	first: Boolean;
	f: TDriveTypes;

Procedure WriteInfo( Const di: TDriveInfo );
	Begin
		If ([ INVALID, CD_ROM, FLOPPY ] * di.Flags ) = [] Then Begin
		  Write( '  ' );
			If not(REMOTE In di.Flags) Then Begin
			  WriteLn( 'Volumen Name: ', StrPas(@di.Info.VolName),
			           ', Serial-No.: ', di.Info.SerialNo,
			           ', FAT-TYpe: ', StrPas(@di.Info.FATType) );
			End { If }
			Else
			  WriteLn( 'Netshare: ', StrPas(@di.DevName));
		End; { If }
	End; { WriteInfo }

Begin
{$IFDEF WINDOWS}
  ScreenSize.Y := 80;
{$ENDIF}

  BuildDriveMap( Map );
	For n := Min_DriveNums To Max_DriveNums Do Begin
	  first := True;
		Write( 'Drive ',Chr( n+Ord( '@' ) ),': [' );
		For f := Low( TDriveTypes ) To High( TDriveTypes )  Do Begin
		  If f in Map[ n ].Flags Then Begin
			  If first Then 
				  first := false
				Else
				  Write( ', ' );
				Write( TypeNames[ f ] );
		  End; { If }
		End; { For }
		WriteLn(']');
		WriteInfo( Map[ n ] );
	End; { For }
	
End.
