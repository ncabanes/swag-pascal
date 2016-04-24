(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0030.PAS
  Description: Keyboard Buffer Routines
  Author: LAVI TIDHAR
  Date: 07-16-93  06:14
*)

Unit TPbuffer;

(* TP-Buffer unit version 1.1 /Update              *)
(* Using the keyboard's buffer in Turbo Pascal     *)
(* This unit is released to the public domain      *)
(* by Lavi Tidhar on 5-10-1992                     *)

(* This unit adds three special functions not      *)
(* incuded in the Turbo Pascal regular package     *)

(* You may alter this source code, move the        *)
(* procedures to your own programs. Please do      *)
(* NOT change these lines of documentation         *)

(* This source might teach you about how to        *)
(* use interrupts in pascal, and the keyboard's    *)
(* buffer. from the other hand, it might not :-)   *)

(* Used: INT 16, functions 0 and 1                 *)
(*       INT 21, function 0Ch                      *)

(* INT 16 - KEYBOARD - READ CHAR FROM BUFFER, WAIT IF EMPTY
           AH = 00h
           Return: AH = scan code
                   AL = character         *)

(* INT 16 - KEYBOARD - CHECK BUFFER, DO NOT CLEAR
           AH = 01h
           Return: ZF = 0 character in buffer
                       AH = scan code
                       AL = character
                       ZF = 1 no character in buffer *)

(* INT 21 - DOS - CLEAR KEYBOARD BUFFER
        AH = 0Ch
        AL must be 1, 6, 7, 8, or 0Ah.
        Notes: Flushes all typeahead input, then executes function specified by AL
        (effectively moving it to AH and repeating the INT 21 call).
        If AL contains a value not in the list above, the keyboard buffer is
        flushed and no other action is taken. *)

(* For more details/help etc, you can contact me on: *)

(* Mail: Lavi Tidhar
         46 Bantam Dr.
         Blairgowrie
         2194
         South Africa 
*)

(* Phone:
          International: +27-11-787-8093
          South Africa:  (011)-787-8093
*)

(* Netmail: The Catacomb BBS 5:7101/45 (fidonet)
            The Catacomb BBS 80:80/100 (pipemail)
*)

Interface

Uses Dos;

Function GetScanCode:Byte; (* Get SCAN CODE from buffer, wait if empty *)
Function GetKey:Char;      (* Get Char from buffer, do NOT wait *)
Procedure FlushKB;

Implementation

Function GetKey:Char;
 Var Regs:Registers;
 Begin
  Regs.AH:=1;                (* Int 16 function 1 *)
  Intr ($16,Regs);           (* Read a charecter from the keyboard buffer *)
  GetKey:=Chr (Regs.AL);     (* do not wait. If no char was found, CHR(0) *)
 End;                        (* (nul) is returned *)

Function GetScanCode:Byte;   (* Int 16 function 0 *)
 Var Regs:Registers;         (* The same as CRT's Readkey, but gives you *)
  Begin                      (* the scan code. Esp usefull when you want to *)
   Regs.AH:=0;               (* use special keys as the arrows, there will *)
   Intr ($16,Regs);          (* be a conflict when using ReadKey *)
   GetScanCode:=Regs.AH;
  End;

Procedure FlushKB;           (* INT 21 function 0C *)
 Var Regs:Registers;         (* Flushes (erase) the keyboard buffer *)
  Begin                      (* ONLY. No other function is executed *)
   Regs.AH:=$0C;
   Regs.AL:=2;
   Intr ($21,Regs);
  End;

End.

