(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0018.PAS
  Description: Extended Keys
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{ MICHAEL NICOLAI }

Uses
  Dos;

Function Get_Extended_KeyCode : Word;
Var
  regs : Registers;
begin
  regs.ah := $10;
  intr($16, regs);
  Get_Extended_KeyCode := (regs.ah shl 4) + regs.al;
end;

{
This Function waits Until a key is pressed.  The upper Byte contains the
scan code, the lower Byte contains the ASCII code.  If you don't want your
Program to hang if no key is pressed, use this funtion to check if any
keycode is actually present in the keyboard buffer:
}

Function Check_For_Extended_KeyStroke : Boolean;  { like KeyPressed }
Var
  regs : Registers;
begin
  regs.ah := $11;
  intr($16, regs);
  Check_For_Extended_Keystroke := False;
  if ((regs.flags and fzero) = 0) then
    Check_For_Extended_Keystroke := True;
end;

{
After this Function returns True, the keycode can be read With
'Get_Extended_KeyCode'.

Here are the routines my Functions are based on:

INTERRUPT 16h - Function 10h
Keyboard - Get enhanced keystroke

Purpose: Wait For any keyboard input.
Available on: AT or PS/2 With enhanced keyboard support only.
Restrictions: none.
Registers at call: AH = 10h.
Return Registers: AH = scan code, AL = ASCII code
Details: if no keystroke is available, this Function waits Until one is
         placed in the keyboard buffer. Unlike Function 00h, this Function
         does not discard extended keystrokes.
Conflicts: none known.


INTERRUPT 16h - Function 11h
Keyboard - Check For enhanced keystroke

Purpose: Checks For availability of any keyboard input.
Available on: AT or PS/2 With enhanced keyboard only.
Restrictions: none.
Registers at call: AH = 11h
Return Registers: ZF set if no keystroke available
                  ZF clear if keystroke available
                     AH = scan code
                     AL = ASCII code
Details: if a keystroke is available, it is not removed from the keyboard
         buffer. Unlike Function 01h, this Function does not discard extended
         keystrokes.
conflicts: none known.


INTERRUPT 16h - Function 12h
Keyboard - Get extended shift states

Purpose: Returns all shift-flags information from enhanced keyboards.
Available: AT or PS/2 With enhanced keyboard only.
Restrictions: none.
Registers at call: AH = 12h
Return Registers: AL = shift flags 1 (same as returned by Function 02h):
                       bit 7: Insert active
                           6: CapsLock active
                           5: NumLock active
                           4: ScrollLock active
                           3: Alt key pressed (either Alt on 101/102-key
                              keyboard)
                           2: Crtl key pressed (either Ctrl on 101/102-key
                              keyboard)
                           1: left shift key pressed
                           0: right shift key pressed

                  AH = shift flags 2:
                       bit 7: SysRq key pressed
                           6: CapsLock pressed
                           5: NumLock pressed
                           4: ScrollLock pressed
                           3: right Alt key prssed
                           2: right Ctrl key pressed
                           1: left Alt key pressed
                           0: left Ctrl key pressed
Details: AL bit 3 is set only For left Alt key on many machines. AH bits 7
         through 4 are always clear on a Compaq SLT/286.
Conflicts: none known.
}

