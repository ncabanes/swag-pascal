(*
I have *really* simple code I wrote for loading a 320x200x256 pcx if
that'd do. I have other stuff that you could work with, but it's not
mine and not finished.

CL/  Display a background .PCX (a map in this case), and allow for the
CL/movement of foreground objects w/o affecting the background .PCX.

What you want to do is use virtual screens or page flipping, depending
on the graphic mode. If you're in low res (really easy!) 320x200x256,
you can easily use 64k virtual screens (just arrays of [0..199,0..319]
for simplicity) and treat *them* like a screen. Then dump them to the
real screen once all your updates are done.  For higher vid modes,
virtual screens can get a *bit* more complex, 'specially for 16 color
modes.

CL/Item_REc = rec
CL/             name : string [30];
CL/             amt : byte;
CL/          end;
CL/Item_Type = array[1..5] of Item_Rec;

CL/Map_Rec = Record
CL/            Occupant : Byte; { Player=1, Nobody=0, etc }
CL/            Items    : Item_type;
CL/            Case Terrain:Char of
CL/              'F' : etc,etc...
CL/         End; { Map_rec }
CL/map_type = array[1..100,1..100] of map_rec;

CL/var
CL/  Map : map_type;

Well, the list of items should be link listed. I mean, not *every* map
will always have 5 items, right? Save memory that way.  Also, use
item numbers instead of signifying an item by it's entire name.  Using
a record structure something like this might help a bit:
*)

Type
  PItemRec = ^ItemRec;
  ItemRec = record
    name  : string[28];
    idnum : word;
    next  : PItemRec;
  end; {ItemRec 35 bytes}

  PItemIdx = ^ItemIdx;
  ItemIdx = record
     idnum : word;      {maximum of ~65535 items, depending on mem}
     amt   : Byte;
     next  : PItemIdx;
   end; {ItemIdx 7 bytes }

  PPlayerIdx = ^PlayerIdx
  PlayerIdx = record
    idnum : word;
    next : PPlayerIdx
  end; {PlayerIdx 6 bytes} {This will allow for more than one player
                            on a map coord if you want. Just an idea}

  Map_Rec = Record
    Occupants : PPlayerIdx;  {list of players}
    Items     : PItemIdx;    {list of items}
    Case Terrain:char etc
  End; { Map_rec 9 bytes}

{If you only want one player per square at a time, you can change
occupants to type byte, makeing map_rec 6 bytes, increasing your maximum
map size by like 1/3

Again, you could do linked lists for the map, but I'm sure you won't
have *that* big a map...  85x85 should be ok, right?
}

  pmap_type = ^Map_Type;  {This will save your data segment some room}
  map_type = array[1..85,1..85] of map_rec;   {with 9 byte maprec}
  map_type = array[1..104,1..104] of map_rec; {with 6 byte maprec}

{here's some examples of how to access these variables}

Procedure AddItem(NewName:string;NewId:Word;Var List:PItemIdx);
var
  NewItem:PItemRec;
begin
  New(Newitem);       {alloc mem for new item}
  with newitem^ do
    begin
      name:=newname;
      Idnum:=newid;
      Next:=List;     {chain "list" after newitem}
    end;
  List:=NewItem;      {Insert into front of list}
end;

Var
  Map      : PMap_Type;
  ItemList : PItemRec;
  t,i      : integer;
  pPlr     : PPlayerIdx;
  pItm     : PItemIdx;

begin
  new(map);      { get heap memory for the MAP pointer}
  ItemList:=nil;    { no items in master list yet}

  fillchar(map^,sizeof(map^),0);  { clear *ALL* map memory to zeros }

  {Make some arbitary items}
  Additem('Sword',0,ItemList);
  Additem('Shield',1,ItemList);
  Additem('Dagger',2,ItemList);
  Additem('Helm',3,ItemList);

  For T:=1 to 85 do
    for I:=1 to 85 do
      begin
        terrain:=terraintypes[random(10)]; {whatever}
        if random(100) then
          begin
            new(pitm); {make a new item idex}
            with pitm^ do
              begin
                idnum:=random(4);
                amt:=1;
                next:=nil;
              end;
            Map^[t,i].items^:=pitm;
          end;
      end;

{these next lines should clean up the entire map, no matter how many
items, players or whatever you have around.  As long as you don't have
any invalid pointers...<G>}

  For T:=1 to 85 do
    for I:=1 to 85 do
      begin
        while occupant<>nil do
          begin
            pplr:=occupant;
            occupant:=occupant^.next;
            dispose(pplr);
          end;
        while items<>nil do
          begin
            pitm:=items;
            items:=items^.next;
            dispose(pitm);
          end;
      end;
  dispose(map);  { free heap memory for the MAP pointer}
end.

