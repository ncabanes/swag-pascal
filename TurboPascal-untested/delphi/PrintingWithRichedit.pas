(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0346.PAS
  Description: Printing with Richedit
  Author: JAMES BACUS
  Date: 01-02-98  07:33
*)


James V. Bacus <bacuslab@mcs.net>

I have written a program that collects information that a user selects, by
a number of checkboxes and buttons, to a non visible RichEdit box.  The
program was written under Windows 95 and works fine.  But under NT 4.0 the
line ...

RichEdit1.Print(''); 

returns a Divide by Zero Error.  The only way I have found round this is to
save the file and use Word to print the final file.

Does anyone have or know of any workrounds?

Yes, I have a solution and a fix...
To fix this problem requires a minor change to the VCL unit ComCtrls.pas.

I've tested this on many different systems running NT 4.0 and Win95, and all seems to work well now. It's actually a very simple fix, and here it is...



--------------------------------------------------------------------------------

{
A compatibility problem exists with the original RichEdit.Print method
code and the release of NT 4.0.  A EDivByZero exception is caused because
accessing the Printer.Handle property outside of a BeginDoc/EndDoc block
returns an Information Context (IC) handle under NT 4.0 instead of a
Device Context (DC) handle.  The EM_FORMATRANGE attempts to use this IC
instead of a real printer DC, which causes the exception.  If the Handle
property is accessed AFTER the BeginDoc, a true Device Context handle is
returned, and I have modified the code to handle this correctly.  I have
left the original position of BeginDoc in the code but remarked it out to
indicate the difference.    J.V.Bacus 11/12/96
}
procedure TCustomRichEdit.Print(const Caption: string);
var
  Range: TFormatRange;
  LastChar, MaxLen, LogX, LogY: Integer;
begin
  FillChar(Range, SizeOf(TFormatRange), 0);
  with Printer, Range do
  begin
    LogX := GetDeviceCaps(Handle, LOGPIXELSX);
    LogY := GetDeviceCaps(Handle, LOGPIXELSY);
    // The repositioned BeginDoc to now be compatible with
    // both NT 4.0 and Win95
    BeginDoc;
    hdc := Handle;
    hdcTarget := hdc;
    if IsRectEmpty(PageRect) then
    begin
      rc.right := PageWidth * 1440 div LogX;
      rc.bottom := PageHeight * 1440 div LogY;
    end
    else begin
      rc.left := PageRect.Left * 1440 div LogX;
      rc.top := PageRect.Top * 1440 div LogY;
      rc.right := PageRect.Right * 1440 div LogX;
      rc.bottom := PageRect.Bottom * 1440 div LogY;
    end;
    rcPage := rc;
    Title := Caption;
    // The original position of BeginDoc
    { BeginDoc; }
    LastChar := 0;
    MaxLen := GetTextLen;
    chrg.cpMax := -1;
    repeat
      chrg.cpMin := LastChar;
      LastChar := SendMessage(Self.Handle, EM_FORMATRANGE, 1, Longint(@Range));
      if (LastChar < MaxLen) and (LastChar <> -1) then NewPage;
    until (LastChar >= MaxLen) or (LastChar = -1);
    EndDoc;
  end;
  SendMessage(Handle, EM_FORMATRANGE, 0, 0);
end;

