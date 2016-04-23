(*
:Could someone please tell me how to disable CTRL-BREAK/C in my program so the
:user cannot exit without using my "exit" option?  The DOS BREAK=OFF just

The mother of all TP FAQs :-)

-From: garbo.uwasa.fi:/pc/ts/tsfaqp20.zip Frequently Asked TP Questions
-Subject: Disabling or capturing the break key

1. *****
 Q: I don't want the Break key to be able to interrupt my TP
programs. How is this done?
 Q2: I want to be able to capture the Break key in my TP program.
How is this done?
 Q3: How do I detect if a certain key has been pressed?

 A: This very frequently asked question is basically a case of RTFM
(read the f*ing manual). But this feature is, admittedly, not very
prominently displayed in the Turbo Pascal reference. (As a general
rule we should not use the newsgroups as a replacement for our
possibly missing manuals, but enough of this line.)
   There is a CheckBreak variable in the Crt unit, which is true by
default. To turn it off use
     uses Crt;
     :
     CheckBreak := false;
     :
Besides turning off break checking this enables you to capture the
pressing of the break key as you would capture pressing ctrl-c. In
other words you can use e.g.
     :
procedure TEST;
var key : char;
begin
  repeat
    if KeyPressed then
      begin
        key := ReadKey;
        case key of
          #3 : begin writeln ('Break'); exit; end;  {ctrl-c or break}
          else write (ord(key), ' ');
        end; {case}
      end; {if}
  until false;
end;
     :
IMPORTANT: Don't test the ctrl-break feature just from within the TP
IDE, because it has ctlr-break handler ("intercepter") of its own
and may confuse you into thinking that ctrl-break cannot be
circumvented by the method given above.
  The above example has a double purpose. It also shows the
rudiments how you can detect if a certain key has been pressed. This
enables you to give input without echoing it to the screen, which is
a later FAQ in this collection.
  This is, however, not all there can be to break checking, since
the capturing is possible only at input time. It is also possible to
write a break handler to interrupt a TP program at any time. For
more details see Ohlsen & Stoker, Turbo Pascal Advanced Techniques,
Chapter 7. (For the bibliography, see FAQPASB.TXT in this same FAQ
collection).

 A2: Here is an example code for disabling Ctrl-Break and Ctrl-C
with interrupts
*)
  uses Dos;
  var OldIntr1B : pointer;  { Ctrl-Break address }
      OldIntr23 : pointer;  { Ctrl-C interrupt handler }
      answer    : string;   { For readln test }
  {$F+}
  procedure NewIntr1B (flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp : word);
            Interrupt;
  {$F-} begin end;
  {$F+}
  procedure NewIntr23 (flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp : word);
            Interrupt;
  {$F-} begin end;
  begin
    GetIntVec ($1B, OldIntr1B);
    SetIntVec ($1B, @NewIntr1B);   { Disable Ctrl-Break }
    GetIntVec ($23, OldIntr23);
    SetIntVec ($23, @NewIntr23);   { Disable Ctrl-C }
    writeln ('Try breaking, disabled');
    readln (answer);
    SetIntVec ($1B, OldIntr1B);    { Enable Ctrl-Break }
    SetIntVec ($23, OldIntr23);    { Enable Ctrl-C }
    writeln ('Try breaking, enabled');
    readln (answer);
    writeln ('Done');
  end.
