
{ Here are programs for Copying and Deleting directories. }

}

{****************************************************************************}

{                               Copy Directory                               }

{****************************************************************************}
{$S+}

{for large directories alocate some mem true $M compiler directive}
PROGRAM CopyDirectory;
USES DOS,CRT;
VAR DI: SearchRec;
    N1,WWW: string;

Procedure Coppy(Source, Target : String);

Var InFile, OutFile : File;
    Buffer          : Array[ 1..8192 ] Of Char;
    NumberRead,
    NumberWritten   : Word;
    Attr: Word;
    Time: LongInt;

begin

   Assign( InFile, Source );
   Reset ( InFile, 1 );     {This is Reset For unTyped Files}
   Assign  ( OutFile, Target );
   ReWrite ( OutFile, 1 );  {This is ReWrite For unTyped Files}
   Repeat
      BlockRead ( InFile, Buffer, Sizeof( Buffer ), NumberRead );
      BlockWrite( OutFile, Buffer, NumberRead, NumberWritten );
   Until (NumberRead = 0) or (NumberRead <> NumberWritten);
   Close( InFile );
   Close( OutFile );
   Assign( InFile, Source);
   GetFAttr(InFile, Attr);
   GetFTime(InFile, Time);
   Assign( OutFile, Target);
   SetFAttr( OutFile, Attr);
   SetFTime( OutFile, Time);

end;

FUNCTION FileExist(FileName: String) : Boolean;
VAR DirInfo: SearchRec;
BEGIN
     FindFirst(FileName, AnyFile, DirInfo);
     IF (DosError=0) THEN FileExist:=True
                     ELSE FileExist:=False;
END;

PROCEDURE CopyDir(Name1,Name2 : String);
VAR GR,GD: SearchRec;
    k,j: Integer;
