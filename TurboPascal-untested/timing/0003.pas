 {$G+,S-,R-,Q-}
 program timer;

 { Program to time short segments of code; inspired by Michael Abrash's
   Zen timer.  Donated to the public domain by D.J. Murdoch }

 uses
   opdos; { Object Professional unit, needed only for TimeMS,
            a millisecond timer. }

 const
   onetick = 1/33E6;  { This is the time in seconds for one cpu cycle.
                        I've got it set for a 33 Mhz machine. }

 { Instructions:  put your code fragment into a short routine called Segment.
   It should leave the stack unchanged, or it'll blow up when we clone it.
   It *must* have a far return at the end.  Play around with declaring it
   as an assembler procedure or not to see the cost of the TP entry and
   exit code. }

 { This example is Sean Palmer's "var2 := var1 div 2" replacement fragment. }

 var
   var1,var2 : integer;

 procedure Segment; far; assembler;
 asm
    mov ax,var1
    sar ax,1
    jns @S
    adc ax,0
  @S:
    mov var2,ax
 end;

 { This is the comparison TP code.  Note that it includes entry/exit code;
   play around with variations on the assembler version to make it a fair
   comparison }
 (*
 procedure Segment; far;
 begin
   var2 := var1 div 2;
 end;
 *)

 { This procedure is essential!!! Do not move it. It must follow
   Segment directly. }
 procedure Stop;
 begin
 end;

 { This routine will only be called once at the beginning of the program;
   set up any variables that Segment needs }

 procedure Setup;
 begin
   var1 := 5;
   writeln('This run, var1=',var1);
 end;

 const
   maxsize=65520;
   RETF   = $CB;
 var
   p : pointer;
   src,dest : ^byte;
   size : word;
   repeats : word;
   i : word;
   start,finish : longint;
   count : longint;
   main,overhead,millisecs : real;
 begin

   setup;

   { Get a segment of memory, and fill it up with as many copies
     of the segment as possible }

   size := ofs(stop) - ofs(Segment) -1;
   repeats := maxsize div size;
   getmem(p, size*repeats + 1);
   src := @Segment;
   dest := p;
   for i:=1 to repeats do
   begin
     move(src^,dest^,size);
     inc(dest,size);
   end;
   { Add a final RETF at the end. }
   dest^ := RETF;

   { Now do the timing.  Keep repeating one second loops indefinitely. }

   writeln(' Bytes     Clocks       ns       MIPS');
   repeat
     { First loop:  one second worth of calls to the segment }
     start := timems;
     count := 0;
     repeat
       asm
         call dword ptr p
       end;
       finish := timems;
       inc(count);
     until finish > 1000+start;
     main := (finish - start)/repeats/count;

     { Second loop:  1/2 second worth of calls to the RETF }
     start := timems;
     count := 0;
     repeat
       asm
         call dword ptr dest
       end;
       finish := timems;
       inc(count);
     until finish > 500+start;
     overhead := (finish-start)/count;
     millisecs := (main-overhead/repeats);
     writeln(size:6,millisecs/1000/onetick:11:1,
                    1.e6*millisecs:11:0,
                    1/millisecs/1000:11:3);
   until false;
 end.


--- Msg V3.2
 * Origin: Murdoch's Point, Kingston, Ont, Canada  - -   (1:249/99.5)
