{
MARCO MILTENBURG

>> if you find SOURCE to detect/give up time slices For Windows/OS/2/Desqview,
>> could you post it? I have stuff For Desqview, I believe.

>  Procedure GiveTimeSlice; Inline( $cd/$28 );

This is nice, but you have to be sure that you have enough stack space left,
because Dos or TSR's that hook this interrupt will use SS:SP For their own
stack. I use the following in my multitasker detect Unit :
}

Procedure TimeSlice;
Var
  Regs : Registers;
begin
  Case OS_Type Of
    _Dos :
      begin
      end;

    _DV,
    _DVX :
       begin
         Regs.AX := $1000;
         Intr($15, Regs);
       end;

    _OS2,
    _WINS,
    _WIN3:
      begin
        Regs.AX := $1680;
        Intr($2F, Regs);
      end;
  end;
end;
