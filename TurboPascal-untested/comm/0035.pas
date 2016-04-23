{
I can give you a brief run on a UART of the 8250 line.

Reg 0 used for sending or Recieving a byte;
Reg 1 Interrupt Enable: Bits 0= RX, 1=TX, 2=Serial ERROR, 3=ModemInputStatus
Reg 2 Interrupt ID : if Bit 0 set then no interrupt has happen else
      Bits 1=RXready,2=TxEmty,3=Serial error, 4= ModemInputStatus;

Reg 3 Data Format Line Control;
       Bits 0,1 Select Word Size 0=5,1=6,2=7,3=8
            2   Stops Bits On = 2, oFf - 1;
            3,4,5 :Parity 0=none,1=odd,3=even,5=mark,7=space;
            6   Break Control off = off, on = on
            7   Devisor latch control;
                 Must set this on to have reg 0,1 used as 16 bit value to
                BAUD Rate;
                divisor =(1843200 div (16 * desired baud rate));
(89 min left), (H)elp, More?                When done set bit 7 to off.
reg 4 OutputControl
        0 = DTR,1= RTS, 2,3 = GPO, 4 = LoopBack Test;
Reg 5 Serial Status reg;
       0 = Data Ready on RX line;
       1 = over run, 2= parity errro,3= frame error, 4= break detected,
         5= TXbuffer empty, 6 = Tx Output Reg empty.
Reg 6 Modem INputs
       0-3 are Delta Bits, meaning they  are set when a change has happen
        in the state of the DRS,CTS,RI,DCD since last time, when read these
        bits will clear.
       4 = CTS , 5 = DSR, 6 RI. 7 DCD;
       { ^^^ Reports the current logit level of these inputs }
       { all Delta Bits are in the same alignment bit wise. }
{ Hope this helps }

