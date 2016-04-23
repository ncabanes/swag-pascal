{ Three ways to find the BASE of a number }


function base2l(strin: string; base: byte): longint;

{ converts a string containing a "number" in another base into a decimal
  longint }

var cnter, len: byte;
    dummylint: longint;
    seendigit, negatize: boolean;
    begalpha, endalpha, thschr: char;
begin
  dummylint := 0;
  begalpha := char(65);
  endalpha := char(64 + base - 10);
  negatize := false;
  seendigit := false;
  len := length(strin);
  cnter := 1;

  { the following loop processes each character }

  while cnter <= len do begin
    thschr := upcase(strin[cnter]);
    case thschr of
      '-': if seendigit then cnter := len else negatize := true;

           { if we haven't seen any "digits" yet, it'll be a negative
             number; otherwise the hyphen is an extraneous character so
             we're done processing the string }

      '0' .. '9': if byte(thschr) - 48 < base then begin
                    dummylint := base*dummylint + byte(thschr) - 48;
                    seendigit := true;
                    end
                   else cnter := len;

           { 0-9: if the base supports the digit, use it; otherwise,
             it's an extraneous character and we're done }

      ' ': if seendigit then cnter := len;

           { space: if we've already encountered some digits, we're done }

      else begin

           { all other characters }

        if (thschr >= begalpha) and (thschr <= endalpha) then

          { an acceptable character for this base }

          dummylint := base*dummylint + byte(thschr) - 65 + 10
         else

          { not acceptabe: we're done }

          cnter := len;
        end;
      end;
    cnter := cnter + 1;
    end;
  if negatize then dummylint := -dummylint;
  base2l := dummylint;
  end;

{Another way:}

function l2base(numin: longint; base, numplaces: byte; leadzero: boolean): string;

{ Converts a longint into a string representing the number in another base.
  Numin = the longint; base = base; numplaces is how many characters the answer
  should go in; leadzero indicates whether to put leading zeros. }

var tmpstr: string;
    remainder, cnter, len: byte;
    negatize: boolean;
begin
  negatize := (numin < 0);
  if negatize then numin := abs(numin);

  { assign number of places in string }

  tmpstr[0] := char(numplaces);
  len := numplaces;

  { now fill those places from right to left }

  while numplaces > 0 do begin
    remainder := numin mod base;
    if remainder > 9 then
      tmpstr[numplaces] := char(remainder + 64 - 9)
     else
      tmpstr[numplaces] := char(remainder + 48);
    numin := numin div base;
    numplaces := numplaces - 1;
    end;

  { not enough room assigned: fill with asterisks }

  if (numin <> 0) or (negatize and (tmpstr[1] <> '0')) then
     for numplaces := 1 to byte(tmpstr[0]) do tmpstr[numplaces] := '*';

  { put in minus sign }

  if leadzero then begin
    if negatize and (tmpstr[1] = '0') then tmpstr[1] := '-'
    end
   else begin
    cnter := 1;
    while (cnter < len) and (tmpstr[cnter] = '0') do begin
      tmpstr[cnter] := ' ';
      cnter := cnter + 1;
      end;
    if negatize and (cnter > 1) then tmpstr[cnter - 1] := '-';
    end;
  l2base := tmpstr;
  end;

{ Yet another way }

Program ConvertBase;

Procedure UNTESTEDConvertBase(BaseN:Byte; BaseNNumber:String;
                                  BaseZ:Byte; var BaseZNumber:String);

var
  I: Integer;
  Number,Remainder: LongInt;

begin
 Number := 0;
 for I := 1 to Length (BaseNNumber) do
  case BaseNNumber[I] of
    '0'..'9': Number := Number * BaseN + Ord (BasenNumber[I]) - Ord ('0');
    'A'..'Z': Number := Number * BaseN + Ord (BasenNumber[I]) -
      Ord ('A') + 10;
    'a'..'z': Number := Number * BaseN + Ord (BasenNumber[I]) -
      Ord ('a') + 10;
    end; BaseZNumber := ''; while Number > 0 do
  begin
  Remainder := Number mod BaseZ;
  Number := Number div BaseZ;
  case Remainder of
    0..9: BaseZNumber := Char (Remainder + Ord ('0')) + BaseZNumber;
    10..36: BaseZNumber := Char (Remainder - 10 + Ord ('A')) + BaseZNumber;
    end;

end; end;


var BaseN,BaseZ:Byte;
    BaseNNumber,
    BaseZNumber:String;

Begin

 Write(' BASE N  > ');
 Readln(BaseN);
 Write(' NUMBER N> ');
 Readln(BaseNNumber);
 Write(' BASE Z  > ');
 Readln(BaseZ);
 Write(' NUMBER Z> ');
 UntestedConvertBase(BaseN,BaseNNumber,BaseZ,BaseZNumber);
 Writeln(BaseZNumber);
 Readln;
end.
