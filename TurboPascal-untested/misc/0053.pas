{
SEAN PALMER

> I'm trying to Write a small Poker game For a grade in my High
> School Pascal Class.  I set the deck up as an Array of String's
> (example: Deck: Array[1..52] of String)
> And then filled the Array With somthing like: Deck[1]:='2 of
> Diamonds'; I may have started wrongly, but I need a way to "Shuffle"
> the deck.  I could probably read them into the Array Randomly, or
> could I keep them in a logical order in the Array and shuffle the
> Array itself?  Let me know if you have any ideas concerning my
> problem maybe you could post some code For me.

There are probably better ways to set up the data structure, such as:
}

Type
  tCardVal  = (Two, Three, Four, Five, Six, Seven,
               Eight, Nine, Ten, Jack, Queen, King, Ace);
  tCardSuit = (Spades, Diamonds, Hearts, Clubs);

  tCard = Record
    val  : tCardVal;
    suit : tCardSuit;
  end;

Const
  valStrings : Array [tCardVal] of String[5] =
    ('Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
     'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King', 'Ace');
 suitStrings : Array [tCardSuit] of String[8] =
   ('Spades', 'Diamonds', 'Hearts', 'Clubs');

Var
  deck : Array [0..51] of tCard;

{ after initializing the deck, you could shuffle With a Procedure like this: }

for i := 300 + random(50) downto 0 do
begin
  posn           := random(51);
  tempCard       := deck[posn];
  deck[posn]     := deck[posn + 1];
  deck[posn + 1] := tempCard;
end;

{
This might be better if it swapped two randomly-picked cards, would shuffle
better... }
