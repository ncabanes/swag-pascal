{From: MARK OUELLET}
{ FLUSH/STUFF Keyboard w/INT21}

PROGRAM StuffKbdTest;
uses dos;

  procedure FlushKbd; Assembler;

    asm
      Mov AX, $0C00;
      Int 21h;
    end;

  procedure StuffKbd(S:string);

        var
      Regs : registers;
      x : byte;
      BufferFull : boolean;

    begin
      FlushKbd;
      Inc(S[0]);
      S[byte(S[0])] := #13;
      x := 1;
      repeat
        Regs.AH := $05;
        Regs.CL := Byte(S[x]);
        Intr($16, Regs);
        BufferFull := boolean(Regs.AL);
        inc(x);
      until BufferFull or (x>byte(S[0]));
    end;

  begin
        StuffKbd('Dir C:\');
  end.
