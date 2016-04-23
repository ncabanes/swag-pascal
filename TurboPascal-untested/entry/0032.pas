{
CS>I need to put a input inside a repeat loop to enter a password, but don't
CS>want it to show what the user is typing, but rather show a different
charactCS>say the charcter ' ' or any character that i can define.

Here you go...  here is some tested source code:


{Scott Mitchell...   1996}

program Password_Program;
uses crt;
const TAB=9;  BACKSPACE=8;  ENTER=13;
var password:string;

{--------------------------------------------------------------------------}

procedure ClearKeyboardBuffer;
begin
    MEM[$0040:$001A]:=MEM[$0040:$001C];     {Clears Keyboard Buffer!}
end;

{--------------------------------------------------------------------------}

function LChar(s:char):char;
{This is the opposite of the function UPCASE(char).  This simply turns
a character into a lowercase character.}
begin
    if (ord(s)>=65) and (ord(s)<=90) then
           s:=chr(ord(s)+32);
    lchar:=s;
end;

{--------------------------------------------------------------------------}

procedure GetInput(var s:string; filler:char; capital:boolean);
{This procedure gets input from the user, and saves the response as the
 string S.  Filler is the character you want to "mask" the actual typing.
If you don't want the entry masked, just enter a ' ' in the procedure
decleration.  Capital is a boolean value (TRUE/FALSE) which, if declared
TRUE, forces Capitalization.  What this means, is that if the user types
in his response, it capitalizes the first letter automatically and makes
the rest lowercase.}
var done:boolean;
   ch:char;
   temp,count,x,y:byte;
   reply:packed array[0..255] of char;
begin
    ClearKeyboardBuffer;
    x:=wherex;  y:=wherey;
    count:=0;   done:=false;

    repeat
    repeat until keypressed;
    ch:=readkey;
    case ord(ch) of
         Enter:begin
                 done:=true;
                 reply[0]:=chr(count);
            end;
         Tab:begin
                if not(count>245) then begin
                   inc(x,5);
                   gotoxy(x,y);
                   for temp:=1 to 5 do
                       reply[count+temp]:=' ';
                   inc(count,5);
                end;
           end;
         BackSpace:begin
                if not(count=0) then begin
                   reply[count]:=' ';
                   dec(count);
                   dec(x);
                   gotoxy(x,y);
                   write(' ');
                   gotoxy(x,y);
                end;
           end;
         else
             begin
                inc(count);  inc(x);
                if (filler<>' ') and (ch<>' ') then
                   write(filler)
                else
                   if capital then begin
                        if count>1 then
                           if reply[count-1]=' ' then
                              write(upcase(ch))
                           else write(lchar(ch))
                        else
                            write(upcase(ch));
                   end
                   else write(ch);
                reply[count]:=ch;
             end;
    end;
    until done;

    for x:=1 to ord(reply[0]) do
        s:=s+reply[x];
end;

{--------------------------------------------------------------------------}

begin
    clrscr;
    getinput(password,'*',false);
    writeln; writeln;
    write('You entered the password ',password);
    readln
end.

{============================== CUT HERE ============================}

