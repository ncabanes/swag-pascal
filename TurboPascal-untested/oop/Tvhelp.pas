(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0020.PAS
  Description: TV-HELP.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

(*
Last week I found a bug in HELPFile.PAS and called Borland.  After describing
the error, the Borland representative agreed that it was a bug and that
it hasn't been reported.  ThereFore, I will describe the bug here and give
a fix to the problem.

Problem:
Recall, HELPFile.PAS is the Turbo Vision Unit that TVDEMO.PAS Uses to
provide on-line help to Turbo Vision Programs.  The problem that occurred
was that if a help panel was brought up that did not contain a cross
reference entry (i.e. hyperText link), and the user pressed [Tab] or
Shift+[Tab] then a run-time error is generated.   notE: the run-time
error is generated if the Program is Compiled With Range Checking on.
if Range checking is off, then unpredicatable results occur.

to see the bug in action, do the following:

Fire up Turbo Pascal 6 and load the TVDEMO.PAS Program (by default it exists
in the TVDEMOS subdirectory).  Make sure Range checking is turned on.
The option is in Options|Compiler.  You will also want to turn debugging
on in both the TVDEMO.PAS and HELPFile.PAS Files.  to do this, you must
edit the source code of both Files and change the {$D-} option to {$D+}
at the beginning of both Files.

Once you have done the above, press Ctrl+F9 to run TVDEMO.  When TVDEMO
comes up, press F1 to bring up the help Window.  Now, press Shift+[Tab]
or [Tab] and a RunTime error 201 will occur.

This bug arises from the fact that the HELPFile.PAS Unit assumes that
there will always be at least one cross reference field on a help panel.
Obviously, this is an invalid assumption.

Luckily, there is an easy solution to the problem.  The following shows
how to change the HELPFile.PAS Program so that this error doesn't occur.
The only Procedure that needs to be changed is THelpViewer.HandleEvent.

*)

Procedure THelpViewer.HandleEvent(Var Event: TEvent);
Var
  KeyPoint, Mouse: TPoint;
  KeyLength: Byte;
  KeyRef: Integer;
  KeyCount: Integer;
{ 1. Add the following Variable declaration }
  n : Integer;

Procedure MakeSelectVisible;
Var
  D: TPoint;
begin
  topic^.GetCrossRef(Selected, KeyPoint, KeyLength, KeyRef);
  D := Delta;
  if KeyPoint.X < D.X then D.X := KeyPoint.X;
  if KeyPoint.X > D.X + Size.X then D.X := KeyPoint.X - Size.X;
  if KeyPoint.Y < D.Y then D.Y := KeyPoint.Y;
  if KeyPoint.Y > D.Y + Size.Y then D.Y := KeyPoint.Y - Size.Y;
  if (D.X <> Delta.X) or (D.Y <> Delta.Y) then Scrollto(D.X, D.Y);
end;

Procedure Switchtotopic(KeyRef: Integer);
begin
  if topic <> nil then Dispose(topic, Done);
  topic := HFile^.Gettopic(KeyRef);
  topic^.SetWidth(Size.X);
  Scrollto(0, 0);
  SetLimit(Limit.X, topic^.NumLines);
  Selected := 1;
  DrawView;
end;

begin
  TScroller.HandleEvent(Event);
  Case Event.What of
    evKeyDown:
      begin
        Case Event.KeyCode of
          kbTab:
            begin
{ 2. Change This...
              Inc(Selected);
              if Selected > topic^.GetNumCrossRefs then Selected := 1;
              MakeSelectVisible;
to this... }
              Inc(Selected);
              n := topic^.GetNumCrossRefs;

              if n > 0 then
              begin
                  if Selected > n then
                      Selected := 1;
                  MakeSelectVisible;
              end
              else
                  selected := 0;
{ end of Change 2 }
            end;
          kbShiftTab:
            begin
{ 3. Change this ...
              Dec(Selected);
              if Selected = 0 then Selected := topic^.GetNumCrossRefs;
              MakeSelectVisible;
to this... }
              Dec(Selected);
              n := topic^.GetNumCrossRefs;
              if n > 0 then
              begin
                  if Selected = 0 then
                      Selected := n;
                  MakeSelectVisible;
              end
              else
                  Selected := 0;
{ end of Change 3 }
            end;
          kbEnter:
            begin
{ 4. Change this...
              if Selected <= topic^.GetNumCrossRefs then
              begin
                topic^.GetCrossRef(Selected, KeyPoint, KeyLength, KeyRef);
                Swithtotopic(KeyRef);
              end;
to this...}
              n := topic^.GetNumCrossRefs;
              if n > 0 then
              begin
                  if Selected <= n then
                  begin
                    topic^.GetCrossRef(Selected, KeyPoint, KeyLength, KeyRef);
                    Switchtotopic(KeyRef);
                  end;
              end;
{ end of Change 4 }
            end;
          kbEsc:
            begin
              Event.What := evCommand;
              Event.Command := cmClose;
              PutEvent(Event);
            end;
        else
          Exit;
        end;
        DrawView;
        ClearEvent(Event);
      end;
    evMouseDown:
      begin
        MakeLocal(Event.Where, Mouse);
        Inc(Mouse.X, Delta.X); Inc(Mouse.Y, Delta.Y);
        KeyCount := 0;
        Repeat
          Inc(KeyCount);
          if KeyCount > topic^.GetNumCrossRefs then Exit;
          topic^.GetCrossRef(KeyCount, KeyPoint, KeyLength, KeyRef);
        Until (KeyPoint.Y = Mouse.Y+1) and (Mouse.X >= KeyPoint.X) and
          (Mouse.X < KeyPoint.X + KeyLength);
        Selected := KeyCount;
        DrawView;
        if Event.Double then Switchtotopic(KeyRef);
        ClearEvent(Event);
      end;
    evCommand:
      if (Event.Command = cmClose) and (Owner^.State and sfModal <> 0) then
      begin
        endModal(cmClose);
        ClearEvent(Event);
      end;
  end;
end;

