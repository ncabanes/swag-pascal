{
> I know how to determine the current mode of a card, but how do a lot of
> Programs determine if a VGA is present in the first place? I'd Really

MICHAEL NICOLAI
It's very easy to check if a VGA card is present, 'cause there are some
Functions which are only supported on VGAs. The best one is this:
}

Uses
  Dos;

Function Is_VGA_present : Boolean;
Var
 regs : Registers;
begin
 Is_VGA_present := True;
 regs.ax := $1A00;
 intr($10, regs);
 if (regs.al <> $1A) then
  Is_VGA_present := False;
end;


{ KELD R. HANSEN }

Function VGA : Boolean; Assembler;
Asm
  MOV     AH,1Ah
  INT     10h
  CMP     AL,1Ah
  MOV     AL,True
  JE      @OUT
  DEC     AX
 @OUT:
end;

{ will return True if a VGA card is installed. }
begin
  Writeln(Is_VGA_present);
  Writeln(VGA);
end.