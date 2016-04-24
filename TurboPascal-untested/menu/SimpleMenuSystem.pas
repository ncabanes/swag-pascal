(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0015.PAS
  Description: Simple Menu System
  Author: BRANDON SNEED
  Date: 03-04-97  13:18
*)

{ NMENU.PAS - 8/25/96 by Brandon Sneed (Nivenh) }
{ Use it and abuse it and don't give me credit if you don't want too. }
{ example of use at the end !! }
unit nmenu;

interface

uses crt;

type
  menurec = record
            text : string[30]; { description }
            xpos,              { X coord }
            ypos : byte;       { Y coord }
            key  : char;       { hot key }
            end;

function domenu(var menu; numitems, start, highclr, loclr : byte) : byte;
  { the MENU param must be untyped since we'll be passing an array to it }
  {  menu = menu array constant                   }
  {  numitems = number of items in the menu array }
  {  start = which item should be highlighted by default? usually 1 }
  {  highclr = color to highlight with            }
  {  loclr = color to deselect with               }

implementation

function domenu(var menu; numitems, start, highclr, loclr : byte) : byte;
type
	{ Increase the size of this array for more than 25 menu items }
  menucast = array [1..25] of menurec;
var
  cnt : byte;
	choice : byte;
  getkey : char;
begin
  if start > numitems then start := 1;
  begin
  { draw the menu }
  for cnt := 1 to numitems do
    with menucast(menu)[cnt] do
    begin
    textattr := loclr;
    gotoxy(xpos, ypos);
    write(text);
    end;
  end;

  getkey := #255;
  choice := start;

  repeat
    if (choice <= numitems) and (choice > 0) then
    with menucast(menu)[choice] do
      begin
      textattr := highclr;
      gotoxy(xpos, ypos);
      write(text);
      textattr := loclr;

      if keypressed then
        getkey := readkey;
      { if a arrowkey, or any function type key is sent, a #0 always is sent
        first, and THEN the actual key value is sent. so, the first call to
        readkey will get #0, and the second will get the key we're looking
        for. }
      if getkey = #0 then
        begin
        getkey := readkey;
        case getkey of
          { up }
          #72 : if choice > 1 then
                begin
                textattr := loclr;
                gotoxy(xpos, ypos);
                write(text);
                dec(choice);
                end;
          { down }
          #80 : if choice < numitems then
                begin
                textattr := loclr;
                gotoxy(xpos, ypos);
                write(text);
                inc(choice);
                end;
          end;
        end;
      { if they hit ESC, set choice to 0 and exit }
      if getkey = #27 then choice := 0;
      { if they press a key, see if the key the pressed is a hotkey }
      getkey := upcase(getkey);
      if getkey in ['A'..'Z'] then
        begin
        for cnt := 1 to numitems do
          if getkey = menucast(menu)[cnt].key then
            begin
            choice := cnt;
            getkey := #13;
            end;
        end;
      end;

  until (getkey = #13) or (getkey = #27);
  domenu := choice;
end;

end.

{ ----------   DEMO PROGRAM ------------ }
{ 8/25/96 NMENU Example by Brandon Sneed }
program nmenuexample;

uses crt, nmenu;

const
	DummyMenu : Array [1..5] of MenuRec =
		((Text : ' Test 1 '; XPos : 1; YPos : 1; Key : '1'),
		 (Text : ' Test 2 '; XPos : 1; YPos : 2; Key : '2'),
		 (Text : ' Test 3 '; XPos : 1; YPos : 3; Key : '3'),
		 (Text : ' Test 4 '; XPos : 1; YPos : 4; Key : '4'),
		 (Text : ' Test 5 '; XPos : 1; YPos : 5; Key : '5'));
	{ the menu array can have as many options as you need.  just add them.
		be sure to change the 'numitems' value being passed to domenu }
var
	userpick : byte;

begin
	userpick := domenu( dummymenu,       { our menu const }
											5,               { total number of items in array }
											1,               { which item is first highlighted }
											$1F,             { highlight color (white! on blue) }
											$07);            { unhighlight color (white) }
	gotoxy(1, 7);
	writeln('User picked: '+DummyMenu[userpick].Text);
end.

