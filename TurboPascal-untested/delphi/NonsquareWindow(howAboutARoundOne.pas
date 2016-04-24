(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0361.PAS
  Description: Non-square window (how about a round one
  Author: MIKE RYAN
  Date: 01-02-98  07:33
*)


procedure TForm1.FormCreate(Sender: TObject);
var
    R: HRgn;
    P: array [0..360] of TPoint;
    x,y,radius,c1,c2,theta:integer;
begin
       radius:=200;
       c1:=300; // center x
       c2:=300; // center y
       for theta:=0 to 360 do
       begin
            x:=c1+round(radius * cos(theta));
            y:=c2+round(radius * sin(theta));
            p[theta]:=point(x,y);
       end;

    //   R := CreatePolygonRgn (P , 360 , ALTERNATE);
       R := CreatePolygonRgn (P , 360 , WINDING);
       SetWindowRgn(Form1.Handle, R , TRUE);
end;

Yes you have to use the CreatePolygonRgn  and SetWindowRgn. In this
example I create a round form, you would have to watch you coordinates
to ensure you have the title bar still visible at the top so you can
move your form, either that or you would have to implement the
functionality yourself. Create whatever shape you want using an array of
TPoint and CreatePolygonRgn

