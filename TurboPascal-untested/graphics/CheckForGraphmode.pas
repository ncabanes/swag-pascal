(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0198.PAS
  Description: Check for graphmode
  Author: PING HANSEN
  Date: 11-22-95  13:27
*)

{
Here is a little routine for those of you wanting to check if the VGA is in
graphics mode or textmode - quite handy for screensavers and DOS pop-ups.
}

Var
  t1, t2 : Boolean;

Function InGraphMode : Boolean; Assembler;
  Asm
    CLI
    Mov   Dx,3DAh
    In    Al,Dx         {Reset addr/data flipflop}
    Mov   Dx,3C0h       {Index register}
    Mov   Al,30h        {10h + keep screen output enabled}
    Out   Dx,Al         {Set index}
    Inc   Dx            {Read address}
    {Accesses to the attribute controller must be separated by at least 250ns}
    Nop                 {Small delay, try Jmp @Lab; @Lab: if it doesn't work}
    In    Al,Dx         {Get mode control register}
    And   Al,1          {Isolate graphics bit}
    STI
end {InGraphMode};

Procedure SetMode(m : word); Assembler;
  Asm
    Mov ax,m
    int 10h
  end;

Begin
  SetMode($13);
  t1 := InGraphMode;
  SetMode(3);
  t2 := InGraphMode;
  Writeln(t1, ' ', t2);
end.

