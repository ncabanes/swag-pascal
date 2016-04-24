(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0041.PAS
  Description: Deletes Subdirs and files
  Author: SHANE KERR
  Date: 02-28-95  10:04
*)

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  NUKE.PAS by Shane Kerr                                               *
 *        Deletes a subdirectory and everything it contains.             *
 *        Nuke for DOS written Turbo Pascal 5.5                          *
 *        Nuke for Windows written using Turbo Pascal for Windows 1.0    *
 *  Version 1.95    November 23, 1991                                    *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

program Nuke;

uses
{$IFDEF MsDos}
	DOS;
{$ENDIF}
{$IFDEF Windows}
    WinCRT, WinDOS, Strings;
{$ENDIF}

const
    MajorVer = '1';                     { Current major version number }
    MinorVer = '95';                    { Current minor version number }
    Year     = 1991;                    { Release year }

{$IFDEF MsDos}
    fsDirectory = 64;                   { Set directory length }
    faReadOnly = ReadOnly;              { Set directory flags }
    faHidden = Hidden;
    faSysFile = SysFile;
    faVolumeID = VolumeID;
    faDirectory = Directory;
    faArchive = Archive;
    faAnyFile = AnyFile;
{$ENDIF}

{$IFDEF MsDos}
type
	TRegisters = Registers;				{ Used for DOS calls }
    TSearchRec = SearchRec;             { Used for search record }
{$ENDIF}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  procedure FCBDeleteFile (FileSpec : string);
 *        Deletes files using the MS-DOS FCB function (from Version 1.0).
 *  parameters:  filespec, file(s) to be deleted
 *  notes:  Can only delete files in the current directory.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

procedure FCBDeleteFile (filespec : string);
type
    TFCB = record
        drive : char;  	                { 0 = default, 1 = A, 2 = B }
        name : array[0..7] of char;     { File name }
        ext : array[0..2] of char;      { File extension }
        curblk : word;                  { Current block number }
        recsize : word;                 { Logical record size in bytes }
        filsize : longint;              { File size in bytes }
        date : word;                    { Date file was last written }
        resv : array[0..10] of byte;    { Reserved for DOS }
        currec : byte;                  { Current record in block }
        random : longint;               { Random record number }
    end;
var
    FCB : TFCB;
    Regs : TRegisters;
    TempStr : string;
    NameSeg, NameOfs : word;
    FCBSeg, FCBOfs : word;
begin
  { Get segment and offset of the filespec }
    TempStr := filespec + chr(0);
    NameSeg := seg(TempStr);
    NameOfs := ofs(TempStr) + 1;
    FCBSeg := seg(FCB);
    FCBOfs := ofs(FCB);
  { Do the actual DOS calls }
    Regs.AX := $2900;
    Regs.DS := NameSeg;
    Regs.SI := NameOfs;
    Regs.ES := FCBSeg;
    Regs.DI := FCBOfs;
    MsDos(Regs);                        { Parse file to FCB }
    Regs.DS := FCBSeg;
    Regs.DX := FCBOfs;
    Regs.AH := $13;
    MsDos(Regs);                        { Delete file (FCB) }
end; { FCBDeleteFile }

{$IFDEF MsDos}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  procedure ClearKb
 *        Clears the keyboard buffer
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

procedure ClearKb;
var
    Regs : TRegisters;
begin
    Regs.AH := $01;
    Intr($16, Regs);
    while ((Regs.Flags and FZero) = 0) do
      begin
        Regs.AH := $00;
        Intr($16, Regs);
        Regs.AH := $01;
        Intr($16, Regs);
      end;
end; { procedure ClearKb }
{$ENDIF}

{$IFDEF MsDos}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  procedure WaitKey
 *        Waits for a key press
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

procedure WaitKey;
var
    Regs : TRegisters;
begin
	Regs.AH := $00;
    Intr($16, Regs);
end; { procedure WaitKey }
{$ENDIF}

{$IFDEF MsDos}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  function IsRedirected : boolean;
 *        Determines whether a program's input or output is redirected
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

