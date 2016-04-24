(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0118.PAS
  Description: Convert the PAUSE key to a 'P' char
  Author: PINO NAVATO
  Date: 01-02-98  07:35
*)

 {***************************************************************************}
 {                                                                           }
 {   Pause2P  -  Convert the PAUSE key to a 'P' char.  Freeware.             }
 {               Simply add this unit to an USES clause of your program      }
 {               and forget it.  Its way of operating is fully automatic!    }
 {               A minimal demo is at the end of this unit.                  }
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


Unit Pause2P;

interface

  { This unit doesn't export anything! }


implementation
uses Dos;

const PauseChar = 'P';    { You can use any char you like (not a string!) }

var OldInt9     : Procedure;
    KbdFlags    : byte absolute $0040:$0018;
    OldExitProc : pointer;


procedure ExitHandler; far;
begin
   ExitProc := OldExitProc;
   SetIntVec($9, Addr(OldInt9))   { Restore the old vector }
end;


procedure NewInt9; interrupt;
begin
   inline ($9C);   { PUSHF -- Push flags }
   OldInt9;        { Call the old ISR }
   if KbdFlags and 8 = 8 then            { IF the pause flag is set THEN... }
      begin
         KbdFlags := KbdFlags and 247;   { ...clear it and... }
         asm                             { ...put a 'P' in the kdb buffer }
            XOR CH,CH           { You can remove         }
            MOV CL,PauseChar    { these asm instructions }
            MOV AH,5            { if you simply want to  }
            INT 16h             { disable the PAUSE key  }
         end
      end
end;


begin  { Initialization }
   GetIntVec($9, @OldInt9);
   SetIntVec($9, Addr(NewInt9));   { Insert NewInt9 into the keyboard chain }
   OldExitProc := ExitProc;
   ExitProc := @ExitHandler
end.

{ ========================================================================== }


Program Pause2P_Test;

uses Pause2P;

begin
   readln    { Try to press the PAUSE key and look at the result! }
end.

{ It couldn't be easier! :) }

