(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0429.PAS
  Description: Store Fontstyle in INI
  Author: JXIDUS
  Date: 01-02-98  07:34
*)


From: jxidus@aol.com (JXidus)

My solution: (to store the entire font, actually)


--------------------------------------------------------------------------------

function FontToStr(font: TFont): string;
procedure yes(var str:string);
begin
     str := str + 'y';
end;
procedure no(var str:string);
begin
     str := str + 'n';
end;
begin
     {encode all attributes of a TFont into a string}
     Result := '';
     Result := Result + IntToStr(font.Color) + '|';
     Result := Result + IntToStr(font.Height) + '|';
     Result := Result + font.Name + '|';
     Result := Result + IntToStr(Ord(font.Pitch)) + '|';
     Result := Result + IntToStr(font.PixelsPerInch) + '|';
     Result := Result + IntToStr(font.size) + '|';
     if fsBold in font.style then yes(Result) else no(Result);
     if fsItalic in font.style then yes(Result) else no(Result);
     if fsUnderline in font.style then yes(Result) else no(Result);
     if fsStrikeout in font.style then yes(Result) else no(Result);
end;

procedure StrToFont(str: string; font: TFont);
begin
     if str = '' then Exit;
     font.Color := StrToInt(tok('|', str));
     font.Height := StrToInt(tok('|', str));
     font.Name := tok('|', str);
     font.Pitch := TFontPitch(StrToInt(tok('|', str)));
     font.PixelsPerInch := StrToInt(tok('|', str));
     font.Size := StrToInt(tok('|', str));
     font.Style := [];
     if str[0] = 'y' then font.Style := font.Style + [fsBold];
     if str[1] = 'y' then font.Style := font.Style + [fsItalic];
     if str[2] = 'y' then font.Style := font.Style + [fsUnderline];
     if str[3] = 'y' then font.Style := font.Style + [fsStrikeout];
end;

function tok(sep: string; var s: string): string;
     function isoneof(c, s: string): Boolean;
     var
        iTmp: integer;
     begin
          Result := False;
          for iTmp := 1 to Length(s) do
          begin
              if c = Copy(s, iTmp, 1) then
              begin
                   Result := True;
                   Exit;
              end;
          end;
     end;
var
   c, t: string;
begin
     if s = '' then
     begin
          Result := s;
          Exit;
     end;
     c := Copy(s, 1, 1);
     while isoneof(c, sep) do
     begin
          s := Copy(s, 2, Length(s) - 1);
          c := Copy(s, 1, 1);
     end;
     t := '';
     while (not isoneof(c, sep)) and (s <> '') do
     begin
          t := t + c;
          s := Copy(s, 2, length(s)-1);
          c := Copy(s, 1, 1);
     end;
     Result := t;
end;

--------------------------------------------------------------------------------

Note that you can keep stuff like this really handy by creating your own
subclass of the TIniFile class, and adding routines like this.

