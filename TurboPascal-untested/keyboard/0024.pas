BB>procedure ShiftStatus(var Ins,
  >                          CapsLock,
  >                          NumLock,
  >                          ScrollLock,
  >                          Alt,
  >                          Ctrl,
  >                          LeftShift,
  >                          RightShift: Boolean);

I thought this was a little tedious because it is a pain to have all
those variables....so I made something like this:


Unit KeyStats;

Interface

  Function RightShift: Boolean;
  Function LeftShift: Boolean;
  Function Control: Boolean;
  Function Alt: Boolean;
  Function ScrollLock: Boolean;
  Function NumLock: Boolean;
  Function CapsLock: Boolean;
  Function Insert: Boolean;

Implementation

Uses Dos;

Function ShiftState: Byte;
Var Regs: Registers;
Begin
  Regs.Ah:=2;
  Intr($16, Regs);
  ShiftState:=Regs.Al;
End;

Function RightShift: Boolean;
Begin
  RightShift:=(ShiftState and 1)<>0;
End;

Function LeftShift: Boolean;
Begin
  LeftShift:=(ShiftState and 2)<>0;
End;

Function Control: Boolean;
Begin
  Control:=(ShiftState and 4)<>0;
End;

Function Alt: Boolean;
Begin
  Alt:=(ShiftState and 8)<>0;
End;

Function ScrollLock: Boolean;
Begin
  ScrollLock:=(ShiftState and 16)<>0;
End;

Function NumLock: Boolean;
Begin
  NumLock:=(ShiftState and 32)<>0;
End;

Function CapsLock: Boolean;
Begin
  CapsLock:=(ShiftState and 64)<>0;
End;

Function Insert: Boolean;
Begin
  Insert:=(ShiftState and 128)<>0;
End;

End.

Here is a little something that will turn on the light for you.
The state of the keys below is at addrees $40 and offset $17 in memory, by
changing the values at that location, you can turn on the CAPS, the NUM etc..


Type

   Toggles      = (RShift, LShift, Ctrl, Alt,
                   ScrollLock, NumLock, CapsLock, Insert);
   Status       = Set of Toggles;

Var
   KeyStatus   : Status Absolute $40:$17;


Example : to turn on the caps lock, do this :

                        KeyStatus := KeyStatus + [CapsLock];

