{
SEAN PALMER

> name:_______________) problem, how do you make a field where you
> define the max Chars in the field and doNOT let the person Type more
> than that.  stop the users keyboard at the last Char in this Case its
> 78 Chars max and the field looks like this

Try this. Send it a default value, the length of the field, and a set of
Char containing all the valid Characters For the field.

}
Uses uInput,Crt;

Function getName : String;
Const
  nameMax = 20;
Var
  Count    : Integer;
  attrsave : Byte;
begin
  GotoXY(12, 2);
  Write('ENTER NAME:');
  attrsave := TextAttr;
  TextColor(0);
  TextBackground(7);
  GotoXY(26, 2);
  for Count := 1 to nameMax do
    Write(' ');  {draw inverse field}
  GotoXY(26, 2);
  getName  := input('Nobody', nameMax, ['A'..'Z','a'..'z','.',' ']);
  Textattr := attrsave;
end;

{----------}

{uInput}
{by Sean Palmer}
{released to the public domain}
 {2237 Lincoln St.}
 {Longmont, CO 80501}
{Alms gladly accepted! 8) }

Unit uInput;
{$B-,I-,N-,O-,R-,S-,V-,X-}

Interface

{tCharSet is used to specify Function keys to the input routine}
Type
  tCharSet = set of Char;

Function isKey : Boolean;
Inline(
 $B4/$B/   {mov ah,$B}
 $CD/$21/  {int $21}
 $24/$FE); {and al,$FE}

Function getKey : Char;
Inline(
 $B4/7/    {mov ah,7}
 $CD/$21); {int $21}

Function input(default : String; maxCh : Byte; cs : tCharSet) : String;

Implementation

Function input(default : String; maxCh : Byte; cs : tCharSet) : String;
Var
  p : Byte;
  c : Char;
  s : String[255];
begin
  s := default;
  Repeat
    c := getKey;
    if c = #0 then
      c := Char(Byte(getKey) or $80);
    Case c of
      ^H :
        if s[0] <> #0 then
        begin
          Write(^H, ' ', ^H);
          dec(s[0]);
        end;
      #127 :
        begin
          For p := length(s) downto 1 do
            Write(^H, ' ', ^H);
            s[0] := #0;
          end;
      ^M : ; {don't beep}
      ' '..'~' :
        if length(s) < maxCh then
        begin
          Write(c);
          inc(s[0]);
          s[Byte(s[0])] := c;
        end
        else
          Write(^G);

      else
        if c in cs then
        begin
          s[1] := c;
          s[0] := #1;
          c    := ^M;
        end
        else
          Write(^G);
    end;
  Until (c = ^M) or (c = ^[);

  if c = ^[ then
    input := default
  else
    input := s;

end;

end.

