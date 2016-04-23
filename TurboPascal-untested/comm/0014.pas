{
│    Does anyone have a few minutes to help a novice?   I'm new to Pascal
│  and have just added a new dimension to my Programming interests
│  through the purchase of Borland's Pascal With Objects 7.0 and as I
│  struggle through the 3000 odd pages of documentation I find I'm
│  missing some of the basics.   For example, I'm trying to Write a
│  little phone dialer as an exercise in using OOP and am having trouble
│  talking to the modem With the following:
│  Assign(Port,COM1);   ReWrite(Port);    Write(Port,ATDT);
│    This works fine only if I run my dialer Program after having using
│  another comms Program With my modem. if I try to run it cold I  get
│  Error 160: Device Write fault.  There is obviously some initialization
│  I need to do to "WAKEUP" the modem.


...Here's some routines to initialize/manipulates the RS-232 port.
}


Procedure InitCommPort(IniStr      : Byte;
                       CommPort    : Word;
                   Var LineStatus
                       ModemStatus  : Byte);
(****************************************************************************
  Parameters:

        InitStr   -   Initialization paramter

                      Bits 7654321     Meaning
                           000           110 baud
                           001           150 baud
                           010           300 baud
                           011           600 baud
                           100          1200 baud
                           101          2400 baud
                           110          4800 baud
                           111          9600 baud
                              00        no parity
                              01        odd parity
                              10        no parity
                              11        even parity
                                0       1 stop bit
                                1       2 stop bit
                                 10     7-bit data length
                                 11     8-bit data length

                      ie: For 1200/N/8/1 use InitStr = 10000011b

        CommPort  -   Communication port (0=com1, 1=com2, 2=com3 etc)

        LineStatus    Bits 76543210        Meaning
                           1            time-out error
                            1           transfer shift register empty
                             1          transfer holding register empty
                              1         break interrupt detected
                               1        framing error
                                1       parity error
                                 1      overrun error
                                  1     data ready

        ModemStatus   Bits 76543210         Meaning
                           1            receive line signal detect
                            1           ring indicator
                             1          data set ready (DSR)
                              1         clear to send (CTS)
                               1        delta receive line signal detect
                                1       trailing edge ring detector
                                 1      delta data set ready (DDSR)
                                  1     delta clear to send  (DCTS)

*****************************************************************************)

Var
  regs : Registers;         (* Uses Dos Unit *)
begin
  regs.AH := $00;
  regs.AL := InitStr;
  regs.DX := CommPort;
  Intr($14, regs);          (* initialize comm port *)
  LineStatus := regs.AH;
  ModemStatus := regs.AL;
end;  (* InitCommPort *)


Procedure TransmitChar(Ch: Byte;            (* Character to send *)
                       CommPort: Word;      (* comm port to use  *)
                   Var Code: Byte)          (* return code       *)
(****************************************************************************

  notE:   BeFore calling this routine, the port must be first initialized
          by InitCommPort.

****************************************************************************)
Var
  regs : Registers;
begin
  regs.AH := $01;
  regs.AL := Ch;
  regs.DX := CommPort;          (* 0=com1, etc    *)
  Intr($14, regs);              (* send Character *)
  Code := regs.AH               (* return code    *)
end;  (* TransmitChar *)
