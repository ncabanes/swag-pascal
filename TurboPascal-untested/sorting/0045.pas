{
    Here is an example of a TStringCollection decendant that sorts the
    strings by the 30th character and beyond.  The default
    TStringCollection sorts from the first character. }

    uses Objects;

    type
        PMyCollection   = ^TMyCollection;
        TMyCollection   = object(TStringCollection)
            function Compare(Key1, Key2 : Pointer); virtual;
        end;

    function TMyCollection.Compare(Key1, Key2 : Pointer); virtual;
    var s, t : string;
    begin
        { This is where you would sort two strings Compare must
          return -1 if Key1 < Key2, 0 if Key1 = Key2, and
          1 if Key1 > Key2 }
        s := Copy(Key1^, 30, Length(Key1^) - 30);
        t := Copy(Key2^, 30, Length(Key2^) - 30);
        if s < t then Compare := -1 else
         if s = t then Compare := 0 else
           Compare := 1;
    end;

    var P : PMyCollection;
    begin
       P := New(PMyCollection, Init(10, 10));
       ReadLineFromFile;
       Insert(NewStr(LineFromFile));
       for x := 0 to P^.Count - 1 do
        writeln(PString(P^.At(x))^);
       Dispose(P, Done);
    end;
