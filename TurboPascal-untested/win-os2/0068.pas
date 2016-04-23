

(* This is a program that should ensure only 1 copy of a dos program *)
(* will be able to run under windows.                                *)
(* There are 2 options                                               *)
(* - = add a startup directory                                       *)
(* @ = Look for an alternate window title                            *)
(* you may look at the help below                                    *)

{$I-}

Uses
  Strings,
  WinProcs,
  WinTypes;

Const
  ExeError: Array[0..21] of PChar =
  ('System was out of memory, executable file was corrupt, or relocations were invalid.'+
   '  or you may be trying to run a com file without adding .com'#13'Example - EDIT.COM',
   '',
   'File was not found.',
   'Path was not found.',
   '',
   'Attempt was made to dynamically link to a task, or there was a sharing or network-protection error.',
   'Library required separate data segments for each task.',
   '',
   'There was insufficient memory to start the application.',
   '',
   'Windows version was incorrect.',
   'Executable file was invalid. Either it was not a Windows application or there was an error in the .EXE image.',
   'Application was designed for a different operating system.',
   'Application was designed for MS-DOS 4.0.',
   'Type of executable file was unknown.',
   'Attempt was made to load a real-mode application (developed for an earlier version of Windows).',
   'Attempt was made to load a second instance of an executable file containing multiple data segments that were '+
   'not marked read-only.',
   '',
   '',
   'Attempt was made to load a compressed executable file. The file must be decompressed before it can be loaded.',
   'Dynamic-link library (DLL) file was invalid. One of the DLLs required to run this application was corrupt.',
   'Application requires 32-bit extensions.');


Const
  DosError: Array[2..11] of PChar =
  ('File not found','Path not found','','Access denied','Invalid handle',
   '','Not enough memory','','Invalid environment','Invalid format');

Var
  Path       : String;      (* Path and program name of program to run - from the command line *)
  StartupDir : String;      (* Directory information removed from the above *)
  WindowTitle : String[20];  (* Name of the DOS window - appears in the title bar *)


Function Trim(S: String): String;
Begin
  While Copy(S,1,1) = ' ' Do
    Delete(S,1,1);
  Trim := S;
End;

Function GetToken(Var S: String;Marker: Char): String;
Var
  P : Integer;
Begin
  P := Pos(Marker,S);
  If P = 0 Then
    P := Length(S);
  GetToken := Copy(S,1,P-1);
  Delete(S,1,P);
  S := Trim(S);
End;

Procedure DispParams;
Var
  Msg: String;
