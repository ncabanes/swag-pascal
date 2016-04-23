{
  OK, here's a problem. FExpand takes Newest.Name and appends it to the
  full CURRENT path, not the path you specified on the command line. You
  have to keep track of that path yourself. Or, here's a unit that might
  help. It's an Expanded Searchrec that returns a full filespec.
}

unit EXSRec;
{ Written by Steve Rogers - 1994. Released to public domain }

interface
uses
  dos;

type
  EXSearchRec = record           { EXtended searchrec       }
    name : pathstr;              { fully specified filename }
    dsub : searchrec;            { dos.searchrec            }
  end;

procedure ffirst(path : pathstr;attr : word;var dd : EXSearchRec);
procedure fnext(var dd : EXSearchRec);

implementation

procedure ffirst(path : pathstr;attr : word;var dd : EXSearchRec);
begin
  findfirst(path,attr,dd.dsub);
  if (doserror=0) then with dd do begin
    name:= path;
    while not (name[length(name)] in ['\',':',#0])
      do dec(name[0]);
    name:= name+dsub.name;
  end else dd.name:= '';
end;

{----------------------}
procedure fnext(var dd : EXSearchRec);

begin
  findnext(dd.dsub);
  if (doserror=0) then with dd do begin
    while not (dd.name[length(dd.name)] in ['\',':',#0])
      do dec(name[0]);
    name:= name+dsub.name;
  end else dd.name:= '';
end;

{----------------------}
end.
