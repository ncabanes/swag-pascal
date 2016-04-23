{
This unit will allow you to access the original command line as it was
originally entered by the user.  Here is the source code for the CmdLine
object.  It was developed by Computer Mavericks, using information gleened
from the info-pascal internet forum.  In the spirit of the forum, this is
offered into the public domain.  If you use it, think kind thoughs of Lee
Crites and the small staff here at CM.

This was written using Borland Pascal 7.0's BPW in Real Mode.  (after all,
you'll probably not have to many command line parameters to check if you
are working in Windows or OS2, right???  It requires the STRINGS unit that
comes with BP7.  If you are working in TP6/TP5.5, and don't have access to
this, we do (should I say <did>) have a unit for doing null terminated
strings for each of those releases that we might be able to send out.  As
I remember, we took the BPW 1.0 Strings unit and played around with it
until it compiled in TP6, so I don't know which version that I still have
access to (it's been a while since I looked at our last tp6 archives).

I threw this together over the weekend, and tested it using the whoami
program and test.bat file.  There might still be a problem floating around
in there somewhere.  This is about the first time that I've really sent
out some source code like this, and really haven't gone through it with a
fine tooth comb.  If there are bugs or (more importantly) imporvements
that some of you can see, please let me know.
}

{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
{ =-=-=-=-=                                                   =-=-=-=-= }
{ =-=                                                               =-= }
{                               CMDLINE.PAS                             }
{ This unit contains the following:                                     }
{    -- CMDLINE, a mute object that will parse the physical command     }
{       line as input by the user, and return the information that was  }
{       requested.                                                      }
{ =-=                                                               =-= }
{ =-=-=-=-=                                                   =-=-=-=-= }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
{$D-} { debugging information off }
{$X+} { allow extended syntax }
{$V+} { require same var type }
{$R-} { range checking off }
{$E+} { Add 8087 software emulation code }
{$N+} { Use the 8087 software emulation code }
{$I-} { Enable IOResult for I/O checking }
{$B-} { Short-cut boolean evauation }
{$O+} { Allow this to be a part of an overlay }
Unit CmdLine;
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Interface
Uses Strings;  { Strings is a BP7 unit.  I have a TP6 version available }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Type
  TCmdLine = Object
     Constructor Init;
     Destructor Done; Virtual;
     { this will return the information requested -- the whole reason   }
     { for doing this in the first place.  It will return TRUE if the   }
     { ParmStrIn was found, otherwise false. This way you can check for }
     { switches entered with no data, since StrBack would otherwise be  }
     { null.                                                            }
     Function  GetParameter(ParmStrIn:String;Var StrBack:String):Boolean;
     Function  GetCommandLine:String;                 { the entire line }
     Function  GetActualProgram:String;       { the actual name entered }
     Function  GetCallingProgram:String;     { the fully qulaified name }
     Function  GetLaunchingProgram:String; { what environment called me }
     Procedure Trim;        { remove leading, trailing, multiple spaces }
     Procedure Capitalize;                   { just what it sounds like }
     Procedure Restore;                 { restores the original version }
     Function  GetDivideChars:String;      { returns the dividing chars }
     Procedure SetDivideChars(NewDivideChars:String);       { sets them }

     Private
     DivideChars:String;             { the chars that signal a new parm }
     CommandLine,OriginalCommandLine:String;  { just what the name says }
     LaunchingProgram,CallingProgram,ActualProgram:String;
     End; { TCmdLine }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Var
  CommandLine:TCmdLine;
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
{PAGE}
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Implementation
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Const
  NONE = '<NONE>';
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Procedure MakeCaps(Var ss:String);
Var xx,ll:Byte;
Begin
  ll := Length(ss);
  For xx := 1 to ll Do ss[xx] := UpCase(ss[xx]);
End; { MakeCaps }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Procedure TrimString(Var ss:String);
Var xx:Integer;
Begin
  If (length(ss) < 1) Then exit;
  { remove leading spaces }
  While (ss[1] = chr(32)) Do Begin delete(ss,1,1);
  If (length(ss) < 1) Then exit; End;
  { remove trailing spaces }
  While (ss[length(ss)] = chr(32)) Do Delete(ss,length(ss),1);
  { remove imbedded spaces }
  xx := pos('  ',ss);
  While (xx <> 0) Do Begin Delete(ss,xx,1); xx := Pos('  ',ss); End;
End; { TrimString }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Procedure TCmdLine.Capitalize;
Begin
  MakeCaps(CommandLine);
End; { Capitalize }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Destructor TCmdLine.Done;   { I'm not sure what can/should be done here }
Begin
End; { CmdLine }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Function TCmdLine.GetActualProgram:String;
Begin
  GetActualProgram := ActualProgram;
End; { GetActualProgram }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Function TCmdLine.GetCallingProgram:String;
Begin
  GetCallingProgram := CallingProgram;
End; { GetCallingProgram }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Function TCmdLine.GetCommandLine:String;
Begin
  GetCommandLine := CommandLine;
End; { GetCommandLine }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Function TCmdLine.GetDivideChars:String;
Begin
  GetDivideChars := DivideChars;
End; { GetDivideChars }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Function TCmdLine.GetLaunchingProgram:String;
Begin
  GetLaunchingProgram := LaunchingProgram;
End; { GetLaunchingProgram }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Function TCmdLine.GetParameter(ParmStrIn:String;Var StrBack:String):Boolean;
Const AM:Char = Chr(254);
Var ss,PrmStr:String; ssLen,ParmLen:Integer;
  { =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
  Procedure SkipQuote(Var xx:Integer;WhichQuote:Char);
  Begin
    Inc(xx);
    While (xx <= ssLen) Do Begin
      If (ss[xx] = WhichQuote) Then Exit;
      Inc(xx);
      End;
  End; { SkipQuote }
  { =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
  Procedure Setup;
  Var xx,ll:Integer;
  Begin
    ss := CommandLine; MakeCaps(ss);
    PrmStr := ParmStrIn; MakeCaps(PrmStr);
    ssLen := Length(ss); ParmLen := Length(PrmStr);
    { change all dividechars into AMs }
    xx := 0;
    While (xx <= ssLen) Do Begin
       Inc(xx);
       Case ss[xx] Of
         '''','"','`': SkipQuote(xx,ss[xx]);
         Else If (Pos(ss[xx],DivideChars) > 0) Then ss[xx] := AM;
         End; { case }
       End; { while }
  End; { Setup }
  { =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
  Function IsThisIt(Var Start:Integer):Boolean;
  Var xx:Integer;
  Begin
    IsThisIt := False;
    For xx := 1 to ParmLen Do Begin
      If (ss[Start+xx] <> PrmStr[xx]) Then Exit;
      End; { yy }
    Start := Start+ParmLen;
    IsThisIt := True;
  End; { IsThisIt }
  { =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
  Function FindIt:Boolean;
  Var xx,yy,l1:Integer;
  Begin
    FindIt := False; StrBack := '';
    l1 := ssLen - ParmLen; If (l1 < 1) Then Exit;
    xx := 0;
    While (xx <= l1) Do Begin
       Inc(xx);
       If (ss[xx] = AM) Then Begin
          If IsThisIt(xx) Then Begin
             FindIt := True; yy := 0;
             { find the next AM, and copy the string out }
             While (xx+yy <= ssLen) And (ss[xx+yy] <> AM) Do Inc(yy);
             StrBack := Copy(CommandLine,xx+1,yy-1);
             { delete trailing space(s), if there }
             While (StrBack[Length(StrBack)] = ' ') Do
                Delete(StrBack,Length(StrBack),1);
             { we've got the answer, get out }
             Exit;
             End; { this is it }
          End; { found }
       End; { xx }
  End; { FindIt }
  { =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Begin
  { default to not found }
  GetParameter := False; StrBack := '';
  If (Length(CommandLine) < 1) or (CommandLine = NONE) Then Exit;
  If (Length(ParmStrIn) < 1) Then Exit;

  Setup; GetParameter := FindIt;
End; { GetParameter }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Constructor TCmdLine.Init;
  { =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
  Function LaunchedBy:String;
  Var ParentSeg:^word; p:pchar;
  Begin
    ParentSeg := ptr(PrefixSeg,$0016); p := ptr(ParentSeg^-1,8);
    LaunchedBy := StrPas(p);
  End; { LaunchedBy }
  { =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
  Function RealCommandLine:String;
  Var ss:String;
  Begin
    ss := StrPas(ptr(PrefixSeg,130));
    If (Ord(ss[0]) > 0) Then ss[0] := Chr(Ord(ss[0])-1);
    RealCommandLine := ss;
  End; { RealCommandLine }
  { =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
  Function ActualProgramName:String;
  Var cc:Char; ss:String; p:PChar; xx,yy:Byte;
  Begin
    p := ptr(PrefixSeg,228); ss := ''; xx := 0; yy := 0;
    Repeat
      cc := p[xx];
      If (cc <> #0)
         Then Begin
              If (Ord(cc) > 47) and (Ord(cc) < 126) Then Begin
                 ss := ss+' '; ss[Ord(ss[0])] := p[xx]; End;
              End
         Else Begin Inc(yy); If (yy = 1) Then ss := ss+'.'; End;
      Inc(xx);
      Until (xx > 12) or (yy > 1);
      If (ss[Ord(ss[0])] = '.') Then ss[0] := Chr(Ord(ss[0])-1);
    ActualProgramName := ss;
  End; { ActualProgramName }
  { -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Begin
  LaunchingProgram := LaunchedBy;        { what environment launched me }
  OriginalCommandLine := RealCommandLine;   { the original command line }
  If (Length(OriginalCommandLine) < 1) Then OriginalCommandLine := NONE;
  CommandLine := OriginalCommandLine;                { default to exact }
  CallingProgram := ActualProgramName;     { just what the user entered }
  ActualProgram := ParamStr(0);   { BP returns the fully qualitied name }

  SetDivideChars('-/');                   { set the default DivideChars }
End; { Init }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Procedure TCmdLine.Restore;
Begin
  CommandLine := OriginalCommandLine;
End; { Restore }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Procedure TCmdLine.SetDivideChars(NewDivideChars:String);
Begin
  DivideChars := NewDivideChars;
End; { SetDivideChars }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Procedure TCmdLine.Trim;
Begin
  TrimString(CommandLine);
End; { Trim }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }


{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }
Begin { main block }
  CommandLine.Init;
End. { main block }
{ =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= }



{ This is a test program showing some of the cmdline object functions }
Program whoami;
Uses DOS, CRT, CmdLine;
Var ss:String;
begin
  { show some general information that it returns }
  WriteLn('I was launched by [',CommandLine.GetLaunchingProgram,']');
  WriteLn('Program executed was [',CommandLine.GetCallingProgram,']');
  WriteLn('BP returnd [',CommandLine.GetActualProgram,']');
  WriteLn('Command line was [',CommandLine.GetCommandLine,']');

  { these will change the part that you can use }
  CommandLine.Capitalize; CommandLine.Trim;
  WriteLn('Fixed command line [',CommandLine.GetCommandLine,']');

  { this will return it to it's original value }
  CommandLine.Restore;
  WriteLn('Restored command line [',CommandLine.GetCommandLine,']');

  { check for the existance of some parameter }
  If CommandLine.GetParameter('s',ss)
     Then WriteLn('Parameter "s" was [',ss,']')
     Else WriteLn('Parameter "s" was not found');
  If CommandLine.GetParameter('ss',ss)
     Then WriteLn('Parameter "ss" was [',ss,']')
     Else WriteLn('Parameter "ss" was not found');
end.

{
------------------------------ test.bat ------------------------------
@Echo Off
whoami /a:france/b 'this-is "the" way'  /chest /store /left
whoami /aaa-bbb/s"this 'is'-it"   /sss
whoami -ss/shell

}