unit PostCont;

{ Class to parse the data from a web server's QUERY_STRING variables and the
  stdin data during a POST.  The .Create method used determines how this
  loads the data.

  by Dave Wedwick
}  

interface

uses SysUtils, Classes;

type
  EPostContentError = class(Exception);

  TPostContent = class
    private
      FList: TList;
      function GetValue(Index: Integer): String;
      function GetKey(Index: Integer): String;
      function GetCount: Word;
      procedure ParseStream(MemStr: TMemoryStream);
      procedure FreeItems;
    public
      constructor Create(ContentLen: Integer);
      constructor CreateFromString(Str: String);
      destructor  Destroy; override;

      property Value[Index: Integer]: String read GetValue;
      property Key[Index: Integer]: String read GetKey;
      property Count: Word read GetCount;

      function ValueForKey(Key: String; Occurance: Word): String;
  end;

implementation

type
  PValueRec = ^ValueRec;

  ValueRec = record
    Name: String[100];
    Value: String[200];
  end;

{ Support functions }
function StrToHex(const HexVal: String): Char;
const
  StartingLetter = ord('A');
  StartingNumber = ord('0');

var
  Val, Counter: Byte;

begin

  { Find the hex value of the passed two byte string }
  Val := 0;
  for Counter := 1 to 2 do begin
    if Counter = 2 then
      Val := Val shl 4;

    case HexVal[Counter] of
      '0'..'9':  Val := Val + (ord(HexVal[Counter]) - StartingNumber);
      'A'..'F':  Val := Val + (ord(HexVal[Counter]) - StartingLetter + 10);
    end;
  end;

  Result := Char(Val);
end;

{ Class methods }
constructor TPostContent.Create(ContentLen: Integer);
var
  MemStr: TMemoryStream;
  Counter: Word;
  NextChar: Char;

begin
  FList := TList.Create;
  MemStr := TMemoryStream.Create;

  Counter := 1;
  while Counter <= ContentLen do begin
    Read(NextChar);
    MemStr.Write(NextChar, 1);

    { Add one to the count }
    Inc(Counter);
  end;

  ParseStream(MemStr);

  MemStr.Free;
end;

constructor TPostContent.CreateFromString(Str: String);
{ This creates the value pairs by parsing out a string, rather than
  reading from stdin.  Used with the QUERY_STRING. }
var
  MemStr: TMemoryStream;
  StartPos: Word;

begin
  FList := TList.Create;
  MemStr := TMemoryStream.Create;

  { The query data starts after the ? in the query.  If none is found, start
    at position 1.  Convenient, since Pos returns 0 if not found. }
  StartPos := Pos('?', Str) + 1;

  MemStr.Write(Str[StartPos], Length(Str)-StartPos+1);

  ParseStream(MemStr);

  MemStr.Free;
end;

destructor TPostContent.Destroy;
begin

  FreeItems;   { See below }
  FList.Free;

  inherited;
end;

procedure TPostContent.ParseStream(MemStr: TMemoryStream);
type
  InType = (itName, itValue);

var
  VRecPtr: PValueRec;
  NextChar: Char;
  Counter: Word;
  CurrType: InType;
  VRec: ValueRec;
  HexVal: String[2];

begin
  Counter  := 1;
  CurrType := itName;

  { Clear the structure to where the value are going to go }
  VRec.Name := '';
  VRec.Value := '';

  MemStr.Seek(0, soFromBeginning);	
  while Counter <= MemStr.Size do begin
    { Get the next character from the stream }
    MemStr.Read(NextChar, 1);

    { Plus signs are spaces }
    if NextChar = '+' then
      NextChar := ' ';

    case NextChar of
      '=': CurrType := itValue;

      '%':
        begin
          { The next two bytes are a hex value for an ASCII character.  Decode
            the character, add it to the appropriate place, and increment
            the counter by three}

          HexVal := '';
          MemStr.Read(NextChar, 1);   HexVal := HexVal + NextChar;
          MemStr.Read(NextChar, 1);   HexVal := HexVal + NextChar;

          NextChar := StrToHex(HexVal);

          if CurrType = itName then
            VRec.Name := VRec.Name + NextChar
          else
            VRec.Value := VRec.Value + NextChar;

          { Add two to the counter here -- there is one more added below
            at the bottom of the loop, making a total of three added }
          Inc(Counter, 2);
        end;

      '&':
        begin
          { Finished with this variable name/value pair.  Allocate memory
            and add it to the list }
          New(VRecPtr);
          VRecPtr^ := VRec;
          FList.Add(VRecPtr);

          { Get ready for the next values }
          CurrType := itName;
          VRec.Name := '';
          VRec.Value := '';
        end;

    else
      with VRec do begin
        if CurrType = itName then
          Name := Name + NextChar
        else
          Value := Value + NextChar;
      end;
    end;

    { Add one to the count }
    Inc(Counter);
  end;

  { Add the last one }
  if MemStr.Size > 0 then begin
    New(VRecPtr);
    VRecPtr^ := VRec;
    FList.Add(VRecPtr);
  end;
end;

procedure TPostContent.FreeItems;
var
  Counter: Word;

begin
  { Free all items in the list }
  for Counter := 1 to FList.Count do
    Dispose(PValueRec(FList[Counter-1]));

end;

function TPostContent.GetValue(Index: Integer): String;
begin
  if Index < 0 then
    raise EPostContentError.Create('Can''t have negative numbers');

  if Index > FList.Count-1 then
    raise EPostContentError.Create('Index value too high');

  Result := PValueRec(FList[Index])^.Value;
end;

function TPostContent.GetKey(Index: Integer): String;
begin
  if Index < 0 then
    raise EPostContentError.Create('Can''t have negative numbers');

  if Index > FList.Count-1 then
    raise EPostContentError.Create('Index value too high');

  Result := PValueRec(FList[Index])^.Name;
end;

function TPostContent.GetCount: Word;
begin
  Result := FList.Count;
end;

function TPostContent.ValueForKey(Key: String; Occurance: Word): String;
var
  Counter, HitCount: Word;

begin
  { Find the Occurance of Key in the list }
  if Occurance < 1 then
    raise EPostContentError.Create('Occurance value must be > 0');

  Result := '';

  HitCount := 0;
  for Counter := 1 to FList.Count do begin
    with PValueRec(FList[Counter-1])^ do begin
      { If the key passed matches the name of the value, and the occurance
        is found, return the value } 
      if UpperCase(Key) = UpperCase(Name) then begin
        Inc(HitCount);

        if HitCount = Occurance then begin
          Result := Value;
          Exit;
        end;
      end;
    end;
  end;

  { If we're here, then we didn't find the value for the key -- raise
    an exception }
  raise EPostContentError.Create('Key not found');
end;

end.
