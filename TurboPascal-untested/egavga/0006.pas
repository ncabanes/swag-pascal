{
Would anyone have a Procedure of Function to do a fadein or
fadeout CLXXof a bitmapped image.  if I understand correctly, these
CLXXfadeins are perFormed by changing the DAC Registers of the CLXXVGA
Cards.  Can anyone enlighten me on this as I have CLXXsearched many
books on how to do this and have not found CLXXit.  I know that there is
a utility out there called CLXXFastGraph by Teg Gruber which can do
this, but short of CLXXbuying it For $200.00 Would one of you good folks
have a CLXXroutint in Asm or BAsm to do this. CLXXI thank you all in
advance For your assistance. CLXXChristian Laferriere.
}

Procedure Pageswitch(X: Byte);
begin
  Asm
    mov ah,5
    mov al,x
    int 10h
  end;
end; { Pageswitch }

{********************************************}
Procedure FadeIn;

Var
  oldp,
  oldp2,
  oldp3       : Byte;
  Palette     : Array[1..255 * 4] of Byte;
  FAKEPalette : Array[1..255 * 4] of Byte;
  I, J : Integer;

begin
  For I := 1 to 255 do
  begin
    Port[$3C7] := I;
    Palette[(I - 1) * 4 + 1] := I;
    Palette[(I - 1) * 4 + 2] := Port[$3C9];
    Palette[(I - 1) * 4 + 3] := Port[$3C9];
    Palette[(I - 1) * 4 + 4] := Port[$3C9];
  end;
  For I := 1 to 255 do
  begin
    Port[$3C8] := I;
    Port[$3C9] := 0;
    Port[$3C9] := 0;
    Port[$3C9] := 0;
  end;

  Pageswitch(0);

  For J := 0 to 63 do
  begin

    For I := 1 to 255 do
    begin
      Port[$3C7] := I;
      oldp  := Port[$3C9];
      oldp2 := Port[$3C9];
      oldp3 := Port[$3C9];
      Port[$3C8] :=I;
      if oldp + 1 <= Palette[(I - 1) * 4 + 2] then
        Port[$3C9] := oldp+1
      else
        Port[$3C9] := Oldp;
      if oldp2 + 1 <= Palette[(I - 1) * 4 + 3] then
        Port[$3C9] := oldp2+1
      else
        Port[$3C9] := Oldp2;
      if oldp3 + 1 <= Palette[(I - 1) * 4 + 4] then
        Port[$3C9] := oldp3+1
      else
        Port[$3C9] := Oldp3;
    end;

    For I := 1 to 30000 do
    begin
    end;

  end;
end; {end of FadeIn}


Procedure FadeOut;

Var
  uoldp,
  uoldp2,
  uoldp3  : Byte;
  I, J : Integer;
begin
  Pageswitch(0);

  For J := 0 to 63 do
  begin

    For I := 1 to 255 do
    begin
      Port[$3C7] := I;
      uoldp  := Port[$3C9];
      uoldp2 := Port[$3C9];
      uoldp3 := Port[$3C9];
      Port[$3C8] := I;
      if uoldp - 1 >= 0 then
        Port[$3C9] := uoldp - 1
      else
        Port[$3C9] := uOldp;
      if uoldp2 - 1 >= 0 then
        Port[$3C9] := uoldp2 - 1
      else
        Port[$3C9] := uOldp2;
      if uoldp3 - 1 >= 0 then
        Port[$3C9] := uoldp3 - 1
      else
        Port[$3C9] := uOldp3;
    end;

    For I := 1 to 30000 do
    begin
    end;

  end;
end; {end of FadeOut}

{
That Procedure can FadIn and FadeOut any Text screen or any
Graphics in Mode $13 With no problems.. Just make sure that you
switch the video pages at the right time between fadeIns and
Fadeouts.. Hope that helped.. LATER
}

begin
  FadeOut;
  FadeIn;
end.