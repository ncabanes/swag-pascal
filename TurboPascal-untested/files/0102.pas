{$A+,B-,D-,E-,F-,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V+,X+,Y-}

Unit UFile95;

{A lot of declarations in this unit belong in other units, such as
 Move32 (UMemory); TBoolean/TByte/TChar - UGlobal. Unit was modified to
 be standalone.}


(* **************************************************************
     TO COMPILE  UFILE95  YOU NEED TO COMPILE THE  UMULTI  UNIT
         WHOSE SOURCE CAN BE FOUND AT THE END OF THIS FILE
   **************************************************************
                  PLEASE PUBLISH THIS IN THE SWAG
   ************************************************************** *)


Interface {Nothing!}

Const Author = 'UFile95 v6.2, 05-Feb-97, 1995-1997.'+
               'Written by Gil Shapira.'+
               'Bug or other reports to:  gilsh@ibm.net';

{Nicer looks ;-) }
Type TBoolean = Boolean;
     TPointer = Pointer;
     TChar = Char;
     TByte = Byte;
     TWord = Word;
     THalf = ShortInt;
     TInt = Integer;
     TDouble = LongInt;

Type THandle = TWord;
     TError = TWord;

{File modes}
Const fmRead = 0;
      fmWrite = 1;
      fmReadWrite = 2;
      fmDenyAll = 16;
      fmDenyWrite = 32;
      fmDenyRead = 48;
      fmDenyNone = 64;

{File seek origins}
Const foStart = 0;
      foCurrent = 1;
      foEnd = 2;

{File attributes}
Const faReadOnly = 1;
      faHidden = 2;
      faSystem = 4;
      faVolume = 8;
      faDirectory = 16;
      faArchive = 32;
      faAnyFile = 63;

{File parts}
Const fcExtension = 1;
      fcFileName = 2;
      fcDirectory = 4;
      fcWildcards = 8;

{Search record for DOS interrupt 21h}
Type PSearch = ^TSearch;
     TSearch = Record
                SearchDrive: TChar;
                SearchTemplate: Array [1..11] Of TByte;
                SearchAttr: TByte;
                DirEntry: TWord;
                StartCluster: TWord;
                Reserved: Array [1..4] Of TByte;
                Attr: TByte;
                Time: TWord;
                Date: TWord;
                Size: TDouble;
                Name: Array [1..13] Of TChar;
               End;

