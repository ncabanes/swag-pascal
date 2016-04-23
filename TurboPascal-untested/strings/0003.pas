{ CB> ...I work For a bank and would like to create a Program to
 CB> maintain better Record of our Cashier Checks and also any
 CB> stop payments on them..I have done very little Programming
 CB> on pascal. Ok here goes:
 CB>         I would like to make the input of numbers to move
 CB>         from a fixed point to the left and insert commas
 CB>         every three digits For monetary figures?

You will need to set up a dedicated Character by Character input routine using
ReadKey and controlling the display yourself.  After each Character is entered
examine it and determine whether or not to add a comma.  The following very
simple (and untested) routine demonstrates this.

For a better way to do such input find and download TCSEL003.* from a PDN node
near you and study the KEYINPUT Unit.  You may be able to modify it to do
exactly what you want or perhaps use it as a guide to producing your own
"bullet proof" input routine.
}
Uses
  Crt;

Function LastPos(ch : Char; S : String): Byte;
  { Returns the last position of ch in S or zero if ch not in S }
  Var
    x   : Word;
    len : Byte Absolute S;
  begin
    x := succ(len);
    Repeat
      dec(x);
    Until (x = 0) or (S[x] = ch);
    LastPos := x;
  end;  { LastPos }


Procedure GetNumber(fieldwidth: Byte);
  Var ch : Char;
      x,y: Byte;
      i  : Word;
      st : String;
  begin
    st := '';
    Write('Enter a number: ');
    x := WhereX;
    y := WhereY;
    Repeat
      ch := ReadKey;
      Case ch of
        '0'..'9': begin
                    if LastPos(',',st) = length(st)-3 then
                      st := st + ',';
                    st := st + ch;
                  end;
        #8      : begin
                    delete(st,length(st),1);
                    if st[length(st)] = ',' then
                      delete(st,length(st),1);
                  end;
        #13     : Exit;
      end;
      gotoXY(x,y);
      Write(st:fieldwidth);
    Until False;
  end;

begin
  Writeln;
  Writeln;
  getnumber(14);
end.