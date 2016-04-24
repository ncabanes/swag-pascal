(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0008.PAS
  Description: SAVERES.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

Uses Dos,Crt;
{ saves and restores and area of screen }
Const
   Max = 3;

Type
   ScreenImage = Array[0..1999] of word;
   FrameRec    = Record
                    Upperleft    : Word;
                    LowerRight   : Word;
                    ScreenMemory : ScreenImage;
                 End;

VAR
   SnapShot     : ^ScreenImage;
   FrameStore   : Array [1..10] of ^FrameRec;
   WindowNum    : Byte;

Procedure OpenWindow(UpLeftX,UpLeftY,LoRightX,LoRightY : Byte);
Begin
   SnapShot := Ptr( $B800, $0000);
   Inc(WindowNum);
   New(FrameStore[WindowNum]);
   WITH Framestore[WindowNum]^ do
   Begin
      ScreenMemory := SnapShot^;
      UpperLeft    := WindMin;
      LowerRight   := WindMax;
   end;
   Window(UpLeftX,UpLeftY,LoRightX,LoRightY);
end;

Procedure CloseWindow;
Begin
   With Framestore[WindowNum]^ do
   Begin
      Snapshot^ := ScreenMemory;
      Window ( (Lo(UpperLeft)+1), (Hi(UpperLeft)+1),
             (Lo(LowerRight)+1), (Hi(LowerRight)+1) );
   end;
   Dispose( Framestore[WindowNum]);
   Dec(WindowNum);
End;

Begin
OpenWIndow(3,3,45,15);
ClrScr;
Readkey;
CloseWindow;
End.

