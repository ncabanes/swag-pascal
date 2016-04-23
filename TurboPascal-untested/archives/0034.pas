{FILE_ID.DIZ importer for RA 2.xx, exec from ramgr.exe
 dizzy.exe @ C:\PK\ C:\RA }
{$A+,B-,D+,E+,F-,G+,I+,L+,N+,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 4384,0,4045}
uses dos, Crt, mytoolbx;
Var iii : byte;
Begin
     Clrscr;
     Writeln(' fileid.DIZzy eXtractor v.1.0 by: Chris Evans (c) 1995 ');
     Writeln(' For RAMGR.EXE; A remoteAccess utility! ');
     for iii := 1 to 80 do Write(#196);
     If Paramcount = 0 then Err('syntax :',Paramstr(0) +
     ' <archive.zip> <path to pkunzip.exe> <ra home dir> ',11,15,254);
     Write('Working...');
     If fileexist(ParamStr(2) + 'PKUNZIP.EXE') = false then
        err('■','cannot find archiver.',12,15,1);
     If fileexist(ParamStr(1)) = true then
     begin
swapvectors;
Exec(ParamStr(2) + 'PKUNZIP.EXE',ParamStr(1) + ' File_id.diz ' + ParamStr(3));
swapvectors;
If fileexist(ParamStr(3) + 'RAMGRBUF.$00') = true then
   deletefile(ParamStr(3) + 'RAMGRBUF.$00');
RenameFile(ParamStr(3) + 'FILE_ID.DIZ', ParamStr(3) + 'RAMGRBUF.$00');
     end
     else
     begin
          Err('■','target not found failure.',12,15,2);
     end;
    Writeln('Done!');
end.
