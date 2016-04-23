{
> This leads me to a question that I've often wondered about, but never
> Really bothered to ask anyone: why use a delimiter (commonly '/' or '-')
> preceeding the parameter option?

How would you parse the following command tail:

COPY XYZZY.PAS V:\/S/P/O

if it was entered as

COPY XYZZY.PAS V:\SPO

The delimiter is there to - yes - delimit the parameter from the Text preceding
it.

(and BTW: All the code examples shown here won't take care of this problem,
since they don't allow imbedded parameters. Try this one instead:)
}

Function CAPS(S : String) : String; Assembler;
Asm
  PUSH    DS
  LDS     SI,S
  LES     DI,@Result
  CLD
  LODSB
  STOSB
  xor     CH,CH
  MOV     CL,AL
  JCXZ    @OUT
@LOOP:  LODSB
  CMP     AL,'a'
  JB      @NEXT
  CMP     AL,'z'
  JA      @NEXT
  SUB     AL,20h
@NEXT:  STOSB
  LOOP    @LOOP
@OUT:   POP   DS
end;

Function Switch(C : Char) : Boolean;
Var
  CommandTail         : ^String;
  P                   : Word;

begin
  CommandTail := PTR(PrefixSeg, $0080);
  P := POS('/' + UpCase(C), CAPS(CommandTail^));
  if P = 0 then
    Switch := False
  ELSE
  begin
    Switch := True;
    DELETE(CommandTail^, P, 2)
  end
end;

{
The CAPS routine only converts the 'a' to 'z' range (I have one in my library
that converts all international Characters, but this was a simple one I could
Type in without looking in my library).

The Switch Function also has the added benefit that it strips off the switch
from the command line after having tested For it. This way, you should Program
your Programs in the following way:

[...]
}
begin
  GetSwitchs;
  CopyFile(ParamStr(1),ParamStr(2))
end.

{
and the switches can then be at ANY place on the command line, and the Program
will still Function correctly.
}