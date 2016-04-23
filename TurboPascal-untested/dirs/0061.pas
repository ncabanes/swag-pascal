{****************************************}
{*           DOSINI.PAS 1.20            *}
{*                                      *}
{*       Author : Thomas Bargholz       *}
{*     Written : August 10th, 1994      *}
{*                                      *}
{*    Donated to the Public Domain      *}
{****************************************}
{

This unit implements a Windows style .INI file for DOS applications, by
supplying easy and fast access to the exact infomation in the .INI file
of your choise.
The Windows API supplies functions to retrieve information in .INI files,
but are (ofcource) directed at Windows. Now DOS real and pmode programs
can use .INI files just as easy.
As in Windows, the DOS .INI files must have the format:

[section]
entry=profile

By supplying the .INI filename, the section name, and the entry name,
DOSINI will return the profile.
The .INI file can be placed anywhere, but this unit supplies two functions
to locate the DOS directory and your applications home directory, so if
you place your .INI file in one of those directories, you can locate
your .INI files easily.

This unit uses TurboPowers Objecty Professional (OPRO):
TurboPower : US phone    : 800-333-4160
             Other phone : 719-260-9136
             Fax         : 719-260-7151
If you don't have OPRO, it's still possible to use this unit. Simply
undefine OPRO below.

If you have any comments, suggestions or bug reports, please contact me:

e-mail    : tba@m.dia.dk
snail mail: Thomas Bargholz
            Smallegade 20, 3 tv.
            DK-2000 Frederiksberg
            Denmark

Changes:

06.09.94:     Added DEFINE OPRO. Create simmilar functions of those in
              OPRO for those of you that don't have OPRO.
26.09.94:     Removed bug in WriteProfileString. Tanks to Germano Rossi
              for giving me this bugfix. (germano@chiostro.univr.it)

}

{$IFDEF WINDOWS}
  Use the Windows API, it is better for this purpose !!!
{$ENDIF}

{$DEFINE DEBUG}  {Include debug info in TPU}

{$DEFINE OPRO}   {Undefine this if you don't have OPRO - It'll still compile}

{$IFDEF DEBUG}
  {$A+,D+,I-,L+,R+,X+,Y+}
{$ELSE}
  {$A+,D-,I-,L-,R-,X+,Y-}
{$ENDIF}
{Fee free to change the compiler directives above, but please leave the I-}

Unit DosIni;

Interface

{------ Read a profile in a .INI file ------}

Function GetProfileStr(IniName, Section, Entry, Default : String) : String;
  {- Read a string in a .INI file}

Function GetProfileInt(IniName, Section, Entry : String; Default : Integer) : Integer;
  {- Read a Integer in a .INI file}

Function GetProfileLong(IniName, Section, Entry : String; Default : LongInt) : LongInt;
  {- Read a LongInt in a .INI file}

Function GetProfileReal(IniName, Section, Entry : String; Default : Real) : Real;
  {- Read a Real in a .INI file}

{------ Write a profile to .INI file ------}

Function WriteProfileStr(IniName, Section, Entry, Str : String) : Integer;
  {- Write a string to a .INI file}

Function WriteProfileInt(IniName, Section, Entry : String; Int : Integer) : Integer;
  {- Write a Integer to a .INI file}

Function WriteProfileLong(IniName, Section, Entry : String; Long : LongInt) : Integer;
  {- Write a LongInt to a .INI file}

Function WriteProfileReal(IniName, Section, Entry : String; R : Real) : Integer;
  {- Write a Real to a .INI file}

{------ Directory related functions ------}

Function GetDOSDirectory : String;
  {- Returns the path to the DOS directory}

Function GetHomeDirectory : String;
  {- Returns the path to the applications home directory}


Implementation

{$IFDEF OPRO}

Uses
  OpDos,
  OpString;

{$ELSE}

Uses
  Dos;

