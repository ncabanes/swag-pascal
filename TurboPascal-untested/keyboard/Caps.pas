(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0079.PAS
  Description: Caps
  Author: ROBBIE FLYNN
  Date: 08-24-94  13:27
*)

{
hereya go. I've found that these come in pretty handy. You can make
some cool things with them too. I also have the code to detect if
the lights are on/off also if you want it.
}
uses crt; Procedure TurnCapsOn;Assembler;
ASM

    SUB    AX,AX
    MOV    ES,AX
    MOV    AL,64
    OR     ES:[417h],AL
    RET
END;

Procedure TurnNumOn;Assembler;
ASM

    SUB    AX,AX
    MOV    ES,AX
    MOV    AL,32
    OR     ES:[417h],AL
    RET
END;

Procedure TurnScrollOn;Assembler;
ASM

    SUB    AX,AX
    MOV    ES,AX
    MOV    AL,16
    OR     ES:[417h],AL
    RET
END;

Procedure TurnCapsOff;Assembler;
ASM

    SUB   AX,AX
    MOV   ES,AX
    MOV   AL,10111111b
    AND   ES:[417h],AL
    RET
END;

Procedure TurnNumOff;Assembler;
ASM

    SUB   AX,AX
    MOV   ES,AX
    MOV   AL,11011111b
    AND   ES:[417h],AL
    RET
END;

Procedure TurnScrollOff;Assembler;
ASM

    SUB   AX,AX
    MOV   ES,AX
    MOV   AL,11101111b
    AND   ES:[417h],AL
    RET
END;

var
   x : integer;
{Watch your lights} begin
    x:=0;
    repeat
         inc(x);
         if x mod 3 = 0 then
         Begin             TurnNumOn;TurnCapsOff;TurnScrollOff;
         End;
         If X mod 3 = 1 then
         Begin
             TurnNumOff;TurnCapsOn;TurnScrollOff;
         End;
         If X Mod 3 = 2 then
         Begin
             TurnNumOff;TurnCapsOff;TurnScrollOn;
         End;
         Delay(115);
    until keypressed;
end.

