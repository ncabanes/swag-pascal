(* this one is a small unit creating (up to 10) virtual screens in RAM. It's
   some kind of thrown-together code, so feel free to optimize it somehow.
   the viewer could be done using linked lists, for instance... :-)
   The unit is absolutely FREE. You are not even asked for crediting me...
   I donate it to SWAG.

   If you optimized it, please re-donate it to SWAG, so we can ALL
   have the profits.

   Done by KLAUSI, (aka Steffen Unger)
   contact:
           NICK'S BOX - +49 3741 223617
           e-mail     - systemklaus@t-online.de
           snail mail - Steffen Unger
                        Baerenstr. 9
                        D-08523 Plauen
                        GERMANY
   Have fun!

   PS. Sorry for the partly German remarks, i was too lazy to
   translate them all ;-)
*)






{$M 8192,0,655300}
{$G+,X+}
unit vscreen;
interface

uses dos,crt;

type vptr=^vs; {pointer to a virtual screen}
     vs=array[0..3999] of byte; {one screen}

     vpa=array[0..9] of vptr; {10 virtual screens}

     s80=string[80]; {common type for one string, that fits 80x25}

     pwin=^twin; {pointer to a window-data-record}
     twin=record
      closerpos:shortint;
      typ,rahmen:byte; {typ  = position of title, rahmen=frame type
                               (see definition below)}
      l,o,br,ho:shortint;  {l/o  = upper left corner of the window,
                        br/ho= width/height of window}
      raf,arbf,
      titf,shadf:byte; {raf/arbf/titf/shadf=
                        frame-workarea-title-shadow colors}
      titel:s80;       {titel = title}
      shadow:boolean;  {should the window be shadowed ?}
      ismove,isresize:boolean;
     end;

CONST VGA:BOOLEAN=TRUE;         {TRUE, if a VGA present}
      MONO:BOOLEAN=TRUE;        {TRUE if there is a mono display?}
      nkey:char=#0;             {dummy for function keys read by readkey}
      ismaus:boolean=false;     {is there a mouse connected ?}
      tmaxwin=15;               {max. count of windows. play with it...}
      isblink:boolean=true;     {high background active?}

var ms:vpa; {holds the virtual screens in ram}
    savecurs:word; {last cursor-size}
    winds:array[0..tmaxwin] of pwin; {array of tmaxwin+1 records(TWIN)}
    maxwin,aktwin:byte; {maxwin = count of windows stored
                         aktwin = current window-number}
    mx,my:word;         {mouse-coordinates}
    but:byte;           {mousebutton # pressed}

{Procedures}

procedure waitms(x:word);      {machine independent delay}
function up(ch:char):char;     {"GERMAN" upcase}
function ups(s:String):string; {"GERMAN" string-upcase}
function readkey:char;         {replacement of crt.rreadkey, which misses
                                some keys}
procedure retrace;             {wait for retrace}
procedure checkvga;            {checks presence of vga and sets VGA and MONO}
procedure newscn(nr:byte);     {get a new screenpointer}
procedure getscn(nr:byte);     {get a new scnpointer and copy scn currently shown}
procedure copyscn(fromscn,toscn:byte); {copy pages in virtual scn-area}
procedure clearscn(nr,color:byte); {clear one virtual screen using color COLOR}
procedure putscn(nr:byte);  {put screen NR onto the monitor}
procedure killscn(nr:byte); {frees the memory used by one vscreen(NR)}
procedure freescn(nr:byte); {re-displays the screen (NR) and then kills it}
procedure blinken(an:boolean); {if VGA then switches bright background (TRUE=ON)}
procedure cursor(an:boolean);  {shows (TRUE) or hides (FALSE) the cursor}
function vcol(color:byte):byte; {this manages the colors shown, if VGA and blink or MONO...}
function z(x,y:byte):integer;     {returns the location of a single CHAR in vscn-array}
function f(x,y:byte):integer;     {does the same for the attribute}
procedure print(nr,x,y,farbe:byte;s:string); {puts a string into vscreen-ram.
                                             if farbe < $ff then the color is set too.}
procedure balken(nr,x,y,l,farbe:byte); {changes the color of a line in vscn(NR), starting
                                       at x,y and running over length(L)}
function rp(c:char;cnt:byte):s80; {expands char (C) into a string of length(CNT)}
procedure window(anr,nr:byte); {puts SAVED! window nr(ANR) into screen (NR)}
{,typ,rahmen,l,o,br,ho,raf,arbf,shadf,titf:byte;
                 titel:s80;shadow:boolean);}