BEGIN
     k:=0;
     MkDir(Name2);
     Name2:=FExpand(Name2);
     ChDir(Name1);
     FindFirst('*.*',AnyFile,GR);
     WHILE DosError = 0 DO
     BEGIN
          IF GR.Attr AND Directory <> 0 THEN k:=k+1
          ELSE Coppy(Name1+'\'+GR.Name, Name2+'\'+GR.Name);
          FindNext(GR);
     END;
     IF k>2 THEN
     BEGIN
          FindFirst('*.*', AnyFile, GR);
          WHILE DosError = 0 DO
          BEGIN
               j:=2;
               REPEAT
                     IF (GR.Name <> '.') AND (GR.Name <> '..') THEN
                     IF GR.Attr AND Directory <> 0 THEN
                     CopyDir(Name1+'\'+GR.Name, Name2+'\'+GR.Name);
                     FindNext(GR);
                     j:=j+1;
               UNTIL (j=k+1) OR (DosError <> 0);
          END;
     END;
END;


BEGIN
     WRITELN('                   CopyDir Version 1.0 by AMATRIX Software');
     Writeln;
     Writeln('     This is a freeware, you  can use it  and  distribute it as  you  wish.');
     Writeln('     CopyDir is part of Data Master Version 1.0 which is not yet releasted.');
     Writeln;
     Writeln('                            Programed by Kresimir Mihalj,  august, 1994.');
     Writeln('                            E-Mail:      piko@cromath.math.hr');
     Writeln;
     GetDir(0,www);
     www:=FExpand(www);
     IF (ParamStr(1)='/h') OR (ParamStr(1)='/H') THEN
     BEGIN
          Writeln('  USAGE:');
          Writeln;
          WRITELN('     You mut enter name of directory you copying and  name  of  nonexist');
          WRITELN('     directory where you copy.');
          Writeln('     Example:      CopyDir source target');
     END
     ELSE
     IF (ParamStr(1)='') OR (ParamStr(2)='') THEN
     BEGIN
          Writeln('  ERROR:');
          Writeln;
          WRITELN('     Enter /h switch for help.');
     END
     ELSE
     IF (ParamStr(1)<>'') AND ((ParamStr(1)<>'/h') OR (ParamStr(1)<>'/H')) AND (ParamStr(2)='') THEN
     BEGIN
          Writeln('  ERROR:');
          Writeln;
          WRITELN('     Enter /h switch for help.');
     END
     ELSE
     BEGIN
          IF FileExist(ParamStr(1)) THEN
          BEGIN
               FindFirst(ParamStr(1), AnyFile, DI);
               IF DI.Attr AND Directory <> 0 THEN
               BEGIN
                    IF FileExist(ParamStr(2)) THEN
                    BEGIN
                         Writeln('  ERROR:');
                         WRITELN;
                         Writeln('     ',ParamStr(2),' already exist.');
                    END
                    ELSE
                    BEGIN
                          N1:=FExpand(ParamStr(1));
                          CopyDir(N1,ParamStr(2));
                    END;
               END
               ELSE
               BEGIN
                    Writeln('  ERROR:');
                    Writeln;
                    Writeln('     ',ParamStr(1),' is not a directory')
               END;
          END
          ELSE
          BEGIN
               Writeln('  ERROR:');
               Writeln;
               Writeln('     ',ParamStr(1),' does not exist.');
          END;
     END;
     ChDir(www);
END.



{****************************************************************************}

{                               Delete Directory                             }

{****************************************************************************}

PROGRAM DeleteDirectory;
{for large directories alocate some mem true $M compiler directive}
USES DOS,CRT;
VAR DI: SearchRec;

FUNCTION FileExist(FileName: String) : Boolean;
VAR DirInfo: SearchRec;
BEGIN
     FindFirst(FileName, AnyFile, DirInfo);
     IF (DosError=0) THEN FileExist:=True
                     ELSE FileExist:=False;
END;


PROCEDURE DelDir(Name: String);
VAR k: Integer;
    DD: SearchRec;
    m,w: File;
    s: String;
BEGIN
     REPEAT
           ChDir(Name);
           k:=0;
           FindFirst('*.*', AnyFile, DD);
           While DosError=0 Do
           BEGIN
                IF DD.Attr AND ReadOnly <> 0 THEN
                BEGIN
                     Assign(m, DD.Name);
                     SetFAttr(m, Archive);
                END;
                IF DD.Attr AND Hidden <> 0 THEN
                BEGIN
                     Assign(m, DD.Name);
                     SetFAttr(m, Archive);
                END;
                IF DD.Attr AND SysFile <> 0 THEN
                BEGIN
                     Assign(m, DD.Name);
                     SetFAttr(m, Archive);
                END;
                IF DD.Attr <> Directory THEN
                BEGIN
                     Assign(m, DD.Name);
                     Rename(m, '$$$$$$$$.$$$');
                     REWRITE(m);
                     Close(m);
                     Erase(m);
                     Delay(100);
                END;
                FindNext(DD);
           END;
           FindFirst('*.*', AnyFile, DD);
           WHILE DosError = 0 DO
           BEGIN
                IF (DD.Name <> '.') AND (DD.Name <> '..') THEN
                BEGIN
                     IF DD.Attr AND Directory <> 0 THEN
                     BEGIN
                          DelDir(DD.Name);
                     END;
                END;
                FindNext(DD);
           END;
           FindFirst('*.*', AnyFile, DD);
           WHILE DosError = 0 DO
           BEGIN
                FindNext(DD);
                k:=k+1;
           END;
           IF k=2 THEN ChDir('..');
           RmDir(Name);
           GetDir(0, s);
     UNTIL (k=2);
END;

BEGIN
     WRITELN('                   DelDir Version 1.0 by AMATRIX Software');
     Writeln;
     Writeln('     This is a freeware, you  can use it  and  distribute it as you  wish.');
     Writeln('     DelDir is part of Data Master Version 1.0 which is not yet releasted.');
     Writeln;
     Writeln('                                WARNING !!!');
     Writeln('     DelDir erase & wipe ALL files in specified directory and all subdirs,');
     WRITELN('     no metter on attribute sets, so you cannot undelete erased files.');
     Writeln;
     Writeln('                            Programed by Kresimir Mihalj,  august, 1994.');
     Writeln('                            E-Mail:      piko@cromath.math.hr');
     Writeln;
     IF ParamStr(1)='' THEN
     BEGIN
          Writeln('  ERROR:');
          Writeln;
          Writeln('     Enter /h switch for help.');
     END
     ELSE
     IF (ParamStr(1)='.') OR (ParamStr(1)='..') THEN
     BEGIN
          Writeln('  ERROR:');
          Writeln;
          Writeln('     Cannot erase courent directory.');
     END
     ELSE
     IF (ParamStr(1)='/h') OR (ParamStr(1)='/H') THEN
     BEGIN
          Writeln('  USAGE: ');
          Writeln('     You must specify directory name which you wonna erase.');
          Writeln('     EXAMPLE:     DelDir batfiles');
     END
     ELSE
     IF FileExist(ParamStr(1)) THEN
     BEGIN
          FindFirst(ParamStr(1), AnyFile, DI);
          IF DI.Attr AND Directory <> 0 THEN DelDir(ParamStr(1)) ELSE
          BEGIN
                Writeln('  ERROR:');
                Writeln;
                Writeln('     ',ParamStr(1),' is not a directory.')
          END;
     END
     ELSE WRITELN('     ',ParamStr(1),' does not exist.');
END.
