{
: Is there a way that I can cut off all access to a hard drive in bp7.
: I mean like a security program that if you don't enter the right Password
: then it won't let you even read the HD... Is there a Dos function or
: something?

From: martijn@arbor.gds.nl (M. Moeling)
}

program x;
{$M 1024,0,0} {only if you use the keep 0}

procedure kill_int_13h; interrupt;

begin
end;

begin
  if not(get_password) then   {funtion that will get the password}
  begin
     setintvec($13,@kill_int_13h);
     keep 0;   {if you want to return to dos}
  end;
{
  the rest of your program
}
end.

{
int 13h is your hd interrupt. Dos uses functions of this int to manage you hd,
now you tp procedure does the job and returns without doing anything.
}