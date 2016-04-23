{
>try using resource files with TurboVision. When opening a resource file with
>extension EXE, TV will append it to the file during write operations.
>I did it already for registration stuff and it works fine.

The trouble with this approach is that each write operation appends a
record, it doesn change the existing one.  For something you do only once
like registration, that's okay, but for config changes, you need to do
something to pack the records.  With Resource files that's complicated, but
possible.  Here's the unit I use to do it.
}

unit resources;

{ Unit to provide extra functions to TVision TResourceFiles }

interface

uses
  objects;

type
  PPackableResource = ^TPackableResource;
  TPackableResource = object(TResourceFile)
    function pack : boolean;
    { Packs the resource file by reading all resources and rewriting them to
      the stream.  Returns false if it fails. }
  end;

implementation

type
  { Type here to get at the secret fields of the TResourceFile }
  TResourceSecrets = object(TObject)
    Stream   : PStream;
    Modified : Boolean;
    BasePos  : Longint;
    IndexPos : Longint;
    Index    : TResourceCollection;
  end;

  PNamedItem = ^TNamedItem;
  TNamedItem = object(TObject)
    Item : PObject;
    Name : PString;
    destructor done; virtual;
  end;

destructor TNamedItem.done;
begin
  DisposeStr(Name);
  inherited done;
end;

procedure Deletechars(var S : TStream; count : Longint);
{ Deletes the given number of characters from the stream }
var
  copy    : longint;
  buffer  : array [1..1024] of byte;
  bufsize : word;
  pos     : longint;
begin
  pos     := S.GetPos;
  copy    := S.GetSize - pos - count;
  bufsize := sizeof(buffer);

  while copy > 0 do
  begin
    if copy < sizeof(buffer) then
      bufsize := copy;
    S.Seek(pos + count);
    S.Read(Buffer, bufsize);
    S.Seek(pos);
    S.write(Buffer, bufsize);
    inc(pos, bufsize);
    dec(copy, bufsize);
  end;
  S.Truncate;
end;

function TPackableResource.Pack : boolean;
var
  contents  : TCollection;
  i         : integer;
  item      : PObject;
  nameditem : PNamedItem;
  OldSize   : longint;
begin
  Flush;
  pack := false;   { Assume failure }
  if Stream^.status <> stOk then
    exit;

  { First, make a copy of all the contents in memory }

  contents.init(Count, 10);
  for i := 0 to pred(Count) do
  begin
    item := Get(KeyAt(i));
    New(NamedItem, init);
    if (NamedItem = nil) or (item = nil) then
    begin
      contents.done;
      exit;
    end;
    NamedItem^.item := item;
    NamedItem^.name := Newstr(Keyat(i));
    contents.atinsert(i, nameditem);
  end;

  { Now, remove all traces of the original. }

  with TResourceSecrets(Self) do
  begin
    Stream^.Seek(BasePos + 4);
    Stream^.Read(OldSize, Sizeof(OldSize));
    Stream^.Seek(BasePos);
    DeleteChars(Stream^, OldSize + 8);
  end;

  { Now, close down and restart }
  TResourceSecrets(Self).Index.Done;
  Stream^.Seek(0);
  inherited init(Stream);

  { Now rewrite all those saved objects. }
  for i := 0 to pred(contents.count) do
  begin
    nameditem := PNamedItem(contents.At(i));
    Put(nameditem^.item, nameditem^.name^);
  end;

  { Get rid of the copies from memory }
  contents.done;

  if Stream^.Status = stOk then
    pack := true;
end;

end.

