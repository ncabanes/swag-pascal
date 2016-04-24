(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0061.PAS
  Description: EQUATION parser
  Author: KD TART
  Date: 01-27-94  11:59
*)

{
> I'm currently working on a small program for a Turbo Pascal class
> I am taking.  The assignment is to write a program that solves a system
> of equations via Cramer's Rule.  For example:
>
> 4x - 3y + 9z = 21
> 5x - 43y - 3z = 45
> 34x - 394y + 32z = 9
>
> and then find values for x, y, and z.
>
>    Now this is no problem:  I simply get input into a 3 x 4 array, which
> would look like this for the sample above:
>
> 4    -3     9     21
> 5    -43    -3    45
> 34   -394   32    9
>
>    The problem I am having is getting this input from the user.  Now I
> have thought of a few ways to accomplish this, namely:
>
> (1) Ask the user to enter the coefficients and the answer on a line and
> hit return, and do this for each equation--this method allows me to put the
> data directly into the array.
>
> (2) Give a rigid example of how and where to enter the equation, for
> example #####x(sign)#####y(sign)#####z = #####
> so I know where to read for the values to put into the array.
>
> (3) Possibly use the Val procedure and ask the user to input all number
> as in #1, but separate the numbers with dashes.
>
> (4) Possibly convert string values to their ascii equivalent, and see if
> they are numbers, turning non numbers into spaces.
>
> But, what I would rather do is to prompt the user for the whole equation
> and have him/her type it out naturally and then pick the numbers out of
> it to put into the 3x4 array.  Example:
>
> Enter equation #1:
> 3x + 4y - 8z = 45
> ...
>
>    This would seem to require storing the input as a string, and as far
> as I know, you can't pick values of a string (except in a limited sense
> with the Val function as touched upon above).  But I think that it has
> to be possible for me to process a naturally typed out equation!  And I
> would appreciate pointers to that effect.

The following code, written in Turbo Pascal 6, should do what you
want. You may want to test it more thoroughly than I did, and tidy up
the code a bit. It checks for validity of input. Values are stored as
reals.

It reads in the equation, and puts the values into the global array
eq_array.
}

program input_equations(input, output);

type
  eq_string = string[40];

var
  instr :eq_string;
  eq_array :array [1..3, 1..4] of real;
  eq_num :byte;
  x, y, z, answer :real;
  eq_ok :boolean;


procedure prepare_equation_string (var s :eq_string);
{ Removes spaces and converts all letter to upper case }
var
  tempstr :eq_string;
  n :byte;
begin
  tempstr := '';
  for n := 1 to length(s) do
    if s[n] <> ' ' then tempstr := tempstr + upcase(s[n]);
  s := tempstr
end;

function get_arguments (s :eq_string; var a1, a2, a3 :eq_string) :boolean;
{ Splits equation into argument.
  eg, if s='3X+4Y-Z', then a1='3X', a2='+4Y', a3='-Z'.

If any argument is blank, or there are more than 3 arguments,
returns FALSE, otherwise returns TRUE }

  function next_arg (s :eq_string) :eq_string;
  var
    n :byte;
  begin
    n := 2;
    while (n <= length(s)) and not (s[n] in ['+', '-']) do
      inc (n);
    next_arg := copy (s, 1, n-1);
  end;

begin
  a1 := next_arg (s);
  delete (s, 1, length(a1));
  a2 := next_arg (s);
  delete (s, 1, length(a2));
  a3 := next_arg (s);
  delete (s, 1, length(a3));
  get_arguments := ((length(a1)*length(a2)*length(a3)) > 0) and
                   (s = '')
end;

function assign_values (var x, y, z :real; a1, a2, a3 :eq_string) :boolean;
var
  x_assigned, y_assigned, z_assigned, ok_so_far :boolean;

    function assign_value (s :eq_string) :boolean;
    var
      id :char;
      value :real;
      resultcode :integer;
      ok :boolean;
    begin
      id := s[length(s)];
      delete (s, length(s), 1);
      if (s = '') or (s = '+') then
        s := '1';
      if s = '-' then
        s := '-1';
      val (s, value, resultcode);
      ok := (resultcode = 0);
      case id of
        'X' : begin
                x := value;
                x_assigned := true
              end;
        'Y' : begin
                y := value;
                y_assigned := true
              end;
        'Z' : begin
                z := value;
                z_assigned := true
              end
      else
        ok := false
      end;
      assign_value := ok
    end;

begin
  x_assigned := false;
  y_assigned := false;
  z_assigned := false;
  ok_so_far  := assign_value (a1);
  ok_so_far  := ok_so_far and assign_value (a2);
  ok_so_far  := ok_so_far and assign_value (a3);
  assign_values := ok_so_far and x_assigned and y_assigned and z_assigned;
end;

function extract_values(s : eq_string; var x, y, z, ans : real) : boolean;
var
  ok_so_far : boolean;
  n : byte;
  lhs, rhs,
  a1, a2, a3 : eq_string;
  resultcode : integer;

begin
  ok_so_far := true;
  prepare_equation_string(s);
  n := pos ('=', s);
  if n = 0 then
    ok_so_far := false                     { No = in equation }
  else
  begin
    rhs := copy (s, n+1, length(s)-n);
    if pos ('=', rhs) > 0 then
      ok_so_far := false                 { More than one = in equation }
    else
    begin
      lhs := copy (s, 1, n-1);
      if (lhs = '') or (rhs = '') then
        ok_so_far := false             { At least one side of equation }
      else                             { is blank }
      begin
        ok_so_far := get_arguments (lhs, a1, a2, a3);
        ok_so_far := ok_so_far and assign_values (x, y, z, a1, a2, a3);
        val (rhs, ans, resultcode);
        ok_so_far := ok_so_far and (resultcode = 0)
      end;
    end;
  end;
  extract_values := ok_so_far;
end;

begin
  for eq_num := 1 to 3 do
  begin
    repeat
      write ('Equation ', eq_num, ': ');
      readln (instr);
      eq_ok := extract_values (instr, x, y, z, answer);
      if not eq_ok then
        writeln ('Equation not in suitable format, try again');
    until eq_ok;
    eq_array [eq_num, 1] := x;
    eq_array [eq_num, 2] := y;
    eq_array [eq_num, 3] := z;
    eq_array [eq_num, 4] := answer;
  end;
end.


