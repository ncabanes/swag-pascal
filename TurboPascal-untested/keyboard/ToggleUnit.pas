(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0121.PAS
  Description: TOGGLE Unit
  Author: ZAK SMITH
  Date: 08-30-97  10:08
*)


Unit Toggle;
{$O+}

interface

 type
  BytePtr = ^Byte;

 const
  _ScrollLock = $10;
  _NumLock    = $20;
  _CapsLock   = $40;
  _InsertKey  = $80;

 procedure KeyboardToggle ( Mask : byte );

 implementation

 (* To use this procedure, just pass along the constants that you want
    toggled.  For example.  To toggle the Scroll Lock and Caps Lock you
    would call:
        KeyBoardToggle(_ScrollLock + _CapsLock);
 *)

 procedure KeyboardToggle ( Mask : byte );
 var
  KeyBoardStatus : BytePtr;
 begin
  KeyBoardStatus := Ptr($0000,$0417);
  KeyBoardStatus^ := KeyBoardStatus^ xor Mask;
 end;

 end.

