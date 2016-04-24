(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0054.PAS
  Description: POKER Again and Again
  Author: LEE BARKER
  Date: 11-02-93  10:33
*)

{
LEE BARKER

│ I'm trying to Write a small Poker game For a grade in my
│ High School Pascal Class.

While the Array of Strings will work, it is a lot of overhead
for what you want to do. It is also difficult to do the scoring.
The following is a small piece of code I posted a year or two
ago when someone asked a similar question. Offered as a study
guide For your homework.
}

Const
  Limit    = 5; { Minimum cards before reshuffle }
  MaxDecks = 1; { Number of decks in use }
  NbrCards = MaxDecks * 52;
  Cardvalue : Array [0..12] of String[5] =
                ('Ace','Two','Three','Four','Five','Six','Seven',
                 'Eight','Nine','Ten','Jack','Queen','King');
  Suit : Array [0..3] of String[8] =
           ('Hearts','Clubs','Diamonds','Spades');

Type
  DeckOfCards = Array [0..Pred(NbrCards)] of Byte;

Var
  Count,
  NextCard : Integer;
  Cards    : DeckOfCards;

Procedure shuffle;
Var
  i, j,
  k, n : Integer;
begin
  randomize;
  j := 0;  { New Decks }
  For i := 0 to pred(NbrCards) do
  begin
    Cards[i] := lo(j);
    inc(j);
    if j > 51 then
      j := 0;
  end;
  For j := 1 to 3 do { why not ? }
    For i := 0 to pred(NbrCards) do
    begin { swap }
      n := random(NbrCards);
      k := Cards[n];
      Cards[n] := Cards[i];
      Cards[i] := k;
    end;
  NextCard := NbrCards;
end;

Function CardDealt : Byte;
begin
  Dec(NextCard);
  CardDealt := Cards[NextCard];
end;

Procedure ShowCard(b : Byte);
Var
  c, s : Integer;
begin
  c := b mod 13;
  s := b div 13;
  Writeln('The ', Cardvalue[c], ' of ', Suit[s]);
end;

begin
  Shuffle;
  Writeln('< The deck is shuffled >');
  { if NextCard <= Limit then shuffle }
  For Count := 1 to 5 do
    ShowCard(CardDealt);
  Readln;
end.

