{
 Q: How is the code for rebooting the PC written in Turbo Pascal?

 A: This item draws from the information and the C-code example in
Stan Brown's comp.os.msdos.programmer FAQ, garbo.uwasa.fi:
/pc/doc-net/faqp9317.zip (at the time of writing this), from
memory.lst and interrup.b in /pc/programming/inter39b.zip, and from
/pc/programming/helppc21.zip. The Turbo Pascal code is my adaptation
of the C-code. It is not a one-to-one replica.
   The usually advocated warm-boot method is storing $1234 in the
word at $0040:$0072 and jumping to address $FFFF:$0000. The problem
with this approach is that files must first be closed, potential
caches flushed. This is how to do this
}

  procedure REBOOT;
  label next;
  var regs  : registers;
      i     : byte;
      ticks : longint;
  begin
    {... "press" alt-ctrl ...}
    mem[$0040:$0017] := mem[$0040:$0017] or $0C;  { 00001100 }
    {... "press" del, try a few times ...}
    for i := 1 to 10 do
      begin
        FillChar (regs, sizeOf(regs), 0);  { initialize }
        regs.ah := $4F;  { service number }
        regs.al := $53;  { del key's scan code }
        regs.flags := FCarry;  { "sentinel for ignoring key" }
        Intr ($15, regs);
        {... check if the del key registered, if not retry ...}
        if regs.flags and Fcarry > 0 then goto next;
        {... waste some time, watch out for midnight ...}
        ticks := MemL [$0040:$006C];
        repeat until (MemL[$0040:$006C] - ticks > 3) or
                     (MemL[$0040:$006C] - ticks < 0)
    end; {for}
    exit;
  next:
    {... disk reset: writes all modified disk buffers to disk ...}
    FillChar (regs, sizeOf(regs), 0);
    regs.ah := $0D;
    MsDos (regs);
    {... set post-reset flag, use $0000 instead of $1234 for coldboot ...}
    memW[$0040:$0072] := $1234;
    {... jump to $FFFF:0000 BIOS reset ...}
    Inline($EA/$00/$00/$FF/$FF);
  end;  (* reboot *)
{
One slight problem with this approach is that the keyboard intercept
interrupt $15 service $4F requires at least an AT according to
inter39b.zip. A simple test based on "FFFF:E byte ROM machine id"
(the previous definition is from helppc21.zip) is:
}
  function ISATFN : boolean;
  begin
     case Mem[$F000:$FFFE] of
       $FC, $FA, $F8 : isatfn := true;
       else isatfn := false;
     end; {case}
  end;  (* isatfn *)
{
For a more comprehensive test use CPUFN "Get the type of the
processor chip" from TSUNTH in garbo.uwasa.fi:/pc/ts/tspa*.zip or
see the TP + ASM code in Michael Ticher (1992), PC Intern System
Programming, pp. 725-727.
   An addition by Per Bergland (d6caps@dtek.chalmers.se): I recently
downloaded the FAQ for this newsgroup, and studied the code for
rebooting a PC. The problem with that code (calling FFFF:0000) is
that it will not work in protected mode programs such as those
compiled for Windows or BP7 DPMI, or even in a DOS program run in a
Windows DOS session. The solution provided has been tested on
various COMPAQ PC:s, but I think it will work on any AT-class
machine. It involves using the 8042 keyboard controller chip output
pin 0, which is physically connected to the reset pin of the CPU.
There is unfortunately no way to perform a "warm" reboot this way,
and the warnings about disk caches etc apply to this code, too (see
FAQ). The code is written in BP7 assembly lingo, because that's what
I normally write code in, but anyone could rewrite it in C or high
level Pascal.
}

  UNIT Reboot;
  INTERFACE
    procedure DoReboot;
  IMPLEMENTATION
    procedure DoReboot;assembler;
    asm
      cli
  @@WaitOutReady:       { Busy-wait until 8042 is ready for new command}
      in al,64h         { read 8042 status byte}
      test al,00000010b { Bit 1 of status indicates input buffer full }
      jnz @@WaitOutReady
      mov al,0FEh       { Pulse "reset" = 8042 pin 0 }
      out 64h,al
      { The PC will reboot now }
    end;
  END.
