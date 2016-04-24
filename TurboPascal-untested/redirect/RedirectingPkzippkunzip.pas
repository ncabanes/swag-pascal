(*
  Category: SWAG Title: DOS REDIRECTION ROUTINES
  Original name: 0009.PAS
  Description: Redirecting PKZIP/PKUNZIP
  Author: MARK OUELLET
  Date: 05-26-95  23:24
*)

{
>> Program windatest;
>> Uses Crt;
>> Begin
>> Window(1, 15, 80, 22);
>> ClrScr;
>> SwapVectors;
>> Exec('C:\PKUNZIP.EXE','-V ZIPPY.ZIP');
>> SwapVectors;
>> End.

>> Note that this may not work for some users: your command is an
>> explicit path/filename, and unless PKUNZIP were in the root

SR>   Although I agree about the comspec problem (and there's no $m
SR> directive), I think this won't work in any case. You probably know
SR> more about this than I, Mike, but I think that exec essentially sets
SR> the screen to 80 by 25 and clears it. Anyway, I've never had success
SR> doing this under normal TP. Gayle Davis (I think) posted a program in
SR> the FIDO Pascal echo that would work, as long as the program didn't
SR> use direct screen writes (which I think PKZIP does). I really can't
SR> think of a way to make it work with direct writes. Well, I can, but it
SR> means going into virtual 86 mode, something I wouldn't feel
SR> comfortable even discussing <g>. I guess that's what Windows and
SR> DesqView do.

SR>   Of course, if you can redirect the output to a file you can then
SR> print that file to the screen....  :)

    The problem is that Pkzip sends output through a different chanel than TP
uses for screen writes. Actually, if you set up a window as above, then hook
up Int29 and replace Normal Int29 code by simply using Write(register al),
then your output will go through TP's IO routines and will respect the window
coordinates. Here ya go! Written, Compiled and Tested using BP 7.x
}

{$A+ Word Align Data}
{$B+ Complete Boolean Eval}
{$D+ Debug Information}
{$E+ Numeric Processing Emulation}
{$F+ Force Far Calls}
{$G+ Generate 286 Instructions}
{$I+ Input/Output Checking}
{$L+ Local Symbol Information}
{$N+ Numeric Coprocessor}
{$O+ Overlay Code Generation}
{$P+ Open String Parameters}
{$Q+ Numerical Overflow Checking}
{$R+ Range Checking}
{$S+ Stack-Overflow Checking}
{$T+ Type-Checked Pointers}
{$V+ Var-String Checking}
{$X+ Extended Syntax}
{$Y+ Symbol Reference Imformation}
{$M 16384,0,0}
Program RedirExec;
uses
  dos,
  crt;

 {$F+}
 procedure NewInt29h(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
  interrupt;

  begin
   asm
     cli
   end;
   write(char(lo(AX)));
   asm
     sti
   end;
  end;
 {$F-}

var
  OldInt29h : procedure;
  X,Y : byte;

begin
  {Save the old Int29 handler adress so we can restore it}
  getintvec($29, @OldInt29h);
  {Set our own Int29 handler}
  setintvec($29, @NewInt29h);
  {Create a fancy window with border}
  textcolor(Yellow);
  textbackground(Blue);
  clrscr;
  window(1,1,80,20);
  write('╔');
  for x := 2 to 80-1 do
    write('═');
  write('╗');
  for x := 2 to 20-1 do
  begin
    write('║');
    for y := 2 to 80-1 do
      write(' ');
    write('║');
  end;

  write('╚');
  for x := 2 to 80-1 do
    write('═');

  inc(WindMax);
  write('╝');
  dec(WindMax);
  textcolor(White);
  textbackground(Black);
  { Now that the border is drawn, just reduce the window by 1 caracters on
    each side so our writes don't mess the border }
  window(2,2,79,19);
  clrscr;
  swapvectors;
  exec('C:\UTIL\PKUNZIP.EXE', '-v G:\DOS\NU\NU8-1.ZIP');
  swapvectors;
  setintvec($29, @OldInt29h);    {Restore old Int 29h}
  window(1,1,80,25);
  gotoxy(1,21);
end.

