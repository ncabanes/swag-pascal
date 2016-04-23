{
WL> Say, would anyone know how-to sort a Record With 5 thing
 WL> in it one of which is "NAME"...I want to sort each Record
 WL> in the Array by name and can't figure it out....my Array
 WL> name is LabelS and my Record name is SofT....so any help
 WL> would greatly be appreciated...thanks

The easiest way is to make it an Object, and put it in a TSortedCollection.
For example:
}

  Type
    PMyrec = ^TMyrec;
    TMyrec = Object(tObject)
      name : String;
      other : Integer;
    end;

    TSortedRecs = Object(TSortedCollection)
      Function Compare(Key1,key2:Pointer):Integer; Virtual;
    end;

  Function TSortedRecs.Compare;
  Var
    p1 : PMyrec Absolute Key1;
    p2 : PMyrec Absolute Key2;
  begin
    if p1^.name < p2^.name then
      Compare := -1
    else if p1^.name = p2^.name then
      Compare := 0
    else
      Compare := 1;
  end;

Var
  rec : PMyrec;
  coll: TSortedRecs; begin
  coll.init(100,10);   { Init to 100 Records, grow by 10s }

  While More_Records do
  begin
    new(rec,init);
    rec^.name := Get_Name;
    rec^.other:= Get_Other;
    coll.insert(rec);
  end;
