(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0059.PAS
  Description: Musical Keyboard Handler
  Author: SWAG SUPPORT TEAM
  Date: 11-26-93  17:21
*)

{
You'll have to write a new Keyboard hardware interrupt handler, I did that
(quite a while ago) for this little program. It generates a different beep
sound for every key pressed. The comments are in Dutch, but if you can read
Afrikaans you might be able to understand them. I think the code is self-
explanatory anyway.
}

program MusicKey;                                    { herziene versie }

uses crt, dos;

const kbd_data   = $60;                   { Keyboard data poort        }
      kbd_ctrl   = $61;                   { Keyboard control poort     }
      int_ctrl   = $20;                   { Interrupt control poort    }
      eoi        = $20;                   { End-of-interrupt constante }
      release    = $80;                   { Key released bit           }
      enable_kbd = $80;                   { Enable keyboard bit        }

const Press      : Byte = 0;    { Scancode van ingedrukte toets        }
var   SaveInt09  : Pointer;     { Om originele intvector in te bewaren }

Procedure NewKbdInt; interrupt;        { Interrupt service routine,    }
var b:Byte;                            { aangeroepen door kbd hardware }
begin
  b:=Port[kbd_data];                    { Lees scancode van poort      }
  if b = Press + Release then Press:=0  { Laatst ingedrukte toets los? }
    else if b < Release then Press:=b;  { Toets ingedrukt? Press:=b    }
  b:=Port[kbd_ctrl];                    { Interrupt netjes afwerken    }
  Port[kbd_ctrl]:=b or enable_kbd;
  Port[kbd_ctrl]:=b;
  Port[int_ctrl]:=eoi;
end;

begin
  GetIntVec($9,SaveInt09);                  { Bewaar originele vector  }
  SetIntVec($9,@NewKbdInt);                 { Installeer onze routine  }
{***}
  Writeln(^J^J^M,'Escape = Exit');
  repeat
    Write(^M,'Gelezen scancode: ',Press:2);     { Druk scancode af     }
    if Press > 1 then Sound(100 * Press)        { Laat toontje horen   }
                 else NoSound;                  { Of niet (Press = 0)  }
  until Press = 1;                              { Escape : Press = 1   }
{***}
  SetIntVec($9,SaveInt09);                  { Herstel originele vector }
end.

