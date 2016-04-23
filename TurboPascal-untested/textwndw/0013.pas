
unit windows;

interface
uses crt;

procedure sh;
procedure sn;
procedure Drawbox(x1,y1,x2,y2: byte);
procedure PopWindow(x1,y1,x2,y2: byte);
procedure CloseWindow;
procedure Drawshadowbox(x1,y1,x2,y2: byte);
procedure shh;
procedure snn;

const
 color: boolean = true;

type
 windowtype = record
               x1,x2,y1,y2: byte;
               scrsave: array[1..4096] of byte;
              end;
 scrarray= array[1..4096] of byte;
 scrptr= ^scrarray;
const
 screenbase: word =$B800;
var
 numwindows: byte;
 ws: array[1..3] of windowtype;
 cursorpos: integer;
 fileabs: array[1..20] of word;
 searchdir: byte;
 searchwild: string;
 searchdate: string;
 searchuploader: string;
 searchsize: longint;
 searchtext: string;
 numindex: word;
 sortprimary,sortsecondary: byte;
 filelow: longint;
 numentries: byte;

procedure textcolor(i: byte);
procedure textbackground(i: byte);

implementation

procedure Textcolor(i: byte);
begin;
 if color then crt.textcolor(i) else begin;
  case i of
    0: crt.textcolor(0);
    7: crt.textcolor(7);
   11..15: crt.textcolor(15);
  end;
 end;
end;

procedure TextBackGround(i: byte);
begin;
 if color then crt.textbackground(i) else begin;
  case i of
   0..6: crt.textbackground(0);
   7: crt.textbackground(7);
  end;
 end;
end;

procedure sh;
begin;
 if color then begin;
  textcolor(blue);
  textbackground(7);
 end else begin;
  textcolor(0);
  textbackground(7);
 end;
end;

procedure sn;
begin;
 textcolor(white);
 textbackground(blue);
end;

procedure Drawbox(x1,y1,x2,y2: byte);
var
 x,y: byte;
begin;
 gotoxy(x1,y1);
 for x:=x1+1 to x2 do write('═');
 gotoxy(x1,y2);
 for x:=x1+1 to x2 do write('═');
 for y:=y1+1 to y2-1 do begin;
  gotoxy(x1,y);
  write('│');
  gotoxy(x2,y);
  write('│');
 end;
 gotoxy(x1,y1);
 write('╒');
 gotoxy(x2,y1);
 write('╕');
 gotoxy(x1,y2);
 write('╘');
 gotoxy(x2,y2);
 write('╛');
end;

procedure PopWindow(x1,y1,x2,y2: byte);
begin;
 inc(numwindows);
 ws[numwindows].x1:=lo(windmin)+1;
 ws[numwindows].x2:=lo(windmax)+1;
 ws[numwindows].y1:=hi(windmin)+1;
 ws[numwindows].y2:=hi(windmax)+1;
 move(mem[screenbase:0000],ws[numwindows].scrsave,4096);
 window(1,1,80,25);
 drawbox(x1,y1,x2,y2);
 window(x1+1,y1+1,x2-1,y2-1);
end;

procedure CloseWindow;
begin;
 move(ws[numwindows].scrsave,mem[screenbase:0000],4096);
 window(ws[numwindows].x1,ws[numwindows].y1,ws[numwindows].x2,ws[numwindows].y2);
 dec(numwindows);
end;

procedure Drawshadowbox(x1,y1,x2,y2: byte);
var
 x,y: byte;
begin;
 textbackground(0);
 textcolor(7);
 gotoxy(x1,y1);
 for x:=x1+1 to x2 do write('═');
 gotoxy(x1,y2);
 for x:=x1+1 to x2 do write('═');
 for y:=y1+1 to y2-1 do begin;
  gotoxy(x1,y);
  write('│');
  gotoxy(x2,y);
  write('│');
 end;
 gotoxy(x1,y1);
 write('╒');
 gotoxy(x2,y1);
 write('╕');
 gotoxy(x1,y2);
 write('╘');
 gotoxy(x2,y2);
 write('╛');
 textcolor(7);
 textbackground(0);
 for y:=y1+1 to y2+1 do begin;
  gotoxy(x2+1,y);
  write(' ');
 end;
 for x:=x1+1 to x2+1 do begin;
  gotoxy(x,y2+1);
  write(' ');
 end;
end;

procedure shh;
begin;
 textcolor(0);
 textbackground(7);
end;

procedure snn;
begin;
 textcolor(7);
 textbackground(0);
end;

end.