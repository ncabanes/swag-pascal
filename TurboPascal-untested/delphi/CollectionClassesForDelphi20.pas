(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0191.PAS
  Description: Collection Classes for DELPHI 2.0
  Author: ALIN FLAIDER
  Date: 11-29-96  08:17
*)

unit Collect;
{ Collection classes for Delphi 2.0
  Alin Flaider, 1996
  aflaidar@datalog.ro }
  
interface
uses Windows, Classes, Sysutils;

const
  coIndexError = -1;              { Index out of range }
  coOverflow   = -2;              { Overflow }
  coUnderflow  = -3;              { Underflow }

type
 CollException = class(Exception);

 TCollection = class( TObject)
    private                       { return item at index position }
       function    At( Index : integer) : Pointer;
                                  { replace item at index position}
       procedure   AtPut( Index : integer; Item : Pointer);
    protected
       It     : PPointerList;     { array of pointers }
       Limit  : integer;          { Current Allocated size of array}
       Delta  : integer;          {Number of items by which the collection grows when full}
                                  { deletes item at index position }
       procedure   AtDelete      (Index : integer);
                                  { generates CollException }
       procedure   Error         (Code,Info : Integer); virtual;
                                  { destroys specified Item; override this method if Item is not
                                    a descendant of TObject }
       procedure   FreeItem      (Item : Pointer); virtual;
    public
       Count  : integer;          {Current Number of Items}
       constructor create(aLimit, aDelta : integer);
                                  {before deallocating object it disposes all items and the storage array}
       destructor  destroy; override;
                                  {inserts Item at specified position }
       procedure   AtInsert( Index : integer; Item : Pointer);
                                  {deletes and disposes Item at specified position}
       procedure   AtFree(Index: Integer);
                                  {deletes Item}
       procedure   Delete( Item : Pointer);
                                  {deletes all Items without disposing them }
       procedure   DeleteAll;
                                  {formerly Free, renamed to Clear to avoid bypassing inherited TObject.Free;
                                   deletes and disposes Item }
       procedure Clear(Item: Pointer);
                                  {finds first item that satisfies condition specified in
                                   function Test( Item: pointer): boolean}
       function    FirstThat( Test : Pointer) : Pointer;
                                  {finds last item that satisfies condition specified in
                                   function Test( Item: pointer): boolean}
       function    LastThat( Test : Pointer) : Pointer;
                                  {calls procedure Action( Item: pointer) for each item in collection}
       procedure   ForEach( Action : Pointer);
                                  {disposes all items; set counter to zero}
       procedure   FreeAll;
                                  {finds position of Item using a linear search}
       function    IndexOf( Item : Pointer) : integer; virtual;
                                  {inserts Item at the end of collection}
       procedure   Insert( Item : Pointer); virtual;
                                  {packs collection by removing nil Items}
       procedure   Pack;
                                  {expands array of pointers }
       procedure   SetLimit( aLimit : integer);virtual;
                                  {direct access to items through position}
       property Items[Index: integer]: pointer read At write AtPut; default;
    end;

    TSortedCollection = class(TCollection)
       Duplicates: boolean;       {if true, rejects item whose key already exists}
                                  {override this method to specify relation bewtween two keys
                                  1 if Key1 comes after Key2, -1 if Key1 comes before Key2,
                                  0 if Key1 is equivalent to Key2}
       function Compare (Key1,Key2 : Pointer): Integer; virtual; abstract;
                                  {returns key of Item}
       function KeyOf   (Item : Pointer): Pointer; virtual;
                                  {finds index of item by calling Search}
       function IndexOf (Item : Pointer): integer; virtual;
                                  {finds item required position and performs insertion }
       procedure Insert  (Item : Pointer); virtual;
                                  {finds index of item by performing an optimised search}
       function Search  (key : Pointer; Var Index : integer) : Boolean; virtual;
    end;

implementation

constructor TCollection.Create(ALimit, ADelta: Integer);
begin
   inherited Create;
   Limit:= 0;
   Delta:=aDelta;
   Count:=0;
   It := nil;
   SetLimit( ALimit);
end;

destructor TCollection.Destroy;
begin
   FreeAll;
   SetLimit(0);
   inherited Destroy;
end;

function TCollection.At(Index: Integer): Pointer;
begin
   If Index > pred(Count) then
   begin
     Error(coIndexError,0);
     Result :=nil;
   end
   else Result := It^[Index];
end;

procedure TCollection.AtPut(Index: Integer; Item: Pointer);
begin
   if (Index < 0) or (Index >= Count) then
     Error(coIndexError,0)
   else It^[Index] := Item;
