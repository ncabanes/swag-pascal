(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0194.PAS
  Description: Card Game of Spite & Malice
  Author: BENJAMIN ARNOLDY
  Date: 11-29-96  08:17
*)

{_____________________________________________________________________________
|  Filename: CODE.PAS
|     Title: Spite & Malice
|  Written By: Benjamin Arnoldy and Raechel Kula
|_____________________________________________________________________________
|  Contents:
|    The procedures: Deal, WhoseTurn, PickupCards, Decision, GetMove,
|                    CheckMove, MoveCard
|    Oject: Pile
|_____________________________________________________________________________
|  Synopsis:
|    This program allows the user to select either another person, or the
     computer as the opponent, then play the opponent in the card game
|    Spite & Malice.  The interface is textual.
|_____________________________________________________________________________
|  Description:
|    No references at this time.
|_____________________________________________________________________________
|  Environment:
|    TurboPASCAL for the PC.
|_____________________________________________________________________________
|  Version History:
|
|  Version 5.1 -- May 8, 1996
|              Raechel Kula & Benjamin Arnoldy
|              Improved interface and Decision.
|
|  Version 5.0 -- May 7, 1996
|              Raechel Kula & Benjamin Arnoldy
|              Code is cleaned up and ready for presentation.
|
|  Version 4.3 -- May 6, 1996
|               Raechel Kula & Benjamin Arnoldy
|               Additional testing, more tinkering with weights.
|
|  Version 4.2 -- May 5, 1996
|               Raechel Kula & Benjamin Arnoldy
|               Added provisions in decision for jokers.
|
|  Version 4.1 -- May 4, 1996
|                Raechel Kula & Benjamin Arnoldy
|                Testing and tinkering with weights to make
|                the computer a better opponent.
|
|  Version 4.0 -- May 3, 1996
|                Raechel Kula & Benjamin Arnoldy
|                An "operable" Decision procedure is
|                in place.
|
|  Version 3.1 -- May 2, 1996
|                Raechel Kula & Benjamin Arnoldy
|                Various Embellishments to make it an operable
|                2 player game (e.g. end of game stuff).
|
|  Version 3.0 -- May 1, 1996
|                 Raechel Kula & Benjamin Arnoldy
|                 Ascii Graphical Interface is instituted.
|
|  Version 2.9 -- April 30, 1996
|                 Raechel Kula & Benjamin Arnoldy
|                 Small display functions (CardString) coded.
|
|  Version 2.2 -- April 28, 1996
|                  Raechel Kula & Benjamin Arnoldy
|                  CheckMove procedure ironed out.
|
|   Version 2.1 -- April 26, 1996
|                  Raechel Kula & Benjamin Arnoldy
|                  Basic Main Program Procedures Modified to fit with new
|                  object structure.
|
|   Version 2.0 -- April 25, 1996
|                  Raechel Kula & Benjamin Arnoldy
|                   Object Pile Coded.
|
|    MidApril -- Meeting with Prof Squier & Subsequent Major Rethinking
|
|    Version 1.1 -- Apr. 7, 1996
|                   Raechel Kula & Benjamin Arnoldy
|                     Pieces of Decision and CheckMove procedures are
|                     completed.
|
|    Version 1.0 -- Mar. 29, 1996
|                   Raechel Kula & Benjamin Arnoldy
|                     WhoseTurn, PickupCards, MoveCard procedures are coded.
|                     The code successfully compiles.
|
|    Version 0.2 -- Mar. 12, 1996
|                   Raechel Kula & Benjamin Arnoldy
|                     Deal and GetMove procedures are coded.
|
|    Version 0.2 -- Mar. 5, 1996
|                   Raechel Kula & Benjamin Arnoldy
|                     GetValue and GetPlace procedures are coded.
|
|    Version 0.1 -- Feb. 30, 1996
|                   Raechel Kula & Benjamin Arnoldy
|                     Main Program and Stubs
|    Version 0.0
|____________________________________________________________________________}

program SpiteMalice;

uses CRT;

{=============================================================================
                                   CONSTANTS
=============================================================================}

const DRAWPILE_MAX = 108;
      HAND_MAX = 6;
      SCOREPILE_MAX = 14;
      DISCARDPILE_MAX = 108;
      ACEPILE_MAX = 13;
      TRASHPILE_MAX = 108;
      MAXSIZE = 108;
      NULL = -1;

{=============================================================================
                                     TYPES
=============================================================================}

type CardVal_t = integer;
     Pos_t = integer;
     CardArray_t = array [1..108] of CardVal_t;
     CardValTable_t = array [1..26] of CardVal_t;
     choiceTable_t = array [1..26, 1..19] of integer;

{=============================================================================
                              OBJECT DECLARATION
=============================================================================}

type Pile = object
   {public}
   procedure Init;
   procedure RandomShuffle;
   procedure PutOnTop (CardtoPutOn: CardVal_t);
   function RemoveFromTop: CardVal_t;
   function SeeRandom (Pos: Pos_t): CardVal_t;
   function DeleteByValue (value : CardVal_t): CardVal_t;
   function IsPresent (CardtoFind: CardVal_t): boolean;
   function NumCards: integer;

   private

   data: CardArray_t;
   top: Pos_t;  {top = slot with top card in it.}

end; {Object declaration}

{=============================================================================
                         OBJECT DEPENEDENT TYPES
=============================================================================}

Type pilepointer_t = ^Pile;
     stack_t = array [1..26] of pilepointer_t;

{=============================================================================
                                GLOBAL VARIABLES
=============================================================================}

var DrawPile: Pile;
    PlayerHand: Pile;
    ComputerHand: Pile;
    PlayerScorePile: Pile;
    ComputerScorePile: Pile;
    PlayerDiscardPile1: Pile;
    PlayerDiscardPile2: Pile;
    PlayerDiscardPile3: Pile;
    PlayerDiscardPile4: Pile;
    ComputerDiscardPile1: Pile;
    ComputerDiscardPile2: Pile;
    ComputerDiscardPile3: Pile;
    ComputerDiscardPile4: Pile;
    AcePile1: Pile;
    AcePile2: Pile;
    AcePile3: Pile;
    AcePile4: Pile;
    TrashPile: Pile;
    ComputerTurn: boolean;
    Game: boolean;
    Valid, Discard, DecisionDiscard: boolean;
    From, Tto: integer;
    PosTable : stack_t;
    TopCardTable: CardValTable_t;
    pos: integer;
    Winner: string;
    ChoiceRate: choiceTable_t;
    AnotherGame: boolean;
    TwoPlayer: boolean;
    MustMove: boolean;

{=============================================================================
                       OBJECT PROCEDURES & FUNCTIONS
=============================================================================}

{____________________________________________________________________
| Init
|       Initializes a pile's array (data) and pointer (top)
|___________________________________________________________________}

procedure Pile.Init;

var Count: integer;

begin
   top := MAXSIZE + 1;
   for Count := 1 to MAXSIZE do
      Pile.PutOnTop (NULL);   {Stores NULL values in entire array.}
   top := MAXSIZE + 1;
end; {procedure Init}

{____________________________________________________________________
| RandomShuffle
|         Shuffles the cards in a pile.
|___________________________________________________________________}

procedure Pile.RandomShuffle;

var ShuffleArray: Pile;  {Temporary Storage Pile}
    Counter: Pos_t;
    RandSlot: integer;
    DeckSize: integer;
    TopofDeck: Pos_t;