procedure vsinit; {initialises ALL vscreens (0..9).}
procedure vsfree; {frees ALL (0..9) vscreens}
procedure winsave(anr,typo,rahme:byte;li,ob,brt,hoh:byte;ra,arb,shad,tit:byte;titl:s80;sha:boolean;mv,res:boolean);
{creates a new entry in the windows list, which can be displayed later}
procedure hwin(nr,typ,rahmen,l,o,br,ho,raf,arbf,shadf,titf:byte;titel:s80;shadow:boolean);
{creates an UNSAVED window in screen (ANR), for help or so...}
procedure winget(nr,vnr:byte;all:boolean); {activates window(NR) on vscreen(VNR)}
procedure winwrite(ys,nr,snr,color:byte;s:string); {write a string into window}
procedure winkill(nr:byte); {kill window-record(NR) from heap}
procedure minit; {init mouse and set ISMAUS.}
procedure weg;   {HIDE mouse pointer}
procedure zeig;  {SHOW mouse pointer}
function mausx:integer; {x-coordinate of the mouse}
function mausy:integer; {y-coordinate of the mouse}
function button:byte;{number of the button pressed}
function mausxy(l,o,r,u:word):boolean; {check range(L,O,R,U) if mouse is within}
procedure mauspos(x,y:word); {set x,y-position of mouse-pointer}
procedure mausbereich(l,o,r,u:word); {shrink mouse-range to (L,O,R,U)}

{these parts depend on the simple textviewer}

const tmaxzeilen=2500;  {since one string is max 159 chars long,max-lines=2500}
      xoffs:byte=0;     {number of char in string to be shown leftmost (for horizontal scroll)}

type zp=^zeile;         {pointer to ONE line}
     zeile=string[159];  {Max: 159 chars= 160 bytes}
     zeilen=array[1..tmaxzeilen] of zp;
     {line-array, which holds all lines read}

var tf:text; {textfile to read}
    zmax,zakt:integer; {ZMAX=number of lines read, ZAKT=current startline in display-range.}
    ch:char; {key pressed}
    ze:zeilen; {here are the lines read}
    tcol:byte; {color for text-display}


function doxor(s:string):string; {a very simple en-/decoding algorithm (XOR 13)}
function readin(f:string):boolean; {read textfile into array(ZEILEN). False if failed}
procedure display(nr,pxpos,x,ys,zrange,color:byte;mitxor:boolean);
{this is the viewer thng.NR=number of vscreen to write to,
 pxpos= xposition of line-counter,
 x,sy = leftmost/uppermost startposition of display,
 zrange = nomber of lines to display in window,
 color = display-color,
 mitxor = TRUE, if the text is encoded using DOXOR and should be
          decoded in viewer.}
procedure cleanup; {frees memory used by ZEILEN}


implementation

procedure retrace; assembler;
asm
  mov dx,3dah
 @vert1:
  in al,dx
  test al,8
  jz @vert1
 @vert2:
  in al,dx
  test al,8
  jnz @vert2
end;


procedure minit;
begin asm mov ismaus,1;mov ax,0;int 33h;cmp ax,0;jz @nixmaus;jmp @raus;
@nixmaus: mov ismaus,0;@raus: end end;

procedure weg;
begin asm mov ax,2;int 33h end end;

procedure zeig;
begin asm mov ax,1;int 33h end end;

function mausx:integer;
begin asm mov ax,3;int 33h;shr cx,3;mov @result,cx end end;

function mausy:integer;
begin asm mov ax,3;int 33h;shr dx,3;mov @result,dx end end;

function button:byte;
begin asm mov ax,3;int 33h;mov @result,bl end end;

function mausxy(l,o,r,u:word):boolean;
var mx,my:word;
begin mx:=mausx;my:=mausy;mausxy:=((mx>=l) and (mx<=r)) and ((my>=o) and (my<=u));end;

procedure mauspos(x,y:word);
begin asm mov ax,4;mov cx,x;mov dx,y;shr cx,3;shr dx,3; int 33h;end end;

procedure mausbereich(l,o,r,u:word);
begin
 asm mov ax,7;mov cx,l;mov dx,r;shr cx,3;shr dx,3;int 33h;
     mov ax,8;mov cx,o;mov dx,u;shr cx,3;shr dx,3;int 33h end;
end;


procedure waitms(x:word);assembler;
asm           { delay.. }
 mov ax,x;mov bx,1000;mul bx;mov cx,dx;mov dx,ax;mov ax,$8600;int $15
end;

function up(ch:char):char;
var cc:char;
begin
 case ch of
  'ä':cc:='Ä';
  'ö':cc:='Ö';
  'ü':cc:='Ü';
 else cc:=upcase(ch);
 end;
 up:=cc;
end;

function ups(s:String):string;
var l:byte;ss:string;
begin ss:='';for l:=1 to length(s) do ss:=ss+up(s[l]);ups:=ss; end;

