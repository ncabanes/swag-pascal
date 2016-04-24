(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0012.PAS
  Description: MAXFILES.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

{
>I'm searching For a possibility to access more then 20 (I don't know the exact
>number) Files at once With TP 7.0 (Real mode). I'll be happy if anyone can post
>me sourcecode and technical information - technical information alone would be
>enough, too.

Boland Magazin 6/92 (Hot Line) Writes:

There is error in Dos: it's equal what you in Config.sys after Files= Write,
it can manage only 15 (!) open Files. Here is an Unit to outwit it:
(should be as first, can be not in overlay, entry also in config.sys)
}

Unit maxFiles;

Interface

Const
  maxFile = 255;
  {for 250 open Files}
Var
  index: Integer;
  puffer: Array[1..maxFile] of Byte;

begin
  For index := 1 to maxFile do
    puffer[index] := $FF;
  For index := 1 to 5 do
    puffer[index] := mem[prefixseg:$18 + pred(index)];
  memw[prefixseg:$32] := maxFile;
  memw[prefixseg:$34] := ofs(puffer);
  memw[prefixseg:$36] := seg(puffer);
end.

