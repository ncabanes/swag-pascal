(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0016.PAS
  Description: WILDCRD1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

Program wild_card;

Var
   check:Boolean;

Function Wild(flname,card:String):Boolean;
{Returns True if the wildcard description in 'card' matches 'flname'
according to Dos wildcard principles.  The 'card' String MUST have a period!
Example: Wild('test.tat','t*.t?t' returns True}

Var
   name,temp:String[12];
   c:Char;
   p,i,n,l:Byte;
   period:Boolean;

begin
    wild:=True;
    {test For special Case first}
    if flname='*.*' then Exit;
    wild:=False;
    p:=pos('.',card);
    i:=pos('.',flname);
    if p > 0 then period:=True else Exit; {not a valid wildcard if no period}
    N:=1;
    Repeat
       if card[n]='*' then n:=p-1 else
        if (upCase(flname[n]) <> upCase(card[n])) then
         if card[n]<>'?' then Exit;
                inc(n);
    Until n>=p;
    n:=p+1; {one position past the period of the wild card}
    l:=length(flname);
    inc(i); {one position past the period of the Filename}
    Repeat
    if n > length(card) then Exit;
    c:=upCase(card[n]);
         if c='*' then i:=l+1 {in order to end the loop}
          else
             if (upCase(flname[i]) = c) or (c = '?') then
                begin
                inc(n);
                inc(i);
                end
             else Exit;
    Until i > l;

    wild:=True;

end;

begin
  check:=False;
  check:=wild('TEST.Tat','T*.T?T'); {True}
  Writeln(check);
  check:=wild('TEST.Taq','T*.T?T');  {False}
  Writeln(check);
  check:=wild('12345678.pkt','*.pkt'); {True}
  Writeln(check);
  check:=wild('test.tat','T*.t?');  {False}
  Writeln(check);
  check:=wild('12345678.pkt','1234?678.*'); {True}
  Writeln(check);
end.
