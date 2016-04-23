{> How can I copy strings to the clipboard with TPW program?.

This procedure is triggered by a menu or button message:
}


PROCEDURE MyWindow.CopyToClipboard(VAR msg : tmessage);

VAR TextToCopy : array[0..255] of char;

BEGIN

MyEdit.GetText(TextToCopy,SizeOf(Tex tToCopy));

IF NOT CopyText(TextToCopy) then
   messagebox(hWindow,'Hasn't worked!','Copy to Clipboard',mb_ok);

END;


This function does the copy.


FUNCTION MyWindow.CopyText(TextString : Pchar) : Boolean;

VAR StringGlobalHandle : THandle;

    StringGlobalPtr    : PChar;

BEGIN

CopyText := False;
StringGlobalHandle := GlobalAlloc(gmem_Moveable,StrLen(TextString)+1);
IF StringGlobalHandle <> 0 then
   BEGIN
   StringGlobalPtr := GlobalLock(StringGlobalHandle);
   IF StringGlobalPtr <> nil then
      BEGIN
      StrCopy(StringGlobalPtr,TextString);
      GlobalUnlock(StringGlobalHandle);
      IF OpenClipboard(hWindow) then
         BEGIN
         EmptyClipboard;
         SetClipboardData(cf_Text,StringGlobalHandle);
         CloseClipboard;
         CopyText := True;
         END
      ELSE GlobalFree(StringGlobalHandle);
      END
   ELSE GlobalFree(StringGlobalHandle);
   END;
END;
It's partly taken from the German 1.5 manual. But Borland's program

didn't work, it had bugs (which I have corrected in the program above,

of course).



   Basti



E-Mail: 101674.2227@compuserve.com



--

------------------------------------------------------------------

  Bastisoft    101674.2227@compuserve.com



  Fleestedt, Germany

------------------------------------------------------------------





