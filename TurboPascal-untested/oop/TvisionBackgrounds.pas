(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0033.PAS
  Description: TVision Backgrounds
  Author: MARTIN WERNER
  Date: 01-27-94  12:23
*)

{
> I'm starting to play with TVision 1 and I would like to know how
> to change the background fill character.

Working example:
}

program otherbackground;

uses
  app, objects;

type
  pmyapp=^tmyapp;
  tmyapp=object(tapplication)
    constructor init;
  end;

constructor tmyapp. init;

  var
    r: trect;

  begin
    tapplication. init;
    desktop^. getextent(r);
    dispose(desktop^. background, done);
    desktop^. background:=new(pbackground, init(r, #1));
    desktop^. insert(desktop^. background);
  end;

var
  myapp: tmyapp;

begin
  myapp. init;
  myapp. run;
  myapp. done;
end.

