(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0048.PAS
  Description: Re: Clipboard and Streams
  Author: MARK JOHNSON
  Date: 11-24-95  10:15
*)


In article <684156579wnr@spudsoft.demon.co.uk>,
   "D:DEMONSPOOLMAIL" <jt@spudsoft.demon.co.uk> wrote:
>I want to use the clipboard to store data in a proprietry format but I 
>would like to just write a single set of routines to input and output 
>from streams.
>
>Is it possible to set up a TMemoryStream object, fill it with the data 
>and then give it to the clipboard?
>If so, how?

Not only is it possible, but this is exactly how Borland implemented
the Clipboard.GetComponent and Clipboard.SetComponent functions.
Basically, you would need to register your own clipboard format
with a call to RegisterClipboardFormat():

CF_MYFORMAT := RegisterClipboardFormat('My Format Description');

You would then follow these steps:
1. Create a memory stream & write your data to it.
2. Create a global memory buffer and copy the stream into it.
3. Call Clipboard.SetAsHandle() to place it on the clipboard.

Example:

var
  hbuf    : THandle;
  bufptr  : Pointer;
  mstream : TMemoryStream;
begin
  mstream := TMemoryStream.Create;
  try
    {-- Write your data to the stream. --}
    hbuf := GlobalAlloc(GMEM_MOVEABLE, mstream.size);
    try
      bufptr := GlobalLock(hbuf);
      try
        Move(mstream.Memory^, bufptr^, mstream.size);
        Clipboard.SetAsHandle(CF_MYFORMAT, hbuf);
      finally
        GlobalUnlock(hbuf);
      end;
    except
      GlobalFree(hbuf);
      raise;
    end;
  finally
    mstream.Free;
  end;
end;

IMPORTANT: Do not delete the buffer you GlobalAlloc().  Once you
put it on the clipboard, it's up to the clipboard to dispose of
it.  When retrieving it, again, do not delete the buffer you
retrieve -- just make a copy of the contents.

To retrieve the stream and its data, do something like this:

var
  hbuf    : THandle;
  bufptr  : Pointer;
  mstream : TMemoryStream;
begin
  hbuf := Clipboard.GetAsHandle(CF_MYFORMAT);
  if hbuf <> 0 then begin
    bufptr := GlobalLock(hbuf);
    if bufptr <> nil then begin
      try
        mstream := TMemoryStream.Create;
        try
          mstream.WriteBuffer(bufptr^, GlobalSize(hbuf));
          mstream.Position := 0;
          {-- Read your data from the stream. --}
        finally
          mstream.Free;
        end;
      finally
        GlobalUnlock(hbuf);
      end;
    end;
  end;
end;


