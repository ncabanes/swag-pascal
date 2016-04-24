(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0041.PAS
  Description: Windows Shell!
  Author: PETER GRUHN
  Date: 08-25-94  09:13
*)

{
From: peter.gruhn@delta.com (Peter Gruhn)

 Ba> What I want to know is, can some-one post a sample of source code
 Ba> that would provide a 'beginners shell' for windows programming. I.e.

How about if I post this test code that somebody wanted a few days ago.
It has no interaction and doesn't bother to make use of the timer or
anything in the draw loop, but it's a quick draw loop. You can set up
timers and i/o responses as you see fit. Right off though, just having a
window to draw in is a good start. It's how I started...

by Peter Gruhn
 it's small and useless and stupid and somebody
 might find it useful, so I release this program
 into the public domain for the good of all
 sentient species the universe over. 7-8-1994}

program offscree;

uses owindows,winprocs,wintypes;

type
  TMyApp=object(tapplication)
    procedure initmainwindow; virtual;
    end;

  PMyWin=^TMyWin;
  TMyWin=object(TWindow)
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    end;

procedure TMyApp.initmainwindow;
begin
  mainwindow:=new(pmywin,init(nil,'Try this...'));
end;

procedure TMyWin.Paint;
var adc:hdc;
    abmp:hbitmap;
    i:integer;
    s:string;
begin
{Create stuff}
  adc:=createcompatibledc(paintdc);
  {I believe that I am cheating here, by just divving number of bits
   by 2 as I happen to know that right now I am in 16 colour mode.
   You will forgive me.}
  abmp:=createcompatiblebitmap(paintdc,300 div 2,300 div 2);
  abmp:=selectobject(adc,abmp);

{Blank off screen bitmap of random data}
  bitblt(adc,0,0,300,300,adc,0,0,whiteness);

{Draw something}
  for i:=0 to 1024 do
    begin
    rectangle(adc,random(300),random(300),random(300),random(300));
    str(i:5,s);                    {textify i for...}
    s[6]:=#0;                      {null terminator}
    textout(paintdc,10,10,@(s[1]),byte(s[0])); {just to count so it don't look
plain}
    end;

{blit it to the window}
  bitblt(paintdc,10,10,300,300,adc,0,0,srccopy);

{Kill stuff}
  deleteobject(selectobject(adc,abmp));
  deletedc(adc);
end;

var app:TMyApp;

begin
  app.init('frog');
  app.run;
  app.done;
end.

