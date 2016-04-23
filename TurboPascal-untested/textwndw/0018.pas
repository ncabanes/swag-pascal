{ very simple windowing routine. This allow you to define a text window with
borders, and upper and lower label. The ascii code for corners and lines is
the portuguese version. I'm not sure if it'll work well in the International
code. If it doesn't just replace the symbols by the correct ones (also to
change from double to single line border). This is freeware. No guarantees.
Made by Luis Evaristo Fonseca, Thunderball Software Inc., 1994 Portugal }

{ Parameters for makewindow:
       (x1,y1) upper left corner coordinates;
       (x2,y2) lower right corner coordinates;
       ctxt    text color;
       cfnd    background color (numbers bigger than 7 are blinking colors);
       title   upper title (lefty);
       bottom  bottom note (centered);

  Hidecursor:
       Simply hides the cursor;

  Showcursor:
       Makes the cursor visible again;

  Setcolor:
       Changes text/back color, by changing values in textattr;
}


unit windows;
interface
uses crt;

procedure makewindow(x1,y1,x2,y2,ctxt,cfnd:integer;title,bottom:string);
procedure hidecursor;
procedure showcursor;
procedure setcolor(f,b:integer);

implementation

{****************************************************************************}
procedure setcolor(f,b:integer);
begin
    textattr := f + b * 16;
end;
{****************************************************************************}
procedure hidecursor; assembler;
asm
    mov   ax,$0100
    mov   cx,$2607
    int   $10
end;
{****************************************************************************}
procedure showcursor; assembler;
asm
    mov   ax,$0100
    mov   cx,$0506
    int   $10
end;
{****************************************************************************}
procedure makewindow(x1,y1,x2,y2,ctxt,cfnd:integer;title,bottom:string);
var c1,c2:integer;
    sattr:byte;
begin
    if (x1+1>x2) or (y1+1>y2) then
        exit;
    sattr:=textattr;
    hidecursor;
    setcolor(cfnd,ctxt);
    c2:=x1;
    for c1:=y1 to y2 do
    begin
        for c2:=x1 to x2 do
        begin
            gotoxy(c2,c1);
            write(' ');
        end;
    end;
    gotoxy(x1,y1);
    write('╔');
    for c1:=x1+1 to x2-1 do
        write('═');
    write('╗');
    for c1:=y1+1 to y2-1 do
    begin
        gotoxy(x1,c1);
        write('║');
        gotoxy(x2,c1);
        write('║');
    end;
    gotoxy(x1,y2);
    write('╚');
    for c1:=x1+1 to x2-1 do
        write('═');
    write('╝');
    if (title<>'') and (length(title)<x2-x1-4) then
    begin
        gotoxy(x1+1,y1);
        write('╣ '+title+' ╠');
    end;
    if (bottom<>'') and (length(bottom)<x2-x1-9) then
    begin
        gotoxy(x1+((x2-x1) div 2 - length(bottom) div 2 - 2),y2);
        write('╣ '+bottom+' ╠');
    end;
    gotoxy(x1+1,y1+1);
    showcursor;
    textattr:=sattr;
end;
end.