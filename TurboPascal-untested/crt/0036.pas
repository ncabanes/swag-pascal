procedure fadeout;
var x,y,z : word;
  palbuf: array[0..255,1..3] of byte;
begin
  for y := 0 to 255 do
    begin
      asm cli end;
      port[$3c7] := y;
      for z := 1 to 3 do
        palbuf[y,z] := port[$3c9];
      asm sti end;
    end;
  for x := 0 to 63 do
    begin
      for y := 0 to 255 do
        for z := 1 to 3 do 
          if palbuf[y,z] > 0 then dec(palbuf[y,z]);
      asm
        mov dx,3dah
      @1:
        in al,dx
        test al,8
        jz @1
      @2:
        in al,dx
        test al,8
        jnz @2
      end;
      for y := 0 to 255 do
        begin
          asm cli end;
          port[$3c8] := y;
          for z := 1 to 3 do
            port[$3c9] := palbuf[y,z];
          asm sti end;
        end;
    end;

Not the fastest code in the world, but what did you expect?
