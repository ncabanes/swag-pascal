
Function to Test for the accessibility of a drive (its existence as well as
the presence of a disc in a drive) until the user choose to abort or
correct the problem.

The function (TestDrive) is included in this small demo program.


The function can be easily improved for example by using GetDriveType to
distinguish between Non-exitsent drives and Floppy disc drives with
no disc in them.


Coded for use with Borland Pascal 7.0 on a Windows 3.1 program.


>From : Dr D. Tetard, France, E-Mail : PandemoniumSoft@Earthling.Net


Program DrivePresent;

Uses Wincrt, Win31, WinProcs, WinTypes, Strings, WinDos;

Var
   Dr : Array[0..1] of Char;

Function TestDrive(Drive : PChar) : Integer;

{ This function test for the presence of the drive whose letter is
'Drive'. If it's present

 (and a disc is in the drive), the function return 0. If it's not present
(for example,

  no disc in the drive or drive not present), the function ask to retry
and test again until

 the drive is found (for example the user has inserted a disc in the
drive)(return 0) or the

 user choose to abort (return IDNO). }

Var
   F : TSearchRec;
   Txt : Array[0..255] of Char;
   OldError : Word;
   Rep : Integer;
   Error : Integer;
Begin
     Rep := 0;
     Repeat
          StrCopy(Txt, Drive); StrCat(Txt, ':\*.*');
	  OldError := SetErrorMode(SEM_FailCriticalErrors);
	  { Trap MS-DOS errors to avoid default handling of error messages }
	  FindFirst(Txt, faAnyFile, F);
	  { Test for the accessibility searching for 'X:\*.*' (any file) }
	  SetErrorMode(OldError);
	  { Restore old Error mode }
          Error := DosError;
	  { If DosError <> 0, the drive is not accessible, so ask for another
test or abortion. }

          If Error <> 0 then
          Begin
               StrCopy(Txt, 'Cannot find drive '); StrCat(Txt, Drive);
               StrCat(Txt, ':'#10#13'Retry test of drive ?');
               Rep := MessageBox(GetFocus, Txt, 'Watcher - Error', mb_YESNO or mb_IconQuestion);
          End;
     Until (Error = 0) or (Rep = IDNO);
     TestDrive := Rep;
End;


Begin
     Write('Choose a drive to test : ');
     Readln(Dr);
     If TestDrive(Dr) = IDNO then Writeln('Abort operation.')
     Else writeln('Drive/Disc present.');
End.



