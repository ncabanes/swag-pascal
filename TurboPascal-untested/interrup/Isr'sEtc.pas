(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0021.PAS
  Description: ISR's etc!
  Author: GERHARD SKOLNIK
  Date: 05-26-95  23:27
*)

(*
>I've got two questions:
>1. If i write a program that uses SetIntVec and ends with keep(0), how
>can I determine how much heap and how much stack I have to use?
>

I'm not sure about the stack, but the heap can be reduced to a minimum,
like {$M 1024, 0, 0}. As I've never written a resident program in Pascal,
I guess the stack size is a matter of experimenting, but how could I know...


>2. With this program:
>
>uses dos, crt;
>
>procedure print; interrupt;
>begin
> write(#7);
>end;
>
>begin
> SetIntVec($5,addr(print));
>end;
>
>I am also having troubles. At first, the program works, but after a few
>int 5's (which are replacd by a beep) a get (in dutch): internal stack
>overflow error - stopping all system activities
>
>So, at first the stack was big enough, later it wasn't. If the the stack
>'fills', how can I empty it (so it won't overflow)
>
>And, if I intercept an interrupt (PrtScr in this example) there will be
>not screendump. How can I just 'read' the interrupt, or how can I let the
>interrupt continue as it would have done without my SetIntVec. (hop you
>get what I mean :))
>

You've got a classical re-entry problem there. The "write(#7)" statement
takes quite some time to execute (especially as this Pascal line is
compiled into hundreds of machine code lines - it's really better if you
try assembler) if you hit <PrtScreen> too fast again the routine is still
executing, interrupted, called another time etc... until there is no
place on the stack to store any more return addresses. This will never
work, not even with unlimited stack :-(

Here's a workaround and an example how to chain to the original handler
It's taken from a program of mine where I do a lot of interrupt bending,
however it's not a resident one. In this program I called an external
Dos program via exec, which insisted on destroying my screen mask by
displaying some stupid, unnecessary messages. Therefore I had to hide
the video output while it was executing, and as swapping the video
pages didn't work I decided to shoot the fly with a cannon.

I've commented out the Video-Interrupt chaining and inserted your
PrtScr-Interrupt 5 instead. In the commented section you can see
how the chaining is done.

From: skolnik@kapsch.co.at (Gerhard Skolnik)
*)

program DontDoMuch;

{$M 1024, 0, 0}

uses
  Dos, Crt;

var
   OldInt10       : pointer;                       {* old interrupt address *}
   Chain_Int10    : procedure absolute OldInt10;   {* chain to old interrupt *}
   Reg            : Registers;
   IntActive      : boolean;      {* is interrupt active? *}

procedure SkipVideo(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: word);
  interrupt;

  begin
(*    case Reg.AH of
      $09,$0a,$0e,$13 : exit;              {* skip if output request *}
    else
      Chain_Int10;                         {* do anything else as expected *}
    end;
*)
    if not IntActive then
      begin
        IntActive := true;
        write(#7);
        IntActive := false;
      end;
  end;

procedure HideOutPut;

  begin
    SetIntVec($10, @SkipVideo);
  end;

procedure RestoreOutPut;

  begin
    SetIntVec($10, OldInt10);
  end;

begin
  IntActive := false;
  GetIntVec($05, OldInt10);
  SetIntVec($05, @SkipVideo);
  { further initialization stuff }
  keep(0);  { this I never used, but it should go here I guess }
end.

