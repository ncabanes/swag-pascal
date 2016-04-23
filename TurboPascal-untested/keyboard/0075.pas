{

I have a program that needed to disable Ctl-Break.  The program uses the
CRT unit, and the program also used the Readkey() function and the
Keypressed() function.  In order to keep Ctl-Brk from 'working' I had to
replace *both* the Readkey and Keypressed functions with my own, because
those functions, in the TP units, respond to Ctl-Break.  I Also had to
set CheckBreak to false early in the main program routine.

The following  _Keypressed()  function uses bios interrupt 16h to test
to see if a key was pressed and a keystroke is in the keyboard buffer.
It is used just like the TP Keypressed function, and does not process
(responed to) ctl-break. ( if _keypressed then ... ) }

function _keypressed: Boolean; Assembler;
  asm
     push   ds      { save TP DS reg }
     push   sp      { save stack ptr }
     mov    ah, 1   { int 16h fcn 1 }
     int    16h     { ret zero flag clr if keypressed }
     mov    al, 0   { assume false }
     jz     @1      { keypressed ? }
     mov    al, 1   { set true }
   @1:
     pop    sp
     pop    ds
  end;
{
The following _readkey function uses dos interrupt 21h function 7 to get
a character from the keyboard buffer.  It does not echo the character
and does not process (respond to) ctl-break.  It is used just like the
TP readkey function.  ( c := _readkey; ) }

function _readkey: Char;
  var regs:registers;
 begin
   regs.ah := 7;
   msdos(regs);
   _Readkey := char(regs.al);
 end;
