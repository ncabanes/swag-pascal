{
KEITH TYSINGER

You can make an encoder that will scramble a string(s) that even YOU, the
 programmer couldn't unscramble without a password. They are many different
 ways to scramble a string; just be creative! One way is to swap every
 character with another character ( ex. swap every letter 'A' with the number
 '1') , a better way would use a password to scramble it. Here is a simple
 procedure that requires the password, the string to be scrammbled, and returns
 the scrambled string. The password should not exceed 20 characters in length.
Forget about the messy code; I blame my word processor:
}

procedure encode(password, instring : string; var outstring : string);
var
  len,
  pcounter,
  scounter : byte;

begin
  len := length(password) div 2;
  scounter := 1;
  pcounter := 1;

  repeat
    outstring := outstring + chr(ord(password[pcounter]) +
                             ord(instring[scounter]) + len);
    inc(scounter);
    inc(pcounter);
    if pcounter > length(password) then
      pcounter := 1;
  until scounter > length(instring);
end;

procedure decode(password, instring : string; var outstring : string);
var
  len,
  pcounter,
  scounter : byte;

begin
  len := length(password) div 2;
  scounter := 1;
  pcounter := 1;

  repeat
    outstring := outstring + chr(ord(instring[scounter]) -
                             ord(password[pcounter]) - len);
    inc(scounter);
    inc(pcounter);
    if pcounter > length(password) then
      pcounter := 1;
  until scounter > length(instring);
end;

var
  password,
  original,
  scrambled,
  descrambled : string;
begin
  original := 'Hello There!';
  password := 'Eat my';
  encode(password, original, scrambled);
  writeln('orig = ', original);
  writeln('scrm = ', scrambled);
  decode(password, scrambled, descrambled);
  writeln('dcod = ', descrambled);
  readln;
end.

