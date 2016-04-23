
{
  This program demonstrates how to use your EXE
  file as a resource.  You should run this program
  twice - once to write info to the EXE and once to

  read info out.
}

program foo;

uses Objects;

type
  PMyObject = ^TMyObject;
  TMyObject = object(TObject)
    AString: String;
    constructor Init(S: String);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
  end;

constructor TMyObject.Init(S: String);
begin
  inherited Init;
  AString := S;
end;

constructor TMyObject.Load(var S: TStream);
begin
  inherited Init;
  S.Read(AString, SizeOf(AString));
end;

procedure TMyObject.Store(var S: TStream);

begin
  S.Write(AString, SizeOf(AString));
end;

const
  RMyObject: TStreamRec = (
    ObjType: 100;
    VmtLink: Ofs(TypeOf(TMyObject)^);
    Load: @TMyObject.Load;
    Store: @TMyObject.Store);

var
  Rez: PResourceFile;
  TheStream: PBufStream;
  AObject, Obj: PMyObject;

begin
   { Register my object for streaming }
  RegisterType(RMyObject);
   { Create instace of my object }
  Obj := New(PMyObject, Init('Hello world'));
   { Create instance of a stream pointing to EXE file }

  TheStream := New(PBufStream, Init(ParamStr(0), stOpen, 1024));
   { was stream created okay? }
  if TheStream^.Status = stOk then begin
   { Crate instance of resource file }
    Rez := New(PResourceFile, Init(TheStream));
   { try to grab object from resource stream }
    AObject := PMyObject(Rez^.Get('My Object'));
    if AObject <> nil then
   {  if found, then write object's string to screen }
      writeln('The magic string is: ' + AObject^.AString)
    else

   { if not, then write object to resource }
      Rez^.Put(Obj, 'My Object');
  end;
   { clean up }
  Obj^.Free;
  Rez^.Free;
end.


