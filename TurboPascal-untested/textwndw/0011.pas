{ WRITTEN BY TIM SCHEMPP
  OCTOBER 21, 1993       }

unit drawline;

interface

   procedure horizline(x1,x2,y:integer; default:char);
   procedure vertline(x,y1,y2:integer; default:char);
   procedure rectlines(x1,y1,x2,y2:integer; default:char);

{ IF writetomemory IS SET TO TRUE, LINES WILL BE DRAWN AN AVERAGE OF
  ABOUT 15 TO 20 PERCENT FASTER THAN IF writetomemory IS SET TO FALSE.
  HOWEVER, IF DATA IS WRITTEN DIRECTLY TO VIDEO MEMORY, YOU ARE STUCK WITH
  THE SCREENS CURRENT COLORS (TEXTCOLOR AND TEXTBACKGROUND HAVE NO EFFECT).
  THE DEFAULT VALUE OF writetomemory IS FALSE. }

var writetomemory:boolean;

implementation
 uses crt; {for gotoxy, wherex and wherey}

     const symbols:array[1..40] of char=
                      ('│','┤','╡','╢','╖','╕','╣','║','╗','╝','╜','╛','┐',
                       '└','┴','┬','├','─','┼','╞','╟','╚','╔','╩','╦','╠',
                       '═','╬','╧','╨','╤','╥','╙','╘','╒','╓','╫','╪','┘',
                       '┌');

           codes:array[1..40] of string[4]=
                    ('1010','1011','1012','2021','0021','0012','2022','2020',
                     '0022','2002','2001','1002','0011','1100','1101','0111',
                     '1110','0101','1111','1210','2120','2200','0220','2202',
                     '0222','2220','0202','2222','1202','2101','0212','0121',
                     '2100','1200','0210','0120','2121','1212','1001','0110');

            {THE SCREEN DIMENSIONS}
            screenwidth=80;   screenlength=25;

{******}

{READS A CHARACTER FROM VIDEO MEMORY AT THE GIVEN COORDINANTS}
function Memread(col,row:integer):char;

  Const
    Seg = $B000; { Video memory address for color system  }
    Ofs = $8000; { For monochrome system, make Ofs = $0000 }
  Var
    SChar : Integer;
  Begin
          SChar := ((Row-1)*160) + ((Col-1)*2); { Compute starting location }
          memread:=chr(Mem[Seg:Ofs + SChar]);   { read character from memory}
  End;

{******}

{WRITES A CHARACTER DIRECTORY TO VIDEO MEMORY AT THE GIVEN COORDINATES}
{NOTE: THE CURRENT COLORS AT THE GIVEN COORDINANTS ARE USED FOR DRAWING.}
procedure Memwrite(col,row:integer; c:char);

  Const
    Seg = $B000; { Video memory address for color system  }
    Ofs = $8000; { For monochrome system, make Ofs = $0000 }
  Var
    SChar : Integer;
  Begin
          SChar := ((Row-1)*160) + ((Col-1)*2); { Compute starting location }
          Mem[Seg:Ofs + SChar]:=ord(c);         { write character to memory}
  End;

{******}

   {PROCEDURE USED INTERNALLY TO CREATE A SET OF CHARACTER CODES}
   function getcode(c:char; direction:byte):char;
   var counter:integer;
   begin
    counter:=1;
    while (counter<=40) and (c<>symbols[counter]) do inc(counter);
    if counter>40 then getcode:='0' else getcode:=codes[counter,direction];
   end;

{******}

   {PROCEDURE DRAWS A LINE IN TEXT MODE FROM (X1,Y) TO (X2,Y)}
   {DEFAULT IS EITHER '1' OR '2' FOR SINGLE OF DOUBLE LINES}
   procedure horizline(x1,x2,y:integer; default:char);

    var code:string[4];
        defaultchar:char;
        c,index:integer;
        xpos,ypos:integer;

    begin
     xpos:=wherex; ypos:=wherey;
     if x2<x1 then begin c:=x1; x1:=x2; x2:=c; end;
     if default='1' then defaultchar:=symbols[18]
                    else defaultchar:=symbols[27];
     for c:=x1 to x2 do
      begin
       code:='0000';
       if y<>0 then code[1]:=getcode(memread(c,y-1),3) else code[1]:='0';
       if (c=x2) and (x2=screenwidth) then code[2]:='0'
          else if (c=x2) then code[2]:=getcode(memread(x2+1,y),4)
                         else code[2]:=default;
       if y<>screenlength then code[3]:=getcode(memread(c,y+1),1)
                          else code[3]:='0';
       if (c=x1) and (x1=1) then code[4]:='0'
          else
           if (c=x1) then code[4]:=getcode(memread(x1-1,y),2)
                     else code[4]:=default;
       index:=1;
       while (index<=40) and (code<>codes[index]) do inc(index);
       if writetomemory then
         if index>40 then memwrite(c,y,defaultchar)
                     else memwrite(c,y,symbols[index])
                   else
         if index>40 then begin gotoxy(c,y); write(defaultchar); end
                     else begin gotoxy(c,y); write(symbols[index]); end;
      end; {counter}
      if not writetomemory then gotoxy(xpos,ypos);
   end;

