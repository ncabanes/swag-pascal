(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0108.PAS
  Description: Re: keyboard buffer routines
  Author: BRIAN PETERSEN
  Date: 02-21-96  21:03
*)


{
GA> To clear the keyboard buffer
GA>
GA> To manipulate the status of the num lock, caps lock, and scroll lock keys

To flush the keyboard, you can do it like this: }

procedure flushkb; assembler;
asm
  mov ax,0c00h
  int 21h
end;

or simply use a "mem[$0000:$041c]:=mem[$0000:$041a];" command.  To toggle the
status of the number lock, caps lock, and scroll lock keys, the following
procedures can be used.

procedure capslock(on:boolean);
begin
  if on then mem[$40:$17]:=mem[$40:$17] or $40
    else
  mem[$40:$17]:=mem[$40:$17] and $bf;
end;

procedure numlock(on:boolean);
begin
  if on then mem[$40:$17]:=mem[$40:$17] or $20
    else
  mem[$40:$17]:=mem[$40:$17] and $df;
end;

procedure scrolllock(on:boolean);
begin
  if on then mem[$40:$17]:=mem[$40:$17] or $10
    else
  mem[$40:$17]:=mem[$40:$17] and $ef;
end;

... If you need routines to detect whether the caps/scroll/number lock keys
are on or off, these may be of use ...

function capslockon:boolean;
begin
  capslockon:=mem[$0040:$0017] and $40=$40;
end;

function numlockon:boolean;
begin
  numlockon:=mem[$0040:$0017] and $20=$20;
end;

function scrollockon:boolean;
begin
  scrollockon:=mem[$0040:$0017] and $10=$10;
end;

{
AN> im looking to make my own keypress/readkey routines, simply because
AN> of the  fact that readkey does all that keyboard aliasing (#0 leading a
AN> keypress, and  that #0 = alt and ctrl, etc).. does anyone have any
AN> routines that can help?

Try this on for size... instead of returning a character, it'll return a
word.  The high portion of the word contains the scan code (the one you
get after doing a second readkey if the first returned #0) and the lower
portion of the word contains the ascii code.
}

function getkey:word; assembler;
asm
  mov ah,10h
  int 16h
  cmp al,0e0h
  jne @end
  mov al,00h
  @end:
end;
                  { usage example ... }
var w:word;

begin
  w:=getkey;
  if hi(w)=0 then case lo(w) of
    59:write('F1');
    60:write('F2');
    61:write('F3');
    62:write('F4');
    63:write('F5'); { etc ... }
  end else case chr(lo(w)) of
    '1':write('Pressed 1');
    '2':write('Pressed 2');
    '3':write('Pressed 3');
    'A':write('Pressed A');
    'B':write('Pressed B');
    'C':write('Pressed C');
  end;
end.


