(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0042.PAS
  Description: Timer Unit
  Author: JACOB LISTER <LISTERJA@WERO.EE.CIT.
  Date: 08-30-97  10:09
*)


{  +-------------------------------------------------------------------+
   |  Project  : Generic             |  Filename    : TIMERINT.PAS     |
   |  Coded By : Lost (Jacob Lister) |  Version     : 1.0              |   
   |--========-------------+---------+--========-----------------------|
   |  Date     : 05/07/97  |  Created                                  |
   |             06/07/97  |  Got it working                           |
   |             24/07/97  |  Interrupt handler now saves state of     |
   |                       |  flags                                    |
   |             21/08/97  |  Cleaned up for SWAG release              |
   |--========-------------+--========---------------------------------|
   |  Purpose  : General purpose timer interrupt functions, allow many |
   |             handlers to be strung onto the one timer, and         |
   |             re-programs the clock rate as nessacary               |
   |  Notes    : There are some very messy fiddles used here to get the|
   |             interrupt handler working with the sub-fuction record |
   |             table, this is OK because the crappy code is confined |
   |             to this unit.  Take care of what procedures you use   |
   |             this unit to call, for example 'writeln' will behave  |
   |             unstabily if it is being called by both an IRQ and    |
   |             other code at the same time, this goes for most       |
   |             procedures.                                           |
   |  Wish List: Optimize the interrupt handler (timer cirtical)       |
   |--========---------------------------------------------------------|
   |  Credits  : Some interrupt programming info from SWAG             |
   +--========---------------------------------------------------------+  }
{ Usage : to install a handler, call the 'install_handler' with a pointer
          to your procedure and the interval rate in Hz that it is to be
          called.  You handlers MUST be far code, force this by adding
          the directive 'far' to the procedure header, eg
             procedure mytest; far;
          Your procedures are free to use all CPU registers as the unit
          handles preserving these.
          I beleive it is possible for procedures in different units to
          use different data segments, if this is the case for your code,
          your handlers must point DS to their own data segment, to do
          this, put these lines at the start of your handler:
             asm
                mov ax, seg @data
                mov ds, ax
             end;
          You can de-install handlers by calling 'remove_handler',
          alternativly the program will handle all de-installation on
          exit }

unit timerint;

INTERFACE

procedure install_handler(address : pointer; rate : longint);
procedure remove_handler(address : pointer);

IMPLEMENTATION
uses dos;
const USE32 = $66;                      {32 bit instruction prefix}

const clock_rate = 1192755;             {Timer rate (Hz)}
      dos_rate = 63356;                 {The rate dos service call is called}
var tick_rate : longint;                {The current timer rate}
    dos_tick  : longint;                {number of ticks since last dos
                                         timer service called }
    old_handler : pointer;              {Variable to save old int 8 handler}
    old_exit  : pointer;                {save for exit chain}

type timer_int_function = record
   address : pointer;                   {Pointer to the handler}
   rate    : longint;                   {Required rate in timer ticks}
   ticks   : longint;                   {ticks since last call}
   active  : boolean;                   {Is this handler active?}
end;

const t_address  = $0;                  {Address values for the timer record}
      t_rate     = $4;                  {Needed, as they cannot be directly}
      t_ticks    = $8;                  {derived for the inline ASM}
      t_active   = $C;
      t_size     = $D;

const num_handlers = 5;
var timer_ints : array[1..num_handlers] of timer_int_function;

{Variables for interrupt service rountine.}
var call_adr : pointer;


{Re-programs the timer to genererate an interrupt every 'ticks' ticks }
procedure set_clock_rate(ticks : longint);
begin
   port[$43] := $36;
   port[$40] := lo(ticks);
   port[$40] := hi(ticks);
   tick_rate := ticks;
end;

{  +-------------------------------------------------------------------+
   |  Procedure : find_clock_rate                                      |
   |  Callers   : install_handler, remove_handler                      |
   |  Purpose   : Finds the maximum clock rate needed, and sets the    |
   |              timer to run at that rate                            |
   +--========---------------------------------------------------------+
   |  Input     : nothing                                              |
   |  Output    : nothing                                              |
   |  Destroys  : nothing                                              |
   +--========---------------------------------------------------------+
   |  Notes     :                                                      |
   +--========---------------------------------------------------------+   }
procedure find_clock_rate;
var i : byte;
    max_rate : longint;
begin
   max_rate := dos_rate;
   for i:=1 to num_handlers do
     if (timer_ints[i].active = true) and (timer_ints[i].rate < max_rate)
        then max_rate := timer_ints[i].rate;
   set_clock_rate(max_rate);
end;

{  +-------------------------------------------------------------------+
   |  Procedure : install_handler                                      |
   |  Callers   : Anything                                             |
   |  Purpose   : Installs an interrupt handling funtion on to the     |
   |              interrupt.  If the requested rate cannot be handled  |
   |              by the current clock rate, the clock rate is changed |
   +--========---------------------------------------------------------+
   |  Input     : address - Pointer to code to run on interrupt        |
   |              rate    - the rate at which the hander is to run     |
   |                        (in Hz)                                    |
   |  Output    :                                                      |
   |  Destroys  : nothing                                              |
   +--========---------------------------------------------------------+
   |  Notes     :                                                      |
   +--========---------------------------------------------------------+   }
procedure install_handler(address : pointer; rate : longint);
var handler_tick_rate : longint;
    i                 : byte;
