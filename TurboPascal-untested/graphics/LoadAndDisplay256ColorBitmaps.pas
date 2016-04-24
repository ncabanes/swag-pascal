(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0234.PAS
  Description: Load and display 256 color bitmaps
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)

program loadbmp;

{ only 256 colors }

uses dos,crt,graph;

{ the driver is include in "play256.zip" on my pascal-homepage }
{ http://quintus.universal.nl/users/dickmann/pascal.htm }

var
  regs                  :registers;
  maxx,maxy,p,x,y       :integer;
  f                     :file;
  header                :record
                           bm:array[0..1] of char;
                           groottebestand       :longint;
                           reserve              :longint;
                           offset               :longint;
                           groottebeeldinfo     :longint;
                         end;
  beeldinfo             :record
                           breedte,hoogte       :longint;
                           vlakken,bitsperpixel :word;
                           hor,ver              :longint;
                           aantalkleuren        :longint;
                         end;
  bytesperlijn,oudpos   :longint;
  rgbi                  :array[1..256] of record bb,gg,rr,ii :byte;end;
  rgb                   :array[1..256] of record r,g,b :byte;end;
  lijn                  :array[1..1024] of byte;


procedure load_bmp(xx,yy :integer;filenaam :string);

procedure set256palette(var rgb_buffer);

begin
  with regs do begin
    ax :=$1012;
    bx :=0;
    cx :=256;
    es :=seg(rgb_buffer);
    dx :=ofs(rgb_buffer);
    intr($10,regs);
  end;
end;

begin
  maxx :=getmaxx-1;maxy :=getmaxy-1;
  assign(f,filenaam+'.bmp');
  {$I-} reset(f,1); {$I+}
  if ioresult =0 then begin
    blockread(f,header,sizeof(header));
    fillchar(beeldinfo,sizeof(beeldinfo),0);
    blockread(f,beeldinfo,header.groottebeeldinfo -4);
    with beeldinfo,header do begin
      bytesperlijn :=breedte *bitsperpixel;
      if (bytesperlijn and 31) =0 then bytesperlijn :=bytesperlijn shr 3
        else bytesperlijn :=succ(bytesperlijn shr 5)shl 2;
      if aantalkleuren =0 then aantalkleuren :=1 shl bitsperpixel;

      if bitsperpixel <>8 then exit;
      blockread(f,rgbi,4*aantalkleuren);
      for p :=1 to aantalkleuren do with rgb[p],rgbi[p] do begin
        r :=rr shr 2;
        g :=gg shr 2;
        b :=bb shr 2;
      end;
      set256palette(rgb);

      with header,beeldinfo do begin
        if hoogte <= maxy then oudpos :=offset
          else oudpos :=offset +bytesperlijn *(hoogte -maxy);
        if breedte < maxx then maxx :=breedte;
        if hoogte <maxy then maxy :=hoogte;
        for y :=yy+(maxy-1) downto yy do begin
          seek(f,oudpos);
          blockread(f,lijn,maxx);
          for x :=xx to (maxx)+xx do putpixel(x,y,lijn[x-xx]);
          inc(oudpos,bytesperlijn);
        end;
      end;

      close(f);
    end;
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
     { 0 = 320x200 / 1 = 640x400 / 2 = 640x480 }
     { 3 = 800x600 / 4 = 1024x768 pixels }

  load_bmp(0,0,'demo');   { no extension }
  readln;
  closegraph;
  halt;
end.