begin
   DeckSize := DrawPile.NumCards;
   TopofDeck := (MAXSIZE - DeckSize) + 1;
   ShuffleArray.Init;   {Initializing ShuffleArray}
   ShuffleArray.top := TopofDeck;
   for Counter := 1 to DeckSize do begin
      RandSlot := Random (DeckSize) + 1;  {'+1' due to Random range.}
      While ShuffleArray.SeeRandom (RandSlot) <> NULL do
         RandSlot := Random (DeckSize) + 1;
      ShuffleArray.top := TopofDeck + Randslot;
         {Set ShuffleArray's "top" pointer to slot beneath empty slot, so
          that PutOnTop will put the card in the empty slot.}
      ShuffleArray.PutOnTop (DrawPile.RemoveFromTop);
      ShuffleArray.top := TopofDeck;
   end; {for}
   ShuffleArray.top := TopofDeck;
      {Set ShuffleArray's "top" pointer to the top of the stack.}
   for Counter := 1 to DeckSize do
      DrawPile.PutOnTop (ShuffleArray.RemoveFromTop);
   {Transfered shuffled ShuffleArray to DrawPile.}
end; {Procedure RandomShuffle}

{____________________________________________________________________
| PutOnTop
|      Places a card value on the top of the pile.
|
|___________________________________________________________________}

procedure Pile.PutOnTop (CardtoPutOn: CardVal_t);

begin
   top := top - 1; {Advance the top pointer to the empty slot above it.}
   If top < 0 then begin
      writeln ('ERROR. Array Overflow.');
      HALT;
      {Program is stopped if program attempts to a put a card on top of what
       should be a full pile.  This should never never happen given that the
       size of the pile arrays are the same size as the number of cards.}
   end;
   data [top] := CardtoPutOn;
end; {procedure PutOnTop}

{____________________________________________________________________
| RemoveFromTop
|      Removes the top card from a pile and return the value of
|      of the card.
|___________________________________________________________________}

function Pile.RemoveFromTop: CardVal_t;

begin
   RemoveFromTop := data [top];
   data [top] := NULL;
   top := top + 1; {Adjusts the top pointer so it points at the top card.}
end; {Procedure RemoveFromTop}

{____________________________________________________________________
| SeeRandom
|      Allows the program to view the card value in any given
|      position in a stack.
|___________________________________________________________________}

function Pile.SeeRandom (pos: Pos_t): CardVal_t;

begin
   SeeRandom := data [top + pos - 1];
      {The "- 1" in the equation defines position 1 as the top card.}
   if (top + pos - 1) > MAXSIZE then
      SeeRandom := NULL;
   {if the seek excedes the boundaries, a null value is returned.}
end; {Procedure SeeRandom}

{____________________________________________________________________
|  DeleteByValue
|       Searches through a pile for a designated value, and "pulls"
|       the card out, returning the card's value.  After the card is
|       removed, the gap in the stack is filled in by readjusting the
|       cards.
|___________________________________________________________________}

function Pile.DeleteByValue (value : CardVal_t): CardVal_t;

var count:integer; hold : CardVal_t;

begin
   count:=0;
   Repeat
      count :=count+1;
   Until (data[count] = value);
   hold := data[top];
   data[top] := value;
   data[count] := hold;
   hold := Pile.RemoveFromTop;
end; {Procedure DeleteByValue}

{____________________________________________________________________
| IsPresent
|      Searches through a pile, looking to see if a designated card
|      value is present.
|___________________________________________________________________}

function Pile.IsPresent (CardtoFind: CardVal_t): boolean;

var
   ValuePresent: boolean;

begin
   ValuePresent := FALSE;
   while ((ValuePresent = FALSE) OR (top > MAXSIZE)) do begin
      top := top + 1;
      If data [top] = CardtoFind then
         ValuePresent := TRUE;
      end; {While}
      If ValuePresent = FALSE then
         IsPresent := FALSE
      else
         IsPresent := TRUE;
end; {Function IsPresent}

{____________________________________________________________________
|  NumCards
|      Returns the number of cards in a pile.
|___________________________________________________________________}

function Pile.NumCards: integer;

begin
   NumCards := (MAXSIZE - top) + 1;
      {The "+ 1" in the equation takes into account that the position of top
       contains a card.}
end; {function NumCards}

{============================================================================
                               GENERAL FUNCTIONS
============================================================================}

{____________________________________________________________________
|  CardValue
|     Converts card value (4..111) to orderinal value.
|     (0 = Joker, 1,2,3,...10,11 = JACK,...)
|___________________________________________________________________}

function CardValue (Card: CardVal_t): integer;

begin
   if Card = NULL then
      CardValue := NULL
   else
      CardValue := Card DIV 8;
end; {function CardValue}

{____________________________________________________________________
|  CardString
|     Converts a card value to a string, for representation on the
|     screen.
|___________________________________________________________________}

function CardString (Card: CardVal_t): string;
var
   Number: integer;
   Output: string;

begin
   Number := Card DIV 8;
   if Card = NULL then Output := '' else
   if Number = 0 then Output := 'JO' else
   if Number = 1 then Output := 'AC' else
   if Number = 2 then Output := '02' else
   if Number = 3 then Output := '03' else
   if Number = 4 then Output := '04' else
   if Number = 5 then Output := '05' else
   if Number = 6 then Output := '06' else
   if Number = 7 then Output := '07' else
   if Number = 8 then Output := '08' else
   if Number = 9 then Output := '09' else
   if Number = 10 then Output := '10' else
   if Number = 11 then Output := 'JA' else
   if Number = 12 then Output := 'QU' else
   if Number = 13 then Output := 'KI' else
   Output := 'ERROR';

   Number := Card MOD 4;
   if Card = NULL then Output := '' else
   if (Card DIV 8) = 0 then Output := Output + '!' else
   if Number = 0 then Output := Output + chr(3) else
   if Number = 1 then Output := Output + chr(4) else
   if Number = 2 then Output := Output + chr(5) else
   if Number = 3 then Output := Output + chr(6) else
   Output := 'ERROR';

   CardString := Output;

end; {function CardSuit}

{___________________________________________________________________
|  AceTopCard
|     Due to the possibility of a joker on an ace pile, this
|     function returns the ordinal value of the card on the top of
|     an ace pile -- if there's a joker it is converted to its
|     ordinal value within the pile.
|___________________________________________________________________}

function AceTopCard (Number: integer): integer;

var position: integer;

begin
   position := 1;
   while (CardValue (PosTable [Number]^.SeeRandom (position)) = 0) do
      position := position + 1;
   AceTopCard := CardValue (PosTable [Number]^.SeeRandom (position)) +
                 position - 1;
end; {function AceTopCard}

{============================================================================
                             MAIN PROGRAM PROCEDURES
                   (Grouped with corresponding sub-procedures)
============================================================================}

{___________________________________________________________________
|  Initialize
|      Does all the Non-Object initialization.
|__________________________________________________________________}

procedure Initialize;

var count:integer;

begin
   Randomize;
   DrawPile.Init;
   PlayerHand.Init;
   ComputerHand.Init;
   PlayerScorePile.Init;
   ComputerScorePile.Init;
   PlayerDiscardPile1.Init;
   PlayerDiscardPile2.Init;
   PlayerDiscardPile3.Init;
   PlayerDiscardPile4.Init;
   ComputerDiscardPile1.Init;
   ComputerDiscardPile2.Init;
   ComputerDiscardPile3.Init;
   ComputerDiscardPile4.Init;
   AcePile1.Init;
   AcePile2.Init;
   AcePile3.Init;
   AcePile4.Init;
   TrashPile.Init;
   Game := TRUE;

   {Set up Position Table}

   PosTable[1] := @PlayerHand;
   PosTable[2] := @PlayerHand;
   PosTable[3] := @PlayerHand;
   PosTable[4] := @PlayerHand;
   PosTable[5] := @PlayerHand;
   PosTable[6] := @PlayerHand;
   PosTable[7] := @PlayerScorePile;
   PosTable[8] := @PlayerDiscardPile1;
   PosTable[9] := @PlayerDiscardPile2;
   PosTable[10] := @PlayerDiscardPile3;
   PosTable[11] := @PlayerDiscardPile4;
   PosTable[12] := @AcePile1;
   PosTable[13] := @AcePile2;
   PosTable[14] := @AcePile3;
   PosTable[15] := @AcePile4;
   PosTable[16] := @ComputerDiscardPile1;
   PosTable[17] := @ComputerDiscardPile2;
   PosTable[18] := @ComputerDiscardPile3;
   PosTable[19] := @ComputerDiscardPile4;
   PosTable[20] := @ComputerHand;
   PosTable[21] := @ComputerHand;
   PosTable[22] := @ComputerHand;
   PosTable[23] := @ComputerHand;
   PosTable[24] := @ComputerHand;
   PosTable[25] := @ComputerHand;
   PosTable[26] := @ComputerScorePile;

end; {procedure Initialize}

{___________________________________________________________________
|  InitTable
|     Refreshes the values for the TopCardTable, which stores the
|     values of the top card in all 26 positions.
|__________________________________________________________________}

procedure InitTable;

var count:integer;

begin
   for count := 1 to 6 Do
      TopCardTable[count] := PosTable[count]^.SeeRandom (count);
   for count := 7 to 19 Do
      TopCardTable[count] := PosTable[count]^.SeeRandom (1);
   for count := 20 to 25 Do
      TopCardTable[count] := PosTable[count]^.SeeRandom(count-19);
   TopCardTable[26] := PosTable[26]^.SeeRandom(1);
end; {procedure InitTable}

{___________________________________________________________________
|  Deal
|    Deals the cards at the beginning of each game and decides,
|    based on the outcome of the deal, who will go first.
|__________________________________________________________________}

procedure Deal;

var Card: CardVal_t;
    Counter: integer;
    PlayerScoreTop: CardVal_t;
    ComputerScoreTop: CardVal_t;

begin
   for Card := (1 +3) to (MAXSIZE +3) do
      {Put 2 decks of cards in draw pile, +3 is necessary for the div and mod
       to operate correctly.}
      DrawPile.PutOnTop (Card);
   DrawPile.RandomShuffle;  {Shuffle the draw pile.}
   for Counter := 1 to 5 do begin {Deal the hands}
      PlayerHand.PutOnTop (DrawPile.RemoveFromTop);
      ComputerHand.PutOnTop (DrawPile.RemoveFromTop);
   end; {for}
   for Counter := 1 to 14 do begin {Deal the score piles}
      PlayerScorePile.PutOnTop (DrawPile.RemoveFromTop);
      ComputerScorePile.PutOnTop (DrawPile.RemoveFromTop);
   end; {for}
   PlayerDiscardPile1.PutOnTop (DrawPile.RemoveFromTop);
   PlayerDiscardPile2.PutOnTop (DrawPile.RemoveFromTop);
   PlayerDiscardPile3.PutOnTop (DrawPile.RemoveFromTop);
   PlayerDiscardPile4.PutOnTop (DrawPile.RemoveFromTop);
   ComputerDiscardPile1.PutOnTop (DrawPile.RemoveFromTop);
   ComputerDiscardPile2.PutOnTop (DrawPile.RemoveFromTop);
   ComputerDiscardPile3.PutOnTop (DrawPile.RemoveFromTop);
   ComputerDiscardPile4.PutOnTop (DrawPile.RemoveFromTop);
        {Decide whose turn it is.  ComputerTurn set to opposite, because
         it will be reversed in upcoming WhoseTurn procedure.}
   PlayerScoreTop := CardValue (PlayerScorePile.SeeRandom(1));
   ComputerScoreTop := CardValue (ComputerScorePile.SeeRandom(1));

   if PlayerScoreTop = 0 then
      ComputerTurn := FALSE
   else if ComputerScoreTop = 0 then
      ComputerTurn := TRUE
   else if PlayerScoreTop = ComputerScoreTop then
      ComputerTurn := FALSE
   else if PlayerScoreTop > ComputerScoreTop then
      ComputerTurn := TRUE
   else
      ComputerTurn := FALSE;

end; {Deal}

{___________________________________________________________________
|  OutString
|     One of the procedures involving the interface.
|     This procedure receives x,y coordinates for a screen position
|     and outputs a string starting at that position.
|__________________________________________________________________}

procedure OutString (x,y: integer; toPrint: string);

begin
   GotoXY (x,y);
   write (toPrint);
end; {procedure OutString}

{____________________________________________________________________
|  ColorDim
|     One of the procedures involving the interface.
|     Sets colors for displaying things involving the player whose
|     turn it is not (hence, they are dimmed.)
|___________________________________________________________________}

procedure ColorDim;

begin
   TextColor (LIGHTgray);
   TextBackground (BLACK);
end; {procedure ColorDim}

{___________________________________________________________________
|  ColorCard
|     One of the procedures involving the interface.
|     Sets colors for displaying a card of the player whose turn it
|     is.
|___________________________________________________________________}

procedure ColorCard;

begin
   TextColor (YELLOW);
   TextBackGround (BLUE);
end; {procedure ColorCard}

{____________________________________________________________________
|  ColorFrame
|     One of the procedures involving the interface.
|     Sets colors for highlighting the section of the frame
|     involving the player whose turn it is.
|___________________________________________________________________}


procedure ColorFrame;

begin
   TextColor (YELLOW);
   TextBackground (BLACK);
end; {procedure ColorFrame}

{____________________________________________________________________
|  ColorNormalText
|     One of the procedures involving the interface.
|     Sets colors for normal text and is also the colors which the
|     game returns to upon exiting.
|___________________________________________________________________}

procedure ColorNormalText;

begin
   TextColor (WHITE);
   TextBackground (BLACK);
end; {procedure ColorNormalText}

{___________________________________________________________________
|  ColorPosition
|     One of the procedures involving the interface.
|     Sets colors for the display of position indicators.
|__________________________________________________________________}

procedure ColorPosition;

begin
   TextColor (WHITE);
   TextBackground (RED);
end; {procedure ColorPosition}

{___________________________________________________________________
|  TitleScreen
|     Displays a title screen and asks whether the user would like
|     a one-player or a two-player game.  Accompanying procedures are
|     called by TitleScreen
|__________________________________________________________________}



procedure Heart;
begin
TextColor (red);
TextBackground (LightGray);
write (char(3));
end;

procedure Club;
begin
TextColor (black);
TextBackground (LightGray);
write (char(5));
end;

procedure Diamond;
begin
TextColor (red);
TextBackground (lightgray);
write (char(4));
end;

procedure Spade;
begin
TextColor (black);
TextBackground (lightgray);
write (char(6));
end;

procedure SuitsCol (x, y, count: integer);
var c :integer;
begin
c := 0;
while (count > 0) Do begin
 GotoXY (x, y+c*4);
 Heart;
 GotoXY (x, y+c*4+1);
 Club;
 GotoXY (x, y+c*4+2);
 Diamond;
 GotoXY (x, y+c*4+3);
 Spade;
 c := c + 1;
 count := count - 1;
 TextBackGround (black);
end; {while loop}
end; {SuitsCol}

procedure SuitsRow (x, y, count: integer);
var c :integer;
begin
c := 0;
while (count > 0) Do begin
 GotoXY (x + (4*c), y);
 Heart;
 Club;
 Diamond;
 Spade;
 c := c + 1;
 count := count - 1;
 TextBackground (black);
end; {while loop}
end; {SuitsRow}

procedure DrawTitleBox;
Begin
SuitsCol (25, 7, 2);
SuitsRow (25, 7, 8);
SuitsRow (25, 15, 8);
SuitsCol (57, 7, 2);
GotoXY (57, 15);
Heart;
end; {DrawTitleBox}

procedure Title;
 begin
  TextColor (white);
  TextBackground (black);
  OutString (28, 9, 'Welcome to Spite & Malice!');
 end;


procedure Info (var TwoPlayer : boolean);
var response : char;
begin
repeat
 OutString (33, 12, 'How many players?');
 OutString (37, 13, '(');
 TextColor (lightred);
 OutString (38, 13, '1 ');
 TextColor (white);
 OutString (40, 13, 'or ');
 TextColor (lightred);
 OutString (43, 13, '2');
 TextColor (white);
 OutString (44, 13,  ')');
 GotoXY (40, 14);
 readln (response);
 until ((response = '1') OR (response = '2'));
   if response = '1' then
      TwoPlayer := FALSE
   else
      TwoPlayer := TRUE;

end;

procedure TitleScreen (var TwoPlayer:boolean);

var response: char;

Begin
TextBackground (black);
clrscr;
TextBackground (black);
DrawTitleBox;
Title;
Info (TwoPlayer);
TextBackground (black);
TextColor (white);
End; {procedure TitleScreen}

{___________________________________________________________________
|  DrawFrame
|     One of the procedures involving the interface.
|     This procedure draws the ascii graphical skeleton of the
|     screen.  It also takes into account the turn in its choice of
|     colors.
|__________________________________________________________________}

procedure DrawFrame (ComputerTurn: boolean);

var Row: integer;
    Column: integer;

begin
   {Clear screen with Black background.}
   TextBackGround (BLACK);
   TextColor (BLACK);
   For Row:= 1 to 25 do
      For Column := 1 to 80 do begin
         if NOT ((Row = 25) and (Column = 80)) then
            OutString (Column, Row, chr(219));
      end; {for column}
   if ComputerTurn = TRUE then
      ColorDim
   else
      ColorFrame;
   OutString (1,1,chr(201));
   OutString (1,24,chr(200));
   OutString (31,1,chr(203));
   OutString (31,24,chr(202));
   for Column := 2 to 30 do begin
      OutString (Column,1,chr(205));
      OutString (Column,24,chr(205));
   end; {for}
   For Row := 2 to 23 do begin
      OutString (1,Row,chr(186));
      OutString (31,Row,chr(186));
   end; {for}
   Outstring (1,18,chr(204));
   Outstring (31,18,chr(185));
   For Row := 2 to 30 do
      OutString (Row,18,chr(205));
   OutString (31,5,chr(204));
   OutString (31,13,chr(204));
   if ComputerTurn = TRUE then
      ColorFrame
   else
      ColorDim;
   For Column := 51 to 79 do begin
      OutString (Column,1,chr(205));
      OutString (Column,18,chr(205));
      OutString (Column,24,chr(205));
   end; {for}
   For Row := 2 to 23 do begin
      OutString (50,Row,chr(186));
      OutString (80,Row,chr(186));
   end; {for}
   OutString (50,1,chr(203));
   OutString (50,24,chr(202));
   OutString (50,5,chr(185));
   OutString (50,13,chr(185));
   OutString (50,18,chr(204));
   OutString (80,1,chr(187));
   OutString (80,24,chr(188));
   ColorFrame;
   For Column := 32 to 49 do begin
      OutString (Column,1,chr(205));
      OutString (Column,5,chr(205));
      OutString (Column,13,chr(205));
      OutString (Column,24,chr(205));
   end; {for}

   TextColor (BLUE);
   for Row := 2 to 4 do
      for Column := 32 to 49 do
         OutString (Column,Row,chr(219));
   TextColor (WHITE);
   TextBackground (BLUE);
   OutString (34,2,'Spite & Malice');
   OutString (34,3,'By Ben Arnoldy');
   OutString (34,4,'& Raechel Kula');
end; {procedure DrawFrame}

{___________________________________________________________________
|  DrawDiscards
|     One of the procedures involved with the interface.
|     This procedure sets up the discard portions of the screen.
|__________________________________________________________________}

procedure DrawDiscards (ComputerTurn:boolean);

var Counter: Pos_t;

begin

   if ComputerTurn = TRUE then
      ColorDim
   else
      ColorNormalText;
   OutString (9,2,'Player Discard');
   if ComputerTurn = TRUE then
      ColorNormalText
   else
      ColorDim;
   if (TwoPlayer = FALSE) then
      OutString (58,2,'Computer Discard')
   else if (TwoPlayer = TRUE) then
      OutString (58,2,'Opponent Discard');
   ColorPosition;
   OutString (3,3,'H'+chr(26));
   OutString (10,3,'I'+chr(26));
   OutString (17,3,'J'+chr(26));
   OutString (24,3,'K'+chr(26));
   OutString (52,3,'P'+chr(26));
   OutString (59,3,'Q'+chr(26));
   OutString (66,3,'R'+chr(26));
   OutString (73,3,'S'+chr(26));
   for Counter := 1 to 14 do begin
      if ComputerTurn = TRUE then
         ColorDim
      else
         ColorCard;
      OutString(6,2+Counter,
         CardString (PlayerDiscardPile1.SeeRandom(Counter)));
      OutString(13,2+Counter,
         CardString (PlayerDiscardPile2.SeeRandom(Counter)));
      OutString(20, 2+Counter,
         CardString (PlayerDiscardPile3.SeeRandom(Counter)));
      OutString(27, 2+Counter,
         CardString (PlayerDiscardPile4.SeeRandom(Counter)));
      if ComputerTurn = FALSE then
         ColorDim
      else
         ColorCard;
      OutString(55, 2+Counter,
         CardString (ComputerDiscardPile1.SeeRandom(Counter)));
      OutString(62, 2+Counter,
         CardString (ComputerDiscardPile2.SeeRandom(Counter)));
      OutString(69, 2+Counter,
         CardString (ComputerDiscardPile3.SeeRandom(Counter)));
      OutString(76, 2+Counter,
         CardString (ComputerDiscardPile4.SeeRandom(Counter)));
   end; {for}
   {if there are too many cards in a discard pile to display...}
   TextColor (LIGHTred);
   TextBackground (BLACK);
   for Counter := 1 to 4 do begin
      if PosTable [7+Counter]^.NumCards > 14 then
         OutString ((-2 + (Counter*7)),17,'more');
      if PosTable [15+Counter]^.NumCards > 14 then
         OutString ((44 + (Counter*7)),17,'more');
   end; {for}
end; {procedure DrawDiscards}

{___________________________________________________________________
|  DrawHands
|     One of the procedures involved with the interface.
|     This procedure displays the hands and scorepiles.
|__________________________________________________________________}

procedure DrawHands (ComputerTurn:boolean);

var CardFace: string;

begin

   if ComputerTurn = TRUE then
      ColorDim
   else
      ColorNormalText;
   GotoXY (2,19);
   write ('Player''s Hand:');
   if ComputerTurn = FALSE then
      ColorDim
   else
      ColorNormalText;
   if (TwoPlayer = FALSE) then begin
      GotoXY (51,19);
      write ('Computer''s Hand:');
   end
   else if (TwoPlayer = TRUE) then begin
      GotoXY (51,19);
      write ('Opponent''s Hand:');
   end;
   ColorPosition;
   OutString (3,21,'A'+chr(24));
   OutString (8,21,'B'+chr(24));
   OutString (13,21,'C'+chr(24));
   OutString (18,21,'D'+chr(24));
   OutString (23,21,'E'+chr(24));
   OutString (28,21,'F'+chr(24));
   OutString (52,21,'T'+chr(24));
   OutString (57,21,'U'+chr(24));
   OutString (62,21,'V'+chr(24));
   OutString (67,21,'W'+chr(24));
   OutString (72,21,'X'+chr(24));
   OutString (77,21,'Y'+chr(24));
   If ComputerTurn = TRUE then
      ColorDim
   else
      ColorCard;
   OutString(3,20,CardString (PlayerHand.SeeRandom(1)));
   OutString(8,20,CardString (PlayerHand.SeeRandom(2)));
   OutString(13,20,CardString (PlayerHand.SeeRandom(3)));
   OutString(18,20,CardString (PlayerHand.SeeRandom(4)));
   OutString(23,20,CardString (PlayerHand.SeeRandom(5)));
   OutString(28,20,CardString (PlayerHand.SeeRandom(6)));
   If ComputerTurn = FALSE then
      ColorDim
   else
      ColorCard;
   If TwoPlayer then begin
      OutString(52,20,CardString (ComputerHand.SeeRandom(1)));
      OutString(57,20,CardString (ComputerHand.SeeRandom(2)));
      OutString(62,20,CardString (ComputerHand.SeeRandom(3)));
      OutString(67,20,CardString (ComputerHand.SeeRandom(4)));
      OutString(72,20,CardString (ComputerHand.SeeRandom(5)));
      OutString(77,20,CardString (ComputerHand.SeeRandom(6)));
   end {if}
   else begin
      CardFace := chr(168) + chr(63);
      if ComputerHand.NumCards > 0 then
         OutString(52,20,CardFace);
      if ComputerHand.NumCards > 1 then
         OutString(57,20,CardFace);
      if ComputerHand.NumCards > 2 then
         OutString(62,20,CardFace);
      if ComputerHand.NumCards > 3 then
         OutString(67,20,CardFace);
      if ComputerHand.NumCards > 4 then
         OutString(72,20,CardFace);
      if ComputerHand.NumCards > 5 then
         OutString(77,20,CardFace);
   end; {if-else}
   if ComputerTurn = TRUE then
      ColorDim
   else
      ColorNormalText;
   GotoXY (2,23);
   write ('Score Pile: ', PlayerScorePile.NumCards,
      ' cards> ');
   ColorPosition;
   write('G'+chr(26));
   TextColor (BLACK);
   TextBackground (BLACK);
   write(' ');
   if ComputerTurn = TRUE then
      ColorDim
   else
      ColorCard;
   write (CardString (PlayerScorePile.SeeRandom(1)));
   if ComputerTurn = FALSE then
      ColorDim
   else
      ColorNormalText;
   GotoXY (51,23);
   write ('Score Pile: ', ComputerScorePile.NumCards,
      ' cards> ');
   ColorPosition;
   write('Z'+chr(26));
   TextColor (BLACK);
   TextBackground (BLACK);
   write(' ');
   if ComputerTurn = FALSE then
      ColorDim
   else
      ColorCard;
   write (CardString (ComputerScorePile.SeeRandom(1)));
end; {procedure DrawHands}

{___________________________________________________________________
|  DrawAcePiles
|     One of the procedures involved with the interface.
|     This procedure draws the AcePile portion of the screen.
|__________________________________________________________________}

procedure DrawAcePiles;

var Counter: integer;

begin

   ColorNormalText;
   OutString (36,5,'Ace Piles:');
   ColorPosition;
   OutString (38,8,'L'+chr(26));
   OutString (38,9,'M'+chr(26));
   OutString (38,10,'N'+chr(26));
   OutString (38,11,'O'+chr(26));
   ColorCard;
   for Counter := 1 to 4 do begin
      OutString(41,7+Counter,CardString (TopCardTable [11+Counter] ));
      if CardValue( TopCardTable [11+Counter] )=0 then
         if AceTopCard (11+Counter) < 10 then
            OutString(45,7+Counter,chr(AceTopCard (11+Counter) + 48))
         else if AceTopCard (11+Counter) = 10 then
            OutString(45,7+Counter,'10')
         else if AceTopCard (11+Counter) = 11 then
            OutString(45,7+Counter,'JA')
         else if AceTopCard (11+Counter) = 12 then
            OutString(45,7+Counter,'QU')
         else if AceTopCard (11+Counter) = 13 then
            OutString(45,7+Counter,'KI');
   end; {for}
end; {Display}

{___________________________________________________________________
|  DrawMessageBox
|     One of the procedures involved with the interface.
|     This procedure clears the message portion of the screen and
|     prints a message displaying the turn.
|__________________________________________________________________}

procedure DrawMessageBox (ComputerTurn: boolean);

var
   Column: integer;
   Row: integer;

begin

   TextColor (BLACK);
   TextBackground (BLACK);
   for Column := 32 to 49 do
      for Row := 14 to 23 do
         OutString (Column,Row,chr(219));
   ColorNormalText;
   if ((ComputerTurn = TRUE) AND (TwoPlayer = FALSE)) then begin
      GotoXY (33,15);
      write ('Computer''s Turn');
   end
   else if ((ComputerTurn = TRUE) AND (TwoPlayer = TRUE)) then begin
      GotoXY (33,15);
      write ('Opponent''s Turn');
   end
   else begin
      GotoXY (34,15);
      write ('Player''s Turn');
   end;
end; {procedure DrawMessageBox}

{___________________________________________________________________
|  Display
|     This procedure directs the interface procedures for a complete
|     redrawing of the screen.
|__________________________________________________________________}

procedure Display;

begin
   clrscr;
   DrawFrame (ComputerTurn);
   DrawDiscards (ComputerTurn);
   DrawHands (ComputerTurn);
   DrawAcePiles;
   DrawMessageBox (ComputerTurn);
end; {Display}

{___________________________________________________________________
|  PickUpHand
|     Picks up the required number of cards from the draw pile and
|     places them in the hand of the person whose turn it is.
|     This procedure also checks to see if the draw pile has run out
|     of cards.  If so the trash pile is placed in the draw pile and
|     the draw pile is subsequently reshuffled.
|___________________________________________________________________}

Procedure PickupHand (var Hand : pile);

var numToGet, count, Counter : integer;

begin

   If (Hand.NumCards > 3)Then
      numToGet := 1
   Else
      numToGet := (5 - Hand.NumCards);

   For count := 1 to numToGet Do begin
      If DrawPile.NumCards = 0 then begin {Draw pile out of card, replenish}
         For Counter := 1 to TrashPile.NumCards do
            DrawPile.PutOnTop (TrashPile.RemoveFromTop);
         DrawPile.RandomShuffle;
      end; {if}
      Hand.PutOnTop (DrawPile.RemoveFromTop);
   end; {for}
end; {procedure PickupHand}

{____________________________________________________________________
|  PickUpCards
|     Sends correct hand to the PickupHand procedure according to
|     whose turn it is.
|___________________________________________________________________}

Procedure PickupCards;

begin
   If ComputerTurn Then
      PickupHand (ComputerHand)
   Else
      PickupHand (PlayerHand);

   InitTable; {Refresh the Top Card Table}
end; {PickupCards}

{____________________________________________________________________
|  HouseKeeping
|     Performs some checks after a card has been moved.
|     These checks include: removing completed ace piles,
|        checking for completed game, and checking for
|        insufficient cards to discard.
|___________________________________________________________________}

procedure HouseKeeping;

var Counter: integer;
    Counter2: integer;

begin

   InitTable; {Keep current top card information updated.}

   {Clean up any full ace piles.}

   for Counter := 12 to 15 do
      if PosTable [Counter]^.NumCards = 13 then
         for Counter2 := 1 to 13 do
            TrashPile.PutOnTop (PosTable [Counter]^.RemoveFromTop);

   {Check for Game over.}

   if ComputerScorePile.NumCards = 0 then
      begin
         Game := FALSE;
         Discard := TRUE;
         Winner := 'Computer';
      end; {if}

   if PlayerScorePile.NumCards = 0 then
      begin
         Game := FALSE;
         Discard := TRUE;
         Winner := 'Player';
      end; {if}

   {Run out of cards before discard.}

   If ((Discard = FALSE) AND ComputerTurn AND
       (ComputerHand.NumCards = 0)) then
      PickUpCards;
   If ((Discard = FALSE) AND (NOT ComputerTurn) AND
       (PlayerHand.NumCards = 0)) then
      PickUpCards;

end; {procedure HouseKeeping}

{____________________________________________________________________
|  MoveCard
|     Moves a card from one pile to another as specified.
|___________________________________________________________________}

Procedure MoveCard (From, Tto : integer);

var frompile : pilepointer_t;  value: CardVal_t;
    dummy: integer;

begin
  if ((From < 7) Or ((From > 19) AND (From < 26))) then begin
     frompile :=PosTable[From];
     value := TopCardTable[From];
     dummy := frompile^.DeleteByValue(value);
     PosTable[Tto]^.PutOnTop(value);
     end
  else
     PosTable[Tto]^.PutOnTop (PosTable[From]^.RemoveFromTop);

  HouseKeeping; {Calls the HouseKeeping procedure}
end; {procedure MoveCard}

{____________________________________________________________________
|  WhoseTurn
|     This procedure changes the turns.
|___________________________________________________________________}

Procedure WhoseTurn (var ComputerTurn : boolean);

begin
   If ComputerTurn Then
      ComputerTurn := False
   Else
      ComputerTurn := True;
end; {WhoseTurn}

{____________________________________________________________________
|  CheckMove
|     Checks to see if the move proposed is a) valid, and
|       b) a discard.
|___________________________________________________________________}

