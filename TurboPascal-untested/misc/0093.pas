{
 After looking around through some of my routines, I found a few that were
 generic enough that they might be of use to the rest of ya.

 My only request is that if you modify them and make them any cooler than
 they already are -- send me back a copy.  Oh -- yeah -- and if you use
 them in your programs give me credit, or at least a registered copy. :)

 Here's a brief rundown of these routines:

 proc SeqRen -        renames a file, keep a certain number of backups.
                      EG: When you download a file, and one already exists,
                      it renames them. Only thing is, that this keeps them
                      in age order. :)

 func Filetype -      determines the type of a file.  Right now, it only
                      knows about ZIP, ARJ, LHA, EXE and GIF files.  If you
                      can expand on this, feel free - and make sure you
                      mail me back a copy of the new ones!  :)

 func FileExistWild - takes a wildcard filename and determines if any files
                      matching that spec are present.  (Eg: *.EXE)  The
                      filename doesn't even have to be a wildcard, so you
                      could use this as a generic function to see if a file
                      exists or not.

 func SizeFile -      takes a filename as input, and if the file exists, it
                      returns the size of the file.  Returns -1 if file
                      does not exist.

 funct SwtVal -       returns the value of a command line switch.  For
                      example, on a 'comms' (I hate that) program you might
                      want to be able to specify an alternate COM: port on
                      the command line. With this routine you could do that
                      easily, just check for SwtVal('/COM:').  If the
                      result is anything other than an empty string, then
                      that is the value.  You can specify multiple words
                      per command line parameter by replacing the spaces
                      with underscores ('_').

 func StatusBar -     You've all seen those programs which display those
                      nifty progress bars as they do things.  Now you can
                      do it too! Simply call this with the total number of
                      items (eg: the file size say 10 records for example)
                      and the current item (eg: record 4 out of 10 records)
                      and StatusBar will return a demi-hi-res progress bar
                      as a string. :)

 func EraseFiles -    Erases all the files in with a filespec matching the
                      one it is passed.  Example: EraseFiles('*.BAK') would
                      delete all files with the .BAK extension in the
                      current directory.
}

procedure SeqRen(Fn : string; Max : byte);
{ Sequentially rename file Fn, keeping Max number of files }
var idx, rn : byte;
    sfn, efn, ofn : string;
    Rend, whole : boolean;
    f : file;

  function Merge(st:string; ln:longint):string;
  var tmp : string;
  begin
    tmp:=Long2Str(ln);
    if length(tmp)>1 then
    begin
      st[length(st)-1]:=tmp[1];
      st[length(st)]:=tmp[2];
    end
      else
    st[length(st)]:=tmp[1];
    Merge:=St;
  end;

begin
  Rend:=false;whole:=false;idx:=0;    { Set up variables             }

  If pos('.',fn)>0 then               { Disect the filename          }
  begin
    sfn:=copy(fn,1,pos('.',fn)-1);
    efn:=copy(fn,pos('.',fn)+1,length(fn));
  end
    ELSE
  whole:=true;
  repeat
    Inc(idx);
    if not ExistFile(sfn+'.'+Merge(efn, idx)) then rend:=true;
  until (idx=max) or Rend;

  if (idx=max) and (rend=false) then      { Nope?  Okay, no problem.     }
  begin
    Assign(f,sfn+'.'+Merge(efn, max));    { Rename all oldies and make   }
    Erase(f);                             { room for it as number 1      }
    for idx:=(max-1) downto 1 do
    begin
      Assign(f,sfn+'.'+Merge(efn, idx));
      Rename(f,sfn+'.'+Merge(efn, idx+1));
    end;
    rn:=1;
  end;

  if rend then rn:=idx;

  Assign(f,fn);                       { Rename the requested file!   }
  Rename(f,sfn+'.'+Merge(efn, rn));
end;

Type FileIDType = (fEXE, fZIP, fARJ, fLHA, fGIF87);

function FileType(Filename : string) : FileIDType;
{ This function attempts to identify what type of a file Filename is }
var Infile : file;
    IdBytes : Array[1..10] of char;
    SubId : string;
begin
  FileType := fUnknown;
  If NOT ExistFile(FileName) then Exit;
  Assign(Infile, FileName);
  Reset(Infile, 1);
  If (FileSize(Infile) = 0) then
  begin
    Close(Infile);
    Exit;
  end;
  BlockRead(Infile, IDBytes, 10);
  Close(Infile);
  SubId := Copy(IDBytes, 1, 2);
  If (SubID = 'MZ') then FileType := fEXE
    ELSE
  If (SubID = 'PK') then FileType := fZIP
    ELSE
  if (SubID = #96 + #234) then FileType := fARJ
    ELSE
  If (Copy(IDBytes, 3, 5) = '-lh5-') then FileType := fLHA
    ELSE
  If (Copy(IDBytes, 3, 5) = '-lh1-') then FileType := fLHA
    ELSE
  if (Copy(IDbytes, 1, 5) = 'GIF89a') then FileType := fGIF87;
end;

function  FileExistWild(Mask : string) : boolean;      { Does X*.* exist? :) }
var sr : SearchRec;
begin
  FindFirst(Mask, AnyFile, SR);
  If DosError<>18 then
    FileExistWild := TRUE
      ELSE
    FileExistWild := FALSE;
end;

Function SizeFile(Fname : string) : longint;
var  sr : SearchRec;
     idx : integer;
begin
  SizeFile := 0;
  Findfirst(Fname, Anyfile, SR);
  If DosError = 0 then SizeFile := SR.Size ELSE SizeFile := -1;
end;

function SwtVal(Swt : string) : string;
{ Returns the value of a command line switch. Eg: for /COM:2, call
  SwtVal('/COM2:') and it will return 2. }
var ndx, found : byte;
    st : string;
begin
  Found := 0;
  For ndx := 1 to ParamCount do
  begin
    if StUpCase(copy(paramstr(ndx), 1, length(swt))) = StUpCase(swt) then
    begin
      Found := ndx;
      Break;
    end;
  end;
  if (Found = 0) then
  begin
    swtval := '';
    Exit;
  end;
  st := '';
  st := StUpCase(Copy(ParamStr(Found), Length(Swt) + 1,
                 Length(ParamStr(Found)) - Length(Swt)));
  For ndx := 1 to Length(St) do
    if (St[ndx] = '_') then St[ndx] := #32;
  SwtVal := st;
end;

Function StatusBar(total, amt : longint) : string;
Const BarLength = 40;
var a, b, c, d : longint;
    percent : real;
    st : string;
begin
  If (total = 0) OR (amt = 0) then
  begin
    StatusBar := '';
    Exit;
  end;
  if (Amt > Total) then amt := total;
  Percent := Amt / Total * (Barlength * 10);
  a := trunc(percent);
  b := a div 10;
  c := 1;
  percent := amt / total * 100;
  d := trunc(percent);
  st := ' (' + int_to_str(d) + '%)';
  StatusBar := CharStr(b * c, #219) + CharStr(Barlength - (b * c), #176) + st;
end;

function EraseFiles(Path, Mask : string) : integer;
var S : SearchRec;
begin
  FindFirst(Path + Mask, Anyfile - Directory, s);      { Find the first file }
  If (DosError = 18) then exit;                          { No files to erase }
  KillFile(Path + s.name);                            { Erase the first file }
  repeat
    Findnext(s);                                        { Find the next file }
    If NOT (DOSError=18) then KillFile(Path + s.name);      { Erase the file }
  until Doserror=18;                                         { no more files }
  EraseFiles := IOResult;                             { Return the IO result }
end;
