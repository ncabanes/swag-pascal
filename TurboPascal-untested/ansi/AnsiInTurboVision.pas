(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0039.PAS
  Description: ANSI in Turbo Vision
  Author: ANDREW NOWINSKI
  Date: 05-26-95  23:30
*)

{
From: nowinski@sciborg.uwaterloo.ca (Andrew Nowinski)

To prroperly understand this article you must use a ANSI text driver to
see clearly what I mean, on the other hand you can use your imagination :-)

The following subroutine is from a program that I am having trouble with.
In big block letters I have formed the word TEST. When I run the following
code the last line of TEST which is :
         '      ██      ████████▄   ▀███████▀        ██';
does not show up in the turbo vision dialog box when running the program.
If you do not yet know what I mean, and you would like to help, please
adapt the following subroutine to a simple turbo vision application.


.
.
.
.
}
Uses
  Objects, App, Views, Dialogs;

var
  J: PDialog;
  Control: PView;
  R: TRect;

begin
  R.Assign(0, 0, 52, 13);
  J := New(PDialog, Init(R, 'Test'));
  with J^ do
  begin
    Options := Options or ofCentered;

    R.Grow(-1, -1);
    Dec(R.B.Y);
    Insert(New(PStaticText, Init(R,
    #13 +
    '  ▐████████▌  ████████▀   ▄████████▀   ██████████'#13+
    '      ██      ██          ██               ██    '#13+
    '      ██      ██▄▄▄▄▄▄    ██▄▄▄▄▄▄▄        ██    '#13+
    '      ██      ██▀▀▀▀▀▀            ██       ██    '#13+
    '      ██      ██                  ██       ██    '#13+
    '      ██      ████████▄   ▀███████▀        ██    ')));


    R.Assign(21, 10, 31, 12);

    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));

  end;

  if ValidView(J) <> nil then
  begin
    Desktop^.ExecView(J);
    Dispose(J, Done);

  end;

end;

begin
  TApplication.Init;
end;

