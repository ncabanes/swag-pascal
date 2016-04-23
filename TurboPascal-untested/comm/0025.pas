{
GINA DAVIS

I have used routines to read/write the comm ports and read Status using
the Port instruction, but mostly I have used BIOS calls (Int $14).  What
you need is a technical reference book spelling out the Registers and
the use of each bit.  (I have a book called "DOS Programmers Reference")
I have source code which accesses a modem on Com1 or Com2 to dial phone
numbers as part of my name & address database / dialer prog (Shareware).

Here's an example of calling INT 14 to set up the serial port:-
}

FUNCTION Init_Port(serialport, params : word) : word;
BEGIN
  regs.AX := params;
  regs.DX := port;
  regs.AH := 0;
  intr($14, regs);
END;

{
 The "serialport" is 0 for Com1 or 1 for Com2.
 "params" determines baud, parity, stop bits, etc.
 $43 for 300, $A3 gives 2400, $83 gives 1200,8,N,1 (p468 DOS Prog Ref)
 (baudbits SHL 5) OR OtherBits - 110,150,300,600,1200,2400,4800,9600

 The function returns the Status, ie. whether the operation was successful.
 And an example of using "Port" to directly access the a port register to
 toggle the DTR bit to hangup the modem:-
}

PROCEDURE Hang_Up_Modem(serialport : word);
VAR
  portaddress : word;
  dummychar   : char;
BEGIN
  IF serialport = 0 THEN
    portaddress := $3FC
  ELSE
    portaddress := $2FC;

  port[portaddress] := port[portaddress] xor $01;
  DELAY(10);
  port[portaddress] := port[portaddress] xor $01;
  DELAY(10);
  port[portaddress] := port[portaddress] AND $FE;

  REPEAT
    dummychar := read_modem(serialport)
  UNTIL regs.AH <> 0;
END;    { Hang_Up_Modem }

