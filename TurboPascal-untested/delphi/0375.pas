
Another solution (my favorite :-):

function GetUserName(Var Name:String):Boolean;
var I : integer
begin
  I := 100 ; {buffer length}
  setlength (Name,I) ;
  GetUserName (pchar(Name),I) ;
  setlength (Name,I) ;
  Result := (I <> 0) ;
end ;

