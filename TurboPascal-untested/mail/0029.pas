{
16 Dec 95 18:41, Adam Rutter wrote to Martin Woods:
 AR> ok, well I wanted to know how to CREATE an account in the RA
 AR> userbase.. sorry if I was unclear.. I said I wanted to know both,
 AR> but I know how to read from it already.. if you could post some
 AR> source on creating a user record I would appreciate it... thanks.

{ This is similar to the viewer except it will allow editing of the security
level and writes the new value to the users.bbs,using this as a guide you
could edit each of the other fields in the same way,I would suggest you copy
a users.bbs file into the current work dir to play with first: see main below
}
Program RA_Security_Edit;
Uses Crt, Dos;
{$I c:\ra\STRUCT.200}
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
   write(' Remote Access Security Edit');
   textattr:=$01;
   gotoxy(1,2);
   for a:=1 to 80 do write('═');
   gotoxy(1,23);
   for a:=1 to 80 do write('─');
   textattr:=15;
   gotoxy(3,24);
   Write('(PgUp) Last User    (PgDn) Next User    (C)hange Security   (ESC)
Exit');end;

Procedure Write_New_Record;
  begin
    gotoxy(2,24);clreol;
    write('Levels: [L]ockout, [U]nvalidated, [R]egular, [V]ip, [S]ysop. ?');
    repeat ch := upcase(readkey) until ch in ['L','U','R','V','S'];
      case ch of
        'L' : UserRec.security := 0;
        'U' : UserRec.security := 10;
        'R' : UserRec.security := 150;
        'V' : UserRec.security := 2000;
        'S' : UserRec.security := 65535;
      end;
          gotoxy(1,24); clreol;
          writeln('Writing User File One Moment...');
          delay(450);
          {$I-}
          seek(userfile,X);
          write(userfile,UserRec);
          {$I+}
       end;

Begin {main}
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
   UserPath := FixPath(SysRec.MsgBasePath);
   UserPath:=UserPath + 'USERS.BBS';
   {$I-}
> Assign(UserFile,{UserPath}'USERS.BBS'); { <- Copy a USERS.BBS file into the
} Reset(UserFile);                        { current dir to play with before
}   {$I+}                                 { you comment out UserPath
}    If IOresult <> 0 then Begin
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
   Writeln;
   Writeln('  User #    : ',X+1);
   Writeln('  Name      : ',Name);
   Writeln('  Handle    : ',Handle);
   WriteLn('  Security  : ',Security);
   WriteLn('  Location  : ',Location);
   WriteLn('  Data #    : ',DataPhone);
   WriteLn('  Home #    : ',VoicePhone);
   WriteLn('  Birthday  : ',BirthDate);
   Write('  Last Call : ',LastDate);
   WriteLn(' ',Lasttime);
          case Sex of
               1 : writeln ('  Sex       : Male');
               2 : writeln ('  Sex       : Female');
              else writeln ('  Sex       : Unknown');
            end;
   writeln('  Number of Calls :',NoCalls);
   end; {with}
    drawscreen;
    Ch := Readkey;
   if (ch=#0) then ch:=upcase(readkey);
   Case ch Of
     #81 : If X < FileSize(UserFile)-1 Then Inc(X);
     #73 : If X > 0 Then Dec(X);
     #27 : Done := True;
     #99 {'C'} : Write_New_Record;
 end;
   Until done;
    Close(UserFile);
    textattr:=$07;
    clrscr;
 End.
