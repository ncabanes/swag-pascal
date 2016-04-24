(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0021.PAS
  Description: Card Shuffling
  Author: JOHN HOWARD
  Date: 11-26-94  05:01
*)

program CardGame;
{ Author: John Howard  jh
  Date: 08-SEP-94
  Version: 1.0
  Demonstrate two methods to shuffle cards.  Swap method is fast!
  Demonstrate how to evaluate Bridge hands:
    Each hand of 13 cards are arranged by suits and rank within suit (aces are
    high).  The hand is then evaluated using the following standard bridge
    values.

   Aces count 4
   Kings count 3
   Queens count 2
   Jacks count 1
   Voids (no cards in a suit) count 3
   Singletons (one card in a suit) count 2
   Doubletons (two cards in a suit) count 1
   Long suits with more than five cards in the suit
      count 1 for each card over five in number

   Example: 2C QD TC AD 6C 3D TD 3H 5H 7H AS JH KH = 16 points
   because there are 2 aces, 1 king, 1 queen, 1 jack, 1 singleton.
}
{$DEFINE BridgeHand}
const
{$IFDEF BridgeHand}
   points : integer = 0;
{$ENDIF}
   maxdeck = 52;
   maxsuit = 13;
   sentinel = 0;
   suits = 4;

type
   card = byte;
   suit = array[1..maxsuit] of card;    { ace rank is 1, king rank is 13 }

var
   hearts, diamonds : suit;       {red}
   clubs, spades : suit;          {black}
   deck : array[1..maxdeck] of card;
   i, j, k : integer;             { indices }
   count : integer;               { count of used cards }

procedure swap(a,b : integer);
var temp : integer;
begin
  temp := deck[a];
  deck[a] := deck[b];
  deck[b] := temp;
end;

BEGIN  {main}
  writeln('method one -  random swap.  Absolutely the fastest!');
  randomize;
  for i := 1 to maxdeck do        {initialize deck}
    deck[i] := i;                 { Card number MODULO 13 will help to rank }

  for i := 1 to maxdeck do        {index card deck}
    begin
      j := random(maxdeck) +1;    { range is 1..52 }
      SWAP(i, j);                 { shuffle two cards }
    end;

  for i := 1 to maxdeck do        {index card deck}
    write(deck[i], ' ');          { display card order }
  writeln;

  writeln('method two -  rank each card.  Theoretically may take forever!');
  randomize;
  for i := 1 to maxdeck do        {initialize deck}
    deck[i] := sentinel;          { Zero is our sentinel }

  for i := 1 to maxsuit do        {initialize suits with their card numbers}
    begin
      hearts[i]   := i;              { range is  1..13 }
      diamonds[i] := i + maxsuit;    { range is 14..26 }
      clubs[i]    := i + 2*maxsuit;  { range is 27..39 }
      spades[i]   := i + 3*maxsuit;  { range is 40..52 }
    end;

  count := maxdeck;
{$IFDEF BridgeHand}
  count := maxsuit;
{$ENDIF}
  repeat
  i := random(maxdeck) +1;        { range is 1..52 }
  if deck[i] = sentinel then
    begin
      j := random(maxsuit) +1;    { range is 1..13 }
      k := random(suits) +1;      { range is 1..4 }
      case k of
        1 :
              if hearts[j] <> sentinel then
                begin
                  hearts[j] := sentinel;
                  deck[i] := j;
                  dec(count);
                end;
        2 :
              if diamonds[j] <> sentinel then
                begin
                  diamonds[j] := sentinel;
                  deck[i] := j+ maxsuit;
                  dec(count);
                end;
        3 :
              if clubs[j] <> sentinel then
                begin
                  clubs[j] := sentinel;
                  deck[i] := j+ 2*maxsuit;
                  dec(count);
                end;
        4 :
              if spades[j] <> sentinel then
                begin
                  spades[j] := sentinel;
                  deck[i] := j+ 3*maxsuit;
                  dec(count);
                end;
      end; {case}
    end;
  until (count = 0);

  for i := 1 to maxdeck do        {index card deck}
    write(deck[i], ' ');          { display card order }
  writeln;

{$IFDEF BridgeHand}
{ Only block for Hearts is shown.  Code is similar for each suit! }
  count := 0;
  if hearts[1]  = sentinel then inc(points, 4);      { ace }
  if hearts[13] = sentinel then inc(points, 3);      { king }
  if hearts[12] = sentinel then inc(points, 2);      { queen }
  if hearts[11] = sentinel then inc(points, 1);      { jack }
  for i := 1 to maxsuit do
     if hearts[i] = sentinel then inc(count);
  case count of
     0: inc(points, 3);                              { void }
     1: inc(points, 2);                              { singleton }
     2: inc(points, 1);                              { doubleton }
     6..13: inc(points, count-5);                    { long suit }
  end; {case}
  writeln('Points for Hearts = ', points);
{$ENDIF}
END. {program}

