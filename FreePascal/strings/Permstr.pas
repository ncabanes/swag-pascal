(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0005.PAS
  Description: PERM-STR.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

{

Here it is.  note that this permutes a set of Characters.  if you want to
do something different, you will have to modify the code, but that should
be easy.
}

Type
  tThingRec = Record
    ch  : Char;
    occ : Boolean;
  end;

Var
  Thing       : Array[1..255] of tThingRec;
  EntryString : String;

Procedure Permute(num : Byte);
{ N.B.  Procedure _must_ be called With num = 1;
  it then calls itself recursively,
  incrementing num }
Var
  i : Byte;
begin
  if num > length(EntryString) then
  begin
    num := 1;
    For i := 1 to length(EntryString) do
      Write(Thing[i].Ch);                 { You'll want to direct }
    Writeln;                              { output somewhere else }
  end
  else
  begin
    For i := 1 to length(EntryString) do
    begin
      if (not Thing[i].Occ) then
      begin
        Thing[i].Occ := True;
        Thing[i].Ch := EntryString[num];
        Permute(succ(num));
        Thing[i].Occ := False;
      end;
    end;
  end;
end;

begin
  FillChar(Thing,sizeof(Thing),0);
  Write('Enter String of Characters to Permute: ');
  Readln(EntryString);
  Permute(1);
  Writeln;
  Writeln('Done');
end.