function altpressed:boolean;
begin altpressed:=(mem[$0:$417] and 8 = 8);end;


function readkey:char;
var res,nk:byte;
begin
  if nkey<>#0 then begin
   readkey:=nkey;nkey:=#0;exit;
  end;
  asm
   mov nk,0
   mov ah,$10
   int 16h
   cmp al,0
   jz @fkey
   cmp al,$e0
   jz @fkey
   mov res,al
   jmp @raus
 @fkey:
   mov res,0
   mov nk,ah
 @raus:
  end;
  nkey:=chr(nk);
  readkey:=chr(res);
end;


PROCEDURE CheckVga;
VAR r:REGISTERS;
BEGIN
  r.ax:=$1a00; {Funktion 26 des Interrupts 16 (Bildschirmsteuerung).}
  intr($10,r);
  VGA:=(r.al=$1a) AND (r.bl in [4,5,7,8]);
  {Gibt die Funktion 26 zurück, ist eine EGA/VGA Karte vorhanden.
   Die Werte 4,5,7,8 geben an, ob ein Schwaz/Weiß ode Farbbilschirm
   angeschlossen ist.}
  IF VGA THEN
    {Ist eine EGA/VGA da, gilt: bei Werten 5 und 7 existiert ein
     Schwarz/Weiß - Monitor.}
    MONO:=((r.bl=5) OR (r.bl=7))
  ELSE
    {Ist keine VGA da, bedeutet LASTMODE=7: Monochrommonitor}
    MONO:=(mem[0:$449]=7);
END;

FUNCTION VSeg:WORD;
BEGIN
  VSeg:=$b800;
  IF mem[0:$449]=7 THEN
    VSeg:=$b000;

END;

procedure newscn(nr:byte);
begin
 if nr>9 then exit;
 new(ms[nr]);
end;

procedure getscn(nr:byte);
begin
 if nr>9 then exit;
 new(ms[nr]);
 move(ptr(vseg,0)^,ms[nr]^,4000);
end;

procedure copyscn(fromscn,toscn:byte);
begin
 if fromscn>9 then begin move(ptr(vseg,0)^,ms[toscn]^,4000);exit end;
 if toscn>9 then begin move(ms[fromscn]^,ptr(vseg,0)^,4000);exit end;
 move(ms[fromscn]^,ms[toscn]^,4000);
end;

procedure clearscn(nr,color:byte);
var z,s:byte;fw:word;
begin
 fw:=$2000 or color;
 for z:=0 to 24 do
  for s:=0 to 80 do memw[seg(ms):(z+s)]:=fw
end;

procedure putscn(nr:byte);
begin
 retrace;
 move(ms[nr]^,ptr(vseg,0)^,4000)
end;

procedure killscn(nr:byte);
begin
 dispose(ms[nr])
end;

procedure freescn(nr:byte);
begin
 putscn(nr);killscn(nr)
end;


PROCEDURE Blinken(an:BOOLEAN);
BEGIN
  IF NOT VGA THEN Exit;
  asm
    mov ax,$1003
    mov bl,an
    int 10h
  end;
  isblink:=an;
END;

PROCEDURE Cursor(an:BOOLEAN);
BEGIN
  IF NOT an THEN
  asm
    mov ax,$0300
    int 10h
    mov SaveCurs,cx
    mov ax,$0100
    mov cx,$2000
    int 10h
  end
  ELSE
  asm
    mov ax,$0100
    mov cx,SaveCurs
    int 10h
  end
End;

function vcol(color:byte):byte;
begin
 vcol:=color;
 if not(vga) or (isblink) then color:=color and $7f;
 if mono then begin
  if color and $ff>$f then color:=70;
  if color and $ff>7 then color:=$F;
  if color and $ff<8 then color:=$7
 end;
 vcol:=color
end;

FUNCTION Z(x,y:BYTE):integer;
BEGIN
  Z:=((Pred(y)*160)+(x SHL 1)-2);
END;

FUNCTION F(x,y:BYTE):integer;
BEGIN
  F:=Succ(Z(x,y));
END;

procedure print(nr,x,y,farbe:byte;s:string);
var l:byte;
begin
 for l:=1 to length(s) do begin
  if nr>9 then
   mem[vseg:z(x+pred(l),y)]:=ord(s[l])
  else
   ms[nr]^[z(x+pred(l),y)]:=ord(s[l]);
  if farbe<>$ff then begin
   farbe:=vcol(farbe);
    if nr>9 then
     mem[vseg:f(x+pred(l),y)]:=farbe
    else
     ms[nr]^[f(x+pred(l),y)]:=farbe
  end
 end
