LARS FOSDAL

> Hi all.  I've got a little Program that brings up a Window and several
> buttons in TP 7.  The buttons have the names of Various batch Files on them
> which are executed when they are pressed.  The batch Files start up Various
> other Programs.  This launchpad requires about 100K of RAM as currently
> written, and I'm wondering about ways to reduce this amount significantly.
> According to the BP 7 manual resource Files can be used to reduce RAM by 8-
> 10%.  Right now the Various buttons' Labels and commands are stored in
> simple Arrays, which are not the most efficient memory-wise, but I don't
> think that making them Records will significantly reduce RAM need.  I'd like
> to reduce RAM usage an order of magnitude, to about 10K.  Any chance of
> doing this?

There is a dirty way of doing this, and it works With every Dos /
command-interpreter that I've tried it under, including Dos 6.0
in a Window under Windows, and 4Dos.

The Really nice thing about this way to do it, is that you can even
load TSR's etc. since the menu Program is not in memory at all and there is
no secondary command interpreter when the user executes his choice.

The trick is that you run your Program from a "self-modifying" batchFile.

--- MENU.BAT ---
:StartAgain
SET MENU=C:\Dos\MENU.BAT  ; Check this environment Var from your menu-prog
GOMENU.EXE                ; and abort if it is not set
SET MENU=
----------------

Lets say you want to run another batchFile from a menu choice f.x MY.BAT.
Let your Program modify the MENU.BAT to:
---
:StartAgain
SET MENU=C:\Dos\MENU.BAT
GOMENU.EXE
SET MENU=
CALL MY.BAT
GOTO StartAgain
---

When you want to terminate your menu-loop, simply modify the MENU.BAT
back to it's original state.

The menu Program can be shared from a network server.  There is no
limitations at all.  You can do Dos commands from the menu Without
having to load a second shell.

Following my .sig there is a short example Program.  It can't be run
directly since it Uses some libraries of mine, but you'll get an idea
of how to do it.


Program HitAndRun; {Menusystem}
Uses
  Dos, Crt, LFsystem, LFCrt, LFinput;
{
  Written by Lars Fosdal
  May 5th, 1991

  Released to the public domain, May 15th, 1993
}
Const
  HitAndRunMsg = 'Written by Lars Fosdal ';
  Prog         = 'HIT&RUN';

Var
  path : String;

{----------------------------------------------------------------------------}

Procedure Message(MessageIndex : Integer);
begin
  Writeln(Output);
  Writeln(Output, Prog, ' - ', HitAndRunMsg);
  Write(Output, 'Error: ');
  Case MessageIndex OF
    -1 :
      begin
        Write(Output, Prog, ' must be started from ');
        Writeln(Output,Path + 'MENU.BAT');
      end;
  end;
  Write(Output,^G);
end;

Procedure BuildBatchFile(Execute : String);
Var
  BatchFile : Text;
begin
  Assign(BatchFile, Path + 'MENU.BAT');
  ReWrite(BatchFile);
  Writeln(BatchFile, '@ECHO OFF');
  Writeln(BatchFile, 'REM ' + Prog + ' Menu Minder');
  Writeln(BatchFile, 'REM ' + HitAndRunMsg);
  Writeln(BatchFile, ':HitAgain');
  Writeln(BatchFile, 'SET H&R=BATCH');
  Writeln(BatchFile, path + 'HIT&RUN');
  if Execute<>'' then
  begin
    Writeln(BatchFile, Execute);
    Writeln(BatchFile, 'GOTO HitAgain');
  end
  else
    Writeln(BatchFile, 'SET H&R=');
  Close(BatchFile);
end;

Function InitOK : Boolean;
Var
  OK : Boolean;
begin
  path   := BeforeLast('\', ParamStr(0)) + '\';
  OK     := GetEnv('H&R') = 'BATCH';
  InitOK := OK;
end;

Procedure HitAndRunMenu;
Var
  Mnu : aMenu;
  win : aWindow;
begin
  wDef(Win, 70, 1, 80, 25, 1, Col(Blue, LightGray), Col(Blue, White));
  ItemSeparator:= '`';
  mBarDefault := Red * 16 + Yellow;
  mNew(Mnu, 'Pick an item to run',
       'Quit Menu`COMMAND`DIR /P`D:\BIN\NI'
      + '`D:\BIN\MAPMEM`D:\BIN\X3\XTG'
      + '`D:\BIN\LIST C:\Dos\MENY.BAT');
  Menu(Win, Mnu);
  Case Mnu.Entry OF
    1 : BuildBatchFile('');
    else
      BuildBatchFile(Mnu.Items[Mnu.Entry]^);
  end;
end;{HitAndRunMenu}

begin
  if InitOK then
    HitAndRunMenu
  else
  begin
    Message(-1);
    BuildBatchFile('');
  end;
  Writeln(OutPut);
end.
