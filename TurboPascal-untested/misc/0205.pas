{
(* NOTE *)
Dice Object was created by Todd A. Jacobs and is hereby released
into the public domain.  Long live SWAG!

This unit is intended as a stand-alone object.  The idea was to
create a reusable object for dice games, such that types for 2d6,
2d10, 1d20, etc. (you role-playing gamers know what I mean) wouldn't
have to be created for each dice type.

The following sample code shows it's usage by writing a screenful of
random dice rolls:

	program DiceDemo;

	uses Dice;

	var
		d6: TDice;
                 i: byte;

	begin
		randomize;
		d6.init (3, 6);
		for i := 1 to 23 do
                    writeln (d6.roll);
		d6.done;
		readln;
	end. (*DiceDemo*)

No, it didn't have to be an object, but that's what I wanted to do.
Use it any way you like. =)

If you have any improvements to offer, please submit them to SWAG.
Thanks!
}

Unit
	Dice;

interface

type
	TDice = object
		NumDice: byte;
		Sides: byte;
		constructor Init (iDice, iSides: byte);
		function Roll: word; virtual;
		destructor Done; virtual;
	end; {type definition of TDice}

implementation

constructor TDice.Init;
begin
     NumDice := iDice;
     Sides := iSides;
end;

function TDice.Roll;
var
	iLoopCounter: byte;
	CurrValue: word;
begin
	CurrValue := 0;
	while iLoopCounter < NumDice do begin
		CurrValue := CurrValue + Random (Sides) + 1;
		inc (iLoopCounter);
		end; {while iLoopCounter}
	Roll := CurrValue;
end; {function Roll}

destructor TDice.Done;
begin
end;

end. {Unit Dice}
