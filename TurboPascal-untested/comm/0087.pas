{
{This program will find the RA enviroment,open up CONFIG.RA and get the
path to the message base as it is entered in RACONFIG,then open up the
USERS.BBS as found in the message base,then list all users by scrolling
with the PgUp/PgDn keys,this program does not do anything exept *view* the
users,as such it is a good learning tool and a skeleton for a user Editor}

Program RA_User_Viewer;
Uses Crt, Dos;
{$I STRUCT.200}
Var
   UserRec : USERSrecord;
   UserFile : File of USERSrecord;
   SysPath : String;
   SysRec: CONFIGrecord;
   SysFile : File of CONFIGrecord;
   X,a : Integer;
   Y : LongInt;
   Done : Boolean;
   Ch : Char;

Begin
   ClrScr;
   SysPath := GetEnv('RA'); {find out where RA is}
       if SysPath[length(SysPath)] <> '\' then
       SysPath := SysPath + '\';
       SysPath := SysPath + 'CONFIG.RA';
   {$I-}
   Assign(SysFile,Syspath);
   Reset(SysFile);
    {$I+}
    If IOresult <> 0 then Begin
    WriteLn(' Error Reading ',SysPath);
    WriteLn(' Exiting with Errorlevel 1');
    Halt(1);   {Exit At Errorlevel 1, RA or Config.ra not found}
    End;

   read(SysFile,SysRec); {open up CONFIG.RA and find the *Path* to the}
                         { Messsage base,(where users.bbs is stored) }
   Close(SysFile);       {and close it up right away}

   SysPath := GetEnv('RA'); {start again here to find the Users.bbs}
                            {from the above Path}
   SysPath := SysRec.MsgBasePath + 'USERS.BBS';
   {$I-}
   Assign(UserFile,Syspath);
   Reset(UserFile);
   {$I+}
    If IOresult <> 0 then Begin
     WriteLn(' Error Reading ',SysPath);
     WriteLn(' Exiting with Errorlevel 2');
     Halt(2);   {Exit At Errorlevel 2 ,RA\Msgbase or Users.bbs not found}
    End;
   X := 0;
   Done := False;
Repeat
   textattr:=$07;
   ClrScr;
   Seek(UserFile, X);
   Read(UserFile, UserRec);
   gotoxy(1,3);
   Writeln('User #    : ',X+1);
   Writeln('Name      : ',UserRec.Name);
   Writeln('Handle    : ',UserRec.Handle);
   WriteLn('Security  : ',UserRec.Security);
   WriteLn('Location  : ',UserRec.Location);
   WriteLn('Data #    : ',UserRec.DataPhone);
   WriteLn('Home #    : ',UserRec.VoicePhone);
   WriteLn('Birthday  : ',UserRec.BirthDate);
   Write('Last Call : ',UserRec.LastDate);
   WriteLn(' ',UserRec.Lasttime);
   IF UserRec.Sex=0 THEN WriteLn('Sex       : Unknown');
   IF UserRec.Sex=1 THEN WriteLn('Sex       : Male');
   IF UserRec.Sex=2 THEN WriteLn('Sex       : Female');
   WriteLn('Addr 1    : ',UserRec.Address1);
   WriteLn('Addr 2    : ',UserRec.Address2);
   WriteLn('Addr 3    : ',UserRec.Address3);
   Writeln('Msg''s Posted : ',UserRec.Msgsposted);
   Writeln('Last Read    : ',UserRec.Lastread);
   Writeln('Msg Group    : ',UserRec.Msggroup);
   Writeln('Msg Area     : ',UserRec.Msgarea);
   WriteLn('Comment      : ',UserRec.Comment);
   gotoxy(46,3);
   writeln('Files Downloaded   : ',UserRec.Downloads);
   gotoxy(46,4);
   writeln('Download Kilobytes : ',UserRec.Downloadsk);
   gotoxy(46,5);
   Writeln('Files Uploaded     : ',UserRec.Uploads);
   gotoxy(46,6);
   writeln('Upload Kilobytes   : ',UserRec.Uploadsk);
   gotoxy(46,7);
   writeln('Credits  : ',UserRec.Credit);
   gotoxy(46,8);
   writeln('Protocol : ',UserRec.DefaultProtocol);
   gotoxy(46,9);
   writeln('Language : ',UserRec.Language);
   gotoxy(46,10);
   writeln('Number of Calls :',UserRec.NoCalls);
   textattr:=14;
   gotoxy(25,1);
   write(' Remote Access User Viewer');
   textattr:=$01;
   gotoxy(1,2);
   for a:=1 to 80 do write('═');
   gotoxy(1,23);
   for a:=1 to 80 do write('─');
   textattr:=15;
   gotoxy(1,24);
   Write('        (PgUp) Last User     (PgDn) Next User     (ESC) Exit');
    Ch := Readkey;
   Case ch Of
     #81 : If X < FileSize(UserFile)-1 Then Inc(X);
     #73 : If X > 0 Then Dec(X);
     #27 : Done := True;
     #0 : Begin
      end;
   End;
Until done;
Close(UserFile);
End.
