{
 SJ>     What is the best way to enter extended characters using readln?  I
 SJ> would really like to assign Ctrl-E to ASCII 130.  I tried using ansi
 SJ> and I could get it to work in dos but Pascal seems to override it.
 SJ> Basically what I am tying to do is make it easy for the user to enter
 SJ> foreign letters into a string.  Any suggestions would be appreciated.
 SJ>                                             Stuart Johnston

To achieve this, you have to prog your own ReadLine-procedure, using
the READKEY and KEYPRESSED functions of TP.
You can't get READLN() to do the job for you. You have to do it your
own. :-)

Here is an example of what an Input-Line routine could look like:
It's only a small one. I also have a much more comfortable one, but it
isn't finished yet. :-)))

----------------------------------------------------------------------- }

uses CRT;

function InputLine(column, line, width, color : byte) : string;
{
 Function to read one line of input from the keyboard.
}

var

 i     : byte;
 key   : char;
 coln  : byte;    { column of cursor position }
 entry : byte;    { pointer into inputstring }
 str   : string;  { input string }

begin
 textattr := color;    { set color of whole line }
 gotoxy(column, line);
 for i := column to (column + width - 1) do
  write(#32);
 coln := column;
 entry := 1;
 str[0] := #0;  { empty string }
 while (TRUE) do
 begin
  gotoxy(coln, line);
  key := readkey;
  case key of
   #0 : begin  { Trace Function-keys }
         key := readkey;
        end;
   #8 : begin  { BACKSPACE-key }
         if (entry > 1) then
         begin
          coln := coln - 1;
          gotoxy(coln, line);
          write(#32);
          entry := entry - 1;
         end;
        end;
   #12 : begin        { Ctrl-L : delete entire line }
          gotoxy(column, line);
          for i := column to (column + width - 1) do
           write(#32);
          coln := column;
          entry := 1;
          str[0] := #0;  { empty string }
         end;
   #13 : begin  { RETURN-key }
          if (entry > 1) then  { no RETURN with an empty line! }
          begin
           str[0] := char(entry - 1);  { set string length }
           InputLine := str;
           exit;
          end;
         end;
   #27 : begin        { ESC-key : to abort the entry }
          str := #255;            { set a marker for "ESC-key has been pressed" }
          InputLine := str;
          exit;
         end;
   #32..#254 : begin
                if (entry <= width) then { input field full? }
                begin
                 write(key);
                 str[entry] := key;
                 entry := entry + 1;
                 coln := coln + 1;
                end;
               end;
  end;
 end;
end;

