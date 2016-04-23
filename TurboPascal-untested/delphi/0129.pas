{
this is not complete but it may help someone
 - code for 256 colour DIBs

I've nearly finished a little DIB demo that I'll upload to DSP soon

John B
===================================
}

unit DIB_surface_object;

interface

uses
  { Borland }
  Windows,Sysutils,Graphics,Classes,
  { Mine }
  Palunit;

type
  Pshape = ^shape;
  shape  = array[0..0] of Tpoint;

type
  DIBsurfaceobject = Class(TObject)
    DIBheader    : TMyBitmapInfo;
    DIBPalette   : TMyLogPalette;
    DIBhpalette  : hPalette;
    DIBpalsize   : integer;
    DIBbits      : Pointer;
    DIBhandle    : THandle;
    DIBDC        : hDC;
    Original_BMP : hBitmap;
    Original_PAL : hPalette;
    DIBWidth     : integer;
    DIBHeight    : integer;
    DIBWidth_b   : integer;
    DIBSize      : integer;
    constructor Create(palette:TMyLogPalette; newsize:TPoint);
    destructor  destroy;  override;
    procedure   change_size(newsize:TPoint; force:boolean);
    procedure   change_palette(newpal:shortstring);
    procedure   draw_horizontal_line(x1,x2,y:integer; b:byte);
    procedure   set_pixel(x,y:integer; b:byte);
    procedure   safe_set_pixel(x,y:integer; b:byte);
    procedure   fill_polygon(n:integer; poly:Pshape; fillcol:byte);
    procedure   copy_surface_to_screen(destDC:hDC);
    procedure   copy_screen_to_surface(sourceDC:hDC);
    procedure   clear_surface;
  end;

implementation

{ ------------------------------------------------------------------------ }
{                             DIB surface object                           }
{ ------------------------------------------------------------------------ }
constructor DIBsurfaceobject.Create(palette:TMyLogPalette; newsize:TPoint);
var lp1 : integer;
begin
  inherited Create;
  DIBbits      := nil;
  DIBhandle    := 0;
  DIBPalette   := palette;
  DIBhpalette  := CreatePalette(PLogPalette(@palette)^);
  DIBDC        := CreateCompatibleDC(0);
  Original_PAL := SelectPalette(DIBDC,DIBhpalette,false);
  with DIBheader do begin
    with bmiHeader do begin
      biSize          := sizeof(TBITMAPINFOHEADER);
      biWidth         := newsize.x;
      biHeight        := newsize.y;
      biPlanes        := 1;
      biBitCount      := 8;
      biCompression   := BI_RGB;
      biSizeImage     := 0;
      biXPelsPerMeter := 0;
      biYPelsPerMeter := 0;
      biClrUsed       := 0;
      biClrImportant  := 0;
    end;
    for lp1:=0 to 255 do BMIcolors[lp1] := (lp1+0) and 255; { Pal_indices - no offset }
  end;
  Original_BMP := 0;
  DIBWidth     := 0;
  DIBHeight    := 0;
  change_size(newsize,false);
end;

destructor DIBsurfaceobject.destroy;
begin
  if Original_BMP<>0 then SelectObject(DIBDC,Original_BMP);
  if Original_PAL<>0 then SelectPalette(DIBDC,Original_PAL,false);
  if DIBhandle<>0    then DeleteObject(DIBhandle);
  if DIBhpalette<>0  then DeleteObject(DIBhpalette);
  DeleteDC(DIBDC);
  inherited destroy;
end;

procedure DIBsurfaceobject.change_size(newsize:TPoint; force:boolean);
begin
  if (not force) and (newsize.x=DIBWidth) and (newsize.y=DIBHeight) then exit;
  DIBWidth   := newsize.x;
  DIBHeight  := newsize.y;
  DIBWidth_b := ((DIBWidth+3)shr 2)shl 2;
  DIBSize    := DIBWidth_b*DIBHeight;
  if Original_BMP<>0 then SelectObject(DIBDC,Original_BMP);
  if DIBhandle<>0 then DeleteObject(DIBhandle);
  DIBheader.BMIheader.biWidth  := DIBWidth;
  DIBheader.BMIheader.biHeight :=-DIBHeight; { Top down for me please...}
  DIBhandle    := CreateDIBSection(DIBDC,pBitmapInfo(@DIBheader)^,DIB_PAL_COLORS,DIBbits,nil,0);
  Original_BMP := SelectObject(DIBDC,DIBhandle);
end;

procedure DIBsurfaceobject.change_palette(newpal:shortstring);
begin
  SelectPalette(DIBDC,Original_PAL,false);
  create_256_identity_palette_from_file(DIBpalette,DIBhpalette,newpal);
  Original_PAL := SelectPalette(DIBDC,DIBhpalette,false);
  change_size(Point(DIBwidth,DIBheight),true);
