(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0022.PAS
  Description: Card Shuffling 2 + Display!
  Author: JOHN STEPHENSON
  Date: 11-26-94  05:01
*)

{
> I am writing a Card game in TP 7 and have run into a problem.
> I need to generate a random order of numbers (Cards) 1 to 52
> without any duplicates, and with so speed. I have tried useing
> ramdom(52). Checking for #0 and for Duplicate numbers takes alot
> of time.
> Does anyone have any ideas how to do this quickly?

I rewrote the routine for one of my doors that I'm writing, and came up
with this, (note I've removed my jsdoor procedures in place of CRT's)
}

{$X+}
uses crt;
{ Globals for the draw card }
const
  backside = 0;
  hearts   = 1;
  diamonds = 2;
  spades   = 3;
  clubs    = 4;
  low      = 1;
  high     = 2;
  maxcards = 52;
type
  card = record
    suit,value: byte;
  end;
  cardstype = array[1..maxcards] of card;
Const
  backcard : card = (suit:0;value:0);

Function FSpace(num: word): string;{ Following space }
var temp: string;
begin
  str(num,temp);
  if length(temp) < 2 then temp := temp + ' ';
  fspace := temp;
end;

Function PSpace(num: word): string;{ Prior space }
var temp: string;
begin
  str(num,temp);
  if length(temp) < 2 then temp := ' ' + temp;
  pspace := temp;
end;

Procedure Drawcard(thecard: card);
{ To draw a card for High, low or to draw a card for blackjack }
var
  picture: char;
  first,second: string;
begin
  with thecard do
  if suit = backside then begin
    textattr := blue shl 4+yellow;
    write('░░░░░');
    gotoxy(wherex-5,wherey+1);
    write('░░░░░');
    gotoxy(wherex-5,wherey+1);
    write('░░░░░');
  end
  else begin
    case suit of
      hearts: begin
        picture := #3;
        textattr := lightgray shl 4+red;
      end;
      diamonds: begin
        picture := #4;
        textattr := lightgray shl 4+red;
      end;
      spades: begin
        picture := #6;
        textattr := lightgray shl 4+black
      end;
      clubs: begin
        picture := #5;
        textattr := lightgray shl 4+black
      end;
    end;
    case value of
      1: begin
        first := 'A ';
        second := ' A';
      end;
      2..10: begin
        first := FSpace(value);
        second := PSpace(value);
      end;
      11: begin
        first := 'J ';
        second := ' J';
      end;
      12: begin
        first := 'Q ';
        second := ' Q';
      end;
      13: begin
        first := 'K ';
        second := ' K';
      end;
    end;
    if value <> 14 then begin
      write(first+'  '+picture);
      gotoxy(wherex-5,wherey+1);
      write('  '+picture+'  ');
      gotoxy(wherex-5,wherey+1);
      write(picture+'  '+second);
    end
    else begin
      write('Joker');
      gotoxy(wherex-5,wherey+1);
      write(#25' '#5); { Five spaces }
      gotoxy(wherex-5,wherey+1);
      write('Joker');
    end;
  end;
  textattr := lightgray;
end;

Procedure ShuffleCards(var cards: cardstype);
Procedure Swapcard(var card1, card2: card);
var dummy: card;
begin
  dummy := card1;
  card1 := card2;
  card2 := dummy;
end; { End Swapcard }
var i: byte;
begin
  for i := 1 to maxcards do swapcard(cards[i],cards[random(maxcards)+1]);
end; { End Shufflecards }

Procedure SetupDeck(var cards: cardstype);
var i,j: byte;
begin
  for i := 1 to 4 do
    for j := 1 to 13 do begin
      cards[(I-1)*13+j].value := j;
      cards[(I-1)*13+j].suit := i;
    end;
end;

Procedure Drawcards(cards: cardstype);
var i,j: byte;
begin
  for i := 1 to 4 do
    for j := 1 to 13 do begin
      gotoxy((j-1)*6+1,(i-1)*4+1);
      drawcard(cards[(i-1)*13+j]);
    end;
end;

Var
  cards: cardstype;
begin
  randomize;
  { Init all the cards to face down }
  fillchar(cards,sizeof(cards),0);
  clrscr;
  drawcards(cards);
  readkey;
  Setupdeck(cards);
  drawcards(cards);
  readkey;
  Shufflecards(cards);
  drawcards(cards);
  readkey;
End.