Function ExistOnPath(FileName : String; Var FullPath : String) : Boolean;
Var
  S : String;
Begin
  ExistOnPath := False;
  S := FSearch(FileName,GetEnv('PATH'));
  If S <> '' Then
  Begin
    ExistOnPath := True;
    FullPath := FExpand(S);
  End;
End;

Function JustPathName(FileName : String) : String;
Var
  D : DirStr;
  N : NameStr;
  E : ExtStr;
Begin
  FSplit(FileName,D,N,E);
  JustPathName := D;
End;

Function StUpCase(S: String) : String;
Var
  I : Integer;
  Tmp : String;
Begin
  Tmp := '';
  If S <> '' Then
    For I := 1 To Length(S) Do
      Tmp := Tmp + UpCase(S[I]);
  StUpCase := Tmp;
End;

Function Str2Int(S : String; Var I : Integer) : Boolean;
Var
  Error : Integer;
Begin
  Str2Int := False;
  Val(S,I,Error);
  If Error = 0 Then
    Str2Int := True;
End;

Function Str2Long(S : String; Var I : LongInt) : Boolean;
Var
  Error : Integer;
Begin
  Str2Long := False;
  Val(S,I,Error);
  If Error = 0 Then
  Begin
    Str2Long := True;
    I := LongInt(I);
  End;
End;

Function ExistFile(FileName : String) : Boolean;
Var
  S : String;
Begin
  ExistFile := False;
  S := FSearch(FileName,'');
  If S <> '' Then
    ExistFile := True;
End;

{$ENDIF}

Function GetProfileStr(IniName, Section, Entry, Default : String) : String;
  {- Read a string in a .INI file}
Var
  F : Text;
  S : String;
  I : Integer;
