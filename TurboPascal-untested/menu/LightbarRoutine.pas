(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0007.PAS
  Description: Re: Lightbar routine.
  Author: GEORGE ROBERTS
  Date: 02-21-96  21:03
*)

{
 TL>   Could someone please give me a good routine or sample for a
 TL> scrolling lightbar menu. Mine always trun out ka-putz.
}

Procedure TestMenu;
VAR choices : ARRAY[1..6] of STRING[15];
    current : BYTE;
    c       : CHAR;
    done    : BOOLEAN;

BEGIN
done:=FALSE;
clrscr;
choices[1]:='Menu Option #1';
choices[2]:='Menu Option #2';
choices[3]:='Menu Option #3';
choices[4]:='Menu Option #4';
choices[5]:='Menu Option #5';
choices[6]:='Menu Option #6';
textcolor(7);
textbackground(0);
for current:=1 to 6 do begin
        gotoxy(2,current+1);
        write(choices[current]);
end;
current:=1;
repeat
{ highlight current option }
gotoxy(2,current+1);
textcolor(15);
textbackground(1);
write(choices[current]);
{ process input }
while not(keypressed) do begin end;
c:=readkey;
case c of
        #0:begin
                c:=readkey;
                case c of
                        #72:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                dec(current);
                                if (current=0) then current:=6;
                            end;
                        #80:begin
                                gotoxy(2,current+1);
                                textcolor(7);
                                textbackground(0);
                                write(choices[current]);
                                inc(current);
                                if (current=7) then current:=1;
                            end;
                end;
           end;
       #13:begin
                case current of
                        { process actions based on the current option # }
                        1:begin
                          end;
                        2:begin
                          end;
                        { etc. }
                end;
           end;
       #27:begin
                done:=TRUE;
           end;
end;
until (done);
end;

