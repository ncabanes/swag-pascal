(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0009.PAS
  Description: ASYNC Routines
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{
>doors. But, i have one little problem: I don't know how to hang-up the modem
>- I am using a ready-made TPU that does all the port tasks, but it just can'
>hang up!

Here is some code I pulled out of this conference a While ago:
}

Unit EtAsync;

{****************************************************************************}
{* EtAsync V.1.04, 9/4 1992 Et-Soft                                         *}
{*                                                                          *}
{* Turbo Pascal Unit With support For up to 8 serial ports.                 *}
{****************************************************************************}

{$A-}                              {- Word alignment -}
{$B-}                              {- Complete Boolean evaluation -}
{$D-}                              {- Debug inFormation -}
{$E-}                              {- Coprocessor emulation -}
{$F+}                              {- Force Far calls -}
{$I-}                              {- I/O checking -}
{$L-}                              {- Local debug symbols -}
{$N-}                              {- Coprocessor code generation -}
{$O-}                              {- Overlayes allowed -}
{$R-}                              {- Range checking -}
{$S-}                              {- Stack checking -}
{$V-}                              {- Var-String checking -}
{$M 16384,0,655360}                {- Stack size, min heap, max heap -}
{****************************************************************************}
                                   Interface
{****************************************************************************}
Uses
  Dos;
{****************************************************************************}
  {- Standard baudrates: -}
  {- 50, 75, 110, 134 (134.5), 150, 300, 600, 1200, 1800, 2000, 2400, 3600, -}
  {- 4800, 7200, 9600, 19200, 38400, 57600, 115200 -}

Function OpenCOM            {- Open a COMport For communication -}
  (Nr         : Byte;       {- Internal portnumber: 0-7 -}
   Address    : Word;       {- Port address in hex: 000-3F8 -}
   IrqNum     : Byte;       {- Port Irq number: 0-7  (255 For no Irq) -}
   Baudrate   : LongInt;    {- Baudrate: (see table) -}
   ParityBit  : Char;       {- Parity  : 'O','E' or 'N' -}
   Databits   : Byte;       {- Databits: 5-8 -}
   Stopbits   : Byte;       {- Stopbits: 1-2 -}
   BufferSize : Word;       {- Size of input buffer: 0-65535 -}
   Handshake  : Boolean)    {- True to use hardware handshake -}
     : Boolean;             {- Returns True if ok -}

Procedure CloseCOM          {- Close a open COMport -}
  (Nr : Byte);              {- Internal portnumber: 0-7 -}

Procedure ResetCOM          {- Reset a open COMport incl. buffer -}
  (Nr : Byte);              {- Internal portnumber: 0-7 -}

Procedure COMSettings       {- Change settings For a open COMport -}
  (Nr        : Byte;        {- Internal portnumber: 0-7 -}
   Baudrate  : LongInt;     {- Baudrate: (see table) -}
   Paritybit : Char;        {- Parity  : 'O','E' or 'N' -}
   Databits  : Byte;        {- Databits: 5-8 -}
   Stopbits  : Byte;        {- Stopbits: 1-2 -}
   Handshake : Boolean);    {- True to use hardware handshake -}

Function COMAddress         {- Return the address For a COMport (BIOS) -}
  (COMport : Byte)          {- COMport: 1-8 -}
    : Word;                 {- Address found For COMport (0 if none) -}

Function WriteCOM           {- Writes a Character to a port -}
  (Nr : Byte;               {- Internal portnumber: 0-7 -}
   Ch : Char)               {- Character to be written to port -}
    : Boolean;              {- True if Character send -}

Function WriteCOMString     {- Writes a String to a port -}
  (Nr : Byte;               {- Internal portnumber: 0-7 -}
   St : String)             {- String to be written to port -}
    : Boolean;              {- True if String send -}

Function CheckCOM           {- Check if any Character is arrived -}
  (Nr : Byte;               {- Internal portnumber: 0-7 -}
   Var Ch : Char)           {- Character arrived -}
    : Boolean;              {- Returns True and Character if any -}

Function COMError           {- Returns status of the last operation -}
    : Integer;              {- 0 = Ok -}
                            {- 1 = not enough memory -}
                            {- 2 = Port not open -}
                            {- 3 = Port already used once -}
                            {- 4 = Selected Irq already used once -}
                            {- 5 = Invalid port -}
                            {- 6 = Timeout -}
                            {- 7 = Port failed loopback test -}
                            {- 8 = Port failed IRQ test -}

Function TestCOM            {- PerForms a loopback and IRQ test on a port -}
  (Nr : Byte)               {- Internal port number: 0-7 -}
    : Boolean;              {- True if port test ok -}
                            {- note: This is perFormed during OpenCOM -}
                            {- if enabled (TestCOM is by default enabled -}
                            {- during OpenCOM, but can be disabled With -}
                            {- the DisableTestCOM routine) -}

Procedure EnableTestCOM;    {- Enable TestCOM during Openport (Default On) }

Procedure DisableTestCOM;   {- Disable TestCOM during Openport -}

Function COMUsed            {- Check whether or not a port is open -}
  (Nr : Byte)               {- Internal port number: 0-7 -}
    : Boolean;              {- True if port is open and in use -}
                            {- note: This routine can not test -}
                            {- whether or not a COMport is used by
                            {- another application -}

Function IrqUsed            {- Check whether or not an Irq is used -}
  (IrqNum : Byte)           {- Irq number: 0-7 -}
    : Boolean;              {- True if Irq is used -}
                            {- note: This routine can not test -}
                            {- whether or not an IRQ is used by -}
                            {- another application -}

Function IrqInUse           {- Test IRQ in use on the PIC -}
  (IrqNum : Byte)           {- Irq number: 0-7 -}
    : Boolean;              {- True if Irq is used -}

Procedure SetIrqPriority    {- Set the Irq priority level on the PIC -}
  (IrqNum : Byte);          {- Irq number: 0-7 -}
                            {- The IrqNum specified will get the highest -}
                            {- priority, the following Irq number will
                            {- then have the next highest priority -}
                            {- and so on -}

Procedure ClearBuffer       {- Clear the input buffer For a open port -}
  (Nr : Byte);              {- Internal port number: 0-7 -}


{****************************************************************************}
                                 Implementation
{****************************************************************************}
Type
  Buffer = Array[1..65535] of Byte;  {- Dummy Type For Interrupt buffer -}
  PortRec = Record                   {- Portdata Type -}
    InUse   : Boolean;               {- True if port is used -}
    Addr    : Word;                  {- Selected address -}
    Irq     : Byte;                  {- Selected Irq number -}
    OldIrq  : Byte;                  {- Status of Irq beFore InitCOM -}
    HShake  : Boolean;               {- Hardware handshake on/off -}
    Buf     : ^Buffer;               {- Pointer to allocated buffer -}
    BufSize : Word;                  {- Size of allocated buffer -}
    OldVec  : Pointer;               {- Saved old interrupt vector -}
    Baud    : LongInt;               {- Selected baudrate -}
    Parity  : Char;                  {- Selected parity -}
    Databit : Byte;                  {- Selected number of databits -}
    Stopbit : Byte;                  {- Selected number of stopbits -}
    InPtr   : Word;                  {- Pointer to buffer input index -}
    OutPtr  : Word;                  {- Pointer to buffer output index -}
    Reg0    : Byte;                  {- Saved UART register 0 -}
    Reg1    : Array[1..2] of Byte;   {- Saved UART register 1's -}
    Reg2    : Byte;                  {- Saved UART register 2 -}
    Reg3    : Byte;                  {- Saved UART register 3 -}
    Reg4    : Byte;                  {- Saved UART register 4 -}
    Reg6    : Byte;                  {- Saved UART register 6 -}
  end;

Var
  COMResult   : Integer;                    {- Last Error (Call COMError) -}
  ExitChainP  : Pointer;                    {- Saved Exitproc Pointer -}
  OldPort21   : Byte;                       {- Saved PIC status -}
  Ports       : Array[0..7] of PortRec;     {- The 8 ports supported -}

Const
  PIC = $20;                                {- PIC control address -}
  EOI = $20;                                {- PIC control Byte -}
  TestCOMEnabled : Boolean = True;          {- Test port during OpenCOM -}

{****************************************************************************}
Procedure DisableInterrupts;                {- Disable interrupt -}
begin
  Inline($FA);                            {- CLI (Clear Interruptflag) -}
end;
{****************************************************************************}
Procedure EnableInterrupts;                 {- Enable interrupts -}
begin
  Inline($FB);                            {- STI (Set interrupt flag) -}
end;
{****************************************************************************}
Procedure Port0Int; Interrupt;              {- Interrupt rutine port 0 -}
begin
  With Ports[0] Do
  begin
    Buf^[InPtr] := Port[Addr];             {- Read data from port -}
    Inc(InPtr);                            {- Count one step Forward.. }
    if InPtr > BufSize then
      InPtr := 1;    {  .. in buffer -}
  end;
  Port[PIC] := EOI;                          {- Send EOI to PIC -}
end;
{****************************************************************************}
Procedure Port1Int; Interrupt;                 {- Interrupt rutine port 1 -}
begin
  With Ports[1] Do
  begin
    Buf^[InPtr] := Port[Addr];             {- Read data from port -}
    Inc(InPtr);                            {- Count one step Forward.. }
    if InPtr > BufSize then
      InPtr := 1;    {  .. in buffer -}
  end;
  Port[PIC] := EOI;                          {- Send EOI to PIC -}
end;
{****************************************************************************}
Procedure Port2Int; Interrupt;                 {- Interrupt rutine port 2 -}
begin
  With Ports[2] Do
  begin
    Buf^[InPtr] := Port[Addr];             {- Read data from port -}
    Inc(InPtr);                            {- Count one step Forward.. }
    if InPtr > BufSize then
      InPtr := 1;    {  .. in buffer -}
  end;
  Port[PIC] := EOI;                          {- Send EOI to PIC -}
end;
{****************************************************************************}
Procedure Port3Int; Interrupt;                 {- Interrupt rutine port 3 -}
begin
  With Ports[3] Do
  begin
    Buf^[InPtr] := Port[Addr];            {- Read data from port -}
    Inc(InPtr);                           {- Count one step Forward.. }
    if InPtr > BufSize then
      InPtr := 1;   {  .. in buffer -}
  end;
  Port[PIC] := EOI;                         {- Send EOI to PIC -}
end;
{****************************************************************************}
Procedure Port4Int; Interrupt;                {- Interrupt rutine port 4 -}
begin
  With Ports[4] Do
  begin
    Buf^[InPtr] := Port[Addr];            {- Read data from port -}
    Inc(InPtr);                           {- Count one step Forward.. }
    if InPtr > BufSize then
      InPtr := 1;   {  .. in buffer -}
  end;
  Port[PIC] := EOI;                         {- Send EOI to PIC -}
end;
{****************************************************************************}
Procedure Port5Int; Interrupt;                {- Interrupt rutine port 5 -}
begin
  With Ports[5] Do
  begin
    Buf^[InPtr] := Port[Addr];            {- Read data from port -}
    Inc(InPtr);                           {- Count one step Forward.. }
    if InPtr > BufSize then
      InPtr := 1;   {  .. in buffer -}
  end;
  Port[PIC] := EOI;                         {- Send EOI to PIC -}
end;
{****************************************************************************}
Procedure Port6Int; Interrupt;                {- Interrupt rutine port 6 -}
begin
  With Ports[6] Do
  begin
    Buf^[InPtr] := Port[Addr];            {- Read data from port -}
    Inc(InPtr);                           {- Count one step Forward.. }
    if InPtr > BufSize then
      InPtr := 1;   {  .. in buffer -}
  end;
  Port[PIC] := EOI;                         {- Send EOI to PIC -}
end;
{****************************************************************************}
Procedure Port7Int; Interrupt;                {- Interrupt rutine port 7 -}
begin
  With Ports[7] Do
  begin
    Buf^[InPtr] := Port[Addr];            {- Read data from port-}
    Inc(InPtr);                           {- Count one step Forward..}
    if InPtr > BufSize then
      InPtr := 1;   {  .. in buffer-}
  end;
  Port[PIC] := EOI;                         {- Send EOI to PIC-}
end;
{****************************************************************************}
Procedure InitPort(Nr : Byte; SaveStatus : Boolean);     {- Port initialize -}

Var
  divider  : Word;                               {- Baudrate divider number -}
  CtrlBits : Byte;                                     {- UART control Byte -}

begin
  With Ports[Nr] Do
  begin
    divider := 115200 div Baud;                {- Calc baudrate divider -}

    CtrlBits := DataBit - 5;                    {- Insert databits -}

    if Parity <> 'N' then
    begin
      CtrlBits := CtrlBits or $08;            {- Insert parity enable -}
      if Parity = 'E' then                    {- Enable even parity -}
        CtrlBits := CtrlBits or $10;
    end;

    if Stopbit = 2 then
      CtrlBits := CtrlBits or $04;              {- Insert stopbits -}

    if SaveStatus then
      Reg3 := Port[Addr + $03];    {- Save register 3 -}
    Port[Addr + $03] := $80;                        {- Baudrate change -}

    if SaveStatus then
      Reg0 := Port[Addr + $00];    {- Save Lo Baud -}
    Port[Addr + $00] := Lo(divider);                {- Set Lo Baud -}

    if SaveStatus then
      Reg1[2] := Port[Addr + $01]; {- Save Hi Baud -}
    Port[Addr + $01] := Hi(divider);                {- Set Hi Baud -}

    Port[Addr + $03] := CtrlBits;                   {- Set control reg. -}
    if SaveStatus then
      Reg6 := Port[Addr + $06];    {- Save register 6 -}
  end;
end;
{****************************************************************************}
Function IrqUsed(IrqNum : Byte) : Boolean;

Var
  Count : Byte;
  Found : Boolean;

begin
  Found := False;                                 {- Irq not found -}
  Count := 0;                                     {- Start With port 0 -}

  While (Count <= 7) and not Found Do             {- Count the 8 ports -}
    With Ports[Count] Do
    begin
      if InUse then
        Found := IrqNum = Irq;                  {- Check Irq match -}
      Inc(Count);                               {- Next port -}
    end;

  IrqUsed := Found;                               {- Return Irq found -}
end;
{****************************************************************************}
Procedure EnableTestCOM;
begin
  TestCOMEnabled := True;
end;
{****************************************************************************}
Procedure DisableTestCOM;
begin
  TestCOMEnabled := False;
end;
{****************************************************************************}
Function TestCOM(Nr : Byte) : Boolean;

Var
  OldReg0   : Byte;
  OldReg1   : Byte;
  OldReg4   : Byte;
  OldReg5   : Byte;
  OldReg6   : Byte;
  OldInPtr  : Word;
  OldOutPtr : Word;
  TimeOut   : Integer;

  begin

  TestCOM := False;

  With Ports[Nr] Do
  begin
    if InUse then
    begin
      OldInPtr  := InPtr;
      OldOutPtr := OutPtr;
      OldReg1 := Port[Addr + $01];
      OldReg4 := Port[Addr + $04];
      OldReg5 := Port[Addr + $05];
      OldReg6 := Port[Addr + $06];

      Port[Addr + $05] := $00;
      Port[Addr + $04] := Port[Addr + $04] or $10;

      OldReg0 := Port[Addr + $00];
      OutPtr  := InPtr;

      TimeOut := MaxInt;
      Port[Addr + $00] := OldReg0;

      While (Port[Addr + $05] and $01 = $00) and (TimeOut <> 0) Do
        Dec(TimeOut);

      if TimeOut <> 0 then
      begin
        if Port[Addr + $00] = OldReg0 then
        begin
          if IRQ In [0..7] then
          begin
            TimeOut := MaxInt;
            OutPtr := InPtr;

            Port[Addr + $01] := $08;
            Port[Addr + $04] := $08;
            Port[Addr + $06] := Port[Addr + $06] or $01;

            While (InPtr = OutPtr) and (TimeOut <> 0) Do
              Dec(TimeOut);

            Port[Addr + $01] := OldReg1;

            if (InPtr <> OutPtr) then
              TestCOM := True
            else
              COMResult := 8;
          end
          else
            TestCOM := True;
        end
        else
          COMResult := 7;            {- Loopback test failed -}
      end
      else
        COMResult := 6;                {- Timeout -}

      Port[Addr + $04] := OldReg4;
      Port[Addr + $05] := OldReg5;
      Port[Addr + $06] := OldReg6;

      For TimeOut := 1 to MaxInt Do;
      if Port[Addr + $00] = 0 then;

      InPtr  := OldInPtr;
      OutPtr := OldOutPtr;
    end
    else
      COMResult := 2;                    {- Port not open -}
  end;
end;
{****************************************************************************}
Procedure CloseCOM(Nr : Byte);

begin
  With Ports[Nr] Do
  begin
    if InUse then
    begin
      InUse := False;

      if Irq <> 255 then                         {- if Interrupt used -}
      begin
        FreeMem(Buf,BufSize);                  {- Deallocate buffer -}
        DisableInterrupts;
        Port[$21] := Port[$21] or ($01 Shl Irq) and OldIrq;
{-restore-}
        Port[Addr + $04] := Reg4;              {- Disable UART OUT2 -}
        Port[Addr + $01] := Reg1[1];           {- Disable UART Int. -}
        SetIntVec($08+Irq,OldVec);            {- Restore Int.Vector -}
        EnableInterrupts;
      end;

      Port[Addr + $03] := $80;                    {- UART Baud set -}
      Port[Addr + $00] := Reg0;                   {- Reset Lo Baud -}
      Port[Addr + $01] := Reg1[2];                {- Reset Hi Baud -}
      Port[Addr + $03] := Reg3;                {- Restore UART ctrl. -}
      Port[Addr + $06] := Reg6;                  {- Restore UART reg6 -}
    end
    else
      COMResult := 2;                               {- Port not in use -}
  end;
end;
{****************************************************************************}
Function OpenCOM
 (Nr : Byte; Address  : Word; IrqNum : Byte; Baudrate : LongInt;
  ParityBit : Char; Databits, Stopbits : Byte; BufferSize : Word;
  HandShake : Boolean) : Boolean;

Var
  IntVec : Pointer;
  OldErr : Integer;

begin
  OpenCOM := False;

  if (IrqNum = 255) or
  ((IrqNum In [0..7]) and (MaxAvail >= LongInt(BufferSize))
                      and not IrqUsed(IrqNum)) then
    With Ports[Nr] Do
    begin
      if not InUse and (Address <= $3F8) then
      begin
        InUse   := True;                    {- Port now in use -}

        Addr    := Address;                 {- Save parameters -}
        Irq     := IrqNum;
        HShake  := HandShake;
        BufSize := BufferSize;
        Baud    := Baudrate;
        Parity  := Paritybit;
        Databit := Databits;
        Stopbit := Stopbits;

        InPtr   := 1;                       {- Reset InputPointer -}
        OutPtr  := 1;                       {- Reset OutputPointer -}

        if (Irq In [0..7]) and (BufSize > 0) then
        begin
          GetMem(Buf,BufSize);            {- Allocate buffer -}
          GetIntVec($08+Irq,OldVec);      {- Save Interrupt vector -}

          Case Nr of                    {- Find the interrupt proc. -}
            0 : IntVec := @Port0Int;
            1 : IntVec := @Port1Int;
            2 : IntVec := @Port2Int;
            3 : IntVec := @Port3Int;
            4 : IntVec := @Port4Int;
            5 : IntVec := @Port5Int;
            6 : IntVec := @Port6Int;
            7 : IntVec := @Port7Int;
          end;

          Reg1[1] := Port[Addr + $01];    {- Save register 1 -}
          Reg4    := Port[Addr + $04];    {- Save register 4 -}
          OldIrq  := Port[$21] or not ($01 Shl Irq);{- Save PIC Irq -}

          DisableInterrupts;              {- Disable interrupts -}
          SetIntVec($08+Irq,IntVec);    {- Set the interrupt vector -}
          Port[Addr + $04] := $08;        {- Enable OUT2 on port -}
          Port[Addr + $01] := $01;      {- Set port data avail.int. -}
          Port[$21] := Port[$21] and not ($01 Shl Irq);{- Enable Irq-}
          EnableInterrupts;         {- Enable interrupts again -}
        end;
        InitPort(Nr,True);                  {- Initialize port -}

        if TestCOMEnabled then
        begin
          if not TestCOM(Nr) then
          begin
            OldErr := COMResult;
            CloseCOM(Nr);
            COMResult := OldErr;
          end
          else
            OpenCOM := True;
        end
        else
          OpenCOM := True;

        if Port[Addr + $00] = 0 then;  {- Remove any pending Character-}
        if Port[Addr + $05] = 0 then;  {- Reset line status register-}

        Port[Addr + $04] := Port[Addr + $04] or $01;     {- Enable DTR-}
      end
      else if InUse then
        COMResult := 3                        {- Port already in use-}
      else if (Address > $3F8) then
        COMResult := 5;                       {- Invalid port address-}
    end
  else if (MaxAvail >= BufferSize) then         {- not enough memory-}
    COMResult := 1
  else if IrqUsed(IrqNum) then                  {- Irq already used -}
    COMResult := 4;
end;
{****************************************************************************}
Procedure ResetCOM(Nr : Byte);

begin
  With Ports[Nr] Do
  begin
    if InUse then                        {- Is port defined ?-}
    begin
      InPtr  := 1;                     {- Reset buffer Pointers-}
      OutPtr := 1;
      InitPort(Nr,False);              {- Reinitialize the port-}

      if Port[Addr + $00] = 0 then;    {- Remove any pending Character-}
      if Port[Addr + $05] = 0 then;    {- Reset line status register-}
    end
    else
      COMResult := 2;                    {- Port not open-}
  end;
end;
{****************************************************************************}
Procedure COMSettings(Nr : Byte; Baudrate : LongInt; ParityBit : Char;
  Databits, Stopbits : Byte; HandShake : Boolean);
begin
  With Ports[Nr] Do
  begin
    if InUse then                                     {- Is port in use-}
    begin
      Baud    := Baudrate;                          {- Save parameters-}
      Parity  := Paritybit;
      Databit := Databits;
      Stopbit := Stopbits;
      HShake  := HandShake;

      InitPort(Nr,False);                           {- ReInit port-}
    end
    else
      COMResult := 2;                                 {- Port not in use-}
  end;
end;
{****************************************************************************}
Function COMAddress(COMport : Byte) : Word;

begin
  if Comport In [1..8] then
    COMAddress := MemW[$40:(Pred(Comport) Shl 1)]       {- BIOS data table-}
  else
    COMResult := 5;                                     {- Invalid port-}
end;
{****************************************************************************}
Function WriteCOM(Nr : Byte; Ch : Char) : Boolean;

Var
  Count : Integer;

begin
  WriteCom := True;

  With Ports[Nr] Do
    if InUse then
    begin
      While Port[Addr + $05] and $20 = $00 Do;   {- Wait Until Char send-}
      if not HShake then
        Port[Addr] := ord(Ch)                    {- Send Char to port-}
      else
      begin
        Port[Addr + $04] := $0B;               {- OUT2, DTR, RTS-}
        Count := MaxInt;

        While (Port[Addr + $06] and $10 = 0) and (Count <> 0) Do
          Dec(Count);                          {- Wait For CTS-}

        if Count <> 0 then                     {- if not timeout-}
          Port[Addr] := ord(Ch)                {- Send Char to port-}
        else
        begin
          COMResult := 6;                    {- Timeout error-}
          WriteCom  := False;
        end;
      end;
    end
    else
    begin
      COMResult := 2;                            {- Port not in use-}
      WriteCom  := False;
    end;
end;
{****************************************************************************}
Function WriteCOMString(Nr : Byte; St : String) : Boolean;

Var
  Ok : Boolean;
  Count : Byte;

begin
  if Length(St) > 0 then                           {- Any Chars to send ?-}
  begin
    Ok    := True;
    Count := 1;
    While (Count <= Length(St)) and Ok Do        {- Count Chars-}
    begin
      Ok := WriteCOM(Nr,St[Count]);            {- Send Char-}
      Inc(Count);                              {- Next Character-}
    end;
    WriteCOMString := Ok;                        {- Return status-}
  end;
end;
{****************************************************************************}
Function CheckCOM(Nr : Byte; Var Ch : Char) : Boolean;

begin
  With Ports[Nr] Do
  begin
    if InPtr <> OutPtr then                      {- Any Char in buffer ?-}
    begin
      Ch := Chr(Buf^[OutPtr]);                 {- Get Char from buffer-}
      Inc(OutPtr);                             {- Count outPointer up-}
      if OutPtr > BufSize then
        OutPtr := 1;
      CheckCOM := True;
    end
    else
      CheckCOM := False;                         {- No Char in buffer-}
  end;
end;
{****************************************************************************}
Function COMError : Integer;

begin
  COMError := COMResult;                           {- Return last error-}
  COMResult := 0;
end;
{****************************************************************************}
Function COMUsed(Nr : Byte) : Boolean;

begin
  COMUsed := Ports[Nr].InUse;                      {- Return used status-}
end;
{****************************************************************************}
Function IrqInUse(IrqNum : Byte) : Boolean;

Var
  IrqOn : Byte;
  Mask  : Byte;

begin
  IrqInUse := False;

  if IrqNum In [0..7] then
  begin
    IrqOn := Port[$21];         {-1111 0100-}
    Mask  := ($01 Shl IrqNum);
    IrqInUse := IrqOn or not Mask = not Mask;
  end;
end;
{****************************************************************************}
Procedure SetIrqPriority(IrqNum : Byte);

begin
  if IrqNum In [0..7] then
  begin
    if IrqNum > 0 then
      Dec(IrqNum)
    else IrqNum := 7;

    DisableInterrupts;
    Port[PIC] := $C0 + IrqNum;
    EnableInterrupts;
  end;
end;
{****************************************************************************}
Procedure ClearBuffer(Nr : Byte);

begin
  With Ports[Nr] Do
    if InUse and (BufSize > 0) then
      OutPtr := InPtr;
end;
{****************************************************************************}
Procedure DeInit;

Var
  Count : Byte;

begin
  For Count := 0 to 7 Do
    CloseCOM(Count);          {- Close open ports-}

  DisableInterrupts;
  Port[$21] := OldPort21;                          {- Restore PIC status-}
  Port[$20] := $C7;                                {- IRQ0 1. priority-}
  EnableInterrupts;

  ExitProc := ExitChainP;                          {- Restore ExitProc-}
end;

{****************************************************************************}
Procedure Init;

Var
  Count : Byte;

begin
  COMResult  := 0;
  ExitChainP := ExitProc;                          {- Save ExitProc-}
  ExitProc   := @DeInit;                           {- Set ExitProc-}

  For Count := 0 to 7 Do
    Ports[Count].InUse := False;                   {- No ports open-}

  OldPort21 := Port[$21];                          {- Save PIC status-}
end;

{****************************************************************************}

begin
  Init;
end.

