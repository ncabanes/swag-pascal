{
> I used something like this:
> for x := 1 to 100 do
> begin
>      y := slope*x;
>      putpixel(x,y);
> end;

the slope method is a close cousin to bubble-sort an algorithm to use if
you can't be bothered to use a more efficient one for the job.

here's one. that only uses addition and subtraction in it's loop.
(FWIW it's based on the commutativity of multiplication.)

I think It's got some fancy name which I forget, this code is 100% my
own (freeware) and reasonably well tested.
}

  procedure myline(x1,y1,x2,y2,color:integer);

    {Freeware: my bugs - your problem , 29 dec 1993 J.Betts,
     PASCAL echo Fidonet.     please keep this notice intact}

  function sign(x:integer):integer; {like sgn(x) in basic}
  begin if x<0 then sign:=-1 else if x>0 then sign:=1 else sign:=0 end;
  var
    x,y,count,xs,ys,xm,ym:integer;
  begin
    x:=x1;y:=y1;

    xs:=x2-x1;    ys:=y2-y1;

    xm:=sign(xs); ym:=sign(ys);
    xs:=abs(xs);  ys:=abs(ys);

    putpixel(x,y,color);

  if xs > ys
    then begin {flat line <45 deg}
      count:=-(xs div 2);
      while (x <> x2 ) do begin
        count:=count+ys;
        x:=x+xm;
        if count>0 then begin
          y:=y+ym;
          count:=count-xs;
          end;
        putpixel(x,y,color);
        end;
      end
    else begin {steep line >=45 deg}
      count:=-(ys div 2);
      while (y <> y2 ) do begin
        count:=count+xs;
        y:=y+ym;
        if count>0 then begin
          x:=x+xm;
          count:=count-ys;
          end;
        putpixel(x,y,color);
        end;
      end;
  end;

