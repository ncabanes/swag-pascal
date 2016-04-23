

This program demonstrates how to access the special keys,
such asright & left Shift keys, Ctrl key, Alt key, Num Lock key, etc

{
Toggle Controls: -- allow you to check to see if a certain key
was pressed or to turn off or on a certain key, such as
activating the Num-Lock key.

MemW[0000:$0417]
number   bit
    1     0  - Right Shift
    2     1  - Left Shift
    4     2  - Ctrl
    8     3  - Alt
   16     4  - Scroll Lock
   32     5  - Num Lock
   64     6  - Caps Lock
  128     7  - Insert
  256     8  -
  512     9  -
 1024    10  - Sys Req
 2048    11  -
 4096    12  - Scroll Lock Pressed

 8192    13  - Num Lock Pressed
16384    14  - Caps Lock Pressed
32768    15  - Insert Pressed

Other memory locations that can be accessed to get/put
information.

Clock ticks: MemW[$0040:$006C] updates every 58ms.
Clear Key Buffer: MemW[0000:$041A] := MemW[0000:$041C].

Color Address: $B800:0000; Mono Address: $B000:0000.

Print Screen: inline ($CD/$05).
}

{ example }
program TrapAlt;
 Uses
   Dos, Crt;
 Var
   i:char;
 Function alt:boolean;
 Begin

   if MemW[0000:$0417] and 8<>0 then
     begin
      alt:=true;
      repeat
       if keypressed then
         begin
           alt:=false;
           exit;
         end;
      until MemW[0000:$0417] and 8=0;
     end
     else
      alt:=false;
  End;

Begin
 clrscr;
  repeat
   if keypressed then
     begin
       writeln('non alt');
       i:=readkey;
     end;
   if alt then writeln('Alt key pressed');
  until (i=#13);
End.


