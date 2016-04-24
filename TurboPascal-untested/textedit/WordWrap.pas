(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0012.PAS
  Description: Word Wrap
  Author: JASON KING
  Date: 05-25-94  08:24
*)

{
BT>Hello All...

BT>       Ok once again I have reached a brick wall in my program... What I
BT>was trying to do, was to make Word Wrap actully work... Turns out I was
BT>barking up the wrong tree... If you have examples on how to do this... Th
BT>please reply
BT>and let me know...

What I'm about to describe assumes you either have a loop of
procedure/function that'll read in one line as it works on a line by
line basis....  What I've always done (for wordwrap) is when entering a
line, it stores each character into a holding string that'll contain the
final line, you also have a string that contains the wrapped text, if
the user presses space, you clear the string holding the wrapped text,
and if they reach the end of the line, you erase as many characters as
the length of the string holding the wrapped text...

Example (untested):

(uses the CRT unit)
}

Procedure GetLineWithWrap(var Line,Wrap: String);
Const Cr=#13;
      BS=#8;
      EraseChar=#8+#32+#8;

Var HoldLine,HoldWrap: String;
    Ch: Char;
    Count: Byte;

Begin
     HoldWrap:='';
     HoldLine:='';
     if length(line)<>0 then begin
        HoldLine:=Line;
        Write(Line) end;
     Repeat
        While not keypressed do;
        Ch:=Readkey;
        If WhereX=80 and then begin
           For Count:=1 to Length(HoldWrap) Write(EraseChar);
           HoldLine:=Copy(HoldLine,1,Length(HoldLine)-Length(HoldWrap)-1);
           Line:=HoldLine;
           If Ch=#32 then Wrap:='' else Wrap:=HoldWrap+ch;
           Exit End;
        Case Ch of
            #13 : {nothing, but don't want it added to the line};
             #8 : If length(HoldLine)>0 then begin
                     Write(EraseChar);
                     If Length(HoldLine)>1 then
                       HoldLine:=Copy(HoldLine,1,Length(HoldLine)-1)
                       else HoldLine:='';
                     If Length(HoldWrap)>1 then
                       HoldWrap:=Copy(HoldWrap,1,Length(HoldWrap)-1)
                       else HoldWrap:='';
                   End;
             #32 : Begin
                HoldLine:=HoldLine+' ';
                HoldWrap:='' end;
        Else HoldLine:=HoldLine+Ch End;
    Until Ch=#13;
    Line:=HoldLine;
    Wrap:='';
    End;

