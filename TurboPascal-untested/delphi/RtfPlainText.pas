(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0233.PAS
  Description: Re: RTF -> plain text
  Author: PAUL SOBOLIK
  Date: 03-04-97  13:18
*)

{
> I use a RichEdit in one of my apps with plaintext set to false, since
> I do some color coding. Now, when I copy RTF text from e.g. Word and
> paste it into my app, the size and font is also pasted, but I just
> want the text without RTF information.
<snip>
> What would be the proper way to paste just the plaintext of RTF text
> in the clipboard into the RichEdit?

Proper? I don't know about its propriety, but the following routine
works.

Please note that this doesn't override the rich edit control's
standard paste function, so sending it a WM_PASTE message, (by
pressing Ctrl-V, perhaps) will still paste formatted text.
}

procedure PasteTextOnly(dest: TRichEdit);
var
  MyHandle: THandle;
  TextPtr: PChar;
begin
  ClipBoard.Open;
  Try
    MyHandle := Clipboard.GetAsHandle(CF_TEXT);
    TextPtr := GlobalLock(MyHandle);
    try
      dest.SetSelTextBuf(TextPtr);
    finally
      GlobalUnlock(MyHandle);
    end;
  finally
    Clipboard.Close;
  end;
end;

