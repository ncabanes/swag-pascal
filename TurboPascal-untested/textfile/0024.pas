{ GUY MCLOUGHLIN }

(* Public domain text-file "seek" line demo.            *)
(* Guy McLoughlin - October 1993.                       *)
program SeekLineDemo;

(* Text buffer type definition.                         *)
type
  TextBuffer = array[1..(16 * 1024)] of byte;

  (***** Check for IO file errors.                                    *)
  (*                                                                  *)
procedure CheckForErrors;
var
  Error : byte;
begin
  Error := ioresult;
  if (Error <> 0) then
  begin
    writeln('FILE ERROR = ', Error);
    halt(1);
  end;
end;

(***** Seek to specified line in a text file. LineCount returns the *)
(*     line number that was "seeked" to.                            *)
(*                                                                  *)
procedure SeekLine({input } var TextFile   : text;
                            var Tbuffer    : TextBuffer;
                                LineNumber : word;
                   {output} var LineCount  : word);
var
  TempStr  : string;
begin
  (* Assign text buffer.                                  *)
  settextbuf(TextFile, Tbuffer);

  (* Reset text file, and check for IO errors.            *)
  {$I-}
  reset(TextFile);
  {$I+}
  CheckForErrors;

  (* Read text file until just before specified line, or  *)
  (* end of text file reached.                            *)
  LineCount := 0;
  repeat
    readln(TextFile, TempStr);
    inc(LineCount)
  until (LineCount = pred(LineNumber)) or eof(TextFile);

  (* If end of text file not reached, add 1 to LineCount. *)
  if NOT eof(TextFile) then
    inc(LineCount)
end;

var
  LineCount,
  LineNumber : word;
  TempStr    : string;
  TextFile   : text;
  Tbuffer    : TextBuffer;

BEGIN
  (* Assign text filename.                                *)
  assign(TextFile, 'TEST.TXT');

  (* Obtain line numbe to display from user.              *)
  write('ENTER LINE NUMBER TO DISPLAY : ');
  readln(LineNumber);
  writeln('SEEKING TO LINE ', LineNumber);

  (* Seek to line user wants to see.                      *)
  SeekLine(TextFile, Tbuffer, LineNumber, LineCount);

  (* If seek was successful, then read and display line.  *)
  if (LineCount = LineNumber) then
  begin
    readln(TextFile, TempStr);
    writeln;
    writeln('LINE ', LineNumber, ' = ', TempStr);
  end
  else
    (* Else, display total number of lines in text file.    *)
    writeln('Sorry, total lines in TEST.TXT = ', LineCount);

  (* Close the text file.                                 *)
  close(TextFile);
END.
