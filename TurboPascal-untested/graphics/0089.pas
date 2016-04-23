{
This is my plasma code. Written here for windows 24bit mode. There's
some comments in it. It had a problem. I tried to fix it. Couldn't.
Deleted some POSITIVELY ABSOLUTELY ESSENTIAL bits of code, and the
problem went away. Don't ask me, I just wrote it.

You should be able to put it to palette based code pretty easy. It
started out that way and then got converted to RGB. Probably all you'd
need to do, is kill red and green, and just use blue as the palette
entry. Your problem to make sure your palette has nice colours.

It still tends to be a little ridgy on the primary axes. If anybody can
get rid of that, that would be cool. Let me know.

It's also a fractal terrain generator. Same alg. This is just 3 fractal
terrain altitude maps overlaid in rgb.

(Oh, yeah, it's not really windows code. All the real windows code
should be separate from the useful code, just in case you don't do
windows, don't be scared.)

--8<--------------------------------------------------------
}

program plasma;
{integer version of cloud.
 Only works 24bit. Change resolution
 constants width, height if you need.}
{Left button starts drawing.
 CTRL-ALT-DEL to stop. Or wait for it to finish, and
 right button}
uses OWindows, ODialogs, WinTypes, WinProcs;

const
{integer version of old real constant.
 For calm versions, try FUZZ1/FUZZ2=0.3
 For wild versions, try FUZZ1/FUZZ2=10}
  FUZZ1=1;
  FUZZ2=6;

  width= 800;
  height= 600;

type
     TMyApp=object (TApplication)
       procedure InitMainWindow; virtual;
       end;

     PMyWindow=^TPlasmaWindow;
     TPlasmaWindow=object (TWindow)
       r,g,b:byte;
       w,h:integer;
       constructor init(AParent:PWindowsObject; ATitle:PChar);
       procedure SetUpWindow; virtual;
       procedure WMLButtonDown(var Msg:TMessage); virtual wm_First+wm_LButtonDown;
       procedure WMRButtonDown(var Msg:TMessage); virtual wm_First+wm_RButtonDown;
       function getclassname:pchar; virtual;
       procedure getwindowclass(var awndclass:twndclass); virtual;
       end;

var maxx,maxy:integer;
    backg:TColorRef;
    i:integer;

function clamp(x:integer):byte;
begin
{  if x<0 then x:=0
  else if x>255 then x:=255;
  clamp:=x;}
  case x of
   -32767..0 : clamp:=0;
   0..255    : clamp:=x;
   256..32767: clamp:=255;
   else {oops};
   end; {case}
end;

function randomcolour:TColorRef;
var r,g,b:byte;
begin
    randomcolour:=rgb(random(256),random(256),random(256));
end;

procedure TMyApp.InitMainWindow;
begin
   MainWindow := New(PMyWindow, Init(NIL,'Plasma'));
end;

constructor TPlasmaWindow.init(AParent:PWindowsObject; ATitle:PChar);
begin
  inherited init(AParent,ATitle);
  r:=0; g:=0; b:=0;
  w:=2;h:=2;
  attr.x:=0; attr.y:=0;
  attr.w:=width; attr.h:=height;
  attr.style:=ws_popup + ws_visible;
end;

procedure TPlasmaWindow.SetUpWindow;
begin
  inherited setupwindow;
end;

procedure TPlasmaWindow.WMLButtonDown(var Msg:TMessage);
var ADC:HDC;
    AP,TempP:HPen;
    AB,TempB:HBrush;

    function max(a,b:integer):integer;
    begin
      if a<b then        max:=b      else        max:=a;
    end;

    function mid(a,b:integer):integer;
    begin
      mid:=(a + b) div 2;
    end;

    function ridge(a,b,c,d:integer):TColorref;
    {Take two endpoints, shift the mid point, based on how far apart they are.}
    var variance:integer;
        r,g,l:byte;
        m,n:TColorref;
        vd2:integer;
    begin
      variance:=max(c-a,d-b) * FUZZ1 div FUZZ2;
      vd2:=variance div 2;
      m:=getpixel(adc,(a),(b));
      n:=getpixel(adc,(c),(d));
      r:=clamp(((getrvalue(m) + getrvalue(n)) div 2{ + (random(variance))-vd2}));
      g:=clamp(((getgvalue(m) + getgvalue(n)) div 2{ + (random(variance))-vd2}));
      l:=clamp(((getbvalue(m) + getbvalue(n)) div 2{ + (random(variance))-vd2}));
      ridge:=rgb(r,g,l);
    end;

    function shift(a,b,c,d:integer; col:tcolorref):tcolorref;
    var variance:integer;
        r,g,l:byte;
        vd2:integer;
    begin
{      variance:=max(d-b,c-a) * FUZZ1 div FUZZ2;}
      variance:=(c-a) * FUZZ1 div FUZZ2;
      vd2:=variance div 2;
      r:=clamp(getrvalue(col) + (random(variance))-vd2);
      g:=clamp(getgvalue(col) + (random(variance))-vd2);
      l:=clamp(getbvalue(col) + (random(variance))-vd2);
      shift:=rgb(r,g,l);
    end;

    procedure quarter(l,t,r,b:integer);
    var mx,my,width,colour,variance:integer;
        mzr,mzg,mzb:byte;
        c:char;
        m,n,o,p,tc:TColorRef;
        vd2:integer;
        abrush:hbrush;
    begin
      width:=r-l;
      if (width>1) or (b-t>1) then
        begin
        variance:=width * FUZZ1 div fuzz2 ;
        vd2:=variance div 2;
        mx:=mid(l,r);
        my:=mid(t,b);
        m:=getpixel(adc,l,t);
        n:=getpixel(adc,l,b);
        o:=getpixel(adc,r,t);
        p:=getpixel(adc,r,b);
        mzr:=clamp((getrvalue(m) + getrvalue(n) + getrvalue(o) + getrvalue(p)) div 4 + random(variance)-vd2);
        mzg:=clamp((getgvalue(m) + getgvalue(n) + getgvalue(o) + getgvalue(p)) div 4 + random(variance)-vd2);
        mzb:=clamp((getbvalue(m) + getbvalue(n) + getbvalue(o) + getbvalue(p)) div 4 + random(variance)-vd2);

        setpixel(adc,mx,my,rgb(mzr,mzg,mzb));
        setpixel(adc,(l),(my),ridge(l,t,l,b));
        setpixel(adc,(r),(my),ridge(r,t,r,b));
        setpixel(adc,(mx),(t),ridge(l,t,r,t));
        setpixel(adc,(mx),(b),ridge(l,b,r,b));

        quarter(l,t,mx,my);
        quarter(l,my,mx,b);
        quarter(mx,t,r,my);
        quarter(mx,my,r,b);
        end;
    end;

begin
  ADC:=getdc(HWindow);
  randomize;
  maxx:=width-1; maxy:=height-1;
  backg:=getpixel(ADC,10,10);
  setpixel(adc,0,0,randomcolour);
  setpixel(adc,0,maxy,randomcolour);
  setpixel(adc,maxx,0,randomcolour);
  setpixel(adc,maxx,maxy,randomcolour);
  setpixel(adc,mid(0,maxx),0,randomcolour);
  setpixel(adc,mid(0,maxx),maxy,randomcolour);
  setpixel(adc,0,mid(0,maxy),randomcolour);
  setpixel(adc,maxx,mid(0,maxy),randomcolour);
  quarter(0,0,maxx,maxy);
  end;

procedure TPlasmaWindow.WMRButtonDown(var Msg:TMessage);
begin
  destroy;
end;

function TPlasmaWindow.getclassname:pchar;
begin
  getclassname:='Cloud Window';
end;

procedure TPlasmaWindow.getwindowclass(var awndclass:twndclass);
begin
  inherited getwindowclass(awndclass);
  awndclass.hbrbackground:=getstockobject(white_brush);
end;

var DitherApp:TMyApp;

begin
  DitherApp.init('Cloud');
  DitherApp.run;
  DitherApp.done;
end.
