program PrintPS;
{ Print text to a PostScript Printer, takes filename on command line
  Chris J G Frizelle    CompuServe 70630,717   October 1994
  Released into the public domain  }

const
  PageLen = 61;         { length of a page, lines of text }
var
  Str, pPort, FName : string;
  f, tf        : text;
  cLine        : byte;
  cPage        : longint;

function StringFix(S : string) : string;
  begin
    { replace \ by \\ and ( by (( and ) by )) and anything else you
      need to do to cope with pound (Sterling) signs, high ascii
      characters -- an exercise for you! }
    StringFix := S;
  end;  { StringFix }

begin
  { open the file to be printed, the file name is on the command line }
  if ParamCount < 2 then begin
    WriteLn('PrintPS  Print text files on a PostScript Printer');
    WriteLn('Chris J G Frizelle October 1994  CompuServe 70630,717');
    WriteLn('Syntax:  PRINTPS  <filename>  <port>');
    WriteLn('Example: PRINTPS  config.sys  lpt1');
    HALT;
  end;
  FName := ParamStr(1);                 { file to print }
  pPort := ParamStr(2);                 { port or filename for output }
  assign(TF, FName);
  reset(TF);

  assign(f, pPort);                     { open the printer }
  rewrite(f);
  { set up counters }
  cLine := 0;                           { line counter }
  cPage := 1;                           { page counter }

  { do prolog -- subroutines for use by the PostScript program }
  WriteLn(f, #4);                       { Ctrl D character = new PS job }
  WriteLn(f, '%!PS-Adobe-2.0');         { this is a PS document... }
  WriteLn(f, '/Top 750 def');           { location of top margin, points }
  WriteLn(f, '/Head 790 def');          { location of header }
  WriteLn(f, '/LeftMarg 65 def');       { amount of left margin }
  WriteLn(f, '/PnumPos 500 def');       { position of page number }
  { subroutine to select our default font -- Courier }
  WriteLn(f, '/Deffont {/Courier findfont 10 scalefont setfont} def');
  { subroutine to print a line of text }
  WriteLn(f, '/DoLine { %def');
  WriteLn(f, '   show NewLine }def');
  { subroutine to do a new line }
  WriteLn(f, '/NewLine { %def');
  WriteLn(f, '   currentpoint 11 sub');
  WriteLn(f, '   exch pop LeftMarg');
  WriteLn(f, '   exch moveto }bind def');
  WriteLn(f, '%%EndProlog');

  { first page heading: file name and page number }
  WriteLn(f, 'LeftMarg Head moveto');
  WriteLn(f, '/Courier-Bold findfont 10 scalefont setfont');
  WriteLn(f, '('+FName+')DoLine');
  WriteLn(f, 'PnumPos Head moveto');
  WriteLn(f, '(Page ', cPage, ')DoLine');
  WriteLn(f, 'Deffont');
  WriteLn(f, 'LeftMarg Top moveto');

  while not EOF(TF) do begin
    ReadLn(TF, Str);            { read a line from input file }
    Str := StringFix(Str);      { fix up the line of text }
    inc(cLine);
    if cLine = PageLen then begin
      { new page needed, print previous page and do header }
      Inc(cPage);
      WriteLn(f, 'showpage');                   { outputs existing page }
      WriteLn(f, 'LeftMarg Head moveto');
      WriteLn(f, '/Courier-Bold findfont 10 scalefont setfont');
      WriteLn(f, '('+FName+')DoLine');
      WriteLn(f, 'PnumPos Head moveto');
      WriteLn(f, '(Page ', cPage, ')DoLine');
      WriteLn(f, 'Deffont');
      WriteLn(f, 'LeftMarg Top moveto');
      cLine := 1;
    end;
    WriteLn(f, '('+Str+')DoLine');              { print line of text file }
  end;
  WriteLn(f, 'showpage '#4);  { output final page & Ctrl D for end of job }

  close(TF);
  close(f);

end.
