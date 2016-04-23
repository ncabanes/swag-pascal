
{ SWAG NOTE :  Other unit and Demos at BOTTOM ! }

{
LCD.PAS
Written by Leopoldo Salvo Massieu, april 92. e-mail a900040@zipi.fi.upm.es
Freeware.

Written for Borland Pascal 7.0.

This units implement scalable lcd displays for numerical output in graphics mode.
Works in any graphic mode. Works in real and protected mode applications.

Restrictions: Digits must be at most 254 pixels wide horizontally
                (the digit width is equal to the width of the lcd display divided into the number of digits)
}

Unit LCD;
Interface
 Uses Graph;
     {Uses getmaxx,getmaxy,setcolor,putpixel,bar}

 Type PDisplay = ^Display;
      Display = object
                   private
                     xi,yi,xf,yf : integer;
                     num_cars : byte;
                     col_on, col_off : word;
                     graficos : array [1..9] of pointer;
                     tamano_graficos : array [1..9] of word;
                     buffer : array [1..40] of byte;
                     desbordado : boolean;
                   public

                     constructor init (x1,y1,x2,y2:integer;num_digits:byte;
                                     forecolor,backcolor:word);
   {coordinates of top-left and bottom-right corners, number of digits in the
    display (without counting the decimal point), and color of foreground and
    background}

                     destructor done;
   {Releases memory}

                     procedure display_string (cadena_num:string);
   {Writes a string (only numbers will be displayed)}

                     procedure display_real (ndecimals: integer; r:real);
   {Writes a real with n decimals (use 0 for integers)}

                     procedure redraw;
                end;

Implementation
  Const
    palotes_x_digito = 9; {7 segments for each digit, plus the decimal point and an overflow point at the top-left}
    no_error =  0;
  Type
    st40 = string[40];
    digi_font = (cero,uno,dos,tres,cuatro,cinco,seis,siete,ocho,nueve,e,desbordamiento,espacio,menos,punto);
              {these are all the characters that can be displayed ['0'..'9','E','-',' ', '.'].
               The '+' caracter is displayed as an space.}
    digi_palo = array[1..6] of pointtype;
              {each segment has at most 6 extremes (end points)}
    digi_data = array[1..palotes_x_digito] of record
                                               data:digi_palo;
                                               longitud: byte;
                                              end;
              {number of extremes and the extremes themselves for all segments}
    digi_masc = record              {esta es una forma de guardar los 'trozos' de digito en}
                 esq_si : pointtype;{memoria sin que ocupe demasiado espacio en memoria}
                 num_lin: byte;
                 datos : array[1..256] of record
                                           p,u:byte;
                                          end;
                end;
              {structure to keep the scaled segments in memory (only necessary mem allocated, tipycally <256)}
    digi_memo = array[1..palotes_x_digito] of ^digi_masc;
    digi_st   = array[1..40] of digi_font;
  Const
    {this codes what segments must be lighted for each character}
    caracteres : array[cero..punto,1..palotes_x_digito] of boolean =
                  ((true,true,true,false,true,true,true,false,false),      {cero/0}
                   (false,false,true,false,false,true,false,false,false),  {uno/1}
                   (true,false,true,true,true,false,true,false,false),     {dos/2}
                   (true,false,true,true,false,true,true,false,false),     {tres/3}
                   (false,true,true,true,false,true,false,false,false),    {cuatro/4}
                   (true,true,false,true,false,true,true,false,false),     {cinco/5}
                   (true,true,false,true,true,true,true,false,false),      {seis/6}
                   (true,false,true,false,false,true,false,false,false),   {siete/7}
                   (true,true,true,true,true,true,true,true,true),         {ocho/8}
                   (true,true,true,true,false,true,false,false,false),     {nueve/9}
                   (true,true,false,true,true,false,true,false,false),     {E}
                   (false,false,false,false,false,false,false,false,true), {desbordamiento/overflow}
                   (false,false,false,false,false,false,false,false,false),{espacio/space}
                   (false,false,false,true,false,false,false,false,false), {signo menos/'-'}
                   (false,false,false,false,false,false,false,true,false));{punto decimal/'.'}

    {this defines the edges of each segment, scaled to 1:80 vertically and 1::90 horizontally
             o#9      #1
                  ----------
              #2 /        /#3
                /   #4   /
               /--------/
           #5 /        / #6
             /   #7   /
            ----------   o #8
    }
    digitos : digi_data =
      (
        ({uno, el horizontal, arriba}
         data : ( (x:20;y:75), (x:26;y:80),
                  (x:78;y:80), (x:80;y:78),
                  (x:69;y:70), (x:28;y:70) );
         longitud : 6
        ),
        ({dos, vertical, izquierda y arriba}
         data : ( (x:19;y:73), (x:27;y:67),
                  (x:25;y:48), (x:18;y:43),
                  (x:15;y:45), (x:-1;y:-1) );
         longitud : 5
        ),
        ({tres, vertical, derecha y arriba}
         data : ( (x:80;y:75), (x:77;y:45),
                  (x:74;y:42), (x:67;y:47),
                  (x:69;y:67), (x:-1;y:-1) );
         longitud : 5
        ),
        ({cuatro, horizontal en el medio}
         data : ( (x:27;y:47), (x:63;y:47),
                  (x:71;y:41), (x:62;y:37),
                  (x:25;y:37), (x:20;y:42) );
         longitud :  6
        ),
        ({cinco, vertical, izquierda y abajo}
         data : ( (x:14;y:40), (x:17;y:42),
                  (x:22;y:36), (x:19;y:12),
                  (x:10;y:09), (x:-1;y:-1) );
         longitud : 5
        ),
        ({seis, vertical, derecha y abajo}
         data : ( (x:73;y:40), (x:75;y:37),
                  (x:70;y:03), (x:68;y:00),
                  (x:61;y:11), (x:64;y:36) );
         longitud :  6
        ),
        ({siete, horizontal, abajo}
         data : ( (x:21;y:10), (x:58;y:10),
                  (x:64;y:00), (x:13;y:00),
                  (x:10;y:05), (x:11;y:07) );
         longitud :  6
        ),
        ({ocho, punto decimal}
         data : ( (x:80;y:10), (x:90;y:10),
                  (x:89;y:00), (x:79;y:00),
                  (x:-1;y:-1), (x:-1;y:-1) );
         longitud : 4
        ),
        ({nueve, desbordamiento}
         data : ( (x:01;y:80), (x:11;y:80),
                  (x:10;y:70), (x:00;y:70),
                  (x:-1;y:-1), (x:-1;y:-1) );
         longitud : 4
        )
      );
