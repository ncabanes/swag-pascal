(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0006.PAS
  Description: Making a FIDO Message
  Author: MARK LEWIS
  Date: 08-27-93  21:32
*)

{
MARK LEWIS

> I've been playing with those files in MKMSG101.ZIP ... I've had
> them for awhile, but cannot get them to work.
 > All I'm trying to do is make a simple message in FIDO format for
 > my BBS.  Does anyone have any examples?

little to no error checking... tossed together from part(s) of the sample
WRITEMSG.PAS example that comes with MKMSGSRC...
}

program sample_MKMSG_code;

{ reads a text file specified on the command line and posts it
  to specified directory in *.MSG format. }

Uses
  DOS, CRT, MKString, MKGlobt,
  MKMsgAbs, MKFile, MKDos, MKMsgFid;

Var
  TheMSG  : AbsMsgPtr;
  Error   : Boolean;
  MSGDir,
  TheName,
  TheLine : String;
  TheFile : Text;
  MSGNum  : Word;

Begin
  If ParamCount < 2 Then
  Begin
    Writeln('Usage : ' + Paramstr(0) + ' <MSG Dir> <Text file to post>');
    halt(1);
  End;
  Error   := False;
  MSGDir  := WithBackSlash(Upper(Paramstr(1)));
  TheName := Upper(Paramstr(2));
  Assign(TheFile, TheName);
  {$I-}
  Reset(TheFile);
  {$I+}
  Error := IOResult <> 0;
  If Not Error Then
  Begin
    TheMSG := New(FidoMsgPtr, Init);
    TheMSG^.SetMsgPath(MSGDir);
    Error := (TheMSG^.OpenMsgBase <> 0);
    If Not Error Then
    Begin
      TheMSG^.SetMailType(mmtNormal);
      TheMSG^.StartNewMsg;
      TheMSG^.SetFrom('SysOp');
      TheMSG^.SetTo('ALL');
      TheMSG^.SetSubj(TheName);
      TheMSG^.SetPriv(False);
      TheMSG^.SetDate(DateStr(GetDosDate));
      TheMSG^.SetTime(TimeStr(GetDosDate));
      TheMSG^.SetLocal(True);
      TheMSG^.SetEcho(False);
      TheMSG^.SetRefer(0);
      While Not EOF(TheFile) Do
      Begin
        ReadLn(TheFile, TheLine);
        TheMSG^.DoStringLn(TheLine);
      End;
      Error := TheMSG^.WriteMsg <> 0;
      If Not Error Then
      Begin
        MsgNum := TheMSG^.GetMsgNum;
        Writeln('File ', TheName, ' posted to Area ', MSGDir, ' as MSG # ',
                MSGNum,'.');
      End
      Else
      Begin
        Writeln('Message Creation Error!');
        Halt(4);
      End;
      If TheMSG^.CloseMsgBase <> 0 Then; {Close msg base}
    End
    Else
    Begin
      Writeln('Cannot Open Message Area ', MSGDir, '!');
      Dispose(TheMSG, Done); {Dispose of the object pointer}
      Halt(3);
    End;
    Dispose(TheMSG, Done); {Dispose of the object pointer}
  End
  Else
    Writeln('OOPS! Cannot Locate File ', TheName, '!');
End.

