{$A+,B+,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 20000,0,0}

{Burn V1.0: the original fireroutine was made by
 Frank Jan Sorensen alias Frank Patxi (fjs@lab.jt.dk)}

{Burn V2.0: interaction, speedup and sparks
            added by Gerhard Piran}

Program Burn2;           {12.12.95}

uses  Dos, Crt;

var   regs: Registers;
      pic: integer;      {drawn pictures}

{********************************************************}
procedure SetVideoMode (vMode: byte);

begin
  regs.ax := vMode;      {Bit 7 = 1: RAM nicht löschen}
  Intr ($10,regs);
end;
{--------------------------------------------------------}
function GetVideoMode: byte;

begin
  regs.ah := $0F;
  intr ($10, regs);
  GetVideoMode := regs.al;
end;
{*********************************************************}
type  ColorValue = record R,G,B: byte; end;
      VGAPaletteType = array[0..255] of ColorValue;

procedure ReadPal (var pal: VGAPaletteType);

begin
  regs.AX := $1017;
  regs.BX := 0;
  regs.CX := 256;
  regs.ES := Seg(pal);
  regs.DX := Ofs(pal);
  repeat until Port[$03DA] And $08 = $08; {Wait for rescan}
  Intr ($10,regs);
end;
{--------------------------------------------------------}
procedure WritePal (var pal: VGAPaletteType);

begin
  regs.AX := $1012;
  regs.BX := 0;
  regs.CX := 256;
  regs.ES := Seg(pal);
  regs.DX := Ofs(pal);
  repeat until Port[$03DA] and $08 = $08; {Wait for rescan}
  Intr($10,regs);
end;
{*********************************************************}
{ Convert HSI (Hue, Saturation, Intensity) -> RGB }
{---------------------------------------------------------}
procedure Hsi2Rgb (H, S, I: Real; var C: ColorValue);

var   T, Rv, Gv, Bv: Real;

begin
  T  := H;
  Rv := 1 + S * Sin(T - 2 * Pi / 3);
  Gv := 1 + S * Sin(T);
  Bv := 1 + S * Sin(T + 2 * Pi / 3);
  T  := 63.999 * I / 2;
  c.R := trunc(Rv * T);
  c.G := trunc(Gv * T);
  c.B := trunc(Bv * T);
