
{ Updated DATATYPE.SWG on May 26, 1995 }

{
> Is there any way to append an untyped file onto a text file
> in tp?  you can't append an untyped file, so I can't think
> of any way to do this.

Well, the thing with untyped (and typed, only not text) files is that appending
is so easy (once you know), there isn't a procedure for, it's just seeking to
the end of the file.So you just open the textfile as binary file, and seek to
the end of file.

Example (untested):
}

var
 F:file;
begin
 assign(F,'textfile.txt');
 reset(F,1);
 Seek(F,FileSize(F));
 BlockWrite(F,Data,SizeOf(Data))
 Close(F);
end.
{
And Data is appended to the textfile.


I don't think you need to following, but now I'm writing in this echo anyway, I
like to share the it.I made something to seek in a textfile, i.e. if you know
the offset of a line (not the linenumber), it's possible to seek directly to
it, without reading all the lines before it first. TP doesn't allow this, but
with typecasting I got it working. Maybe someone is interested...

}
program Test;
{ Show how to seek to an OFFSET (not a line number) in a textfile, }
{ without using asm. Arne de Bruijn, 1994, PD }
uses Dos; { For TextRec and FileRec }
var
 F:text;
 L:longint;
 S:string;
begin
 assign(F,'TEST.PAS');                 { Assign F to itself }
 reset(F);                             { Open it (as a textfile) }
 ReadLn(F);                            { Just read some lines }
 ReadLn(F);
 ReadLn(F);
 FileRec((@F)^).Mode:=fmInOut;         { Set to binary mode }
  { (The (@F)^ part is to let TP 'forget' the type of the structure, so }
  {  you can type-caste it to everything (note that with and without (@X)^ }
  {  can give a different value, longint(bytevar) gives the same value as }
  {  bytevar, while longint((@bytevar)^) gives the same as }
  {  longint absolute Bytevar (i.e. all 4 bytes in a longint are readed }
  {  from memory instead of 3 filled with zeros))) }
 FileRec((@F)^).RecSize:=1;            { Set record size to 1 (a byte)}
 L:=(FilePos(File((@F)^))-TextRec(F).BufEnd)+TextRec(F).BufPos;
  { Get the fileposition, subtract the already readed buffer, and add the }
  { position in that buffer }
 TextRec(F).Mode:=fmInput;             { Set back to text mode }
 TextRec(F).BufSize:=SizeOf(TextBuf);  { BufSize overwritten by RecSize }
                                       { Doesn't work with SetTextBuf! }
 ReadLn(F,S);                          { Read the next line }
 WriteLn('Next line:',S);              { Display it }
 FileRec((@F)^).Mode:=fmInOut;         { Set to binary mode }
 FileRec((@F)^).RecSize:=1;            { Set record size to 1 (a byte)}
 Seek(File((@F)^),L);                  { Do the seek }
 TextRec(F).Mode:=fmInput;             { Set back to text mode }
 TextRec(F).BufSize:=SizeOf(TextBuf);  { Doesn't work with SetTextBuf! }
 TextRec(F).BufPos:=0; TextRec(F).BufEnd:=0; { Reset buffer counters }
 ReadLn(F,S);                          { Show that it worked, the same }
 WriteLn('That line again:',S);        { line readed again! }
 Close(F);                             { Close it }
end.
