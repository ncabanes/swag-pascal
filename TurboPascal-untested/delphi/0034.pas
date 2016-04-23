
Okay, its late, and I've been playing with Delphi.  I just wrote out a
simple little program that will allow you to control the size of a form when 
its maximized.  It does this in such a way as to remove the flickering that 
you see if you've been adjusting the size via the resize event.  Basically, 
this code traps the wm_getminmaxinfo message. To use this style form instead 
of the Delphi standard, simply compile the following text pascal file into a 
DCU. In then replace occurences of TForm with TMaxForm and add (if you
called the pascal file maxform.pas) maxform to your uses clause.  Here 
now is the short program:

unit Maxform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TMaxForm = class(TForm)
  private
    { Private declarations }
    fmh, fmw, fml, fmt : word;
    procedure mymax(var m: TWMGETMINMAXINFO);
              message wm_getminmaxinfo;
  published
    property maxheight : word read mh write mh;
    property maxwidth  : word read mw write mw;
    property maxleft   : word read ml write ml;
    property maxtop    : word read mt write mt;
    constructor create(AOwner : TComponent); override;
  end;

implementation

procedure TMaxForm.mymax(var m : TWMGETMINMAXINFO);
begin
m.minmaxinfo^.ptmaxsize.x := fmw;
m.minmaxinfo^.ptmaxsize.y := fmh;
m.minmaxinfo^.ptmaxposition.x := fml;
m.minmaxinfo^.ptmaxposition.y := fmt;
end;

constructor TMaxForm.create(Aowner : TComponent);
begin
fmw := screen.width;
fmh := screen.height;
fmt := 0;
fml := 0;
inherited create(aowner);
end;
end.

