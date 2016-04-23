{
| From: Scott Stone <pslvax!ucsd!u.cc.utah.edu!ss8913>
|
| This may sound like a simplistic request, but I need code to do the
following:

 not really trivial, although its not hard
|
| Take a standard 80-column textfile and reformat it (w/ correct
| wordwrapping) to be a new text file with lines of specified length (ie,
| 40, 50, 60, etc).  Can anyone tell me how to do this (w/o truncating
| lines, and w/o splitting words)?

 anyway, the following program may fill your needs as is
 its for dos, of course, ..
 (just change the constant max_wid to 40, 50, 60 etc), or,
 at least, it will give you a head start on writing a program
 for yourself.
}

{*************************************************************************
Program reformat
by Sadunathan Nadesan
6/9/89

Formats a file into paragraphs suitable for sending via MCI

Usage: (on MS Dos)   % reformat < filename > outfilename

*************************************************************************}

program reformat(input,output);

const
        max_wid =      80; {all output lines are less than this}
      {change this for different sized lines}
type
 i_line  = string;  {input line buffer type}
 o_line  = string;  {input line buffer type}
 ref = ^node;
 node = record
    word : string;
    next : ref;
   end;
var
 root : ref;  {beginning of sized line}
 tail : ref;  {pointer to last record in list}
 line : i_line; {input buffer}
{------------------------------------------------------------------------}

function end_of_paragraph (buffer : i_line): boolean;
{detect the end of a paragraph}
begin
if (length(buffer) > 0) then
     end_of_paragraph := FALSE
else
     end_of_paragraph := TRUE;
end;

{------------------------------------------------------------------------}
procedure store_words ( buffer : i_line );
{ **********************************************************
  create a single linked list of all the words in a paragraph)
  this is called anew for every line of the paragraph, but
  uses a global linked list that it keeps working with.

  input paramters are buffer = the input line
  uses global variables root and tail
  ********************************************************** }
var
 insize          : integer; {size of input line}
 b_counter : integer; {position marker in input buffer}
 p  : ref;  {word record}
begin
insize    := length(buffer);
b_counter := 1;
if not (end_of_paragraph(buffer)) then  {if not an empty line}
     repeat    {for each word in the input line}
   begin
   new (p);   {make a bucket for the word}
   with p^ do
        begin
        next := nil;
        word := '';
        repeat
      begin
      if (buffer[b_counter] <> ' ') then
    word := concat(word, buffer[b_counter]);
      b_counter := b_counter + 1;
      end;
        until ((buffer[b_counter] = ' ') or (b_counter > insize));
        end;
   if (root = nil) then    {this is the first word in the par.}
        begin
        root := p;
        tail := p;
        end
   else   {attach this word to the list of words}
        begin
        tail^.next := p;
        tail := p;
        end;
   end; {repeat 1}
     until (b_counter > insize);
end; {store_words}

{------------------------------------------------------------------------}
procedure format_output( p : ref );
{ **********************************************************
  dump a single linked list of all the words in a paragraph
  out into lines of <= max_wid characters

  input paramters is p = root, the starting record of the linked word list
  uses global variable line

  ********************************************************** }
var
 pretty   : o_line; {output buffer}
 one_more  : boolean;
begin
one_more := false;
pretty := '';
while (p^.next <> nil) do
     begin
     if (length(p^.word) + length(pretty) + 1 < max_wid)  then
        begin
        pretty := concat (pretty, p^.word);
        pretty := concat (pretty, ' ');
        p := p^.next;
        end
     else
   begin
   writeln(pretty);
   pretty := '';
   end;

     if (p^.next = nil) then   {for the last word!}
   if (length(p^.word) + length(pretty) + 1 < max_wid)  then
        pretty := concat (pretty, p^.word)
     else
   one_more := true;
     end;

if (length(pretty) > 0) then  {get the last line}
     writeln(pretty);
if (one_more) then
     writeln(p^.word);
end;
{------------------------------------------------------------------------}

begin
root := nil;
repeat
     repeat
   begin
   readln(input, line);
   store_words ( line);
   end;
     until (end_of_paragraph(line));

     if (root <> nil) then
   begin
   format_output(root);
   writeln;
   root := nil;
   end;

until (eof(input));
end.
