{
> I would like to send one byte of data to the parallel port so I can test
> an interface.  What is the easiest way to do this?
}

Program Send_A_To_LPT1;
Var
  PrinterPort:Array[1..4] Of Byte Absolute $40:$8;
Begin
  Port[PrinterPort[1]]:=Ord('A');
End.

