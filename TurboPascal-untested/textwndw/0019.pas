
unit testwin2;

interface
uses crt;
procedure Popbox(x1,y1,x2,y2,UPborder,DNborder,Back: byte);
procedure CloseBox;
Procedure SaveScreen;
Procedure RestoreScreen;
procedure Cursoron;
procedure Cursoroff;
type
 windowtype = record
               x1,x2,y1,y2: byte;
               scrsave: array[1..4096] of byte;
              end;
 scrarray= array[0..3999] of byte;
 scrptr= ^scrarray;
 AScreen = Array[1..4000] of Byte;
const
 screenbase: word =$B800;
var
 Screen: scrarray Absolute $B800:$0;
 numwindows: byte;
 ws: array[1..3] of windowtype;
 scr1,scr2,scr3: scrptr;
 P : ^AScreen;    {Pointer to the Array}
 Scr : AScreen;
 CursorType : word;

implementation

procedure Cursoroff; assembler;

    asm
        mov ah, 03h
        mov bh, 00h
        int 10h
        mov CursorType, cx
        mov ah, 01h
        mov cx, 65535
        int 10h
    end;

procedure Cursoron; assembler;

    asm
        mov ah, 01h
        mov cx, CursorType
        int 10h
    end;

Procedure SaveScreen;
begin
  P := Ptr($B800,$0); {Point to video memory}
  Move(P^,Scr,4000);  {Move the screen into the Array}
end;

Procedure RestoreScreen;
begin
  Move(Scr,MEm[$B800 : 0], 4000); {Move the saved screen to video mem}
end;

procedure Popbox(x1,y1,x2,y2,UPborder,DNborder,back: byte);
var
 x,y: byte;
begin;
 window(1,1,80,25);
 textcolor(UPborder);
 textbackground(Back);
 gotoxy(x1,y1);
 for x:=x1+1 to x2 do write('─');
 textcolor(dnborder);
 gotoxy(x1,y2);
 for x:=x1+1 to x2 do write('─');
 for y:=y1+1 to y2-1 do begin;
  textcolor(upborder);
  gotoxy(x1,y);
  write('│');
  textcolor(dnborder);
  gotoxy(x2,y);
  write('│');
 end;
 textcolor(upborder);
 gotoxy(x1,y1);
 write('┌');
 textcolor(dnborder);
 gotoxy(x2,y1);
 write('┐');
 textcolor(upborder);
 gotoxy(x1,y2);
 write('└');
 textcolor(dnborder);
 gotoxy(x2,y2);
 write('┘');
 inc(numwindows);
 ws[numwindows].x1:=lo(windmin)+1;
 ws[numwindows].x2:=lo(windmax)+1;
 ws[numwindows].y1:=hi(windmin)+1;
 ws[numwindows].y2:=hi(windmax)+1;
 move(mem[screenbase:0000],ws[numwindows].scrsave,4096);
 window(x1+1,y1+1,x2-1,y2-1);
 clrscr;
 gotoxy(1,1);
end;

procedure CloseBox;

begin;
 move(ws[numwindows].scrsave,mem[screenbase:0000],4096);
 window(ws[numwindows].x1,ws[numwindows].y1,ws[numwindows].x2, {editor wrap}
                                                          ws[numwindows].y2);
 dec(numwindows);
end;
end.

{ ------------------------------   DEMO PROGRAM  ---------------------- }

Program Demo_for_testwin2;

uses crt,testwin2;
begin;
 cursoroff;
 new(scr1);
 new(scr2);
 textcolor(0);
 textbackground(7);
 clrscr;
gotoxy(30,12);
write('Main Screen');
savescreen;
 readkey;
 Popbox(17,9,62,17,15,0,3);
 writeln('     Window one');
 move(mem[screenbase:0000],scr1^,4096);
 readkey;
 Popbox(25,3,40,22,10,0,2);
 writeln('Window two');
 move(mem[screenbase:0000],scr2^,4096);
 readkey;
 Popbox(8,12,65,20,12,0,4);
 writeln('Window three');
 readkey;
 CloseBox;
 move(scr2^,mem[screenbase:0000],4096);
 readkey;
 CloseBox;
 move(scr1^,mem[screenbase:0000],4096);
 readkey;
 restorescreen;
 readkey;
  cursoron;
 end.

