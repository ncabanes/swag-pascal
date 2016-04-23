{
> I would like to start on a Program that reads a certain File.  The
> problem is that the Records are of different lenghts.  The File
> structure is as follows: One File contains the header For each Record
> which is kept in a seperate File. The header has a Word Variable which
> is the size of the Record in the other File.  It also has a Integer
> With points to the Record number in the other File.

The easiest way is to use streams.  Here's a sketch:

}

Uses
  Objects;

Var
  S : TDosStream;
  data : Array[1..1000] of Byte;   { Big enough For anything }
  Position : LongInt;              { The position of the item }
  Size : Word;                     { The size of the item }
begin
  S.init('dataFile',stOpenRead);

 { Now determine Position and Size from the other File somehow }

  S.Seek(Position);
  S.Read(data,Size);
  if S.Status <> stOK then
  begin
    Writeln('Stream error ',S.Status,' With error info ',S.ErrorInfo);
    S.Reset;
  end;
end.