{
  Author: Casey Billett
          RR#4,
          Prescott, Ontario,
          Canada
          K0E 1T0
          ** billettc@grenvillecc.ca **

  Date: Saturday, September 21, 1997
  License: Freeware
  Agreement: Header stays intact of source code
  Original purpose: Convert values of an integer or hex to show what the
                    bits in memory would look like. Helps for designing
                    mouse cursor bitmaps.
  Intent: Give to SWAG, they rock.
  This should be easy enough to figure out by yourself. Heck, I'm only
  in grade 12 math. AND I'm a lamer too.
  Help: this program is set up so that you can use parameters. It's a
        handy feature, because then you can specify if you want extra
        output so that you can see a bit more detail of what's going on.
        Its also nice, because you can get output just from the command
        line. ie. bitwise $444 will write the bitwise pattern for it on
        the same line, and that way, with multiple bitwise calls, you
        can draw the bitmap at column 50 on the screen. To use params,
        simply type bitwise and then the hex value. WITH THE $ as the
        prefix to the number. Also, if you specify the -ext option,
        it will print out extra information. That's it! :)
}

program Hex_to_Bits_Converter;

uses
  crt;

type
  bitarraytype = array [0..15] of integer;
  paramtype = array [0..5] of string;

var
  bits: bitarraytype;
  wantextoutput:boolean;
  e,k,l,x:integer;
  y,w:word;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure processparams(var w: word; var wantextoutput: boolean);
var x:integer;
    t:string;
begin
  wantextoutput := false;
  for x:= 1 to paramcount do begin
    if paramstr(x) = '-ext' then wantextoutput := true else begin
      t := paramstr(x);
      val(t,w,e);
    end;
  end;
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure header; { Just some flakey crap - not important functionally }
begin
  writeln;
  textcolor(white);
  write('-> bitwise: ');
  textcolor(lightgray);
  write('by rood00d');
  writeln;
  textcolor(green);
  write('-> hexidecimal => bitwise value');
  textcolor(lightgray);
  writeln;
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
function Power(Base: real; Exponent: integer): longint;
var
  MultCount: integer;
  Result: real;
begin
  Result := 1;
  for MultCount := 1 to Exponent do
    Result := Result * Base;
  Power := round(Result);
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
begin
  w:=0;
  processparams(w,wantextoutput);
  if (w=0) then begin
    header;
    write('-> Give hex value (avec ''$''): ');
    read(w);
  end;
  y:=w;
  k:=1;
  while w<>0 do begin
    w:=w div 2;
    bits[k]:=w mod 2;
    k:=k+1;
  end;
  if odd(y) then bits[0]:=1;
  if wantextoutput then begin
    writeln('Hex as integer: ',y);
    for l:=15 downto 0 do begin
      textcolor(white);
      write(l:2,'-> ');
      textcolor(lightgray);
      gotoxy(6,wherey);
      write(bits[l],': ',power(2,l):5,' = ');
      if (bits[l]*power(2,l) <> 0) then begin
        textcolor(red);
        writeln(bits[l]*power(2,l):5);
        textcolor(lightgray);
      end else begin
        textcolor(lightgray);
        writeln(bits[l]*power(2,l):5);
      end;
    end;
  end;
  textcolor(lightgray);
  gotoxy(50,wherey-1);
  for l:=15 downto 0 do begin
    if bits[l] <> 0 then textcolor(white) else textcolor(lightgray);
    write(bits[l]);
  end;
  textcolor(lightgray);
  write(' ');
end.