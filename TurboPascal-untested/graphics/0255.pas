program loadpcx;

{ only 256 colors pcx-images }
{ Svga256.bgi driver necessary }

uses dos,crt,graph;

const
  BufferLengte = $FFFE;
  Klaar    : boolean = false;

type PcxType = Object
        Kenmerk, Versie: byte;
        Gecomprimeerd: boolean;
        BitsPerPixel: byte;
        Raam: Record Links, Boven, Rechts, Onder: word End;
        HorResolutie, VerResolutie: word;
        Kleuren: array[0..15] of Record Rood, Groen, Blauw: byte End;
        Reserve: byte;
        AantalVlakken: byte;
        AantalBytesPerLijn: word;
        PaletInformatie: word;
        ReserveArray: array[1..58] of byte;
      End;
      ArByte = array[0..$FFFE] of byte;


      RGBColor   = record R,G,B :byte; end;
      VGAPalette = array[0..255] of RGBColor;


var
  Herhaal,Teller,m,
  xx,yy,MaxX,MaxY       :word;
  PCX                   :PCXType;
  Buffer,Lijnx          :^ArByte;
  PCX_Bestand           :File;
  BufSize               :word;
  Regs                  :Registers;
  Kleuren256            :array[0..255] of Record Rood,Groen,Blauw :byte End;
  PaletNr,ID            :byte;



Procedure LeesBuffer;

Begin
  Klaar := Klaar or EOF(PCX_Bestand);
  BlockRead(PCX_Bestand, Buffer^, SizeOf(Buffer^), BufSize)
End;

Procedure Lees256Kleuren;

Begin
  Seek(PCX_Bestand, FileSize(PCX_Bestand) - 769);
  ID := 0;
  BlockRead(PCX_Bestand, ID, 1);
  If ID = 12 then With Regs do Begin
    BlockRead(PCX_Bestand, Kleuren256, 768);
    For PaletNr := 0 to 255 do With Kleuren256[PaletNr] do Begin
      Rood := Rood shr 2; Groen := Groen shr 2; Blauw := Blauw shr 2
    End;
    AX := $1012;
    BX := 0;
    CX := 256;
    ES := Seg(Kleuren256);
    DX := Ofs(Kleuren256);
    Intr($10, Regs)
  end;
  seek(PCX_Bestand, SizeOf(PCX))
end;

Procedure Increment;

Begin
  If Teller < BufferLengte then Inc(Teller)
  else Begin
    Teller := 0;
    LeesBuffer;
  End;
End;

procedure load_pcx(posx,posy,breedte,hoogte :word;pcxnaam :string);

begin
  MaxX :=(breedte+posx)-1; MaxY :=(hoogte+posy)-1;
  Assign(PCX_Bestand,pcxnaam +'.pcx');
  {$I-} Reset(PCX_Bestand, 1); {$I+}
  if ioresult =0 then Begin
    BlockRead(PCX_Bestand, PCX, SizeOf(PCX));
    GetMem(Buffer,BufferLengte);
    Lees256Kleuren;
    xx :=posx;yy :=posy;Teller :=0;
    LeesBuffer;
    While not Klaar do Begin
      If Buffer^[Teller] and $C0 = $C0 then Begin
        Herhaal := Buffer^[Teller] - $C0;
        Increment;
      End
      else Herhaal := 1;
      For m := 1 to Herhaal do Begin
        If xx <= MaxX then PutPixel(xx, yy, Buffer^[Teller]);
        Inc(xx);
      End;
      If xx >= pcx.AantalBytesPerLijn +posx then Begin
        xx := posx; Inc(yy);
        If yy > MaxY then Klaar := true;
      End;
      Increment;
    end;
    freemem(buffer,bufferlengte);
    close(pcx_bestand);
    klaar :=false;
  end;
end;

procedure Setvideo(scherm :byte);

var  AutoDetect : pointer;  GrMd,GrDr  : integer;

{$F+}
function DetectVGA0 : Integer;
begin detectvga0 :=0;end;
function DetectVGA1 : Integer;
begin detectvga1 :=1;end;
function DetectVGA2 : Integer;
begin detectvga2 :=2;end;
function DetectVGA3 : Integer;
begin detectvga3 :=3;end;
function DetectVGA4 : Integer;
begin detectvga4 :=4;end;
{$F-}

begin
  AutoDetect := @DetectVGA2;
  case scherm of
    0:AutoDetect := @DetectVGA0;
    1:AutoDetect := @DetectVGA1;
    2:AutoDetect := @DetectVGA2;
    3:AutoDetect := @DetectVGA3;
    4:AutoDetect := @DetectVGA4;
  end;
  GrDr := InstallUserDriver('SVGA256',AutoDetect);
  GrDr := Detect;
  InitGraph(GrDr,GrMd,'');
end;


begin
  setvideo(2);
  setcolor(15);
  settextstyle(0,0,2);
  outtextxy(140,60,'GROETEN UIT DOETINCHEM');
  setcolor(2);
  outtextxy(141,61,'GROETEN UIT DOETINCHEM');
  load_pcx(120,100,192,128,'demo1');  { 192 is width / 128 is height image }
  load_pcx(320,100,192,128,'demo2');
  load_pcx(120,240,192,128,'demo3');
  load_pcx(320,240,192,128,'demo4');
  readln;
  closegraph;
  halt;
end.