Procedure CheckMove(var From, Tto: integer);

var
   TopCard: integer;
   position: Pos_t;
   Counter: Pos_t;
   EmptyAcePile: boolean;

begin
   InitTable;
   Valid := TRUE;
   Discard := FALSE;
   MustMove := FALSE;
 

   If TopCardTable [From] = NULL then
      Valid := FALSE; {Invalid if moving from empty space.}
   If (Valid AND ((Tto < 8) OR (Tto > 19))) then
      Valid := FALSE;{Invalid if proposed to move card to ScorePiles or Hands}
   If (Valid AND ComputerTurn AND ((Tto < 12) OR (From < 12))) then
      Valid := FALSE; {Invalid if computer proposed to or from player's side.}
   If (VALID AND (NOT ComputerTurn) AND ((Tto > 15) OR (From > 15))) then
      Valid := FALSE; {Invalid if player proposed to or from computer's side.}
   If (VALID AND ((From > 11) AND (From < 16))) then
      Valid := FALSE; {Invalid if to Acepile from Acepile.}
   if (VALID AND (((Tto > 7) AND (Tto < 12)) OR ((Tto > 15) AND (Tto < 20)))
      AND (((From < 12) AND (From > 6)) OR ((From = 26) OR
      ((From > 15) AND (From < 20))))) then
      Valid := FALSE; {Invalid if to discard from a discard or score pile.}

   {Ace on top of Discard Pile must be played first.}

   EmptyAcePile := FALSE;
   for Counter := 1 to 4 do
      if PosTable [Counter + 11]^.NumCards = 0 then
         EmptyAcePile := TRUE;

   if (EmptyAcePile AND Valid) then
      for Counter := 1 to 4 do begin
         if ((ComputerTurn) AND (CardValue (TopCardTable [Counter + 15]) = 1)
           AND (From <> (Counter + 15))
           AND (NOT(CardValue(TopCardTable[From])=1))) then
            Valid := FALSE;
         if ((NOT ComputerTurn) AND (CardValue (TopCardTable[Counter+7]) = 1)
           AND (From <> (Counter + 7))
           AND (NOT(CardValue(TopCardTable[From])=1))) then
           Valid := FALSE;
      end; {for}

   if (EmptyAcePile AND Valid) then
      for Counter := 1 to 4 do begin
         if ((ComputerTurn) AND (CardValue (TopCardTable [Counter + 15]) = 1)
           AND (From = (Counter + 15))
           OR (CardValue(TopCardTable[From])=1)) then begin
            Valid := True;
            MustMove := True;
         end; {if}
      end; {for} {forces computer to play ace when
                   To/From scores below threshold}


   {Ace Piles Check}
   if (VALID AND ((Tto > 11) AND (Tto < 16))) then begin
      TopCard := AceTopCard (Tto);
      If ((TopCard = NULL) AND (CardValue (TopCardTable [From]) <> 1)) then
         Valid := FALSE {If placing non-ace on empty ace pile.}
      else if TopCard = NULL then
         Valid := TRUE
      else if CardValue(TopCardTable[From]) = 0 then
         Valid := TRUE {In all cases but as ace, joker is valid.}
      else if ((TopCard + 1) <> CardValue (TopCardTable[From])) then
         Valid := FALSE; {If it is not next card in series.}
   end; {if}

   {Discard Check}
   if (Valid AND ((ComputerTurn AND ((Tto < 20) AND (Tto > 15) AND (From > 19)
      AND (From < 26))) OR (NOT ComputerTurn AND ((Tto < 12) AND (Tto > 7)
      AND (From < 7) AND (From > 0))))) then
      if PosTable [Tto]^.NumCards > 0 then begin
         Discard := TRUE;
         if ComputerTurn then
            For Counter := 16 to 19 do
               if PosTable [Counter]^.NumCards = 0 then begin
                  Valid := FALSE;
                  Discard := FALSE;
               end; {if}
         if NOT ComputerTurn then
            For Counter := 8 to 11 do
               if PosTable [Counter]^.NumCards = 0 then begin
                  Valid := FALSE;
                  Discard := FALSE;
               end; {if}
      end; {if}
end;{CheckMove}

{____________________________________________________________________
|  GetMove
|     Requested a proposal for a move from the player.
|___________________________________________________________________}

Procedure GetMove (var From, Tto: integer);

var FromChar, ToChar: char;

begin
   Display;
   ColorNormalText;
   OutString (33,17,'Enter positions');
   ColorDim;
   OutString (35,18,'(@ to Quit)');
   ColorNormalText;
   OutString (33,19,'Move a card');
   OutString (33,20,'from: ');
   readln (FromChar);
   OutString (33,21,'to: ');
   readln (ToChar);
   From := ord(UpCase(FromChar)) - 64;
   Tto := ord(UpCase(ToChar)) - 64;

   {-64 to adjust for alphabet's position in ASCII table.}
   if ((From = 0) OR (Tto = 0)) then begin {quit}
      ColorNormalText;
      clrscr;
      HALT;
   end; {if}

   if ((From < 1) OR (From > 26) OR (Tto < 1) OR (From > 26)) then begin
      From := 1;
      Tto := 1;
   end; {if}

end; {GetMove}

{____________________________________________________________________
|  ResultsofCheck
|     Displays a message regarding the results of the check in
|     CheckMove.
|___________________________________________________________________}

procedure ResultsofCheck;

begin
   DrawMessageBox (ComputerTurn);    {Calls the DrawMessageBox procedure}
   ColorNormalText;
   OutString (33,17,'Proposed Move:');
   GotoXY (33,18);
   write ('From: ',chr(From + 64));
   GotoXY (33,19);
   write ('To: ',chr(Tto + 64));
   GotoXY (33,21);
   if NOT Valid then begin
      TextColor (WHITE+BLINK);
      write ('Is NOT Valid!!');
   end
   else begin
      TextColor (WHITE);
      write ('Is Valid.');
   end; {if else}
   TextColor (RED+BLINK);
   OutString (33,23,'Press <Enter>...');
   readln;
end; {ResultsofCheck}

{_____________________________________________________________________
|    PlayAgainBox
|     Displays Box and asks player if he/she wants to play again
|_____________________________________________________________________}
procedure PlayAgainBox;

Begin
 ColorNormalText;
 clrscr;
 DrawTitleBox;
 ColorNormalText;
 OutString (27, 11, 'Would you like to play again?');
 OutString (37, 12, '(');
 TextColor (LightRed);
 OutString (38, 12,  'Y ');
 TextColor (white);
 OutString (40, 12, 'or ');
 TextColor (lightRed);
 OutString (43, 12, 'N');
 TextColor (white);
 OutString (44, 12, ')');
End;

{____________________________________________________________________
|  GameOverDisplay
|     Notifies player that the game is over, displays who won, and
|     asks the player if he/she would like to play again.
|___________________________________________________________________}

Procedure GameOverDisplay (Winner: string);

var Response: char;
    Valid: boolean;

begin
   ColorNormalText;
   clrscr;
   DrawTitleBox;
   ColorNormalText;
   OutString (36, 10, 'Game Over!!');
   OutString (32, 12, 'The ');
   OutString (36, 12, Winner);
   OutString (44, 12,  ' wins!');
   readln;
   {Play Again?}
   Valid := FALSE;
   Repeat
      PlayAgainBox;
      readln (Response);
      if (Upcase (Response) = 'Y') then begin
         AnotherGame := TRUE;
         Valid := TRUE;
      end
      else
      if (Upcase (Response) = 'N') then begin
         AnotherGame := FALSE;
         Valid := TRUE;
      end
      else
      Valid := FALSE;
   Until Valid;
end; {function AnotherGame}

{___________________________________________________________________
|  SetUp
|     One of Decision's evaluative functions.
|     This function adds a negative weight if a play will result in
|     setting up the player to play from his/her score pile.
|__________________________________________________________________}

Function SetUp: integer;

const
   WEIGHT = -20;
   SWEIGHT =-10;

var
   position: integer;
   Points: integer;
   CardCanPlay: integer;
   ScoreCard: integer;
   CardPlayed: integer;

begin
   Points := 0;
   ScoreCard := CardValue (TopCardTable [7]);
   CardPlayed := AceTopCard (Tto) + 1;
   CardCanPlay := CardPlayed + 1;
   If CardCanPlay  = ScoreCard then begin
      Points := WEIGHT;
      For position := 16 to 26 do begin
         if CardValue (TopCardTable [position]) = ScoreCard then
            Points := 0;
         if position = From then
            if CardValue (PosTable [position]^.SeeRandom(2)) = ScoreCard then
               Points := 0;
      end; {for}
   end; {if}
   If (Points = WEIGHT) AND (From = 26) then
    Points := SWEIGHT;

   SetUp := Points;
end; {function SetUp}

{___________________________________________________________________
|  Block
|    One of Decision's evaluative functions.
|    This function adds a positive weight if the play results in
|    preventing the player from playing from his score pile.
|__________________________________________________________________}

function Block: integer;

const
   WEIGHT = 25;

var
   Points: integer;
   ScoreCard: integer;
   CardPlayed: integer;

begin
   Points := 0;
   ScoreCard := CardValue (TopCardTable [7]);
   CardPlayed := AceTopCard (Tto) + 1;
   If CardPlayed = ScoreCard then
      Points := WEIGHT;
   Block := points;
end; {Block}

{___________________________________________________________________
|  PlayMore
|    One of Decision's evaluative functions.
|    This function adds a positive weight if a play results in the
|    computer being able to play more cards.
|    It also adds a positive weight if a play allows the computer to
|    move a card.
|___________________________________________________________________}

function PlayMore: integer;

const
   WEIGHT = 15;  {If move allows the computer to move more cards.}
   WEIGHT2 = 10; {If Computer can move a card.}
var
   position: integer;
   Points: integer;
   CardCanPlay: integer;
   CardPlayed: integer;

begin
   Points := WEIGHT2; {Just for being able to play a card.}
   CardPlayed := AceTopCard (Tto) + 1;
   CardCanPlay := CardPlayed + 1;

   position := 16;
   While (Position < 27) do begin
      if CardValue (TopCardTable [position]) = CardCanPlay then
         Points := WEIGHT;
      if position = From then
         if CardValue(PosTable [position]^.SeeRandom (2)) = CardCanPlay then
            Points := WEIGHT;
      position := position + 1;
   end; {While}

        {Special case for Jokers}
   If CardValue (TopCardTable [From]) = 0 then
      Points := Points - WEIGHT;
   PlayMore := Points;
end; {function PlayMore}

{____________________________________________________________________
|  MoreCards
|     One of Decision's evaluative functions
|     This function adds weight to a play that will result in the
|     computer being able to pick up more cards at the beginning of
|     its next turn.  Additional weight is given to a play that will
|     result in the computer being able to pick up 5 more cards this
|     turn.
|____________________________________________________________________}

function MoreCards: integer;

const WEIGHT = 10;
      WEIGHT2 = 20;

var HolestoFill: integer;
    Counter: integer;
    Points: integer;

begin
   Points := 0;

               {creates empty discard pile, ie a hole to fill}
   If ((From >15) AND (From <20) AND (PosTable [From]^.NumCards = 1) AND
       (NOT CardValue(TopCardTable [From]) = 0)) then
      Points := WEIGHT;

             {takes into account the holes}
   HolestoFill := 0;
   If ((From > 19) AND (From < 26 )) then begin
      Points := WEIGHT;
      For Counter := 16 to 19 do begin
         If PosTable [Counter]^.NumCards = 0 then
            HolestoFill := HolestoFill + 1;
      end; {for}
      If (ComputerHand.NumCards - HolestoFill) = 0 then
          Points := WEIGHT2;

                 {special case for Jokers}
      If CardValue (TopCardTable [From]) = 0 then
          Points := Points - WEIGHT;
   end; {if}
   MoreCards := Points;
end; {MoreCards}

{_____________________________________________________________________
|  HelpScore
|     One of Decision's evaluative functions
|     This function will add positive weight to a play that results
|     in the computer being able to play from its score pile.
|____________________________________________________________________}

function HelpScore: integer;

const WEIGHT = 30;

var ScoreCard: integer;
    CardPlayed: integer;
    CardCanPlay: integer;
    Points: integer;

begin
   Points := 0;
   ScoreCard := CardValue (TopCardTable [26]);
   CardPlayed := AceTopCard (Tto) + 1;
   CardCanPlay := CardPlayed + 1;
   If CardCanPlay  = ScoreCard then
      Points := WEIGHT;
   HelpScore := Points;
end; {function HelpScore}

{_____________________________________________________________________
|  Score
|     One of Decision's evaluative functions.
|     This function adds positive weight to a score pile play.
|____________________________________________________________________}

function Score: integer;

const WEIGHT = 60;
      WEIGHT2 = 10;

var ScoreCard: integer;
    position: integer;
    Points: integer;

Begin
 Points := 0;
 if From = 26 then begin
   ScoreCard := CardValue (TopCardTable [26]);
   if (((AceTopCard (Tto) + 1) = ScoreCard) OR (ScoreCard = 0)) then begin
         Points := WEIGHT;
         if ((ScoreCard + 1) = CardValue (TopCardTable [7])) then begin
            Points := WEIGHT2;
            position := 16;
            while (position < 26) do begin
               position := position + 1;
               if ((TopCardTable [position] = 0)  OR
                   (TopCardTable [position] = (ScoreCard +1))) then
                   Points := WEIGHT;
            end; {While}
         end; {if}
   end; {if}
 end; {if}
 Score := Points;
end; {function Score}

{_____________________________________________________________________
|  SameScore
|     One of DiscardDecision's evaluative functions
|     This function adds a negative weight to a discard
|     of a card that is the same value as the computer's score
|     pile.
|____________________________________________________________________}

function SameScore: integer;

const WEIGHT = -5;
      JWEIGHT = -20;

var Points: integer;

begin
   Points := 0;
   If (CardValue(TopCardTable[From]) = CardValue (TopCardTable[26])) then
      Points := WEIGHT;

             {special case for Jokers}
   If CardValue (TopCardTable[From]) = 0 then
      Points := JWEIGHT;

   SameScore := Points;
end; {function SameScore}

{_____________________________________________________________________
|  Order
|     One of DecisionDiscard's evaluative functions
|     This function uses weights to prioritize a discard to the closest
|     possible lower value in relation to the top cards of the discard
|     piles.
|____________________________________________________________________}

function Order: integer;

const WEIGHT1 = 20;
      WEIGHT2 = 11;
      WEIGHT3 = 4;
      WEIGHT4 = -5;
      JWEIGHT = -20;

var next: CardVal_t;
    Points: integer;

begin

   next := CardValue (TopCardTable [Tto]) - 1;
   if (CardValue (TopCardTable [From]) = next)
      then Points := WEIGHT1;
   if ((CardValue (TopCardTable [From]) + 1) = next)
      then Points := WEIGHT2;
   if ((CardValue (TopCardTable[From]) + 1) < next)
      then Points := WEIGHT3;
   if (CardValue (TopCardTable [From]) > next)
      then Points := WEIGHT4;

      {special case for Jokers}
   if CardValue (TopCardTable [From]) = 0 then
      Points := JWEIGHT;

   Order := Points;
end; {Order}

{_____________________________________________________________________
|  HighCard
|     One of DecisionDiscard's evaluative functions.
|        This function weights the possible cards to fill in a space
|        in the discard piles.  It adds most weight to the highest
|        valued card.
|____________________________________________________________________}

function HighCard: integer;

var count, Points: integer;

begin
   Points := 0;
   if ((PosTable [16]^.NumCards = 0) OR (PosTable [17]^.NumCards = 0) OR
      (PosTable [18]^.NumCards = 0) OR (PosTable [19]^.NumCards = 0)) then
      for count := 20 to 25 do
         if (CardValue(TopCardTable [From]) >
            CardValue (TopCardTable [count])) then
            Points := Points + 1;
   HighCard := Points * 2;
end; {function HighCard}

{_____________________________________________________________________
|  DiscardDecision
|     This procedure is responsible for applying the various weights
|     on to the decision surrounding the computer's discard.
|____________________________________________________________________}

Procedure DiscardDecision (var From, Tto: integer);

var max: integer;
    f, t: integer;

Begin

   For f := 20 to 25 Do
      For t := 16 to 19 Do begin
         From := f;
         Tto := t;
      CheckMove (From, Tto);
      If Not (Valid) Then
         ChoiceRate[f, t] := -10000
      Else
         ChoiceRate[f, t] := ((HighCard) + (Order) + (SameScore));
      end; {for}

   From := 20;
   Tto := 16;
   max := 0;
   For f := 20 to 25 Do
      For t := 16 to 19 Do  begin
         If (ChoiceRate[f, t] > ChoiceRate[From, Tto]) Then  begin
            max := ChoiceRate[f, t];
            From := f;
            Tto := t;
         end; {if}
      end; {for}
End; {DiscardDecision}

{_____________________________________________________________________
|  Decision
|     This procedure is responsible for applying the weights to the
|     decision surrounding the computer's choice of moves.
|____________________________________________________________________}

Procedure Decision (var From, Tto: integer);

const Threshold = 10;

var Max: integer;
    f, t: integer;
Begin
   Display;
   For f := 1 to 26 do
      For t := 1 to 19 do
         ChoiceRate [f, t] := 0;

   For f := 16 to 26 Do
      For t := 12 to 15 Do begin
         From := f;
         Tto := t;
         CheckMove(From, Tto);
         If Not (Valid) Then
            ChoiceRate[f, t] := -10000
         Else
            ChoiceRate[f, t] := ((SetUp) + (Block) +
            (PlayMore) + (MoreCards) + (HelpScore) + (Score));
   end; {for}

   {Tests Threshold}
   From := 16;
   Tto := 12;
   max := 0;
   For f := 16 to 26 Do
      For t := 12 to 15 Do  begin
         If (ChoiceRate[f, t] > ChoiceRate[From, Tto]) Then  begin
            max := ChoiceRate[f, t];
            From := f;
            Tto := t;
         end; {if}
      end; {for}
   If (Max < Threshold) AND (NOT(MustMove)) Then
      DiscardDecision (From, Tto);

End; {Decision}

{============================================================================
                                 MAIN PROGRAM
============================================================================}


BEGIN {Main Program}
   Repeat
      TitleScreen (TwoPlayer);
      Initialize;
      Deal;
      While (Game) Do begin
            WhoseTurn (ComputerTurn);
            PickupCards;
            Repeat
                  If ((ComputerTurn) AND (NOT TwoPlayer)) Then
                      Decision (From, Tto)
                  Else
                      GetMove (From, Tto);
                  CheckMove(From, Tto);
                  ResultsofCheck;
                  If Valid then
                     MoveCard (From, Tto);
            Until (Discard);
      End; {While Loop}
      GameOverDisplay (Winner);
   Until (NOT AnotherGame);
END. {Main Program}