end;
{*********************************************************}
{ fast pixel drawing for graphic mode 320x200x256
{---------------------------------------------------------}
procedure PutPixel (x,y: integer; c: byte); assembler;
 asm
  mov ax,y
  mov bx,ax
  shl ax,8
  shl bx,6
  add bx,ax
  add bx,x
  mov ax,0a000h
  mov es,ax
  mov al,c
  mov es:[bx],al
 end;
{--------------------------------------------------------}
function GetPixel (x,y: integer): byte;

begin
 asm
  mov ax,y
  mov bx,ax
  shl ax,8
  shl bx,6
  add bx,ax
  add bx,x
  mov ax,0a000h
  mov es,ax
  mov al,es:[bx]
  mov @result,al
 end;
end;
{********************************************************}
procedure Info;

begin
  ClrScr;
  WriteLn('Burn V 2.0,   a hot burning stuff'#13#10);
  WriteLn('commands: '#13#10
         +'    ?     this help'#13#10
         +'   + -    change width'#13#10
         +'    C     clear base fire'#13#10
         +'    W     give water into fire'#13#10
         +'    P     draw palette'#13#10
         +'    A     animate values on/off');
  WriteLn('  space   random values'#13#10
         +'  cursor  edit values'#13#10
         +'   ESC    exit demo'#13#10);
  WriteLn('values 1: decrease root of flame'#13#10
         +'       2: how far flames go up'#13#10
         +'       3: more or less fire'#13#10
         +'       4: smooth root of flame'#13#10
         +'       5: limit of start burning'#13#10
         +'       6: burnability (wood..gaz)'#13#10
         +'       7: sparks'#13#10
         +'       8: new flames'#13#10
         +'       9: put water into fire'#13#10);
end;
{********************************************************}
const maxPar = 9;
      actPar: integer = 1;

procedure StartBurning (xl,yl: integer);

type  tPar = record min, max, value: integer end;

const par: array [1..maxPar] of tPar
      =((min:  0;   max: 50;   value: 10)   {0: rootRand}
       ,(min:  0;   max: 50;   value: 15)   {1: decay}
       ,(min: -2;   max: 10;   value: 10)   {2: moreFire}
       ,(min:  0;   max:  9;   value: 10)   {3: smooth}
       ,(min:  0;   max:100;   value: 10)   {4: minFire}
       ,(min:  3;   max: 90;   value: 10)   {5: fireInc}
       ,(min:  0;   max: 10;   value: 10)   {6: sparks}
       ,(min:  0;   max: 20;   value: 10)   {7: new fire}
       ,(min:  0;   max: 20;   value: 10)); {8: put water}

const maxX = 319;
      maxY = 199;
      bkColor = 16;

var   vga256: array[0..maxY,0..maxX] of byte absolute $A000:0;
      cb: char;

      rootRand,         {Max/Min decrease of the root of the flames}
      moreFire,         {change fire intensity}
      decay,            {How far should the flames go up on the screen ?}
      smooth,           {How descrete can the flames be?}
      minFire,          {limit between the "starting to burn" and
                         the "is burning" routines }
      fireIncrease,     {3 = Wood, 90 = Gazolin}
      sparks,           {new sparks per picture}
      newFlame,         {create new flame}
      putWater: integer;{put water to fire}

      x1,x2,y1,y2: integer;  {drawing rectangle}

{********************************************************}
procedure MakePal;

const maxColor = 110;

var   ni: integer;   pal: VGAPaletteType;

begin
  FillChar (pal, SizeOf (pal), 0);
  for ni := 1 to MaxColor
  do HSI2RGB (4.6-1.5*ni/MaxColor, ni/MaxColor, ni/MaxColor, pal[ni]);
  for ni := MaxColor to 255
  do begin
    pal[ni] := pal[ni-1];
    With pal[ni] do
    begin
      if R < 63 then Inc(R);
      if R < 63 then Inc(R);
      if (ni Mod 2=0) And (G<53) then Inc(G);
      if (ni Mod 2=0) And (B<63) then Inc(B);
    end;
  end;
  WritePal (pal);
end;

procedure DrawPaletteScreen;

var   xi, yi: integer;

begin
  MakePal;
  for yi := 0 to maxY
  do for xi := 0 to maxX do PutPixel (xi,yi,yi);
end;

procedure DrawValues;

var   ni, yi: integer;

begin
  for ni := 1 to maxPar
  do begin
    yi := succ(ni) * 3;
    FillChar (vga256[yi,100], 120, 0);
    with par[ni]
    do if actPar = ni
    then FillChar (vga256[yi,100], 1 + longint(value)*119 div 20, 100)
    else FillChar (vga256[yi,100], 1 + longint(value)*119 div 20,  50);
  end;
end;

procedure CalcValues;

begin
  with par[1] do rootRand     :=  min + value * (max - min) div 20;
  with par[2] do decay        :=  max - value * (max - min) div 20;
  with par[3] do moreFire     :=  min + value * (max - min) div 20;
  with par[4] do smooth       :=  min + value * (max - min) div 20;
  with par[5] do minFire      :=  min + value * (max - min) div 20;
  with par[6] do fireIncrease :=  min + sqr (value);
  with par[7] do sparks       :=  min + value * (max - min) div 20;
  with par[8] do newFlame     :=  max - value * (max - min) div 20;
  with par[9] do putWater     :=  max - value * (max - min) div 20;
end;

procedure ChangeValue;

begin
  cb := ReadKey;
  if cb = 'P' {down} then actPar := (actPar mod maxPar) + 1;
  if cb = 'H' {up}   then actPar := (actPar+maxPar-2) mod maxPar + 1;
  with par[actPar]
  do begin
    if cb = 'K' {left}  then if value >  0 then dec (value);
    if cb = 'M' {right} then if value < 20 then inc (value);
  end;
  CalcValues;
  DrawValues;
  cb := #1;
end;

procedure RandomValues;

var   ni: integer;

begin
  for ni := 1 to maxPar
  do par[ni].value := random(21);
  CalcValues;
  DrawValues;
end;

procedure AnimateValues;

var   ni: integer;

begin
  ni := 1 + random (maxPar);
  with par[ni]
  do if random (2) = 0
  then if value < 20 then inc (value) else
  else if value >  0 then dec (value);
  CalcValues;
  DrawValues;
end;

procedure ChangeSize (dx: integer);

var   yi: integer;

begin
  if (dx > 0) and (x1 - dx > 2)
  then repeat
    dec (x1);
    inc (x2);
    dec (dx);
    for yi := y1 to y2
    do begin
      PutPixel (x1,yi,0);
      PutPixel (x2,yi,0);
    end;
  until dx = 0;
  if (dx < 0) and (x1 - dx < 140)
  then repeat
    for yi := y1 to y2
    do begin
      PutPixel (x1, yi, bkColor);
      PutPixel (x2, yi, bkColor);
    end;
    inc (x1);
    dec (x2);
    inc (dx);
  until dx = 0;
  xl := x2 - x1 - 1;
end;


procedure Help;

begin
  SetVideoMode (3);          {TextMode}
  ClrScr;
  Info;
  Write ('Hit any key to start ');
  cb := ReadKey;
  SetVideoMode ($13);
  MakePal;
end;

const animValues: boolean = false;

var   flameArray: array[0..319] of byte;
      x,xi,y,c,v: integer;

begin
  x1 := (320 - xl) div 2;   x2 := x1 + xl - 1;
  y1 := (200 - yl) div 2;   y2 := y1 + yl - 1;
  Help;
  Randomize;

  FillChar (vga256, SizeOf(vga256), bkColor);
  FillChar (flameArray, SizeOf(flameArray), 0);
  for x := x1 to x2 do for y := y1 to y2 do PutPixel (x,y,0);
  CalcValues;
  pic := 0;
  repeat
    inc (pic);
    if KeyPressed then cb := upcase(ReadKey) else cb := #1;
    if cb = #0 then ChangeValue;
    while KeyPressed do ReadKey;  {empty keyboard buffer}

    {Put the values from flameArray on the bottom line of the screen}
    for x := x1 to x2 do PutPixel (x, y2, flameArray[x]);

    {This loop makes the actual flames}
    for xi := x1 to x2
    do begin
      if      xi = x1 then x := xi
      else if xi < x2 then x := xi - 1
      else                 x := xi - 2;
      for y := y1 + 1 to y2
      do begin
        v := GetPixel (xi,y);
        if (v = 0)
        or (v < decay)
{        then PutPixel (x,pred(y),0)
        else PutPixel (x-pred(Random(3)),Pred(y),v-Random(decay));
}       then vga256[pred(y),xi] := 0
        else vga256[pred(y),x+Random(3)] := v-Random(decay);
      end;
    end;

    for xi := 1 to sparks
    do begin
      x := x1 + random (xl);
      y := y2 - random (yl - 10);
      PutPixel (x,y, GetPixel (x,y)+y);
    end;

    if Random(newFlame) = 0       {new fire ?}
    then FillChar (flameArray[x1+Random(xl-5)],5,199);

    if Random(putWater)= 0        {put water ?}
    then FillChar (flameArray[x1+Random(xl-5)],3,0);

    if cb <> #1                   {check input ?}
    then begin
      if      cb = '+' then ChangeSize (+5)
      else if cb = '-' then ChangeSize (-5)
      else if cb = 'R' then RandomValues
      else if cb = ' ' then RandomValues
      else if cb = 'A' then animValues := not animValues
      else if cb = 'C' then FillChar (flameArray, SizeOf(flameArray),0)
      else if cb = 'W' then for x := 1 to xl div 10
                            do flameArray[x1+Random(xl)] := 0
      else if cb = '?' then Help
      else if cb = 'P' then DrawPaletteScreen;
    end;
    if animValues then AnimateValues;

    {This loop controls the "root" of the flames (values in flameArray)}
    for x := x1 to x2 do
    begin
      c := flameArray[x];
      if c < MinFire then    {Increase by the "burnability"}
      begin                  {Starting to burn:}
        if c > 10 then Inc (c, Random (fireIncrease));
      end
      else {Otherwise randomize and increase by intensity (is burning)}
        Inc (c, Random (rootRand * 2 + 1) - rootRand + moreFire);
      if c > 200 then c := 200;  {c too large ?}
      flameArray[x] := c;
    end;

    {Pour a little water on both sides of the fire
     to make it look nice on the sides}
    for x := 1 to xl div 8 do
    begin
      c := Trunc(Sqr(Random)*xl/8);
      flameArray[x1+c] := 0;
      flameArray[x2-c] := 0;
    end;

    {Smoothen the values of FrameArray to avoid "descrete" flames}
    for x := x1+Smooth to x2-Smooth do
    begin
      c := 0;
      for y := -Smooth to Smooth do Inc (c,flameArray[x+y]);
      flameArray[x] := c div (2*Smooth+1);
    end;
  until (cb = #27);
end;
{********************************************************}
var   lastMode: byte;

begin
  lastMode := GetVideoMode;  {save video mode}
  StartBurning (120, 100);   {fire simulation}
  SetVideoMode (lastMode);   {Restore video mode}
  Info;
end.
