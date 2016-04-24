(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0098.PAS
  Description: File date & time stamp unit
  Author: ALBERT L. FOWLER
  Date: 11-29-96  08:17
*)

{ I made this to time stamp my programs with a time stamp giving the
  version no.  Much of it is courtesy of SWAG and TP6's on line help.

  Use, improve, modify or whatever, but at one's own risk.

                             Albert L. Fowler.
                             Kircaldy, Scotland                    }
{------------------------------------------------------------------}

Program time_and_date_stamp_the_passed_file;      { stamp_it.pas }

(*  A file date and time stamping facility.

                 By A. L. Fowler 10th November 1996 *)

Uses
Dos, Crt, List_A;      { for List_A.pas see below }

Var
  hrs, mins    : Word;        { to set time stamp }


Function LeadingZero (w : Word) : String;
Var
  s     : String;

Begin
  Str (w : 0, s);
  If Length (s) = 1 Then
     s := '0' + s;
  LeadingZero := s;
End;


Procedure header;
Begin
  GotoXY (4, 1);
  TextColor (14);
  Write ('STAMP_IT A File Time & Date Updating Facility.  By  A. L. Fowler. 1996');
  NormVideo;
End;


Procedure check_passed_param;

Var
  s     : String [80];
  f     : Text;
  ft    : LongInt;            { For Get/SetFTime }
  dt    : DateTime;        { For Pack/UnpackTime }


Begin
  GetDir (0, s);             { 0 = Current drive }
  If ( ParamCount <> 1 ) Then
     Begin
     header;
     GotoXY (14, 4);
     TextColor (10);
     Write ('STAMP_IT  Does not have a following filename');
     GotoXY (8, 6);
     Write ('e.g.  ', s, '\STAMP_IT  [drive:][path][filename]');
     NormVideo;
     GotoXY (1, 24);
     Halt (1);
     End;

  If Not FileExists (ParamStr (1) ) Then
     Begin
     header;
     TextColor (10);
     GotoXY (8, 4);
     Write ('  File  ', UpperCase (ParamStr (1) ), '  not found.');
     GotoXY (8, 6);
     Write ('Syntax  ', s, '\STAMP_IT  [drive:][path][filename]');
     NormVideo;
     GotoXY (1, 24);
     Halt (2);
     End
  Else
     GotoXY (4, 3);
  TextColor (11);
  Write (UpperCase (ParamStr (1) ) );

  Assign (f, ParamStr (1) );
  Reset (f);                 { Open specified File }
  GetFTime (f, ft);            { Get creation time }
  UnpackTime (ft, dt);
  With dt Do
       Begin
       Write (' [ Time Stamped ', LeadingZero (hour), ':', LeadingZero (min),
       ':', LeadingZero (sec), ' & Dated ', day, '-', month, '-', year, ' ]');
       End;
  GotoXY (4, 4);
  WriteLn ('Will be Stamped with Today''s Date & given a Time Stamp you can choose.');
  NormVideo;
End;


Procedure choose_time_stamp;

Var
  yn, ap, Confirm      : Char;
  _h,  _m    : String [3];
  c, h, inp  : Integer;

Label
  again, h1, m1;

