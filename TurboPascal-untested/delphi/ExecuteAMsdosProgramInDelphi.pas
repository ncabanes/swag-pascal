(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0292.PAS
  Description: Execute a MS-DOS program in Delphi
  Author: KEITH ANDERSON
  Date: 05-30-97  18:23
*)

{
> I need run a MS-DOS program at my program, and wait until MS-DOS program
> finish its work.

Here is probably the most original way to do this, but works the best.
It creates a .PIF file and uses that to execute the DOS program.
Note that the first function "exec" runs a windows program and waits, etc.
(This is for Delphi 2.x only)

  Function Exec(Path,Params,WorkPath:string; Wait:Boolean; Runmode:integer):boolean;
  {Path       Full path to the executable
   Params     Parameters
   WorkPath   Default directory, '' if same path as executable
   Wait       TRUE if execution of current program waits until new program finishes
   RUNMODE    How the application is executed (0 for default SHOWNORMAL):

      Value                  Meaning
      SW_HIDE                Hides the window and activates another window.
      SW_MAXIMIZE            Maximizes the specified window.
      SW_MINIMIZE            Minimizes the specified window and activates the
                             next top-level window in the Z order.
      SW_RESTORE             Activates and displays the window. If the window
                             is minimized or maximized, Windows restores it to
                             its original size and position. An application
                             should specify this flag when restoring a minimized
                             window.
      SW_SHOW                Activates the window and displays it in its current
                             size and position.
      SW_SHOWDEFAULT         Sets the show state based on the SW_ flag specified
                             in the STARTUPINFO structure passed to the CreateProcess
                             function by the program that started the application. An
                             application should call ShowWindow with this flag to set
                             the initial show state of its main window.
      SW_SHOWMAXIMIZED       Activates the window and displays it as a maximized window.
      SW_SHOWMINIMIZED       Activates the window and displays it as a minimized window.
      SW_SHOWMINNOACTIVE     Displays the window as a minimized window. The active
                             window remains active.
      SW_SHOWNA              Displays the window in its current state. The active
                             window remains active.
      SW_SHOWNOACTIVATE      Displays a window in its most recent size and position.
                             The active window remains active.
      SW_SHOWNORMAL          Activates and displays a window. If the window is minimized
                             or maximized, Windows restores it to its original size and
                             position. An application should specify this flag when
                             displaying the window for the first time.}

  var name:string;
      handle:integer;
      startUpInfo : TStartupInfo;
      processInfo       : TProcessInformation;
      exeCmd : string;
    begin
      if Runmode=0 then Runmode:=SW_SHOWNORMAL;
      if WorkPath='' then WorkPath:=extractfilepath(path);

      if wait
        then begin  // wait for the process to end...
               // Check to make{ If the execution file does not exist, then try
               // adding the path, if that fails then you're stuffed }
               if not FileExists(path) then begin
                  result := false;
                  exit;
               end;

               // Concat in the parameters
               exeCmd := path + ' ' + params;

               // Initialise the StartUpInfo record, which handles the creation of

               // a new main window for a process
               FillChar(startUpInfo, SizeOf(startUpInfo), Chr(0));
                    StartUpInfo.cb := SizeOf( StartUpInfo );
                    StartUpInfo.dwFlags     := STARTF_USESHOWWINDOW;
                    StartUpInfo.wShowWindow := runmode;

               // Spawn the process out.
                    if not CreateProcess(


                        nil, PChar(exeCmd), nil, nil, false,
                        CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
                        PChar(ExtractFilePath(path)), startUpInfo, processInfo
                      ) then begin
                  result := false;
               end;

               // Wait for ze old process to finish.
               WaitForSingleObject(processInfo.hProcess, INFINITE);
             end
        else begin
               handle:=ShellExecute(Application.Handle,'open',pchar(path),pchar(params),
                                    pchar(WorkPath),RunMode);
             end;
    end;


  Function ExecDOS(Path,Params,WorkPath,Title:String; Wait:Boolean; Minimized:Boolean):Boolean;
  {Just for DOS programs, creates a PIF file then executes it, deleting it afterward.
   Path       Full path to the executable
   Params     Parameters
   WorkPath   Default directory, '' if same path as executable
   Title      Title to display at top of window
   Wait       TRUE if execution of current program waits until new program finishes
   Minimized  TRUE if program is to run minimized.}
  var f:file;
      pifpath:string;
      a:string;
      ierr:integer;
    begin
      if WorkPath='' then WorkPath:=extractfilepath(path);

      // this is a generic PIF image that we've hacked to pieces...settings:
      //   Idle sensitivity set lowest
      //   Default window
      //   Exit on terminate
      //   All memory resources used if needed
      //   Allow screen saver
      //   Not dynamic allocation
      a:=#0#120#84#69#83#84#68#79#126#49#32#32#32#32#32#32#32#32#32#32+
      #32#32#32#32#32#32#32#32#32#32#32#32#128#2#0#0#68#58#92#116#101+
      #115#116#100#111#115#112#114#111#103#114#97#109#116#104#105#110+
      #103#46#101#120#101#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#16#0#101#58#92#116#101#109#112+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#45#101#120+
      #32#100#58#92#116#101#115#116#32#100#58#92#42#46#42#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#1#0#255#25#80#0#0#7#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#77#73+
      #67#82#79#83#79#70#84#32#80#73#70#69#88#0#135#1#0#0#113#1#87#73+
      #78#68#79#87#83#32#51#56#54#32#51#46#48#0#5#2#157#1#104#0#128+
      #2#0#0#100#0#50#0#255#255#0#0#255#255#0#0#2#0#2#0#159#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#45#101#120#32#100#58#92#116#101+
      #115#116#32#100#58#92#42#46#42#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#87+
      #73#78#68#79#87#83#32#86#77#77#32#52#46#48#0#255#255#27#2#172+
      #1#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#80#73#70+
      #77#71#82#46#68#76#76#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#2#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#129#0#0#0#0#0#0#0#0#0#0#0#1#0#0#0#5#0#25#0#3#0#200#0+
      #232#3#2#0#10#0#1#0#0#0#0#0#0#0#28#0#0#0#0#0#0#0#8#0#12#0#84#101+
      #114#109#105#110#97#108#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#76#117#99#105#100#97#32#67#111#110#115#111#108#101+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#3#0#0#0#80#0#25#0#128+
      #2#44#1#0#0#0#0#22#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
      #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#1#0;
      title:=spaces(title,30);
      move(title[1],a[$02+1],30);

      if length(path)>63 then path:=copy(path,1,63);
      path:=path+#0;
      move(path[1],a[$24+1],length(path));

      if length(params)>63 then params:=copy(params,1,63);
      params:=params+#0;
      move(params[1],a[$a5+1],length(params));
      move(params[1],a[$1c5+1],length(params));

      if length(workpath)>63 then workpath:=copy(workpath,1,63);
      workpath:=workpath+#0;
      move(workpath[1],a[$65+1],length(workpath));

      if minimized
        then a[$1af+1]:=#$12
        else a[$1af+1]:=#$2;

      result:=false; // default unsuccessful
      pifpath:=newfilename(temppath+'00000000.pif',false);
      assignfile(f,pifpath);
      rewrite(f,1);
      ierr:=ioresult;
      blockwrite(f,a[1],length(a),ierr);
      closefile(f);
      if ierr<>length(a) then exit;
      result:=exec(pifpath,'','',wait,0);
      application.processmessages;
      if not wait then delay(1000); // we must wait one second for Windows to read file
      deletefile(pifpath);
    end;


