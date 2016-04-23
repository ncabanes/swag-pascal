{
>show some help Text or something, and then make it disappear
>without erasing the Text that the Window overlapped.  In other
>Words, there will be a screen full of Text, the Window would open
>up over some Text display whatever message, and disappear, leaving

The Text you see displayed on the screen can be captured to a Variable
and subsequently restored through direct screen reads/Writes.  Video
memory is located (on most systems) at $B800 For color and $B000 on
monochrome adapters.  Each screen location consists of two Bytes: 1) the
Foreground/background color of the location, and 2) the Character at the
location.

The following Program Writes a screen full of 'Text', captures this
screen to a Variable (VidScreen), Writes over top of the current screen,
then restores original screen stored in VidScreen.
}
Program OverLap;
Uses Crt;

Const
  VidSeg = $B800;     {..$B000 For monochrome}

Type
  VidArray = Array[1..2000] of Word;

Var
  VidScreen : VidArray;
  x : Integer;


Procedure SetScreenColor(back,Fore : Integer);
begin
  TextBackGround(back);
  TextColor(Fore);
end;


begin
  SetScreenColor(4,2);                   {.. green on red }
  ClrScr;
  For x := 1 to 25 do
    begin                                {..Write original screen }
    GotoXY(1,x);
    Write('Text Text Text Text Text Text Text Text Text Text Text '+
           'Text Text Text Text Text');
    end;
  readln;                                {..press enter to cont. }

  For x := 1 to 2000 do                  {..store current screen in }
    VidScreen[x] := MemW[VidSeg:x];      {  VidScreen Array }

  SetScreenColor(7,0);                   {..black on white }
  GotoXY(38,11);
  WriteLn('HELP');                       {..Write help Text, or }
  GotoXY(38,12);                         {  whatever... }
  WriteLn('HELP');
  GotoXY(38,13);
  WriteLn('HELP');
  readln;                                {..press enter to cont. }

  For x := 1 to 2000 do                  {..restore VidScreen Array }
    MemW[VidSeg:x] := VidScreen[x];
  readln;
end.
