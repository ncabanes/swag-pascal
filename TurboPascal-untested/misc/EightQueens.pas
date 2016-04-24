(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0073.PAS
  Description: Eight Queens
  Author: PIGEON STEVEN
  Date: 01-27-94  12:19
*)

{
pigeons@JSP.UMontreal.CA (Pigeon Steven)

>     Hey, I have a friend who is taking a Pascal class at another col-
>lege and he asked me to make a query of you all.  Basically, he has to
>do the "eight queens" on a chessboard (with none of them interfering
>vertically, horizontally, or diagonally with each other) problem in
>Pascal.  The program has to use stacks.  Its input is the number of
>queens (the dimensions of the chessboard are that number x that number).
>The output is that it can't be done with that number of queens or a
>grid of the queens and either empty spaces or dashes.  I was wondering
>if any of you had any similar programs in old code lying around, and if
>so if you could send it to me.  My friend says it's a pretty classic
>problem for programmers, so I figured I'd ask.  Oh, and in case some of
>you think that I am this "friend", the only Pascal course here at Brown
>(cs15) has already done its job with stacks, and it wasn't this.  Btw,
>speaking of cs here, it's Object-Oriented; my friend's program needs to
>be done procedureally (straight-line), not in OOPas.  I thank you all
>for your indulgence in allowing me to post this.  Please don't flame me,
>as I am only trying to help out a friend.  If there is a more appropriate
>place for me to post this, please tell me (I am going to post this to
>cs groups if possible).  Oh, and as I don't get around here often, I
>would appreciate it much if any and all replies were sent to the address
>below.  Thanx,
>

Here's a programm that does that. It's a little bit strange, but I put
extra code so the board would not be passed as a parameter (since Turbo
Profiler said :"Hey, 75% of your run time goes in copy of the board").
The file is name REINES5.PAS (litterally QUEENS5.PAS) and it's limited
(so to say) to 64x64 boards (with 64 queens on it). It is fast enough.


}
 program Probleme_des_reines;

 const max = 64;
       libre = 8;
       reine = 8;

 const colname:string =
                        'abcdefghijklmnopqrstuvwxyz'+
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'+
                        'αßΓτΣσµΦΘΩδ';
 type echiquier = array[1..max,1..max] of byte;
 var  sol,recursions:longint;
      top:word;
      Reines,Attaques:echiquier;


 function min(a,b:integer):integer;
  begin
   if a<b
      then min:=a
      else min:=b;
  end;

 procedure mark(x,y:integer);
 var t,g,i:integer;
  begin
   for t:=y+1 to top do inc(attaques[x,t]);

   t:=x+1;
   g:=y+1;

   for i:=1 to min(top-t,top-g)+1 do
    begin
     inc(attaques[t,g]);
     inc(t);
     inc(g);
    end;

   t:=x-1;
   g:=y+1;

   if t>0 then
   for i:=1 to min(top-g+1,t) do
    begin
     inc(attaques[t,g]);
     dec(t);
     inc(g);
    end;

   Reines[x,y]:=reine;

  end;

 procedure unmark(x,y:integer);
 var t,g,i:integer;
  begin
   for t:=y+1 to top do dec(attaques[x,t]);

   t:=x+1;
   g:=y+1;

   for i:=1 to min(top-t,top-g)+1 do
    begin
     dec(attaques[t,g]);
     inc(t);
     inc(g);
    end;


   t:=x-1;
   g:=y+1;

   if t>0 then
   for i:=1 to min(top-g+1,t) do
    begin
     dec(attaques[t,g]);
     dec(t);
     inc(g);
    end;

   Reines[x,y]:=libre;

  end;



 procedure traduit;
 var t,g:integer;
  begin
   write(sol:4,'. ');
   for t:=1 to top do
    for g:=1 to top do
     if Reines[g,t]=reine then write(colname[t],g,' ');
   writeln('  ',recursions);
  end;


 function find(level,j:integer):integer;
  begin
   inc(j);
   while (attaques[j,level]<>libre) and (j<top) do inc(j);
   if (attaques[j,level]=libre)
      then find:=j
      else find:=0;
  end;



 procedure recurse(level:integer);
 var t:integer;
  begin
   inc(recursions);
   t:=0;
   repeat
    t:=find(level,t);
    if t<>0
       then begin
             if level=top
                then begin
                      inc(sol);
                      Reines[t,level]:=reine;
                      traduit;
                      Reines[t,level]:=libre;
                     end
                else begin
                      mark(t,level);
                      recurse(level+1);
                      unmark(t,level);
                     end;
            end
   until (t=0) or (t=top);
  end;


  function fact(n:real):real;
   begin
    if n<=1 then fact:=1
            else fact:=n*fact(n-1);
   end;


 var a:echiquier;
     i:integer;
 begin


  sol:=0;
  val(paramstr(1),top,i);
  if top>max
     then begin
           writeln('! ',Top,' a ete remis a ',max,' (max)');
           top:=max;
          end;

  if top<1 then top:=1;

  writeln;
  writeln(' Le probleme des ',top,' reines FAST (c) 1992-1993 Steven Pigeon');
  writeln;

  recursions:=0;
  fillchar(attaques,sizeof(attaques),libre);
  fillchar(Reines,sizeof(Reines),libre);
  recurse(1);
  writeln;
  writeln(' Solutions: ',sol);
  writeln(' Recursions: ',recursions,' (au lieu de ',fact(top):0:0,')');
 end.


