{
OK. Maybe this isn't exactly what you were asking for, but I've seen quite a
number of variations on this peeka-boo-into-the-exe-file, so I felt I just had
to write a comment to this matter.

   Using some kind of a magic constant, which is then searched for in the exe
file, probably is the most common approach to this kind of problem. But there's
really no need to do a search. You can calculate exactly where any const is (or
should be) located.

   The trick is to use a couple of simple facts:

   1/ The size of the exe header, in paragraphs, is located at byte 8 in the
header (actually it's a word made up by bytes 8 and 9 but I still haven't seen
an exe header of more than 4k, so I make it simple for myself using only the
byte).

   2/ After the exe header comes the code segment and then directly the data
segment. Thus the size of the code segment can be calculated by a simple dseg-
cseg. Still talking paragraphs.

   3/ Now we've reached the data segment in the exe file. The location in the
data segment can be found with ofs. Here we're talking bytes.

   Using these facts, here's a simple sample that let's you change a const
string to whatever paramstr(1) you supply. Hope you'll be able to pick out the
stuff you may find any need for.

   Since this code was extracted from a pretty small program I once wrote, it
uses the rather crude method to read the entire exe file into a buffer, and
then creating a new file blockwriting the entire buffer. If your program is
larger than 64k you obviously need to use some other method.
}

program SelfModifier;   (* Looks for a const and alters it *)
                        (* Puts paramstr(1) into Name *)

const
    Name : string = 'Fix me up';      {get 256 bytes to play with}
type
    Buffer = array[0..$3fff] of byte;
var
    ExeFile : file;
    P       : ^Buffer;
    N,I,O   : word;
    NStr    : string;

begin
 begin
  new(P);                             {get mem for our buffer}
  assign(ExeFile,paramstr(0));        {get myself}
  reset(ExeFile,1);
  blockread(ExeFile,P^,sizeof(Buffer),N);
  close(ExeFile);                     {got it into Buf, now close it}
  O:=(dseg-cseg+word(P^[8])) shl 4;   {start of data seg in exe file}
  writeln('Name: ',Name);
  NStr := paramstr(1);                {new string to put in Name}
  inc(O,ofs(Name));                   {where Name is located}
  move(NStr[0],P^[O],length(NStr)+1); {move string incl. length byte}
  rewrite(ExeFile,1);                 {create new version}
  blockwrite(ExeFile,P^,N);           {write it}
  close(ExeFile);                     {close it...}
  dispose(P)                          {...and release mem}
 end
end.
