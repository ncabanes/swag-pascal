(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0003.PAS
  Description: EQUATE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{ Author: Gavin Peters. }

Program PostFixConvert;
(*
 * This Program will convert a user entered expression to postfix, and
 * evaluate it simultaniously.  Written by Gavin Peters, based slightly
 * on a stack example given in Algorithms (Pascal edition), pg
 *
 *)
Var
  Stack : Array[1 .. 3] of Array[0 .. 500] of LongInt;

Procedure Push(which : Integer; p : LongInt);
begin
  Stack[which,0] := Stack[which,0]+1;
  Stack[which,Stack[which,0]] := p
end;

Function Pop(which : Integer) : LongInt;
begin
  Pop := Stack[which,Stack[which,0]];
  Stack[which,0] := Stack[which,0]-1
end;

Var
  c       : Char;
  x,t,
  bedmas  : LongInt;
  numbers : Boolean;

Procedure Evaluate( ch : Char );

  Function Power( exponent, base : LongInt ) : LongInt;
  begin
    if Exponent > 0 then
      Power := Base*Power(exponent-1, base)
    ELSE
      Power := 1
  end;

begin
  Write(ch);
  if Numbers and not (ch = ' ') then
    x := x * 10 + (Ord(c) - Ord('0'))
  ELSE
  begin
    Case ch OF
      '*' : x := pop(2)*pop(2);
      '+' : x := pop(2)+pop(2);
      '-' : x := pop(2)-pop(2);
      '/' : x := pop(2) div pop(2);
      '%' : x := pop(2) MOD pop(2);
      '^' : x := Power(pop(2),pop(2));
      'L' : x := pop(2) SHL pop(2);
      'R' : x := pop(2) SHR pop(2);
      '|' : x := pop(2) or pop(2);
      '&' : x := pop(2) and pop(2);
      '$' : x := pop(2) xor pop(2);
      '=' : if pop(2) = pop(2) then
              x := 1
            else
              x := 0;
      '>' : if pop(2) > pop(2) then
              x := 1
            else
              x := 0;
      '<' : if pop(2) < pop(2) then
              x := 1
            else
              x := 0;
      '0','1'..'9' :
            begin
              Numbers := True;
              x := Ord(c) - Ord('0');
              Exit
            end;
      ' ' : if not Numbers then
              Exit;
    end;

    Numbers := False;
    Push(2,x);
  end;
end;

begin
  Writeln('Gavin''s calculator, version 1.00');
  Writeln;
  For x := 1 to 3 DO
    Stack[x, 0] := 0;
  x := 0;
  numbers := False;
  Bedmas := 50;
  Writeln('Enter an expression in infix:');
  Repeat
    Read(c);
    Case c OF
      ')' :
        begin
          Bedmas := Pop(3);
          Evaluate(' ');
          Evaluate(Chr(pop(1)));
        end;

      '^','%','+','-','*','/','L','R','|','&','$','=','<','>' :
        begin
          t := bedmas;
          Case c Of

            '>','<' : bedmas := 3;
            '|','$',
            '+','-' : bedmas := 2;
            '%','L','R','&',
            '*','/' : bedmas := 1;
            '^'     : bedmas := 0;
          end;
          if t <= bedmas then
          begin
            Evaluate(' ');
            Evaluate(Chr(pop(1)));
          end;
          Push(1,ord(c));
          Evaluate(' ');
        end;
      '(' :
        begin
          Push(3,bedmas);
          bedmas := 50;
        end;
      '0','1'..'9' : Evaluate(c);
    end;

  Until Eoln;

  While Stack[1,0] <> 0 DO
  begin
    Evaluate(' ');
    Evaluate(Chr(pop(1)));
  end;
  Evaluate(' ');
  Writeln;
  Writeln;
  Writeln('The result is ',Pop(2));
end.

{
That's it, all.  This is an evaluator, like Reuben's, With a few
more features, and it's shorter.

Okay, there it is (the above comment was in the original post). I've
never tried it, but it looks good. :-) BTW, if it does work you might
want to thank Gavin Peters... after all, he wrote it. I was just
interested when I saw it, and stored it along With a bunch of other
source-code tidbits I've git here...
}

