{
SEPP MAYER

> Unfortunately I can't cut down on the size of my variables...(well,
> ok, one  of them I did, but it drastically reduces the usefulness of
> the program  itself).  So now I got rid of it, but one of my variables
> is of Array  [1..1000] Of String[12].  I'd like to have the array go to
> 2500.   Unfortunately, when I do this, it gives me the error.  Is there
> some way to  get around that??

At the Time your Array uses 13000 Byte of Memory in the Data-Segment
(12 Byte for the 12 characters in the string + 1 Byte for the Length).

The Only Thing You have to do, is to put your Array to the Heap, so you
can have an Array[1..3250] of your String with the same Use of Memory in
your Data-Segment.
}

program BigArray;

type
  PStr12 = ^TStr12;
  tStr12 = String[12];

var
  TheTab : Array[1..3250] of PStr12;
  i      : Integer;

function AddTabEle(i : Integer; s : String) : Boolean;
begin
  if i < 1 then
  begin
    WriteLn('You Used an Index lower than 1');
    AddTabEle := false;
    Exit;
  end;
  if i > 3250 then
  begin
    WriteLn('You Used an Index higher then 3250');
    AddTabEle := false;
    Exit;
  end;
  if TheTab[i] <> nil then
  begin
    WriteLn('TAB Element is already in Use');
    AddTabEle := false;
    Exit;
  end;
  if MemAvail < 13 then
  begin
    WriteLn('Not Enough Heap Memory');
    AddTabEle := false;
    Exit;
  end;
  New[TheTab[i]);
  TheTab[i]^ := Copy(s,1,12); {Limit to 12 Characters}
  AddTabEle  := true;
end;

function ChangeTabEle(i : integer; s : string) : Boolean;
begin
  if TheTab[i] = nil then
  begin
    WriteLn('You Tried to Modify an non-existing TAB Element, Use AddTabEle');
    ChangeTabEle := false;
    Exit;
  end;
  TheTab[i]^   := Copy(s, 1, 12);
  ChangeTabEle := true;
end;

function GetTabEle(i : integer) : string;
begin
  if TheTab[i] = nil then
  begin
    GetTabEle := 'TAB Ele not found'; {No error occurs}
    Exit;
  end;
  s := TheTab[i]^;
end;
function FreeTabEle(i : integer) : Boolean;
begin
  if TheTab[i] = nil then
  begin
    WriteLn('TAB Element is not used';
    FreeTabEle := false;
    Exit;
  end;
  Dispose(TheTab[i]);
  TheTab[i]  := nil;
  FreeTabEle := true;
end;

procedure FreeTab;
begin
  for i := 1 to 3250 do
  begin
    if TheTab[i] <> nil then
      if NOT FreeTabEle(i) then
        WriteLn('Error releasing Tab element');
  end;
end;

begin
  for i := 1 to 3250 do       {Initialize Pointers with nil, to test       }
    TheTab[i] := nil;         {if Element is Used, compare pointer with nil}
  {.......}                   {Your Program}
  if NOT AddTabEle(1, 'Max 12 Chars') then  {Add an Ele}
    WriteLn('Error creating TAB element');  {evtl. use FreeMem + Halt(1)}
                                            {to terminate Programm}
  WriteLn(GetTabEle(1));                    {Write an Tab Ele}
  if NOT ChangeTabEle(1, '12 Chars Max') then {Change an Ele}
    WriteLn('Error changing TAB element');  {evtl. use FreeMem + Halt(1)}
                                            {to terminate Programm}
  WriteLn(GetTabEle(1));                    {Write an Tab Ele}
  if NOT FreeTabEle(1) then                 {Delete(Free) an Ele}
    WriteLn('Error releasing Tab element'); {evtl. use FreeMem + Halt(1)}
                                            {to terminate Programm}
  {.......}                   {Your Program}
  FreeTab;                    {At The End of Your Program free all TAB Ele}
end.

