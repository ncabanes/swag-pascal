(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0399.PAS
  Description: Rotating textout
  Author: SEAN MATHEWS
  Date: 01-02-98  07:34
*)


Have a look at the procedure now, Should give you some clues...
You have to be sure of two things
1. You are using a True Type Font.
2. If you use an TImage, you set the font of the Image CANVAS first.

Sean

----------
procedure DC_TextOut(x,y,angle,size:integer;txt:string);
var hfont, fontold      : integer;
    dc                          : hdc;
    fontname                    : string;

begin
Image1.Canvas.Font.Name := 'Arial';
if length(txt)= 0 then exit;
     dc := Image1.Canvas.handle;  (Here ??? handle from component not from
activeform)
     SetBkMode(dc,transparent);
     fontname := Image1.Canvas.font.name;  (Here ??? handle from component
not from activeform)
     hfont   :=
CreateFont(-size,0,angle*10,0,fw_normal,0,0,0,1,4,$10,2,4,PChar(fontname));
     fontold := SelectObject(dc,hfont);
     TextOut(dc,x,y,PChar(txt),length(txt));
     SelectObject(dc, fontold);
     DeleteObject(hfont);
end;