constructor Display.init;
type
   mem_buffer = array[0..255,0..63] of byte;
     {temp. buffer for initialization}
var
   xinicial,yinicial:integer;
   resx,resy:real;
   t,l,n,digit:byte;
   si,id:pointtype;
   puntos : array [1..6] of pointtype;
   v_mem : ^mem_buffer;

procedure pon_mem_XY (x,y:byte);       {putpixel in temp. buffer to draw each segment}
var sx,ox:byte;
begin
  sx:=x div 8;ox:=x-sx*8;
  v_mem^[y,sx]:=v_mem^[y,sx] or (1 shl ox);
end;

function get_mem_XY (x,y:byte):boolean;  {getpixel from temp. buffer}
var sx,ox,comp:byte;
begin
  sx:=x div 8;
  ox:=x-(sx*8);   {faster than mod}
  comp:=1 shl ox;
  get_mem_XY:=(v_mem^[y,sx] and comp)=comp;
end;

procedure halla_extremos; {finds minimum area that covers a digit}
var a:byte;
begin
  si.x:=getmaxx;si.y:=getmaxy;id.x:=0;id.y:=0;
  for a:=1 to digitos[t].longitud do
     begin
       if (puntos[a].x<si.x) then si.x:=puntos[a].x;
       if (puntos[a].y<si.y) then si.y:=puntos[a].y;
       if (puntos[a].x>id.x) then id.x:=puntos[a].x;
       if (puntos[a].y>id.y) then id.y:=puntos[a].y;
     end;
end;

Procedure Linea_mem (X1,Y1,X2,Y2 : integer); {draws a line in temp. buffer}
var dx,x3,y3:integer; m:real;
begin
  if (x1>x2) then begin
                   x3:=x1;x1:=x2;x2:=x3;
                   y3:=y1;y1:=y2;y2:=y3;
                  end;
  if (x2<>x1) then
   begin
    m:=(Y2-Y1)/(X2-X1);
    for dx:=X1 to X2 do pon_mem_XY (dx,y1+round(m*(dx-X1)));
   end;
  if (y1>y2) then begin
                   x3:=x1;x1:=x2;x2:=x3;
                   y3:=y1;y1:=y2;y2:=y3;
                  end;
  if (y2<>y1) then
   begin
    m:=(X2-X1)/(Y2-Y1);
    for dx:=Y1 to Y2 do pon_mem_XY(x1+round(m*(dx-Y1)),dx);
   end;
