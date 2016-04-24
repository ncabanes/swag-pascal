(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0004.PAS
  Description: Word wrap #1
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:08
*)

{This was a Programming contest Program- BTW, this is to Van
Slingerhead, not to Mike...
}
Program Wordwrap; 
Uses Crt,Printer; 
Const
  max = 10; 
Var
  ch : Char;
  arr : Array[1..800] of Char;
  small,
  s : String;
  w,
  len,
  counter : Integer; 
begin
  w := 1;
  Writeln; Writeln;
  Repeat
    arr[w] := ReadKey;
    inc(w);
    if arr[w-1] = #8 then
      begin
        Write(#8' '#8);
        if w > 2 then
          dec(w,2)
        else
          w:= 1;
      end  { if }
    else
      Write(arr[w-1]);
  Until arr[w-1] = #13;
  arr[w-1] := ' ';

  dec(w);
  Writeln; Writeln;
  For counter := 1 to w do
    Write(arr[counter]);

  small := '';
  len := 0;
  Writeln(lst);
  Writeln(lst,'123456789012345678901234567890123456789012345');
  Writeln(lst,'         ^         ^         ^         ^    ^');
  For counter := 1 to w do
    begin
      if arr[counter] <> ' ' then
        begin
          small := small + arr[counter];
          inc(len);
        end
      else
        if len <= 45 then
          begin
            Write(lst,small,' ');
            small := '';
            inc(len);
          end
        else
          begin
            Writeln(lst);
            Write(lst,small,' ');
            len := length(small)+1;
            small := '';
          end;  { else }
    end; 
end.


