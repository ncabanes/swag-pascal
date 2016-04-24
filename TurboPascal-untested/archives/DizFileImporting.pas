(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0036.PAS
  Description: Diz file importing
  Author: KIM FORWOOD
  Date: 11-22-95  13:33
*)

{
 LP> Ok like in bbs programs when you upload a file it checks for a
 LP> file_id.diz, if the file exists it inserts the description into the
 LP> dir listing, that is basically what i am trying to accomplish, but i
 LP> have no idea where to start, i need to add that code into a bbs
 LP> program i am working on, but everyoe i know has no idea how to do
 LP> that.

I'm not quite clear as to what you want exactly, but maybe the DIZExist()
function in the following program will be of some help to you. It reads the
ZIP file header and returns a boolean reflecting the existence of a
FILE_ID.DIZ file (it can be easily modified to retrieve various information
for all the files in the archive).

This code is tested:

{===========================================================================}
PROGRAM ZIPRead;

type
    ZFHeader = record
       Signature  : longint;
       Version,
       GPBFlag,
       Compress,
       Date,Time  : word;
       CRC32,
       CSize,
       USize      : longint;
       FNameLen,
       ExtraField : word;
    end;

var
   Hdr: ^ZFHeader;
   FName: string;

{-------------------------------------------------------}
FUNCTION DIZExist(ZIPFile: string): boolean;
const
   SIG = $04034B50;
var
   F: file;
   S: string;

begin
   New(Hdr);
   DIZExist := False;
   Assign(F, ZIPFile);
   {$I-}
   Reset(F,1);
   {$I+}
   if IoResult = 0 then
   repeat
      FillChar(S,SizeOf(S), #0);
      BlockRead(F,Hdr^,SizeOf(ZFHeader));
      BlockRead(F,Mem[Seg(S) : Ofs(S) + 1], Hdr^.FNameLen);
      S[0] := Chr(Hdr^.FNameLen);
      if (Hdr^.Signature = Sig) and (S = 'FILE_ID.DIZ') then
      begin
         DIZExist := True;
         Close(F);
         Exit;
      end;
      Seek(F,FilePos(F) + Hdr^.CSize + Hdr^.ExtraField);
   until Hdr^.Signature <> SIG;
   Close(F);
end;
{-------------------------------------------------------}

BEGIN
   FName := 'TEST.ZIP';
   if DIZExist(FName) then WriteLn('FILE_ID.DIZ is present.')
   else WriteLn('FILE_ID.DIZ is not present.');
END.
{===========================================================================}

Now if you want something that will extract the FILE_ID.DIZ file you will be
best off to use PKUNZIP rather than doing it via some source code that unzips
files, because the source code method will eventually fail due to version
differences.

To actually import the extracted file into your dir listing you are going to
have to either work it out yourself, or else give us specifics on how your
BBS program is currently designed in this area (i.e. actual code).

If you want more help with this I would be glad to give it...


        -- Kim Forwood --

