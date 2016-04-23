
Hi

> From:          Henry Holland <hholland@CNO.COM.BR>
> Can someone perhaps give me the pascal translation of the
> GetVolumeInformation C-function? I'm not exactly sure how to
> implement these windows API functions - which parameters are
> variable?

Here's a little bit of what I used.  Does it make any sense?

procedure YaddaYaddaYadda;
VAR
 RootPathBuf, VolNameBuf,FileSysNameBuf : PChar;
 NameBufSize, VolSerialNumber,
 MaxFileNameLength,FileSysFlags : dword;
Begin
  NameBufSize := 256;
  RootPathBuf := StrAlloc(NameBufSize);
  VolNameBuf := StrAlloc(NameBufSize);
  FileSysNameBuf := StrAlloc(NameBufSize);
  RootPathBuf := 'A:\';
  IF GetVolumeInformation(RootPathBuf,VolNameBuf,NameBufSize,
              @VolSerialNumber,MaxFileNameLength,
              FileSysFlags,FileSysNameBuf,NameBufSize)
   THEN
     Begin
       Whatever;
     End;
  StrDispose(RootPathBuf);
  StrDispose(VolNameBuf);
  StrDispose(FileSysNameBuf);
end;

