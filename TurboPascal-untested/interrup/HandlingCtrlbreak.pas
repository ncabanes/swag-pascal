(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0011.PAS
  Description: Handling Ctrl-Break
  Author: BRYCE OSTENSON
  Date: 08-27-93  20:39
*)

{
BRYCE OSTENSON

> I am looking for a way to diable the use of the control break and control
> alt delete features.

BTW: Simple concept...  Here's how it works - When the program begins,
SavedInt23 is assigned to the original C-Break interrupt...  When the
SetCtrlBreak procedure is called with Status equaling false, the C-Break
interrupt is assigned to a CBreakHandler which has no substance...  Thus
when C-Break is called it does nothing.  When SetCtrlBreak is called
with Status equaling false, Interrupt 23h is assigned to the default
C-Break handler.
}

UNIT TBUtil;

INTERFACE

Uses
  Dos;

Var
  SavedInt23 : Pointer;
  CBreak     : Boolean;

Procedure SetCtrlBreak(Status : Boolean);
Function  GetCtrlBreak : Boolean;

IMPLEMENTATION

Procedure CBreakHandler; INTERRUPT;
Begin
End;

Procedure SetCtrlBreak(Status : Boolean);
Begin
  If Status then
    SetIntVec($23, SavedInt23);
  Else
    SetIntVec($23, @CBreakHandler);
  CBreak := Status;
End;

Function GetCtrlBreak : Boolean;
Begin
  GetCtrlBreak := CBreak;
End;

Begin
  CBreak := True;
  GetIntVec($23, SavedInt23); { Save the Ctrl-Break handler. }
End.


