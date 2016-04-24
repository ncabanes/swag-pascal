(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0082.PAS
  Description: Scrolling Bars in JSDoor
  Author: JOHN STEPHENSON
  Date: 05-26-95  23:18
*)

{
For a good voting door I'd suggest using a scrolling bar to choose
like your choices, this is a demo from the upcomming v1.31a, but I'll
show it to you, because it's just nifty.
}

{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 16384,0,655360}
Program Linebar_demo;
Uses Jsmisc,Jsdoor,Asmmisc,Crt;
Const
  Product = 'Line Bar Demo';
  Version = '1.00a';
  Release = 'Gamma';
  Author  = 'John Stephenson';

Procedure Hiya1;
var loop: byte;
begin
  makebox(2,20,76,4,2,cyan shl 4+lightblue,true);
  textattr := cyan shl 4+blue;
  jsgotoxy(4,21); jswrite('Hiya!!!!!!!');
  textattr := cyan shl 4+yellow;
  jsgotoxy(4,22); jswrite('Press any key');
  jsreadkey;
  textattr := lightgray;
  for loop := 20 to 23 do begin
    jsgotoxy(2,loop);
    jsclreol;
  end;
end;

Const
  Choices = 8;
Var
  Select,Quit: boolean;
  Choice,Lastchoice: byte;
  ChoiceList: array[1..choices] of string[60];
  Loop: byte;
  Ch: Char;
  CtrlSeq: String[10];

Procedure DrawChoice(num: byte);
Begin
  jsgotoxy(11,num+7);
  if choice = num then textattr := blue shl 4+lightgray
  else textattr := lightgray;
  jswrite(' '+choicelist[num]+#25' '+char(57-length(choicelist[num])));
End;

Begin
  Fakedoorsys(doorsys);
  Jsclrscr;
  Textattr := blue shl 4+lightcyan;
  Jswrite(' '+product+' '+version+' '+release+' by
'+author+avtclreol+avtlightcyan);
Makebox(10,5,60,4+choices,1,lightblue,false);  jsgotoxy(12,6);
  jswrite('Please use your arrow keys, and enter to select');
  { Best idea is not to create a typed constant when dealing with strings! }
  { Initialise them like this: }
  Choicelist[1] := 'Hiya from linebar 1, enjoy this demo!';
  Choicelist[2] := 'Hiya 2';
  Choicelist[3] := 'Hiya 3';
  Choicelist[4] := 'Hiya 4';
  Choicelist[5] := 'Hiya 3';
  Choicelist[6] := 'Hiya 4';
  Choicelist[7] := 'Hiya 4';
  Choicelist[8] := 'Quit';
  Quit := False;
  Choice := 1;
  For loop := 1 to choices do drawchoice(loop);
  Repeat
    Select := False;
    Repeat
      Lastchoice := choice;
      Ch := Jsreadkey;
      Case ch of
        #0  : CtrlSeq := Ch+jsreadkey;          { eg #0#71 }
        #22 : CtrlSeq := Ch+jsreadkey;          { eg #22#4 }
        #27 : begin
          CtrlSeq := ch;
          Ch := jsreadkey;
          If ch = #27 then begin quit := true; CtrlSeq := ''; end
          Else CtrlSeq := CtrlSeq+ch+jsreadkey;
        End;
        #13,#32: Select := true;
      End;
      If CtrlSeq <> '' then begin
        For loop := tty to avatar do begin
          If CtrlSeq = Cursormove.Up[loop] then begin dec(choice); CtrlSeq :=
''; end;          If CtrlSeq = Cursormove.Down[loop] then begin inc(choice);
CtrlSeq := ''; end;          If CtrlSeq = Cursormove.Left[loop] then begin
dec(choice); CtrlSeq := ''; end;          If CtrlSeq = Cursormove.Right[loop]
then begin inc(choice); CtrlSeq := ''; end;          If CtrlSeq =
Cursormove.Home[loop] then begin choice := 1; CtrlSeq := ''; end;
          If CtrlSeq = Cursormove.Endkey[loop] then begin choice := choices;
CtrlSeq := ''; end;        End;
        CtrlSeq := '';
      end;
      If Choice > Choices then Choice := 1;
      If Choice < 1 then Choice := Choices;
      If Choice <> LastChoice then begin
        Drawchoice(LastChoice);
        Drawchoice(Choice);
      End;
    Until Select or Quit;
    { Process the choices }
    If not Quit then begin
      Case Choice of
        1: hiya1;
        choices: Quit := True;
      end;
    End;
  Until Quit;
  textattr := lightgray;
  jsclrscr;
  jswriteln('Thank you for looking at this demo!');
End.

