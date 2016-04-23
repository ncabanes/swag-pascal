{Here's a unit for sending and receiving async commands }

{ ======================= SERIAL COMMUNICATIONS ============================ }

UNIT      Async;

{$D-,V-,B-,S-,R-}

INTERFACE

USES      Dos, Crt;

TYPE

  BAUD              = (B110,B150,B300,B600,B1200,B2400,B4800,B9600);
  PARITY            = (PNONE, PODD, PNOTHING, PEVEN);

VAR
  AsyncInstalled    : BOOLEAN;
  AsyncActive       : BOOLEAN;


PROCEDURE InitAsync(Com       :BYTE;
                    Speed     :BAUD;
                    Par       :PARITY;
                    Stop      :BYTE;
                    Dbits     :BYTE);
PROCEDURE TermAsync;
FUNCTION  CheckAsync          :WORD;
PROCEDURE HangUp;
PROCEDURE Send(Buffer         :STRING);
PROCEDURE Receive(VAR Buffer  :STRING);

IMPLEMENTATION

CONST

  THR               = 0;
  RBR               = 0;
  IER               = 1;
  IIR               = 2;
  LCR               = 3;
  MCR               = 4;
  LSR               = 5;
  MSR               = 6;
  BUFFSIZE          = 255;
  TIMOUT            = 60000;
  EOI               : BYTE = $20;
  IRQ4low           : BYTE = $EF;
  IRQ4high          : BYTE = $10;
  IRQ3low           : BYTE = $F7;
  IRQ3high          : BYTE = $08;
  ErrorMask         : BYTE = $0E;
  DSRready          : BYTE = $20;
  OUT2              : BYTE = $08;
  DTR               : BYTE = $01;
  RTS               : BYTE = $02;

VAR

  Regs              : REGISTERS;
  OldVector         : POINTER;
  AsyncStatus       : WORD;
  IntType           : BYTE;
  AsyncDisable      : BYTE;
  AsyncEnable       : BYTE;
  AsyncBuff         : ARRAY [0..BUFFSIZE] OF BYTE;
  Front             : INTEGER;
  Rear              : INTEGER;
  ComPort           : BYTE;
  ComBase           : WORD;

{//////////////////////////////////////////////////////////////////////////}

PROCEDURE ZeroDlab;

{ -- zero divisor latch access bit allowing access to THR, RBR and IER }

BEGIN
          PORT[ComBase+LCR]:= PORT[ComBase+LCR] AND $7F;
END;

{//////////////////////////////////////////////////////////////////////////}

PROCEDURE SetDTR;

{ -- enable interrupts and set DTR }

BEGIN
  PORT[ComBase+MCR]:= OUT2 + DTR + RTS;
  DELAY(1000)
END;

{//////////////////////////////////////////////////////////////////////////}

PROCEDURE ReadPorts;

{ -- read UART values }

VAR
  Temp              : BYTE;

BEGIN
  Temp:= PORT[ComBase];
  Temp:= PORT[ComBase+IIR];
  Temp:= PORT[ComBase+LSR];
  Temp:= PORT[ComBase+MSR];
END;

{//////////////////////////////////////////////////////////////////////////}

PROCEDURE HangUp;

{ -- hang up phone }

BEGIN
  ReadPorts;
  PORT[ComBase+MCR]:= 0;
  DELAY(1000);
END;

{//////////////////////////////////////////////////////////////////////////}

FUNCTION CheckAsync;

{ -- return status MB = Line Status, LB = Modem Status }

VAR
  LSReg             : WORD;

BEGIN
  LSReg:= PORT[ComBase+LSR];
  CheckAsync:= (LSReg SHL 8) OR PORT[ComBase+MSR];
END;

{//////////////////////////////////////////////////////////////////////////}

{$F+}

PROCEDURE AsyncISR;

INTERRUPT;

{ -- serial port interrupt routine }

BEGIN
  PORT[$21]:= PORT[$21] AND AsyncDisable;
  INLINE($FB);        { enable interrupts }
  IntType:= PORT[ComBase+IIR] AND 6;
  IF IntType = 4 THEN
  BEGIN
    ZeroDlab;
    AsyncBuff[Rear]:= PORT[ComBase+RBR];
    Rear:= SUCC(Rear) MOD BUFFSIZE
  END;
  AsyncStatus:= (PORT[ComBase+LSR] SHL 8) + PORT[ComBase+MSR];
  INLINE($FA);        { disable interrupts }
  PORT[$20]:= EOI;
  PORT[$21]:= PORT[$21] AND AsyncEnable
END;

{$F-}

{//////////////////////////////////////////////////////////////////////////}

PROCEDURE InstallAsync;

{ -- replaces interrupt vector by user routine }

BEGIN
  IF NOT(AsyncInstalled) THEN
  BEGIN
    GetIntVec($0C-ComPort,OldVector);
    SetIntVec($0C-ComPort,@AsyncISR);
    AsyncInstalled:=TRUE;
  END;
END;

{//////////////////////////////////////////////////////////////////////////}

PROCEDURE DeinstallAsync;

{ -- restores interrupt vector }

BEGIN
  IF AsyncInstalled THEN
  BEGIN
    SetIntVec($0C-ComPort,OldVector);
    AsyncInstalled:=FALSE;
  END;
END;

{//////////////////////////////////////////////////////////////////////////}

PROCEDURE InitAsync(Com       : BYTE;
                    Speed     : BAUD;
                    Par       : PARITY;
                    Stop      : BYTE;
                    Dbits     : BYTE);

{ -- initialize serial port communications }

BEGIN
  WITH Regs DO
  BEGIN
    IF NOT(AsyncActive) THEN
    BEGIN
      ComPort       := Com-1;
      MEMW[0:$400]  := $3F8;             { to prevent a BIOS bug }
      MEMW[0:$402]  := $2F8;             { to prevent a BIOS bug }
      IF ComPort    = 0 THEN
      BEGIN
        ComBase     := $3F8;
        AsyncEnable := IRQ4low;
        AsyncDisable:= IRQ4high;
      END
      ELSE
      BEGIN
        ComBase     := $2F8;
        AsyncEnable := IRQ3low;
        AsyncDisable:= IRQ3high
      END;
      Front         := 0;
      Rear          := 0;
      AsyncStatus   := 0;
      InstallAsync;
      DX            :=ComPort;
      AX            :=ORD(Speed)*32 + ORD(Par)*8 + (Stop-1)*4 + Dbits-5;
      INTR($14,Regs);
      ReadPorts;
      ZeroDlab;
      PORT[ComBase+IER]:= $05;
      INLINE($FA);                                { disable interrupts }
      PORT[$21]     :=PORT[$21] AND AsyncEnable;
      INLINE($FB);                                { enable interrupts }
      SetDTR;
      AsyncActive   := TRUE;
    END
    ELSE
    BEGIN
      HangUp;
      SetDTR;
    END;
  END;
END;

{//////////////////////////////////////////////////////////////////////////}

PROCEDURE Receive;

{ -- get characters from circular buffer }

VAR
  Ch                : CHAR;
  NbrChrs           : INTEGER;
  Count             : LONGINT;

BEGIN
  Buffer  := '';
  Count   := TIMOUT;
  NbrChrs := 0;
  WHILE Count>0 DO
  BEGIN
    DEC(Count);
    IF Front <> Rear THEN
    BEGIN
      REPEAT
        Ch          := CHAR(AsyncBuff[Front]);
        Front       := SUCC(Front) MOD BUFFSIZE;
        IF Ch IN [#0..#31] THEN Ch:= #32;
        Buffer      := Buffer + Ch;
        INC(NbrChrs);
      UNTIL (Front = Rear) OR (NbrChrs = BUFFSIZE);
      Count:= TIMOUT;
    END;
  END;
END;

{//////////////////////////////////////////////////////////////////////////}

PROCEDURE Send;

VAR
  Ptr               : INTEGER;
  TH                : BYTE;
  CH                : CHAR;

BEGIN
  IF LENGTH(Buffer)>0 THEN
  BEGIN
    SetDTR;
    FOR Ptr:=1 TO LENGTH(Buffer) DO
    BEGIN
      REPEAT
        TH:= PORT[ComBase+LSR] AND DSRready
      UNTIL TH<>0;
      CH:= Buffer[Ptr];
      IF (CH = '%') THEN
      BEGIN
        DELAY(1000);
        EXIT;
      END;
      IF (CH = '|') THEN CH:= #13;
      IF (CH = '~') THEN
        DELAY(2000)
      ELSE
        PORT[ComBase+THR]:= BYTE(CH);
    END;
    DELAY(1000);
  END;
END;

{//////////////////////////////////////////////////////////////////////////}

PROCEDURE TermAsync;

{ -- terminate communications }

BEGIN
  IF AsyncActive THEN
  BEGIN
    HangUp;
    INLINE($FA);                        { disable interrupts }
    PORT[$21]       := PORT[$21] OR (IRQ4high + IRQ3high);
    INLINE($FB);                        { enable interrupts }
    ZeroDlab;
    PORT[ComBase+IER]:= 0;
    DELAY(1000);
    DeinstallAsync;
    AsyncActive     := FALSE;
  END;
END;

{//////////////////////////////////////////////////////////////////////////}

BEGIN
  AsyncInstalled    := FALSE;
  AsyncActive       := FALSE;
END.

It's a old unit from tp4 but it works well for me. I think it will not
support the fifo buffers and the specials of the 16550 uart because
they wern't available at that time but maybe somebody can modify it

Greetings from:
                     Niko van Hagen
                     Monday, 25 March 1996, 10:19.
                     The Haghe, Holland
                     Fido       : 2:281/909.11
                     Internet   : nvhagen@worldonline.nl
                     PGP KEYID  : 6CF49689
