unit dotmat; {written by Iain Whyte. (c) 1994 }

{ This unit generates a 'dot matrix' LED effect that is very effective. If
you would like to use this code, all that I ask is that you mention it
in the credits somewhere, and let me know what you used it for. If you have
any suggestions, or you want to talk to me or ask questions, I can be
contacted at whytei@topaz.ucq.edu.au or ba022@cq-pan.cqu.edu.au
via the Internet, or by snail-post :

          Iain Whyte
          141 Racecourse Road
          Mt Morgan Q4714
          Australia.

or on the Rockhampton Computer Club BBS, via the programming, IBM/DOS, or
AMIGA conferences... RCC BBS: (079) 276200

Instructions :

Self explanatary, really, there is a sample prog for using this unit at the
of this file..... }

{displays upto 10 characters at once, max string size (ATM) is 20 chars....}


interface

uses dos,crt,graph;



procedure display_dotmat_screen(xpos,ypos:integer);
procedure create_dotmat(inputstring:string);
procedure straight_display;
procedure left_right;
procedure right_left;
procedure top_bot;
procedure bot_top;
procedure italics;
procedure random_fade_out;
procedure random_fade_in;
procedure fall_away;



implementation


type

letter_set=array[0..8,0..4] of integer;
dotmattype=array[0..8,0..119] of integer;

