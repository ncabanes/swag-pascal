(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0130.PAS
  Description: Calculate a formula using recursion
  Author: COLIN LAMARRE
  Date: 08-30-97  10:09
*)

{$S-}
{$M 65520,0,655360}
{$N+}

{ Cal.pas by Colin Lamarre, 1991
  Email: lamarre@vir.com

  This program calculates a formula using recursion.

}

const
  digits : set of char = ['0'..'9', '.', 'E'];

var
  answer : extended;
  rcal : string;
  print : boolean;
  i : integer;

procedure error(cal : string; var i : integer);
begin
  if print then
  begin
    writeln(copy(cal, i - 5, 10) + ' error.');
    print := false;
  end;
  i := length(cal) + 1;
end;

function clean(var toupper : string) : boolean;
var
  i, l, r : integer;
  t : string;
begin
  print := true;
  t := '';
  l := 0;
  r := 0;
  for i := 1 to length(toupper) do
    if toupper[i] <> ' ' then
    begin
      t := t + upcase(toupper[i]);
      if toupper[i] = '(' then
        l := l + 1;
      if toupper[i] = ')' then
        r := r + 1;
    end;
  if r <> l then
  begin
    writeln('Missing brackets');
    clean := false;
  end
  else
  begin
    if t = '' then
      toupper := '0'
    else
      toupper := t;
    clean := true;
  end;
end;

function fstr(x : extended) : string;
var
  s : string;
begin
  str(x:1:9, s);
  if s[1] = ' ' then
    delete(s, 1, 1);
  fstr := s;
end;

function fval(s : string) : extended;
var
  x : extended;
  code : integer;
begin
  val(s, x, code);
  fval := x;
end;

function prevnum(var temp : string; i : integer) : extended;
var
  oldi : integer;
begin
  oldi := i;
  while ((temp[i] in digits) or ((temp[i - 1] = 'E') and (temp[i] in ['+', '-']))) and (i >= 1) do
    dec(i);
  if (temp[i] in ['+', '-']) and ((i = 1) or (temp[i - 1] in ['+', '-', '*', '/'])) then
    dec(i);
  prevnum := fval(copy(temp, i + 1, oldi - i));
  delete(temp, i + 1, oldi - i);
end;

function signs(cal : string; var i : integer) : integer;
var
  sign : integer;
begin
  sign := 1;
  repeat
    if cal[i] = '-' then
    begin
      sign := sign * -1;
      inc(i);
    end
    else
    if cal[i] = '+' then
      inc(i);
  until not(cal[i] in ['-', '+']);
  signs := sign;
end;

function nextnum(cal : string; var i : integer) : extended;
var
  temp : string;
  sign : integer;
begin
  temp := '';
  sign := signs(cal, i);
  while (cal[i] in digits) and (i <= length(cal)) do
  begin
    temp := temp + cal[i];
    inc(i);
    if (cal[i - 1] = 'E') and (cal[i] in ['+', '-']) then
    begin
      temp := temp + cal[i];
      inc(i);
    end;
  end;
  nextnum := sign * fval(temp);
end;

function getbrackets(cal : string; var i : integer) : string;
var
  count : integer;
  temp : string;
begin
  count := 1;
  temp := '';
  repeat
    inc(i);
    if cal[i] = '(' then
      count := count + 1;
    if cal[i] = ')' then
      count := count - 1;
    temp := temp + cal[i];
  until (cal[i] = ')') and (count = 0);
  delete(temp, length(temp), 1);
  inc(i);
  getbrackets := temp;
end;

function doadd(temp : string) : extended;
var
  i : integer;
  tot : extended;
begin
  i := 1;
  tot := nextnum(temp, i);
  repeat
    inc(i);
    case temp[i - 1] of
      '+' : tot := tot + nextnum(temp, i);
      '-' : tot := tot - nextnum(temp, i);
    end;
  until i > length(temp);
  doadd := tot;
end;

function domuls(cal : string) : extended;
var
  i, sign : integer;
  temp, s : string;