{******}

   {PROCEDURE DRAWS A LINE IN TEXT MODE FROM (X,Y1) TO (X,Y2)}
   {DEFAULT IS EITHER '1' OR '2' FOR SINGLE OF DOUBLE LINES}
   procedure vertline(x,y1,y2:integer; default:char);

    var code:string[4];
        defaultchar:char;
        c,index:integer;
        xpos,ypos:integer;

    begin
     xpos:=wherex; ypos:=wherey;
     if y2<y1 then begin c:=y1; y1:=y2; y2:=c; end;
     if default='1' then defaultchar:=symbols[1]
                    else defaultchar:=symbols[8];
     for c:=y1 to y2 do
      begin
       code:='0000';
       if (c=y2) and (y2=screenlength) then code[3]:='0'
          else if (c=y2) then code[3]:=getcode(memread(x,y2+1),1)
                         else code[3]:=default;
       if x<>screenwidth then code[2]:=getcode(memread(x+1,c),4)
                         else code[1]:='0';
       if x<>1 then code[4]:=getcode(memread(x-1,c),2)
               else code[1]:='0';
       if (c=y1) and (y1=0) then code[1]:='0'
          else if (c=y1) then code[1]:=getcode(memread(x,y1-1),3)
                         else code[1]:=default;
       index:=1;
       while (index<=40) and (code<>codes[index]) do inc(index);

       if writetomemory then
             if index>40 then memwrite(x,c,defaultchar)
                         else memwrite(x,c,symbols[index])
                        else
             if index>40 then begin gotoxy(x,c); write(defaultchar) end
                         else begin gotoxy(x,c); write(symbols[index]); end;
      end; {counter}
     if not writetomemory then gotoxy(xpos,ypos);
    end;

{******}

   {PROCEDURE DRAWS A RECTANGLE IN TEXT MODE}
   {DEFAULT IS EITHER '1' OR '2' FOR SINGLE OF DOUBLE LINES}
   procedure rectlines(x1,y1,x2,y2:integer; default:char);

   begin
    horizline(x1,x2,y1,default);
    horizline(x1,x2,y2,default);
    vertline(x1,y1,y2,default);
    vertline(x2,y1,y2,default);
   end;

{******}

 begin
  writetomemory:=false;
 end. {unit}


 {-------------------   DEMO PROGRAM ------------------------}
 { ----------------      CUT HERE  --------------------------}

 { WRITTEN BY TIM SCHEMPP
  OCTOBER 21, 1993       }

   {THIS PROGRAM DEMONSTARTES THE USE OF THE UNIT drawline.  UNIT DRAWLINE
    WILL USE THE ASCII SET TO DRAW LINES.  WHEN LINE INTERSECTIONS ARE
    FOUND, THE PROCEDURES DESCIDE WHICH CHARACTER FITS BEST.  THUS MAKING
    IT VERY EASY TO CREATE VARIOUS TABLES AND OTHER SCREEN SET UPS.  THE
    UNIT ALSO HAS THE ABILITY TO WRITE DIRECTORY TO VIDEO MEMORY FOR
    A 15% TO 20% IMPROVEMENT IN SPEED.  SEE DRAWLINE.DOC FOR MORE INFO.}

program demo;

 uses crt,drawline;

 var counter:integer;

 begin
  {SET THE SCREEN UP}
  textbackground(black);
  textcolor(white);
  clrscr;

  {THE CALL TO CLEAR SCREEN FILLED THE SCREEN WITH SPACES WITH A BLACK
   BACKGROUND AND A WHITE FOREGROUND.  IF writetomemory IS SET TO TRUE,
   ALL OF THE OUTPUT WILL BE WRITTEN WITH A BLACK BACKGROUND AND A WHITE
   FOREGROUND REGARDLESS OF TEXT ATTRIBUTE CHANGES.}

  {writetomemory:=true;} { <--- ADD THIS STATEMENT AND SEE COLOR DIFFERENCE}

  {WRITE SOME TEXT}
   gotoxy(22,6);
   textcolor(lightblue);
   write('LINE DRAWING DEMONSTARTATION PROGRAM');
   textcolor(yellow);
  {DRAW A RECTANGLE WITH DOUBLE LINES}
  rectlines(10,4,70,20,'2');
  {DRAW SOME HORIZONTAL SINGLE LINES}
  for counter:=9 to 19 do
   horizline(10,70,counter,'1');
  {DRAW SOME SINGLE VERTICLE LINES}
   counter:=20;
   while counter<=60 do
    begin
     vertline(counter,8,20,'1');
     inc(counter,10);
    end; {WHILE}
  {DRAW ONE LAST HORIZONTAL DOUBLE LINE}
   horizline(10,70,8,'2');

  repeat until keypressed;
 end.