
For those interested in storing components onto a stream, take a look
at TWriter.WriteRootComponent and TWriter.WriteComponent.  Then check
out the TReader.Read... counterparts.  Unfortunately, there appears
to be no documentation showing HOW to use these methods properly.
The docs keep mentioning the "root" component, but never clearly
explain what it is or how you are suppose to use the root property
to store your components.

If you are interested in writing objects to the stream that are
not components, I recommend doing something like the follow:

type
  TMyObject = class(TObject)
    ...
  protected
    procedure SaveToStream(writer : TWriter); virtual; 
    procedure LoadFromStream(writer : TWriter); virtual;
    ...
  end;

procedure TMyObject.SaveToStream(writer : TWriter);
begin
  with writer do begin
    WriteListBegin;
    {- write object state -}
    WriteListEnd;
  end;
end;

procedure TMyObject.LoadFromStream(reader : TReader);
begin
  with reader do begin
    ReadListBegin;
    while not EndOfList do begin
      {- read object state -}
    end;
    ReadListEnd;
  end;
end;

Somewhere in the initialization section of the unit in which this
object is declared, call RegisterObject('TMyObject').  (See
RegisterObject() below.)

In the main program, where you specify the file to read/write,
you can do something like this:

var
  RegisteredObjects : TStringList;

procedure RegisterObject(cname : string; ctype : TClass);
begin
  RegisteredObjects.AddObject(cname, ctype);
end;

procedure GetObject(cname : string) : TClass;
var
  i : integer;
begin
  i := RegisteredObjects.IndexOf(cname);
  if i > -1 then
    Result := TClass(RegisteredObjects.Objects[i])
  else
    Result := nil;
end;

procedure SaveFile(const filename : string; objlist : TList);
var
  stream : TFileStream;
  writer : TWriter;
  i      : integer;
begin
  stream := TFileStream.Create(filename, fmCreate or fmOpenWrite);
  try
    writer := TWriter.Create(stream, $ff);
    try
      with writer do begin
        WriteSignature;     {marker to indicate a Delphi filer object file.}
        WriteListBegin;     {outer list marker}
        for i := 0 to objlist.Count - 1 do begin
          WriteListBegin;   {object marker}
          WriteString(TMyObject(objlist[i]).ClassName);
          TMyObject(objlist[i]).SaveToStream(writer);
          WriteListEnd;     {object marker}
        end;
        WriteListEnd;       {outer list marker}
      end;
    finally
      writer.Free;
    end;
  finally
    stream.Free;
  end;
end;

procedure OpenFile(const filename : string; objlist : TList);
var
  stream : TFileStream;
  writer : TWriter;
  cname  : string;  {class name}
  ctype  : TClass;  {class type}
  obj    : TObject;
