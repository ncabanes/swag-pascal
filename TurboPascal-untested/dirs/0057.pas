
program soupdir;  {do a directory, listing SOUP files}

{
Russell_Schulz@alpha3.ersys.edmonton.ab.ca (950904)

Copyright 1995 Russell Schulz

this code is not in the Public Domain

permission is granted to use these routines in any application regardless
of commercial status as long as the author of these routines assumes no
liability for any damages whatsoever for any reason.  have fun.
}

uses dos,genericf;

type
  nodep=^node;
  node=record
      filename: string;
      description: string;
      next: nodep;
    end;

var
  head: nodep;

procedure die(s: string);

begin
  writeln(s);
  halt(1);
end;

procedure usage;

begin
  writeln('usage: SOUPDIR');
  halt(2);
end;

procedure lfreadln(var lff: text; var astring: string);

var
  done: boolean;
  c: char;

begin
  astring := '';

  done := false;
  while not done do
    begin
      if eof(lff) then
        done := true
      else if length(astring)>=255 then
        done := true
      else
        begin
          read(lff,c);
          if c=#10 then
            done := true
          else if c<>#13 then
            astring := astring+c;
        end;
    end;
end;

procedure initialize;

var
  areasf: text;
  tempstring: string;
  tempnodep: nodep;

begin
  if paramcount<>0 then
    usage;

  head := nil;

  assign(areasf,'AREAS');
{$I-}
  reset(areasf);
{$I+}
  if ioresult<>0 then
    die('could not open AREAS file');

  while not eof(areasf) do
    begin
      lfreadln(areasf,tempstring);
      new(tempnodep);

      tempnodep^.filename := chopfirstw(tempstring)+'.msg';
      tempnodep^.description := chopfirstw(tempstring);

      tempnodep^.next := head;
      head := tempnodep;
    end;

  close(areasf);
end;

procedure process;

var
  fileinfo: searchrec;
  filename: string;
  tempnodep: nodep;

begin
  findfirst('*.MSG',archive,fileinfo);
  while doserror=0 do
    begin
      filename := lower(fileinfo.name);

{assume no packet will be bigger than a meg}
      write(leftjustify(filename,12,' '),' ',fileinfo.size:6,' ');
      tempnodep := head;
      while tempnodep<>nil do
        begin
          if tempnodep^.filename=filename then
            begin
              write(copy(tempnodep^.description,1,50));
              tempnodep := nil;
            end
          else
            tempnodep := tempnodep^.next;
        end;
      writeln;
      findnext(fileinfo);
    end;
end;

procedure shutdown;

begin
end;

begin
  initialize;
  process;
  shutdown;
end.
-- 
