(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0022.PAS
  Description: Interrupt driven external events
  Author: UDO JUERSS
  Date: 02-21-96  21:03
*)

{ This little program shows how to count or act on external events. It works
  since 3 years in a industial application without any problems.
  It's interrupt driven to make sure, that no event is missed.

  You need a male DB25 connector (the counterpart of the PC's printer
  connector), and at least 2 wires. A switch is recommend.
  What you have to do is to connect 2 wires to the male DB25 connector.
  One wire to pin 10 and the other to pin 25.

              IRQ-inputline
            +----------------+
            |                |
            -         13     |10               1
          switch       - - - - - - - - - - - - -
            -           - - - - - - - - - - - -   backview of connector
            |         25|                     14
            +-----------+
               ground

  Pin 10 is the acknowledge line (input) witch normaly is connected to a
  printer output signal. A internal resistor with 4,7k_ pulls this pin up to
  5V TTL level. So the normal level is 5V TTL. With some software setup
  this input line can perform interrupts when the signal is forced from high
  to low level. This can be done with a simple switch that connects pin10 to
  ground. The little "framework" above shows it.

  In the program below events up to 35kHz can be sensed.

  Try ($define IRQ7) first. If this doesn't work then use ($define IRQ5).
  If you do your own interrupt service, consider that it must be a far proc.

  There's a lot of what you can do with this - go external...

  Dec. 12, 1995, Udo Juerss, 57078 Siegen, Germany, CompuServe [101364,526]}

{$define IRQ7}
uses
  Dos,
  Crt;
{---------------------------------------------------------------------------}

var
  Lpt            : Word;
  InterruptCount : Word;
  LptOrgVec      : Procedure;
{---------------------------------------------------------------------------}

procedure SetPortBit(PortAdr:Word; Bit:Byte); assembler;
asm
           mov   dx,PortAdr
           in    al,dx
           mov   cl,Bit
           and   cl,7
           mov   ah,1
           shl   ah,cl
           or    al,ah
           out   dx,al
end;
{---------------------------------------------------------------------------}

procedure ClearPortBit(PortAdr:Word; Bit:Byte); assembler;
asm
           mov   dx,PortAdr
           in    al,dx
           mov   cl,Bit
           and   cl,7
           mov   ah,1
           shl   ah,cl
           not   ah
           and   al,ah
           out   dx,al
end;
{---------------------------------------------------------------------------}

function GetLptPort(LptNr:Byte):Word;
begin
  GetLptPort:=MemW[$0040:8 + (LptNr - 1) * 2];
end;
{---------------------------------------------------------------------------}

{$F+}
procedure NewLptInt; interrupt;
begin
  Sound(880);                                      {Quittungssignal ausgeben}
  Delay(5);
  NoSound;

  Inc(InterruptCount);                              {Interruptzdhler erhvhen}

  SetPortBit(Lpt + 1,6);                 {Bit 6 im Interrupt Register setzen}

  asm                                         {Interrupt Anforderung lvschen}
    mov  al,20h
    out  20h,al
  end;
end;
{$F-}
{---------------------------------------------------------------------------}

begin
  ClrScr;

  Lpt:=GetLptPort(1);                     {Port Adresse der 1. Schnittstelle}
  SetPortBit(Lpt + 1,6);                 {Bit 6 im Interrupt Register setzen}
  SetPortBit(Lpt + 2,4);                  {Bit 4 im Kontroll Register setzen}

{$ifdef IRQ7}
  ClearPortBit($21,7);                {IRQ7 im Intrrupt-Controller freigeben}
  GetIntVec($0F,@LptOrgVec);              {Bisherigen Interrupt Vektor holen}
  SetIntVec($0F,@NewLptInt);              {Vektor f|r neuen Interrupt setzen}
{$else}
  ClearPortBit($21,5);                {IRQ5 im Intrrupt-Controller freigeben}
  GetIntVec($0D,@LptOrgVec);              {Bisherigen Interrupt Vektor holen}
  SetIntVec($0D,@NewLptInt);              {Vektor f|r neuen Interrupt setzen}
{$endif}

  Writeln('Press the interrupt-switch to test response, or any key to quit...');
  Writeln('Interrupts occurrences : ');
  InterruptCount:=0;
  repeat
    GotoXY(25,2);
    Write(InterruptCount:5);
  until KeyPressed;
  ReadKey;

{$ifdef IRQ7}
  SetPortBit($21,7);                    {IRQ7 im Intrrupt-Controller sperren}
  SetIntVec($0F,@LptOrgVec);     {Vektor von urspr|nglichem Interrupt setzen}
{$else}
  SetPortBit($21,5);                    {IRQ5 im Intrrupt-Controller sperren}
  SetIntVec($0D,@LptOrgVec);     {Vektor von urspr|nglichem Interrupt setzen}
{$endif}
end.