end;
procedure graba_palote(pal:byte); {by now a segment is drawn in temp. buffer,
                                   the task is finding the first and last column
                                   for each row}
var
  lneas:byte;u,p:integer;
function primer_negro:byte; {primer_extremo}
var f:byte;
begin
  primer_negro:=255;
  for f:=si.x to id.x do
    if get_mem_XY(f,lneas) then begin primer_negro:=f;exit;end;
end;
function ultimo_negro:byte; {ultimo extremo}
var f:byte;
begin
  ultimo_negro:=255;
  for f:=p to id.x do
    if get_mem_XY (f,lneas) and not(get_mem_XY(f+1,lneas)) then ultimo_negro:=f;
end;

begin
  digi_masc(graficos[pal]^).num_lin:=id.y-si.y;
    {# of rows to scan}
  digi_masc(graficos[pal]^).esq_si:=si;
    {top-left corner of segment}
  for lneas:=si.y to id.y do
    begin
      p:=primer_negro;
      u:=ultimo_negro;
      digi_masc(graficos[pal]^).datos[lneas-si.y+1].p:=p-si.x;
      digi_masc(graficos[pal]^).datos[lneas-si.y+1].u:=u-si.x;
      {store segments in memory}
     end;
end;

begin
  if (x2<x1+num_digits*3) or (x2>x1+254*num_digits) or (y2<=y1+4) or (num_digits<1) then
   begin
    writeln ('Error: Invalid parameters: Area too small or number of digits<1');
    FAIL;
  end;
  xi:=x1;xf:=x2;yi:=y1;yf:=y2;col_on:=forecolor;col_off:=backcolor;num_cars:=num_digits;
  resx:=((x2-x1)/num_digits)*0.0111;
  resy:=(y2-y1)*0.0125;
   {Constants to scale digits}
  xinicial:=xi;
  yinicial:=yi;
  if (MaxAvail<sizeof(mem_buffer)) then
   begin
     writeln ('Out of memory creating lcd display. Initialization failed.');
     fail;
   end;
  new (V_mem); {gets temp. buffer}
  for t:=1 to palotes_x_digito do graficos[t]:=NIL;
  for t:=1 to palotes_x_digito do
    begin
     l:=digitos[t].longitud;
     fillchar (v_mem^,sizeof(mem_buffer),0);
     for n:=1 to l do
      begin
       puntos[n].x:=round(digitos[t].data[n].x*resx);
       puntos[n].y:=round(digitos[t].data[n].y*resy);
      end; {scales points...}
     halla_extremos; {find minimum area}
     tamano_graficos[t]:=5+(2*(id.y-si.y+1));{gets memory to copy coded scaled segments}
     if (MaxAvail<tamano_graficos[t]) then
      begin
       writeln ('Out of memory creating lcd display. Initialization failed.');
       done;
       fail;
      end;
     getmem(graficos[t],tamano_graficos[t]);
     for n:=1 to l do
        linea_mem (puntos[n].x,puntos[n].y,puntos[(n mod l)+1].x,puntos[(n mod l)+1].y);
       {draws segment in memory}
     graba_palote(t);
       {copy segment to memory}
    end;
   dispose (V_mem); {release temp buffer}
   fillchar (buffer,sizeof(buffer),espacio); {nothing written in display}
end;

destructor display.done;
var pal : integer;
begin
   display_string ('');
   for pal:=1 to palotes_x_digito do
    if (graficos[pal]<>NIL) then freemem (graficos[pal], tamano_graficos[pal])
end;


Procedure display.display_string;
var
  resx:real;xinicial,yinicial:integer;f,digit:byte;cr:digi_font;
  cadena:digi_st;pdecs:byte;
const
  blancos :st40 = '                                       ';

procedure barrotes(barrote:byte;encendido:boolean); {draws a segment}
var lineas:byte;
    color :word;
begin
  if encendido then color:=col_on
               else color:=col_off; {segment colour}
  setcolor (color);
  for lineas:=1 to digi_masc(graficos[barrote]^).num_lin do
      if (digi_masc(graficos[barrote]^).datos[lineas].p<>255) then
       line (xinicial+digi_masc(graficos[barrote]^).esq_si.x+digi_masc(graficos[barrote]^).datos[lineas].p,
             yinicial-digi_masc(graficos[barrote]^).esq_si.y-lineas,
             xinicial+digi_masc(graficos[barrote]^).esq_si.x+digi_masc(graficos[barrote]^).datos[lineas].u,
             yinicial-digi_masc(graficos[barrote]^).esq_si.y-lineas);
  {actually draws the segment, scaning rows in memory}
end;

Procedure get_font_str(var res:digi_st); {conversion from string to displayable font}
var f:byte;cr:char;
begin
  for f:=1 to byte(cadena_num[0]) do
    case cadena_num[f] of
     'E' : res[f]:=E;
     ' ' : res[f]:=espacio;
     '-' : res[f]:=menos;
     '.' : res[f]:=punto;
     '+' : res[f]:=espacio;             {'+' is not representable}
    else
           res[f]:=digi_font(BYTE(cadena_num[f])-48);
   end;
end;

procedure display(caracter:digi_font); {displays a character}
var g:byte;
begin
  xinicial:=xi+round(digit*resx);
  if (caracter=punto) then barrotes (8,true)
  else
  if (caracter=desbordamiento) then barrotes (9,true)
  else
   begin
    inc(digit);   {# of digit}
    for g:=1 to 7 do
       if (caracteres[caracter,g]<>caracteres[digi_font(buffer[f]),g])
           then barrotes (g,caracteres[caracter,g]);
          {only draws a segment if it has changed}
   end;
end;

procedure borra_desborde;  {erases overflow}
begin
  barrotes (9,false);
end;
procedure borra_punto;  {erases decimal point}
begin
  barrotes (8,false);
end;

function num_puntos:byte;
var a,res:byte;
begin
  res:=0;
  for a:=1 to ord(cadena_num[0]) do if cadena_num[a]='.' then inc(res);
  num_puntos:=res;
end;

begin {proc. display}
  digit:=0; {digitos escritos}
  resx:=(xf-xi)/num_cars;
  yinicial:=yf;
  if desbordado then
   begin
    borra_desborde;
     {erases overflow}
    desbordado:=false;
   end;
  pdecs:=num_puntos;
  if (length(cadena_num)-pdecs<num_cars)
       then
         cadena_num:=copy(blancos,1,pdecs+num_cars-length(cadena_num))+cadena_num
  else
  if (length(cadena_num)-pdecs>num_cars)
       then
        begin
         desbordado:=true;
         cadena_num:=copy(cadena_num,(1+length(cadena_num)-num_cars),num_cars);
        end;
  get_font_str (cadena);
  for f:=1 to num_cars+pdecs do
   begin                 {all characters}
    cr:=cadena[f];
    if (cr<>punto) then
    begin
     {updates decimal point}
     if (digi_font(buffer[f+1])=punto) then
       begin
        if not(cadena[f+1]=punto) then borra_punto
       end
      else
        if (cadena[f+1]=punto) then display (punto);
     if (cr=digi_font(buffer[f]))
       then inc(digit)
       else
        begin
          {only draws a character if it's changed}
          display(cadena[f]);
          buffer[f]:=byte(cr);
        end;
    end;
   end;
  digit:=0; {el signo de desbordamiento se encuentra incluido en el primer digito}
  if desbordado then display(desbordamiento);
  {set overflow if necessary}
end;

Procedure display.display_real;
var cad : STRING;
begin
  if (ndecimals+1>=num_cars) then ndecimals:=num_cars-2;
  str (r:num_cars-ndecimals-1:ndecimals, cad);
  display_string (cad);
end;

Procedure display.redraw;
var cad : st40;
    i : integer;
begin
   cad[0]:=char(num_cars);
   for i:=1 to num_cars do
     case digi_font(buffer[i]) OF
       E: cad[i]:='E';
       espacio: cad[i]:=' ';
       menos: cad[i]:='-';
       punto: cad[i]:='.';
     else
       cad[i]:=CHAR(48+buffer[i]);
    end;
   fillchar (buffer, sizeof(buffer), espacio);
   display_string (cad);
end;

end.

{ ---------  UNIT NEED FOR THIS SNIPET ----------------------- }
Unit inisvga;
interface
 uses Crt,Graph;
 var
   v : byte;
   OldExitProc : Pointer;  { Saves exit procedure address }
   graphdriver,graphmode,errorcode:integer;
   PathToDriver   : string[80];  { Stores the DOS path to *.BGI & *.CHR }
 const
   edit            = 0;
   vga320x200x256  = 1;
   svga640x400x256 = 2;
   svga640x480x256 = 3;
   svga1024x768x256= 4;
   ega640x350x16   = 5;
   herc720x348x2   = 6;

  Procedure Graficos(modo_grafico:byte);
  Procedure Cierragraficos;
  Procedure Dimensiones (Var horizontal, vertical: INTEGER);

implementation
var
   err:integer;

procedure Cierragraficos;
begin
   closegraph;
end;

{$F+}
procedure MyExitProc;
begin
  ExitProc := OldExitProc; { Restore exit procedure address }
  CloseGraph;              { Shut down the graphics system }
end; { MyExitProc }
{$F-}
{$F+}
function DetectVGA256 : integer;
{ Detects VGA or MCGA video cards }
var
  DetectedDriver : integer;
  SuggestedMode  : integer;
begin
  DetectGraph(DetectedDriver, SuggestedMode);
  if (DetectedDriver = VGA) or (DetectedDriver = MCGA) then
    DetectVGA256 := v        { Default video mode = 0 }
  else
    DetectVGA256 := grError; { Couldn't detect hardware }
end; { DetectVGA256 }
{$F-}

var
  AutoDetectPointer : pointer;


function Inicializa_svga:byte;
{ Initialize graphics and report any errors that may occur }
var
  InGraphicsMode : boolean; { Flags initialization of graphics mode }
begin
  { when using Crt and graphics, turn off Crt's memory-mapped writes }
  DirectVideo := False;
  OldExitProc := ExitProc;                { save previous exit proc }
  ExitProc := @MyExitProc;                { insert our exit proc in chain }
  repeat

    AutoDetectPointer := @DetectVGA256;   { Point to detection routine }
    GraphDriver := InstallUserDriver('SVGA256', AutoDetectPointer);
    GraphDriver := Detect;

    InitGraph(GraphDriver, Graphmode, PathToDriver);
    ErrorCode := GraphResult;             { preserve error return }
    inicializa_svga:=grok;
    if ErrorCode <> grOK then             { error? }
    begin
      Writeln('Graphics error: ', GraphErrorMsg(ErrorCode));
      if ErrorCode = grFileNotFound then  { Can't find driver file }
      begin
        Writeln('Enter full path to BGI driver or type <Ctrl-Break> to quit:');
        Readln(PathToDriver);
        Writeln;
      end
      else
        inicializa_Svga:=grok;
    end;
  until ErrorCode = grOK;
  Randomize;                { init random number generator }
end; { Initialize }

procedure Graficos(modo_grafico:byte);
var  ch:char;
procedure egadriver;
begin
    graphdriver:=EGA;
    graphmode:=EGAHi;
    InitGraph(graphdriver,graphmode,'');
    Err := GraphResult;
    if Err <> grOk then WriteLn('Graphics error:',GraphErrorMsg(Err));
    modo_grafico:=ega640x350x16;
end;
procedure Hercules;
begin
     graphdriver:=hercmono;
     graphmode:=hercmonohi;
     InitGraph(graphdriver,graphmode,'');
     Err := GraphResult;
     if Err <> grOk then WriteLn('Graphics error:',GraphErrorMsg(Err));
     modo_grafico:=herc720x348x2;
end;
begin
  if (modo_grafico<1) or (modo_grafico>6) then
   begin
    window (20,8,60,16);
    clrscr;
    Writeln ('       Modos gráficos');
    writeln;
    Writeln ('1 - VGA 320x200 256 colores');
    Writeln ('2 - SVGA 600x480 256 colores');
    Writeln ('3 - SVGA 640x480 256 colores');
    Writeln ('4 - SVGA 1024x768 256 colores');
    Writeln ('5 - EGA 640x350 16 colores');
    Writeln ('6 - Hercules mono');
    err:=-1;
    Repeat
      ch:=readkey;
      case ch of
      '1' : begin v:=0; modo_grafico:=vga320x200x256;  err:=inicializa_svga; end;
      '2' : begin v:=1; modo_grafico:=svga640x400x256; err:=inicializa_svga; end;
      '3' : begin v:=2; modo_grafico:=svga640x480x256; err:=inicializa_svga; end;
      '4' : begin v:=3; modo_grafico:=svga1024x768x256;err:=inicializa_svga; end;
      '5' : egadriver;
      '6' : hercules;
      end;
    Until (err=grOk);
   end
  else
   begin
    if (modo_grafico=ega640x350x16) then egadriver
    else
    if (modo_grafico=herc720x348x2) then hercules
    else
    if (modo_grafico=vga320x200x256) then
         begin v:=0;err:=inicializa_svga; end
    else
    if (modo_grafico=svga640x400x256) then
         begin v:=1;err:=inicializa_svga; end
    else
    if (modo_grafico=svga640x480x256) then
         begin v:=2; err:=inicializa_svga; end
    else
    if (modo_grafico=svga1024x768x256) then
         begin v:=3;err:=inicializa_svga; end;
   end;
end;

Procedure dimensiones (Var horizontal, vertical: INTEGER);
begin
  horizontal:=Getmaxx;
  vertical:=Getmaxy;
end;

begin
  PathToDriver := 'D:\bp\bgi';
end.


{ --------------------------   DEMO  -----------------------  }
Program DemoLCD;
{
   Demo for LCD unit, keeps drawing ellipses until a key is pressed.
   There's a LCD that counts the number of ellipses drawn.

   Leopoldo Salvo, e-mail a900040@zipi.fi.upm.es
}
Uses Inisvga,Crt,Graph,Lcd;  { unit INISVGA found at the bottom !! }

Var
  i, numero:word;
  xq,yq,rx,ry,x,y,maxcolor,maxx,maxy:integer;
  n_str: string;
  graphdriver,graphmode,error:integeR;
  v1 : ^Display;
  ch : char;
begin
   graficos (edit);
   maxcolor:=256;maxx:=getmaxx;maxy:=getmaxy;numero:=0;
   xq:=maxx div 6;
   yq:=maxy div 10;  {constants for centering stuff}
   new (v1, init (xq,0,5*xq,2*yq,4,15,0));
   {creates and initializes lcd display, digits are white(#15) over black(#0) background}
   if (v1=NIL) then
    begin
     writeln ('Error creating lcd displays, exiting...');
     halt;
    end;
   maxx:=maxx-2*xq;
   maxy:=maxy-4*yq;
   setcolor (15);
   line (xq-4,3*yq-4,5*xq+4,3*yq-4);
   line (5*xq+4,3*yq-4,5*xq+4,9*yq+10);
   line (5*xq+4,9*yq+10,xq-1,9*yq+10);
   line (xq-4,9*yq+10,xq-4,3*yq-4);
   repeat
     setcolor (maxcolor+1);
     x:=random(maxx);
     y:=random(maxy);
     if (x<maxx div 2) then rx:=random(x)
     		       else rx:=random(maxx-x);
     if (y<maxy div 2) then ry:=random(y)
     		       else ry:=random(maxy-y);
     setfillstyle (solidfill,random(maxcolor));
     fillellipse (xq+x,3*yq+y,rx,ry);
     inc(numero);
     v1^.display_real (0, numero);               {updates counter lcd}
   until keypressed;
   dispose (v1, done);
   closegraph;
   ch:=readkey;
end.

{ --------------------------   DEMO  -----------------------  }

{
Demo for LCD unit.

Leopoldo Salvo Massieu, e-mail a900040@zipi.fi.upm.es

A rather artistic lcd display show.
}

Program demolcd3;

uses crt,graph,lcd;
var
  graphdriver,graphmode,err:integer;
  a:byte;
  rx,ry:real;
  maxcol,c: byte;
  s:string;
  v:array[1..6] of ^display;
const
  tiempo= 350;

procedure abre (xi,yi,xf,yf,n,c1,c0,w:byte);
begin
   new (v[w], init (round(xi*rx),round(yi*ry),round(xf*rx),round(yf*ry),n,c1,c0));
   if (v[w]=NIL) then
    begin
      writeln ('Error creating lcd display... halting program...');
      halt;
    end;
enD;
procedure pon (num:byte);
begin
   v[num]^.display_string (char(48+num));
   delay (tiempo);
   v[num]^.display_string (' ');
end;

begin
   graphdriver:=detect;
   graphmode:=0;
   initgraph (graphdriver,graphmode,'');
   err:=graphresult;
   if err<>grok then
       begin
        writeln ('had trouble opening graphic mode (probably egavga.bgi not found)',grapherrormsg(err));
        exit;
       end;
  rx:=getmaxx*0.01;
  ry:=getmaxy*0.01;
  maxcol:=getmaxcolor;

  Abre (5,20,25,40,1,30,0,1);
  Abre (43,5,77,18,1,25,0,2);
  Abre (85,25,100,75,1,23,0,3);
  Abre (72,60,93,81,1,4,0,4);
  Abre (36,69,72,85,1,56,0,5);
  Abre (12,44,36,75,1,98,0,6);
  Repeat
    for a:=1 to 6 do pon (a);
    Until keypressed;
  for a:=1 to 6 do dispose (v[a], done);
  closegraph;
end.
