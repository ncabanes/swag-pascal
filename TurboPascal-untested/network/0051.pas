 {
 Program Name : Phone.Pas
 Written By   : Anonymous
 E-Mail       : nothing
 Web Page     : nothing
 Program
 Compilation  : Turbo Pascal 5.0 or later

 Program Description :

 Usefulness for BBS'S and general communications.
 For a detailed description of this code source, please,
 read the file TENTOOLS.DOC. Thank you
 }

Program Phone;
{$F+}
Uses CRT,TenTools;

Type
  S80 = String[80];

Var
  RemoteID : S12;
  Caller : S12;
  NodeID   : S12;
  SendCount,I,TransType,Msgs : INteger;
  TransID : Real;
  SendString : S80;
  RcvString : S80;
  RcvLength : Integer;
  TenError : Word;
  Connect,Hangup,BeingCalled,Calling,CBMess : Boolean;
  X,Y,Gar : Integer;
  SendKey,SpecChar,Inchar : Char;

Procedure Ring;
Begin
   ClrScr;
   GotoXY(1,1);Write('With which node do you wish to converse: ');
   Readln(RemoteID);
   While Length(RemoteID)<12 do RemoteID:=RemoteID+' ';
   For I:=1 to 12 do RemoteID[I]:=Upcase(RemoteID[I]);
   ClrScr;
   SendString:='You are being "PHONE"ed...';
   TenError:=Chat(RemoteID,SendString);
   If TenError<>0
   then
    begin
       Writeln('Error Chatting...',TenError);
       Halt;
    end;
   SendCount:=0;
   TenError:=TBSend(RemoteID,SendString,Length(SendString)+1,SendCount,17,0);
   SendString:='';
   Window(1,1,80,25);
   GotoXY(1,25);
   TextColor(White);
   Write(
'Ringing ',RemoteID,'  (A)bort ');
   ClrEol;
   Caller:=RemoteID;
   Calling:=True;
End;

Procedure Ignore;
Begin
   SendString:='Cannot Talk Now...Sorry';
   TenError:=TBSend(RemoteID,SendString,Length(SendString)+1,SendCount,18,0);
   SendString:='';
   Caller:='';
   BeingCalled:=False;
   Hangup:=True;
End;

Procedure Answer;
Begin
   RemoteID:=Caller;
   SendCount:=0;
   SendString:='Responding...';
   TenError:=TBSend(RemoteID,SendString,Length(SendString)+1,SendCount,17,0);
   SendString:='';
   If TenError<>0
   then
    begin
       Writeln('Error Sending String to ',Caller);
       Halt;
    end;
End;

Procedure ClearBuffers;
Begin
   Repeat
      TenError:=TBReceive(RemoteID,RcvString,RcvLength,TransID,TransType,Msgs,CBMess);
   Until Msgs=0;
End;


