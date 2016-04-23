unit databox;

{ This is a unit to let you open data-entry boxes on the screen for quick 'n'
  easy data entry.  It operates on variables of type "string", "integer",
  "word", "byte", "longint" and "boolean".  There are two main routines to
  call here:

    OpenBox(x, y, data, temp, type) -- to open a data entry box on the screen
    ReadBoxes -- to read all data entry boxes

  The parameters for "OpenBox":
    x, y -- the coordinates where the box should appear on the screen
    data -- the variable you want to do data entry on
    type -- an character indicating what type of variable you're working on.
            Valid "types" are:

            'S' -- String            'I' -- Integer
            'W' -- Word              'L' -- LongInt
            'Y' -- Byte              'B' -- Boolean

    temp -- a string "template" indicating the size of the data entry
            field and the data acceptable at each position.  The following
            characters mean the following:

            'X' -- accept any character                 ( strings )
            '!' -- accept any character, but capitalize ( strings )
            '9' -- accept only digits and minus signs   ( numeric )
            'T' -- accept only 'T' and 'F'              ( boolean )
            'Y' -- accept only 'T', 'F', 'Y' and 'N'    ( boolean )

            All of these template characters are valid on strings.  For
            numeric fields, the whole template gets converted to all 9's;
            for boolean, the template will either be a single 'T' or 'Y'
            (it defaults to 'T').

    Examples:

      OpenBox(12, 10, counter, '99999', 'I');

      -- is for an integer variable "counter".  It opens a data entry box at
         position (12, 10), and is five characters across.

      OpenBox(1, 14, yes_or_no, 'Y', 'b')

      -- opens a data entry box for a boolean variable "yes_or_no", and will
         accept only a "Y" or an "N" as input.

      OpenBox(1, 25, namestring, '!XXXXXXXXXXXXXXXX', 's')

      -- opens a data entry box for a string variable "namestring"; it will
         automatically capitalize the first letter, and accept every other
         character entered "as is".

    When you have opened all your data boxes, call "ReadBoxes" to allow
    the user to actually input into the boxes.  Once you are done, the
    boxes "close" so you can't do any more data entry on them.  There is
    also a "ClearBoxes" procedure to manually "close" open boxes, and a
    "Qwrite" procedure for doing direct video writes.

    Oh, I'm Lou Duchez, and if you could leave my name somewhere in the
    code I'd appreciate it.  I'll never be rich off of public domain code
    like this, so at least help me get famous ...
  }
{
-------------------------------------------------------
}
interface

const boxforeground: byte = 1;
      boxbackground: byte = 7;

procedure qwrite(x, y: byte; s: string; f, b: byte);
procedure openbox(x, y: byte; var data; template: string; datatype: char);
procedure clearboxes;
procedure readboxes;
{
-------------------------------------------------------
}
implementation
uses crt;       { for "checkbreak" and "readkey" functions }

const maxboxes = 255;     { open up to 255 data boxes simultaneously }

