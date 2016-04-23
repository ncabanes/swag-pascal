{
> Does anyone know how to give up your free time under dv or dv/x? Or make
> these programs desqview aware?

DONATED TO THE PUBLIC DOMAIN by Danny Melton
}

program YourProgramHere;

uses
  DOS, CRT;

const
  MultiTasking : boolean = false;

function UnderDV : boolean;
var
  R : registers;
begin
  if MultiTasking then
    exit;
  R.AX := $1022;
  R.BX := $0000;
  intr($15, R);
  MultiTasking := boolean(R.BX <> 0);
  UnderDV := MultiTasking;
end;

procedure GiveUpTimeSlice;
var
  R : registers;
begin
  if not MultiTasking then
    exit;
  R.AX := $1000;
  intr($15, R);
end;

begin
  if UnderDV then
    writeln('Running under a multi-tasker.');
  writeln('Press a key when ready');
  while not keypressed do
    GiveUpTimeSlice;
  writeln('You pressed a key.');
end.

