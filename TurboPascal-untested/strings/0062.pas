{
MIKE COPELAND

> Does anybody know how to make a variable for a procedure or
> function use the special formatting like the write procedure?
> I can;t figure this out after several weeks of investigation..
> the str function is too 'clunky' is that the only way to do
> this?

   Write yourself a function which invokes the Str procedure.  Such a
routine should be in your global Unit, so you can access for every/any
program you create.  Here are mine:
}

function FSI(N : Longint; W : byte) : string;    { Convert LongInt to String }
var
  S : string;
begin
  if W > 0 then
    Str(N : W, S)
  else
    Str(N, S);
  FSI := S;
end;

function FSR(N : real; W, D : byte) : string;        { Convert Real to String }
var
  S : string;
begin
  Str(N : W : D, S);
  FSR := S;
end;
