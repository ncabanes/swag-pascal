{
 > Your approach (as all similar ones I have seen so Far) has a major
 > drawback: you can't use PKLITE, TinYPROG, LZEXE afterwards to
 > squeeze them down in size, as the offsets of the Program change.
 > Has anyone come up With a another approach circumventing this?

Yes, you can store it at the end of the .EXE File ( after the
code ) With the following routine :
}

Function CodeLenOnDisk( FName : String ) : LongInt;
Var ImageInfo : Record
                  ExeID     : Array[ 0..1 ] of Char;
                  Remainder : Word;
                  Size : Word
                end;
    F        : File;
begin
  Assign( F, FName );
  Reset( F, 1 );
  if Ioresult <> 0 then Exit;
  BlockRead( F, ImageInfo, Sizeof( ImageInfo ));
  if ImageInfo.ExeID <> 'MZ' then Exit;
  CodeLenOnDisk := LongInt( ImageInfo.size-1 )*512 + ImageInfo.Remainder;
end;

{
With this one, you can determine the end of the code in your .EXE File,
and then Write other data there, Drawback : This Dosen't work in network
environments or With shared .EXE Files. I'd recommend an external passWord
File, and there storing a hash of the passWord.
}
