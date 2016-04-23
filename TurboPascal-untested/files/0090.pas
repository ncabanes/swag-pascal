Program BFTIME; {(C) 1995 - Brian Leiter - 03/11/1995}

Uses DOS,CRT;

Var H,M,S,Hund         : Word;       { For GetTime         }
    FTime              : Longint;    { For Get/SetFTime    }
    DT                 : DateTime;   { For Pack/UnpackTime }
    Year,Month,Day,Dow : Word;       { For Date            }
    F,F1               : Text;       { For File Name       }
    Log                : Boolean;    { For Log File        }
    Count              : Integer;    { For File Count      }
    DirInfo            : SearchRec;  { For Search Info     }

Const Days : Array [0..6] of String[9] =
      ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
      CDrive: Byte = 0;

Procedure Help;
Begin
  ClrScr;
  Textcolor(9);Writeln('■ BFTIME v1.0 - A File Date/Timestamp Updater Program ■');
  Textcolor(15);Writeln('───────────────────────────────────────────────────────');
  Writeln('');Textcolor(14);
  Writeln('Command Line Usage:  BFTIME [FILE MASK] (Log File)');
  Writeln('');Textcolor(11);
  Writeln('Ex 1: BFTIME *.ZIP                    <───< No Log File');
  Writeln('Ex 2: BFTIME *.ZIP C:\LOG\BFTIME.LOG  <───< Log File Used');
  Textcolor(7);
  Writeln('                 ');
  Writeln('      │      │     └──────────────────< Path & Name Of Log File');
  Writeln('      │      │');
  Writeln('      │      └────────────────────────< Mask For Files To Be Updated');
  Writeln('      │');
  Writeln('      └───────────────────────────────< Executionable Program File');
  Writeln('');Sound(850);Delay(350);NoSound;Sound(650);Delay(350);NoSound;Sound(850);Delay(350);NoSound;
  Halt;
End;

Procedure CheckParams;
Begin
  Log:=False;
  If (ParamCount=0) or (ParamCount>2) Then Help;
  If ParamCount=2 Then Log:=True;
End;

Procedure DateNow;
Begin
  GetDate(Year,Month,Day,Dow);
  If Log=True Then
  Begin
    Assign(F1,ParamStr(2));
    {$I-}Reset(F1);{$I+}
    IF IOResult<> 0 Then Rewrite(F1);
    Append(F1);
    Writeln(F1,'START  LOG: ',Days[Dow],', ',Month:0, '-', Day:0, '-', Year:0,' ■ BFTIME v1.0');
  End;
End;

Function LeadingZero(W : Word) : String;
Var S : String;     { For File Name       }

Begin
  Str(W:0,S);
  If Length(S) = 1 Then S := '0' + S;
  LeadingZero := S;
End;

Procedure Importit;
Begin
  FindFirst(ParamStr(1), Archive, DirInfo);
  While DosError = 0 Do
  Begin
    Count:=Count+1;
    Assign(F,DirInfo.Name);
    Reset(F);
    GetTime(H,M,S,Hund);
    GetDate(Year,Month,Day,Dow);
    GetFTime(F,FTime);
    Gotoxy(1,9);
    Textcolor(14);
    Writeln('■ ',DirInfo.Name,' Was Re-Dated And Re-Timestamped At '
    ,LeadingZero(h),':',LeadingZero(m),':',LeadingZero(s));
    If Log=True Then
    Begin
      Append(F1);
      Writeln(F1,'    ■ ',DirInfo.Name,' Was Re-Dated And Re-Timestamped At '
      ,LeadingZero(h),':',LeadingZero(m),':',LeadingZero(s));
    End;
    UnpackTime(FTime,DT);
    With DT Do
    Begin
      GetDate(Year,Month,Day,Dow);
      Day:=Day;
      Month:=Month;
      Year:=Year;
      Hour := H;
      Min := M;
      Sec := S;
      PackTime(DT,FTime);
      Reset(F);
      SetFTime(F,FTime);
    End;
    Close(F);
    FindNext(DirInfo);
  End;
  Gotoxy(1,10);
  Textcolor(11);
  If Count>=1 Then Writeln('■ Operation Successfull - There Were ',Count,' Files Updated!');
  If Count<=0 Then
  Begin
    Writeln('■ Operation Failed - There Were No Files Matches Found!');
    Sound(350);Delay(350);NoSound; Sound(150);Delay(350);NoSound;
  End;
  If Log=True Then
  Begin
    Append(F1);
    If Count<=0 Then Writeln(F1,'    ■ Operation Failed - No File Match Found ■');
    Writeln(F1,'END OF LOG: BFTIME (C) 1995 Brian Leiter, All Rights Reserved');
    Writeln(F1,'════════════════════════════════════════════════════════════════════════════════');
    Close(F1);
  End;
End;

Procedure Logo;
Begin
  Clrscr;
  Textcolor(15);Textbackground(4);
  Writeln('╔════════════════════════════════════════════╗');
  Writeln('║ -=■ BFTIME v1.0 ■=-               03/11/95 ║');
  Writeln('║                                            ║');
  Writeln('║      File Date And Timestamp Updater       ║');
  Writeln('║                                            ║');
  Writeln('║ (C) 1995 Brian Leiter, All Rights Reserved ║');
  Writeln('╚════════════════════════════════════════════╝');
  Textbackground(0);
End;

Begin;
CheckParams;
Logo;
DateNow;
Importit;
Textcolor(7);
;
End.
