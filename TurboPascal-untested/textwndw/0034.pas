unit banner;
{ Note: Specify target pascal version - or USE_STRING if unsure }
{$DEFINE USE_STRING}
{*DEFINE USE_PCHAR}

interface

{$IFDEF USE_PCHAR}
uses crt,strings;
{$ELSE}
uses crt;
{$ENDIF}

{ BANNER object by Emil Mikulic }
type PBanner=^TBanner;
     TBanner=object
{$IFDEF USE_PCHAR}
      caption:PChar;
      len:word;
{$ELSE}
      caption:string;
{$ENDIF}
      y,attr:byte;
      constructor init(yy:byte; s:string; fg,bg:byte);
      procedure draw;
      destructor done;
      end;

procedure drawbanner(y:byte; s:string; fg,bg:byte);

implementation

constructor TBanner.init(yy:byte; s:string; fg,bg:byte);
begin
 { Set y position }
 y:=yy;
 { Calculate textattr from fg color and bg color }
 attr:=fg or (bg shl 4);
{$IFDEF USE_PCHAR}
 { Get the length }
 len:=length(s);
 { Allocate memory }
 getmem(caption,len+1);
 { Set the string }
 StrPCopy(caption,s);
{$ELSE}
 caption:=s;
{$ENDIF}
end;

procedure TBanner.draw;
var tmp:byte;
    ox,oy:byte;
begin
 { Save current position }
 ox:=wherex;
 oy:=wherey;
 { Go to Y line }
 gotoxy(1,y);
 { Save current textattr }
 tmp:=textattr;

 { Set textattr }
 textattr:=attr;
 { Paint strip of color }
 clreol;

 { Gotoxy centred beginning of caption }
 gotoxy((80-length(caption)) div 2,y);
 { Paint banner }
 writeln(caption);

 { Return to saved position }
 textattr:=tmp;
 gotoxy(ox,oy);
end;

destructor TBanner.done;
begin
{$IFDEF USE_PCHAR}
 { Free up the string }
 freemem(caption,len+1);
{$ENDIF}
end;

{ --------------------------------------------------------------------
  DRAWBANNER
  by Emil Mikulic

  Input:
   y - the y position of the banner
   s - the banner text
   fg - the foreground color
   bg - the background color

  Output:
   writes a centred, colored banner according to the input

  Notes:
   Uses my BANNER object
  -------------------------------------------------------------------- }
procedure drawbanner(y:byte; s:string; fg,bg:byte);
var tmp:PBanner;
begin
 { Take a big piece of plastic and paint it }
 tmp:=new(PBanner,init(y,s,fg,bg));
 { Go to town hall and put it up }
 tmp^.draw;
 { Go wash your hands }
 dispose(tmp,done);
end;

end.

{ -------------------------- CUT ------------------------------ }

BANNER Unit Documentation

by Emil Mikulic

BANNER comes in two different versions
in the same file. If you have Borland Pascal or your
Pascal compiler supports the STRINGS unit then use the
{$DEFINE USE_PCHAR} because it's more memory-efficient.
If you're not sure or have Turbo Pascal 6.0 or 7.0 then
use {$DEFINE USE_STRING} and make sure that only one has the $
and the other one has a {*DEFINE ...} If you have another
pascal compiler or you're not sure then USE_STRING. :)

Creating a banner is simple, you need to define a variable as
a PBanner and then use var:=new(PBanner,init(...));

The syntax for the BANNER init is simple:
  constructor init(yy:byte; s:string; fg,bg:byte);

YY specifies which line the banner will be on. S is the
banner string. FG and BG are the foreground and background
colors respectively.

To draw the banner just use
  procedure draw;

And make sure you use
  destructor done;
to free up the leftover memory;

If you don't want to do all that, you can use the
  procedure drawbanner(y:byte; s:string; fg,bg:byte);

The syntax is just like the BANNER init except it
draws the banner and dismantles it.

Here's the source for drawbanner which is also a good
example on how to use the BANNER.

procedure drawbanner(y:byte; s:string; fg,bg:byte);
var tmp:PBanner;
begin
 tmp:=new(PBanner,init(y,s,fg,bg));
 tmp^.draw;
 dispose(tmp,done);
end;

Sure, you could just use DRAWBANNER and forget the BANNER object
but that's no fun. If you're creative you can get
it to flash colors (by changing banner.attr) or move up and
down (banner.y) - on a sinecurve? Or scroll the text
(banner.caption)

That's it.
Emil Mikulic, 1997.