end;

procedure TCollection.AtDelete(Index: Integer);
var p: pointer;
begin
   if (Index < 0) or (Index >= Count) then
   begin
      Error(coIndexError,0);
      exit;
   end;
   if Index < pred(Count) then
     move( It^[succ(Index)], It^[Index], (count-index)*sizeof(pointer));
   Dec(Count);
end;

procedure TCollection.AtInsert( Index: integer; Item: pointer);
var i : integer;
begin
   if (Index < 0) or ( Index > Count) then
   begin
      Error(coIndexError,0);
      exit;
   end;
   if Limit = Count then
   begin
     if Delta = 0 then
     begin
        Error(coOverFlow,0);
        exit;
     end;
     SetLimit( Limit+Delta);
   end;
   If Index <> Count then  {move compensates for overlaps}
      move( It^[Index], It^[Index+1], (count - index)*sizeof(pointer));
   It^[Index] := Item;
   Inc(Count);
end;

procedure TCollection.Delete( Item: pointer);
begin
   AtDelete(Indexof(Item));
end;

procedure TCollection.DeleteAll;
begin
   Count:=0
end;

procedure TCollection.Error(Code, Info: Integer);
begin
   case Code of
        coIndexError: raise CollException.Create('Collection error; wrong index: '+IntToStr(Info));
        coOverflow:  raise CollException.Create('Collection overflow - cannot grow!');
        coUnderflow: raise CollException.Create('Collection underflow - cannot shrink!');
   end
end;

function TCollection.FirstThat(Test: Pointer): Pointer;
type
   tTestFunc = function( p : pointer) : Boolean;
var i : integer;
begin
  Result := nil;
  for i := 0 to pred(count) do
    if tTestFunc(test)(It^[i]) then begin
       Result := It[i];
       break
    end
end;

procedure TCollection.ForEach(Action: Pointer);
type
   tActionProc = procedure(p : pointer);
var i : integer;
begin
  for i := 0 to pred(Count) do
    tActionProc(Action)(It^[i]);
end;

procedure TCollection.Clear(Item: Pointer);
begin
   Delete(Item);
   FreeItem(Item);
end;

procedure TCollection.FreeAll;
var i : integer;
begin
  for I := 0 to Count - 1 do FreeItem(At(I));
  Count := 0;
end;

procedure TCollection.FreeItem(Item: Pointer);
begin
  if Item <> nil then TObject(Item).Free;
end;

function TCollection.IndexOf(Item: Pointer): integer;
var i : integer;
begin
  Result := -1;
  for i := 0 to pred(count) do
    if Item = It^[i] then begin
       Result := i;
       break
    end
end;

procedure TCollection.Insert(Item: Pointer);
begin
   AtInsert(Count,Item);
end;

function TCollection.LastThat(Test: Pointer): pointer;
type
   tTestFunc = function( p : pointer) : Boolean;
var i : integer;
begin
  Result := nil;
  for i := pred(count) downto 1 do
    if tTestFunc(test)(It^[i]) then begin
       Result := It^[i];
       break
    end
end;

procedure TCollection.Pack;
var i: integer;
begin
  for i := pred(count) downto 0 do if It^[i] = nil then AtDelete(i);
end;

procedure TCollection.SetLimit(ALimit: Integer);
begin
  if (ALimit < Count) then Error( coUnderFlow , 0);
  if ALimit <> Limit then
  begin
    ReallocMem( It, ALimit* SizeOf(Pointer));
    Limit := ALimit;
  end;
end;

function TSortedCollection.IndexOf(Item: Pointer): Integer;
var
  i: Integer;
begin
  IndexOf := -1;
  if Search(KeyOf(Item), i) then
  begin
    if Duplicates then
      while (i < Count) and (Item <> It^[I]) do Inc(i);
    if i < Count then IndexOf := i;
  end;
end;

procedure TSortedCollection.Insert(Item: Pointer);
var i : integer;
begin
  if not Search(KeyOf(Item), I) or Duplicates then AtInsert(I, Item);
end;

function TSortedCollection.KeyOf(Item: Pointer): Pointer;
begin
  Result := Item;
end;

function TSortedCollection.Search;
var
  L, H, I, C: Integer;
begin
  Search := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := Compare(KeyOf(It^[I]), Key);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Search := True;
        if not Duplicates then L := I;
      end;
    end;
  end;
  Index := L;
end;

procedure TCollection.AtFree(Index: Integer);
var
  Item: Pointer;
begin
  Item := At(Index);
  AtDelete(Index);
  FreeItem(Item);
end;

end.

