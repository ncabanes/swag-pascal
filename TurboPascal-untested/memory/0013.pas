{
HAGEN LEHMANN

This Procedure flushes the SMARTDRV.EXE-cache.
}

Procedure FlushChache; Assembler;
Asm
  mov   ax,$4A10
  mov   bx,$0002
  int   $2F
end;

{
MARCO MILTENBURG

Flushing SmartDrive: It's written by Max Maischein (2:249/6.17) and Norbert
Igl (2:2402/300.3), both from Germany (if I'm not mistaken).
}

Procedure FlushSD_sys; Far;
Var
  F : File;
  B : Byte;
begin
  Assign(F, 'SMARTAAR');
  Reset(F);
  B := 0;
  Asm
    push  ds
    mov   ax, 04403h
    mov   bx, FileRec(F).Handle
    mov   cx, 1
    int   21h
    pop   ds
  end;
end;

Procedure FlushSD_exe; Far;
begin
  Asm
    mov   ax, 04A10h
    mov   bx, 1
    int   2Fh
  end;
end;
