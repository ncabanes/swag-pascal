(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0043.PAS
  Description: Advanced measurment of operations
  Author: YUVAL MELAMED
  Date: 01-02-98  07:34
*)

(*
  Written by Yuval Melamed <melamed@star.net.il>, 25-Oct-1997.

  THIS CODE USES MSRs - REQUIRES PENTIUM AND ABOVE.
  This source code is mainly to show an advanced way to measure the
  performance of operations.
  The ClockOn/ClockOff procedure can be put inside a unit, that you
  can use instead of the old, unreliable but popular timer-based
  testers.

  What makes my procedures so accurate, is the counting of internal
  clock cycles (aka proccessor's speed in MHz), instead of relying on the
  slow RTC (only 18.2 times a sec, compared to 133,000,000 clock cycles on
  a 133MHz Pentium.

  The usage of this is great - starting from small yet accurate speed
  testers for regular procedures, ending by the test of very very gentle
  operations, such as different memory accessing methods !

  To make this procedures to measure TIME instead of CLOCKS, you can use:

    ClockOn;
    Delay(1000); {use CRT, or use Int 15h/AH=86h}
    ClockOff;
    CPUSpeed := Clocks / 1000000; {var CPUSpeed : Real}

  and then produce a *nano-second* (!!!) accurate results by using:

    ClockOn;
    ... whatever ... {put here the operation to measure}
    ClockOff;
    NanoSeconds := Clocks / CPUSpeed; {var NanoSeconds : extended}
*)

const
  Times = 1000000; {times to run the test loop}

var
  Index : Longint;   {loop counter}
  Clocks,            {clock cycles counter}
  Resolution : comp; {measurement-resolution in clock cycles}

(* This procedure 'starts' the timer.
   It actually reads the value of the TSC (Time Stamp Counter) of the
   Pentium/Compatible proccessor (TSC is one of the MSRs = Model Specific
   Registers, first introduced with the Pentium).
   The TSC is set to 0 on cold-boot, and increments every internal clock
   cycle (nnn million times on a nnnMHz proccessor).
   The TSC is a 64-bit register, thus we use a comp type to hold it.
   We use a 10h-ECX-indexed 'rdmsr' (Read MSR) even though there's a
   specific opcode to read the TSC (rdtsc), because 'rdmsr' works better
   in most cases.                                                         *)
procedure ClockOn; assembler;
asm
  db 66h; mov cx,0010h; dw 0000h   (* mov ecx,10h                *)
  db 0Fh,32h                       (* rdmsr                      *)
  db 66h; mov word ptr Clocks,ax   (* mov dword ptr Clocks,eax   *)
  db 66h; mov word ptr Clocks+4,dx (* mov dword ptr Clocks+4,edx *)
end;

(* This procedure 'stops' the timer.
   It reads the TSC again, and substract the last TSC read from it (to
   substract 64-bit register, I use 32-bit sub's, with overflow check). *)
procedure ClockOff; assembler;
asm
  db 66h; mov cx,0010h; dw 0000h   (* mov ecx,10h                *)
  db 0Fh,32h                       (* rdmsr                      *)
  db 66h; sub ax,word ptr Clocks   (* sub eax,dword ptr Clocks   *)
  db 66h; sbb dx,word ptr Clocks+4 (* sbb edx,dword ptr Clocks+4 *)
  db 66h; mov word ptr Clocks,ax   (* mov dword ptr Clocks,eax   *)
  db 66h; mov word ptr Clocks+4,dx (* mov dword ptr Clocks+4,edx *)
end;

(* This procedure does nothing (using NOP mnemonic), except being a
   'standard' pascal procedure, that is - 'begin end;' bounded.     *)
procedure PascalProc;
begin
  asm
    nop
  end;
end;

(* This procedure uses the 'assembler' directive, to prevent 'call'
   command to it, from allocating superflouos stack memory (see Help
   for details, or track this code with a debugger).
   On my configuration (Turbo-Pascal 7.0, Pentium 133MHz) it is 225% (!)
   faster than a standard procedure.                                     *)
procedure AssemblerProc; assembler;
asm
  nop
end;

(* This is not actually a procedure, since it never gets to be really
   'call'ed. That is, because 'inline' means the code is inserted
   directly each time it is 'called' (again, see Help/Debugger).
   On my PC, it is 900% faster than using a regular Pascal procedure to
   implement the same code... GO OPTIMIZE !!! ;)                        *)
procedure InlineProc; inline
(
  $90 {90h is the value of the byte-sized NOP mnemonic}
);

begin
  Writeln;
  Writeln(Times, ' calls to different types of identical procedures :');
  ClockOn;
  for Index := 1 to Times do;
  ClockOff;
  Resolution := Clocks; {use 'Resolution' to filter the loop timings}

  ClockOn;
  for Index := 1 to Times do PascalProc;
  ClockOff;
  Writeln('  Standard Pascal procedure            : ',
    Clocks-Resolution:10:0, ' clks.');

  ClockOn;
  for Index := 1 to Times do AssemblerProc;
  ClockOff;
  Writeln('  assembler-directived procedure       : ',
    Clocks-Resolution:10:0, ' clks.');

  ClockOn;
  for Index := 1 to Times do InlineProc;
  ClockOff;
  Writeln('  procedure of type inline (no call)   : ',
    Clocks-Resolution:10:0, ' clks.');
end.