begin
  i := 1;
  temp := '';
  repeat
    case cal[i] of
      '+', '-' : begin
                   temp := temp + cal[i];
                   inc(i);
                 end;

      '*' : begin
              inc(i);
              sign := signs(cal, i);
              if cal[i] in digits then
              begin
                s := fstr(sign * prevnum(temp, length(temp)) * nextnum(cal,i));
                temp := temp + s;
              end
              else
              if cal[i] = '(' then
              begin
                s := fstr(sign * prevnum(temp, length(temp)) * domuls(getbrackets(cal, i)));
                temp := temp + s;
              end
              else
                error(cal, i);
            end;

      '/' : begin
              inc(i);
              sign := signs(cal, i);
              if cal[i] in digits then
              begin
                s := fstr(sign * prevnum(temp, length(temp)) / nextnum(cal, i));
                temp := temp + s;
              end
              else
              if cal[i] = '(' then
              begin
                s := fstr(prevnum(temp, length(temp)) / (sign * domuls(getbrackets(cal, i))));
                temp := temp + s;
              end
              else
                error(cal, i);
            end;

      '0'..'9', '.' : while (cal[i] in digits) and (i <= length(cal)) do
                      begin
                        temp := temp + cal[i];
                        inc(i);
                        if (cal[i - 1] = 'E') and (cal[i] in ['+', '-']) then
                        begin
                          temp := temp + cal[i];
                          inc(i);
                        end;
                      end;

      '(' : temp := temp + fstr(domuls(getbrackets(cal, i)));

      else
        error(cal, i);
    end;
  until i > length(cal);
  domuls := doadd(temp);
end;

function dopowers(cal : string) : string;
var
  i, c : integer;
  x, f : extended;

  function fcnt(var cal : string; var i : integer) : integer;
  var
    j : integer;
  begin
    j := 0;
    while cal[i] = '!' do
    begin
      inc(j);
      dec(i);
    end;
    inc(i);
    delete(cal, i, j);
    fcnt := j;
  end;

  function fact(x : extended) : extended;
  var
    k, n : word;
    ans : extended;
  begin
    ans := 1;
    if x < 0 then
      fact := ans / (x - x);
    n := trunc(x);
    for k := 2 to n do
      ans := k * ans;
    fact := ans;
  end;

  function getprev(var cal : string; var i : integer) : extended;
  var
    oldi, count : integer;
  begin
    dec(i);
    oldi := i;
    if cal[i] <> ')' then
    begin
      while ((cal[i] in digits) or ((cal[i - 1] = 'E') and (cal[i] in ['+', '-']))) and (i >= 1) do
        dec(i);
      if (cal[i] in ['+', '-']) and ((i = 1) or (cal[i - 1] in ['+', '-', '*', '/'])) then
        dec(i);
      getprev := fval(copy(cal, i + 1, oldi - i));
      delete(cal, i + 1, oldi - i);
    end
    else
    begin
      count := 1;
      while (cal[i] <> '(') and (count <> 0) and (i >= 1) do
      begin
        dec(i);
        if cal[i] = ')' then
          count := count + 1;
        if cal[i] = '(' then
          count := count - 1;
      end;
      getprev := domuls(dopowers(copy(cal, i + 1, oldi - i - 1)));
      delete(cal, i, oldi - i + 1);
      dec(i);
    end;
  end;

  function getnext(var cal : string; i : integer) : extended;
  var
    oldi, sign, count : integer;
    temp : string;
  begin
    oldi := i;
    inc(i);
    temp := '';
    sign := signs(cal, i);
    if cal[i] <> '(' then
    begin
      while (cal[i] in digits) and (i <= length(cal)) do
      begin
        temp := temp + cal[i];
        inc(i);
        if (cal[i - 1] = 'E') and (cal[i] in ['+', '-']) then
        begin
          temp := temp + cal[i];
          inc(i);
        end;
      end;
      getnext := sign * fval(temp);
      delete(cal, oldi, i - oldi);
    end
    else
    begin
      count := 1;
      temp := '';
      repeat
        inc(i);
        if cal[i] = '(' then
          count := count + 1;
        if cal[i] = ')' then
          count := count - 1;
        temp := temp + cal[i];
      until (cal[i] = ')') and (count = 0);
      delete(temp, length(temp), 1);
      getnext := sign * domuls(dopowers(temp));
      delete(cal, oldi, i - oldi + 1);
    end;
  end;

