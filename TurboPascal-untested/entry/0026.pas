{
Someone earlier wanted a routine that would make the person type in a
capital letter first, and then all lower case letters.  Well, here it
is.  This also has a masking feature for passwords, and allows BACKSPACE
and TAB.  It passes back a string...

{Scott Mitchell, 1995
    Tested
    I take no waranty whatsoever if this program makes your computer
    blow up or whatever...}

PROGRAM ForceCapital;
USES crt;
CONST  Enter=13;   BackSpace=8;   Tab=9;  {ASCII values}

VAR Answer:string;

{--------------------------------------------------------------------}

function LChar(ch:char):char;

{This simply first checks to see if the character is a capital letter,
and then, if it is, it adds 32, making the letter lower-case...}

begin
       if (ord(ch)>=65) and (ord(ch)<=90) then
            ch:=chr(ord(ch)+32);
       LChar:=ch;
end;

{---------------------------------------------------------------------}

procedure GetInput(var s:string; filler:char; capital:boolean);

{S is the string that will be returned.
Filler is a character.  This can be used for masking, like if a user
 is entering in a password or whatever.  If you want this (let's say to
 mask with a "!") then the syntax would be:

               GetInput (answer, '!', true);

Capital is a TRUE or FALSE value.  If you choose TRUE it will make each
 the letters after a space be capital, and all the other letters
 lowercase.  However, the string returned will not have the unique
 capitalization, although the code can be easily modified for that to
 occur.}

var done:boolean;
   ch:char;
   temp,count,x,y:byte;
   reply:packed array[0..255] of char;

begin
    MEM[$0040:$001A]:=MEM[$0040:$001C];     {Clears Keyboard Buffer!}

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

{---------------------------------------------------------------------}

begin
       clrscr;
       write(' What is your name:     ');
       GetInput(answer, ' ', true);
       writeln; writeln; writeln;
       write('  Welcome to the BBS, ', answer,'!');
       readln;
end.
