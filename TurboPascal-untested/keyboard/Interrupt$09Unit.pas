(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0101.PAS
  Description: Interrupt $09 Unit
  Author: ALLYN CROSS
  Date: 09-04-95  10:53
*)

{
Hi Everyone,

I was having some trouble getting an interrupt $09 routine to work and
Lou Douchez put some code on here that helped me out.  I am now posting
the code so that anyone who needs it can use it.  Thanks Lou!
}

{$F+,X+,G+,S-}
{Make it far, extended syntax enabled, use 286 instructions, stack
checking turned off.  I use this with graphics that is why I have the
compiler codes this way}
Unit Mkeys; {by Allyn Cross}
interface
uses Dos;
{Key Definitions}
Const
     ESCKey = 1; Key1 = 2; key2 = 3; Key3 = 4; Key4 = 5; Key5 = 6;
     Key6 = 7; Key7 = 8; Key8 = 9; Key9 = 10; Key0 = 11; MinusKey = 12;
     EqualKey = 13; BACKKey = 14; TABKey = 15; QKey = 16; WKey = 17;
     EKey = 18; RKey = 19; TKey = 20; YKey = 21; UKey = 22; IKey = 23;
     OKey = 24; PKey = 25; EnterKey = 28; ControlKey = 29; AKey = 30;
     SKey = 31; DKey = 32; FKey = 33; GKey = 34; HKey = 35; JKey = 36;
     KKey = 37; LKey = 38; LEFTSHIFT = 42; ZKey = 44; XKey = 45; CKey =
     46; VKey = 47; BKey = 48; NKey = 49; MKey = 50; LessThanKey = 51;
     GreaterThanKey = 52; QuestionKey = 53; RIGHTSHIFT = 54; StarKey =
     55; ALTKEY = 56; SPACEKey = 57; CAPSLOCKKey = 58; F1 = 59; F2 = 60;
     F3 = 61; F4 = 62; F5 = 63; F6 = 64; F7 = 65; F8 = 66; F9 = 67; F10
     = 68; NUMKey = 69; SCROLLKey = 70; HOMEKey = 71; UpKey = 72;
     PGUPKey = 73; MinusKeypad = 74; LeftKey = 75; FiveKeyPad = 76;
     RightKey = 77; PlusKey = 78; EndKey = 79; DownKey = 80; PGDNKey =
     81; INSERTKey = 82; DelKey = 83; F11 = 87; F12 = 88;
Var OldInt09:Procedure; {the pointer to the old interrupt}
    OldMKeysExit : pointer; {pointer to old exit code}
    keys:array[1..127] of boolean; {an array of the keys}
implementation
Procedure ResetKeys;
var j : byte;
begin
for j := 1 to 127 do
     keys[j] := false;
end;
Procedure NewInt09; Interrupt;
Var
   keycode:Byte;
Begin
    Asm Pushf; End; {Lou Douchez gave this line and made it all work}
    keycode:=Port[$60];
    If keycode >= 128 Then keys[keycode-128] := false
    Else
     keys[keycode] := true;
    OldInt09;
    MEMW[$0040:$001A] := MEMW[$0040:$001C];
    {Set keyboard buffer head to tail}
    asm Popf; End; {this helps with difficult keyboards}
end;
Procedure RestoreKeys;
begin
     setintvec($09,@OldInt09);
end;
Procedure SetKeys;
begin
    getintvec($09, @OldInt09);
    setintvec($09, @NewInt09);
end;
Procedure MKeysExit;
begin
     ExitProc := OldMkeysExit;
     restorekeys;
end;
begin
     oldMkeysExit := exitproc;
     exitproc := @MKeysexit;
     resetkeys;
     setkeys;
end.
 
Sorry about the squeeze I wanted to make it all fit in one message.

You simply add this unit to your uses clause.  Everything is loaded and
unloaded automatically. All you need do is if you want to check to see
if the RightKey is pressed (right arrow) then you do this.
if keys[rightkey] then do_something;
BTW I only have 79 of the keycodes defined. I don't use the others so I
don't really know what they are.

