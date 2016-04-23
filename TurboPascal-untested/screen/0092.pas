{
    I've seen a LOT of programs which Say they are doing something like
    Reading/Writing to files, and you wonder if they have crashed or what,
    I think it would be nice to have a nice Status Bar to show the progress
    of what is going on!  so here's my contribution to everyone:

    Statbar:  Highly Accurate Status Bar..

    All Code except for HideCursor and ShowCursor is mine.
}

Uses crt;


Procedure HideCursor; Assembler;  Asm                 {I forget where I got}
MOV   ax,$0100;  MOV   cx,$2607;  INT   $10 end;    {     these two      }

Procedure ShowCursor; Assembler; Asm
MOV   ax,$0100;  MOV   cx,$0506;  INT   $10 end;

Procedure Dupeit(Str: String; Num: Integer);  {Just a little Helper, dupes}
var Cnt: integer;                             {        lines              }
begin
For Cnt := 1 to Num do begin
write(Str);
end;
end;

Procedure Statbar(cnum,enum,xspot,yspot,fullcolor,emptycolor: Integer);
var percentage: Integer;              {Uh-Oh, here comes the Mathematical}
begin                                 {                Crap!!            }
Hidecursor;                                 {Kill That Damned Cursor!}
percentage := round(cnum / enum * 100 / 2);   {/2 can be changed for}
  Gotoxy(xspot,yspot);                          {  Shorter Stat Bars  }
 Textcolor(fullcolor);
dupeit(#219,Percentage);                {Can change the Char to whatever}
 Textcolor(emptycolor);
dupeit(#177,50 - Percentage);                    {same as above}

  write('  ',percentage * 2,'%');         {this is not needed, just an extra}
Showcursor;
end;

Procedure WriteXy(x,y: Integer; dstr: String; tcolor: integer);
Begin
Hidecursor;
Gotoxy(x,y);                      { Yeah, I now it's Cheap and cheezy}
Textcolor(tcolor);                 { but it gets the job done well! }
write(dstr);
Showcursor;
end;

var B1,B2,B3: integer;

Begin

  Clrscr;
  WriteXy(30,3,'Statbar By CJ Cliffe..',yellow);

Repeat

 Inc(B1,4);
 Inc(B2,1);
 Inc(B3,1);

{ The Statbar procedure works like so:

Statbar(Current Number, Final Number, x location, y location,
                   Color of completed bars, color of empty bars);

Will process (as far as I know) Any pairs of numbers, as long as the Current
Number does not exceed the Final Number, everything should look fine.. }


   Statbar(B1,800,15,5,Lightcyan,Cyan);     {800 Just makes em go nice 'n}
   Statbar(B2,400,15,7,LightRed,Red);       {slow because they are FAST  }
   Statbar(B3,300,15,9,LightGreen,Green);

Until B1 = 800;

 WriteXy(30,15,'Press any key to quit...',Lightblue);
 Readkey;

end.