function IsRedirected : boolean;
var
	Regs : Registers;				{ Register values }
	StdIn : ^Byte;					{ Standard input }
	StdOut : ^Byte;					{ Standard output }
begin
	Regs.AH := $62;					{ Get segment address of PSP }
	MsDos(Regs);
	StdIn := Ptr(Regs.BX, $18);		{ Point to StdIn value }
	StdOut := Ptr(Regs.BX, $19); 	{ Point to StdOut value }

  { Return TRUE if StdIn is the same as StdOut }
    IsRedirected := (StdIn^ <> StdOut^);
end;
{$ENDIF}

{$IFDEF MsDos}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  function NumRows : byte;
 *        Returns the number of rows on the screen
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

function NumRows : byte;
var
	ScreenWidth : word absolute $0040:$004A;
	ScreenSize : word absolute $0040:$004C;
begin
	NumRows := (((ScreenSize div 1000) * 1000) div 2) div ScreenWidth;
end;
{$ENDIF}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  function NukeDir (directory : string) : boolean;                     *
 *  	Destroys the specified directory and all it contains recursively *
 *  parameters:  directory, path of the directory to be destroyed        *
 *               remove, TRUE to remove directory                        *
 *				 display, TRUE to display files as they are deleted      *
 *				 pause, TRUE to pause after each screen                  *
 *               attr, file search attributes to delete                  *
 *				 lines, number of lines displayed so far 			     *
 *  returns:  TRUE if directory is removed, FALSE otherwise              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function NukeDir (directory : string; remove, display, pause : boolean;
					attrib : word; var lines : word) : boolean;
var
    OrgDir : string[fsDirectory];       { Saved original directory }
	SrchRec : TSearchRec;	        	{ For file searches }
    Dummy : boolean;
    Handle : file;                      { File handle (for attrib change) }
