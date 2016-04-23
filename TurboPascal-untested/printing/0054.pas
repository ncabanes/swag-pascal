{Ron Nossaman}
uses crt,printer;
var x,gridinc,y:integer;

begin
   write(lst,#27,'E');
(*
   write(lst,#27,'*r0F');    {no rotation}
   write(lst,#27,'*p300X');  {Set cursor position}
   write(lst,#27,'*t300R');    {raster graphics @300dpi}
   write(lst,#27,'*r1A');      {start graphics - current cursor}
*)
   gridinc:=40;
   x:=0; y:=0;
   while x<=3750 do
 {  for x:=0 to 50 do  }          {75*50=3750}
   begin
      write(lst,#27,'*p',x,'X');
      write(lst,#27,'*p1Y');
      write(lst,#27,'*c2A');
      write(lst,#27,'*c3000B');
      write(lst,#27,'*c0p');
      x:=x+gridinc;
   end;
   while y<=6000 do
{   for y:=0 to 80 do }          {75*80=6000}
   begin
      write(lst,#27,'*p1X');
      write(lst,#27,'*p',y,'Y');
      write(lst,#27,'*c3000A');
      write(lst,#27,'*c2B');
      write(lst,#27,'*c0p');
      y:=y+gridinc;
   end;


  write(lst,#27,#38,#108,#48,#72);    {page feed}
end.