begin
   port[$43] := $36;                    {lower clock rate so interrupts don't}
   port[$40] := 0;                      {occur which we are installing handler}
   port[$40] := 0;

   handler_tick_rate := clock_rate div rate;

   for i:=1 to num_handlers do begin
      if(timer_ints[i].active = false) then begin
         timer_ints[i].active   := true;
         timer_ints[i].address  := address;
         timer_ints[i].rate     := handler_tick_rate;
         timer_ints[i].ticks    := 0;
         break;
      end;
   end;
   find_clock_rate;
end;

{  +-------------------------------------------------------------------+
   |  Procedure : remove_handler                                       |
   |  Callers   : Anything                                             |
   |  Purpose   : Searches for the a specified interrupt handler, and  |
   |              removes it, then re-adjusts the clock rate if        |
   |              nessecary                                            |
   +--========---------------------------------------------------------+
   |  Input     : address - pointer to handler routine to remove       |
   |  Output    : nothing                                              |
   |  Destroys  : info for specified handler                           |
   +--========---------------------------------------------------------+
   |  Notes     : Destroys the first found case of routine.  If more   |
   |              than one instance of the same handler function, only |
   |              the first will be destroyed.                         |
   +--========---------------------------------------------------------+   }
procedure remove_handler(address : pointer);
var i : integer;
begin
   port[$43] := $36;                    {lower clock rate so interrupts don't}
   port[$40] := 0;                      {occur which we are removing handler}
   port[$40] := 0;
   for i:=1 to num_handlers do
      if timer_ints[i].address = address then
         timer_ints[i].active := false;
   find_clock_rate;
end;

{  +-------------------------------------------------------------------+
   |  Procedure : interrupt_handler                                    |
   |  Callers   : interrupt 8                                          |
   |  Purpose   : Dispacthes many timer functions off the one timer    |
   |              interrupt as required.  Calls the original DOS IRQ8  |
   |              handler as required                                  |
   +--========---------------------------------------------------------+
   |  Input     : nothing                                              |
   |  Output    : nothing                                              |
   |  Destroys  : nothing                                              |
   +--========---------------------------------------------------------+
   |  Notes     :                                                      |
   +--========---------------------------------------------------------+   }
procedure interrupt_handler; assembler;
asm
   pushf
   db USE32; pusha
   push ds
   push es
   push ss

   mov ax, seg @data
   mov ds, ax

   mov di, OFFSET timer_ints            {Point to our handlers}
   mov cl, num_handlers                 {Get the number of handlers}
 @@L0:
   mov al, 0
   cmp [di+t_active], al
   jz @@Next_Handle                     {Check if handle is active}

   db USE32; mov ax, [di+t_ticks]
   db USE32; add ax, word ptr tick_rate
   db USE32; cmp ax, [di+t_rate]

   jl @@Next_Handle                     {Is it time for the next handle call?}
   db USE32; sub ax, [di+t_rate]        {reset our tick count}

   db USE32; mov bx, [di+t_address]
   db USE32; mov word ptr call_adr, bx

   push ax
   push cx
   push di
   push ds
   CALL call_adr
   pop ds
   pop di
   pop cx
   pop ax

 @@Next_Handle:
   db USE32; mov [di+t_ticks], ax       {Save back the handle tick info}
   add di, t_size
   dec cl
   jnz @@L0

   mov al,$20
   out $20,al

   db USE32; mov ax, word ptr dos_tick
   db USE32; add ax, word ptr tick_rate
   db USE32; mov word ptr dos_tick, ax
   db USE32; cmp ax, 0000; dw 1         {next dos call?}
   jl @@NoDos
   db USE32; sub ax, 0000h; dw 1
   db USE32; mov word ptr dos_tick, ax  {reset dos rate counter}

   pushf
   call [old_handler]                   {never returns}

  @@NoDos:

   pop ss
   pop es
   pop ds
   db USE32; popa
   popf
   iret
end;

{ Clean up code runs when program finishes, resets the timer interrupt
  handler, and resets the clock }
procedure timer_exit; far;
begin
   asm cli end;
   ExitProc := old_exit;
   port[$43] := $36;
   port[$40] := 0;
   port[$40] := 0;
   setintvec(8, old_handler);
   asm sti end;
end;

var i : byte;
begin
   for i:=1 to num_handlers do timer_ints[i].active := false;
   tick_rate := 65536;
   dos_tick := 0;

   getintvec(8,old_handler);
   setintvec(8,@interrupt_handler);
   old_exit := ExitProc;
   ExitProc := @timer_exit;
end.

{---------------------------------- CUT HERE -------------------------------}

program timertst;

uses timerint, crt;

procedure toggle_light(x, y: byte);
const screen = $B800;
      lchr   = $0CFE;
      dchr   = $04FE;
var   adr    : word;
begin
   adr := (y*80+x)*2;
   if(memW[screen:adr] <> lchr) then memW[screen:adr] := lchr
      else memW[screen:adr] := dchr;
end;

procedure test1; far;
begin
   toggle_light(5,5);
end;

procedure test2; far;
begin
   toggle_light(13,5);
end;

procedure test3; far;
begin
   toggle_light(21,5);
end;

procedure test4; far;
begin
   toggle_light(29,5);
end;

procedure test5; far;
begin
   toggle_light(37,5);
end;

begin
   clrscr;
   writeln('+------------------------------------------+');
   writeln('|           TIMERINT UNIT EXAMPLE          |');
   writeln('+------------------------------------------+');
   writeln('|   1 Hz    2 Hz    5 Hz    10 Hz   100 Hz |');
   writeln('|   +-+     +-+     +-+     +-+     +-+    |');
   writeln('|   | |     | |     | |     | |     | |    |');
   writeln('|   +-+     +-+     +-+     +-+     +-+    |');
   writeln('+------------------------------------------+');
   install_handler(@test1, 1);
   install_handler(@test2, 2);
   install_handler(@test3, 5);
   install_handler(@test4, 10);
   install_handler(@test5, 100);

   repeat
   until keypressed;
end.

