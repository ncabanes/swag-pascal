{
   ▌Is there an easy way to time functions and/or procedures??  I'm trying
   ▌to compare a couple functions that do the samething and I would like to
   ▌time them.  I've tried using the GetTime procedure but the hundredths of
   ▌seconds isn't fast enough.  Can any one help?

   I think this unit may help you:

***************************************************************************
}
unit tptimer;

interface

procedure cardinal(l:longint; var result:double);

procedure elapsedtime(start:longint; stop:longint; var result:double);
(*Calculate time elapsed (in milliseconds) between Start and Stop*)

procedure initializetimer;
(*Reprogram the timer chip to allow 1 microsecond resolution*)

procedure restoretimer;
(*Restore the timer chip to its normal state*)

function readtimer:longint;
(*Read the timer with 1 microsecond resolution*)

implementation
uses dos;

const
TimerResolution=1193181.667;

procedure cardinal(l:longint; var result:double);
 Begin
  if l < 0 then result:= l + 4294967296.0
    else
  result := l;
 End;

procedure elapsedtime(start, stop:longint; var result:double);
  var r:double;
 Begin
  cardinal(stop - start, r);
  result := (1000 * r) / TimerResolution;
 End;

procedure initializetimer;
label NullJump1,NullJump2;
Begin
  port[$043]:=$034;
  asm jmp NullJump1;
  NullJump1:
  end;
  port[$040]:=$000;
  asm jmp NullJump2
  NullJump2:
  end;
  port[$040]:=$000;
End;

procedure restoretimer;
label NullJump1,NullJump2;
Begin
  port[$043]:=$036;
  asm jmp NullJump1;
  NullJump1:
  end;
  port[$040]:=$000;
  asm jmp NullJump2
  NullJump2:
  end;
  port[$040]:=$000;
End;

function readtimer:longint; assembler;
label done;
Asm
  cli             (* Disable interrupts *)
  mov  dx,020h     (* Address PIC ocw3   *)
  mov  al,00Ah     (* Ask to read irr    *)
  out  dx,al
  mov  al,00h     (* Latch timer 0 *)
  out  043h,al
  in   al,dx      (* Read irr      *)
  mov  di,ax      (* Save it in DI *)
  in   al,040h     (* Counter --> bx*)
  mov  bl,al      (* LSB in BL     *)
  in   al,040h
  mov  bh,al      (* MSB in BH     *)
  not  bx         (* Need ascending counter *)
  in   al,021h     (* Read PIC imr  *)
  mov  si,ax      (* Save it in SI *)
  mov  al,00FFh    (* Mask all interrupts *)
  out  021h,al
  mov  ax,040h     (* read low word of time *)
  mov  es,ax      (* from BIOS data area   *)
  mov  dx,es:[06Ch]
  mov  ax,si      (* Restore imr from SI   *)
  out  021h,al
  sti             (* Enable interrupts *)
  mov  ax,di      (* Retrieve old irr  *)
  test al,001h     (* Counter hit 0?    *)
  jz   done       (* Jump if not       *)
  cmp  bx,0FFh     (* Counter > 0x0FF?    *)
  ja   done       (* Done if so        *)
  inc  dx         (* Else count int req. *)
done:
  mov ax,bx   (* set function result *)
End;

End.

***********************************************************************

and here is a program to test the unit:

Program TestTime;
uses crt, dos, tptimer;
 var start_time, stop_time: longint;
     time:double;
Begin
 Clrscr;
 initializetimer;
 delay(100);
 start_time:=readtimer;
 delay(2);
 stop_time:=readtimer;
 elapsedtime(start_time, stop_time, time);
 writeln('elapsed time = ', time:0:10);
 readln;
 restoretimer;
End.

