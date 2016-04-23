{
A number of people have been asking about
the API function GetFullPathName recently.
This function does not do what its name implies.

I have written a function which does convert a
short pathname into a long pathname and thought
I would share it with you.

NB: I haven't done any major checks for bugs so
no guarantees!

HTH
Angus Johnson
------------------------------------------------8<--------------------------
-------------}

function GetLongFileName(fn: string): string;
var
  l,r: integer;
  path: string;
  sr: TSearchRec;
begin
  {return '' if invalid path}
  if (length(fn)<3) or (pos(':\',fn)<>2) then begin
    result := '';
    exit;
  end;
  {return if root directory}
  if length(fn) =3 then begin
    result := uppercase(fn);
    exit;
  end;

  path := uppercase(copy(fn,1,3)); {path = root dir}
  l := 4;

  while true do begin {top of loop}
    r := l;
    while (fn[r] <> '\') and (r <= length(fn)) do inc(r);
    if Findfirst(path+copy(fn,l,r-l),faAnyfile,sr) = 0 then begin {OK}
      if (sr.attr and faDirectory) <> 0 then begin {yes, it is a directory}
        path := path + sr.name+'\';
        FindClose(sr);
        if r >= length(fn) then begin
          result := path;
          exit;
        end;
        l := r+1;
        end
      else begin {not a directory!}
        if r > length(fn) then dec(r);
        if (fn[r] = '\') or (r <> length(fn)) then {an error!}
          result := ''
        else begin {must be a file}
          result := path + sr.name; {OK!}
        end;
        FindClose(sr);
        exit;
      end;
      end
    else begin {An Error!!!!}
      result := '';
      FindClose(sr);
      exit;
    end;
  end; {bottom of loop}
end;
