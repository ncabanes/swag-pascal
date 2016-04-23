{
 MG>    Trying to figure out the fastest way
 MG> to find and delete duplicate strings,
 MG> which are actually file names in an
 MG> ASCII file.

Using the strings and objects unit, pstringcollections can be used to sort and
test for dupes quite easilly.
}

Uses Objects,Strings,Dos;

Const
  inFile  : String = '';
  OutFile : String = '';
  DupFile : String = '';

Type
  NewPCol = Object(TStringCollection)
              function compare(key1,key2:pointer):integer; virtual;
            end;
 PSColl  = ^NewPCol;

Function NewPCol.Compare(key1,key2:pointer):integer;
   Begin
     Compare := StrIComp(key1,key2);
   End;

Procedure Doit;
   Var NewLst,
       DupLst : PSColl;
       s      : string;
       ps     : pstring;
       f      : text;
       i      : integer;
   Procedure WriteEm(pst:Pstring); far;
      begin
        writeln(f,pst^);
      end;
   Begin
     New(NewLst,init(5,5));
     New(DupLst,init(5,5));
     DupLst^.Duplicates := true;
     assign(f,InFile);  reset(f);
     While not Eof(f) do
       Begin
         readln(f,s);
         if   s <> ''
         then begin
                ps := newstr(s);
                i := NewLst^.Count;
                NewLst^.insert(ps);
                if i = NewLst^.Count then DupLst^.insert(ps);
              end;
       End;
     close(f);
     if   NewLst^.count > 0
     then begin
            assign(f,OutFile); rewrite(f);
            NewLst^.forEach(@WriteEm);
            close(f);
          end;
     if   DupLst^.Count > 0
     then begin
            assign(f,DupFile); rewrite(f);
            DupLst^.forEach(@WriteEm);
            close(f);
          end;
     dispose(DupLst,done);
     dispose(NewLst,Done);
  End;

Begin
  if paramcount < 2 then halt;
  InFile := paramstr(1);
  OutFile := paramstr(2);
  DupFile := OutFile;
  Dec(DupFile[0],3);
  DupFile := DupFile + 'DUP';
  if DupFile = OutFile then halt;
  Doit;
End.

