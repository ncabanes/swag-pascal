{

 RS>    Can anyone tell me where to find some source dealing with archive
 RS> detection?  I need to be able to determine what archival method was used
 RS> on a file regardless of the extension..

Yep.

BTW: I cut it out of a source I made it for. I should compile as is. you might
have to "USES" dos and/or CRT.

----------------------------= CUT HERE =-------------------------------------
}

Type
     ArchiveType = (ARJ,ZIP,UC2,LZH,UNKNOWN);

Function GetArchiveType (Name : String) : Archivetype;
Var F : File;
    Buf: Word;
    StrBuf : String [3];
Begin
  GetArchiveType := UNKNOWN;
  Assign (F,Name);
  FileMode := 0;
  Reset (F,1);
  If IoResult <> 0 Then
  Begin
    Write ('Unable to access file - ');
    WriteLn (Name);
    Exit;
  End;
  BlockRead (F,Buf,2);
  If Buf = $EA60 Then
  Begin
    GetArchiveType := ARJ;
    Close (f);
    Exit;
  End;
  If Buf = $4b50 Then
  Begin
    GetArchiveType := ZIP;
    Close (f);
    Exit;
  End;
  If Buf = $4355 Then
  Begin
    GetArchiveType := UC2;
    Close (f);
    Exit;
  End;
  BlockRead (F,StrBuf[1],3);
  StrBuf[0] := #3;
  If StrBuf = '-lh' Then
  Begin
    GetArchiveType := LZH;
    Close (f);
    Exit;
  End;
End;

