(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0375.PAS
  Description: How to get username ?
  Author: PAVEL CISAR
  Date: 01-02-98  07:33
*)


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
