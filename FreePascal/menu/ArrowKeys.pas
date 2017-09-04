(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0006.PAS
  Description: Re: Arrow Keys
  Author: PETER LOUWEN
  Date: 11-25-95  09:26
*)

(*
 SB> i have a problem. I want it to show Three Choices Like This;


 SB> Choice #1
 SB> Choice #2
 SB> Choice #3

 SB>
 SB> I want Choice #1 to be in White, and the others to be In Darkgray, if
 SB> they  press down, it will make only #2 White, and the others Darkgray,
 SB> if they press Down again it will make only Choice #3 White, and it will
 SB> Tell Them Which  Choice they choosed on each one if they press enter.
 SB> So if they press Enter  while Choice #1 Was Highlighted, it would say
 SB> 'You Chose Choice Number 1'. and and it will Repeat when you Press the
 SB> arrow keys, untill they press Enter on  anyone of the Choice Choices...

The following should get you started:
*)

PROGRAM Seans_Menu;

USES Crt;


{FUNCTION readkeyword: word; ASSEMBLER;}
{ -- Assumes you have an extended (i.e. non-XT) keyboard.
  -- Returns both scancode and character with one call. }
{ASM mov ah, $10
    int $16
END;}

CONST 
      { -- Value returned by ReadKeyword for the down arrow key. }
      {Down  = $5000;
      Up    = $4800;
      Enter = $1C0D;
      Esc   = $011B;}
      Down  = #$50;
      Up    = #$48;
      Enter = #$0D;
      Esc   = #$1B;

PROCEDURE menu(CONST nbr_of_choices: byte;
               VAR   selected      : byte;
               VAR   accept        : boolean);
{ -- Puts up a menu with NBR_OF_CHOICES choices.
  -- The user can use the up and down arrow keys to select a particular
  -- menu item. Enter then selects, and Esc exits immediately.
  -- On exit, if the user pressed Enter, ACCEPT will be TRUE, and SELECTED
  -- will hold the number of the selected item. If the user cancelled the
  -- selection (Esc pressed), ACCEPT will be FALSE, and SELECTED then is
  -- undefined. }
CONST StartingCol  = 5;  { -- These two determine the top left corner of }
      StartingRow  = 3;  { -- your menu. }
      NormalColour = DarkGray;
      HiliteColour = White;
      Str          = 'Choice #';
VAR j, TA: byte;

  PROCEDURE beep;
  BEGIN sound(700); delay(50); nosound END;

  PROCEDURE DrawCurrentlySelected;
  BEGIN gotoxy(StartingCol, StartingRow + selected - 1);
        write(Str, selected:1)
  END;

  PROCEDURE DoDown;
  BEGIN DrawCurrentlySelected;
        { -- Redraw current item in the normal, i.e. unselected, colour. }

        IF selected = nbr_of_choices THEN selected:=1 ELSE inc(selected);
        TextAttr:=HiliteColour;
        DrawCurrentlySelected;
        { -- Move cursor to newly selected item and redraw in the highlight,
          -- i.e. selected, colour. }
        TextAttr:=NormalColour
  END;

  PROCEDURE DoUp;
  BEGIN DrawCurrentlySelected;
        IF selected = 1 THEN selected:=nbr_of_choices ELSE dec(selected);
        TextAttr:=HiliteColour;
        DrawCurrentlySelected;
        TextAttr:=NormalColour
  END;

  PROCEDURE Process;
  { -- Keep reading keys until user decides s/he has had enough. }
  VAR finished: boolean;
      key     : char;
  BEGIN finished:=FALSE;
        REPEAT 
               key:=readkey;
               if key = #0 THEN key:=readkey;
               CASE key
               OF Down : DoDown;
                  Up   : DoUp;
                  Enter: BEGIN finished:=TRUE; accept:=TRUE  END;
                  Esc  : BEGIN finished:=TRUE; accept:=FALSE END;
               ELSE beep
               END
        UNTIL finished
  END;
BEGIN (* menu *)
      gotoxy(StartingCol, StartingRow);

      TA:=TextAttr;
      { -- If you start messing with the screen colours, it is good
        -- manners to mark the current ones, so you can restore them
        -- when you're through. }

      { -- Now draw all items in the unselected colour: }
      TextAttr:=NormalColour;
      FOR j:=1 TO nbr_of_choices
      DO BEGIN gotoxy(StartingCol, StartingRow + j - 1);
               write(Str, j:1)
         END;

      { -- Do first item in selected colour: }
      TextAttr:=HiliteColour;
      selected:=1; DrawCurrentlySelected;
      TextAttr:=NormalColour;

      accept:=FALSE;
      Process;

      TextAttr:=TA
END;

PROCEDURE ColourClrscr(CONST Colour_U_Like: byte);
{ -- Clears the screen, colouring all positions.
  -- Not essential, just nice ... }
VAR TA: byte;
BEGIN TA:=TextAttr; TextAttr:=Colour_U_Like;
      clrscr;
      TextAttr:=TA
END;

{ -- Main: }

VAR choice: byte;
    ok    : boolean;

BEGIN ColourClrscr(Blue*16);
      menu(5, choice, ok);
      gotoxy(1, 20);
      IF ok
      THEN writeln('You chose nr. ', choice:1)
      ELSE writeln('You aborted ...')
END.

