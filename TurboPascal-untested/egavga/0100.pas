
{$M 16384,0,255360}
uses Dos,crt;

procedure waitretrace;assembler; {wait for next vertical retrace}
asm
  mov dx,$3DA
  @V1: in al,dx; test al,8; jz @v1;
  @V2: in al,dx; test al,8; jnz @v2;
end;

type
  rgb = record r, g, b : byte; end;
  paltype = array[0..255]of rgb;
var
  i : integer;
  pal : paltype;

procedure get_color(var pal : paltype); {save palette}
var
  i : integer;
begin
  port[$3C7] := $00;
  for i:= 0 to 255 do begin
    pal[i].r := port[$3C9];
    pal[i].g := port[$3C9];
    pal[i].b := port[$3C9];
  end;
end;

procedure set_intensity(intensity : byte);
var
  i : integer;
begin
  port[$3C8] := $00;
  for i := 0 to 255 do begin
    port[$3C9] := pal[i].r*intensity div 63;
    port[$3C9] := pal[i].g*intensity div 63;
    port[$3C9] := pal[i].b*intensity div 63;
  end;
end;

procedure set_to_color(r,g,b,h: integer);
var
  i : integer;
begin
  port[$3C8] := $00;
  for i := 0 to 255 do begin
    port[$3C9] := pal[i].r+(r-pal[i].r)*h div 63;
    port[$3C9] := pal[i].g+(g-pal[i].g)*h div 63;
    port[$3C9] := pal[i].b+(b-pal[i].b)*h div 63;
  end;
end;

procedure fade_out(t : integer); {fades from pal to black}
begin
  for i := 63 downto 0 do begin waitretrace; set_intensity(i); delay(t); end;
end;

procedure fade_in(t : integer);  {fades from black to pal}
begin
  for i := 0 to 63 do begin waitretrace; set_intensity(i); delay(t); end;
end;

procedure flash_in(r,b,g: byte;t : integer); {fades from pal to color}
begin
  for i := 0 to 63 do begin waitretrace; set_to_color(r,b,g,i); delay(t); end;
end;

procedure flash_out(r,g,b: byte;t : integer); {fades from color to pal}
begin
  for i := 63 downto 0 do begin waitretrace;set_to_color(r,g,b,i);delay(t);end;
end;

BEGIN

  { Put some stuff on the screen }
  SwapVectors;
  Exec(GetEnv('COMSPEC'),' /c dir \ /w');
  SwapVectors;
  Get_Color(pal);
  fade_out(50);
  fade_in(50);
  Flash_Out(100,16,32,50);
  Flash_In (100,16,32,50);
  ASM
  MOV AX,00003h   {reset to textmode}
  INT 010h
  END;

END.