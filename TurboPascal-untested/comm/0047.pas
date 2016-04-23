{ ---------------------------------------------------------------------------
  unit COM.PAS

  Turbo Pascal (version 4.0 or higher) unit for serial communication which
  is based on interrupt routines and includes buffering of incoming data.

  Features:

  - supports COM1 and COM2 in parallel
  - baudrates up to 115200 baud
  - RTS/CTS and XON/XOFF flow control

  Version 3.0 - May 1994

  Copyright 1994, Willem van Schaik - Oirschot - Netherlands

  ---------------------------------------------------------------------------
}

  unit Com;

  interface

  uses Crt, Dos;

  type
    PortType = (COM1, COM2);
    BaudType = (B110, B150, B300, B600, B1200, B2400, B4800,
       B9600, B19200, B38400, B57600, B115200);
    ParityType = (None, Odd, Even, Mark, Space);
    LengthType = (D5, D6, D7, D8);
    StopType = (S1, S2);
    FlowType = (No, RtsCts, XonXoff);

  procedure InitCom (PortNumber : PortType;
         BaudRate : BaudType;
                     ParityBit : ParityType;
         DataLength : LengthType;
         StopBits : StopType;
         FlowControl : FlowType);
  procedure ExitCom (PortNumber : PortType);
  function  ComReceived (PortNumber : PortType) : boolean;
  function  ReadCom (PortNumber : PortType) : char;
  function  ComAllowed (PortNumber : PortType) : boolean;
  procedure WriteCom (PortNumber : PortType; OutByte : char);
  procedure BreakCom (PortNumber : PortType);

  implementation

  type
    IntBlock = record
      IntOldIP : integer;
      IntOldCS : integer;
      IntNumber : byte;
    end;

    INS8250 = record
      DLL : integer;  { divisor latch low register (if LCR bit7 = 1) }
      DLH : integer;  { divisor latch high register (if LCR bit7 = 1) }
      THR : integer;  { transmit holding register }
      RBR : integer;  { receive holding register }
      IER : integer;  { interrupt enable register }
      LCR : integer;  { line control register }
      MCR : integer;  { modem control register }
      LSR : integer;  { line status register }
      MSR : integer;  { modem status register }
    end;

  const
    IntDS : integer = 0;
    ComPort : array [COM1..COM2] of INS8250 =
      ((DLL : $3F8 ; DLH : $3F9 ; THR : $3F8 ; RBR : $3F8 ;
        IER : $3F9 ; LCR : $3FB ; MCR : $3FC ; LSR : $3FD ; MSR : $3FE),
       (DLL : $2F8 ; DLH : $2F9 ; THR : $2F8 ; RBR : $2F8 ;
        IER : $2F9 ; LCR : $2FB ; MCR : $2FC ; LSR : $2FD ; MSR : $2FE));
    { size of the input buffer and the amount of free space to disable flow
      from the other side and to enable it again }
    ComBufferSize = 4096;
    ComFlowLower = 256;
    ComFlowUpper = 1024;

  var
    ComBuffer : array [COM1 .. COM2, 0..(ComBufferSize-1)] of byte;
    ComBufferHead, ComBufferTail : array [COM1 .. COM2] of integer;
    ComFlowControl : array [COM1 .. COM2] of FlowType;
    ComFlowHalted : array [COM1 .. COM2] of boolean;
    ComXoffReceived : array [COM1 .. COM2] of boolean;
    ComBlock : array [COM1 .. COM2] of IntBlock;

{ ---------------------------------------------------------------------------
  InstallComInt

  To install an interrupt routine, first the old routine vector is read and
  stored using function 35 hex. Next the new routine is installed using
  function 25 hex.
  ---------------------------------------------------------------------------
}

  procedure InstallComInt (IntNumber : byte; IntHandler : integer;
                           var Block : IntBlock);
  var
    Regs : Registers;

  begin
    IntDS := DSeg;
    Block.IntNumber := IntNumber;
    Regs.AH := $35;
    Regs.AL := IntNumber;
    MSDos (Dos.Registers(Regs));
    Block.IntOldCS := Regs.ES;
    Block.IntOldIP := Regs.BX;
    Regs.AH := $25;
    Regs.AL := IntNumber;
    Regs.DS := CSeg;
    Regs.DX := IntHandler;
    MSDos (Dos.Registers(Regs));
  end;

