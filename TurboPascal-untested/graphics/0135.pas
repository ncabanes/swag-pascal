{
From: yliu@morgan.ucs.mun.ca (Yuan Liu)

: I have a question for drawing a graphic.  I have a set of data.
: I want to read these data and plot them in the XY axes.  Does anyone
: know how to caculate the data to fit the X axis.  I am using TP 7.0.

When converting from HP Pascal, which provides a nice subset of the
device-independent graphics kernal and allows plotting in the virtual world
(so the window and viewport can be set in the virtual world), I wrote
several procedures to simulate virtual world plotting.  The following is
part of a unit Plotbase I created.

The function you needed is set_window; the boolean pagefit controls
whether you just want your plot to fit in the whole window or there's a concern
about the isotropy of the plot.  I didn't bother to write a virtual
world set_viewport as I can live without it.

}
UNIT PLOTBASE; {******************* Stored in 'PLOTBASE' ******************}
{*     Basic procedures for graphical manipulations.                      *}
{*     Created in 1983.  Updated 17/05/94 10:00 a.m.       By LIU Yuan    *}
{**************************************************************************}
interface USES Graph;
procedure set_window(left, right, up, down: extended; pagefit: boolean);
         {Sets a mapping of virtual window on the current viewport;
           use isotropic scaling if not pagefit.}
function vToX(x: extended): integer;
function vToY(y: extended): integer;
         {Map x, y in the virtual world onto real world}
function XtoV(X: integer): extended;
function YtoV(Y: integer): extended;
         {Maps X, Y in the real world onto virtual world}
           use isotropic scaling if not pagefit.
procedure vMove(x, y: extended);
          {Moves the current position to (x,y) in the virtual world}
procedure vMoveRel(Dx, Dy: extended);
{Moves the current position a relative distance in the virtual world}
procedure vLine(x1, y1, x2, y2: extended);
          {Draws a line from (x1,y1) to (x2,y2) in the virtual world}
procedure vLineTo(x, y: extended);
          {Draws a line from current position to (x,y) in the virtual world}
function str_width(str: string): extended; {string width in the virtual world}
function str_height(str: string): extended; {string height in the virtual
world}
implementation {************************** PLOTBASE *************************}
        var Text:         string[20];
            xasp, yasp, xbase, ybase: extended;
            {convert from virtual world to display}

procedure set_window(left, right, up, down: extended; pagefit: boolean);
         {Sets a mapping of virtual window on the current viewport;
           use isotropic scaling if not pagefit.
           Side effects: xasp, yasp, xbase, ybase.}
var view: ViewPortType;
begin xbase:=left; ybase:=down; right:=right-left; up:=up-down;
      GetViewSettings(view);
      right:=(view.x2-view.x1)/right;
      up:=(view.y2-view.y1)/up;
      if pagefit then begin xasp:=right; yasp:=up end
      else if right<up then begin yasp:=right; xasp:=right; end
                       else begin xasp:=up; yasp:=up end
end; {set_window}

function vToX(x: extended): integer;begin vToX:=round((x-xbase)*xasp) end;
         {Maps x in the virtual world onto real world}
function vToY(y: extended): integer;begin vToY:=round((y-ybase)*yasp) end;
         {Maps x in the virtual world onto real world}

function XtoV(X: integer): extended; begin XtoV:=X/xasp+xbase end; {XtoV}
         {Maps X in the real world onto virtual world}
function YtoV(Y: integer): extended; begin YtoV:=Y/yasp+ybase end; {YtoV}
         {Maps Y in the real world onto virtual world}

procedure vMove(x, y: extended);
          {Moves the current position to (x,y) in the virtual world}
begin MoveTo(round((x-xbase)*xasp),round((y-ybase)*yasp)) end; {vMove}
procedure vMoveRel(Dx, Dy: extended);
{Moves the current position a relative distance in the virtual world}
begin MoveRel(round(Dx*xasp),round(Dy*yasp)) end; {vMoveRel}

procedure vLine(x1, y1, x2, y2: extended);
          {Draws a line from (x1,y1) to (x2,y2) in the virtual world}
begin line(round((x1-xbase)*xasp),round((y1-ybase)*yasp),
           round((x2-xbase)*xasp),round((y2-ybase)*yasp)) end; {vLine}

procedure vLineTo(x, y: extended);
          {Draws a line from current position to (x,y) in the virtual world}
begin LineTo(round((x-xbase)*xasp),round((y-ybase)*yasp)) end; {vLineTo}

function str_width(str: string): extended; {string width in the virtual world}
begin str_width:=TextWidth(str)/xasp end; {str_width}

function str_height(str: string): extended; {string height in the virtual
world}
begin str_height:=TextHeight(str)/yasp end; {str_height}