Begin
  hrs  := 0;
  mins := 0;
  _h  := '0';
  _m  := '0';

  FlushKeyBuffer;
  again :
  GotoXY (4, 6);
  TextColor (10);
  Write ('Is the Default Time Stamp of 12:01a Acceptable?  Y/N  ');
  CursorOff;
  yn := ReadKey;
  If yn = #13 Then
     Goto again;
  If yn = #27 Then
     Begin
     CursorOn;
     NormVideo;
     GotoXY(1, 24);
     Halt (3);
     End;
  If Not ( UpCase (yn) In [ 'N', 'Y'] )  Then
     Begin                       { Only accept y or n }
     Alarm;
     Goto again;
     End
  Else

     If UpCase (yn) = 'N' Then            { User time stamp requested }

    Begin   { of user input }

    h1 :        { Do not accept nul or error input }
    GotoXY (4, 8);
    Write ('Enter hours. ');
    ReadLn (_h);

    If _h  = '0' Then
       _h := '00';                { ok its a bodge }

    If Ord (_h [0]) >= 3 Then     { oversize hours inputs }
       Begin
       GotoXY (17, 8);
       Write ('           Input not recognised, enter again.   ');
       Alarm;
       Goto h1;
       End;

    { First delete any leading zeros in the hours string }
    If (Ord (_h [0]) >=  1) And (_h [1] = '0') Then
       _h := Copy (_h, 2, Ord (_h [0]) - 1);

    Val (_h, hrs,  c);                    { Convert to hrs }
    If ( c <> 0 ) Or ( hrs > 23 ) Then    { Rubbish inputs }
       Begin
       GotoXY (17, 8);
       Write ('           Hours  in the Range 0 to 23 please.  ');
       Alarm;
       Goto h1;
       End;

    m1 :            { Do not accept nul or error input }
    GotoXY (4, 10);
    Write ('Enter mins.  ');
    ReadLn (_m);

    If _m  = '0' Then
       _m := '00';              { ok its another bodge }

    If Ord (_m [0]) >= 3 Then   { oversize mins inputs }
       Begin
       GotoXY (17, 10);
       Write ('           Input not recognised, enter again.   ');
       Alarm;
       Goto m1;
       End;

    { First delete any leading zeros in the mins string }
    If (Ord (_m [0]) >=  1) And (_m [1] = '0') Then
       _m := Copy (_m, 2, Ord (_m [0]) - 1);

    Val (_m, mins, c);                            { Convert to min }
    If ( c <> 0 ) Or ( mins > 59 ) Then           { Rubbish inputs }
       Begin
       GotoXY (17, 10);
       Write ('           Minutes in the Range 0 to 59 please.  ');
       Alarm;
       Goto m1;
       End;
    End;    { of user input }

  If UpCase (yn) = 'Y' Then       { User accepts 12:01a }
     Begin
     _h  := '0';
     Val (_h, hrs,  c);        { Convert to hrs }
     _m  := '1';
     Val (_m, mins, c);        { Convert to min }
     End;

  Begin                 { Section produces time in  am pm format }
  If hrs < 12 Then      { now convert hrs & mins for user to see }
     Begin
     ap := 'a';
     If hrs = 0  Then
    _h := '12';
     End
  Else
     Begin
     ap := 'p';
     h := hrs - 12;                { to display in am pm format }
     Str (h, _h);
     End;
  If mins < 10 Then
     _m := '0' + _m;
  End;    { am pm on screen information }

  GotoXY (4, 12);
  Write ('File will be Time Stamped ', _h, ':', _m, ap);

  GotoXY (4, 14);
  Write ('Is this acceptable? . . . . Y/N ');
  Confirm := ReadKey;

  If (Confirm = #27) Or (Confirm = #110) Or (Confirm = #78) Then
     Begin                     { Esc , N or n pressed }
     GotoXY (4, 14);
     Write ('Exit confirmed, file has not been changed.');
     CursorOn;
     GotoXY (1, 24);
     NormVideo;
     Halt (4);
     End;

  If (Confirm = #89) Or (Confirm = #121) Then
     GotoXY (1, 24);
  CursorOn;
  NormVideo;
End;


Procedure stamp_file;

Var
  f     : Text;
  ftime : LongInt;                    { For Get/SetFTime }
  dt    : DateTime;                   { For Pack/UnpackTime }
  year, month, day, DofW    : Word;   { for GetDate }

Begin
  Assign (f, ParamStr (1) );
  GetDate (year, month, day, DofW);     { Today''s Date  }
  Reset (f);                            { Open existing File }
  GetFTime (f, ftime);                  { Get old creation time }
  UnpackTime (ftime, dt);
  GotoXY (4, 17);
  TextColor (11);
  With dt Do
       Begin
       Write ('Old File TimeStamp was:  ', LeadingZero (hour), ':', LeadingZero
       (min), ':', LeadingZero (sec), '    Dated:  ', day, '-', month, '-', year);

       GetDate (year, month, day, DofW);   { Again to Set/Confirm today's date }
       hour := hrs;
       min  := mins;             { These for chosen time stamp }
       sec  := 0;

       PackTime (dt, ftime);
       Reset (f);
       { Re-open File For reading otherwise, close will update time }
       SetFTime (f, ftime);

       GetFTime (f, ftime);                { Get new creation time }
       UnpackTime (ftime, dt);
       GotoXY (4, 19);
       With dt Do
        Begin
        Write ('New File TimeStamp  is:  ', LeadingZero (hour), ':',
        LeadingZero (min),
        ':', LeadingZero (sec), '    Dated:  ', day, '-', month, '-', year );
        End;
       End;
  GotoXY (1, 24);
  Close (f);        { Close File }
  NormVideo;
End;


Begin
  ClrScr;
  check_passed_param;
  header;
  choose_time_stamp;
  stamp_file;
End.

{-------------------------------------------------------------------------}
Unit LIST_A;

(* LIST_A a simple list, used in STAMPIT, etc. *)

Interface
Uses Crt, Dos;

Procedure CursorOff;
Procedure CursorOn;
Procedure FlushKeyBuffer;
Procedure Alarm;
Function FileExists (FileName : String) : Boolean;
Function UpperCase (s : String) : String;


  Implementation

{*****************************************************************************}

Procedure CursorOff;
  Assembler;
  Asm
  MOV   ax, $0100
  MOV   cx, $2607
  Int   $10
End;

Procedure CursorOn;
  Assembler;
  Asm
  MOV   ax, $0100
  MOV   cx, $0506
  Int   $10
End;

Procedure FlushKeyBuffer;
Var
  recpack : Registers;
Begin
  With recpack Do
       Begin
       ax := ($0c ShL 8) Or 6;
       dx := $00ff;
       End;
  Intr ($21, recpack);
End;     {FlushKeyBuffer}


Function FileExists (FileName : String) : Boolean;
{ Returns True if file exists; otherwise, it returns  False.
       Closes the file and exists.  }
Var
  f : File;

Begin
  {$I-}
  Assign (f, FileName);
  Reset (f);
  Close (f);
  {$I+}
  FileExists := (IOResult = 0) And (FileName <> '');
End;      { FileExists }


Function UpperCase (s : String) : String;
Var
  I : Integer;
Begin
  For I := 1 To Ord (s [0]) Do
      If s [I] In ['a'..'z'] Then
     Dec (s [I], 32);
  UpperCase := s;
End;

Procedure Alarm;
Begin
  Sound (466);
  Delay (150);
  Sound (349);
  Delay (200);
  NoSound;
End;

End.


