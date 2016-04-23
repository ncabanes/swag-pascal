{added by E.L. Lagerburg}


Unit U_Array;

{Dynamic array by E.L. Lagerburg from the Netherlands}


interface
  Uses SysUtils;

const MaxArray = MaxInt div 8;

Type

  PByteArray=^TByteArray;
  TByteArray=array[0..MaxArray] of byte ;

  TIndexEvent = Procedure(Sender:Tobject;Situation:Integer;Rec:Pointer;Index:Integer) of object;


  Tarray = Class(TObject)
  Private
     FOnForIndex:TIndexEvent;
     FOnForEach:TIndexEvent;
     FArray:PByteArray;
     FRecSize,
     FRecCapacity:Integer;
     FRecCount:Integer;
  Protected
     procedure SetCapacity(NewCapacity: Integer);
     Function GetSize:Integer;
     function Get(Index: Integer): Pointer;
     procedure Put(Index: Integer; Rec: Pointer);
     Procedure Error(Nr:Integer);
     procedure Grow;
     procedure SetCount(NewCount: Integer);
   Public
     Constructor Create(RecSize,RecCapacity:Integer);
     Destructor Destroy; override;
     function AddRecord(Rec:Pointer):Integer;
     Procedure ForEach(Situation:Integer);
     Procedure ForIndex(FromIndex,ToIndex,Situation:Integer);
     procedure DeleteRecord(Index: Integer);
     procedure MoveRecord(CurIndex, NewIndex: Integer);
     procedure InsertRecord(Index: Integer;Rec:Pointer);
     procedure ExchangeRecord(Index1, Index2: Integer);
     Procedure Clear;
     Property ByteArray:PByteArray read FArray;
     Property Count:Integer read FRecCount write SetCount;
     Property Size:Integer read GetSize;
     Property RecordSize:Integer read FRecSize;
     property Records[Index: Integer]: Pointer read Get write Put; default;
     Property OnForEach:TIndexEvent read FOnForEach write FOnForEach;
     Property OnForIndex:TIndexEvent read FOnForIndex write FOnForIndex;
   end;


   EArrayError = class(Exception);


implementation

Constructor TArray.Create(RecSize,RecCapacity:Integer);
Begin
  Inherited Create;
  FArray:=nil;
  FRecSize:=RecSize;
  FRecCapacity:=0;
  FRecCount:=0;
  SetCapacity(RecCapacity);
end;

Procedure TArray.Error(Nr:Integer);
Begin
  raise EArrayError.Create('Array index out of bounds '+intToStr(Nr));
End;

procedure TArray.SetCapacity(NewCapacity: Integer);
Begin
  if (NewCapacity < FRecCount) or (NewCapacity > MaxArray) then Error(1);
  if NewCapacity <> FRecCapacity then
  begin
    ReallocMem(FArray, NewCapacity * FRecSize);
    FRecCapacity := NewCapacity;
  end;
end;

Function TArray.AddRecord(Rec:Pointer):Integer;
begin
  Result := FRecCount;
  if Result = FRecCapacity then Grow;
  System.Move(Rec^,Farray^[FRecSize*FRecCount],FRecSize);
  inc(FRecCount);
end;

procedure TArray.InsertRecord(Index: Integer;Rec:Pointer);
begin
  if (Index < 0) or (Index > FRecCount) then Error(2);
  if FRecCount = FRecCapacity then Grow;
  if Index < FRecCount then
    System.Move(FArray^[FRecSize*Index],FArray^[FRecSize*Index+1],
      (FRecCount - Index) * FRecSize);
  System.Move(Rec^,Farray^[FRecSize*Index],FRecSize);
  Inc(FRecCount);
end;

procedure TArray.DeleteRecord(Index: Integer);
begin
  if (Index < 0) or (Index >= FRecCount) then Error(3);
  Dec(FRecCount);
  if Index < FRecCount then
    System.Move(FArray^[FRecSize*(Index + 1)],FArray^[FRecSize*Index],
      (FRecCount - Index) * FRecSize);
end;

procedure TArray.MoveRecord(CurIndex, NewIndex: Integer);
var
  Rec:PByteArray;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FRecCount) then Error(4);
    Rec:=nil;
    ReallocMem(Rec,FRecSize);
    System.Move(Farray^[FRecSize*CurIndex],Rec^,FRecSize);
    DeleteRecord(CurIndex);
    InsertRecord(NewIndex,Rec);
    ReallocMem(Rec,0);
  end;
end;

procedure TArray.ExchangeRecord(Index1, Index2: Integer);
var
  Rec:PByteArray;
begin
  if (Index1 < 0) or (Index1 >= FRecCount) or
    (Index2 < 0) or (Index2 >= FRecCount) then Error(5);
  Rec:=nil;
  ReallocMem(Rec,FRecSize);
  System.Move(Farray^[FRecSize*Index1],Rec^,FRecSize);
  System.Move(Farray^[FRecSize*Index2],Farray^[FRecSize*Index1],FRecSize);
  System.Move(Rec^,Farray^[FRecSize*Index2],FRecSize);
  ReallocMem(Rec,0);
end;

procedure TArray.SetCount(NewCount: Integer);
begin
  if (NewCount < 0) or (NewCount > MaxArray) then Error(6);
  if NewCount > FRecCapacity then SetCapacity(NewCount);
  if NewCount > FRecCount then
    FillChar(FArray^[FRecCount*FRecSize],(NewCount - FRecCount) * FRecSize, 0);
  FRecCount := NewCount;
end;

procedure TArray.Grow;
var
  Delta: Integer;
begin
  if FRecCapacity > 8 then Delta := 16 else
    if FRecCapacity > 4 then Delta := 8 else
      Delta := 4;
  SetCapacity(FRecCapacity + Delta);
end;

Function TArray.Get(Index: Integer): Pointer;
Begin
  if (Index < 0) or (Index >= FRecCount) then Error(7);
  Result:=@Farray^[FRecSize*Index];
End;

procedure TArray.Clear;
begin
  FRecCount:=0;
  SetCapacity(0);
end;

Procedure TArray.Put(Index: Integer; Rec: Pointer);
Begin
  if (Index < 0) or (Index >= FRecCount) then Error(8);
  System.Move(Rec^,Farray^[FRecSize*Index],FRecSize);
End;

Procedure TArray.ForEach(Situation:Integer);
Var Teller:Integer;
Begin
  If not Assigned(FOnForEach) then exit;
  For Teller:=0 to FRecCount-1 do
  Begin
    FOnForEach(Self,Situation,Get(Teller),Teller);
  End;
End;

Procedure TArray.ForIndex(FromIndex,ToIndex,Situation:Integer);
Var Teller:Integer;
Begin
  If not Assigned(FOnForIndex) then exit;
  if (FromIndex < 0) or (FromIndex >= FRecCount) then Error(9);
  if (ToIndex < 0) or (ToIndex >= FRecCount) then Error(10);
  For Teller:=FromIndex to ToIndex do
  Begin
    FOnForIndex(Self,Situation,Get(Teller),Teller);
  End;
End;

Function TArray.GetSize:Integer;
Begin
  Result:=FRecSize * FRecCount;
end;

Destructor TArray.Destroy;
Begin
  Clear;
  Inherited Destroy;
End;

end.
