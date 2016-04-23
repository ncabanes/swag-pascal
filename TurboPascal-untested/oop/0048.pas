{
> A tiny question for the TV programmers (for me a big problem). I want to
> add a password to my TV program, so when I select a certain menu item, a
> dialog box must appear, where I have to give my password. Is there an easy
> solution to change the TInputline in this way that, if I enter a string,
> only '*' are displayed at the inputline.
}
type
  PPasswordLine = ^TPasswordLine;
  TPasswordLine = object(TInputLine)
    procedure Draw; virtual;
  end;

implementation

procedure TPasswordLine.Draw;
var
  Color: Byte;
  L, R: Integer;
  B: TDrawBuffer;
  S: String;
begin
  if State and sfFocused = 0 then
    Color := GetColor(1) else
    Color := GetColor(2);
  MoveChar(B, ' ', Color, Size.X);
  S:=Copy(Data^, FirstPos + 1, Size.X - 2);
  FillChar(S[1],length(S),'*');
  MoveStr(B[1], S, Color);
  if CanScroll(1) then MoveChar(B[Size.X - 1], #16, GetColor(4), 1);
  if State and sfFocused <> 0 then
  begin
    if CanScroll(-1) then MoveChar(B[0], #17, GetColor(4), 1);
    L := SelStart - FirstPos;
    R := SelEnd - FirstPos;
    if L < 0 then L := 0;
    if R > Size.X - 2 then R := Size.X - 2;
    if L < R then MoveChar(B[L + 1], #0, GetColor(3), R - L);
  end;
  WriteLine(0, 0, Size.X, Size.Y, B);
  SetCursor(CurPos - FirstPos + 1, 0);
end;
