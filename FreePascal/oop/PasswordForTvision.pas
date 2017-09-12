(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0025.PAS
  Description: Password for TVision
  Author: EDWIN GROOTHUIS
  Date: 08-27-93  21:43
*)

{
EDWIN GROOTHUIS

somebody asked For a inputline For passWords. I have such one, but I've
forgotten WHICH discussionlist... so I'll mail it to the above lists, I
know it's one of it, and know it can be interesting For somebody else.

What I have done is overriden the Draw-Procedure For the inputline to draw
only ***'s instead of the right Characters.  The solution I gave yesterday
was not quitte correct: I used the Procedure SetData to put the *'s into the
Data^-field, but that Procedure calls the Draw-Procedure itself so you'll
get an infinite loop and a stack-overflow error. Now I put the *'s direct to
the Data^-field, I don't think it can give problems.
}

Uses
  app, dialogs, views, Objects;

Type
  PPassWord = ^TPassWord;
  TPassWord = Object(TInputLine)
                Procedure Draw; Virtual;
              end;


Procedure TPassWord.Draw;

Var
  s, t : String;
  i    : Byte;
begin
  GetData(s);
  t := s;
  For i := 1 to length(t) do
    t[i] := '*';
  Data^ := t;
  inherited Draw;
  Data^ := s;
end;

Procedure about;
Var
  d : pdialog;
  r : trect;
  b : pview;
begin
  r.assign(1, 1, 60, 15);
  d := new(pdialog,init(r, 'About'));
  With d^ do
  begin
    flags := flags or wfgrow;
    r.assign(1,1,10,3);
    insert(new(PButton, init(r,'~O~K', cmok, bfdefault)));
    r.assign(2,4,8,5);
    insert(new(PPassWord, init(r,10)));
  end;
  desktop^.execview(d);
  dispose(d, done);
end;


Var
  a : TApplication;
begin
  a.init;
  about;
  a.run;
  a.done;
end.
