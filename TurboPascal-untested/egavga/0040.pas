(*
ERIC MILLER

> Let's suppose that I used VGA256.BGI.  I change it to VGA256.OBJ.  And in
> my program, I type the following: {$L VGA256.OBJ}

Well, you can't lin VGA256.BGI into the program that way; for some
reason, if it wasn't included in TP6 it won't register.  You have
to use the InstallUserDriver function instead of RegisterBGIDriver.
Here is a program that get's into VGA256 mode that way - but of
course you must already know how to do it.
*)

PROGRAM Vg;

Uses
  Graph;

FUNCTION vgaPresent : boolean; assembler;
asm
  mov ah,$F
  int $10
  mov ax,$1A00
  int $10      {check for VGA/MCGA}
  cmp al,$1A
  jne @ERR     {no VGA Bios}
  cmp bl,7
  jb @ERR      {is VGA or better?}
  cmp bl,$FF
  jnz @OK
 @ERR:
  xor al,al
  jmp @EXIT
 @OK:
  mov al,1
 @EXIT:
end;

{$F+}
FUNCTION DetectVGA256: Integer;
BEGIN
  IF vgaPresent THEN
    DetectVGA256 := 0
  ELSE
    DetectVGA256 := grError;
END;
{$F-}


VAR
  VGA256: Integer;
  B: Integer;

BEGIN
  VGA256 := InstallUserDriver('VGA256', @DetectVGA256);
  B := 0;
  InitGraph(VGA256, B, '');
  OutText('In 320x200x256 - press enter');
  Readln;
  CloseGraph;
END.
