{
 > Could someone give me some Pascal source on how to do
 > this:
 > I have created a shield program that password-protects
 > a specific program.
 > However, I cannot figure out how to make the password,
 > when being typed by
 > the person entering the code, to make a * or other
 > character instead of the
 > letter, so someone can't see what he's typing. Any
 > help here?

You have to read the chars without screen echo (using crt.readkey is easiest)
and write a char to screen for each valid input char:
}

USES Crt;

CONST CR = #13; { carriage return }

TYPE TCharSet = SET OF Char;

FUNCTION GetPwd(hide : Char; valid : TCharSet): String;
{ 'hide' is char to print. 'valid' is }
{ a set of valid characters for password }
{ dont put #13 in 'valid' }
VAR
  ch : Char;
  pwd : String;
BEGIN
  pwd := '';
  REPEAT
    ch := Readkey;
    IF (ch IN valid) THEN
    BEGIN
      Write(hide);
      pwd := pwd + ch
    END
    ELSE IF (ch <> CR) THEN { bad key }
      IF (ch <> #0) THEN
        Write(^G)
  UNTIL (ch = CR);
  GetPwd := pwd
END;

VAR
  p : String;
BEGIN
  Write('Enter password > ');
  p := GetPwd('*', ['a'..'z', 'A'..'Z', '0'..'9']);
  WriteLn;
  WriteLn('You entered: ', p);
  Readln
END.
