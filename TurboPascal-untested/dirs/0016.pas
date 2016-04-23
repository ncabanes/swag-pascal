{
PER-ERIC LARSSON

> I've seen some posts asking how to search through directories or how to
> find a File anywhere on the disk, so here's a little Procedure I wrote
> to do it...  Give it a whirl and feel free to ask questions...

There is a built in trap in the method you describe. I've fallen into it many
times myself so here's a clue. The problem:
if Your Procedure (that is called once per File) does some processing of the
File you SHOULD first make a backup copy. personally I rename the original
File to .BAK and then take that File as input, writing to a new File With the
original name, perhaps deleting the .bak File if everything works out fine.
For most purposes this works fine. But if you do this using findnext to find
the next File to work With it will Repeat itself til the end of time or
diskspace.

Therefore i recommend :
First get all Filenames to work With,
Then start processing the Files.
}

Procedure runFile(ft : String);
begin
  { Process File here}
end;

Procedure RUNALLFileS(FT : String);
Type
  plista = ^tlista;
  tlista = Record
    namn : String;
    prev : plista;
  end;
Var
 S    : SearchRec;
 Dir  : DirStr;
 Name : NameStr;
 Ext  : ExtStr;
 pp   : plista;

Function insertbefore(before : plista) : plista;
Var
  p : plista;
begin
  getmem(p, sizeof(tlista));
  p^.prev := before;
  insertbefore := p;
end;

Function deleteafter(before : plista) : plista;
begin
  deleteafter := before^.prev;
  freemem(before, sizeof(tlista));
end;

begin
  pp := nil;
  FSplit(fT, Dir, Name, Ext);
  FINDFIRST(ft, $3f, S);
  While DosERROR = 0 DO
  begin
    if (S.ATTR and $18) = 0 then
    begin
      pp := insertbefore(pp);
      pp^.namn := dir + s.name;
   end;
   FINDNEXT(S);
  end;
  if pp <> nil then
  Repeat
    runFile(pp^.namn);
    pp := deleteafter(pp);
  Until pp = nil;
end;

begin
  if paramcount > 0 then
  begin
    For filaa := 1 to paramcount do
      runALLFileS(paramstr(filaa));
  end;
  Writeln('Klar')
end.

{
This is a cutout example from a Program i wrote
It won't compile but it'll show a way to do it !
}
