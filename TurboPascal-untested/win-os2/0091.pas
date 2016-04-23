{ Daniel J. Wojcik  Brute Force Programming/The Mindless Entertainment Group
	wojcik@satcom.kaiserslautern.army.mil & http://147.35.241.5/mindless/bfp.htm

  The other Windows file-copying routines all use blockread/write.  Why?
  Windows comes with a file copying routine in VER.DLL with access through
	Borland's VER.TPW and it does more than just copy.
	This is written as a Unit, but no reason in the world not to use VerInstallFile
	by itself if you set up the parameters correctly in your program.}

Unit WinCopy;

interface

uses Ver, Strings, WinDos;

FUNCTION WindowsFileCopy(Src, Dest : PChar) : LongInt;

implementation
{******************************************************************************
 Function to copy files within Windows.
 It can also rename the file while copying.
 As written, it will copy the file, overwriting an existing file unless the
 existing file is readonly.
 It will also expand the file if it was compressed using COMPRESS.EXE (like a
 normal Windows-type installation, i.e. TWEEDLE.EX_ -> TWEEDLE.EXE)
 The return value can be a number of different things depending on the results
 of the copy.  Check out VerInstallFile in TPW Help for details.
 The VIFF_FORCEINSTALL & VIFF_DONTDELETEOLD can be changed for different
 situations.  Again, check out TPW Help.
 The Functions LZCopy and CopyLZFile do the same things, but use file handles
 instead of file names.  I think this is easier.
 ******************************************************************************}

FUNCTION WindowsFileCopy(Src, Dest : PChar) : LongInt;
VAR
  SDir,
	DDir		: array[0..fsDirectory] of Char; {source & dest dir with drive letter}
	SName,
	DName		: array[0..fsFileName] of Char;  {file name without extension}
  SExt,
	DExt		: array[0..fsExtension] of Char; {extension}
  SFile,
  DFile		: array[0..12] of Char; {name + extension}
	TmpFile     : array[0..fsPathName] of char;
	TmpFileLen 	: Word;
Begin
  FileSplit(Src, SDir, SName, SExt);  {get the parts of the original file}
  FileSplit(Dest, DDir, DName, DExt); {get the parts of the file to copy}
  StrCopy(SFile,SName); {put the name & extension back together}
  StrCat(SFile,SExt);
  StrCopy(DFile,DName); {put the name & extension back together}
  StrCat(DFile,DExt);

	WindowsFileCopy := VerInstallFile(VIFF_FORCEINSTALL+VIFF_DONTDELETEOLD,
																		SFile,DFile,SDir,DDir,SDir,TmpFile,TmpFileLen);
End;

End.


{ --------------------  demo --------------------------- }


{Stupid demo program.  Copies its source code to another filename.  Everything
 must be in the same directory to work.  Don't blink.}

{$A+,B-,D+,F-,G+,I+,K+,L+,N-,P-,Q+,R+,S+,T-,V-,W-,X+,Y+}
{$M 1024,0}
program CopyTest;

uses WinCopy,WinTypes,WinProcs,OWindows,Strings,WinDOS;

CONST
  cm_Start	= 101;

TYPE
  CopyTestApp = object(TApplication)
		PROCEDURE InitMainWindow; virtual;
  End;

	PCopyWindow = ^CopyWindow;
	CopyWindow = object(TWindow)
		CONSTRUCTOR Init(AParent: PWindowsObject; ATitle: PChar);
    PROCEDURE SetupWindow; virtual;
    PROCEDURE CMStart(VAR Msg : TMessage);
    	virtual cm_First + cm_Start;
	End;

PROCEDURE CopyWIndow.SetupWindow;
VAR
	Mess : TMessage;
Begin
	inherited SetupWindow;
  CMStart(Mess);
End;

PROCEDURE CopyWindow.CMStart(VAR Msg : TMessage);
VAR
	SrcDir,
	DstDir	: array[0..fsDirectory] of Char;
	FileName	: array[0..79] of char;
Begin
	GetCurDir(SrcDir, 0);
  StrCopy(DstDir,SrcDir);
  WindowsFileCopy(StrCat(SrcDir,'\COPYWIN.PAS'),StrCat(DstDir,'\THECOPY.PAS'));
  MessageBox(0, 'Done', 'Done!', mb_ApplModal or mb_IconExclamation or mb_Ok);
	PostQuitMessage(0);
End;

PROCEDURE CopyTestApp.InitMainWindow;
Begin
	MainWindow := New(PCopyWindow,Init(nil,'Windows File Copy'));
End;

CONSTRUCTOR CopyWindow.Init(AParent: PWindowsObject; ATitle: PChar);
Begin
  TWindow.Init(AParent,ATitle);
End;

VAR
	CopyApp : CopyTestApp;

Begin
  CopyApp.Init('Windows Copy');
  CopyApp.Run;
  CopyApp.Done
End.