begin
	GetDir(0, OrgDir);   	        	{ Get original directory }

	ChDir(directory);                   { Change to target directory }
  { If display isn't on, just delete everything (grumble) }
	if (not display) then
		FCBDeleteFile('????????.???');  { Delete all files }

  { Find first file present }
    FindFirst('*.*', faDirectory or attrib, SrchRec);

  { Loop and nuke any subdirectories found }
    repeat
        if (((SrchRec.Attr and faDirectory) <> 0) and (DosError = 0) and
{$IFDEF MsDos}
                    (SrchRec.Name[1] <> '.')) then
{$ENDIF}
{$IFDEF Windows}
                    (SrchRec.Name[0] <> '.')) then
{$ENDIF}
          begin
            Assign(Handle, SrchRec.Name);
            SetFAttr(Handle, faDirectory);
			Dummy := NukeDir(SrchRec.Name, TRUE, Display, Pause, Attrib, Lines);
          end
        else if ((DosError = 0) and
{$IFDEF MsDos}
					(SrchRec.Name[1] <> '.') and
{$ENDIF}
{$IFDEF Windows}
					(SrchRec.Name[0] <> '.') and
{$ENDIF}
			(((SrchRec.Attr and Attrib) <> 0) or (Attrib = 0))) then
          begin
            Assign(Handle, SrchRec.Name);
            SetFAttr(Handle, 0);
			Erase(Handle);
		  { If displaying, then show name and increase line count }
			if (Display) then
			  begin
				WriteLn('     Deleting  ', Directory, '\', SrchRec.Name);
				Inc(Lines);
			  end;
		  { If pausing, check line count }
			if (Pause and ((Lines mod (NumRows - 2)) = 0)) then
			  begin
				Write('Press any key to continue...');
				WaitKey;
				WriteLn;
			  end;
          end; { if block }
        FindNext(SrchRec);
    until (DosError <> 0);

  { If original directory is current, change to parent }
	if (OrgDir = Directory) then
		ChDir('..')
	else if (pos(Directory, OrgDir) = 1) then
	  begin
		ChDir(Directory);
		ChDir('..');
	  end
	else
		ChDir(OrgDir);                  { Restore directory }
    NukeDir := FALSE;
    if (Remove) then
      begin
        {$I-}
		RmDir(Directory);	        	{ Kill target directory }
        if (IOResult = 0) then
            NukeDir := TRUE;
        {$I+}
      end;
end; { function NukeDir }

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  function ToUpper (Str : string) : string;                            *
 *      Convert string to upper case                                     *
 *  parameters:  Str, any string                                         *
 *  returns:  uppercase value of the string                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

function ToUpper (Str : string) : string;
var
    i : integer;
    Temp : string;
begin
    Temp := str;
    for i := 1 to length(Str) do
        Temp[i] := UpCase(Temp[i]);
    ToUpper := Temp;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  function ListFiles (directory : string) : integer                    *
 *      Lists files and attributes in the specified directory below      *
 *  parameters:  directory, directory to start listing at                *
 *  returns:  number of files listed                                     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

function ListFiles (directory : string) : integer;
var
    OrgDir : string;	                { Original directory }
    CurDir : string;                    { Current directory }
    SearchRec : TSearchRec;             { Used to find filespecs }
    NumListed : Integer;                { Number of files listed }
    Attr: word;                         { Attributes to remove }
begin
    NumListed := 0;                     { Number of files listed }
	GetDir(0, OrgDir);	        		{ Get original directory }

    ChDir(directory);                   { Change to target directory }
	GetDir(0, CurDir);					{ Get current directory }

  { Find first directory present }
    FindFirst('*.*', faDirectory or faReadOnly or faHidden or faSysFile,
        SearchRec);
    FindNext(SearchRec);
    FindNext(SearchRec);

  { Loop and list any files found }
    repeat
        if ((DosError = 0) and ((SearchRec.Attr and faDirectory) <> 0)) then
          begin
            NumListed := NumListed + ListFiles(SearchRec.Name);
          end;
        if (DosError = 0) then
          begin
            NumListed := NumListed + 1;
            Write('     ', CurDir, '\', SearchRec.Name);
            if ((SearchRec.Attr and faDirectory) <> 0) then
                Write(', directory');
            if ((SearchRec.Attr and faReadOnly) <> 0) then
                Write(', read-only');
            if ((SearchRec.Attr and faHidden) <> 0) then
                Write(', hidden');
            if ((SearchRec.Attr and faSysFile) <> 0) then
                Write(', system');
            WriteLn;
          end; { if }
        FindNext(SearchRec);
    until (DosError <> 0);

    ChDir(OrgDir);                      { Restore directory }
    ListFiles := NumListed;             { Return number of files listed }
end;  { procedure ListFiles }


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  function HasSwitch (switch : string) : boolean                       *
 *      Checks the command-line arguements for the specified switch      *
 *  parameters:  switch, the switch to search for                        *
 *  returns:  TRUE if found, else FALSE                                  *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

function HasSwitch (switch : char) : boolean;
var
    i : integer;                        { Index variable }
begin
    HasSwitch := FALSE;
    for i := 1 to ParamCount-1 do
      begin
        if (Pos(UpCase(switch), ToUpper(ParamStr(i))) <> 0) then
          begin
            HasSwitch := TRUE;
            Exit;
          end; { if }
      end; { for }
end; { function HasSwitch }

var { main variables }
    UserInput : string[fsDirectory];	{ user response }
	Answer : string;  					{ user response }
    OrgDir : string[fsDirectory];       { Original directory }
    Target : string[fsDirectory];       { Directory to nuke }
    Remove : boolean;                   { If directory actually removed }
	Result : boolean;                   { Result of nuking }
	LinesShown : word;					{ Number of lines shown so far }
    Attrib : word;                      { File attributes to delete }

begin { main program }
  { Print greeting }
    WriteLn('NUKE Directory  ', MajorVer, '.', MinorVer);
    WriteLn('    (C)', Year, ' by Kerr');
    WriteLn;

  { Check for DOS help command }
    if ((ParamCount < 1) or HasSwitch('?') or (Pos('?', ParamStr(1)) <> 0)) then
      begin
        Write('Removes a subdirectory, along with the files and ');
        WriteLn('subdirectories is contains');
        WriteLn;
        WriteLn('NUKE [options] [directory]');
        WriteLn;
        WriteLn('Options are as follows:');
		WriteLn('  K      Keeps the subdirectory after clearing out files.');
		WriteLn('  H      Deletes hidden files.');
		WriteLn('  R      Deletes read-only files.');
		WriteLn('  S      Deletes system files.');
		WriteLn('  A      Deletes files of all attributes.');
        WriteLn('  Y      No verification before NUKEing - dangerous!');
		Write  ('  V      Verbose, displays files and subdirectories they ');
		WriteLn('are removed - SLOW!');
		WriteLn('  P      Pause after each screen.');
        WriteLn;
        WriteLn('You cannot nuke the root directory.');
        WriteLn('Nuke will not Pause if you redirect the input or output.');
        Exit;
	  end;

  { Set number of lines displayed }
	LinesShown := 0;

  { Check for /K switch }
    Remove := not HasSwitch('K');

    Attrib := 0;

  { Check for /H switch }
    if (HasSwitch('H')) then
        Attrib := Attrib or faHidden;
  { Check for /R switch }
    if (HasSwitch('R')) then
        Attrib := Attrib or faReadOnly;
  { Check for /S switch }
    if (HasSwitch('S')) then
        Attrib := Attrib or faSysFile;
  { Check for /A switch }
    if (HasSwitch('A')) then
        if (Attrib <> 0) then
          begin
            WriteLn('Cannot use the /A switch with other attribute switches.');
            Exit;
          end
        else
            Attrib := faAnyFile;

{$IFDEF MsDos}
    UserInput := ParamStr(ParamCount);
{$ENDIF}
{$IFDEF Windows}
    Write('Input directory to remove:  ');
    ReadLn(UserInput);
{$ENDIF}

  { Save directory and drive and try to change to new directory }
    GetDir(0, OrgDir);

    {$I-}
    ChDir(UserInput);
    if (IOResult <> 0) then
      begin
        WriteLn('   Specified directory not found!');
        ChDir(OrgDir);
        Exit;
      end;
    {$I+}

	GetDir(0, Target);					{ Get new directory }

  { Display target directory and change back from it }
    WriteLn(' Target is ', Target);
	WriteLn;

	ChDir(OrgDir);                      { Restore directory }

  { Exit if root directory being nuked }
    if (length(Target) = 3) then
      begin
        WriteLn('You cannot NUKE the root directory!');
        WriteLn('  (Try FORMAT...)');
        Exit;
      end;


  { Double check before DECIMATING directory }
	if (not HasSwitch('Y')) then
	  begin
		WriteLn(' Are you SURE you want to OBLITERATE this directory and');
		Write('  everything in or under it?!?!? (Y/N) ');
{$IFDEF MsDos}
		ClearKb;
{$ENDIF}
		ReadLn(Answer);
		Answer := ToUpper(Answer);
	  end;

  { If 'yes' or 'y' entered, or 'Y' SWITCH set, nuke that puppy }
	if ((answer = 'YES') or (answer = 'Y') or HasSwitch('Y'))  then
      begin
        WriteLn(' Beginning now...');
		Result := NukeDir(Target, Remove, HasSwitch('V'),
				HasSwitch('P') and (not IsRedirected), Attrib, LinesShown);
        WriteLn('  ...may the diety of your choice have mercy on your soul.');
      end { if }
    else
      begin
        Result := FALSE;
        WriteLn(' Nothing done.');
        Exit;
      end; { else }

  { List files not deleted }
    if (not Result) then
      begin
        WriteLn;
      { Display a message if the directory was SUPPOSED to be removed }
        if (Remove) then
          begin
            WriteLn('  NUKE failed to remove the directory.');
          end
        else
          begin
            WriteLn('  NUKE has kept the directory.');
          end;
        WriteLn(' The following files or directories remain in it:');
        if (ListFiles(Target) = 0) then
            WriteLn('    None');
      { Display helpful hint if the directory was SUPPOSED to be removed }
        if (Remove) then
          begin
            WriteLn;
            Write('If you wish to remove these files, try the ');
            WriteLn('/H, /R, and /S options,');
            WriteLn('  or the /A option.');
          end;
      end; { if }
end. { main }