begin
  i := length(cal);
  repeat
    case cal[i] of
      '^' : begin
              x := getnext(cal, i);
              if cal[i - 1] = '!' then
              begin
                dec(i);
                c := fcnt(cal, i);
                f := getprev(cal, i);
                for c := 1 to c do
                  f := fact(f);
                insert(fstr(exp(x * ln(f))), cal, i + 1);
              end
              else
                insert(fstr(exp(x * ln(getprev(cal, i)))), cal, i + 1);
            end;

      '!' : begin
              c := fcnt(cal, i);
              f := getprev(cal, i);
              for c := 1 to c do
                f := fact(f);
              insert(fstr(f), cal, i + 1);
            end;

      else
        dec(i);
    end;
  until i < 1;
  dopowers := cal;
end;

function dofuncs(cal : string) : string;
var
  i : integer;
  temp : string;

  function next3 : string;
  begin
    next3 := cal[i + 1] + cal[i + 2] + cal[i + 3];
  end;

  function asin(ratio : extended) : extended;
  begin
    asin := arctan(ratio / sqrt((1 - ratio) * (1 + ratio)));
  end;

  function acos(ratio : extended) : extended;
  begin
    acos := arctan(sqrt((1 - ratio) * (1 + ratio)) / ratio);
  end;

  function atan(ratio : extended) : extended;
  begin
    atan := arctan(ratio);
  end;

  function tan(angle : extended) : extended;
  begin
    tan := sin(angle) / cos(angle);
  end;

  function cot(angle : extended) : extended;
  begin
    cot := cos(angle) / sin(angle);
  end;

  function log(x : extended) : extended;
  begin
    log := ln(x) / 2.302585093;
  end;

begin
  i := 1;
  temp := '';
  repeat
    case cal[i] of
      '+', '-',
      '*', '/',
      '(', ')',
      '^', '!' : begin
                   temp := temp + cal[i];
                   inc(i);
                 end;

      'S' : begin
              if next3 = 'IN(' then
              begin
                inc(i, 3);
                temp := temp + fstr(sin(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
              if next3 + cal[i + 4] = 'QRT(' then
              begin
                inc(i, 4);
                temp := temp + fstr(sqrt(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
                error(cal, i);
            end;

      'C' : begin
              if next3 = 'OS(' then
              begin
                inc(i, 3);
                temp := temp + fstr(cos(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
              if next3 = 'OT(' then
              begin
                inc(i, 3);
                temp := temp + fstr(cot(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
                error(cal, i);
            end;

      'T' : begin
              if next3 = 'AN(' then
              begin
                inc(i, 3);
                temp := temp + fstr(tan(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
                error(cal, i);
            end;

      'A' : begin
              if next3 + cal[i + 4] = 'TAN(' then
              begin
                inc(i, 4);
                temp := temp + fstr(atan(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
              if next3 + cal[i + 4] = 'COS(' then
              begin
                inc(i, 4);
                temp := temp + fstr(acos(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
              if next3 + cal[i + 4] = 'SIN(' then
              begin
                inc(i, 4);
                temp := temp + fstr(asin(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
              if next3 = 'BS(' then
              begin
                inc(i, 3);
                temp := temp + fstr(abs(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
                error(cal, i);
            end;

      'L' : begin
              if next3 = 'OG(' then
              begin
                inc(i, 3);
                temp := temp + fstr(log(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
              if cal[i + 1] + cal[i + 2] = 'N(' then
              begin
                inc(i, 2);
                temp := temp + fstr(ln(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
              end
              else
                error(cal, i);
            end;

      'E' : if next3 = 'XP(' then
            begin
              inc(i, 3);
              temp := temp + fstr(exp(domuls(dopowers(dofuncs(getbrackets(cal, i))))));
            end;

      'P' : if cal[i + 1] = 'I' then
            begin
              inc(i, 2);
              temp := temp + fstr(pi);
            end
            else
              error(cal, i);

      '0'..'9', '.' : while (cal[i] in digits) and (i <= length(cal)) do
                      begin
                        temp := temp + cal[i];
                        inc(i);
                        if (cal[i - 1] = 'E') and (cal[i] in ['+', '-']) then
                        begin
                          temp := temp + cal[i];
                          inc(i);
                        end;
                      end;

      else
        error(cal, i);
    end;
  until i > length(cal);
  dofuncs := temp;
end;

begin
  rcal := '';
  for i := 1 to paramcount do
    rcal := rcal + paramstr(i);

  if clean(rcal) then
  begin
    answer := domuls(dopowers(dofuncs(rcal)));
    if print then
      writeln(answer:1:9);
  end;

end.


