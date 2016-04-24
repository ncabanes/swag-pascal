(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0027.PAS
  Description: Easy Prompt Changing in Shells
  Author: STEVE ROGERS
  Date: 11-26-94  05:02
*)

{
  That won't work, actually. He wants to change the _prompt_ in his
  shell. Here's one way:
}

{$m 4096,0,0}
uses
  dos;

var
  f : text;

begin
  assign(f,'chgprmpt.bat');
  rewrite(f);
  writeln(f,'@set prompt=Type EXIT to return to '+paramstr(0)+'$g');
  close(f);

  swapvectors;
  exec(getenv('COMSPEC'),'/K chgprmpt.bat');
  swapvectors;
end.

