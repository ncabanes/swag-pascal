(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0208.PAS
  Description: Need to throw dices?
  Author: PASI KALLINEN
  Date: 01-02-98  07:34
*)


unit Dices;
(*
  Handy if you need to throw dices.
  Can only handle the basic notation "AdB+C"


  If you have any improvement ideas, or you use this unit in
  your programs, send me email. 
  
  Feel free to do whatever you wish with this.

            pkalli@cs.joensuu.fi
*)

interface

type
     Dicenum = integer; {could be longint}
     Dice = object
                  private
                  times,
                  sides,
                  bonus:Dicenum;  (*AdB+C*)

                  public
                  procedure Init(tim,sid,bon:Dicenum);
                  procedure InitRange(minimum,maximum:Dicenum);
                  function  Throw:longint;
                  function  Dice2Str:string;
                  function  Str2Dice(st:string):boolean;
                  function  Min:longint;
                  function  Max:longint;
            end;


implementation

const
     plussign  = '+';
     minussign = '-';
     Dicesign  = 'd';
     Dicesign2 = 'D';

procedure Dice.Init(tim,sid,bon:Dicenum);
(*Sets Dice values*)
begin
     times:=tim;
     sides:=sid;
     bonus:=bon;
end; (*Dice.Init*)

procedure Dice.InitRange(minimum,maximum:Dicenum);
(*Sets Dice range. 
  Ugh! What code. But it seems to work, so...*)
var tmp:Dicenum;
    tmp2:Dicenum;
begin
     times:=0;
     sides:=0;
     bonus:=0;
     if minimum>maximum then begin
        tmp:=minimum;
        minimum:=maximum;
        maximum:=tmp;
     end;
     tmp:=0;
     tmp2:=0;
     if minimum=maximum then begin
        bonus:=minimum;
     end else begin
         if minimum=0 then begin
            inc(minimum);
            inc(maximum);
            inc(tmp2);
         end else
         if minimum<1 then begin
            inc(tmp2,abs(minimum*2));
            inc(minimum,tmp2);
            inc(maximum,tmp2);
         end;
         while ((maximum mod minimum)<>0) and (minimum>1) do begin
              dec(minimum);
              dec(maximum);
              inc(tmp);
         end;
         if (maximum mod minimum)=0 then begin
               bonus:=(maximum mod minimum)+tmp-tmp2;
               sides:= maximum div minimum;
               times:= minimum;
         end else begin
             writeln('koe!');
                bonus:=minimum-1-tmp-tmp2;
                sides:=maximum-minimum+1;
                times:=1;
         end;
     end;
end; (*Dice.InitRange*)

function Dice.Throw:longint;
(*Throws the Dices*)
var x:longint;
    tmp:dicenum;
begin
     x:=0;
     tmp:=times;
     while (tmp>0) do begin
        inc(x,Random(sides)+1);
        dec(tmp);
     end;
     inc(x,bonus);
     if x<0 then x:=0;
     Throw:=x;
end; (*Dice.Throw*)

function Dice.Dice2Str:string;
(*Converts Dice to String*)
var st,t:string;
begin
     st:='';
     if (times>0) then begin
        str(times,t);
        st:=st+t+Dicesign;
        str(sides,t);
        st:=st+t;
        if bonus>0 then st:=st+plussign;
     end;
     if (bonus<>0) then begin
        str(bonus,t);
        st:=st+t;
     end else if (sides=0) and (times=0) then st:='0';
     Dice2Str:=st;
end; (*Dice.Dice2Str*)

function Dice.Str2Dice(st:string):boolean;
(*Converts String to Dice.
  Returns true if there occurred any errors, false otherwise*)
const sign:char = '+';
var errcode,errcount:integer;
    dsign:char;
begin
     sides:=0;
     times:=0;
     bonus:=0;
     errcount:=0;
     if pos(Dicesign,st)>0 then dsign:=Dicesign else dsign:=Dicesign2;
     if (pos(Dsign,st)>0) then begin
        Val(copy(st,1,pos(dsign,st)-1),times,errcode);
        if errcode<>0 then times:=1;
        if (pos(minussign,st)>0) then sign:=st[pos(minussign,st)];
        if (pos(sign,st)>0) then begin

Val(copy(st,pos(dsign,st)+1,pos(sign,st)-pos(dsign,st)-1),sides,errcode);
           inc(errcount,errcode);
           Val(copy(st,pos(sign,st),length(st)),bonus,errcode);
           inc(errcount,errcode);
        end else begin
            Val(copy(st,pos(dsign,st)+1,length(st)),sides,errcode);
        end;
     end else begin
         val(st,bonus,errcode);
         inc(errcount,errcode);
     end;
     Str2Dice:=(errcount<>0);
end; (*Dice.Str2Dice*)

function Dice.Min:longint;
(*Returns the min. number dice can give*)
begin
     Min:=bonus+times;
end; (*Dice.Min*)

function Dice.Max:longint;
(*Returns the max. number dice can give*)
begin
     Max:=bonus+(times*sides);
end; (*Dice.Max*)

begin
     Randomize;
end.


