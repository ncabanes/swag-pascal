(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0010.PAS
  Description: Screen Save TSR
  Author: STEVE CONNET
  Date: 08-27-93  21:56
*)

{
STEVE CONNET

>Have you written a screen saver before (or has ANYONE ELSE on this
>echo)? Please post some code I could modify/study/adapt...

I have written a screen saver TSR.  Here's some source if you're interested.
}

Program Save20;
{ SAVE v2.0 by Steve Connet -- Sunday, Jan. 17, 1993
  This is a simple TSR screen saver.  Numeric keypad 5 is the hot key. }

{$M 1024,0,0}                 { reserve 1k of stack space    }
Uses
  DOS;                        { needed to set int vectors    }

{$F+}
VAR
  KbdIntVec : Procedure;      { used to get ISR              }

Procedure GoSave; Interrupt;  { this is our baby             }
Begin { gosave }
  If Port[$60] = 76 then      { Numeric Keypad 5 pressed?    }
  Begin { our baby }
    Asm
      cli                     { ;clear interrupts                     }
      mov  ah, 0fh            { ;get video mode, al=mode, bh=page     }
      int  10h                { ;call interrupt                       }
      mov  ah, 03h            { ;get cursor position, dl=x, dh=y      }
      int  10h                { ;call interrupt                       }
      push dx                 { ;store cursor position on stack       }
      push bx                 { ;store page number on stack           }
      push ax                 { ;store video mode on stack            }
    End;
    Repeat
      Port[$3c2] := 0;                    { wierd video mode  }
      Port[$3c2] := 9;                    { wierd video mode  }
      Port[$3c2] := 247                   { wierd video mode  }
    Until Port[$60] in [0..75, 77..128];  { wait for keypress }

    Port[$60] := 1;      { stuff left shift key }
                         { to disable right ctrl,alt,shift keys }
                         { so they don't mess up keyboard input }
    Asm
      pop ax             { ;restore video mode from stack        }
      or  al,80h         { ;set bit 7, prevent screen clearing   }
      mov ah,00h         { ;set video mode                       }
      int 10h            { ;call interrupt                       }
      pop bx             { ;restore page number from stack       }
      mov ah,05h         { ;set display page                     }
      mov al,bh          { ;use saved page number                }
      int 10h            { ;call interrupt                       }
      pop dx             { ;restore cursor position from stack   }
      mov ah,02h         { ;set cursor position                  }
      int 10h            { ;call interrupt                       }
      sti                { ;restore interrupts                   }
    End;
  End;  { our baby }
  Inline($9c);           { PUSHF push flags                      }
  KbdIntVec;             { call old ISR using saved vector       }
End;
{$F-}

Begin
  Writeln(#13#10, 'SAVE 2.0 by Steve Connet', #13#10, 'Installed.');
  GetIntVec($9, @KbdIntVec); { define a procedure for ISR     }
  SetIntVec($9, @GoSave);    { insert ISR into keyboard chain }
  Keep(0)                    { terminate and stay resident    }
End.

{
 The GoSave procedure has two statements that you may want to take out
 at the very beginning and at the end.  CLI and STI are assembly
 statements that prevent interrupts from happening during our procedure.
 The downfall of these statements is that it prevents the internal clock
 from being updated while the procedure is executing.
}
