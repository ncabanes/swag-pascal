(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0296.PAS
  Description: Convert Long File name to a 8.3 structur
  Author: ANDRE V.D MERWE
  Date: 08-30-97  10:08
*)


> Has anyone had any luck making GetShortPathName
> to work? It's supposed to convert a long file/path
> name to a DOS 8.3 structure... but it keeps returning
> the same long file name I pass in.

Try this, it worked for me....

function ToShortPath(  sPath : string  ) : string;
var
   iLen : integer;    
   sShort : string;
   szShort : PChar;
begin
   iLen := Length(  sPath  );

   szShort := StrAlloc(  iLen  );
   GetShortPathName(  PChar(sPath),  szShort,  iLen  );

   sShort := szShort;
   StrDispose(  szShort  );

   Result := sShort;
end;

