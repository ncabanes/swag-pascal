{
You included one of my subroutines in the SWAG-library. Unfortunately
it was buggy. Below you will find the, hopefully, bugfree code.
}

function GetRelativeFileName (F: FNameStr): FNameStr;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  i: integer;
  rd: string;
begin
  F := FExpand(F);
  FSplit(F, D, N, E);
  if GetCurDrive = D[1] then begin
    { Same Drive - remove Driveinformation from D }
    Delete (D,1,2);
    F := GetCurDir;
    Delete (F,1,2);
    { Maybe it is a file in a directory higher than the actual directory }
    i := Pos(F,d);
    if i > 0 then begin
      if length(f) = 1 then Delete (d,1,length(F))
                       else Delete (d,1,length(F)+1);
      end
    else begin
      rd := '';
      if Pos(d,F) = 0 then begin
        repeat
          repeat
            rd := d[Ord(d[0])]+rd;
            dec(d[0]);
          until d[Ord(d[0])] = '\';
        until Pos(d,F) > 0;
        end;
      { Maybe it  is a file in a directory lower than the actual directory }
      if length(d)=1 then
         d:= '\'+rd
      else if Pos(d,F) > 0 then begin
        repeat
          rd := '..\'+rd;
          dec (F[0]);
          while F[Ord(F[0])] <> '\' do dec(F[0]);
        until (Pos(F,D) > 0) and not((d='\') and (F<>'\'));
        d := rd;
        end
      end;
    end;
  GetRelativeFileName := lower(D+N+E);
end;