end;

procedure DIBsurfaceobject.draw_horizontal_line(x1,x2,y:integer; b:byte);
var lp1,offset : integer;
begin
  offset:=integer(DIBbits)+ y*DIBWidth_b;
  for lp1:=x1 to x2 do Pbyte( offset+lp1 )^ := b;
end;

procedure DIBsurfaceobject.set_pixel(x,y:integer; b:byte);
begin
  Pbyte( integer(DIBbits) + y*DIBWidth_b + x )^ := b;
end;

procedure DIBsurfaceobject.safe_set_pixel(x,y:integer; b:byte);
begin
  if (x<DIBWidth) and (x>=0) then begin
    if (y<DIBHeight) and (y>=0) then begin
      Pbyte( integer(DIBbits) + y*DIBWidth_b + x )^ := b;
    end;
  end;
end;

procedure DIBsurfaceobject.fill_polygon(n:integer; poly:Pshape; fillcol:byte);
var loop1                   : integer;
    yval,ymax,ymin          : integer;
    yval0,yval1,yval2,yval3 : integer;
    ydifl,ydifr             : integer;
    xval0,xval1,xval2,xval3 : integer;
    xleft,xright            : integer;
    mu                      : integer;
    minvertex               : integer;
    vert0,vert1,vert2,vert3 : integer;
begin
  ymax:=-99999; ymin:=99999;
  { get top & bottom scan lines to work with }
  for loop1:=0 to n-1 do begin
    yval:=poly^[loop1].y;
    if yval>ymax then ymax:=yval;
    if yval<ymin then begin ymin:=yval; minvertex:=loop1; end;
  end;
  vert0 := minvertex;      vert1 :=(minvertex+1) mod n-1;
  vert2 := minvertex;      vert3 :=(minvertex-1) mod n-1;
  yval0 := poly^[vert0].y; yval1 := poly^[vert1].y;
  yval2 := poly^[vert2].y; yval3 := poly^[vert3].y;
  ydifl := yval1-yval0;    ydifr := yval3-yval2;
  xval0 := poly^[vert0].x; xval1 := poly^[vert1].x;
  xval2 := poly^[vert2].x; xval3 := poly^[vert3].x;

  for loop1:=ymin to ymax do begin

    {intersection on left hand side }
    mu:=(loop1-yval0);
    if mu>ydifl then begin
      vert0:=vert1; vert1:=(vert1+1) mod n-1;
      yval0 := poly^[vert0].y; yval1 := poly^[vert1].y;
      xval0 := poly^[vert0].x; xval1 := poly^[vert1].x;
      ydifl := yval1-yval0;
      mu:=(loop1-yval0)
    end;
    if ydifl<>0 then xleft:=xval0 - (mu*integer(xval0-xval1) div ydifl)
    else             xleft:=xval0;

    {intersection on right hand side }
    if ydifr<>0 then mu:=(loop1-yval2)
    else mu:=ydifr;
    if mu>ydifr then begin
      vert2:=vert3; vert3:=(vert3-1) mod n-1;
      yval2 := poly^[vert2].y; yval3 := poly^[vert3].y;
      xval2 := poly^[vert2].x; xval3 := poly^[vert3].x;
      ydifr := yval3-yval2;
      if ydifr<>0 then mu:=(loop1-yval2)
      else mu:=ydifr;
    end;
    if ydifr<>0 then xright:=xval2 + (mu*integer(xval3-xval2) div ydifr)
    else             xright:=xval2;
    draw_horizontal_line(xleft,xright,loop1,fillcol);
  end;
end;

procedure DIBsurfaceobject.copy_surface_to_screen(destDC:hDC);
begin
  SelectPalette(destDC,DIBhpalette,false);
  BitBlt(destDC,0,0,DIBWidth,DIBHeight,DIBDC,0,0,SRCCOPY);
end;

procedure DIBsurfaceobject.copy_screen_to_surface(sourceDC:hDC);
begin
  BitBlt(DIBDC,0,0,DIBWidth,DIBHeight,sourceDC,0,0,SRCCOPY);
end;

procedure DIBsurfaceobject.clear_surface;
var DWORDptr : Plongint;
    lp1      : integer;
begin
  for lp1:=0 to DIBheight-1 do
    draw_horizontal_line(0,DIBwidth,lp1,lp1);
  exit;

  DWORDptr:=DIBbits;
  for lp1:=0 to (DIBsize div 4)-1 do begin
    Plongint(DWORDptr)^:=$00000000;
    inc(DWORDptr);
  end;
end;

initialization
end.
