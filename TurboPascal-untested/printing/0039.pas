{
From: randyd@alpha2.csd.uwm.edu (Randall Elton Ding)

>Does anyone have any code that shows how one might print some graphics
>on a 9 or 24-pin Epson compatible dot-matrix printer?  I'm specifically

I pulled this out of my graphstuff unit which I made years ago.  It
was designed for my epson mx100 (thats mx not fx) printer... early 80's.
The mx printer has 9 pins and only 8 are used for graphics.
Hopefully the escape codes are the same for your newer epson.
}

program foo;

uses graph;

const
  rotate90 = true;
  widepaper = false;


procedure developgraph(rotate: boolean);
                            { if passed parameter is true, the graphics
                              image will be rotated 90 degrees to fit on
                              a narrow sheet of printer paper, if false
                              the image will completely fill the wide
                              paper erect and double height }

  const maxprinter = 816;   { maximum pixel width of printer }

  var
    graphwidth,graphheight,printerwidth,printerheight: integer;
    n1,n2,sx,sy,x,y,y2,pixcolr: integer;
    widthratio,heightratio: real;
    blank: boolean;
    bitloc,bits: byte;
    bytes: array [1..maxprinter] of byte;
    lst: text;

  begin
    assign(lst,'lpt1');
    rewrite(lst);
    case rotate of
      widepaper: begin                       { develop erect on wide paper }
                   graphwidth:= getmaxx+1;
                   graphheight:= getmaxy+1;
                   printerwidth:= maxprinter;       { scale 1.275 x 2 }
                   printerheight:= graphheight*2;
                 end;
      rotate90:  begin                     { if rotate then reverse x and y }
                   graphwidth:= getmaxy+1;
                   graphheight:= getmaxx+1;
                   printerwidth:= graphwidth;       { scale 1 x 1 }
                   printerheight:= graphheight;
                 end;
    end;
    n2:= printerwidth div 256;
    n1:= printerwidth mod 256;
    write (lst,chr(27),'A',chr(8));   { set line spacing to 8 }
    widthratio:= printerwidth/graphwidth;
    heightratio:= printerheight/graphheight;
    y:= 0;
    while y < printerheight do begin
      blank:= true;    { remains true if entire printer pass is blank }
      for x:= 1 to printerwidth do begin
        sx:= trunc ((x-1)/widthratio);  { screen x coorid }
        bits:= 0;
        bitloc:= $80;
        for y2:= y to y+7 do begin
          sy:= trunc(y2/heightratio);  { screen y coorid }
          if sy < graphheight then begin { last printer pass is incomplete }
            case rotate of
              widepaper: pixcolr:= getpixel (sx,sy);
              rotate90:  pixcolr:= getpixel (sy,sx);   { x and y swaped }
            end;
            if pixcolr > 0 then bits:= bits or bitloc;
          end;
          bitloc:= bitloc shr 1;
        end;
        case rotate of
          widepaper: bytes [x]:= bits;
          rotate90:  bytes [printerwidth-x+1]:= bits;  { reverse image }
        end;
        if bits > 0 then blank:= false; { have something to print this pass }
      end;
      if not blank then begin    { line feed if nothing to print this pass }
        write (lst,chr(27),'K',chr(n1),chr(n2));  { set printer graph mode }
        for x:= 1 to printerwidth do write (lst,chr(bytes[x]));
      end;
      writeln (lst);   { output 8 printer pixels high per pass }
      y:= y+8;
    end;
    write (lst,chr(12));       { top of form }
    write (lst,chr(27),'@');   { re-initalize printer }
    close(lst);
  end;

Var
  gd, gm,
  Count  : Integer;


begin
  { Demo By Kerry Sokalsky - SWAG Support Team }

  Gd := Detect;
  InitGraph(gd, gm, 'e:\bp\bgi');

  For Count := 1 to 100 do
    Circle(Random(500) + 50, Random(380) + 50, Random(50));

  Readln;
  DevelopGraph(False);
  Readln;

end.
