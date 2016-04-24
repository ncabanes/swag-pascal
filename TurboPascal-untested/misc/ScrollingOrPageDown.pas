(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0097.PAS
  Description: Scrolling or page down
  Author: JAMIE RUTHERFORD
  Date: 05-26-94  06:19
*)


function More: string;
var
  Prompt: char;
begin
  More:='';
  if Pause and (Lines=mem[$40:$84]) then
    begin
      write('Continue - [Y]es, [N]o? ');
      Prompt:=ReadKey;
      writeln(upcase(Prompt));
      if Prompt in ['N','n'] then
        halt(0)
      Lines:=0
    end;
  inc(Lines)
end;      {More}

Pause and Lines are both global variables.  Since I call the function
from many other functions/procedures I decided it would be less work
then passing them through.  Pause is simple a flag deciding whether or
not you want pausing or not.  You may not want to take the same action I
did when the user doesn't want to continue.  The mem command looks at
memory location 0040:0084 which contains the number of lines on the
screen.  This prevents the need to check what mode the screen is in.

Anyways, the way I used it is as follows:

writeln(More,'What ever you may want to display');

Since functions are executed first, it determines wheter or not to
display the line or prompt to continue.

Hope that helps... (assuming you can figure out my explanations)

