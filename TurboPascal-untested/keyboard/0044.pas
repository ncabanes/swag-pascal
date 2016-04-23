{
SEAN PALMER

>I want to be able to transparently read a keypress.  In
>other Words, I'd like to know what key is being pressed,
>but allow the keypress to return to the keyboard buffer or
>to be read by the Program that's reading it.  I'd like this
>to Function as a TSR, and I need some way to Record the
>keypresses.  This is a very complicated problem which I
>have consulted many advanced Programmers With.  Please help
>if you are able.  Thanks in advance!

It returns the Character part of the Char/scan code combo in the current
head of the keyboard buffer queue in the bios data area.
The scan code would be at the location $40:head+1.

It would probably be more efficient if you used $0:$41A instead of
$40:$1A, but that might cause problems With protected mode.
}

Var
  head : Word Absolute $40 : $1A;
  tail : Word Absolute $40 : $1C;

Function peekKey : Char;
begin
  if head = tail then
    peekKey := #0
  else
    peekKey := Char(mem[$40 : head]);
end;

