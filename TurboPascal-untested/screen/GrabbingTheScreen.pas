(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0108.PAS
  Description: Grabbing the Screen
  Author: MORITZ BARTL
  Date: 08-30-97  10:09
*)


-------------------------------------------------------------------------------
Message From 
-------------------------------------------------------------------------------
Group #2 - Fidonet
Conference #9 - Pascal
Message Date: 08-22-97 19:25:00

To:      Nathan Malyon
From:    Moritz Bartl
Subject: GrabScreen
-------------------------------------------------------------------------------

Nathan has told All someting about "GrabScreen":

NM> Does anyone know a way to "Grab" the screen then restore it later
NM> (posibily from a file)

================ CUT ================
uses crt; { only needed for clrscr }
type Screen= array[1..4000] of byte;
var
  ColorScreen : Screen Absolute $B800:$0000;
  SavedScreen : Screen;
begin
 savedscreen := colorscreen;
 clrscr;writeln('Press key to restore');readkey;
 colorscreen := savedscreen;
end.
================ CUT ================

 /\/\/\/< Moritz Bartl >\/\/\/\/\

--- Lamer Mail v1.6 R
 * Origin: - just me - (2:2480/56.17)

