{
Here's a new sorting routine I developed... If someone know that someone
already did this, leave a message to me... Ok.. On with the sorting
routine...

(********************************CutHERE******************************)
{
                     UltraSORT   Jere Sanisalo
                   \***************************/

   This is a new (I think) method of sorting... It uses a table, which
   size can be different every time you use it... Now I am going to tell
   you how this example works (not only the general method). This example
   makes 32000 numbers (words) and randomizes them. Then comes the "WOW"
   part... It sorts them all 100 times... So it processes 3.2 megabytes.
   It took about 8 seconds in my 66 Mzh machine. You all must understand
   all of this code, but I'm still going to explain how the sorting is
   done (for the lazy people). First it (USort procedure) makes a "table"
   that is sized as big as a word can can be ($FFFF), and clears is. Now
   we have a table full of zeros and the numbers to be sorted. Then it
   goes through the number one by one and looks what they are. After that
   it increases the value in the table at the position that the number tells
   by one. Pretty tricky, huh? So if we have a number to process, let's say
   it is 89. Then it increses the value at the table positioned 89 by one.
   (In pascal: Inc(Table[Number]) ) This example just doesn't use straight
   variable. It reserves one memory segment and uses it, but the way the
   sorting is done is not changed. After we have processed the whole number-
   stream we have all information we need in the table. So now we just go
   through the table, and if its value is more that 0 then put the value
   somewhere where you want the final results (In order, of course). When
   that is done, we are finished! We have the sorted table ready!! Enjoy it,
   but if you use it           ====>  GIVE CREDITS TO ME  <====

  BTW. There are some restrictions... You can't have more that 256
  pieces of the same number. And the number can't be greater than $FFFF.
  These retrictions are possible to break, but I am lazy... ;( On with
  the code...
}

uses dos,crt;

const
   numtosort = 32000;                           {How many numbers to sort}

var
   numbers : array [1..numtosort] of word;      {Numbers to be sorted}
   i,j,b,a : word;                              {Just some variables}

procedure usort;
var
   p : pointer;
   segm,maxnum,minnum : word;
 begin
 getmem(p,$ffff); segm:=seg(p^);                {Make the table to be used}
 fillchar(p^,$ffff,0);                          {in the sorting}
{This version looks also for the maximum and minimum numbers for speed...}
 maxnum:=0; minnum:=$ffff;
 for i:=1 to numtosort do                       {This "plots the numbers to}
     begin                                      {the table...}
     if maxnum<numbers[i] then maxnum:=numbers[i];
     if minnum>numbers[i] then minnum:=numbers[i];
     inc(mem[segm:numbers[i]]);
     end;
 b:=1;
 for i:=minnum to maxnum do                     {This gets the procecced}
     begin                                      {numbers back to Numbers[]-}
     if mem[segm:i]>0 then                      {variable}
        begin
        for j:=0 to mem[segm:i]-1 do
            numbers[b+j]:=i;
        inc(b,mem[segm:i]);
        end;
     end;
 freemem(p,$ffff);                              {Free the table's memory}
 end;

begin
randomize;                                      {Randomize the numbers}
for i:=1 to numtosort do
    numbers[i]:=random($ffff);
for a:=1 to 100 do                              {Sort 100 times}
    begin
    write('.');
    usort;
    end;
writeln;
for i:=1 to numtosort do                        {Write the finished results}
    begin
    writeln(numbers[i]);
    if keypressed then begin readkey; readkey; end;
    end;
end.
