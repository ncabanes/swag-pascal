(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0029.PAS
  Description: TMemo Text Lines
  Author: MARK JOHNSON
  Date: 11-22-95  15:49
*)


The correct usage of TMemo.Lines.GetText() (or any other TString's GetText()
method) is as follows:

  var
    lpVar : PChar;
  begin
    lpVar := Memo.Lines.GetText;
    try
      {do whatever you like with/to lpVar's contents}
    finally
      StrDispose(lpVar);
    end;
  end;

The GetText method creates a copy of the text in Memo.Lines (or other
TStrings object) via the StrAlloc() function.  It is entirely up to
you, the programmer, to dispose of the PChar when you are done via
the StrDispose() function.  Since GetText returns a copy of the
text, you can muck about with its contents as you please without
modifying the text in the TMemo.