Begin
  Msg := 'Path        :'+Path+#13+
         'Start Dir   :'+StartupDir+#13+
         'WindowTitle :'+WindowTitle;
  While pos(#0,Msg) > 0 Do
    Delete(Msg,pos(#0,Msg),1);
  Msg := Msg +#0;

  MessageBox(0,@Msg[1],'Program Start Information',mb_OK);
End;

Procedure SayErrorHalt(Msg: String);
Begin
  Msg := Msg+#0;
  If MessageBox(0,@Msg[1],'Program Start Error',mb_OKCancel) = id_OK then
    DispParams;
  Halt;
End;

Procedure SayDOSErrorHalt(Err: Integer;Msg: String);
Var
  ErrStr: String[10];  (* Used when there is an execute error *)
Begin
  Str(Err,ErrStr);

  Msg := StrPas(DosError[Err])+#13+'Error: '+ErrStr+' '+Msg+#0;
  If MessageBox(0,@Msg[1],'Program Start Error',mb_OKCancel) = id_OK then
    DispParams;
  Halt;
End;

Procedure SayExeErrorHalt(Err: Integer;Msg: String);
Var
  ErrStr: String[10];  (* Used when there is an execute error *)
Begin
  Str(Err,ErrStr);

  Msg := StrPas(EXEError[Err])+#13+'Error: '+ErrStr+' '+Msg+#0;
  If MessageBox(0,@Msg[1],'Program Start Error',mb_OKCancel) = id_OK Then
    DispParams;
  Halt;
End;

Var
  InstanceID : THandle;     (* Handle to the executed program - Just used here to check for errors *)
  Wnd        : hWnd;        (* Handle to the window of the program *)
  iStart     : Integer;     (* Used in finding the above *)
  iEnd       : Integer;
  CmdPos     : Integer;     (* Position of the program to execute in the system.CmdLine *)
  Result     : Integer;     (* Check for IO errors *)
Begin
  Path := Trim(StrPas(CmdLine));

  (* If any one tries this with a windows program *)
  If (pos(Copy(Path,1,1),'?') > 0) or (Path = '') Then
    Begin
      If MessageBox(0,'ONEEXE is a program that will ensure'#13+
                   'that only one copy of a DOS program'#13+
                   'is active on a machine.  If the DOS'#13+
                   'program is already running ONEEXE will'#13+
                   'call up the previous copy, if not it will'#13+
                   'start the program.'#13+
                   'PRESS ENTER FOR EXAMPLES',
                   'Program Info',
                   mb_OKCancel) = id_OK Then

      MessageBox(0,'Usage:'+#13+
                   '  EXEONE [@"window name"] [-startup directory] filename'+#13+
                   'Examples:'+#13+
                   '  EXEONE COMMAND.COM'+#13+
                   '  EXEONE -C:\PASFILE D:\BP\BIN\BP.EXE'+#13+
                   '  ^ERR - title change'#13+
                   '  EXEONE @"BORLAND PASCAL 7.0" -C:\PASFILE bp.exe'#13+
                   '  ^works'#13+
                   '  EXEONE C:\DATA G:\PROGS\CONTACT.EXE',
                   'Program Example Info',
                   mb_OK);
      Halt;
    End;

  (* Set the defaults for no startup directory *)
  WindowTitle := '';  (* Flag no window name specified *)

  (* See if there is a startup directory *)

  While Pos(Copy(Path,1,1),'-@') > 0 Do
    Begin
      If Copy(Path,1,1) = '-' Then
        Begin
          Delete(Path,1,1); (* Remove the '-' signature *)
          StartupDir := GetToken(Path,' ');

          (* Clean the path of extra "|" *)
          While (Length(StartupDir) > 0) and (Pos(StartupDir[Length(StartupDir)],'\ ') > 0) Do
            Delete(StartupDir,Length(StartupDir),1);
          ChDir(StartupDir);
          Result := IoResult;
          If Result <> 0 Then
            SayDOSErrorHalt(Result,'changing directories '+#13+StartupDir);
        End;

        (* Window name change - BP needs this *)
      If Copy(Path,1,1) = '@' Then
        Begin
          Delete(Path,1,1); (* Remove the '-' signature *)
          If Copy(Path,1,1) = '"' Then
            Begin
              Delete(Path,1,1); (* Remove the '"' part *)
              WindowTitle := GetToken(Path,'"');
            End
          Else
            WindowTitle := GetToken(Path,' ');
        End;
    End;

  (* Get Window Name - If the program is able to change it's name then this will not work *)
  (* Sorry - The only way to make it work would be to add an name change option *)
  If WindowTitle = '' Then
    Begin
      iStart := Length(Path);
      While (iStart > 0) and (Path[iStart] <> '\') Do
        Dec(iStart);
      Inc(iStart);
      iEnd := Pos('.',Path);
      If iEnd = 0 Then
        iEnd := Length(Path)
      Else
        Dec(iEnd);
      (* Add #0 so these may work as params to windows API *)
      WindowTitle := Copy(Path,iStart,iEnd-iStart+1)+#0;
    End;

  If Path = '' Then
    SayErrorHalt('There is no program path.'#13+
                 'Check for accuracy of your'#13+
                 'commad line.');

  Path := Path + #0;  (* Set it up for passing the the API *)
  (* Check for existing dos window *)
  Wnd := FindWindow('tty',@WindowTitle[1]);
  If Wnd = 0 Then  (* If it is not running *)
    Begin          (* Start it *)
      InstanceID := WinExec(@Path[1],sw_ShowNormal);
      If InstanceID < 32 Then
        SayEXEErrorHalt(Result,'running program '+#13+Path);
    End
  Else
    Begin
      BringWindowToTop(Wnd);       (* Bring it to the top *)
      ShowWindow(Wnd,sw_Restore);  (* And Restore it *)
    End;
End.

