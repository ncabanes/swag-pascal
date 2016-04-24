(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0039.PAS
  Description: Offscreen Bitmaps-Windows
  Author: PETER GRUHN
  Date: 08-25-94  09:12
*)

{
From: peter.gruhn@delta.com (Peter Gruhn)

 Ka> I've had little luck in finding out how to do more general drawing in
 Ka> an offscreen bitmap (say, with a compatible bitmap created from an
 Ka> HWindow's DC).

I'm assuming you have a DC already off screen that you can blit from?
You can draw to it too. Just like a normal DC. I'm worrying now that I
don't quite understand either your problem or just what your code looks
like.

 Ka> Many thanks for your help.

Hey, it's late, I'll see what I can write...there didn't take long. I
was able to draw rectangles off screen and blit them to the main window.
You ought to be able to do whatever drawing function you want. I took
some short cuts regarding colour depth and bitmap size (hard coding
rules OK!)

by Peter Gruhn
 it's small and useless and stupid and somebody
 might find it useful, so I release this program
 into the public domain for the good of all
 sentient species the universe over. 7-8-1994
}

program offscree;

{you have tpw not bp? your uses will be a little different}
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
