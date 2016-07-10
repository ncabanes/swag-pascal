(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0001.PAS
  Description: Get Archive ID
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

{
 > I'm looking For descriptions of the formats of headers in
 > all popular archive Files, ie .ZIP, .ARC, .LZH, .ARJ, etc.
 > I just want to be able to read the headers of all of these
 > archives, not necessarily manipulate them.  Anyone know
 > where such can be had?

Here's a Program that will determine most of the major archive Types.
I've made a couple of additions, but the original source was from
a message on this echo...the original author's name has since been
lost.  To use the Procedure, just call it as follows:
 If GetArcType(FileName.Ext)=Zip then....
}

Uses
  Dos;

Type
  ArcType = (FileError, Unknown, Zip, Zoo, Arc, Lzh, Pak, Arj);

Function GetArcType(FName : String) : ArcType;
Var
  ArcFile : File of Byte;
  i       : Integer;
  Gat     : ArcType;
  c       : Array[1..5] of Byte;
begin
  Assign(ArcFile, FName);
  {$I-}
  Reset(ArcFile);
  {$I+}
  if IOResult <> 0 then
    Gat := FileError
  else
  if FileSize(ArcFile) < 5 then
    Gat := FileError
  else
  begin
    For i := 1 to 5 do
      Read(ArcFile, c[i]);
    Close(ArcFile);
    if ((c[1] = $50) and (c[2] = $4B)) then
      Gat := Zip
    else
    if ((c[1] = $60) and (c[2] = $EA)) then
      Gat := Arj
    else
    if ((c[4] = $6c) and (c[5] = $68)) then
      Gat := Lzh
    else
    if ((c[1] = $5a) and (c[2] = $4f) and (c[3] = $4f)) then
      Gat := Zoo
    else
    if ((c[1] = $1a) and (c[2] = $08)) then
      Gat := Arc
    else
    if ((c[1] = $1a) and (c[2] = $0b)) then
      Gat := Pak
    else
      Gat := Unknown;
  end;

  GetArcType := Gat;
end;

Var
  FileName : String;
  Return   : ArcType;
  {ArcType = (FileError,Unknown,Zip,Zoo,Arc,Lzh,Pak,Arj)}


begin
 if ParamCount = 1 then
 begin
   FileName := ParamStr(1);
   Return   := GetArcType(FileName);
   Case Return of
     ARJ     : Writeln(FileName, ' = ARJ ');
     PAK     : Writeln(FileName, ' = PAK ');
     LZH     : Writeln(FileName, ' = LZH ');
     ARC     : Writeln(FileName, ' = ARC ');
     ZOO     : Writeln(FileName, ' = ZOO ');
     ZIP     : Writeln(FileName, ' = ZIP ');
     UNKNOWN : Writeln(FileName, ' = Unknown!')
     else
       Writeln('File Not Found');
   end;
 end {IF}
 else
  Writeln('No parameter');
end.
