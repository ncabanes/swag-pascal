(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0030.PAS
  Description: RemoteAccess User Viewer
  Author: MARTIN WOODS
  Date: 02-21-96  21:04
*)

{
AR> Could someone give me sample source code to access the RA USER FILE
This should help get you started...
}
Program RA_User_Viewer;
Uses Crt, Dos;
{$I STRUCT.200}
Var
   UserRec : USERSrecord;
   UserFile : File of USERSrecord;
   SysPath,UserPath,ConfigPath : String;
   SysRec: CONFIGrecord;
   SysFile : File of CONFIGrecord;
   X,a : Integer;
   Done : Boolean;
   Ch : Char;

Function FixPath(Path : String): String;
    Begin
    If Path[Length(Path)] <> '\' Then
        Path := Path+'\';
     FixPath := Path;
    End;
procedure drawscreen;
begin;
    textattr:=14;
    gotoxy(25,1);
   write(' Remote Access User Viewer');
   textattr:=$01;
   gotoxy(1,2);
   for a:=1 to 80 do write('═');
   gotoxy(1,23);
   for a:=1 to 80 do write('─');
   textattr:=15;
   gotoxy(11,24);
   Write('(PgUp) Last User     (PgDn) Next User     (ESC) Exit');
end;

Begin
   ClrScr;
   SysPath := GetEnv('RA');           {[drive]:\RA}
       SysPath := Fixpath(SysPath);   {[drive]:\RA\}
       ConfigPath := SysPath + 'CONFIG.RA'; {[drive]:\RA\CONFIG.RA}
   {$I-}
   Assign(SysFile,ConfigPath);
   Reset(SysFile);
    {$I+}
    If IOresult <> 0 then Begin
    WriteLn(' Error Reading ',ConfigPath);
    WriteLn(' Exiting with Errorlevel 1');
    Halt(1);  {Exit at errorlevel 1,[drive]:\RA\CONFIG.RA not Found}
    End;      {Is the enviroment variable set?}
   read(SysFile,SysRec); {open up CONFIG.RA and find the Path to the}
                         { Messsage base,(where users.bbs is stored) }
   Close(SysFile);
   UserPath := FixPath(SysRec.MsgBasePath); { here it is! }
   UserPath:=UserPath + 'USERS.BBS';
   {$I-}
   Assign(UserFile,UserPath);
   Reset(UserFile);
   {$I+}
    If IOresult <> 0 then Begin
     WriteLn(' Error Reading ',UserPath);
     WriteLn(' Exiting with Errorlevel 2');
     Halt(2);{Exit At Errorlevel 2,[drive]:\Msgbase\Users.bbs not found}
    End;
   X := 0;
   Done := False;
Repeat
   textattr:=$07;
   ClrScr;
   Seek(UserFile, X);
   Read(UserFile, UserRec);
   gotoxy(1,3);
   with UserRec do
   Begin
   Writeln('User #    : ',X+1);
   Writeln('Name      : ',Name);
   Writeln('Handle    : ',Handle);
   WriteLn('Security  : ',Security);
   WriteLn('Location  : ',Location);
   WriteLn('Data #    : ',DataPhone);
   WriteLn('Home #    : ',VoicePhone);
   WriteLn('Birthday  : ',BirthDate);
   Write('Last Call : ',LastDate);
   WriteLn(' ',Lasttime);
          case Sex of
               1 : writeln ('Sex       : Male');
               2 : writeln ('Sex       : Female');
              else writeln ('Sex       : Unknown');
            end;
   WriteLn('Addr 1    : ',Address1);
   WriteLn('Addr 2    : ',Address2);
   WriteLn('Addr 3    : ',Address3);
   Writeln('Msg''s Posted : ',Msgsposted);
   Writeln('Last Read    : ',Lastread);
   Writeln('Msg Group    : ',Msggroup);
   Writeln('Msg Area     : ',Msgarea);
   WriteLn('Comment      : ',Comment);
   gotoxy(46,3);
   writeln('Files Downloaded   : ',Downloads);
   gotoxy(46,4);
   writeln('Download Kilobytes : ',Downloadsk);
   gotoxy(46,5);
   Writeln('Files Uploaded     : ',Uploads);
   gotoxy(46,6);
   writeln('Upload Kilobytes   : ',Uploadsk);
   gotoxy(46,7);
   writeln('Credits  : ',Credit);
   gotoxy(46,8);
   writeln('Protocol : ',DefaultProtocol);
   gotoxy(46,9);
   writeln('Language : ',Language);
   gotoxy(46,10);
   writeln('Number of Calls :',NoCalls);
   end; {with}
    drawscreen;
    Ch := Readkey;
   if (ch=#0) then ch:=readkey;
   Case ch Of
     #81 : If X < FileSize(UserFile)-1 Then Inc(X);
     #73 : If X > 0 Then Dec(X);
     #27 : Done := True;
end;
Until done;
Close(UserFile);
textattr:=$07;
clrscr;
End.

