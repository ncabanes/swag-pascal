{
> Some trouble-shooting With Turbo Vision, AGAIN!
> If i want to impelement this source code to
> show x in a Window, how do i do that!!

> For x:=1 to 100 do
>    WriteLn (x);

> That means that i want show x counting in the
> Window..........

Here a simple method you can use to get started. It has been tested, and it
does not do much, except show a counting dialog box.
}

Unit CountDlg;

Interface
Uses
  Objects, dialogs, views, drivers;
Type
  KDialog = Object(TDialog)
              Count : Word;
              ps    : PStaticText;
              Constructor Init(Var bounds:Trect;ATitle:TTitleStr);
              Procedure HandleEvent(Var Event:TEvent); virtual;
             end;
  PKDialog = ^KDialog;

Implementation

Function NumStr(n:Word):String;
Var
  S : String;
begin
  Str(n,s);
  NumStr := s;
end;

Constructor KDialog.Init(Var Bounds:TRect;ATitle:TTitleStr);
Var
  r : TRect;
begin
  inherited init(Bounds,ATitle);
  Count := 0;
  GetExtent(r);
  r.grow(-1,-2); r.b.y := r.a.y + 1;
  new(ps,init(r,'  Cyclycal counter := '+NumStr(Count)));
  insert(ps);
end;

Procedure KDialog.HandleEvent(Var Event:TEvent);
begin
  inc(Count);
  if count > 10000 then count := 0;
  DisposeStr(ps^.Text);
  ps^.Text := NewStr('  Cyclycal count := '+NumStr(Count));
  ps^.Draw;
  Inherited HandleEvent(Event);
end;

end.

{
And... the associated application to try it With ...
}

Program GenApp;
Uses
  Objects, App, Views, Dialogs, CountDlg;
Type
  GenericApp = Object(TApplication)
                 Procedure Run; Virtual;
               end;

Procedure GenericApp.Run;
Var
  r  : TRect;
begin
  GetExtent(R);
  R.Grow(-26,-10);
  ExecuteDialog(new(PKDialog,init(r,'Test Counter')),nil);
end;

Var MyApp : GenericApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
