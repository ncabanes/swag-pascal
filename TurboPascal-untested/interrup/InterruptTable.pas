(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0019.PAS
  Description: Interrupt Table
  Author: KEVIN MESS
  Date: 05-26-94  11:03
*)

{$R-,S+,I+,D+,T+,F-,V+,B-,N-,L+ }
{$M 4096,0,0 }

program interrupt_table (input,output);

{

  A Program that displays all interrupt vectors.

  Version 1.00 - 03/10/88 - First release

  Kevin Mess
  PO Box 35
  Boulder City, NV   89005
  Compuserve 71121,3360

}

uses
  crt,dos,cursors; { Cursors unit as written by Scott Bussinger }

const
  bell        = ^G;

type
  string4     = string [4];
  keyset      = (ESC,PGUP,PGDN,nothing);
  pointer_rec = record
                  case integer of
                    0 : (address         : pointer);
                    1 : (offset, segment : word)
                end; { record }
  screentype  = record
                   position : array [1..4000] of byte;
                   x,y      : byte;
                end; { record }
var
  vector      : array [$00..$FF] of pointer_rec absolute $0000:0000;
  colorscreen : screentype absolute $B800:0000;
  monoscreen  : screentype absolute $B000:0000;
  savedscreen : screentype;
  intnumber   : byte;
  finished    : Boolean;

{*************************************}

function hex (decimal : word) : string4;

   const
      hexdigit  : array [$0..$F] of char = '0123456789ABCDEF';

   var
      temp    : string4;

   begin
      temp := '';
      temp := hexdigit [ hi (decimal) div 16 ] +
              hexdigit [ hi (decimal) mod 16 ] +
              hexdigit [ lo (decimal) div 16 ] +
              hexdigit [ lo (decimal) mod 16 ] ;
      hex  := temp
   end;

{*************************************}

procedure frame (x1,y1,x2,y2 : byte);

   const
      upperleft  = #201;
      lowerleft  = #200;
      upperright = #187;
      lowerright = #188;
      horizontal = #205;
      vertical   = #186;

   var
      i          : byte;

   begin
      gotoxy (x1-1,y1-1);
      write  (upperleft);
      gotoxy (x2+1,y1-1);
      write  (upperright);
      gotoxy (x1-1,y2+1);
      write  (lowerleft);
      gotoxy (x2+1,y2+1);
      write  (lowerright);
      for i := x1 to x2 do
         begin
            gotoxy (i,y1-1);
            write  (horizontal);
            gotoxy (i,y2+1);
            write  (horizontal)
         end;
      for i := y1 to y2 do
         begin
            gotoxy (x1-1,i);
            write  (vertical);
            gotoxy (x2+1,i);
            write  (vertical)
         end;
   end; { frame }


{*************************************}

procedure display_screen (first_intnumber : byte);

  var
     x,y,
     last_intnumber,
     intnumber      : byte;

  begin { display_screen }
     last_intnumber := first_intnumber + $3F;
     x := 5;
     y := 1;
     for intnumber := first_intnumber to last_intnumber do
       with vector [intnumber] do
         begin
           gotoxy (x,y);
           write (copy(hex(intnumber),3,2),hex(segment):6,':',hex(offset));
           inc (y);
           if ((intnumber + 1) mod $10) = 0 then
             if intnumber <> last_intnumber then
                begin
                  inc (x,19);
                  y := 1
                end
         end; { with }
  end; { display_screen }


{*************************************}


function endkey : keyset;

   var
     anykey : char;
     exit   : keyset;

   begin
     repeat
        exit := nothing;
        anykey := readkey;
        if anykey = #0 then
           anykey := readkey;
        case anykey of
           #27 : exit := ESC;
           #73 : exit := PGUP;
           #81 : exit := PGDN;
           else  write (bell);
        end; { case }
     until exit in [ESC,PGUP,PGDN];
     endkey := exit
   end;

{*************************************}

procedure int_table (intnumber : byte);

   begin { int_table }
      if monodisplay then
         savedscreen := monoscreen
      else
         begin
            savedscreen := colorscreen;
            textcolor (white);
            textbackground (blue)
         end;
      savedscreen.x := wherex;
      savedscreen.y := wherey;
      makecursor (nocursor);
      frame  (2,2,79,19);
      window (2,2,79,19);
      clrscr;
      gotoxy (12,18);
      write ('PgUp - Previous Page,  PgDn - Next Page,  Esc to Exit');
      finished  := FALSE;
      repeat
         display_screen (intnumber);
         case endkey of
            PGUP : if intnumber >= $40 then
                      dec (intnumber,$40)
                   else
                      intnumber := $C0;
            PGDN : if intnumber <= $80 then
                      inc (intnumber,$40)
                   else
                      intnumber := $00;
            ESC  : finished := TRUE
         end { case }
      until finished;
      window (1,1,80,25);
      if monodisplay then
         monoscreen := savedscreen
      else
         colorscreen  := savedscreen;
      gotoxy (savedscreen.x,savedscreen.y);
      makecursor (restorecursor)
   end;  { int_table }

{*************************************}


begin { main }
   intnumber := $00;
   int_table (intnumber)
end. { main }

