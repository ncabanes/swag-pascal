{
> I am looking for some source code that will trap Control-Alt-Del,
> Control-C, and Control-Break, prefered if it can be loaded into
> the Config.sys, but autoexec.bat would work also.

  The compiled code can be loaded from the DOS prompt or
  from any batch. To avoid the message just redirect output
  to the nul device:

     breaknot > nul
}

{$F+}  {Far procedures...}
{$M 2048,0,0}

Program BreakNot;
{---------------------------------------------------------------}
{ This TSR code intercepts hardware interrupt $9 and checks for }
{ Ctrl-C, Ctrl-Break and Ctrl-Alt-Del. If none of these key     }
{ combinations has been pressed the preceeding Int 9 is chained,}
{ otherwise, the keyboard is reset without calling the previous }
{ keyboard vector. Interrupt vectors $1B and $23 are not        }
{ redirected. Rebooting is the only way to unload the TSR and   }
{ re-enable breaks.                                             }
{ Note: usual disclaimers apply: use at own risk, etc...        }
{ - Copyright (c) 1994 Jose Campione 1:163/513.3 -              }
{---------------------------------------------------------------}

Uses DOS;

Var
  KbdStat: byte absolute $0000:$0417;
  KbdPort: byte;
  OldKBD : pointer;

procedure JmpOldISR(OldISR: pointer);
{ ------------------------------------------------}
{ Standard Inline code to Jump from an ISR to the }
{ vector being passed. Origin: an old Critical    }
{ Interrupt handler. Note: Merely rewriting this  }
{ inline code as an Assembler procedure will not  }
{ work -Jose-                                     }
{-------------------------------------------------}
  inline($5B/$58/$87/$5E/$0E/$87/$46/$10/$89/
         $EC/$5D/$07/$1F/$5F/$5E/$5A/$59/$CB);

procedure ResetKbd; assembler;
{---------------------------------------}
{ Standard code to reset the keyboard   }
{ Origin: N. Rubenking's book on TP 6.0 }
{---------------------------------------}
asm
  in     AL,$61     {read keyboard controller}
  mov    AH, AL
  or     AL,$80     {set the "reset bit"}
  out   $61, AL     {send it out}
  xchg   AH, AL     {get original value}
  out   $61, AL     {send it out}
  cli               {disable interrupts}
  mov    AL,$20     {EOI, end-of-interrupt signal}
  out   $20, AL     {send EOI to programmable interrupt controller}
  sti               {enable interrupts}
end;

procedure Key_ISR; interrupt;
begin
  KbdPort:= 0;
  KbdPort:= port[$60];
  if (((KbdStat and  4) =  4) and (KbdPort in [46,70])) or
     (((KbdStat and 12) = 12) and (KbdPort = 83)) then
    ResetKbd             {reset Kbd w/o chaining int 9}
  else
  JmpOldISR( OldKBD );   {jump to Old Keyboard handler }
end;

Begin
 writeln(' BreakNot! Copyright (c) 1994, J.Campione');
 writeln(' Ctrl-C, Ctrl-Break and Ctrl-Alt-Del are now disabled');
 writeln(' To re-enable breaks, reset or restart the computer');
 GetIntVec(9,OldKBD);
 SetIntVec(9,@Key_ISR);
 Keep(0);
End.
