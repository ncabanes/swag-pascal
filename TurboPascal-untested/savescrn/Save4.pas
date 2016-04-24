(*
  Category: SWAG Title: SCREEN SAVING ROUTINES
  Original name: 0004.PAS
  Description: SAVE4.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

{
I couldn't find your original message, but you could use this code fragment to
save and restore a Text-mode screen.
}

(* global Vars *)
Var
   vidSeg : Word;
   oldScr : Array[0..3999] of Byte;

Function GetVidSeg : Word;
Var
   mode : Byte;
   seg  : Word;
begin
     seg := 0;
     mode := Mem[0 : $449];
     if (mode = 7) then seg := $B000;
     if (mode <= 3) then seg := $B800;
     if (mode in [4..6]) or (mode > 7) then begin
        (* the Program is not in the correct Text mode *)
        Halt(1);  (* return errorlevel of 1 *)
     end;
     GetVidSeg := seg;
end;

(* main Program *)
begin
     vidSeg := GetVidSeg;
     Move(Mem[vidSeg : 0], oldScr[0], SizeOf(oldScr));
     (* the above line copies 4000 Bytes starting at $B000 : 0 For mono.
        or $B800 For colour into the Array 'oldScr' *)
     ClrScr;
     WriteLn('Press ENTER to restore the screen...');
     Readln;
     Move(oldScr[0], Mem[vidSeg : 0], SizeOf(oldScr));
     (* the above line copies the Array to video memory to restore the
        old screen *)
end.

{
As you can see, video memory starts at offset 0 of either of two segments.  If
the computer is colour, Text screen memory starts at $B800 : 0000 and if the
computer is mono/herc, it starts at $B000 : 0000.  It is 4000 Bytes long.  Why?
 Because there are 2000 Characters on the screen (80 x 25), and each Character
gets a colour attribute (foreground, background, (non)blinking).  The top-left
Character, at row 1, column 1, is [vidSeg] : 0, and the next Byte,[vidSeg] : 1,
is the attribute For the Character, so the memory is laid out like this:

(offset 0) Char, attr, Char, attr, Char, attr.......Char, attr (offset 3999)
}
