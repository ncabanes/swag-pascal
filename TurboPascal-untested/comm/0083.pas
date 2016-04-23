{
After begging for help so many times, I thought I'd actually add something to
the echo...  feel free to put this in the SWAG if you want to:

{
 ParseAddress procedure...
 Uses an MKMsg-type address record:

AddrType=Record
    Zone,
    Net,
    Node,
    Point:Word;
 end;

 Probably could be streamlined, but it works :)
}

function strtoint(s:string):word;
{ a more descriptive name would be strtoword, I know... }
var w:word;
    c:integer
begin
 val(s,w,c);
 strtoint:=w;
end;

Procedure ParseAddress (astring : string; var addrout : AddrType);
                        Var D4 : Boolean;
Begin
  D4 := False;
  {Test for 4D address}
  If Pos ('.', astring) <> 0 Then
     D4 := True;
  addrout.Zone := strtoint (Copy (astring, 1, Pos (':', astring) - 1) );
  astring := Copy (astring, Pos (':', astring) + 1, 78);
  addrout.Net := strtoint (Copy (astring, 1, Pos ('/', astring) - 1) );
  astring := Copy (astring, Pos ('/', astring) + 1, 78);
  If D4 Then
     addrout.Node := strtoint (Copy (astring, 1, Pos ('.', astring) - 1) )
  Else
     Begin
     addrout.Node := strtoint (Copy (astring, 1, 78) );
     addrout.Point := 0;
     Exit;
     End;
  astring := Copy (astring, Pos ('.', astring) + 1, 78);
  addrout.Point := strtoint (astring);
End;