Procedure Communicate;
Begin
   X:=1;
   Y:=11;
   TextColor(White);
   Window(1,1,80,25);
   GotoXY(1,25);
   Write(
'                          Press [F1] to end Conversation');
   GotoXY(1,12);
   Write(
'──────────────────────────────────     ',Caller,' ────────────────────────');
   Window(1,1,80,24);
   Repeat
      RcvLength:=0;
      TenError:=TBReceive(RemoteID,RcvString,RcvLength,TransID,TransType,Msgs,CBMess);
{      If Msgs>0 then Delay(20); }
      If ((TenError=0) and (Msgs>0))
      then while ((TenError=0) and (Msgs>0)) do
       begin
          TextColor(Red);
          Sound(1000);
          Delay(40);
          NoSound;
          GotoXY(1,WhereY);
          IF ((RemoteID=Caller)and(TransType=20))
          then
           begin
              Window(1,13,80,24);
              GotoXY(1,11);
              Writeln('');
              Writeln(RcvString);
           end;
          If ((RemoteID=Caller)and(TransType=19))
          then
           begin
              Window(1,13,80,24);
              GotoXY(1,11);
              Writeln('');
              Writeln(' ',RemoteID,' hung up!');
              Write(' Press any key to Continue...');
              InChar:=ReadKey;
              Hangup:=True;
              Calling:=False;
              Connect:=False;
              BeingCalled:=False;
              Caller:='';
              Msgs:=0;
           end;
          RcvString:='';
          If not Hangup then
          TenError:=TBReceive(RemoteID,RcvString,RcvLength,TransID,TransType,Msgs,CBMess);
          If Msgs>0 then Delay(20);
          If TenError<>0 then Writeln('10Net Error: ',TenError);
       end;
      If (Keypressed and not Hangup)
      then
       begin
          SendKey:=ReadKey;
          If SendKey=#0
          then
           begin
              SpecCHar:=ReadKey;
              If SpecCHar=#59
              then
               begin
                  Window(1,1,80,25);
                  GotoXY(1,25);
                  ClrEOL;
                  TextColor(White);
                  Write(
'                   (E)nd Communication  (C)ontinue Communication');
                  Repeat
                     Inchar:=Upcase(Readkey);
                  Until (Inchar in ['E','C']);
                  If Inchar='E'
                  then
                   begin
                      Hangup:=True;
                      Connect:=False;
                      Caller:='';
                      GotoXY(1,25);
                      ClrEol;
                      Write(
'                    Ending Communication...please wait...');
                      SendString:='CLICK';
                      TenError:=TBSend(RemoteID,SendString,Length(SendString)+1,SendCount,19,0);
                      SendString:='';
                      Window(1,1,80,25);
                      ClrScr;
                      Calling:=False;
                      BeingCalled:=False;
                   end;
                  GotoXY(1,25);
                  ClrEol;
                  GotoXY(1,25);
                  If not Hangup then
                  Write(
               '                          Press [F1] to end Conversation');
                  Window(1,1,80,24);
               end
              else Write(#7);
           end
          else if Sendkey=#13
          then
           begin
              Window(1,1,80,11);
              GotoXY(X,Y);
              Writeln('');
              X:=WhereX;
              Y:=WhereY;
              Inc(SendCount);
              TenError:=TBSend(RemoteID,SendString,Length(SendString)+1,SendCount,20,0);
              SendString:='';
           end
          else
           begin
              TextColor(Cyan);
              Window(1,1,80,11);
              GotoXY(X,Y);
              SendString:=SendString+SendKey;
              Write(SendKey);
              X:=WhereX;
              Y:=WhereY;
           end;
       end;
   Until Hangup;
   TextColor(White);
End;


Procedure ScreenCalls;
Begin
   Repeat
      TenError:=TBReceive(RemoteID,RcvString,RcvLength,TransID,TransType,Msgs,CBMess);
      If Msgs>0 then Delay(20);
      If Msgs>0
      then
       begin
          If Calling
          then
           begin
              If (RemoteID=Caller)
              then
               begin
                  If TransType=17 then Connect:=True;
                  If TransType=18
                  then
                   begin
                      GotoXY(1,25);
                      ClrEol;
                      Write(
'              Call Refused...');
                      Sound(1000);
                      Delay(1000);
                      NoSound;
                      Hangup:=True;
                      Calling:=False;
                   end;
               end;
           end
          else
           begin
              If ((TransType=17) and (Caller=''))
              then Caller:=RemoteID;
           end;
       end;
   Until (Msgs=0)
End;

Procedure ClearCalls;
Begin
   Window(1,1,80,25);
   ClrScr;
   GotoXY(1,25);
   Write('(R)ing someone  (Q)uit');
   Hangup:=False;
End;


Begin  { Main }
  TenError:=TenConfig(80,80,20);
  If TenError<>0
  then
   Begin
      Writeln('Error Configuring TenTools...',TenError);
      Halt;
   end;
  Connect:=False;
  BeingCalled:=False;
  Calling:=False;
  Hangup:=False;
  TextBackground(Black);
  TextColor(Cyan);
  Window(1,1,80,25);
  ClrScr;
{Main Menu}
  ClearBuffers;
  Repeat
     ClearCalls;
      Repeat
         ScreenCalls;
         If Connect
         then Communicate
         else if Keypressed
         then
          begin
             Inchar:=Upcase(Readkey);
             If not (Inchar in ['A','I','R','Q']) then Write(#7);
             If ((Inchar='A') and BeingCalled)
              then
               begin
                  Answer;
                  Communicate;
               end
             else if ((Inchar='A')and Calling)
             then
              begin
                 Calling:=False;
                 Hangup:=True;
                 Caller:='';
              end
             else if Inchar='I'
             then Ignore
             else if Inchar='R'
             then
              begin
                 If Calling then Ignore;
                 Ring;
              end
             else
              begin
                 Hangup:=True;
                 Sound(2000);
                 Delay(10);
                 NOsound;
              end;
          end
         else if ((Caller<>'')and not (Calling or BeingCalled))
         then
          begin
             BeingCalled:=True;
             GotoXY(1,25);
             Write('(R)ing someone (A)nswer  (I)gnore  (Q)uit');
          end;
      Until Hangup;
  Until Inchar in ['Q','q'];
  ClearBuffers;
End.  { Program TenTAlk}
