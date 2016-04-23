Program GoodFade;
Uses
  Crt;

Const
  I1II111 = 75;
  IIIIII = 60;

Var
  Count, Count2 : Byte;
  Pal1, Pal2 : Array [0..255, 0..2] of Byte;

Procedure I1I1;
begin
  For Count := 0 to 255 DO
  begin
    PORT [$03C7] := Count;
    Pal1 [Count, 0] := PORT [$03C9];
    Pal1 [Count, 1] := PORT [$03C9];
    Pal1 [Count, 2] := PORT [$03C9];
   end;
  Pal2 := Pal1;
end;

Procedure IIIIIII;
begin
  For Count := 0 to 255 DO
  begin
    PORT [$03C8] := Count;
    PORT [$03C9] := Pal1 [Count, 0];
    PORT [$03C9] := Pal1 [Count, 1];
    PORT [$03C9] :=
    Pal1 [Count, 2];
  end;
end;

Procedure FadeOut;
begin
  For Count := 1 to I1II111 DO
  begin
    For Count2 := 0 to 255 DO
    begin
      if Pal2 [Count2, 0] > 0 then
        DEC (Pal2 [Count2, 0]);
      if Pal2 [Count2, 1] > 0 then
        DEC (Pal2 [Count2, 1]);
      if Pal2 [Count2, 2] > 0 then
        DEC (Pal2 [Count2, 2]);
      PORT [$03C8] := Count2;
      PORT [$03C9] := Pal2 [Count2, 0];
      PORT [$03C9] := Pal2 [Count2, 1];
      PORT [$03C9] := Pal2 [Count2, 2];
    end;
    Delay (IIIIII);
  end;
end;

Procedure FadeIn;
begin
  For Count := 1 to I1II111 DO
  begin
    For Count2 := 0 to 255 DO
    begin
      if Pal2 [Count2, 0] < Pal1 [Count2, 0] then
        INC (Pal2 [Count2, 0]);
      if Pal2 [Count2, 1] < Pal1 [Count2, 1] then
        INC (Pal2 [Count2, 1]);
      if Pal2 [Count2, 2] < Pal1 [Count2, 2] then
        INC (Pal2 [Count2, 2]);
      PORT [$03C8] := Count2;
      PORT [$03C9] := Pal2 [Count2, 0];
      PORT [$03C9] := Pal2 [Count2, 1];
      PORT [$03C9] := Pal2 [Count2, 2];
    end;
    Delay (IIIIII);
  end;
end;

begin
  I1I1;
  FadeOut;
  FadeIn;
  IIIIIII;
end.