{Search record for Windows '95 interrupt 21h}
Type PSearch95 = ^TSearch95;
     TSearch95 = Record
                  Handle: TWord;
                  Attr: TDouble;
                  Creation: Comp;
                  LastAccess: Comp;
                  LastModify: Comp;
                  SizeHi: TDouble;
                  SizeLo: TDouble;
                  Reserved: Array [1..8] Of TByte;
                  Name: Array [0..259] Of TChar;
                  ShortName: Array [0..13] Of TChar;
                 End;

Var LockLevel,
    FileMode,
    FindAttr,
    CopyAttr,
    DeleteAttr,
    CreateAttr: TWord;
    flError: TError;
    isError,
    Using95: TBoolean;

 {Creates a new directory; only ONE directory at a time.}
Procedure CreateDir(PathName: PChar);
 {Removes an existing directory; should not be current directory}
Procedure RemoveDir(PathName: PChar);
 {Makes the specified directory the current directory,
  without changing the current drive}
Procedure ChangeDir(PathName: PChar);
 {Returns the current directory path}
Procedure CurrentDir(CurDir: PChar);
 {Makes the specified directory the current directory,
  and changes the current drive if needed}
Procedure ChangePath(PathName: PChar);
 {Creates a virtual drive for the path specified; should be
  used ONLY under Windows '95}
Procedure Subst(Drive: TChar; PathName: PChar);
 {Returns the path for the virtual drive specified; should be
  used ONLY under Windows '95}
Procedure QuerySubst(Drive: TChar; Var PathName: PChar);
 {Terminates the virtual drive association; should be
  used ONLY under Windows '95}
Procedure DeleteSubst(Drive: TChar);
 {Creates a new file}
Function Create(FileName: PChar): THandle;
 {Replaces an existing file, erasing its content}
Function Replace(FileName: PChar): THandle;
 {Opens an existing file}
Function Open(FileName: PChar): THandle;
 {Duplicated a file handle}
Function Duplicate(Handle: THandle): THandle;
 {Changes the position in the file; use the file origin
  constants for Origin}
Function Seek(Handle: THandle; Position: TDouble; Origin: TByte): TDouble;
 {Returns the current position in the file}
Function FilePos(Handle: THandle): TDouble;
 {Returns the size of the file}
Function FileSize(Handle: THandle): TDouble;
 {Splits the path to directory, filename (8), and extension (4)}
Function FSplit(Path,Dir,Name,Ext: PChar): TByte;
 {Expands a short/long filename}
Procedure FExpand(Path,Result: PChar);
 {Return the file attributes}
Function GetFileAttr(FileName: PChar): TByte;
 {Changes the file attributes}
Procedure SetFileAttr(FileName: PChar; Attr: TByte);
 {Returns a file's true name}
Procedure TrueName(FileName,TrueFileName: PChar);
 {Returns a file's short name (8.3); should be used only
  under Windows '95}
Procedure ShortName(FileName,ShortFileName: PChar);
 {Generates a short name (8.3) for a long file name; should
  be used only under Windows '95}
Procedure LongToShort(FileName,ShortFileName: PChar);
 {Deletes a file}
Procedure Delete(FileName: PChar);
 {Renames a file; can move a file between directories on the same drive}
Procedure Rename(FileName,NewName: PChar);
 {Deletes any bytes from the position in the file to its end}
Procedure Truncate(Handle: THandle);
 {Flushes any file buffers}
Procedure Commit(Handle: THandle);
 {Closes a file, writing any changes}
Procedure Close(Handle: THandle);
 {Reads a block of bytes to a buffer}
Function BlockRead(Handle: THandle; Var Buff; Count: TWord): TWord;
 {Writes a block of bytes to a file}
Function BlockWrite(Handle: THandle; Var Buff; Count: TWord): TWord;
 {Locks a drive to allow direct drive accesses}
Procedure LockDrive(Drive: TChar);
 {Unlocks a drive to disallow direct drive accesses}
Procedure UnlockDrive(Drive: TChar);
 {Changes the current drive}
Procedure ChangeDrive(Drive: TChar);
 {Returns the current drive}
Function CurrentDrive: TChar;
 {Disables a drive, rendering it completely inaccessible until reenabled}
Procedure DisableDrive(Drive: TChar);
 {Enables a previously disabled drive}
Procedure EnableDrive(Drive: TChar);
 {Turns a FLOPPY drive's led on}
Procedure TurnLedOn(Drive: TChar);
 {Turns a FLOPPY drive's led off}
Procedure TurnLedOff(Drive: TChar);
 {Returns a drive's information}
Function DriveInformation(Drive: TChar; Var DriveType: TByte; Volume: TPointer; Var Serial,TotalSpace,FreeSpace,
                           ClusterSize: TDouble): TBoolean;
 {Returns the amount of bytes free on a drive}
Function DiskFree(Drive: TChar): TDouble;
 {Returns the total amount of bytes used on a drive}
Function DiskSize(Drive: TChar): TDouble;
 {Resets a drive, flushing its buffers}
Procedure ResetDrive(Drive: TChar);
 {Quits from the calling program}
Procedure Halt(ErrorLevel: TByte);
 {Runs another program; READ NOTE IN THE CODE ITSELF!}
Procedure Exec(Prog,Params: PChar);
 {Sets the data transfer area; not to be changed normally}
Procedure SetDTA(Address: TPointer);
 {Returns the data transfer area's address}
Function GetDTA: TPointer;
 {Finds the first file; able to process long filenames; should be
  used ONLY under Windows '95}
Procedure FindFirst95(FileSpec: PChar; Attr: TByte; Var Search: TSearch95);
 {Returns the next file; should be
  used ONLY under Windows '95}
Procedure FindNext95(Var Search: TSearch95);
 {Closes a file search; MUST be done at the end of a search; should be
  used ONLY under Windows '95}
Procedure FindClose95(Var Search: TSearch95);
 {Finds the first file}
Procedure FindFirst(FileSpec: PChar; Attr: TWord; Var Search: TSearch);
 {Finds the next file}
Procedure FindNext(Var Search: TSearch);
 {Moves 4 bytes in each move; much faster; (80386 processors
  and faster ONLY)}
Procedure Move32(Var Source,Target; Len: TWord);


Implementation uses UMulti,Strings; {This is of course the Strings unit
                                     you got with your Borland/Turbo Pascal.
                                     The UMulti unit is at the end of this
                                     file. Compile if first.}

Var DTA: TPointer;
    ParameterBlock: TPointer;
    Block: Array [1..40] Of TByte;

Procedure Move32(Var Source,Target; Len: TWord); Assembler;
Asm
  Push          Ds
  Mov           Cx,Len
  Jcxz         @End
  Lds           Si,Source
  Les           Di,Target
  Cld
  ShR           Cx,1
  Jnc          @Sw
  MovSb
 @Sw:
  Shr           Cx,1
  Jnc          @Sd
  MovSw
 @Sd:
  Db            66h,0F3h,0A5h {Rep MovSd}
 @End:
  Pop           Ds
End;

Procedure CreateDir(PathName: PChar); Assembler;
Asm
  Push          Ds
  Mov           Ax,7139h
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,3900h
 @Use95:
  Lds           Dx,PathName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure RemoveDir(PathName: PChar); Assembler;
Asm
  Push          Ds
  Mov           Ax,713Ah
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,3A00h
 @Use95:
  Lds           Dx,PathName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure ChangeDir(PathName: PChar); Assembler;
Asm
  Push          Ds
  Mov           Ax,713Bh
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,3B00h
 @Use95:
  Lds           Dx,PathName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure CurrentDir(CurDir: PChar); Assembler;
Asm
  Push          Ds
  Mov           Ax,7147h
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,4700h
 @Use95:
  Xor           Dl,Dl
  Lds           Si,CurDir
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure ChangePath(PathName: PChar); Assembler;
Asm
  Push          Ds
  Lds           Si,PathName
  LodSw
  Cmp           Ah,':'
  Jne          @NoDrive
  Cmp           Al,'A'
  Jb           @NoUpper
  Cmp           Al,'Z'
  Ja           @NoUpper
  Sub           Al,20h
 @NoUpper:
  Xor           Ah,Ah
  Push          Ax
  Call          ChangeDrive
 @NoDrive:
  Lds           Si,PathName
  LodSw
  Cmp           Ah,':'
  Jne          @Added
  Dec           Si
  Dec           Si
 @Added:
  Mov           Ax,Ds
  Mov           Es,Ax
  Pop           Ds
  Push          Es
  Push          Si
  Call          ChangeDir
 @End:
End;

Procedure Subst(Drive: TChar; PathName: PChar); Assembler;
Asm
  Push          Ds
  Cmp           Using95,True
  Jne           @End
  Mov           Ax,71AAh
  Xor           Bh,Bh
  Mov           Bl,Drive
  Sub           Bl,64
  Lds           Dx,PathName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure QuerySubst(Drive: TChar; Var PathName: PChar); Assembler;
Asm
  Push          Ds
  Cmp           Using95,True
  Jne           @End
  Mov           Ax,71AAh
  Mov           Bh,02h
  Mov           Bl,Drive
  Sub           Bl,64
  Lds           Dx,PathName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure DeleteSubst(Drive: TChar); Assembler;
Asm
  Cmp           Using95,True
  Jne           @End
  Mov           Ax,71AAh
  Mov           Bh,01h
  Mov           Bl,Drive
  Sub           Bl,64
  Int           21h
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Function Create(FileName: PChar): THandle; Assembler;
Asm
  Push          Ds
  Mov           Ax,716Ch
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,6C00h
 @Use95:
  Mov           Bl,Byte Ptr FileMode
  Mov           Bh,32
  Mov           Cx,Word Ptr CreateAttr
  Mov           Dx,0000000000010000b
  Lds           Si,FileName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
 @End:
End;

Function Replace(FileName: PChar): THandle; Assembler;
Asm
  Push          Ds
  Mov           Ax,716Ch
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,6C00h
 @Use95:
  Mov           Bl,Byte Ptr FileMode
  Mov           Bh,32
  Mov           Cx,32
  Mov           Dx,0000000000010010b
  Lds           Si,FileName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
 @End:
End;

Function Open(FileName: PChar): THandle; Assembler;
Asm
  Push          Ds
  Mov           Ax,716Ch
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,6C00h
 @Use95:
  Mov           Bl,Byte Ptr FileMode
  Mov           Bh,32
  Mov           Cx,32
  Mov           Dx,0000000000000001b
  Lds           Si,FileName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
 @End:
End;

Function Duplicate(Handle: THandle): THandle; Assembler;
Asm
  Mov           Ah,45h
  Mov           Bx,Word Ptr Handle
  Int           21h
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
 @End:
End;

Function Seek(Handle: THandle; Position: TDouble; Origin: TByte): TDouble; Assembler;
Asm
  Mov           Ah,42h
  Mov           Al,Byte Ptr Origin
  Mov           Bx,Word Ptr Handle
  Mov           Cx,Word Ptr Position
  Mov           Dx,Word Ptr Position+2
  Int           21h
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
 @End:
End;

Function FilePos(Handle: THandle): TDouble; Assembler;
Asm
  Mov           Ah,42h
  Mov           Al,foCurrent
  Mov           Bx,Word Ptr Handle
  Xor           Cx,Cx
  Xor           Dx,Dx
  Int           21h
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
  Xor           Dx,Dx
 @End:
End;

Function FileSize(Handle: THandle): TDouble; Assembler;
Var FPos: TDouble;
Asm
  Push          Word Ptr Handle
  Call          FilePos
  Cmp           Word Ptr flError,0
  Jne          @Error
  Mov           Word Ptr FPos,Dx
  Mov           Word Ptr FPos+2,Ax
  Mov           Ah,42h
  Mov           Al,foEnd
  Mov           Bx,Word Ptr Handle
  Xor           Cx,Cx
  Xor           Dx,Dx
  Int           21h
  Jc           @Error
  Pusha
  Mov           Ah,42h
  Mov           Al,foStart
  Mov           Bx,Word Ptr Handle
  Mov           Cx,Word Ptr FPos
  Mov           Dx,Word Ptr FPos+2
  Int           21h
  Jnc          @End
 @Error:
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
  Xor           Dx,Dx
 @End:
  Popa
End;

Function FSplit(Path,Dir,Name,Ext: PChar): TByte;
{Based on the Borland Pascal run-time library and EnhancedDos (Andrew Eigus);
 Modified for long filename support by Gil Shapira}
Var DirLen,NameLen,Flags: TWord;
    NamePtr,ExtPtr: PChar;
Begin
 NamePtr:=StrRScan(Path,'\');
 If (NamePtr=Nil) Then NamePtr:=StrRScan(Path,':');
 If (NamePtr=Nil) Then NamePtr:=Path Else Inc(NamePtr);
 ExtPtr:=StrScan(NamePtr,'.');
 If (ExtPtr=Nil) Then ExtPtr:=StrEnd(NamePtr);
 DirLen:=NamePtr-Path;
 NameLen:=ExtPtr-NamePtr;
 Flags:=0;
 If (StrScan(NamePtr,'?')<>Nil) Or (StrScan(NamePtr,'*')<>Nil) Then Flags:=fcWildcards;
 If (DirLen<>0) Then Flags:=Flags Or fcDirectory;
 If (NameLen<>0) Then Flags:=Flags Or fcFilename;
 If (ExtPtr[0]<>#0) Then Flags:=Flags Or fcExtension;
 If (Dir<>Nil) Then StrLCopy(Dir,Path,DirLen);
 If (Name<>Nil) Then StrLCopy(Name,NamePtr,NameLen);
 If (Ext<>Nil) Then StrLCopy(Ext,ExtPtr,4);
 FSplit:=Flags;
End;

Procedure FExpand(Path,Result: PChar); Assembler;
Asm
  Push	        Ds
  Cld
  Lds	        Si,Path
  Push          Ds
  Push          Si
  Call          StrLen
  Mov           Cx,Ax
  Add	        Cx,Si
  Les	        Di,Result
  LodSw
  Cmp	        Si,Cx
  Ja	       @1
  Cmp	        Ah,':'                  {If DriveLetter not present...}
  Jne          @1                       {use default drive}
  Cmp           Al,'a'                  {If DriveLetter below 'a'...}
  Jb	       @2
  Cmp	        Al,'z'                  {or above 'z'...}
  Ja	       @2                       {jump...}
  Sub	        Al,20h                  {or else make it uppercase...}
  Jmp	       @2                       {and jump}
 @1:                                    {Get current drive}
  Dec	        Si
  Dec	        Si
  Mov	        Ah,19h
  Int	        21h
  Add	        Al,'A'
  Mov	        Ah,':'
 @2:
  StoSw                                 {Write drive letter}
  Cmp	        Si,Cx                   {If source is only drive letter...}
  Je	       @21                      {jump...}
  Cmp	        Byte Ptr [Si],'\'       {if it includes path...}
  Je	       @3                       {jump}
 @21:                                   {Get current directory}
  Sub	        Al,'A'-1
  Mov	        Dl,Al
  Mov	        Al,'\'
  StoSb
  Push	        Si
  Push	        Ds
  Mov	        Ax,7147h
  Mov	        Si,Di
  Push	        Es
  Pop	        Ds
  Int	        21h
  Pop	        Ds
  Pop	        Si
  Jc	       @3
  Cmp	        Byte Ptr Es:[Di],0
  Je	       @3
  Push	        Cx
  Mov	        Cx,-1
  Xor	        Al,Al
  RepNe	        ScaSb
  Dec	        Di
  Mov	        Al,'\'
  StoSb
  Pop	        Cx
 @3:
  Sub   	Cx,Si
  Rep	        MovSb
  Xor	        Al,Al
  StoSb
  Lds	        Si,Result
  Mov	        Di,Si
  Push	        Di
 @4:
  LodSb
  Or	        Al,Al
  Je	       @6
  Cmp	        Al,'\'
  Je	       @6
  Cmp	        Al,'a'
  Jb	       @5
  Cmp	        Al,'z'
  Ja	       @5
 @5:
  StoSb
  Jmp	       @4
 @6:
  Cmp	        Word Ptr [Di-2],'.\'
  Jne	       @7
  Dec	        Di
  Dec	        Di
  Jmp	       @9
 @7:
  Cmp	        Word Ptr [Di-2],'..'
  Jne	       @9
  Cmp	        Byte Ptr [Di-3],'\'
  Jne	       @9
  Sub	        Di,3
  Cmp	        Byte Ptr [Di-1],':'
  Je	       @9
 @8:
  Dec	        Di
  Cmp	        Byte Ptr [Di],'\'
  Jne	       @8
 @9:
  Or	        Al,Al
  Jne	       @5
  Cmp	        Byte Ptr [Di-1],':'
  Jne	       @10
  Mov	        Al,'\'
  StoSb
 @10:
  Xor           Al,Al
  StoSb
  Pop           Di
  Pop	        Ds
End;

Function GetFileAttr(FileName: PChar): TByte; Assembler;
Asm
  Push          Ds
  Mov           Ax,7143h
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,4300h
 @Use95:
  Xor           Bl,Bl
  Lds           Dx,FileName
  Int           21h
  Pop           Ds
  Jnc          @OK
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
  Jmp          @End
 @OK:
  Mov           Ax,Cx
 @End:
End;

Procedure SetFileAttr(FileName: PChar; Attr: TByte); Assembler;
Asm
  Push          Ds
  Mov           Ax,7143h
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,4301h
 @Use95:
  Mov           Bl,01h
  Mov           Cl,Byte Ptr Attr
  Xor           Ch,Ch
  Lds           Dx,FileName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure TrueName(FileName,TrueFileName: PChar); Assembler;
Asm
  Push          Ds
  Mov           Ax,7160h
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,6000h
 @Use95:
  Mov           Cx,0002h
  Lds           Si,FileName
  Les           Di,TrueFileName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure ShortName(FileName,ShortFileName: PChar); Assembler;
Asm
  Push          Ds
  Cmp           Using95,True
  Jne          @End
  Mov           Ax,7160h
  Mov           Cx,0001h
  Lds           Si,FileName
  Les           Di,ShortFileName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure LongToShort(FileName,ShortFileName: PChar); Assembler;
Asm
  Cld
  Push          Ds
  Mov           Ax,71A8h
  Cmp           Using95,True
  Jne          @End
  Lds           Si,FileName
  Les           Di,ShortFileName
  Xor           Dx,Dx
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure Delete(FileName: PChar); Assembler;
Asm
  Push          Ds
  Mov           Ax,7141h
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,4100h
 @Use95:
  Lds           Dx,FileName
  Mov           Si,0001h
  Mov           Cl,Byte Ptr DeleteAttr
  Xor           Ch,Ch
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure Rename(FileName,NewName: PChar); Assembler;
Asm
  Push          Ds
  Mov           Ax,7156h
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,5600h
 @Use95:
  Lds           Dx,FileName
  Les           Di,NewName
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure Close(Handle: THandle); Assembler;
Asm
  Mov           Ah,3Eh
  Mov           Bx,Word Ptr Handle
  Int           21h
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure Truncate(Handle: THandle); Assembler;
Asm
  Push          Ds
  Mov           Ah,40h
  Mov           Bx,Word Ptr Handle
  Xor           Cx,Cx
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure Commit(Handle: THandle); Assembler;
Asm
  Mov           Ah,68h
  Mov           Bx,Word Ptr Handle
  Int           21h
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Function BlockRead(Handle: THandle; Var Buff; Count: TWord): TWord; Assembler;
Asm
  Push          Ds
  Mov           Ah,3Fh
  Mov           Bx,Word Ptr Handle
  Mov           Cx,Count
  Jcxz         @End
  Lds           Dx,Buff
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
 @End:
End;

Function BlockWrite(Handle: THandle; Var Buff; Count: TWord): TWord; Assembler;
Asm
  Push          Ds
  Mov           Ah,40h
  Mov           Bx,Word Ptr Handle
  Mov           Cx,Count
  Jcxz         @End
  Lds           Dx,Buff
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
 @End:
End;

Procedure LockDrive(Drive: TChar); Assembler;
Asm
  Mov           Ax,440Dh
  Mov           Cx,084Ah
  Mov           Bl,Drive
  Sub           Bl,'@'
  Mov           Bh,Byte Ptr LockLevel
  Mov           Dx,0000000000000001b
  Int           21h
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure UnlockDrive(Drive: TChar); Assembler;
Asm
  Mov           Ax,440Dh
  Mov           Cx,086Ah
  Mov           Bl,Drive
  Sub           Bl,'@'
  Int           21h
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure ChangeDrive(Drive: TChar); Assembler;
Asm
  Mov           Ah,0Eh
  Mov           Dl,Byte Ptr Drive
  Sub           Dl,'A'
  Int           21h
End;

Function CurrentDrive: TChar; Assembler;
Asm
  Mov           Ah,19h
  Int           21h
  Add           Al,'A'
End;

Procedure EnableDrive(Drive: TChar); Assembler;
Asm
  Mov           Ax,5F07h
  Mov           Dl,Byte Ptr Drive
  Sub           Dl,'A'
  Int           21h
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
 @End:
End;

Procedure DisableDrive(Drive: TChar); Assembler;
Asm
  Mov           Ax,5F08h
  Mov           Dl,Byte Ptr Drive
  Sub           Dl,'A'
  Int           21h
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
  Xor           Ax,Ax
 @End:
End;

Procedure FindFirst95(FileSpec: PChar; Attr: TByte; Var Search: TSearch95); Assembler;
Asm
  Push          Ds
  Mov           Ax,714Eh
  Xor           Si,Si
  Xor           Ch,Ch
  Mov           Cl,Attr
  Lds           Dx,FileSpec
  Les           Di,Search
  Inc           Di
  Inc           Di
  Int           21h
  Dec           Di
  Dec           Di
  StoSw
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure FindNext95(Var Search: TSearch95); Assembler;
Asm
  Push          Ds
  Lds           Si,Search
  LodSw
  Mov           Bx,Ax
  Mov           Ax,714Fh
  Xor           Si,Si
  Les           Di,Search
  Inc           Di
  Inc           Di
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure FindClose95(Var Search: TSearch95); Assembler;
Asm
  Push          Ds
  Lds           Si,Search
  LodSw
  Mov           Bx,Ax
  Mov           Ax,71A1h
  Int           21h
  Pop           Ds
  Jnc          @End
  Mov           flError,Ax
  Mov           isError,True
 @End:
End;

Procedure FindFirst(FileSpec: PChar; Attr: TWord; Var Search: TSearch); Assembler;
Asm
  Push          Ds
  Mov           Ah,4Eh
  Mov           Cx,Attr
  Lds           Dx,FileSpec
  Int           21h
  Jnc          @Transfer
  Mov           flError,Ax
  Mov           isError,True
  Jmp          @End
 @Transfer:
  Les           Si,DTA
  Push          Es
  Push          Si
  Les           Si,Search
  Push          Es
  Push          Si
  Push          43
  Call          Move32
 @End:
  Pop           Ds
End;

Procedure FindNext(Var Search: TSearch); Assembler;
Asm
  Push          Ds
  Les           Si,Search
  Push          Es
  Push          Si
  Les           Si,DTA
  Push          Es
  Push          Si
  Push          43
  Call          Move32
  Mov           Ah,4Fh
  Int           21h
  Jnc          @Transfer
  Mov           flError,Ax
  Mov           isError,True
  Jmp          @End
 @Transfer:
  Les           Si,DTA
  Push          Es
  Push          Si
  Les           Si,Search
  Push          Es
  Push          Si
  Push          43
  Call          Move32
 @End:
  Pop           Ds
End;

Procedure Halt(ErrorLevel: TByte); Assembler;
Asm
  Mov           Ah,4Ch
  Mov           Al,Byte Ptr ErrorLevel
  Int           21h
End;

Procedure Exec(Prog,Params: PChar); Assembler;
{For some reason, you need to add a space before the Params
 string. For example:

 To run:
   C:\COMMAND.COM /C DIR C:\
 The variables need to be like this:
   Prog:='C:\COMMAND.COM';
   Params:=' /C DIR C:\';   {Notice the space before the /C}

Var ShortFileName: PChar;
Asm
  Push          Ds
{Building ParameterBlock}
  Cld
  Les           Di,ParameterBlock
  Lds           Si,Params
  Inc           Di
  Inc           Di
  Mov           Ax,Si
  StoSw
  Mov           Ax,Ds
  StoSw
  Db            86h,0D0h,90h,86h,0C2h,86h,0C9h
  Pop           Ds
  Push          Ds
  Cmp           Using95,True
  Je           @Use95
  Lds           Dx,Prog
  Jmp          @OK
 @Use95:
{Getting short filename}
  Mov           Ax,7160h
  Mov           Cx,0001h
  Lds           Si,Prog
  Les           Di,ShortFileName
  Int           21h
  Lds           Dx,ShortFileName
  Jc           @End
{Executing}
 @OK:
  Les           Bx,ParameterBlock
  Mov           Ah,4Bh
  Xor           Al,Al
  Int           21h
 @End:
  Pop           Ds
End;

Procedure SetDTA(Address: Pointer); Assembler;
Asm
  Push          Ds
  Mov           Ah,1Ah
  Lds           Dx,Address
  Int           21h
  Pop           Ds
End;

Function GetDTA: Pointer; Assembler;
Asm
  Mov           Ah,2Fh
  Int           21h
  Mov           Dx,Es
  Mov           Ax,Bx
End;

Function DriveInformation(Drive: TChar; Var DriveType: TByte; Volume: TPointer; Var Serial,TotalSpace,FreeSpace,
                           ClusterSize: TDouble): TBoolean; Assembler;
Asm
  Push          Ds
  Mov           Ax,440Dh
  Mov           Bl,Drive
  Sub           Bl,64
  Mov           Cx,0860h
  Lds           Dx,ParameterBlock
  Int           21h
  Mov           Al,1
  Jnc          @Continue
  Xor           Al,Al
  Jmp          @Error
 @Continue:
  Mov           Si,Dx
  Inc           Si
  LodSb
  Les           Di,DriveType
  StoSb
  Pop           Ds
  Push          Ds
  Les           Di,ParameterBlock
  Xor           Ax,Ax
  StoSw
  Lds           Dx,ParameterBlock
  Mov           Ax,440Dh
  Mov           Bl,Drive
  Sub           Bl,64
  Mov           Cx,0866h
  Int           21h
  Mov           Si,Dx
  Inc           Si
  Inc           Si
  Les           Di,Serial
  Dw            0A566h
  Les           Di,Volume
  Dw            0A566h
  Dw            0A566h
  MovSw
  MovSb
  Mov           Ah,36h
  Mov           Dl,Drive
  Sub           Dl,64
  Int           21h
  Push          Dx
  Push          Ax
  Mul           Cx
  Les           Di,ClusterSize
  StoSw
  Mov           Ax,Dx
  StoSw
  Pop           Ax
  Push          Ax
  Mul           Cx
  Mul           Bx
  Les           Di,FreeSpace
  StoSw
  Mov           Ax,Dx
  StoSw
  Pop           Ax
  Pop           Dx
  Mov           Bx,Dx
  Mul           Cx
  Mul           Bx
  Les           Di,TotalSpace
  StoSw
  Mov           Ax,Dx
  StoSw
  Mov           Al,1
 @Error:
  Pop           Ds
End;

Function DiskFree(Drive: TChar): TDouble; Assembler;
Asm
  Mov           Ah,36h
  Mov           Dl,Drive
  Sub           Dl,64
  Int           21h
  Cmp           Ax,0FFFFh
  Je           @Error
  Mul           Cx
  Mul           Bx
  Jmp          @End
 @Error:
  Mov           Dx,Ax
 @End:
End;

Function DiskSize(Drive: TChar): TDouble; Assembler;
Asm
  Mov           Ah,36h
  Mov           Dl,Drive
  Sub           Dl,64
  Int           21h
  Cmp           Ax,0FFFFh
  Je           @Error
  Mul           Cx
  Mul           Dx
  Jmp          @End
 @Error:
  Mov           Dx,Ax
 @End:
End;

Procedure ResetDrive(Drive: TChar); Assembler;
Asm
  Mov           Ax,710Dh
  Cmp           Using95,True
  Je           @Use95
  Mov           Ax,0D00h
 @Use95:
  Mov           Cx,01h
  Xor           Dh,Dh
  Mov           Dl,Drive
  Sub           Dx,65
  Int           21h
End;

Procedure TurnLedOn(Drive: TChar); Assembler;
Asm
  Mov           Al,Drive
  Sub           Al,65
  Mov           Cl,Al
  Add           Cl,4
  Mov           Ah,1
  ShL           Ah,Cl
  Add           Al,Ah
  Add           Al,12
  Mov           Dx,03F2h
  Out           Dx,Al
End;

Procedure TurnLedOff(Drive: TChar); Assembler;
Asm
  Mov           Al,Drive
  Sub           Al,53
  Mov           Dx,03F2h
  Out           Dx,Al
End;


Begin
 CreateAttr:=faArchive;
 FindAttr:=faArchive Or faReadOnly;
 CopyAttr:=faArchive Or faReadOnly;
 DeleteAttr:=faArchive;
 FileMode:=fmReadWrite;
 FillChar(Block,40,$00);
 ParameterBlock:=@Block;
 LockLevel:=0;
 Using95:=(Task.OS=osWin95);
 DTA:=GetDTA;
End.

(* UMulti - multitasker support unit *)
(*        Compile this first         *)
(* UMulti - multitasker support unit *)
(*        Compile this first         *)
(* UMulti - multitasker support unit *)
(*        Compile this first         *)
(* UMulti - multitasker support unit *)
(*        Compile this first         *)
(* UMulti - multitasker support unit *)
(*        Compile this first         *)
(* UMulti - multitasker support unit *)
(*        Compile this first         *)
(* UMulti - multitasker support unit *)
(*        Compile this first         *)
(* UMulti - multitasker support unit *)
(*        Compile this first         *)
(* UMulti - multitasker support unit *)
(*        Compile this first         *)
(* UMulti - multitasker support unit *)
(*        Compile this first         *)

Unit UMulti;

Interface uses UGlobal;

Const Tasker: Array [0..10] Of String[9] = ('DOS','Windows ''95','Windows','OS/2','DesqView','TopView','DoubleDos',
                                            'NetWare','MultiLink','CSwitch','EuroDOS');

Const osDOS = 0;
      osWin95 = 1;
      osWindows = 2;
      osOS2 = 3;
      osDesqView = 4;
      osTopView = 5;
      osDoubleDos = 6;
      osNetWare = 7;
      osMultiLink = 8;
      osCSwitch = 9;
      osEuroDOS = 10;

Type TaskRec = Record
      OS: Word;
      Version: Word;
      Delay: Word;
     End;

Const Task: TaskRec = (OS: 0;
                       Version: 0;
                       Delay: 100);

{ Call  GiveTimeSlice  to release CPU cycles to the multitasker. }

{ Polling  could be use as procedure to be used inside ReadKey procedures
  to read the clock, update the screen, and release CPU cycles. Polling is
  at startup the same as GiveTimeSlice }

Var GiveTimeSlice,
    Polling: TProc;

{ AssignProcs  is called automatically by the startup procedure Init }
Procedure AssignProcs;

{ ReleaseTime is a macro procedure which takes only 7 bytes, and releases
  DOS, Windows, Windows '95, and OS/2 timeslices }
Procedure ReleaseTime; Inline($CD/$28/$B8/$80/$16/$CD/$2F);

Implementation

{$F+}
Procedure NetWare_GTS; Assembler;
Asm
  Mov           Bx,000Ah
  Int           7Ah
End;

Procedure DoubleDOS_GTS; Assembler;
Asm
  Mov           Ax,0EE02h
  Int           21h
End;

Procedure Windows_Win95_OS2_GTS; Assembler;
Asm
  Mov           Ax,1680h
  Int           2Fh
End;

Procedure DesqView_TopView_GTS; Assembler;
Asm
  Mov           Ax,1000h
  Int           15h
End;

Procedure DOS_GTS; Assembler;
Asm
  Int           28h
End;

Procedure MultiLink_GTS; Assembler;
Asm
  Mov           Ah,02h
  Int           7Fh
End;

Procedure CSwitch_GTS; Assembler;
Asm
  Mov           Ah,01h
  Int           62h
End;

Procedure EuroDOS_GTS; Assembler;
Asm
  Mov           Ah,89h
  Xor           Cx,Cx
  Int           21h
End;
{$F-}

Procedure AssignProcs;
Begin
 Case Task.OS Of
  osDos: GiveTimeSlice:=DOS_GTS;
  osWin95: GiveTimeSlice:=Windows_Win95_OS2_GTS;
  osWindows: GiveTimeSlice:=Windows_Win95_OS2_GTS;
  osOS2: GiveTimeSlice:=Windows_Win95_OS2_GTS;
  osDesqView: GiveTimeSlice:=DesqView_TopView_GTS;
  osTopView: GiveTimeSlice:=DesqView_TopView_GTS;
  osDoubleDos: GiveTimeSlice:=DoubleDOS_GTS;
  osNetWare: GiveTimeSlice:=NetWare_GTS;
  osMultiLink: GiveTimeSlice:=MultiLink_GTS;
  osCSwitch: GiveTimeSlice:=CSwitch_GTS;
  osEuroDOS: GiveTimeSlice:=EuroDOS_GTS;
 End;
End;

Procedure Init; Assembler;
Asm
  Mov           Task.OS,00h
  Mov           Task.Version,00h
  Mov           Ah,87h
  Xor           Al,Al
  Int           21h
  Cmp           Al,0
  Jne          @EuroDOS
  Mov           Ah,30h
  Mov           Al,01h
  Int           21h
  Cmp           Al,14h
  Je           @OS2
  Mov           Ax,160Ah
  Int           2Fh
  Cmp           Ax,00h
  Je           @Windows
  Mov           Ax,1022h
  Mov           Bx,0000h
  Int           15h
  Cmp           Bx,00h
  Jne          @DesqView
  Mov           Ah,2Bh
  Mov           Al,01h
  Mov           Cx,4445h
  Mov           Dx,5351h
  Int           21h
  Cmp           Al,0FFh
  Jne          @TopView
  Mov           Ax,0E400h
  Int           21h
  Cmp           Al,00h
  Jne          @DoubleDos
  Mov           Ax,7A00h
  Int           2Fh
  Cmp           Al,0FFh
  Je           @NetWare
  Jmp          @End
 @Windows:
  Cmp           Bh,04h
  Jne          @Win3
  Mov           Task.OS,01h
  Jmp          @Windows_OK
 @Win3:
  Mov           Task.OS,02h
 @Windows_OK:
  Mov           Task.Version,Bx
  Jmp          @End
 @OS2:
  Mov           Task.OS,03h
  Mov           Bh,Ah
  Xor           Ah,Ah
  Mov           Cl,0Ah
  Div           Cl
  Mov           Ah,Bh
  XChg          Ah,Al
  Mov           Task.Version,Ax
  Jmp          @End
 @DesqView:
  Mov           Task.OS,04h
  Jmp          @End
 @TopView:
  Mov           Task.OS,05h
  Jmp          @End
 @DoubleDos:
  Mov           Task.OS,06h
  Jmp          @End
 @NetWare:
  Mov           Task.OS,07h
  Jmp          @End
 @MultiLink:
  Mov           Task.OS,08h
  Jmp          @End
 @CSwitch:
  Mov           Task.OS,09h
  Jmp          @End
 @EuroDOS:
  Mov           Task.OS,10h
 @End:
  Call          AssignProcs
End;

Begin
 Init;
 Polling:=GiveTimeSlice;
End.