{
[example on how to trap debuggers cut]

> The only problem is that people like me just go around this.  Ever tried
> to debug Out of this World?  They tried every trick possible.

I find a better way is to do this:

Procedure Annoy_Debugger;
Inline($CD/$01);

and sprinkle it (VERY!) generously through your code - since it's all inline,
it wont be a separate procedure, and thus cannot be disabled from one
point.... other tricks include (quietly) checking the byte at the address
pointed to by Int 1/3, if the byte contains $CF, then there's no debugger,
else quietly jump to $FFFF:$0000 (reboot address).
Also, this works very well:

A_Word:=$01CD;
If A_Word+$1111 <> $12DE Then
  Kick_Some_But;

This will detect search&replaces of CD 01.

Self-modifying code also works well, and getting the address of Int 1 and
doing a far call....