{ ---------------------------------------------------------------------------
  UnInstallComInt

  Uninstalling the interrupt routine is done by resetting the old interrupt
  vector using function 25.
  ---------------------------------------------------------------------------
}

  procedure UnInstallComInt (var Block : IntBlock);

  var
    Regs : Registers;

  begin
    Regs.AH := $25;
    Regs.AL := Block.IntNumber;
    Regs.DS := Block.IntOldCS;
    Regs.DX := Block.IntOldIP;
    MSDos (Dos.Registers(Regs));
  end;

{ ---------------------------------------------------------------------------
  Com1IntHandler

  This routine is installed as the interrupt routine by InstallComInt, which
  in its turn is called by InitCom at initialisation of the unit.

  When a byte arrives at the COM-port, first action is to get the byte from
  the UART register and store it the buffer. Next the buffer pointer is
  increased. Depending on flow control being enabled or not, it is checked if
  the free space has become less then ComFlowLower and if that is the case the
  other party (the DCE) is signalled to stop transmitting data.

  When the type of flow control specified at calling InitCom is RtsCts (this
  is hardware flow control), the RTS bit of the MCR register is lowered. If
  flow control is XonXoff (software flow control), an XOFF character (13 hex)
  is send to the other party by calling WriteCom.

  Finally the routine must be ended with a CLI instruction and the interrupt
  flags must be cleared.
  ---------------------------------------------------------------------------
}

  procedure Com1IntHandler (Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP
: word);
  interrupt;

  begin
    ComBuffer[COM1, ComBufferHead[COM1]] := Port[ComPort[COM1].RBR];
    if ComFlowControl[COM1] = No then
    begin
      ComBufferHead[COM1] := (ComBufferHead[COM1] + 1) mod ComBufferSize;
    end
    else { when flow control increase buffer pointer later }
    begin
      { check for incoming XON/XOFF }
      if ComFlowControl[COM1] = XonXoff then
      begin
        if ComBuffer[COM1, ComBufferHead[COM1]] = $11 then { XON }
          ComXoffReceived[COM1] := false
        else if ComBuffer[COM1, ComBufferHead[COM1]] = $13 then { XOFF }
          ComXoffReceived[COM1] := true;
      end;
      ComBufferHead[COM1] := (ComBufferHead[COM1] + 1) mod ComBufferSize;
      { check if outgoing must be temporized }
      if not ComFlowHalted[COM1] then
        if (ComBufferHead[COM1] >= ComBufferTail[COM1]) and
   (ComBufferTail[COM1] - ComBufferHead[COM1] + ComBufferSize < ComFlowLower)
   or
   (ComBufferHead[COM1] < ComBufferTail[COM1]) and
   (ComBufferTail[COM1] - ComBufferHead[COM1] < ComFlowLower) then
        begin { buffer gets too full }
   if ComFlowControl[COM1] = RtsCts then
     Port[ComPort[COM1].MCR] := Port[ComPort[COM1].MCR] and $FD { lower RTS }
   else if ComFlowControl[COM1] = XonXoff then
     WriteCom (COM1, #$13); { send XOFF }
   ComFlowHalted[COM1] := true;
        end;
    end;
    inline ($FA);                         { CLI }
    Port[$20] := $20;                     { clear interrupt flag }
  end;

{ ---------------------------------------------------------------------------
  Com2IntHandler

  This routine is identical to Com1IntHandler, only for COM2.
  ---------------------------------------------------------------------------
}

  procedure Com2IntHandler (Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP : word);
  interrupt;

  begin
    ComBuffer[COM2, ComBufferHead[COM2]] := Port[ComPort[COM2].RBR];
    if ComFlowControl[COM2] = No then
    begin
      ComBufferHead[COM2] := (ComBufferHead[COM2] + 1) mod ComBufferSize;
    end
    else { when flow control increase buffer pointer later }
    begin
      { check for incoming XON/XOFF }
      if ComFlowControl[COM2] = XonXoff then
      begin
        if ComBuffer[COM2, ComBufferHead[COM2]] = $11 then { XON }
          ComXoffReceived[COM2] := false
        else if ComBuffer[COM2, ComBufferHead[COM2]] = $13 then { XOFF }
          ComXoffReceived[COM2] := true;
      end;
      ComBufferHead[COM2] := (ComBufferHead[COM2] + 1) mod ComBufferSize;
      { check if outgoing must be temporized }
      if not ComFlowHalted[COM2] then
        if (ComBufferHead[COM2] >= ComBufferTail[COM2]) and
   (ComBufferTail[COM2] - ComBufferHead[COM2] + ComBufferSize < ComFlowLower)
   or
   (ComBufferHead[COM2] < ComBufferTail[COM2]) and
   (ComBufferTail[COM2] - ComBufferHead[COM2] < ComFlowLower) then
        begin { buffer gets too full }
   if ComFlowControl[COM2] = RtsCts then
     Port[ComPort[COM2].MCR] := Port[ComPort[COM2].MCR] and $FD { lower RTS }
   else if ComFlowControl[COM2] = XonXoff then
     WriteCom (COM2, #$13); { send XOFF }
   ComFlowHalted[COM2] := true;
        end;
    end;
    inline ($FA);                         { CLI }
    Port[$20] := $20;                     { clear interrupt flag }
  end;

{ ---------------------------------------------------------------------------
  InitCom;

  For each of the COM ports that will be used, this routine must be called
  to initialize the UART and to install the interrrupt routine. The first
  five parameters define the serial protocol (baudrate B150..B11500, parity
  None..Space, length D5..D8 and number of stop bits S1 or S2). The last
  parameter specifies the type of flow control, with allowed values No,
  RtsCts and XonXoff.

  The control signals DTR and RTS of the COM port (plus the OUT2 signal, which
  is used by some internal modems) are raised to signal the other end of the
  line that the port is ready to receive data.
  ---------------------------------------------------------------------------
}

  procedure InitCom; { (PortNumber : PortType;
            BaudRate : BaudType;
                        ParityBit : ParityType;
            DataLength : LengthType;
            StopBits : StopType;
            FlowControl : FlowType); }
  const
    BaudReg : array [B110 .. B115200] of word =
      ($0417, $0300, $0180, $00C0, $0060, $0030,
       $0018, $000C, $0006, $0003, $0002, $0001);
    ParityReg : array [None..Space] of byte =
      ($00, $08, $18, $28, $38);
    LengthReg : array [D5 .. D8] of byte =
      ($00, $01, $02, $03);
    StopReg : array [S1 .. S2] of byte =
      ($00, $04);

  var
    Regs : Registers;

  begin
    { enable the interrupt (IRQ4 resp. IRQ3) for the specified COM port, by
      resetting the bits in the Interrupt Mask Register of the 8259 interrupt
      controller }
    if PortNumber = COM1 then
    begin
      InstallComInt($0C, Ofs(Com1IntHandler), ComBlock[COM1]);
      Port[$21] := Port[$21] and $EF
    end
    else if PortNumber = COM2 then
    begin
      InstallComInt($0B, Ofs(Com2IntHandler), ComBlock[COM2]);
      Port[$21] := Port[$21] and $F7
    end;

    Port[ComPort[PortNumber].LCR] := $80; { switch to write latch reg }
    Port[ComPort[PortNumber].DLH] := Hi (BaudReg [BaudRate]);
    Port[ComPort[PortNumber].DLL] := Lo (BaudReg [BaudRate]);
    Port[ComPort[PortNumber].LCR] := $00 or
         ParityReg [ParityBit] or
         LengthReg [DataLength] or
         StopReg [StopBits];
    Port[ComPort[PortNumber].IER] := $01; { enable interrupts }
    Port[ComPort[PortNumber].MCR] := $01 or { raise DTR }
                $02 or { raise RTS }
         $08;   { raise OUT2 }
    ComBufferHead[PortNumber] := 0;
    ComBufferTail[PortNumber] := 0;
    ComFlowControl[PortNumber] := FlowControl;
    ComFlowHalted[PortNumber] := false;
    ComXoffReceived[PortNumber] := false;
  end;

{ ---------------------------------------------------------------------------
  ExitCom;

  This routine must be called for each COM port in use, to remove the
  interrupt routine and to reset the control lines.
  ---------------------------------------------------------------------------
}

  procedure ExitCom; { (PortNumber : PortType) }

  var
    Regs : Registers;

  begin
    { disable the interrupt (IRQ4 resp. IRQ3) for the specified COM port, by
      setting the bits in the Interrupt Mask Register of the 8259 interrupt
      controller }
    if PortNumber = COM1 then
      Port[$21] := Port[$21] or $10
    else if PortNumber = COM2 then
      Port[$21] := Port[$21] or $08;

    Port[ComPort[PortNumber].LCR] := Port[ComPort[PortNumber].LCR] and $7F;
    Port[ComPort[PortNumber].IER] := 0; { disable interrupts }
    Port[ComPort[PortNumber].MCR] := 0; { lower DTR, RTS and OUT2 }
    UnInstallComInt(ComBlock[PortNumber]);
  end;

{ ---------------------------------------------------------------------------
  ComReceived;

  When the head and tail pointer (for writing resp. reading bytes) are not
  pointing to the same byte in the buffer, a byte has arrived from the UART
  and was stored in the buffer by the interrupt routine.
  ---------------------------------------------------------------------------
}

  function ComReceived; { (PortNumber : PortType) : boolean; }

  begin
    ComReceived := ComBufferHead[PortNumber] <> ComBufferTail[PortNumber];
  end;

{ ---------------------------------------------------------------------------
  ReadCom;

  Calling this function will wait for a byte in the buffer (if there is not
  yet one present) and then return it. The tail buffer pointer is increased
  and if flow from the other side was stopped, a check is made if the free
  space has again become more then ComFlowUpper. In that situation, depending
  on the type of flow control, either the RTS line is raised or and XON byte
  (11 hex) is send to the other party.
  ---------------------------------------------------------------------------
}

  function ReadCom; { (PortNumber : PortType) : char; }

  begin
    while ComBufferHead[PortNumber] = ComBufferTail[PortNumber] do Delay(10);
    ReadCom := char(ComBuffer[PortNumber, ComBufferTail[PortNumber]]);
    ComBufferTail[PortNumber] := (ComBufferTail[PortNumber] + 1) mod ComBufferSize;
    if (ComFlowControl[PortNumber] <> No) and ComFlowHalted[PortNumber] then
      if (ComBufferHead[PortNumber] >= ComBufferTail[PortNumber]) and
        (ComBufferTail[PortNumber] - ComBufferHead[PortNumber] + ComBufferSize > ComFlowUpper) or
        (ComBufferHead[PortNumber] < ComBufferTail[PortNumber]) and
        (ComBufferTail[PortNumber] - ComBufferHead[PortNumber] > ComFlowUpper)
then
      begin { buffer has emptied enough }
        if ComFlowControl[PortNumber] = RtsCts then
   Port[ComPort[PortNumber].MCR] := Port[ComPort[PortNumber].MCR] or $02 {
raise RTS }
        else if ComFlowControl[PortNumber] = XonXoff then
   WriteCom (PortNumber, #$11); { send XON }
        ComFlowHalted[PortNumber] := false;
      end;
  end;

{ ---------------------------------------------------------------------------
  ComAllowed;

  With this function it is possible to check if writing data to the COM port
  is allowed. When there is no flow control no check is made on any control
  line and the result will always be true. When hardware type flow control is
  enabled, DSR (and CD) and CTS must be high. In case of software flow
  control DSR must be high and a check is made if an XOFF byte was received.
  ---------------------------------------------------------------------------
}

  function  ComAllowed; { (PortNumber : PortType) : boolean; }

  begin
    ComAllowed := true;
    if (ComFlowControl[PortNumber] = RtsCts) then
    begin
      { replace in next line both $30 with $B0 for checking on CD, DSR and CTS}
      if ((Port[ComPort[PortNumber].MSR] and $30) <> $30) then { no DSR or CTS}
        ComAllowed := false;
    end
    else if (ComFlowControl[PortNumber] = XonXoff) then
    begin
      { replace in next line both $20 with $A0 for checking on CD and DSR }
      if ((Port[ComPort[PortNumber].MSR] and $20) <> $20) or { no DSR }
         (ComXoffReceived[PortNumber]) then { XOFF received }
        ComAllowed := false;
    end
  end;

{ ---------------------------------------------------------------------------
  WriteCom;

  This routine is to write a byte to the COM port. However, when necessary
  this will be delayed until the previous output byte is out the the UART.
  ---------------------------------------------------------------------------
}

  procedure WriteCom; { (PortNumber : PortType; OutByte : char); }

  begin
    while ((Port[ComPort[PortNumber].LSR] and $20) <> $20) do  { TD empty }
      Delay(1);
    Port[ComPort[PortNumber].THR] := byte(OutByte);
  end;

{ ---------------------------------------------------------------------------
  BreakCom;

  With this routine the TD line can be lowered for 200 msec, which is a so-
  called break signal.
  ---------------------------------------------------------------------------
}

  procedure BreakCom; { (PortNumber : PortType); }

  begin
    Port[ComPort[PortNumber].LCR] := Port[ComPort[PortNumber].LCR] or $40;
    Delay (200);  { 0.2 seconds }
    Port[ComPort[PortNumber].LCR] := Port[ComPort[PortNumber].LCR] and $BF;
  end;

  end.

{ ---------------------------------------------------------------------------
  end of COM.PAS
  ---------------------------------------------------------------------------
}

{ ---------------------------------------------------------------------------
  program TTY.PAS

  Sample terminal emulation using simple teletype protocol to be used with
  the unit COM.PAS for serial communnication.

  Features:

  - switching between COM1 and COM2
  - baudrates up to 115200 baud
  - RTS/CTS and XON/XOFF flow control
  - debug mode to display control characters

  Version 3.0 - May 1994

  Copyright 1994, Willem van Schaik - Oirschot - Netherlands

  ---------------------------------------------------------------------------
}

  program Tty;

  uses Crt, Com;

  const
    Ascii : array [0..255] of string [5] =
      ('<NUL>','<SOH>','<STX>','<ETX>','<EOT>','<ENQ>','<ACK>','<BEL>',
       '<BS>','<HT>','<LF>','<VT>','<FF>','<CR>','<SO>','<SI>',
       '<DLE>','<DC1>','<DC2>','<DC3>','<DC4>','<NAK>','<SYN>','<ETB>',
       '<CAN>','<EM>','<SUB>','<ESC>','<FS>','<GS>','<RS>','<US>',
       ' ','!','"','#','$','%','&','''','(',')','*','+',',','-','.','/',
       '0','1','2','3','4','5','6','7','8','9',':',';','<','=','>','?',
       '@','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
       'P','Q','R','S','T','U','V','W','X','Y','Z','[','\',']','^','_',
       '`','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
       'p','q','r','s','t','u','v','w','x','y','z','{','|','}','~','<DEL>',
       '<128>','<129>','<130>','<131>','<132>','<133>','<134>','<135>',
       '<136>','<137>','<138>','<139>','<140>','<141>','<142>','<143>',
       '<144>','<145>','<146>','<147>','<148>','<149>','<150>','<151>',
       '<152>','<153>','<154>','<155>','<156>','<157>','<158>','<159>',
       '<160>','<161>','<162>','<163>','<164>','<165>','<166>','<167>',
       '<168>','<169>','<170>','<171>','<172>','<173>','<174>','<175>',
       '<176>','<177>','<178>','<179>','<180>','<181>','<182>','<183>',
       '<184>','<185>','<186>','<187>','<188>','<189>','<190>','<191>',
       '<192>','<193>','<194>','<195>','<196>','<197>','<198>','<199>',
       '<200>','<201>','<202>','<203>','<204>','<205>','<206>','<207>',
       '<208>','<209>','<210>','<211>','<212>','<213>','<214>','<215>',
       '<216>','<217>','<218>','<219>','<220>','<221>','<222>','<223>',
       '<224>','<225>','<226>','<227>','<228>','<229>','<230>','<231>',
       '<232>','<233>','<234>','<235>','<236>','<237>','<238>','<239>',
       '<240>','<241>','<242>','<243>','<244>','<245>','<246>','<247>',
       '<248>','<249>','<250>','<251>','<252>','<253>','<254>','<255>');

  var
    TtyPort : PortType;
    TtyBaud : BaudType;
    TtyParity : ParityType;
    TtyLength : LengthType;
    TtyStop : StopType;
    TtyFlow : FlowType;

    ChCom, ChKey : char;
    DoDebug : boolean;
    GoExit : boolean;

{ ---------------------------------------------------------------------------
  TtyGetPars

  Procedure to handle alt-key combinations that are used to change the
  settings of the terminal emulation protocol.
  ---------------------------------------------------------------------------
}

  procedure TtyGetPars (AltKey : char);

  var
    ParsInput : string[16];

  begin
    case AltKey of

      #120:  { alt-1 }
      begin
        if WhereX > 1 then Writeln;
        Writeln ('TTY:  port = COM1:');
        if TtyPort <> COM1 then
        begin
          ExitCom (TtyPort);
          TtyPort := COM1;
          InitCom (TtyPort, TtyBaud, TtyParity, TtyLength, TtyStop, TtyFlow)
        end;
      end;

      #121:  { alt-2 }
      begin
        if WhereX > 1 then Writeln;
        Writeln ('TTY:  port = COM2:');
        if TtyPort <> COM2 then
        begin
          ExitCom (TtyPort);
          TtyPort := COM2;
          InitCom (TtyPort, TtyBaud, TtyParity, TtyLength, TtyStop, TtyFlow)
        end;
      end;

      #48:  { alt-B }
      begin
        if WhereX > 1 then Writeln;
        Write ('TTY:  baudrate = ');
        Readln (ParsInput);
        if (ParsInput = '3') or (ParsInput = '300') then TtyBaud := B300
        else if (ParsInput = '6') or (ParsInput = '600') then TtyBaud := B600
        else if (ParsInput = '12') or (ParsInput = '1200') then TtyBaud := B1200
        else if (ParsInput = '24') or (ParsInput = '2400') then TtyBaud := B2400
        else if (ParsInput = '48') or (ParsInput = '4800') then TtyBaud := B4800
        else if (ParsInput = '96') or (ParsInput = '9600') then TtyBaud := B9600
        else if (ParsInput = '192') or (ParsInput = '19200') then TtyBaud := B19200
        else if (ParsInput = '384') or (ParsInput = '38400') then TtyBaud := B38400
        else
          Writeln ('      baudrate = 300,600,1200,2400,4800,9600,19200,38400');
        ExitCom (TtyPort);
        InitCom (TtyPort, TtyBaud, TtyParity, TtyLength, TtyStop, TtyFlow);
      end;

      #38:  { alt-L }
      begin
        if WhereX > 1 then Writeln;
        Write ('TTY:  word length = ');
        Readln (ParsInput);
        case ParsInput[1] of
          '5': TtyLength := D5;
          '6': TtyLength := D6;
          '7': TtyLength := D7;
          '8': TtyLength := D8;
        else
          Writeln ('      word length = 5,6,7,8');
        end;
        ExitCom (TtyPort);
        InitCom (TtyPort, TtyBaud, TtyParity, TtyLength, TtyStop, TtyFlow);
      end;

      #25:  { alt-P }
      begin
        if WhereX > 1 then Writeln;
        Write ('TTY:  parity bit = ');
        Readln (ParsInput);
        case ParsInput[1] of
          'n', 'N': TtyParity := None;
          'o', 'O': TtyParity := Odd;
          'e', 'E': TtyParity := Even;
          'm', 'O': TtyParity := Mark;
          's', 'O': TtyParity := Space;
        else
          Writeln ('      parity bit = none,odd,even,mark,space');
        end;
        ExitCom (TtyPort);
        InitCom (TtyPort, TtyBaud, TtyParity, TtyLength, TtyStop, TtyFlow);
      end;

      #31:  { alt-S }
      begin
        if WhereX > 1 then Writeln;
        Write ('TTY:  stop bits = ');
        Readln (ParsInput);
        case ParsInput[1] of
          '1': TtyStop := S1;
          '2': TtyStop := S2;
        else
          Writeln ('      stop bits = 1,2');
        end;
        ExitCom (TtyPort);
        InitCom (TtyPort, TtyBaud, TtyParity, TtyLength, TtyStop, TtyFlow);
      end;

      #33:  { alt-F }
      begin
        if WhereX > 1 then Writeln;
        Write ('TTY:  flow control = ');
        Readln (ParsInput);
        case ParsInput[1] of
          'n', 'N': TtyFlow := No;
          'r', 'R': TtyFlow := RtsCts;
          'x', 'X': TtyFlow := XonXoff;
        else
          Writeln ('      flow control = no,rts/cts,xon/xoff');
        end;
        ExitCom (TtyPort);
        InitCom (TtyPort, TtyBaud, TtyParity, TtyLength, TtyStop, TtyFlow);
      end;

      #23:  { alt-I }
      begin
        if WhereX > 1 then Writeln;
        Write ('TTY:  port = COM', ord(TtyPort)+1, ':      ');
        case TtyBaud of
          B110: Write ('baudrate = 110          ');
          B150: Write ('baudrate = 150          ');
          B300: Write ('baudrate = 300          ');
          B600: Write ('baudrate = 600          ');
          B1200: Write ('baudrate = 1200         ');
          B2400: Write ('baudrate = 2400         ');
          B4800: Write ('baudrate = 4800         ');
          B9600: Write ('baudrate = 9600         ');
          B19200: Write ('baudrate = 19200        ');
          B38400: Write ('baudrate = 38400        ');
          B57600: Write ('baudrate = 57600        ');
          B115200: Write ('baudrate = 115200       ');
        end;
        case TtyParity of
          None: Writeln ('parity bit = none');
          Odd: Writeln ('parity bit = odd');
          Even: Writeln ('parity bit = even');
          Mark: Writeln ('parity bit = mark');
          Space: Writeln ('parity bit = space');
        end;
        case TtyFlow of
          No: Write ('      flow = no         ');
          RtsCts: Write ('      flow = rts/cts    ');
          XonXoff: Write ('      flow = xon/xoff   ');
        end;
        Write ('word length = ', ord(TtyLength)+5, '         ');
        Writeln ('stop bits = ', ord(TtyStop)+1);
      end;

      #35:  { alt-H }
      begin
        if WhereX > 1 then Writeln;
        Write ('TTY:  alt-1 - COM1      ');
        Write ('alt-B - baudrate        ');
        Write ('alt-I - info');
        Writeln;
        Write ('      alt-2 - COM2      ');
        Write ('alt-L - word length     ');
        Write ('alt-H - help');
        Writeln;
        Write ('      alt-F - flow      ');
        Write ('alt-P - parity bit');
        Writeln;
        Write ('      alt-D - debug     ');
        Write ('alt-S - stop bits       ');
        Write ('alt-X - exit');
        Writeln;
      end;

      #32:  { alt-D }
      begin
        DoDebug := not DoDebug;
        if WhereX > 1 then Writeln;
        if DoDebug then
          Writeln ('TTY:  debug = on')
        else
          Writeln ('TTY:  debug = off');
      end;

      #45:  { alt-X }
      begin
        if WhereX > 1 then Writeln;
        Writeln ('TTY:  exit');
        GoExit := true;
      end;

    end;  { case ChKey }
  end;  { procedure TtyGetPars }

{ ---------------------------------------------------------------------------
