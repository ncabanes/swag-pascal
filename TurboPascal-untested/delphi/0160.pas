String manipulation and parsing is often a place where we wish that we had
more functions and methods to do our work for us.  There are many existing
methods that cover our work-a-day needs, but every now and then we need
something more.

In Paradox for Windows, there is an immensely useful function called
BreakApart().  It can do so many things that I have written one (or two)
for Delphi.

Here is how it works:
You pass the base string that you want to parse and the string that you
want to use for the BreakApart().  The function then separates the string
into several pieces and fills a TStringList with their values.

Example:

Base String:  "Here we go."
Break String: " "

Resulting array:
TStringList[0]: "Here"

TStringList[1]: "we"
TStringList[2]: "go."

Note that the break string, in this case spaces, is not to be seen
anywhere in the output.

Now that we know what is done, lets take a look at how to do it.

First, lets look at the string version.

function sBreakApart(BaseString, BreakString: string; StringList: TStringList): TStringList;
var
  EndOfCurrentString: byte;
  TempStr: string;
begin
  repeat
    EndOfCurrentString := Pos(BreakString, BaseString);
    if EndOfCurrentString = 0 then
      StringList.add(BaseString)
    else
      StringList.add(Copy(BaseString, 1, EndOfCurrentString - 1));
    BaseString := Copy(BaseString, EndOfCurrentString + length(BreakString), length(BaseString) - EndOfCurrentString);

  until EndOfCurrentString = 0;
  result := StringList;
end;

This is a fairly straight forward version (as compared with the PChar
version).  We look for the break string.  If we donÆt find it at all,
then we just assign it to the TStringList and go on our merry way.
(Note:  The TStringList must be created outside the function or there
will be problems when the variable goes out of scope.)  If we do find it,
then we want to extract that portion of the string and assign it to the
next available position in the TStringList.  Note that the string is
updated each step of the way.  This is done just because it simplifies
the code.  There are several possible ways of doing this.  I just picked
one.

Let me answer some questions that I hear you asking.

1.  Why didnÆt I make this a procedure?  It is true that the TStringList
would reflect all changes without a value returned, but I left it as a
function because it allows for use in another function that uses the
TStringList.  I use the function in this way later in the article.

E.g.  Listbox1.items.assign(sBreakApart(...));

2.  It doesnÆt interfere with calling it as if it was a procedure.
(I.e. You donÆt need to catch the result if you donÆt want to code it that
way.)

Now that we have seen that it does something, how about if we have it do
something useful.

Here is a search and replace that uses the string version of the
BreakApart() function.

function ReplaceStr(BaseString, ReplaceThis, WithThis: string): string;
var
  t: TStringList;

  i: integer;
begin
  t := TStringList.create;
  sBreakApart(BaseString, ReplaceThis, t);
  if t.count > 1 then
  begin
    result := '';
    for i := 0 to t.count - 2 do
      result := result + t[i] + WithThis;
    result := result + t[i + 1];
  end
  else result := BaseString;
  t.free;
end;

This example requires a form with a pushbutton and 3 edit boxes.
You can call this function like this:

edit1.text := ReplaceStr(edit1.text, edit2.text, edit3.text);

It replaces all occurrences of edit2.text in edit1.text with edit3.text.

I told you that this was simple and useful!

Now lets take a look at the PChar version.  Since we have an idea of how
this works now, IÆll show the code first.

function pBreakApart(BaseString, BreakString: PChar; StringList: TStringList): TStringList;
var
  BreakStringLength: word;
  pEndOfCurrentString, pEndOfBaseString: PChar;
{Automatically gets memory allocated for it.}
  temp: array[0..255] of char;
begin
{Initialize the pointers.}
  BreakStringLength := StrLen(BreakString);
  pEndOfBaseString := BaseString;
  inc(pEndOfBaseString, StrLen(BaseString));
  repeat
    pEndOfCurrentString := StrPos(BaseString, BreakString);
    StringList.add(StrPas(StrLCopy(temp, BaseString, pEndOfCurrentString - BaseString)));

    inc(BaseString, pEndOfCurrentString - BaseString + BreakStringLength);
  until BaseString >= pEndOfBaseString - BreakStringLength;
  result := StringList;
end;

This takes a different approach to solving the same problem.  Since this
is done with a PChar that can be of greatly varying size, it was best to
do it with pointers and pointer arithmetic.  Since we are not changing the
value passed in (which would be bad as it is passed by reference and that
would change the values in their original memory locations) we need a way
to keep track of just where we are in the current part of the process.

A word about pointer arithmetic...  The Inc() and Dec() functions have an
undocumented feature that allows for pointer arithmetic.  The relevant
feature is that the function "knows" the size of the object pointed to
and increments the pointer the correct number of bytes.

Here is an example that uses the PChar version:

procedure TForm1.Button1Click(Sender: TObject);
var
  f: file;
  pStr: PChar;
  LengthOfFile: integer;
  t: TStringList;
begin
  {Get the information.}
  AssignFile(f, 'c:\autoexec.bat');
  {Because this is not a text file type, the record size is 1 (char)}
  Reset(f, 1);
  LengthOfFile := FileSize(f) + 1; {Add one for the null terminator.}
  pStr := AllocMem(LengthOfFile); {Zeros the memory also.}
  BlockRead(f, pStr^, LengthOfFile - 1);
  CloseFile(f);
  t := TStringList.create;
  listBox1.items.assign(pBreakApart(pStr, #13#10, t));
  t.free;
  FreeMem(pStr, LengthOfFile);
end;

This example requires a form that has a listbox and a pushbutton. It reads
the autoexec.bat file into memory in a single gulp using Blockread().
There is just enough memory allocated to get the job done.  This is done
by using the fileÆs size as the basis.  The PChar version is called and
assigned directly, and the file is "broken apart" by carriage return/line
feed.  (Note:  I know that a LoadFromFile() will do this also, but this is
an exercise in memory juggling.)  Then memory clean up is performed.
The contents of the autoexec.bat file are then displayed in the listbox
line by line.

The uses for this are many and varied.  If you used this on a filename with
the full path and did a BreakApart() on "\", you would have element 0 of
the list as the drive, and the last element would be the file name.  You
could break that apart on the ".", and get the separated file name and
extension.

I did not include error checking here.  A string can only hold 255
characters.  It is possible that your users might try to put more than
that in there.  If you want to do the error checking for them, then I
wish you well.  I thought that it would be beyond the scope of this short
article and left it to the reader.

