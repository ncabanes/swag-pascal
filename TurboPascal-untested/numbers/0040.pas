{
> I would also like some possible suggestions on a good random generator
> function or Procedure that is easy to understand.
}


{ Given }

var Seed; {among your globals}

{ You could try seeding it with: }

Procedure Randomise;

var
   hour, min, sec, sex100: word;
   root: Longint;

begin

   GetTime(hour,min,sec,sec100); {from Dos or WinDos unit}
   root := hour shr 1;
   root := root * sec * sec100;
   root := root shr 16;
   Seed := LoWord(root);   {needs WinAPI unit}
end;

{And to get a "random" integer in the range 0 to N - 1: }

function Random(Target: Integer): Integer;

var
   work: Longint;

begin
   work := Seed * Seed;
   work := work shr 16;
   Seed := LoWord(work);
   Random := Seed mod Target;
end;

