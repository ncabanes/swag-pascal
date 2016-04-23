{
> I started writing communicating-Programs, and even
> trying to develope simple doors. But, i have one
> little problem: I don't know how to hang-up the modem!
> - I am using a ready-made TPU that does all the port
> tasks, but it just can't hang up!
> All i know, is beFore the ~~~+++~~~ATH0 String, i need to 'Drop DTR'...
> How do i do that?!?

if you are using a FOSSIL driver For communications, you could do this:
}

Procedure Lower_DTR;
Var regs:Registers;
begin
  regs.dx:=0;  {com1=0;com2=1;com3=2;com4=3}
  regs.al:=$00;
  regs.ah:=$06;
  intr($14,regs);
  Exit;
end;