type boxrecord = record   { holds all the data we need }
     x, y: byte;          { position to display on screen }
     template: string;    { describes size and type of data field }
     dataptr: pointer;    { points to data }
     datatype: char;      { type of data we're pointing to }
     end;

var boxes: array[1 .. maxboxes] of ^boxrecord;  { all the data boxes }
    boxcount, thisbox, boxpos, boxlength: byte;
    boxstring: string;
    boxmodified: boolean;
{
-------------------------------------------------------
}
procedure qwrite(x, y: byte; s: string; f, b: byte);  { direct video writes }

{ x, y: coordinates to display string at }
{ s: the string to display }
{ f, b: the foreground and background colors to display in }

type  videolocation = record           { video memory locations }
        videodata: char;               { character displayed }
        videoattribute: byte;          { attributes }
        end;

var cnter: byte;
    videosegment: word;
    vidptr: ^videolocation;
    videomode: byte absolute $0040:$0049;
    scrncols: byte absolute $0040:$004a;
    monosystem: boolean;
begin

{ Find the memory location where the string will be displayed at, according to
  the monitor type and screen location.  Then associate the pointer VIDPTR with
  that memory location: VIDPTR is a pointer to type VIDEOLOCATION.  Insert the
  screen data and attribute; now go to the next character and video location. }

  monosystem := (videomode = 7);
  if monosystem then videosegment := $b000 else videosegment := $b800;
  vidptr := ptr(videosegment, 2*(scrncols*(y - 1) + (x - 1)));
  for cnter := 1 to length(s) do begin
    vidptr^.videoattribute := (b shl 4) + f;
    vidptr^.videodata := s[cnter];
    inc(vidptr);
    end;
  end;
{
-------------------------------------------------------
}
procedure movecursor(boxnum, position: byte);          { Positions cursor. }
var tmpx, tmpy: byte;
begin
  tmpx := (boxes[boxnum]^.x - 1) + (position - 1);
  tmpy := (boxes[boxnum]^.y - 1);
  asm
    mov ah, 02h           { Move cursor here.  I don't use GOTOXY because it }
    mov bh, 00h           { is window-dependent. }
    mov dh, tmpy
    mov dl, tmpx
    int 10h
    end;
  end;
{
-------------------------------------------------------
}
procedure openbox(x, y: byte; var data; template: string; datatype: char);
var i: byte;
    datastring, tempstring: ^string;
begin
  if boxcount < maxboxes then begin   { If we have room for another data }
    inc(boxcount);                    { box, allocate memory for it from }
    new(boxes[boxcount]);             { the heap and fill its fields. }
    boxes[boxcount]^.x := x;
    boxes[boxcount]^.y := y;
    boxes[boxcount]^.dataptr := @data;
    boxes[boxcount]^.template := template;
    boxes[boxcount]^.datatype := upcase(datatype);
    case upcase(datatype) of

    { "Fix" data entry template as needed.  Make sure the string data and
      the template are of the same length.  Numeric templates should consist
      of all 9's.  Boolean templates should be either 'Y' or 'T'. }

      'S': begin
             datastring := boxes[boxcount]^.dataptr;
             tempstring := addr(boxes[boxcount]^.template);
             while length(datastring^) < length(tempstring^) do
                   datastring^ := datastring^ + ' ';
             while length(tempstring^) < length(datastring^) do
                   tempstring^ := tempstring^ + ' ';
             end;
      'W', 'I', 'L', 'Y': for i := 1 to length(template) do
                          boxes[boxcount]^.template[i] := '9';
      'B': begin
             boxes[boxcount]^.template[0] := #1;
             if not (boxes[boxcount]^.template[1] in ['Y', 'T']) then
                boxes[boxcount]^.template := 'T';
             end;
      end;
    end;
  end;
{
-------------------------------------------------------
}
procedure clearboxes;           { Free up all memory for "box" data. }
begin
  while boxcount > 0 do begin
    dispose(boxes[boxcount]);
    dec(boxcount);
    end;
  end;
{
-------------------------------------------------------
}
procedure fixstring(boxnumber: byte);   { Adjusts string for displaying }
var i: byte;                            { so that each character adheres to }
begin                                   { the corresponding template char. }
  for i := 1 to length(boxstring) do
    case upcase(boxes[boxnumber]^.template[i]) of
      'X': ;
      '!': boxstring[i] := upcase(boxstring[i]);
      '9': if not (boxstring[i] in ['-', '0' .. '9']) then boxstring[i] := ' ';
      'T': case upcase(boxstring[i]) of
           'Y', 'T': boxstring[i] := 'T';
           'N', 'F': boxstring[i] := 'F';
           else boxstring[i] := ' ';
           end;
      'Y': case upcase(boxstring[i]) of
           'Y', 'T': boxstring[i] := 'Y';
           'N', 'F': boxstring[i] := 'N';
           else boxstring[i] := ' ';
           end;
      end;
  qwrite(boxes[boxnumber]^.x, boxes[boxnumber]^.y, boxstring,
         boxforeground, boxbackground);
  end;
{
-------------------------------------------------------
}
procedure displaybox(boxnumber: byte); { Convert data to string and display. }
var lentemplate: byte;
    pntr: pointer;
begin
  pntr := boxes[boxnumber]^.dataptr;
  lentemplate := length(boxes[boxnumber]^.template);
  case boxes[boxnumber]^.datatype of
    'S':  boxstring := string(pntr^);
    'I':  str(integer(pntr^): lentemplate, boxstring);
    'W':  str(word(pntr^):    lentemplate, boxstring);
    'Y':  str(byte(pntr^):    lentemplate, boxstring);
    'L':  str(longint(pntr^): lentemplate, boxstring);
    'B':  if boolean(pntr^) then boxstring := 'T' else boxstring := 'F';
    end;
    fixstring(boxnumber);
  end;
{
-------------------------------------------------------
}
procedure deletekey;    { delete: remove character at cursor and shift over }
var i: byte;
begin
  boxmodified := true;
  for i := boxpos to boxlength - 1 do  boxstring[i] := boxstring[i + 1];
  boxstring[boxlength] := ' ';
  end;

procedure backspace;        { backspace: back up one and delete if we're }
begin                       { still in the same box }
  boxpos := boxpos - 1;
  if boxpos = 0 then begin
    dec(thisbox);
    boxpos := 255;
    end
   else deletekey;
  end;

{ Enter, Tab, and Shift-Tab move you to the beginning of prev/next box }

procedure enterkey;   begin inc(thisbox); boxpos := 1; end;
procedure tab;        begin inc(thisbox); boxpos := 1; end;
procedure reversetab; begin dec(thisbox); boxpos := 1; end;

{ PgUp, PgDn, Esc take you out of editing; "Esc" indicates that the
  "current" box should not be updated }

procedure pageup;     begin thisbox := 0; end;
procedure pagedown;   begin thisbox := 0; end;
procedure esckey;     begin thisbox := 0; boxmodified := false; end;

{ Up / Down }

procedure moveup;     begin dec(thisbox); end;
procedure movedown;   begin inc(thisbox); end;

procedure moveleft;   { Move left; if we go too far left, move up }
begin
  dec(boxpos);
  if (boxpos = 0) then begin
    boxpos := 255;
    moveup;
    end;
  end;

procedure moveright;  { Move right; if we go too far right, move down }
begin
  inc(boxpos);
  if (boxpos > boxlength) then begin
    boxpos := 1;
    movedown;
    end;
  end;

procedure literalkey(keyin: char);  { accept character into field }
var i: byte;
    goodkey, insmode: boolean;
    keyboardstat: byte absolute $0040:$0017;
begin
  case upcase(boxes[thisbox]^.template[boxpos]) of   { does char match tmplt? }
    '9': goodkey := (keyin in ['-', '0'..'9']);
    'T': goodkey := (upcase(keyin) in ['T', 'F']);
    'Y': goodkey := (upcase(keyin) in ['T', 'F', 'Y', 'N']);
    else goodkey := true;
    end;
  if goodkey then begin             { character matches template -- use it }
    boxmodified := true;
    insmode := (keyboardstat and $80 = $80);
    if insmode then begin
      i := length(boxstring);       { "Insert" mode: make space for new char }
      while i > boxpos do begin
        boxstring[i] := boxstring[i - 1];
        dec(i);
        end;
      end;
    boxstring[boxpos] := keyin;     { enter character and move to the right }
    moveright;
    end;
  end;
{
-------------------------------------------------------
}
procedure readbox;  { get data input on the box specified by THISBOX }
var keyin: char;
    startingbox, i: byte;
    pntr: pointer;
    dummyint: integer;
    numstring: string;
begin
  boxmodified := false;             { "housekeeping" here }
  startingbox := thisbox;
  displaybox(thisbox);
  boxlength := length(boxstring);
  if boxpos > boxlength then boxpos := boxlength;   { cursor positioning }
  if boxpos < 1 then boxpos := 1;
  while (thisbox = startingbox) and
        (boxpos >= 1) and (boxpos <= boxlength) do begin  { process field }
    fixstring(startingbox);
    movecursor(startingbox, boxpos);
    keyin := readkey;                         { Interpret keystrokes here }
    case keyin of
       #0:  case readkey of
              #15:  reversetab;
              #72:  moveup;
              #73:  pageup;
              #75:  moveleft;
              #77:  moveright;
              #80:  movedown;
              #81:  pagedown;
              #83:  deletekey;
              end;
       #8:  backspace;
       #9:  tab;
      #13:  enterkey;
      #27:  esckey;
      else  literalkey(keyin);
      end;
    end;
  if boxmodified then begin       { If data was changed, update variable }

    { This section handles numeric decoding.  Since "Val" gets real uppity
      if there are spaces in the middle of your string, these couple loops
      isolates the first section of the data entry string surrounded by
      spaces.  Then "Val" processes that part. }

    i := 1;
    while (i <= length(boxstring)) and (boxstring[i] = ' ') do inc(i);
    numstring[0] := #0;
    while (i <= length(boxstring)) and (boxstring[i] <> ' ') do begin
      inc(numstring[0]);
      numstring[length(numstring)] := boxstring[i];
      inc(i);
      end;
    pntr := boxes[startingbox]^.dataptr;

    { Put the updated data back into its original variable. }

    case boxes[startingbox]^.datatype of
      'S': string(pntr^) := boxstring;
      'I': val(numstring, integer(pntr^), dummyint);
      'W': val(numstring, word(pntr^),    dummyint);
      'Y': val(numstring, byte(pntr^),    dummyint);
      'L': val(numstring, longint(pntr^), dummyint);
      'B': boolean(pntr^) := (upcase(boxstring[1]) = 'Y') or
                             (upcase(boxstring[1]) = 'T');
      end;
    end;

  { Do a final data display. }

  displaybox(startingbox);
  movecursor(startingbox, boxlength + 1);
  end;
{
-------------------------------------------------------
}
procedure readboxes;          { gets data input on all boxes }
var oldcheckbreak: boolean;
begin
  oldcheckbreak := checkbreak;
  checkbreak := false;
  for thisbox := 1 to boxcount do displaybox(thisbox);  { display data boxes }
  thisbox := 1;
  boxpos := 1;
  while (thisbox >= 1) and (thisbox <= boxcount) do readbox;
  clearboxes;
  checkbreak := oldcheckbreak;
  end;
{
-------------------------------------------------------
}
begin               { initialize to "no boxes" }
  boxcount := 0;
  end.

==============================================================================
TEST PROGRAM:
==============================================================================
program datatest;
uses databox, crt;

var i: integer;    s: string;     w: word;
    b: boolean;    l: longint;    y: byte;

begin
  clrscr;
  i := 10;              openbox(1, 1, i, '999999', 'i');
  w := 10;              openbox(1, 3, w, '999999', 'w');
  s := 'SpamBurger';    openbox(1, 5, s, '!xxxxxxxxxxxxxxx', 's');
  readboxes;
  gotoxy(1, 18);  writeln(i);  writeln(w);  writeln(s);

  b := false;           openbox(1, 7, b, 'Y', 'b');
  l := 10;              openbox(1, 9, l, '9999999999', 'l');
  y := 20;              openbox(1,11, y, '9999999999', 'y');
  readboxes;
  gotoxy(1, 21);  writeln(b);  writeln(l);  writeln(y);
  end.
