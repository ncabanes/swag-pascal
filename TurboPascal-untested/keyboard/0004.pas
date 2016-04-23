{
Here is my source For the keyboard handler.
}

{$X+}

Unit KbIO;

(*---------------------------*) Interface (*----------------------------*)

Uses Dos;

Var
   KbScancode  : Byte;  { internal Variable, can be used by host Program }
   OldInt9Vect : Pointer;  { For storing the old interrupt vector }

Procedure RestoreOldInt9;
Procedure NewInt9; Interrupt;

(*------------------------*) Implementation (*--------------------------*)

Procedure RestoreOldInt9;  { Restores control to the old interrupt handler }
begin
  SetIntVec($09, OldInt9Vect);
end;

{$F+}
Procedure NewInt9; (* Interrupt; *)
Var
  scancode : Byte;

  Procedure ResetKBD;
  Var
    b : Byte;
  begin
       b := Port[$61];
       Port[$61] := b or $80;
       Port[$61] := b;
       Port[$20] := $20;
  end;

begin
  scancode   := Port[$60];
  KbScancode := scancode;
  (* at this point, you could add Up, Down, Left & Right Vars
     eg. if (KbScancode = 72) then Up := True;
         if (KbScancode = 72 + 128) then Up := False;
         .
         .
         .
         Don't Forget to initialize Up, Down, etc. if you use them! *)
  ResetKBD;
end;
{$F-}

begin
  GetIntVec($09, OldInt9Vect);
  SetIntVec($09, @NewInt9);
  KbScancode := 0;
  (*
    At this point, the Unit could install a custom Exit Procedure
    that automatically restores the old keyboard handler when the
    host Program finishes.
  *)
end.

{
Just include this Unit in your Uses clause, and, at any time during your
Program, you can check 'KbScancode' to see which key was currently pressed or
released.  Pressed keys have values between 0..127, and released keys have a
value between 128..255.  ESC = scancode #1, so here's a sample.
}
Function Check4Quit : Boolean;
Var
  kbcode  : Byte;
  tmpBool : Boolean;
begin
  tmpBool := False;
  kbcode := KbScancode;
  if (kbcode = 1) then
  begin

     Repeat
       kbcode := KbScancode
     Until (kbcode <> 1);
     (* the above line Repeats Until a different key is pressed
        or released *)

     if (kbcode = 129) then
       tmpBool := True;
     (* if they released ESC directly after pressing it, without
        pressing or releasing any other keys, return a True value *)

  end;
  Check4Quit := tmpBool;
end;

{
So, basically, it's a good idea to save KbScancode in a temporary Variable
beFore doing any checks on it, as it may change if you do this:

if (KbScancode = 1) then begin
   Delay(1);
   WriteLn('You pressed key #', KbScancode);
end;

In that short Delay, they may have released the key or pressed a new one,so the
value would have changed, and the Program might screw up.

Something to add:  Boolean Variables For Up, Down, Left, and Right, For use in
games and such.  See the section in Procedure NewInt9.


Hey, Drew.  I Forgot one thing in my message about the custom KB handler.
You'll probably receive this message at the same time as the Unit I sent.
Here is the important message:

When using the KbIO Unit, at the very end of your Program, include the line
that restores the old int9 vector.  It is a Procedure called 'RestoreOldInt9'.
It may not be Absolutely essential to include this line, but if you don't
restore the old keyboard handler, you might not be able to Type anything when
the Program Exits!  (not so good, huh?)  What to do: you can install a custom
exit Procedure that restores the old int9 vector.  if you don't know how to do
this, quote these lines, or Write to me about "custom Exit Procedures to
restore the old int9 vector," or something like that.  Bye For now.
}
