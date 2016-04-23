Unit Screens;
Interface

Uses Dos, Crt;

{
 Copyright Material by Mark Bloss exists in this file.

 Copyright 1995, all rights reserved.  Submitted to the
 public domain for use with TP or BP 7.0+
 No guarantees.  Use at your own risk, etc etc.

 Uses: This unit will save as many screens as you can fit
 into your heap-space.  I normally setup a constant section
 like this in my program
  const
     DOSscreen = 1;
     MainMenu  = 2;
     HelpScreen= 3;
  or similar, so I may use the names as identifiers rather than
  trying to remember all the numbers.

  Use in the program is simple.  At the beginning of my program
  I can save the screen at DOS (etc) by saving my screen immediately
  like this

  "savescreen(screen, DOSscreen);"

  and as part of my exit proc...
  "restorescreen(screen, DOSscreen);"
  and
  "losescreens(screen);"

  This will not only save the screen, but also the cursor position
  and restore the cursor to its original location when the screen
  was initially saved.

  GetCurWindow and GetCurColors are included and may be used
  independently.

  This unit is NOT a screen-saver, but may be used WITH a screen-
  saver if desired.

  To use this unit, compile and include "SCREENS" in your program's
  "Uses" statement.

}

const
      screenissaved :  boolean  =  false;
      newscreen     :  boolean  =  true;

type
      ScreenBuff= array [0..3999] of byte;
      ScreenPtr = ^ScreenRec ;
      ScreenRec = Record
                   Id          :  Byte;
                   HoldScreen  :  ScreenBuff;
                   xp,yp       :  Byte;
                   Next        :  ScreenPtr;
                  End;

 var
       CGA_buffer           :  ScreenBuff  ABSOLUTE $B800 : 0 ;
       Mono_buffer          :  ScreenBuff  ABSOLUTE $B000 : 0 ;
       identifier           :  byte;
       Screen               :  ScreenPtr;

function Monochrome : boolean;
    { if used on a monochrome monitor will return true }

Procedure LoseScreens ( var root : screenptr );
    { disposes of saved screens from heap }

Procedure SaveScreen (var  root : screenptr ; identifier : byte );
    { save a screen to heapspace, identified with a byte }

Procedure RestoreScreen ( root : screenptr ; identifier : byte );
    { restores a saved screen to the crt }

Procedure GetCurWindow(var x1, y1, x2, y2 : integer);
    { Use to save the window-size }

Procedure GetCurColors(var v1, v2 : integer);
    { Use to save colors/attributes of the screen }

{=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-}
Implementation
{=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-}
Function MonoChrome: boolean;
var
  Regs : Registers;
Begin
 INTR(17,Regs);
 Monochrome := ( (Regs.AX and $0030) = $30 );
End;

Procedure LoseScreens( var root : screenptr );
var  holder : screenptr;

begin
   if root <> nil then
    repeat
     holder := root^.next;
     dispose(root);
     root := holder;
    until root = nil;
end;

Procedure SaveScreen( var root : screenptr ; identifier : byte);
 var workrec  :  screenrec;
     current,
     holder   :  screenptr;
     replaced :  boolean;

Begin
   replaced := false;
   if Monochrome then      { savescreen }
     move ( mono_buffer, workrec.holdscreen, 4000 ) else
     move ( cga_buffer , workrec.holdscreen, 4000 );

   workrec.id := identifier ;         { a byte "label" }
   workrec.xp := wherex;              { current xloc   }
   workrec.yp := wherey;              { current yloc   }

  if root = nil then
  begin
   new(root);
   workrec.next := nil;
   root^ := workrec;
  end else
  begin
   current := root;
   holder  := root;
   repeat
    if current^.id = identifier then { replace screen already in list }
     begin
       move ( workrec.holdscreen, current^.holdscreen, 4000 );
       replaced := true;
     end;
    current := current^.next;
   until (current=nil) or replaced ;

   if not replaced then
    begin
      new(root);
      workrec.next := holder;      { adds record to "start" of list }
      root^  := workrec;
    end;
  end
End;

Procedure RestoreScreen ( root : screenptr ; identifier : byte );
var current : screenptr ;

Begin
  if root = nil then exit;
  current := root;
  while current <> nil do
   begin
     if current^.id = identifier then
     begin
      if monochrome then
        move ( current^.holdscreen, mono_buffer , 4000) else
        move ( current^.holdscreen, cga_buffer , 4000);
        gotoxy( current^.xp, current^.yp );       { put cursor back }
     end;
     current := current^.next;
   end;
  newscreen := true;
End;

Procedure GetCurWindow( var x1, y1, x2, y2 : integer );
Begin
  x1 := lo(WindMin)+1;
  y1 := hi(WindMin)+1;
  x2 := lo(WindMax)+1;
  y2 := hi(WindMax)+1;
End;

Procedure GetCurColors(var v1, v2 : integer );
Begin
 v1 := lo(textattr);
 v2 := hi(textattr);
End;

Begin
Screen := Nil;
End.