begin
  stream := TFileStream.Create(filename, fmOpenRead);
  try
    reader := TReader.Create(stream, $ff);
    try
      with reader do begin
        ReadSignature;     {check Delphi filer object signature.}
        ReadListBegin;     {outer list marker}
        while not EndOfList do begin
          ReadListBegin;   {object marker}
          while not EndOfList do begin
            cname := ReadString;
            ctype := GetObjectClass(cname);
            obj := TObject(TObjectClass(ctype).Create;
            try
              obj.LoadFromStream(reader);
            except
              obj.Free;
              raise;
            end;
            objlist.Add(obj);
          end;
          ReadListEnd;     {object marker}
        end;
        ReadListEnd;       {outer list marker}
      end;
    finally
      reader.Free;
    end;
  finally
    stream.Free;
  end;
end;


Well, I don't know how far this will get you.  I haven't tested ANY
of this code, so who knows if it could ever possibly work.  The most
doubtful part is the whole dynamic instantiation taking place in
LoadFromStream().  Delphi provides a bunch of great functions for
registering TPersistent descendants and getting their class types
from their class names, etc.:  RegisterClass(), FindFieldClass(),
FindClass(), GetClass(), etc.  (They use it for loading components
off of streams....no surprise there.)  However, if your objects
are not TPersistent descendants (and there's no reason they should
be), then you're basically out of luck (read: "you get to write
your own RegisteredClass()").

So, give this a try if you're feeling daring.  Just don't come running
after me with a shotgun complaining about little voices in your heads
if you do.  I suspect the above code will need a lot of polish before
it does what is expected of it...  Nonetheless, I hope you find it
interesting, if nothing else.

----------------------------------------------------------------------

Well, shoot.  After a bit of research and review, I came to realize just
how unnecessary all of this work with trying to store plain objects
on a stream is.  When I wrote up the TStream2 message back in May
(only shortly after Delphi came out), I did not have a good understanding
of the VCL class heirarchy.

Here's a quote from the Component Writer's Guide (TPersistent):

The TPersistent object is the abstract base object for all objects
stored and loaded on Delphi stream objects. In addition to the methods
it inherits from its ancestor, TObject, TPersistent defines three new
methods: AssignTo and DefineProperties, which are protected, and Assign,
which is public.

The GetClass() and RegisterClass() functions work for TPersistent objects.

So, after being in the dark for so long, I sat down and just took a
good long look at TPersistent and other related matters.  Then, after
looking back at what you wanted to do, I wrote up a little program
and tested it out to make sure it actually worked.  Below is the result.

Below I have included two units: Unit1, which is a form definition, and
Unit2, which contains the TPlayer and TObjectList classes.  The form
(Unit1) has for buttons labelled "Create," "Save," "Load," and "Exit."

        Create -- create 5 TPlayers and add them to the object list
        Save   -- save the object list to a file
        Load   -- load the object list from a file
        Exit   -- free the object list and exit

In Unit2, the TPlayer object is declared as a TPersistent descendant
and is given two methods:  ReadData() and WriteData().

        ReadData()  -- read property data with given TReader object
        WriteData() -- write property data with given TWriter object

The TPlayer class is registered with a call to RegisterClass in the
initialization section of Unit2 when the program first begins.

Also in Unit2, the TObjectList class is declared as a TList and
given the methods Clear(), SaveToStream(), LoadFromStream(),
SaveToFile(), and LoadFromFile().  The SaveToFile() and LoadFromFile()
just create a TFileStream object and then pass it to the corresponding
SaveToStream()/LoadFromStream() method, which do the actually accessing
via the TFiler objects (TWriter & TReader).  A destructor was also
added to TObjectList to ensure that it frees the items in the list
when it is destroyed.

I think it would be a good idea to go back into the TObjectList and
add a new kind of Items property that is specifically typed as
TPersistent or TObject instead of just Pointer since many of the
operations we perform on its Items property could cause problems
if a non-object were accidentally stored in the list.  It would also
reduce the need for all of the extra type casting.

Anyhow, here are the two units that worked for me.  Let me know what you
think.

--Mark Johnson

--------------------------------- UNIT1.PAS ---------------------------------

unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    btnCreate: TButton;
    btnSave: TButton;
    btnLoad: TButton;
    btnExit: TButton;
    procedure btnCreateClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;


implementation

{$R *.DFM}

uses
  Unit2;

const
  ObjFilename = 'C:\players.dat';

var
  objList : TObjectList;

procedure TForm1.btnCreateClick(Sender: TObject);
var
  player : TPlayer;
  i      : integer;
begin
  {Creates five players and adds them to ObjList}
  objList.Clear;
  for i := 1 to 5 do begin
    player := TPlayer.Create;
    try
      with player do begin
        Name       := 'Name' + IntToStr(i);
        EmpireName := 'EmpireName' + IntToStr(i);
        Wins       := i;
        Losses     := 5 - i;
        Ranking    := 6 - i;
      end;
      objList.Add(player);
    except
      player.Free;
      raise;
    end;
  end;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
begin
  {Stores objList to file}
  objList.SaveToFile(ObjFilename);
end;

procedure TForm1.btnLoadClick(Sender: TObject);
begin
  {Loads objList from file}
  objList.LoadFromFile(ObjFilename);
end;

procedure TForm1.btnExitClick(Sender: TObject);
begin
  {Frees objList (and everything in list) and exits}
  objList.Free;
  Close;
end;

initialization
  objList := TObjectList.Create;
end.

--------------------------------- UNIT2.PAS ---------------------------------

unit Unit2;

interface

uses
  Classes;

type
  TPlayer = class(TPersistent)
  private
    FName       : string;
    FEmpireName : string;
    FWins       : integer;
    FLosses     : integer;
    FRanking    : integer;
  public
    procedure ReadData(reader : TReader); dynamic;
    procedure WriteData(writer : TWriter); dynamic;
  published
    property Name : string read FName write FName;
    property EmpireName : string read FEmpireName write FEmpireName;
    property Wins : integer read FWins write FWins;
    property Losses : integer read FLosses write FLosses;
    property Ranking : integer read FRanking write FRanking;
  end;

  TObjectlist=class(TList)
  public
    destructor Destroy; override;
    procedure Clear;
    procedure SaveToStream(stream : TStream);
    procedure LoadFromStream(stream : TStream);
    procedure SaveToFile(const filename : string);
    procedure LoadFromFile(const filename : string);
  end;


implementation

uses
  SysUtils;

{TPlayer}

procedure TPlayer.ReadData(reader : TReader);
begin
  with reader do begin
    Name       := ReadString;
    EmpireName := ReadString;
    Wins       := ReadInteger;
    Losses     := ReadInteger;
    Ranking    := ReadInteger;
  end;
end;

procedure TPlayer.WriteData(writer : Twriter);
begin
  with writer do begin
    WriteString(Name);
    WriteString(EmpireName);
    WriteInteger(Wins);
    WriteInteger(Losses);
    WriteInteger(Ranking);
  end;
end;


{TObjectList}

destructor TObjectList.Destroy;
begin
  {deallocate objects in list before termination}
  Clear;
  inherited Destroy;
end;

procedure TObjectList.Clear;
var
  i : integer;
begin
  {This routine deallocates all resources inside this list}
  for i := 0 to Count - 1 do begin
    TObject(Items[0]).Free;
    Delete(0);
  end;
end;

procedure TObjectList.SaveToStream(stream : TStream);
var
  writer : TWriter;
  i      : integer;
begin
    writer := TWriter.Create(stream, $ff);
    try
      with writer do begin
        {mark beginning of file and beginning of object list}
        WriteSignature;
        WriteListBegin;
        {loop through this list}
        for i := 0 to Count - 1 do begin
          {Store any TPersistent objects}
          if TObject(Items[i]) is TPersistent then begin
            WriteString(TPersistent(Items[i]).ClassName);
            {Call WriteData() for TPlayer objects}
            if (TPersistent(Items[i]) is TPlayer) then
              TPlayer(Items[i]).WriteData(writer);
          end;
        end;
        {mark end of object list}
        WriteListEnd;
      end;
    finally
      writer.Free;
    end;
end;

procedure TObjectList.LoadFromStream(stream : TStream);
var
  reader : TReader;
  obj    : TPersistent;
  ctype  : TPersistentClass;
  cname  : string;
  i      : integer;
begin
  reader:=TReader.Create(stream,$ff);
  try
    with reader do begin
      {read beginning of file and beginning of object list markers}
      ReadSignature;
      ReadListBegin;
      {loop through file list of objects}
      while not EndOfList do begin
        {Load ClassName and use it to get ClassType}
        cname := ReadString;
        ctype := GetClass(cname);
        if Assigned(ctype) then begin  {"Assigned()" == " <> nil" but quicker}
          {If a ClassType was found, create an instance}
          obj := ctype.Create;
          try
            {if obj is a TPlayer, call its ReadData() method}
            if obj is TPlayer then
              TPlayer(obj).ReadData(reader);
          except
            obj.free;
            raise;
          end;
          {add object to this list}
          Add(obj);
        end;
      end;
      ReadListEnd;
    end;
  finally
    reader.Free;
  end;
end;

procedure TObjectList.SaveToFile(const filename : string);
var
  stream : TFileStream;
begin
  stream := TFileStream.Create(filename, fmCreate or fmOpenWrite);
  try
    SaveToStream(stream);
  finally
    stream.Free;
  end;
end;

procedure TObjectList.LoadFromFile(const filename : string);
var
  stream : TFileStream;
begin
  stream := TFileStream.Create(filename, fmOpenRead);
  try
    Clear;
    LoadFromStream(stream);
  finally
    stream.Free;
  end;
end;

initialization
  {register TPlayer class here when program begins}
  RegisterClass(TPlayer);
end.
