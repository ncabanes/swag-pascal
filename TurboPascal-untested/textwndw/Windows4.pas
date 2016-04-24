(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0007.PAS
  Description: WINDOWS4.PAS
  Author: SALIM SAMAHA
  Date: 05-28-93  14:08
*)

{ SALIM SAMAHA }

Unit Windows;

Interface

Uses
  Crt;

Const
  Max = 3;

Type
  ScreenImage = Array [0..1999] of Word;
  FrameRec    = Record
    Upperleft    : Word;
    LowerRight   : Word;
    ScreenMemory : ScreenImage;
  end;

Var
  SnapShot   : ^ScreenImage;
  FrameStore : Array [1..10] of ^FrameRec;
  WindowNum  : Byte;

Procedure OpenWindow(UpLeftX, UpLeftY, LoRightX, LoRightY : Byte);
Procedure CloseWindow;

Implementation

Procedure OpenWindow(UpLeftX, UpLeftY, LoRightX, LoRightY : Byte);
begin
  SnapShot := Ptr( $B800, $0000);
  Inc(WindowNum);
  New(FrameStore[WindowNum]);
  With Framestore[WindowNum]^ do
  begin
    ScreenMemory := SnapShot^;
    UpperLeft    := WindMin;
    LowerRight   := WindMax;
  end;
  Window(UpLeftX, UpLeftY, LoRightX, LoRightY);
end;

Procedure CloseWindow;
begin
  With Framestore[WindowNum]^ do
  begin
    Snapshot^ := ScreenMemory;
    Window ((Lo(UpperLeft) + 1), (Hi(UpperLeft) + 1),
            (Lo(LowerRight) + 1), (Hi(LowerRight) + 1));
  end;
  Dispose(Framestore[WindowNum]);
  Dec(WindowNum);
end;


