unit DropBtns;

{ (C) 1995, ingenieursbureau Office Automation
  All Rights Reserved

  Hereby the right to distribute this work electronically is granted,
  provided such is done for at most a nominal fee. Also the right is
  granted to store this work on a computer system.
  Finally the right is granted to incorporate this work into other
  work provided no fee is asked for this work.
  In all cases of distribution this work must be distributed in full,
  which specifically includes this notice.
  Liability is limited to the amount payed for this work. Legal
  jurisdiction is with the court of Leeuwarden, the Netherlands.
}

interface

uses
  WinTypes, WinProcs, Messages, Classes, Controls, Forms, Graphics,
  StdCtrls, ExtCtrls, Buttons, ShellApi, SysUtils;

type
  TDropButton = class(TBitBtn)
  protected
    procedure CreateParams(var Params : TCreateParams); override;
    procedure WMDropFiles(var Message : TMessage); message WM_DROPFILES;
  end;

procedure Register;

implementation

procedure TDropButton.CreateParams(var Params : TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle := ExStyle or WS_EX_ACCEPTFILES;
  end;
end;

procedure TDropButton.WMDropFiles(var Message : TMessage);
var
  hDrop : THandle;
  nFiles, i, j, size : word;
  Glyphs : integer; {darned privates!}
  Pstr : PChar;
begin
  hDrop := Message.WParam;
  Pstr := StrAlloc(256);
  Pstr[0] := chr(0);
  Message.Result := 0; {accept}
  try
    nFiles := DragQueryFile(hDrop, $FFFF, Pstr, size);
    dec(nFiles);
    for i := nFiles to nFiles do
    begin
      size := DragQueryFile(hDrop, i, nil, size); {don't ask}
      size := DragQueryFile(hDrop, i, Pstr, size+1);
      Glyph.LoadFromFile(StrPas(Pstr));
      if Glyph.Width mod Glyph.Height = 0 then
      begin
        Glyphs := Glyph.Width div Glyph.Height;
        if Glyphs > 4 then Glyphs := 1;
        NumGlyphs := Glyphs;
      end;
    end;
  finally
    DragFinish(hDrop);
    StrDispose(Pstr);
  end;
end;

procedure Register;
begin
  RegisterComponents('IBOA', [TDropButton]);
end;

end.
