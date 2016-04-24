(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0001.PAS
  Description: Routines for AVATAR
  Author: SEAN PALMER
  Date: 05-28-93  13:35
*)

{
SEAN PALMER

> Would you mind sharing that source w/us? I would like to
> add AVATAR support to my doors, yet don't have those FSC docs.

Here are some FSC Docs I got off a FIDO echo...

The basic commands are:   (AVT/0 FSC-0025)

   <^L>    -       clear the current Window and set current attribute
                   to default. In the basic session this means:
                   Clear the screen and set its attribute to 3.

   <^Y>    -       Read two Bytes from the modem. Send the first one
                   to the screen as many times as the binary value
                   of the second one. This is the exception where
                   the two Bytes may have their high bit set. Do
                   not reset it here!

   <^V> <^A> <attr> - Set the color attribute to <attr>. The default
                   attribute remains unchanged. However, all Text
                   will be displayed in <attr> Until the next ^V^A,
                   ^V^B, or ^L.

   <^V> <^B>   -   Turn the high bit of current attribute on. In
                   other Words, turn blink on.

   <^V> <^C>   -   Move the cursor one line up. Do nothing, if you
                   already are at the top line of the current
                   Window.

   <^V> <^D>   -   Move the cursor one line down. Do nothing if you
                   already are at the bottom line of the current
                   Window.

   <^V> <^E>   -   Move the cursor one column to the left. Do nothing
                   if you already are at the leftmost column of the
                   current Window.

   <^V> <^F>   -   Move the cursor one column to the right. Do nothing
                   if you already are at the rightmost column of the
                   current Window.

   <^V> <^G>   -   Clear the rest of the line in the current Window
                   using the current attribute (not to be confused
                   With the default attribute).

   <^V> <^H> <row> <col>   - Move the cursor to the <row> <col>
                   position Within the current Window.

New Commands (brief definitions) (AVT/0+ FSC-0037)

   <^V><^I>     -  Turn insert mode ON. It stays on Until any other AVT/0
                   command except <^Y> and <^V><^Y> is encountered after
                   which it is turned off;

   <^V><^J><numlines><upper><left><lower><right> - scroll area up;

   <^V><^K><numlines><upper><left><lower><right> - scroll area down;

   <^V><^L><attr><lines><columns>  - clear area, set attribute;

   <^V><^M><attr><Char><lines><columns>  - initialize area, set attribute;

   <^V><^N>     -  delete Character, scroll rest of line left;

   <^V><^Y><numChars><Char>[...]<count>  -  Repeat pattern.

and here is some source I use For AVATAR codes.
}

Unit Avatar;  {these Functions return avatar codes as Strings}
Interface

{AVT/0+ FSC-0025}

Const
 clearScr : String = ^L;
 blink    : String = ^V^B;
 up       : String = ^V^C;
 dn       : String = ^V^D;
 lf       : String = ^V^E;
 rt       : String = ^V^F;
 cleol    : String = ^V^G;

Function rep(c : Char; b : Byte) : String;
Function attr(a : Byte) : String;
Function goxy(x, y : Byte) : String;

{AVT/0+ FSC-0037}

Const

insMode : String = ^V^I;
delChar : String = ^V^N;

Function scrollUp(n, l, t, r, b : Byte) : String;
Function scrollDn(n, l, t, r, b : Byte) : String;
Function clear(a, w, h : Byte) : String;
Function fill(c : Char; a, w, h : Byte) : String;
Function pattern(s : String; n : Byte) : String;

Implementation

Function rep(c : Char; b : Byte) : String;
begin
  rep := ^Y + c + Char(b);
end;

Function attr(a : Byte) : String;
begin
  attr := ^V^A + Char(a and $7F);
end;

Function goxy(x, y : Byte) : String;
begin
  goxy := ^V^H + Char(y) + Char(x);
end;

Function scrollUp(n, l, t, r, b : Byte) : String;
begin
  scrollUp := ^V^J + Char(n) + Char(t) + Char(l) + Char(b) + Char(r);
end;

Function scrollDn(n, l, t, r, b : Byte) : String;
begin
  scrollDn := ^V^K + Char(n) + Char(t) + Char(l) + Char(b) + Char(r);
end;

Function clear(a, w, h : Byte) : String;
begin
  clear := ^V^L + Char(a) + Char(h) + Char(w);
end;

Function fill(c : Char; a, w, h : Byte) : String;
begin
  fill := ^V^M + c + Char(a) + Char(h) + Char(w);
end;

Function pattern(s : String; n : Byte) : String;
begin
  pattern := ^V^Y + s[0] + s + Char(n);
end;

end.