end;

procedure balken(nr,x,y,l,farbe:byte);
var bl:byte;
begin
 for bl:=0 to pred(l) do begin
   farbe:=vcol(farbe);
    if nr>9 then
     mem[vseg:f(x+bl,y)]:=farbe
    else
     ms[nr]^[f(x+bl,y)]:=farbe
 end
end;

FUNCTION RP(c:CHAR;cnt:BYTE):S80;
VAR s:S80;b:BYTE;
BEGIN
  s:='';
  FOR b:=1 TO cnt DO s:=s+c;
  RP:=s
END;

procedure hwin(nr,typ,rahmen,l,o,br,ho,raf,arbf,shadf,titf:byte;titel:s80;shadow:boolean);
var ro:byte;oho,lrm:byte; titlepos,dc:byte;
const rahf:array[0..4,0..10] of char=
      ((' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),
       ('╔','═','╗','║','╚','╝','╠','╣','╟','╢','─'),
       ('╒','═','╕','│','╘','╛','╞','╡','├','┤','─'),
       ('╓','─','╖','║','╙','╜','╟','╢','╠','╣','═'),
       ('┌','─','┐','│','└','┘','├','┤','╞','╡','═'));

begin
  dec(br);dec(ho);
  titlepos:=o;oho:=o+ho;lrm:=l+br;
  print(nr,l,o,vcol(raf),rahf[rahmen,0]+rp(rahf[rahmen,1],pred(br))+rahf[rahmen,2]);
  if rahmen>0 then print(nr,l+2,o,raf and $f7,' ≡ ');
  for ro:=succ(o) to o+pred(ho) do begin
   print(nr,l,ro,vcol(raf),rahf[rahmen,3]);print(nr,l+br,ro,vcol(raf),rahf[rahmen,3]);
   print(nr,succ(l),ro,vcol(arbf),rp(' ',pred(br)))
  end;
  print(nr,l,o+ho,raf,rahf[rahmen,4]+rp(rahf[rahmen,1],pred(br)));
  print(nr,l+br,o+ho,raf and $f7,rahf[rahmen,5]);
  {Titel / Typart}
  if (titel<>'') and (br>length(titel)+4) then
  case typ of
   0:print(nr,l+(br shr 1)-succ(length(titel) shr 1)+1,titlepos,titf,' '+ups(titel)+' ');
   1:begin  {Titel in Zeile 2 und Rahmen ╠═╣}
       inc(titlepos);if ho>2 then
       print(nr,l,succ(titlepos),raf,rahf[rahmen,6]+rp(rahf[rahmen,1],
       pred(br))+rahf[rahmen,7]);
      if ho>1 then begin
       print(nr,succ(l),titlepos,titf,rp(' ',pred(br)));
       print(nr,l+(br shr 1)-succ(length(titel) shr 1)+1,titlepos,$ff,' '+ups(titel)+' ')
      end
     end;
   2:begin {Titel in Zeile 2 und Rahmen ╟─╢}
      inc(titlepos);if ho>2 then
       print(nr,l,succ(titlepos),vcol(raf),rahf[rahmen,8]+rp(rahf[rahmen,10],
       pred(br))+rahf[rahmen,9]);
      if ho>1 then begin
       print(nr,succ(l),titlepos,titf,rp(' ',pred(br)));
       print(nr,l+(br shr 1)-succ(length(titel) shr 1)+1,titlepos,$ff,' '+ups(titel)+' ')
      end
     end;
   3:begin {Titel in Zeile 2 und Rahmen ║ ═ ║}
       inc(titlepos);if ho>2 then
       print(nr,succ(l),succ(titlepos),raf,' '+rp(rahf[rahmen,1],br-3)+' ');
      if ho>1 then begin
       print(nr,succ(l),titlepos,titf,rp(' ',pred(br)));
       print(nr,l+(br shr 1)-succ(length(titel) shr 1)+1,titlepos,$ff,' '+ups(titel)+' ')
      end
     end;
   4:begin {Titel in Zeile 2 und Rahmen ║ ─ ║}
       inc(titlepos);if ho>2 then
       print(nr,succ(l),succ(titlepos),raf,' '+rp(rahf[rahmen,10],br-3)+' ');
      if ho>1 then begin
       print(nr,succ(l),titlepos,titf,rp(' ',pred(br)));
       print(nr,l+(br shr 1)-succ(length(titel) shr 1)+1,titlepos,$ff,' '+ups(titel)+' ')
      end
     end
  end;
  dc:=0;
  if shadow then begin
   dc:=succ(o);
   if (lrm<79) then
   for ro:=dc to succ(o+ho) do begin
    if (ro<26) then
     balken(nr,succ(l+br),ro,2,vcol(shadf));
   end;
   if lrm<80 then
    for ro:=dc to succ(o+ho) do begin
     if (ro<26) then
      balken(nr,succ(l+br),ro,1,vcol(shadf));
    end;
   if oho<25 then balken(nr,l+2,succ(o+ho),pred(br),vcol(shadf))
  end
end;


procedure window(anr,nr:byte);
var ro,brr,hoh,oho,lrm:byte; titlepos,dc:byte;
const rahf:array[0..3,0..10] of char=
      (('╔','═','╗','║','╚','╝','╠','╣','╟','╢','─'),
       ('╒','═','╕','│','╘','╛','╞','╡','├','┤','─'),
       ('╓','─','╖','║','╙','╜','╟','╢','╠','╣','═'),
       ('┌','─','┐','│','└','┘','├','┤','╞','╡','═'));

begin
 with winds[anr]^do begin
  brr:=pred(br);hoh:=pred(ho);oho:=o+hoh;lrm:=l+brr;
  titlepos:=o;
  print(nr,l,o,raf,rahf[rahmen,0]+rp(rahf[rahmen,1],pred(brr))+rahf[rahmen,2]);
  if rahmen>0 then print(nr,closerpos,o,raf and $f7,' ≡ ');
  for ro:=succ(o) to o+pred(hoh) do begin
   print(nr,l,ro,raf,rahf[rahmen,3]);print(nr,l+brr,ro,vcol(raf),rahf[rahmen,3]);
   print(nr,succ(l),ro,arbf,rp(' ',pred(brr)))
  end;
  print(nr,l,o+hoh,raf,rahf[rahmen,4]+rp(rahf[rahmen,1],pred(brr)));
  print(nr,l+brr,o+hoh,raf and $f7,rahf[rahmen,5]);
  {Titel / Typart}
  if (titel<>'') and (br>length(titel)+4) then
  case typ of
   0:print(nr,l+(brr shr 1)-succ(length(titel) shr 1)+1,titlepos,titf,' '+ups(titel)+' ');
   1:begin  {Titel in Zeile 2 und Rahmen ╠═╣}
       inc(titlepos);if hoh>2 then
       print(nr,l,succ(titlepos),raf,rahf[rahmen,6]+rp(rahf[rahmen,1],
       pred(brr))+rahf[rahmen,7]);
      if hoh>1 then begin
       print(nr,succ(l),titlepos,titf,rp(' ',pred(brr)));
       print(nr,l+1+(brr shr 1)-succ(length(titel) shr 1),titlepos,$ff,' '+ups(titel)+' ')
      end
     end;
   2:begin {Titel in Zeile 2 und Rahmen ╟─╢}
      inc(titlepos);if hoh>2 then
       print(nr,l,succ(titlepos),raf,rahf[rahmen,8]+rp(rahf[rahmen,10],
       pred(brr))+rahf[rahmen,9]);
      if hoh>1 then begin
       print(nr,succ(l),titlepos,titf,rp(' ',pred(brr)));
       print(nr,l+1+(brr shr 1)-succ(length(titel) shr 1),titlepos,$ff,' '+ups(titel)+' ')
      end
     end;
   3:begin {Titel in Zeile 2 und Rahmen ║ ═ ║}
       inc(titlepos);if hoh>2 then
       print(nr,succ(l),succ(titlepos),raf,' '+rp(rahf[rahmen,1],brr-3)+' ');
      if hoh>1 then begin
       print(nr,succ(l),titlepos,titf,rp(' ',pred(brr)));
       print(nr,l+1+(brr shr 1)-succ(length(titel) shr 1),titlepos,$ff,' '+ups(titel)+' ')
      end
     end;
   4:begin {Titel in Zeile 2 und Rahmen ║ ─ ║}
       inc(titlepos);if hoh>2 then
       print(nr,succ(l),succ(titlepos),raf,' '+rp(rahf[rahmen,10],brr-3)+' ');
      if hoh>1 then begin
       print(nr,succ(l),titlepos,titf,rp(' ',pred(brr)));
       print(nr,l+1+(brr shr 1)-succ(length(titel) shr 1),titlepos,$ff,' '+ups(titel)+' ')
      end
     end
  end;dc:=0;
  if shadow then begin
   dc:=succ(o);
   if lrm<79 then
    for ro:=dc to (o+ho) do begin
     if (ro<26) then
      balken(nr,succ(l+brr),ro,2,vcol(shadf));
    end;
   if lrm<80 then
    for ro:=dc to (o+ho) do begin
     if (ro<26) then
      balken(nr,succ(l+brr),ro,1,vcol(shadf));
    end;
   if oho<25 then balken(nr,l+2,succ(o+hoh),pred(brr),vcol(shadf))
  end
 end
end;

procedure vsinit;
var no:byte;
begin
 for no:=0 to 9 do getscn(no)
end;

procedure vsfree;
var no:byte;
begin
 for no:=9 downto 0 do killscn(no)
end;

{Die Prozeduren aus dem Textbetrachter}

function getmaxlength:byte;
var lzeile:integer;maxlength:byte;
begin
 maxlength:=0;
 for lzeile:=2 to zmax do begin
  if (length(ze[pred(lzeile)]^)>length(ze[lzeile]^)) and
     (maxlength<length(ze[pred(lzeile)]^)) then
   maxlength:=length(ze[pred(lzeile)]^)
  else
   if maxlength<length(ze[lzeile]^) then
   maxlength:=length(ze[lzeile]^);
 end;
 getmaxlength:=maxlength;
end;


function readin(f:string):boolean;
var st:string;
label raus; {Wenn was schieflief, wird dort hingesprungen.}
begin
 readin:=false; {Erstmal auf FALSCH setzen, das spart.}
 zmax:=0; {noch keine Zeile gelesen.}
 assign(tf,f); {Der Textdatei einen Namen geben...}
 {$i-}reset(tf);{$i+} {Öffnen (nicht neu anlegen).}
 if ioresult<>0 then goto raus;
 while not(eof(tf)) do begin  {Lesen, bis Datei zuende.}
  {$i-}readln(tf,st);{$i+}
  if (ioresult<>0) then goto raus;
  if (st[1]=#9) then begin
   delete(st,1,1);st:='        '+st;
  end;
  if zmax<tmaxzeilen then begin {Wenn weniger als 10 000 Zeilen}
   inc(zmax); {Zeilen:=Zeilen+1}
   new(ze[zmax]);ze[zmax]^:=st; {Platz für neue Zeile holen und mit St füllen.}
  end else {goto raus;}break;
 end;
 readin:=true; {Wenn alles ok, dann TRUE zurückgeben.}
raus:
 {$i-}close(tf);{$i+} if ioresult<>0 then ;
 {Datei wieder zu.}
end;

function doxor(s:string):string;
var st:string;l:byte;
begin
 st:=s;for l:=1 to length(st) do st[l]:=chr(ord(st[l]) xor 13);
 doxor:=st;
end;


procedure cleanup;
{Wird nur intern benötigt, um den geholten Speicher ordentlich
 wieder freizugeben (nämlich RÜCKWÄRTS!).}
var az:integer; {Zählvariable}
begin
 for az:=zmax downto 1 do dispose(ze[az]);
end;

procedure Zeige(nr,pxpos,x,y,zrange,color:byte;crun:boolean);
{Ist auch nur intern. Zeigt jeweils einen "Bereich" der Datei an.}
var cnt:byte;
    proz:integer;
    ps:string;
begin
 {retrace;}
 for cnt:=0 to pred(zrange) do
 {Die Procedure "PRINT" ist ein Teil aus der IO-Unit, die ich mir mal geschrieben hab.}
 begin
  print(nr,x,y+cnt,color,rp(' ',82-(x shl 1)));
  if crun then
   print(nr,x,y+cnt,color,doxor(copy(ze[zakt+cnt]^,1+xoffs,82-(x shl 1))))
  else
   print(nr,x,y+cnt,color,copy(ze[zakt+cnt]^,1+Xoffs,82-(x shl 1)))
 end;
 proz:=pred(zakt);str(succ(proz):4,ps);
 print(nr,66-x,pxpos,color,' Zeile: '+ps+' ')
end;

procedure display(nr,pxpos,x,ys,zrange,color:byte;mitxor:boolean);
{Hier kann man nun die ganze Datei angucken. Mit Cursosteuerung...}
var repaint:boolean;maxl:byte;
{REPAINT sagt, ob neu angezeigt werden muß. Hat ja keinen Sinn,
 wenn einer 1000x HOME drückt, da rumzuflackern... }

procedure hilfe;
begin
 if nr<9 then begin
  copyscn(nr,succ(nr));
  hwin(succ(nr),0,1,15,7,50,8,$9b,$9e,$80,$9f,'Steuerungshilfe',true);
  print(succ(nr),18,9, $9e,'Vorwärts und rückwärts:  und  , Pos1/Ende');
  print(succ(nr),18,10,$9e,'Seitenweise blättern  : Bild und Bild');
  print(succ(nr),18,11,$9e,'Horizontal verschieben: <- und ->');
  print(succ(nr),18,12,$9e,'Schnell links / rechts: Strg+<- und Strg+->');
  print(succ(nr),18,13,$9e,'Programmteil abbrechen: ESC');
  putscn(succ(nr));
  repeat until readkey=#27;
  while keypressed do readkey;
  putscn(nr);copyscn(0,succ(nr));
 end
end;


begin
 maxl:=getmaxlength;
 zakt:=1; {1. Zeile!}
 zeige(nr,pxpos,x,ys,zrange,color,mitxor);putscn(nr);
  {erstmal den Anfang zeigen}
 repeat {und nun gucken, was der User will...}
  ch:=readkey;if ch=#0 then ch:=readkey;
  case ch of
   #59:hilfe;
   #71:{home}
       begin repaint:=(zakt<>1);zakt:=1;end;
   #79:{end}
       begin repaint:=(zakt<>succ(zmax-zrange));zakt:=zmax-zrange+1;end;
   #72:{Pfeil hoch}
       begin repaint:=(zakt>1);if repaint then dec(zakt); end;
   #80:{Pfeil runter}
       begin repaint:=(zakt<succ(zmax-zrange));
       if repaint then inc(zakt);end;
   #73:{Bild hoch}
       begin repaint:=(zakt-zrange>=1);
        if (zakt-zrange>=1) then dec(zakt,zrange) else begin repaint:=zakt>1;zakt:=1;end; end;
   #81:{Bild runter}
       begin repaint:=((zakt+zrange)<>succ(zmax-zrange));
        if ((zakt+zrange)<=(zmax-zrange)) then inc(zakt,zrange) else
         if zakt+zrange>zmax-zrange then begin repaint:=zakt+zrange<zmax;zakt:=succ(zmax-zrange); end end;
   #75:begin {Pfeil Links}
        repaint:=xoffs>0; if repaint then dec(xoffs);
       end;
   #77:begin {Pfeil rechts}
        repaint:=xoffs<(maxl-(82-(x shl 1)));
        if repaint then inc(xoffs);
       end;
   #115:begin {CTRL+Pfeil links}
         repaint:=(xoffs-8)>0; if repaint then dec(xoffs,8) else begin
         if xoffs>0 then xoffs:=0;repaint:=true end;
        end;
   #116:begin {CTRL+Pfeil rechts}
        repaint:=(xoffs+8)<(maxl-(82-(x shl 1)));
        if repaint then inc(xoffs,8)
        else if xoffs<(maxl-(82-(x shl 1))) then begin xoffs:=(maxl-(80-(x shl 1)));
        repaint:=true; end else repaint:=false;
       end;
  end;
  if repaint then zeige(nr,pxpos,x,ys,zrange,color,mitxor);putscn(nr);
 until ch=#27;
 cleanup;
end;

procedure winsave(anr,typo,rahme:byte;li,ob,brt,hoh:byte;ra,arb,shad,tit:byte;titl:s80;sha:boolean;mv,res:boolean);
begin
 if anr>tmaxwin then exit;
 new(winds[anr]);aktwin:=anr;
 with winds[anr]^do begin
 closerpos:=li+2;
 typ:=typo;
 rahmen:=rahme;
 l:=li;o:=ob;br:=brt;ho:=hoh;
 raf:=ra;arbf:=arb;titf:=tit;
 shadf:=shad;;
 titel:=titl;
 shadow:=sha;
 ismove:=mv;isresize:=res;
 end;
end;

procedure winwrite(ys,nr,snr,color:byte;s:string);
var spos,wpos,lin:byte;
begin
 with winds[nr]^ do begin
  spos:=(br-4);lin:=o+ys;wpos:=0;
  repeat
   if lin>=o+pred(ho) then exit;
   print(snr,l+2,lin,color,copy(s,(wpos*spos)+1,spos));
   inc(wpos);inc(lin);
  until wpos*spos>length(s);
 end;
end;

procedure winget(nr,vnr:byte;all:boolean);
var wn:byte;
begin
 if all then
 for wn:=1 to pred(nr) do
  window(wn,vnr);
 window(nr,vnr);
 if all and (nr<aktwin) then for wn:=succ(nr) to aktwin do
  window(nr,vnr);
 putscn(vnr);
end;

procedure winkill(nr:byte);
begin
 dispose(winds[nr]);
end;

begin
 checkvga
end.

{ ----------------------   DEMO PROGRAM --------------- }

uses dos,crt,vscreen;

var c:char;wc:byte;msx,msy:integer;mxs,mys,mbs:string[5];mis:boolean;
const fenstring:string=
'Das hier ist ein ziemlich langer Satz. Der wird im Fenster angezeigt und am Rahmen umgebrochen, wie das ja so sein soll.'+
'Dieser Satz kann maximal 255 Zeichen lang sein. Paßt er nicht, wird er abgeschnitten... SCHNAPP.';

begin
 cursor(false);
 blinken(false);
 hwin(10,0,0,1,1,80,25,$9f,$9f,$08,$9f,'',false);
 minit;
 getscn(0);getscn(1);getscn(2);
 winsave(0,0,1,10,5,60,15,$1f,$b0,$08,$1e,'ein fenster',true,false,false);
 winsave(1,0,1,1,1,45,15,$1f,$F0,$08,$1e,'fenster2',true,true,true);
 window(0,1);copyscn(1,2);window(1,2);
 winwrite(1,1,2,$f1,fenstring);
 zeig;
 repeat
  with winds[1]^ do begin
   msx:=(l+(br shr 1)-pred(length(titel) shr 1));
   msy:=(l+(br shr 1)+pred(length(titel) shr 1));
  end;
  c:=#0;
  if keypressed then c:=readkey;
  if c<>#0 then
  case c of
   '0':begin weg;
        putscn(0);zeig;while keypressed do readkey end;
   '1':begin weg;
        putscn(1);zeig;while keypressed do readkey end;
   '5':begin weg;
        putscn(2);zeig;while keypressed do readkey end;
   '4':begin copyscn(1,2);
        if (winds[1]^.l>1) then begin dec(winds[1]^.l);
         winds[1]^.closerpos:=winds[1]^.l+2;window(1,2);
         winwrite(1,1,2,$f1,fenstring);
         weg;putscn(2);zeig;
        end;
       end;
   '6':begin copyscn(1,2);
        if ((pred(winds[1]^.l+winds[1]^.br))<80) then begin inc(winds[1]^.l);
         winds[1]^.closerpos:=winds[1]^.l+2;
         window(1,2);
         winwrite(1,1,2,$f1,fenstring);
         weg;putscn(2);zeig;
        end;
       end;
   '8':begin copyscn(1,2);
        if winds[1]^.o>1 then begin dec(winds[1]^.o);
         window(1,2);
         winwrite(1,1,2,$f1,fenstring);
         weg;putscn(2);zeig;
        end;
       end;
   '2':begin copyscn(1,2);
        if ((pred(winds[1]^.o+winds[1]^.ho))<25) then begin inc(winds[1]^.o);
         window(1,2);
         winwrite(1,1,2,$f1,fenstring);
         weg;putscn(2);zeig;
        end;
       end;
   '7':begin copyscn(1,2);
        if ((winds[1]^.br>length(winds[1]^.titel)+4) and
         (winds[1]^.ho>3)) then begin dec(winds[1]^.br);dec(winds[1]^.ho);
         window(1,2);
         winwrite(1,1,2,$f1,fenstring);
         weg;putscn(2);zeig;
        end;
       end;
   '9':begin copyscn(1,2);
        if ((pred(winds[1]^.br)+winds[1]^.l<80) and
         (pred(winds[1]^.ho)+winds[1]^.o<25)) then begin inc(winds[1]^.br);inc(winds[1]^.ho);
         window(1,2);
         winwrite(1,1,2,$f1,fenstring);
         weg;putscn(2);zeig;
        end;
       end;

  end else begin
   with winds[1]^do begin
    mis:=(mausxy(msx,pred(o),msy,pred(o)) and (button=1));
    if mis then begin
     mx:=mausx-l+1;
     repeat
      copyscn(1,2);
       l:=succ(mausx)-(mx);o:=succ(mausy);closerpos:=l+2;
      if ((o+ho-2<25) and (l+br-2<80)) and
       ((l>0) and (o>0)) then begin
       window(1,2);
       winwrite(1,1,2,$f1,fenstring);
       weg;putscn(2);zeig;
      end;
     until button<>1;
    end else begin
     msx:=l+pred(br);msy:=o+pred(ho);
     mis:=(mausxy(pred(msx),pred(msy),(msx),(msy)) and (button=1));
     if mis then begin
      repeat
       copyscn(1,2);
       if (succ(mausx)-l+1) > length(titel)+8+(succ(length(titel)) mod 2) then
        br:=(succ(mausx)-l+1);
       if (succ(mausy)-o+1) >2 then ho:=(succ(mausy)-o+1);
       window(1,2);
       winwrite(1,1,2,$f1,fenstring);
       weg;putscn(2);zeig;
      until button<>1;
     end;
    end;
    if (mausxy(closerpos-1,pred(o),closerpos+1,pred(o)) and (button=1)) then begin
     weg;putscn(1);zeig;
    end;
   end;
  end;
 until (c=#27) or (button=2);

 {vsfree;}
 for wc:=2 downto 0 do killscn(wc);
 for wc:=aktwin downto 0 do winkill(wc);
 clrscr;
 blinken(true);
 cursor(true)
end.