const
     pixelsize = 2; {size of each LED element i.e. 2 therfore LED is 2x2 pixels}
     a : letter_set = ((0,1,1,1,0),  {each letter is set up as a 5x9 array}
                       (1,0,0,0,1),  {1 means LED is ON, 0 means LED OFF}
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,1,1,1,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1));
     b : letter_set = ((1,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,1,1,1,0));
     c : letter_set = ((0,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
     d : letter_set = ((1,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,1,1,1,0));
     e : letter_set = ((1,1,1,1,1),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,1,1,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,1,1,1,1));
     f : letter_set = ((1,1,1,1,1),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,1,1,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0));
     g : letter_set = ((0,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,1,1,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
     h : letter_set = ((1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,1,1,1,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1));
     i : letter_set = ((0,1,1,1,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,1,1,1,0));
     j : letter_set = ((0,0,1,1,1),
                       (0,0,0,1,0),
                       (0,0,0,1,0),
                       (0,0,0,1,0),
                       (0,0,0,1,0),
                       (1,0,0,1,0),
                       (1,0,0,1,0),
                       (1,0,0,1,0),
                       (0,1,1,0,0));
     k : letter_set = ((1,0,0,0,1),
                       (1,0,0,1,0),
                       (1,0,1,0,0),
                       (1,1,0,0,0),
                       (1,1,0,0,0),
                       (1,1,0,0,0),
                       (1,0,1,0,0),
                       (1,0,0,1,0),
                       (1,0,0,0,1));
     l : letter_set = ((1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,1,1,1,1));
     m : letter_set = ((1,0,0,0,1),
                       (1,1,0,1,1),
                       (1,1,1,1,1),
                       (1,0,1,0,1),
                       (1,0,1,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1));
     n : letter_set = ((1,0,0,0,1),
                       (1,1,0,0,1),
                       (1,1,0,0,1),
                       (1,0,1,0,1),
                       (1,0,1,0,1),
                       (1,0,1,0,1),
                       (1,0,0,1,1),
                       (1,0,0,1,1),
                       (1,0,0,0,1));
     o :  letter_set =((0,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
     p :  letter_set =((1,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,1,1,1,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0));
     q :  letter_set =((0,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,1,0,1),
                       (1,0,0,1,1),
                       (0,1,1,1,1));
     r :  letter_set =((1,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,1,1,1,0),
                       (1,1,0,0,0),
                       (1,0,1,0,0),
                       (1,0,0,1,0),
                       (1,0,0,0,1));
     s :  letter_set =((0,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (0,1,1,1,0),
                       (0,0,0,0,1),
                       (0,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
     t :  letter_set =((1,1,1,1,1),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0));
     u :  letter_set =((1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
     v :  letter_set =((1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,0,1,0),
                       (0,1,0,1,0),
                       (0,0,1,0,0));
     w :  letter_set =((1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,1,0,1),
                       (1,0,1,0,1),
                       (0,1,1,1,0),
                       (0,1,0,1,0));
     x :  letter_set =((1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,0,1,0),
                       (0,0,1,0,0),
                       (0,1,0,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1));
     y :  letter_set =((1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,0,1,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0));
     z :  letter_set =((1,1,1,1,1),
                       (0,0,0,0,1),
                       (0,0,0,0,1),
                       (0,0,0,1,0),
                       (0,0,1,0,0),
                       (0,1,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,1,1,1,1));
     exc :  letter_set =((0,0,1,0,0),
                       (0,1,1,1,0),
                       (0,1,1,1,0),
                       (0,1,1,1,0),
                       (0,1,1,1,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,0,0,0),
                       (0,0,1,0,0));
     andm :  letter_set =((0,0,1,1,0),
                       (0,1,0,0,1),
                       (0,0,1,1,0),
                       (0,1,1,1,0),
                       (1,0,0,1,0),
                       (1,0,0,0,1),
                       (1,0,0,1,1),
                       (1,0,0,1,0),
                       (0,1,1,0,1));
     hat :  letter_set =((0,1,0,1,0),
                       (0,1,0,1,0),
                       (1,1,1,1,1),
                       (0,1,0,1,0),
                       (0,1,0,1,0),
                       (1,1,1,1,1),
                       (0,1,0,1,0),
                       (0,1,0,1,0),
                       (0,1,0,1,0));
     com :  letter_set =((0,0,0,0,0),
                       (0,0,0,0,0),
                       (0,0,0,0,0),
                       (0,0,0,0,0),
                       (0,0,0,0,0),
                       (0,0,1,1,0),
                       (0,0,1,1,0),
                       (0,0,1,0,0),
                       (0,1,1,0,0));
     ast : letter_set=((0,0,0,0,0),
                       (1,0,1,0,1),
                       (0,1,1,1,0),
                       (0,0,1,0,0),
                       (1,1,1,1,1),
                       (0,0,1,0,0),
                       (0,1,1,1,0),
                       (1,0,1,0,1),
                       (0,0,0,0,0));
     la : letter_set =((0,0,0,0,1),
                       (0,0,0,1,0),
                       (0,0,1,0,0),
                       (0,1,0,0,0),
                       (1,0,0,0,0),
                       (0,1,0,0,0),
                       (0,0,1,0,0),
                       (0,0,0,1,0),
                       (0,0,0,0,1));
     ra : letter_set =((1,0,0,0,0),
                       (0,1,0,0,0),
                       (0,0,1,0,0),
                       (0,0,0,1,0),
                       (0,0,0,0,1),
                       (0,0,0,1,0),
                       (0,0,1,0,0),
                       (0,1,0,0,0),
                       (1,0,0,0,0));
     one :letter_set =((0,0,1,0,0),
                       (0,1,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,1,1,1,0));
     two : letter_set=((0,1,1,1,0),
                       (1,0,0,0,1),
                       (0,0,0,0,1),
                       (0,0,0,1,0),
                       (0,0,1,0,0),
                       (0,1,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,1,1,1,1));
     thr: letter_set =((0,1,1,1,0),
                       (1,0,0,0,1),
                       (0,0,0,0,1),
                       (0,0,0,0,1),
                       (0,0,1,1,0),
                       (0,0,0,0,1),
                       (0,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
     four:letter_set =((1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,0,0,1,0),
                       (1,0,0,1,0),
                       (1,0,0,1,0),
                       (1,0,0,1,0),
                       (1,1,1,1,1),
                       (0,0,0,1,0),
                       (0,0,0,1,0));
     five:letter_set =((1,1,1,1,1),
                       (1,0,0,0,0),
                       (1,0,0,0,0),
                       (1,1,1,1,0),
                       (1,0,0,0,1),
                       (0,0,0,0,1),
                       (0,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
     six :letter_set =((0,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,0),
                       (1,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
     sev :letter_set =((1,1,1,1,1),
                       (1,0,0,0,1),
                       (0,0,0,0,1),
                       (0,0,0,1,0),
                       (0,0,0,1,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,1,0,0,0),
                       (0,1,0,0,0));
    eight:letter_set =((0,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
   nine : letter_set =((0,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,1),
                       (0,0,0,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
   zer  : letter_set =((0,1,1,1,0),
                       (1,0,0,1,1),
                       (1,0,0,1,1),
                       (1,0,1,0,1),
                       (1,0,1,0,1),
                       (1,0,1,0,1),
                       (1,1,0,0,1),
                       (1,1,0,0,1),
                       (0,1,1,1,0));

   smil  :letter_set =((0,1,1,1,0),
                       (1,1,1,1,1),
                       (1,0,1,0,1),
                       (1,1,1,1,1),
                       (1,1,0,1,1),
                       (1,1,1,1,1),
                       (1,0,0,0,1),
                       (1,1,0,1,1),
                       (0,1,1,1,0));
   dol :  letter_set =((0,0,1,0,0),
                       (0,1,1,1,0),
                       (1,0,1,0,1),
                       (1,0,1,0,0),
                       (0,1,1,1,0),
                       (0,0,1,0,1),
                       (1,0,1,0,1),
                       (0,1,1,1,0),
                       (0,0,1,0,0));
   copyr: letter_set =((0,1,1,1,0),
                       (1,0,0,0,1),
                       (1,0,1,0,1),
                       (1,1,0,1,1),
                       (1,1,0,0,1),
                       (1,1,0,1,1),
                       (1,0,1,0,1),
                       (1,0,0,0,1),
                       (0,1,1,1,0));
   lb:    letter_set =((0,0,0,1,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,1,0,0,0),
                       (0,1,0,0,0),
                       (0,1,0,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,0,1,0));
   rb:    letter_set =((0,1,0,0,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,0,1,0),
                       (0,0,0,1,0),
                       (0,0,0,1,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,1,0,0,0));
   quest: letter_set =((0,1,1,1,0),
                       (1,0,0,0,1),
                       (0,0,0,0,1),
                       (0,0,0,1,0),
                       (0,0,0,1,0),
                       (0,0,1,0,0),
                       (0,0,1,0,0),
                       (0,0,0,0,0),
                       (0,0,1,0,0));


var
  letters:array[' '..'z']of letter_set;
  outchars:array[0..19]of char;
  mainxpos,mainypos:integer;
  dotmatarray:dotmattype;
  dotmatarraymove,dotmatempty:dotmattype;
  counth,countv,lettercount:integer;
  count,count2,countmove,countloop:integer;

procedure setup_chars;

begin
     letters['a']:=a;
     letters['b']:=b;
     letters['c']:=c;
     letters['d']:=d;
     letters['e']:=e;
     letters['f']:=f;
     letters['g']:=g;
     letters['h']:=h;
     letters['i']:=i;
     letters['j']:=j;
     letters['k']:=k;
     letters['l']:=l;
     letters['m']:=m;
     letters['n']:=n;
     letters['o']:=o;
     letters['p']:=p;
     letters['q']:=q;
     letters['r']:=r;
     letters['s']:=s;
     letters['t']:=t;
     letters['u']:=u;
     letters['v']:=v;
     letters['w']:=w;
     letters['x']:=x;
     letters['y']:=y;
     letters['z']:=z;
     letters['!']:=exc;
     letters['&']:=andm;
     letters['#']:=hat;
     letters[',']:=com;
     letters['*']:=ast;
     letters['<']:=la;
     letters['>']:=ra;
     letters['1']:=one;
     letters['2']:=two;
     letters['3']:=thr;
     letters['4']:=four;
     letters['5']:=five;
     letters['6']:=six;
     letters['7']:=sev;
     letters['8']:=eight;
     letters['9']:=nine;
     letters['0']:=zer;
     letters['^']:=smil;
     letters['$']:=dol;
     letters['@']:=copyr;
     letters['(']:=lb;
     letters[')']:=rb;
     letters['?']:=quest;
end;

procedure display_dotmat_screen(xpos,ypos:integer);

var countx,county:integer;

begin
     mainxpos:=xpos;
     mainypos:=ypos;
     setfillstyle(1,8);
     for countx:=0 to 59 do
     begin
          for county:=-1 to 9 do
          begin
               bar((xpos+(countx*(pixelsize+1))),(ypos+(county*(pixelsize+1))),
                  ((xpos+(countx*(pixelsize+1)))+(pixelsize-1)),((ypos+(county*(pixelsize+1)))+(pixelsize-1)));

          end;
     end;
end;


procedure convertstring_to_chars(instr:string);

var count:integer;
    dummys:string[1];
    strcount:char;

begin
     for count:=1 to 20 do
     begin

          dummys:=copy(instr,count,1);
          for strcount:=' ' to 'z' do
          begin
               if dummys = strcount then outchars[count-1]:=strcount;
          end;
     end;
end;


procedure create_dotmat(inputstring:string);

begin
     for countv:=0 to 8 do
     for counth:=0 to 119 do
     dotmatempty[countv,counth]:=0;

     setup_chars;
     convertstring_to_chars(inputstring);

     for lettercount:=0 to 19 do  {make array of dots from letter data}
     begin

     for countv:=0 to 8 do
     begin

          for counth :=(lettercount*6) to ((lettercount*6)+6) do
          begin
              if counth<120 then
              begin
              dotmatarray[countv,counth]:=letters[outchars[lettercount],countv,(counth-lettercount*6)];
              if (counth-lettercount*6) > 4 then dotmatarray[countv,counth]:=0;
              end;
          end;
     end;
     end;



end;


procedure gen_display;

begin

     for counth:=0 to 59 do
     begin
          for countv:=0 to 8 do
          begin
               if (counth < 2) or (counth > 57) then setfillstyle(1,2)
               else setfillstyle(1,10);
               if dotmatarraymove[countv,counth] = 1 then
               begin
                  bar((mainxpos+(counth*(pixelsize+1))),(mainypos+(countv*(pixelsize+1))),
                  ((mainxpos+(counth*(pixelsize+1)))+(pixelsize-1)),((mainypos+(countv*(pixelsize+1)))+(pixelsize-1)));
               end;
               setfillstyle(1,8);
               if dotmatarraymove[countv,counth] = 0 then
               begin
                   bar((mainxpos+(counth*(pixelsize+1))),(mainypos+(countv*(pixelsize+1))),
                  ((mainxpos+(counth*(pixelsize+1)))+(pixelsize-1)),((mainypos+(countv*(pixelsize+1)))+(pixelsize-1)));
               end;
          end;
     end;

end;


procedure straight_display;

begin
     dotmatarraymove:=dotmatarray;
     gen_display;
end;



procedure left_right;
begin

     for count2:=0 to 119 do
     begin
          for count:=0 to 59 do
          begin
          countmove:=count+count2;
          if countmove>119 then countmove:=countmove-120;
          for countloop:=0 to 8 do dotmatarraymove[countloop,count]:=dotmatarray[countloop,countmove];

          end;
     gen_display;
     delay(5);
     end;
end;


procedure right_left;
begin

     for count2:=119 downto 0 do
     begin

          for count:=0 to 59 do
          begin
          countmove:=count+count2;
          if countmove>119 then countmove:=countmove-120;
          for countloop:= 0 to 8 do dotmatarraymove[countloop,count]:=dotmatarray[countloop,countmove];

          end;

     gen_display;
     delay(5);
     end;
end;


procedure top_bot;
begin
     dotmatarraymove:=dotmatempty;
     for count2:=-9 to 9 do
     begin

          for count:=0 to 8 do
          begin
            countmove:=count+count2;
          if countmove>8 then for countloop:=0 to 119 do dotmatarraymove[count,countloop]:=0
          else if countmove<0 then for countloop:=0 to 119 do dotmatarraymove[count,countloop]:=0
          else for countloop:=0 to 119 do dotmatarraymove[count,countloop]:=dotmatarray[countmove,countloop];

          end;

     gen_display;
     delay(50);
     end;
end;


procedure bot_top;
begin
     for count2:=9 downto -9 do
     begin

          for count:=0 to 8 do
          begin
            countmove:=count+count2;
           if countmove>8 then for countloop:=0 to 119 do dotmatarraymove[count,countloop]:=0
          else if countmove<0 then for countloop:=0 to 119 do dotmatarraymove[count,countloop]:=0
          else for countloop:=0 to 119 do dotmatarraymove[count,countloop]:=dotmatarray[countmove,countloop];



          end;

     gen_display;
     delay(50);
     end;


end;

procedure italics;
begin
     for count:=0 to 8 do
     begin
          for count2:=0 to 119 do
          begin
               if (count mod 2) = 0 then
               begin
                    dotmatarraymove[count,count2]:=dotmatarray[count,count2+(count div 2)];
               end else
                    dotmatarraymove[count,count2]:=dotmatarray[count,count2+((count-1) div 2)];
          end;
     end;
     dotmatarray:=dotmatarraymove;
end;



procedure random_fade_out;

var
v,h,rnd,countdots:integer;

begin
     randomize;
     dotmatarraymove:=dotmatarray;
     countdots:=0;
     for v:=0 to 8 do
     begin
     for h:=0 to 119 do
     begin
         if dotmatarraymove[v,h]=1 then

         countdots:=countdots+1;
     end;
     end;
     repeat
     for v:=0 to 8 do
     begin
     for h:=0 to 119 do
     begin
         if dotmatarraymove[v,h]=1 then
         begin
              rnd:=random(5);
              if rnd = 1 then
              begin
                   countdots:=countdots-1;
                   dotmatarraymove[v,h]:=0;
              end;
         end;
     end;
     end;

     gen_display;
     until countdots<=0;

end;


procedure random_fade_in;
var
v,h,rnd,countdots:integer;
begin
     randomize;
     dotmatarraymove:=dotmatempty;
     countdots:=0;
     for v:=0 to 8 do
     begin
     for h:=0 to 119 do
     begin
         if dotmatarray[v,h]=1 then

         countdots:=countdots+1;
     end;
     end;
     repeat
     for v:=0 to 8 do
     begin
     for h:=0 to 119 do
     begin
         if (dotmatarray[v,h]=1)and (dotmatarraymove[v,h]=0) then
         begin
              rnd:=random(5);
              if rnd = 1 then
              begin
                   countdots:=countdots-1;
                   dotmatarraymove[v,h]:=1;
              end;
         end;
     end;
     end;

     gen_display;
     until countdots<=0;

end;

procedure fall_away;
begin
     dotmatarraymove:=dotmatarray;
     for count:=8 downto 0 do
     begin
         count2:=count;
         repeat
              for countloop:=0 to 119 do
              begin
                   if count2=count then
                   begin
                   dotmatarraymove[count2,countloop]:=dotmatarray[count,countloop];
                   end
                   else
                   begin
                   dotmatarraymove[count2,countloop]:=dotmatarray[count,countloop];
                   dotmatarraymove[count2-1,countloop]:=0;
                   end;
              end;
            gen_display;
            delay(5);
         count2:=count2+1;
         until count2=10;

     end;
end;


end.

{-------------------------------  DEMO  ----------------------------------}
program test_dotmat_unit;

uses dos,crt,graph,dotmat;



var
   in1,in2:integer;


begin              {12345678901234567890}  {length guide}

     initgraph(in1,in2,'c:\bp\bgi');  {initialise 640x480x16c mode bgi}
     cleardevice;


     display_dotmat_screen(50,50);    {set_up, display blank LED matrix}

     create_dotmat('this is a demo !    '); {loads string into matrix array}

     straight_display;       {display on matrix}
     delay(1000);


     left_right;             {scroll from left to right}
     delay(1000);

     right_left;             {scroll from right to left}

     create_dotmat('fading in!           ');  {set up new msg}
     random_fade_in;                          {randomised fade}
     delay(1000);

     create_dotmat('fade out!!           ');
     straight_display;
     delay(1000);

     random_fade_out;


     create_dotmat('can scroll 4 ways!!! ');
     left_right;
     top_bot;       {scroll from top to bottom}
     right_left;
     bot_top;       {scroll from bottom to top}


     create_dotmat('italics for the font!'); {create new msg}
     italics;                                {generate italics}
     random_fade_in;
     left_right;
     delay(1000);
     random_fade_out;

     create_dotmat('and a special effect ');  {create new msg}
     left_right;
     delay(1000);
     create_dotmat('called fall away!    ');
     left_right;
     delay(1000);
     fall_away;                               {demo Special FX}

     create_dotmat('well, what dya think?');
     left_right;
     fall_away;

     create_dotmat('@ iain whyte 1994    ');
     random_fade_in;
     left_right;
     right_left;
     random_fade_out;
     top_bot;
     bot_top;



     closegraph;                                    {kill graphics mode}

end.
