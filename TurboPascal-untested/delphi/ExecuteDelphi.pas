(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0092.PAS
  Description: Execute DELPHI
  Author: JASPER STIL
  Date: 02-21-96  21:03
*)


program ExDelphi;
 {executes Delphi, minimizing all apps currently running}
uses
 WinProcs, WinTypes, Messages;
var
 ExResult: integer;
 ExResultSt: string;
 
 function EnumProc (WinHandle: HWnd; Param: LongInt): Boolean;
  far;
 begin
  if (GetParent (WinHandle) = 0) and (not IsIconic (WinHandle))
    and
     (IsWindowVisible (WinHandle)) then
  begin
   SendMessage (WinHandle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
  end; { if...}
  EnumProc := TRUE;
 end; { EnumProc }

 begin {ExDelphi}
   EnumWindows(@EnumProc, 0);
   ExResult := WinExec ('DELPHI.EXE', SW_SHOW);
   if ExResult < 32 then
   begin
     Str(ExResult, ExResultSt);
     ExResultSt := 'Error Loading Delphi : ' + ExResultSt + #0;
     MessageBox (0, @ExResultSt[1], 'EDS ExDelphi Loader',
                 mb_OK or mb_IconInformation);
   end; {if...}
 end. {ExDelphi}

------------------------------------------------------------------
not too big of a program but supposed to be cool.  will minimize all
windows as it executes delphi.

Well, it compiles and works for me. What you have to do is:
        - open a new project;
        - close form1 and unit1;
        - open the project source;
        - paste the whole code above over what is already there;
        - save the project as exdelphi.DPR;
        - build. {result is an EXE of 4K}


