{
> I need to find exactly how many entries are in the stream, to do random
> access.  To find this, I was using TBufStream.GetSize to find the total
> size.  Then, I was dividing by the size of each object to find how many
> there are.

> Is there another way to find how many entries are in a stream?
> Something like TCollection.Count?

Actually there is _no_ way of determining how many objects are stored in a
stream -- I suggest you either

        1)  Store the number in a header at the start
            of the file, or

        2)  Maintain an index for the stream.

An index would just be a stream with lots of Longints.  Each entry would be
an offset into the other stream.

To read object # 100 from the data stream, read a Longint at position #
(100 * SizeOf(Longint)) from the index stream.  Use this Longint with Seek
to seek with the data stream.

Here's a bit of sample code:

lew.romney@thcave.bbs.no
}
var
  Index, Data : TBufStream;

procedure AddObject (P : PObject);
var
  Pos : Longint;
begin
  Pos:=Data.GetSize;

  Data.Seek(Data.GetSize);
  Data.Put(P);

  Index.Seek(Index.GetSize);
  Index.Write(Pos, SizeOf(Pos));
end;

function GetObject (Number : Longint) : PObject;
var
  Pos : Longint;
begin
  Index.Seek(Number * SizeOf(Longint));
  Index.Read(Pos, SizeOf(Pos));

  Data.Seek(Pos);
  GetObject:=Data.Get;
end;
{
Look up the TResourceFile object in your manuals or the online help.  This
object lets you maintain a library of objects inside a stream, each object
"filed" under a unique name.  TResourceFile also stores an index in the
same stream.
}
