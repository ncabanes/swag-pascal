{
  Erase is the proper procedure to delete one file. Here's a program I
  wrote a while back that does the same thin DELTREE does. Look it over
  and see if it helps get you started. BTW, I modified this a bit to
  remove commercial lib refs so there may be a syntax bug or two...

  RFD.PAS - Copyright 1991 Steve Rogers
  Released to public domain since DOS6 has DelTree... :)
}

{$m 16384,0,8192}
{$i-}

uses
  crt,dos;

{-----------------------}
function rfd(const s : pathstr) : boolean;
var
  f : file;
  d : searchrec;
  temp : boolean;

begin
  writeln('Removing '+s+'\');

  findfirst(s+'\*.*',anyfile-directory,d);
  if (doserror=0) then begin

    { Use DOS to get rid of the lion's share of files }
    swapvectors;
    exec(getenv('COMSPEC'),'echo y|del '+s+'\*.* >nul');
    swapvectors;

    { Now get the stragglers }
    findfirst(s+'\*.*',anyfile-directory,d);
    while (doserror=0) do begin
      assign(f,s+'\'+d.name);
      setfattr(f,archive);
      erase(f);
      findnext(d);
    end;
  end;

  { Now process the subs }
  findfirst(s+'\*.*',directory,d);
  while (doserror=0) do begin
    if (d.attr and directory = directory) and (d.name[1]<>'.') then
      temp:= rfd(s+'\'+d.name);
    findnext(d);
  end;

  rmdir(s);
  rfd:= (ioresult=0);
end;

{-----------------------}
begin
  clrscr;
  writeln('RFD - Remove Full Directory  Copyright 1991 Steve Rogers');

  if (paramcount<1) then
    writeln('Syntax is: RFD <directory>')
  else begin
    if rfd(paramstr(1)) then
      writeln(paramstr(1)+' removed. All files and subs deleted.')
    else
      writeln('Unable to find or remove '+paramstr(1));
  end;
end.
