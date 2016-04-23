Var
  Fi : File;

Function ISOpen(Var Fil:File):Boolean;
(* Returns True is File has is open ON A NETWORK!!! *)
Var
 P:^Byte;
begin
 P:=@Fil;
 If P^=0 then IsOpen:=False else IsOpen:=True;
end;

begin
  Assign(Fi,'FileOPEN.PAS');
  Writeln(ISOpen(Fi));
end.