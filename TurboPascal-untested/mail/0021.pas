{
> Is there somebody who can give me an example of
> how to write an JAM Base message (RemoteAccess) ?

> I already have JAMAPI and MKMSG I'll need just an simple unit how to
> write fast and simple an message to the JAM base..

Try this... It should work with the standard JAMAPI (I think, at least I
can't remember changing anything in it). It's a little piece of testcode
I wrote to play around with JAM :
}
Program JAMTest;

Uses
  JAM, JAMmb, JAMcrc32;

Var
  JAMMsg     : JAMAPIPTR;
  ToUsername : String[100];
  Position   : LongInt;
  S          : String;
  MsgNo      : LongInt;
  Error      : Boolean;

Function FileLength (Handle:INTEGER) : LongInt;
Var
  Position : LongInt;
Begin
  Position   := JAMMsg^.SeekFile (Handle, 1, 0);
  FileLength := JAMMsg^.SeekFile (Handle, 2, 0);
  JAMMsg^.SeekFile (Handle, 0, Position);
End; { FileLength }


Begin
  New (JAMMsg, Init);
  New (JAMMsg^.WorkBuf);
  With JAMMsg^ Do
  Begin
    If (WorkBuf <> NIL) Then
    Begin
      WorkLen  := SizeOf(JAMBUF);
      BaseName := 'ANOTHER';

      Error := Not OpenMB;
      If Error Then Error := Not CreateMB;
      If Not Error Then
      Begin
        If LockMB(True) Then
        Begin

          MsgNo := (FileLength(IdxHandle) Div SizeOf(JAMIDXREC)) +
                   HdrInfo.BaseMsgNum;
          Hdr.MsgNum := MsgNo;

          (* Add an index record *)
          ToUsername := 'Marco Miltenburg';
          With Idx Do
          Begin
            S := ToUsername;
            LowCaseBuf (S[1], Length(S));
            UserCRC   := crc32(S[1], Length(S), -1);
            HdrOffset := FileLength (JAMMsg^.HdrHandle);
          End;
          StoreMsgIdx(MsgNo);

          Position := 1;
          FillChar (Workbuf^, SizeOf(WorkLen), #0);
          S := 'This is a test in JAM.'#13#10;
          AddField (0, FALSE, Length(S), Position, S[1]);
          S := '--- WhatEver/386 v0.0'#13#10;
          AddField (0, FALSE, Length(S), Position, S[1]);
          Hdr.TxtLen := Position - 1;
          Hdr.TxtOffset := FileLength(TxtHandle);
          StoreMsgTxt;

          FillChar (Workbuf^, SizeOf(WorkLen), #0);
          S := 'WhatEven/386 v0.0'; Position := 1;
          AddField (2, TRUE, Length(S), Position, S[1]);
          S := ToUserName;
          AddField (3, TRUE, Length(S), Position, S[1]);
          S := 'Just a message';
          AddField (6, TRUE, Length(S), Position, S[1]);
          S := 'WhatEver/386 v0.0';
          AddField (7, TRUE, Length(S), Position, S[1]);

          With Hdr Do
          Begin
            ReservedWord := 0;
            SubfieldLen    := Position;
            TimesRead    := 0;
            MsgIdCRC     := -1;
            ReplyCRC     := -1;
            ReplyTo      := 0;
            Reply1st     := 0;
            ReplyNext    := 0;
            DateWritten    := 0;
            DateReceived := 0;
            DateProcessed:= 0;
            Attribute    := MSG_LOCAL Or MSG_PRIVATE Or MSG_TYPEECHO;
            Attribute2   := 0;
            PasswordCRC  := -1;
            Cost         := 0;
          End; { With }

          StoreMsgHdr(MsgNo);
          WriteFile(HdrHandle, WorkBuf^, Position);

          Inc(HdrInfo.ActiveMsgs);
          UpdHdrInfo(True);

        End { If }
        Else
          WriteLn ('Unable to lock JAM base ''', BaseName,'''');

      End { If }
      Else
        WriteLn ('Unable to open JAM base ''', BaseName,'''');

      Dispose (WorkBuf);
      Dispose (JAMMsg);
    End { If }
    Else
      WriteLn ('Unable to allocate Work Buffer memory');
  End; { With }
End.