Begin
  Assign(F,IniName);
  Reset(F);                       {Open the file}
  If IOResult <> 0 Then           {Success?}
  Begin
    GetProfileStr := Default;
    Exit;
  End;
  Repeat                          {Find the right section}
    ReadLn(F,S);
  Until (StUpCase(S) = StUpCase('['+Section+']')) Or (Eof(F));
  If Not Eof(F) Then
  Begin
    Repeat
      ReadLn(F,S);                {Find the right entry}
      I := Pos(StUpCase(Entry+'='),StUpCase(S));
    Until (I = 1) Or (Eof(F));
    If I = 1 Then                 {Extract the profile string}
      S := Copy(S,Length(Entry)+2,Length(S))
    Else
      S := '';
  End
  Else
    S := '';
  Close(F);                       {Close the .INI file, we're done}
  If S <> '' Then
    GetProfileStr := S
  Else
    GetProfileStr := Default;
End;


Function GetProfileInt(IniName, Section, Entry : String; Default : Integer) : Integer;
  {- Read a Integer in a .INI file}
Var
  S : String;
  I : Integer;
Begin
  S := GetProfileStr(IniName, Section, Entry, '{@}');
  If S = '{@}' Then
    GetProfileInt := Default
  Else
  Begin
    If Not Str2Int(S,I) Then
      GetProfileInt := Default
    Else
      GetProfileInt := I;
  End;
End;


Function GetProfileLong(IniName, Section, Entry : String; Default : LongInt) : LongInt;
  {- Read a LongInt in a .INI file}
Var
  S : String;
  L : LongInt;
Begin
  S := GetProfileStr(IniName, Section, Entry, '{@}');
  If S = '{@}' Then
    GetProfileLong := Default
  Else
  Begin
    If Not Str2Long(S,L) Then
      GetProfileLong := Default
    Else
      GetProfileLong := L;
  End;
End;


Function GetProfileReal(IniName, Section, Entry : String; Default : Real) : Real;
  {- Read a Real in a .INI file}
Var
  S : String;
  R : Real;
  Error : Integer;
Begin
  S := GetProfileStr(IniName, Section, Entry, '{@}');
  If S = '{@}' Then
    GetProfileReal := Default
  Else
  Begin
    Val(S,R,Error);
    If Error <> 0 Then
      GetProfileReal := Default
    Else
      GetProfileReal := R;
  End;
End;


Function WriteProfileStr(IniName, Section, Entry, Str :String) : Integer;
  {- Write a string to a .INI file}
Var
  F1, F2 : Text;
  I : Integer;
  S : String;
  SectionOK, EntryOK : Boolean;
Begin
  If Not ExistFile(IniName) Then  {If the file dosen't exist, create it}
  Begin
    Assign(F1,IniName);
    Rewrite(F1);
    I := IOResult;
    If I <> 0 Then
    Begin
      Close(F1);
      WriteProfileStr := I;
      Exit;
    End;
    WriteLn(F1,'['+Section+']');   {Write the section header}
    WriteLn(F1,Entry+'='+Str);     {Write the entry and the profile string}
    WriteLn(F1);
    Close(F1);
  End
  Else                            {If the file do exist}
  Begin
    Assign(F1,IniName);
    Reset(F1);
    I := IOResult;
    If I <> 0 Then
    Begin
      Close(F1);
      WriteProfileStr := I;
      Exit;
    End;
    Assign(F2,'DOSINI$$.$$$');
    Rewrite(F2);
    I:= IOResult;
    If I <> 0 Then
    Begin
      WriteProfileStr := I;
      Close(F1);
      Close(F2);
      Exit;
    End;
    SectionOK := False;
    EntryOK := False;
    While Not Eof(F1) Do
    Begin
      ReadLn(F1,S);
      If StUpCase(S) = StUpCase('['+Section+']') Then
      Begin
        SectionOK := True;        {We've found the section}
        WriteLn(F2,S);
        Repeat
          ReadLn(F1,S);
          I := Pos(StUpCase(Entry+'='),StUpCase(S));
          If I = 1 Then
          Begin
            EntryOK := True;      {We've found the entry}
            WriteLn(F2,Entry+'='+Str);
          End
          Else
            If (S = '') Or (Pos('[',S)=1) Then
            Begin
              WriteLn(F2,Entry+'='+Str);
              EntryOK := True;
            End
            Else
              WriteLn(F2,S);
        Until (Pos('[',S)=1) Or (Eof(F1)) Or (EntryOK);
        If Not EntryOK Then
        Begin
          WriteLn(F2,Entry+'='+Str);
          WriteLn(F2);
        End;
      End
      Else
        WriteLn(F2,S);
      If (SectionOK) And (EntryOK) Then {We have made the change}
      Begin
        Repeat
          ReadLn(F1,S);
          WriteLn(F2,S);
        Until Eof(F1);
        Close(F1);
        Erase(F1);
        Close(F2);
        Rename(F2, IniName);
        WriteProfileStr := 0;     {Every thing OK -> Return 0}
        Exit;
      End;
    End;
    If Not SectionOK Then
    Begin
      WriteLn(F2);
      WriteLn(F2,'['+Section+']');
      WriteLn(F2,Entry+'='+Str);
    End;
    Close(F1);
    Erase(F1);
    Close(F2);
    Rename(F2, IniName);
  End;
  WriteProfileStr := 0;           {Every thing OK -> Return 0}
End;


Function WriteProfileInt(IniName, Section, Entry : String; Int : Integer) : Integer;
  {- Write a Integer to a .INI file}
Var
  S : String;
  I : Integer;
Begin
  Str(Int,S);
  I := WriteProfileStr(IniName, Section, Entry, S);
  WriteProfileInt := I;
End;


Function WriteProfileLong(IniName, Section, Entry : String; Long : LongInt) : Integer;
  {- Write a Integer to a .INI file}
Var
  S : String;
  I : Integer;
Begin
  Str(Long,S);
  I := WriteProfileStr(IniName, Section, Entry, S);
  WriteProfileLong := I;
End;


Function WriteProfileReal(IniName, Section, Entry : String; R : Real) : Integer;
  {- Write a Real to a .INI file}
Var
  S : String;
  I : Integer;
Begin
  Str(R,S);
  I := WriteProfileStr(IniName, Section, Entry, S);
  WriteProfileReal := I;
End;


Function GetDOSDirectory : String;
  {- Returns the path to the DOS directory}
Var
  Name : String;
Begin
  If Not ExistOnPath('FDISK.EXE',Name) Then    {Is FDISK.EXE on the path?}
  Begin
    If Not ExistOnPath('SETVER.EXE',Name) Then {Is SETVER.EXE on the path?}
      GetDOSDirectory := ''
    Else
      GetDOSDirectory := JustPathName(Name);
  End
  Else
    GetDOSDirectory := JustPathName(Name);
End;


Function GetHomeDirectory : String;
  {- Returns the path to the applications home directory}
Begin
  GetHomeDirectory := JustPathName(ParamStr(0));
  {This function only returns an empty string, when using it in the IDE, but
   din't worry; It works when the program using it is compiled}
End;

End.


{ ---------------------------   DEMO PROGRAM  ------------------------- }
{ CUT }

{********************************************}
{*               EXAMPLE.PAS                *}
{* Sample application using the DOSINI unit *}
{********************************************}

Uses
  DosIni, {<-- Easy INI file manipulation}
  Dos;

Const
  IniFile : String = 'EXAMPLE.INI';
  GrSection : String = 'Graphics';
  SndSection : String = 'Sound';

Var
  No : Integer;
  Day, Month, Year, WeekDay : Word;
  Hour, Minute, Sec, Sec100 : Word;
  S, Date, Time : String;

Begin
  {First extract information from the INI file :}

  {First the setting in the 'Graphics' section...}
  WriteLn('------- Initializing graphics -------');
  Write('Using graphics driver : ');
  WriteLn(GetProfileStr(IniFile,GrSection,'Driver','egavga.bgi'));
  Write('Resolution : ');
  Write(GetProfileInt(IniFile,GrSection,'HorzRes',640));
  Write('x',GetProfileInt(IniFile,GrSection,'VertRes',480));
  WriteLn('x',GetProfileInt(IniFile,GrSection,'Colors',16));

  {Then the settings in the 'Sound' section...}
  WriteLn('-------- Initializing sound ---------');
  Write('Using sound driver : ');
  WriteLn(GetProfileStr(IniFile,SndSection,'Driver','ibm.drv'));

  {And finally the settings in the 'Control' section...}
  WriteLn('------- Initializing controls -------');
  Write('Using joystick : ');
  WriteLn(GetProfileStr(IniFile,'Control','Joystick','No'));
  Write('Using mouse : ');
  WriteLn(GetProfileStr(IniFile,'Control','Mouse','Yes'));
  Write('Using keyboard : ');
  WriteLn(GetProfileStr(IniFile,'Control','Keyboard','No'));
  WriteLn('-------------------------------------'#10#13);

  {Now lets get some user info, and place it in the INI file:}

  {First a new graphic resolution...}
  WriteLn('Select new graphic resolution :');
  WriteLn(' 1) 320x200x16');
  WriteLn(' 2) 320x200x255');
  WriteLn(' 3) 640x480x16');
  WriteLn(' 4) 640x480x255');
  Write('Type 1-4 for selection : ');
  ReadLn(No);
  Case No Of
    1 : Begin
          If WriteProfileStr(IniFile,GrSection,'Driver','egavga.bgi') <> 0 Then
            WriteLn('Error setting new driver');
          If WriteProfileInt(IniFile,GrSection,'HorzRes',320) <> 0 Then
            WriteLn('Error setting initialization data 1');
          If WriteProfileInt(IniFile,GrSection,'VertRes',200) <> 0 Then
            WriteLn('Error setting initialization data 2');
          If WriteProfileInt(IniFile,GrSection,'Colors',16) <> 0 Then
            WriteLn('Error setting initialization data 3');
        End;
    2 : Begin
          If WriteProfileStr(IniFile,GrSection,'Driver','svga.bgi') <> 0 Then
            WriteLn('Error setting new driver');
          If WriteProfileInt(IniFile,GrSection,'HorzRes',320) <> 0 Then
            WriteLn('Error setting initialization data 1');
          If WriteProfileInt(IniFile,GrSection,'VertRes',200) <> 0 Then
            WriteLn('Error setting initialization data 2');
          If WriteProfileInt(IniFile,GrSection,'Colors',255) <> 0 Then
            WriteLn('Error setting initialization data 3');
        End;
    3 : Begin
          If WriteProfileStr(IniFile,GrSection,'Driver','egavga.bgi') <> 0 Then
            WriteLn('Error setting new driver');
          If WriteProfileInt(IniFile,GrSection,'HorzRes',640) <> 0 Then
            WriteLn('Error setting initialization data 1');
          If WriteProfileInt(IniFile,GrSection,'VertRes',480) <> 0 Then
            WriteLn('Error setting initialization data 2');
          If WriteProfileInt(IniFile,GrSection,'Colors',16) <> 0 Then
            WriteLn('Error setting initialization data 3');
        End;
    4 : Begin
          If WriteProfileStr(IniFile,GrSection,'Driver','svga.bgi') <> 0 Then
            WriteLn('Error setting new driver');
          If WriteProfileInt(IniFile,GrSection,'HorzRes',640) <> 0 Then
            WriteLn('Error setting initialization data 1');
          If WriteProfileInt(IniFile,GrSection,'VertRes',480) <> 0 Then
            WriteLn('Error setting initialization data 2');
          If WriteProfileInt(IniFile,GrSection,'Colors',255) <> 0 Then
            WriteLn('Error setting initialization data 3');
        End;
  End;

  {Then a new sound'driver...}
  WriteLn(#10#13'Select sound device :');
  WriteLn(' 1) Sound Blaster');
  WriteLn(' 2) Adlib Gold');
  WriteLn(' 3) PC speaker');
  Write('Type 1-3 for selection : ');
  ReadLn(No);
  Case No Of
    1 : If WriteProfileStr(IniFile,SndSection,'Driver','sblast.drv') <> 0 Then
          WriteLn('Error setting driver info');
    2 : If WriteProfileStr(IniFile,SndSection,'Driver','adlib.drv') <> 0 Then
          WriteLn('Error setting driver info');
    3 : If WriteProfileStr(IniFile,SndSection,'Driver','ibm.drv') <> 0 Then
          WriteLn('Error setting driver info');
  End;

  {Now, let's add a new section to the INI file...}
  GetDate(Year,Month,Day,WeekDay);
  Str(Day,S);
  Date := S;
  Str(Month,S);
  Date := Date + '/'+S;
  Str(Year,S);
  Date := Date + '/'+S;
  If WriteProfileStr(IniFile,'Modified','Date',Date) <> 0 Then
    WriteLn('Error writing date');

  GetTime(Hour,Minute,Sec,Sec100);
  Str(Hour,S);
  Time := s;
  Str(Minute,S);
  Time := Time + ':'+ S;
  Str(Sec,S);
  Time := Time + ':' + S;
  If WriteProfileStr(IniFile,'Modified','Time',Time) <> 0 Then
    WriteLn('Error writing time');
End.

{ ---------------------- DEMO INI FILE }
{ CUT AND SAVE AS EXAMPLE.INI }

[Graphics]
Driver=egavga.bgi
HorzRes=320
VertRes=200
Colors=16

[Sound]
Driver=sblast.drv

[Control]
Joystick=No
Mouse=Yes
Keyboard=Yes
