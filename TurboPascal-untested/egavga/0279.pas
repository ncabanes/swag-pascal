unit graphic;
{ By Nelson Chu 1993,94,95,96 - DOS mini version, to be included in SWAG.

{ This uint contains functions & procedures that I ususally need for
  writing graphical programs in standard VGA mode. There may be some code
  that are not useful. I just release it so that I don't have to include
  the needed routines in my every other programs to SWAG. }
interface
type ScreenType=array[0..199,0..319] of byte;
     pScreenType=^ScreenType;
     palrecordtype = record  { the Palette type, consists }
                     R,G,B:byte; end;
     PALType=array[0..255] of palrecordtype;{ of 3 fields :
                                              Red, Green & Blue values }
     sintable = array[0..255] of shortint;
var  vs,screen:pScreenType;
     sine:sintable;

procedure SetCRTMode(Mode:word);
procedure FadeOut(pal:paltype; low,high,delay:byte);
procedure FadeIn(pal:paltype; low,high,delay:byte);
procedure LoadPAL(FileName:string; var pal:paltype; mix:boolean);
procedure HVline(x1,y1,len:word;color:byte;HV:boolean; screen:pScreenType);
procedure blacken(low,high:byte); {set all color's palette to zero}
procedure setcolor(c,r,g,b:byte);
procedure vSync;
procedure clearScreen(scr:pScreenType);
function VideoOK:boolean; {check for a VGA or MCGA}
Function VGA : Boolean;
procedure GetPal(var pal:palType; b,e:byte);
procedure Setpal(apal:paltype; b,e:byte);
procedure pset(x,y:word; color:byte);{pascal}
Procedure asmPset(Scr:pscreentype;x:Integer;y,Col:Byte);{asm}
{use direct array reference is faster, since every time you call the above
two proc., time wasted on pushing/poping registers.}
procedure copyscreen(ss,ds:pscreentype);
procedure fillbox(x1,y1,x2,y2:word; c: byte; screen:pscreentype);
procedure RotatePal(Var Pal : PALType; beginRec, endRec : byte);
procedure calSine(var sinbl:sintable);
procedure copybox(ss,ds:pscreentype; sx, sy, w, h, dx, dy:word);
implementation

procedure copyright; assembler;
label there;
asm
 jmp there;
 db 13,10,"Graphic Unit(Mini DOS version 1.3) by Nelson Chu 93-96",13,10
there:
end;

PROCEDURE dmove( var S, D; Cnt : Word ); ASSEMBLER;
ASM
	MOV	DX,DS
	LDS	SI,[S]
	LES	DI,[D]
	MOV	CX,[Cnt]
	CLD
	SHR	CX,2
        DB      66h
    REP MOVSW
	ADC	CX,CX
    REP MOVSB
	MOV	DS,DX
END;


procedure SetCRTMode(Mode:word); assembler; { as the name implies, it sets }
asm                                     { the CRT's mode by calling int 10 }
mov ax,Mode;
int 10h
end;

procedure vSync; assembler; { used for smooth output }
label
  l1, l2;
asm
{    cli}
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
{    sti}
end;


procedure FadeOut(pal:paltype; low,high,delay:byte);
var i,j:byte;
begin
for i:=31 downto 1 do
begin
Port[$3c8]:=low;
for j:= 0 to delay do;
vSync;
for j:=low to high do
    begin
    Port[$3c9]:=(pal[j].R*i) div 32;
    Port[$3c9]:=(pal[j].G*i) div 32;
    Port[$3c9]:=(pal[j].B*i) div 32;
    end;
end;
end;

procedure FadeIn(pal:paltype; low,high,delay:byte);
var i,j:byte;
begin

for i:= 1 to 31 do
begin
Port[$3c8]:=low;
for j:= 0 to delay do;
vSync;
for j:=low to high do
    begin
    Port[$3c9]:=(pal[j].R*i) div 32;
    Port[$3c9]:=(pal[j].G*i) div 32;
    Port[$3c9]:=(pal[j].B*i) div 32;
    end;
end;

end;

Function VGA : Boolean; Assembler;
Asm
  MOV     AH,1Ah
  INT     10h
  CMP     AL,1Ah
  MOV     AL,True
  JE      @OUT
  DEC     AX
 @OUT:
end;


function VideoOK:boolean;
var result:byte;
begin
asm
   mov ah,$1a
   xor al,al
   int $10
   mov result,bl
end;
            { VGA mono;VGA color }
            { vvvvvvv            }
if result in [$07,$08,$0a..$0c] then videoOK:=true else videoOK:=false;
                   {  ^^^^^^^^   }
                   { MCGA digital color; MCGA analog color; }
end;               { MCGA analog mono }

procedure LoadPAL(FileName:string; var pal:paltype; mix:boolean);
var
  Fil:file of PALType;
  i:byte;

begin
  assign(Fil,FileName);
  reset(Fil);
  read(Fil,PAL);
  close(Fil);
  if mix then
  for i := 0 to 255 do
    begin
    Port[$3c8]:=i;
    Port[$3c9]:=PAL[i].R;
    Port[$3c9]:=PAL[i].G;
    Port[$3c9]:=PAL[i].B;
    end;
end;

procedure setcolor(c,r,g,b:byte);
begin
    Port[$3c8]:=c;
    Port[$3c9]:=R;
    Port[$3c9]:=G;
    Port[$3c9]:=B;
end;

procedure Setpal(apal:paltype; b,e:byte);
var i:byte;
begin
 Port[$3c8]:=b; {auto incremented}
 for i := b to e do
 begin Port[$3c9]:=aPAL[i].R;
       Port[$3c9]:=aPAL[i].G;
       Port[$3c9]:=aPAL[i].B; end;
end;

procedure GetPal(var pal:palType; b,e:byte);
var i:byte;
begin
  port[$3c7]:=b; {auto incremented}
  For i:= b to e do
  begin Pal[i].R:=port[$3c9];
        Pal[i].G:=port[$3c9];
        Pal[i].B:=port[$3c9]; end;
end;


procedure HVline(x1,y1,len:word;color:byte;HV:boolean; screen:pScreenType);
{ (x1,y1) is the upper-left coordinate; HV determine whelter it's H or V }
var a,b:word;
begin
a:=x1;b:=y1;
if HV then fillchar( screen^[b,a], len, char(color))
      else while len>0 do begin screen^[b,a]:=color; inc(b); dec(len); end;
end;

procedure blacken(low,high:byte);
var d:byte;
begin
for d:=low to high do
	begin
        Port[$3c8]:=d;
	Port[$3c9]:=0;
	Port[$3c9]:=0;
	Port[$3c9]:=0;
	end;
end;


procedure RotatePal(Var Pal : PALType; beginRec, endRec : byte);
var  TRGB : palrecordtype;
begin TRGB:=Pal[beginRec];
      Move(Pal[beginRec+1],Pal[beginRec],(endRec-beginRec)*3);
      Pal[endRec]:=TRGB;
end;


procedure clearScreen(scr:pScreenType);
begin
fillchar(scr^,64000,#0);
end;

Procedure asmPset(Scr:pscreentype;x:Integer;y,Col:Byte);assembler;
Asm les   di,Scr; xor   bh,bh; mov   bl,y; shl   bx,6; add   bh,y;
add bx,x; add   bx,di; mov   al,Col; mov   es:[bx],al; end;

procedure pset(x,y:word; color:byte);
begin
 screen^[y,x]:=color;
end;

procedure copyscreen(ss,ds:pscreentype);
begin
  dmove(ss^,ds^,64000);
end;

procedure fillbox(x1,y1,x2,y2:word; c: byte; screen:pscreentype);
var a: byte; s:word;
begin
 s:=x2-x1+1; for a:= y1 to y2 do fillchar(screen^[a,x1], s, c);
end;



procedure copybox(ss,ds:pscreentype; sx, sy, w, h, dx, dy:word);
var a:word;
begin
 for a:=0 to h-1 do
  move(ss^[sy+a,sx], ds^[dy+a, dx], w);
end;

procedure calSine(var sinbl:sintable);
var a:byte;
begin
for a:=0 to 255 do sinbl[a]:=trunc( sin(a*pi/128)*127);
end;

begin
  Screen:=Ptr(SegA000,0000);
  copyright;
  calSine(sine);
end.

{ At last I can contribute something to SWAG. I waited to be a university
  student in Hong Kong for long. We have our Internet account as we become
  one of their menbers. Only then can I e-mail my programs to you...}

