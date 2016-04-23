{
From: tfiske@delphi.com (Todd Fiske)

I've got a huge unit that I've put together over the years that does this,
but I'm not really ready to part with it. I'm happy to trade some tips
though.

The easiest way to start is with text files under 64K, for which you don't
have to worry about lines crossing the buffer boundary. Get the size of the
file, then allocate an array on the heap of that size and blockread the file
into it. Then use a function that reads from the current position up to the
next CR and/or LF and returns all of that as a string. Here's a simple
example of this:

{------------------------------------------------}
{- bintext.pas - binary text file example       -}
{- Todd Fiske (tfiske@delphi.com) - 09/28/1994  -}
{------------------------------------------------}
program bintext;

uses
   dos;

const
   CR = #13;
   LF = #10;

{------------------------------------------------}
{- input structure definition & base routines   -}
{------------------------------------------------}
type
   big_array = array[0..65519] of byte;
   big_ptr = ^big_array;
   input_buffer = record
      data : big_ptr;
      size : word;
      curr : word;
   end;
   input_ptr = ^input_buffer;

procedure start_input(var i : input_ptr; size : word);
begin
   if i = nil then begin
      new(i);                          { create structure }
      i^.size := size;
      GetMem(i^.data, i^.size);        { create array (could test MemAvail) }
      fillchar(i^.data^, i^.size, 0);  { initialize }
      i^.curr := 0;
   end;
end;
procedure stop_input(var i : input_ptr);
begin
   if i <> nil then begin
      FreeMem(i^.data, i^.size);       { done with array }
      dispose(i);                      { done with structure }
      i := nil;
   end;
end;
procedure load_input(i : input_ptr; s : string);
var
   f : file;
begin
   assign(f, s);                       { set filename }
   reset(f, 1);                        { open with record length 1 }
   blockread(f, i^.data^, i^.size);    { read in file - should test IOResult }
   close(f);
end;

{------------------------------------------------}
{- low level access routines                    -}
{------------------------------------------------}
function curr_char(i : input_ptr) : char;
begin
   curr_char := char(i^.data^[i^.curr]);
end;
procedure next_char(i : input_ptr);
begin
   inc(i^.curr);
end;
function curr_pos(i : input_ptr) : word;
begin
   curr_pos := i^.curr;
end;
function end_of_input(i : input_ptr) : boolean;
begin
   end_of_input := i^.curr >= i^.size;
end;

{------------------------------------------------}
{- medium level access                          -}
{------------------------------------------------}
function get_line(i : input_ptr) : string;
var
   w   : string;
   stt : word;
   len : byte;
begin
   stt := curr_pos(i);
   while (not (curr_char(i) in [CR, LF])) and (not end_of_input(i)) do
      next_char(i);
   {- testing for both CR and LF here allows reading of Unix files -}

   len := curr_pos(i) - stt;           { determine length read }
   move(i^.data^[stt], w[1], len);     { copy into work string }
   w[0] := char(len);                  { set work string length }

   if curr_char(i) = CR then next_char(i);  { skip line-end chars }
   if curr_char(i) = LF then next_char(i);

   get_line := w;                      { return work string }
end;

{------------------------------------------------}
{- main program                                 -}
{------------------------------------------------}
var
   sr   : SearchRec;
   i    : input_ptr;
   line : string;

begin
   writeln;
   writeln('BinText - binary textfile example');

   if paramcount = 0 then begin        { check command line }
      writeln;
      writeln('usage: bintext <filename>');
      halt;
   end;

   FindFirst(paramstr(1), AnyFile, sr); { test input file }
   if DOSError <> 0 then begin
      writeln(paramstr(1), ' not found');
      halt;
   end;
   if sr.size > 65520 then begin
      writeln(sr.name, ' : ', sr.size, ' bytes - too big (65520 bytes max)');
      halt;
   end;

   i := nil;                           { load, read, and close }
   start_input(i, sr.size);
   load_input(i, sr.name);

   while not end_of_input(i) do begin
      line := get_line(i);
      writeln(line);
   end;

   stop_input(i);
end.
{------------------------------------------------}
{- eof                                          -}
{------------------------------------------------}

{
This array-of-char file handling can be very flexible. I've included routines
in my own to do things like skip whitespace, skip while in a particular groups
of characters, skip until in a group of characters, get-while and get-until
routines, etc. Another thing you can do is save the byte start position of each
line, and jump right to that line by setting i^.curr. What's more, the same
basic methods work on binary files as well.
}
