(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0025.PAS
  Description: Simple Disable of CTRL-ALT=DEL
  Author: PINO NAVATO
  Date: 01-02-98  07:35
*)

 {***************************************************************************}
 {                                                                           }
 {   NoBoot  -  The simplest way of disabling CTRL-ALT-DEL.  Freeware.       }
 {              Simply add this unit to an USES clause of your program       }
 {              and forget it.  Its way of operating is fully automatic!     }
 {              A minimal demo is at the end of this unit.                   }
 {                                                                           }
 {   Author: Pino Navato                                                     }
 {                                                                           }
 {   E-Mail: pnavato@poboxes.com                                             }
 {           pnavato@geocities.com                                           }
 {           Pino Navato, 2:335/225.18  (The Bits BBS, Fidonet)              }
 {                                                                           }
 {   WWW:    www.poboxes.com/pnavato                                         }
 {           (currently forwards to  www.geocities.com/SiliconValley/4421)   }
 {                                                                           }
 {   Advertisement:                                                          }
 {     Do you need new CHR fonts for the BGI?  Visit my home page!           }
 {                                                                           }
 {***************************************************************************}


Unit NoBoot;

interface

  { This unit doesn't export anything! }


implementation
uses Dos;

var OldInt9     : Procedure;
    OldExitProc : pointer;


procedure ExitHandler; far;
begin
   ExitProc := OldExitProc;
   SetIntVec($9,Addr(OldInt9))   { Restore the old vector }
end;


procedure NewInt9; interrupt;
begin
   if (Port[$60] = 83) and ( (mem[$40:$17] and $0C) = $0C ) then
      port[$20] := $20      { Signal End Of Interrupt }
   else
      begin
         inline ($9C);   { PUSHF - Push flags }
         OldInt9         { Call the old INT 9 }
      end
end;


begin  { Initialization }
   GetIntVec($9, @OldInt9);
   SetIntVec($9, Addr(NewInt9));   { Insert NewInt9 into the keyboard chain }
   OldExitProc := ExitProc;
   ExitProc := @ExitHandler
end.

{ ========================================================================== }


Program NoBoot_Test;

uses NoBoot;

begin
   readln     { Ctrl-Alt-Del has no effect now }
end.

{ It couldn't be easier! }

