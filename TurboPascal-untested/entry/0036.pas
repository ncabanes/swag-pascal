unit ask;

interface

uses crt;

function askyn(s:string):boolean;
function askch(s,resp:string):integer;
function askno(s:string; min,max:integer):integer;

implementation

{ --------------------------------------------------------------------
  AskYN (Ask Yes/NO)
  by Emil Mikulic

  Input:
   s - the string to display (the question)

  Output:
   boolean - true if answer is yes and false if answer is no

  Intraction:
   User has to type Y or N
  -------------------------------------------------------------------- }
function askyn(s:string):boolean;
var c:char;
begin
 { Write the question }
 write(s);
 repeat
   { Get the uppercase answer }
   c:=upcase(readkey);
 { Until it's Y or N }
 until (c='Y') or (c='N');
 { Write out the choice and move down a line }
 writeln(c);

 { Return true if the answer was Y }
 askyn:=(c='Y');
end;

{ --------------------------------------------------------------------
  AskCH (Ask multiple CHoice)
  by Emil Mikulic

  Input:
   s    - the string to display (the question)
   resp - a string containing the possible responses

  Output:
   integer - the number of the selected choice
             Ex. AskCH('Pick a vowel:','AEIOU'), A=1 E=2 I=3 O=4 U=5

  Intraction:
   User has to type one of the letters is RESP
   Note: case doesn't matter
  -------------------------------------------------------------------- }
function askch(s,resp:string):integer;
var c:char;
    i,j:integer;
    ok:boolean;
begin
 { Write out the question }
 write(s);
 repeat
   { Make sure ok is false }
   ok:=false;
   { Get an answer }
   c:=upcase(readkey);
   { See if the answer is allowed in RESP, if yes, set ok to true }
   for I:=1 to length(resp) do if c=upcase(resp[i]) then ok:=true;
 { Until it's ok :) }
 until ok;
 { Write out the answer and move down a line }
 writeln(c);

 { Find which part of RESP allows the answer }
 for i:=1 to length(resp) do if c=resp[i] then j:=i;
 { Return it }
 askch:=j;
end;

{ --------------------------------------------------------------------
  AskNO (Ask NUMBER)
  by Emil Mikulic

  Input:
   s   - the string to display (the question)
   min - the lowest digit
   max - the highest digit

  Output:
   integer - the digit entered

  Intraction:
   User has to type a digit between min and max
   Note: if you make min greater than 9, it will loop forever
  -------------------------------------------------------------------- }
function askno(s:string; min,max:integer):integer;
var c:string;
    i,j:integer;
begin
 { It's hard to type with one hand while eating a sandwich. }
 write(s);
 repeat
   { Get a response }
   c:=readkey;
   { Turn it into an integer }
   val(c,i,j);
 { Keep going until it's a proper integer (j=0) and it's allowed by
   min and max }
 until (j=0) and (i>min) and (i<max);
 { Write out the answer }
 writeln(c);
 { Return it }
 askno:=i;
end;

end.

ASK Unit Documentation

by Emil Mikulic

  --------------------------------------------------------------------
  AskYN (Ask Yes/NO)
  by Emil Mikulic

  Input:
   s - the string to display (the question)

  Output:
   boolean - true if answer is yes and false if answer is no

  Intraction:
   User has to type Y or N
  
  Examples:
   if AskYN('Wanna quit?') then halt(0);
   if AskYN('Wanna die?') then player.die;
   if AskYN('Do you like me?') then format_drive(C);

  --------------------------------------------------------------------
  AskCH (Ask multiple CHoice)
  by Emil Mikulic

  Input:
   s    - the string to display (the question)
   resp - a string containing the possible responses

  Output:
   integer - the number of the selected choice

  Intraction:
   User has to type one of the letters is RESP
   
  Note: 
   Case doesn't matter
  
  Examples:
   vowel:=AskCH('Pick a vowel: ','aEiOu');
   vowel:=AskCH('Pick a vowel: ','aeiou');
   vowel:=AskCH('Pick a vowel: ','AEiOU');
  
  -------------------------------------------------------------------- 
  AskNO (Ask NUMBER)
  by Emil Mikulic

  Input:
   s   - the string to display (the question)
   min - the lowest digit
   max - the highest digit

  Output:
   integer - the digit entered

  Intraction:
   User has to type a digit between min and max
   
  Note: 
   If you make min greater than 9, it will loop forever

  Example:
    Writeln('(1) Attack');
    Writeln('(2) Run');
    ...
    Writeln('(5) Cast the magical forces of GHGDFKG:LFWEF');
    choice:=AskNO('What do you want to do?',1,5);
    ...
  -------------------------------------------------------------------- 

