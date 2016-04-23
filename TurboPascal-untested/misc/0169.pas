
function MSCDEXFN : string;
var s : string;
    f : text;
    i : byte;
    fmSave : byte;
begin
  mscdexfn := '';                  { To indicate not found }
  fmSave := FileMode;              { Store the original file mode }
  FileMode := 0;                   { Also if read-only }
  Assign (f, 'r:\autoexec.bat');   { Browse the AUTOEXEC.BAT }
  {$I-} Reset (f); {$I+}
  if IOResult <> 0 then exit;      { AUTOEXEC.BAT not found }
  while not eof(f) do begin        { Line by line }
    readln (f, s);
    for i := 1 to Length(s) do s[i] := Upcase(s[i]);
    if Pos('MSCDEX', s) > 0 then begin      { Is this the line }
      if Pos ('REM', s) = 1 then continue;  { Skip rem lines }
      Close (f);
      FileMode := fmSave;          { Restore the original mode }
      i := Pos('/D:', s);          { Look for the switch }
      if i = 0 then exit;          { Nah! }
      i := i + 3;                  { Where the name should start }
      if i > Length(s) then exit;  { Nothing there! }
      s := Copy (s, i, 255);       { Rest of the line after /D: }
      mscdexfn := s;
      i := Pos (' ', s);
      if i = 0 then exit;
      mscdexfn := Copy (s, 1, i-1);
      exit;                        { Don't close twice }
    end; {if}
  end; {while}
  Close (f);
  FileMode := fmSave;              { Restore the original mode }
end; (* mscdexfn *)

   All the best, Timo

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
ts@uwasa.fi http://uwasa.fi/~ts BBS 961-3170972; FIN-65101,  Finland

