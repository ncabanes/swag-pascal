(*
  Category: SWAG Title: PARSING/TOKENIZING ROUTINES
  Original name: 0008.PAS
  Description: Parsing A String
  Author: MARK OUELLET
  Date: 08-24-94  13:59
*)

{
RN> I have a routine in one of my programs that that reads a delimited string
RN> from a configuration file, the string is defined such as: ~040~055~099~144
RN> etc. (these are message base area numbers)

RN> In the program a check is done to see if the current area exists or does
RN> not exist in the list via a simple Pos() function.

RN> Works great! but.......

RN> I have been asked to include the capabilty to include a RANGE of numbers in
RN> this list, this being due to the 255 char limit of a normal string.


RN> So lets assume the list above will look like this:

RN> ~040~055~060-080~099~144

RN> How can I pull out the 060-080 and include all numbers between into the
RN> list or actually, do a check, possibly creating a Set?

RN> OR would I have to create another function/configuration item to do this?

RN> I hope my explanation of what I wish to accomplish can be understood. <g>

RN> All replies are very welcomed!!

Try this, the code is ugly but it works!
{Written, Tested and Compiled with BP 7.x}

uses crt;

type
  Str3 = string[3];
var
  Area, RangeLo, RangeHi : str3;
  List : String;

function Found(List:string;Area:str3):boolean;
begin
  if Pos(Area, List)>0 then begin
    Found := true;
  end else begin
    {
        Area not found yet, are there ranges??
    }
    if Pos('-', List)>0 then begin
      {
        Yes! Process ranges
      }
      while Pos('-', List) > 0 do begin
        RangeLo := Copy(List, Pos('-', List)-3, 3);
        {
          Area must be BETWEEN Lo and hi otherwise it would have
          been found by the first POS check. So if RangeLo is > Area
          No need to lose time extracting RangeHi
        }
        if RangeLo<Area then begin
          RangeHi := Copy(List, Pos('-', List)+1, 3);
          if RangeHi > Area then begin
            {
                Lo < Area < hi, We found a Match
            }
            Found := true;
            {
                Kill list to exit while-loop
            }
            List := '';
          end else begin
            {
                Kill this range's DASH, POS only reports the first match
            }
            Delete(List, Pos('-', List), 1);
          end;
        end else begin
            {
                Kill this range's DASH, POS only reports the first match
            }
          Delete(List, Pos('-', List), 1);
        end;
      end;
      {
        Only two possibilities when we get here
            1- List = '' which means a match was found and list was
                cleared to exit the while-loop.
            2- No match was found, in which case List is non-empty.
      }
      if List<>'' then
        Found := false;
    end else begin
      Found := false;
    end;
  end;
end;

var
  X : byte;

begin
  List := '~012~020~033~060-079~081~090~095-123~';
  clrscr;
  for X := 0 to 255 do begin
    Area := chr(48 + (X div 100)) +
            chr(48 + ((X mod 100) div 10)) +
            chr(48 + ((X mod 10)));
    writeln(Area, ' ', List, ' ', Found(List, Area));
    if (not boolean(x mod 24)) and (x>0) then begin
      while not keypressed do;
      while keypressed do readkey;
      clrscr;
    end;
  end;
end.


