{
>Format is really a good function for use on output and it corresponds roughly
>to the printf function in C, but I really need the corresponding input
>function as well (scanf etc)
>
>does anyone know of such a function? I would hate to spend the time
>reinventing the wheel, when I could be concentrating on other things.

Here's my implementation of scanf:

--------------------------------------------------------------------------}

function sscanf(Input, Format : PChar; var ArgList) : PChar;
type
  WordPtr = ^word;
  LongPtr = ^longint;
  PCharPtr = ^PChar;
var
  DelimPos : PChar;
  ArgPtr : PChar;
  n : longint;
  FmtCmd : char;
  code : integer;
  LongCmd : boolean;
  LenStr : string[8];
  MaxLen : integer;
begin
  sscanf := nil;
  ArgPtr := addr(ArgList);
  if (Format = nil) then Exit;
  while (Format^ <> #0) do begin
    if (Input = nil) or (Input^ = #0) then Exit; { ***ERROR }
    if Format^ = '%' then begin
      inc(Format);
      FmtCmd := Format^;

      if FmtCmd in ['0'..'9'] then begin
        LenStr := '';
        repeat
          LenStr := LenStr + FmtCmd;
          inc(Format);
          FmtCmd := Format^;
        until not (FmtCmd in ['0'..'9']);
        if LenStr <> '' then begin
          Val(LenStr, MaxLen, code);
          if code <> 0 then Exit;
        end;
      end else
        MaxLen := $7FFF;

      if FmtCmd = 'l' then begin
        LongCmd := true;
        inc(Format);
        FmtCmd := Format^;
      end else
        LongCmd := false;

      case FmtCmd of
        'c' : begin
          ArgPtr^ := Input^;
          inc(ArgPtr, 2);
        end;
        'd','i','u','s','*' : begin
          { look for delimiter }
          DelimPos := StrScan(Input, (Format+1)^);
          if DelimPos <> nil then begin
            if (DelimPos-Input > MaxLen) then Exit;
            DelimPos^ := #0; { zero delimiter }
          end;

          if FmtCmd = 's' then begin
            if PCharPtr(ArgPtr)^ = nil then { if dest. string is NIL }
              PCharPtr(ArgPtr)^ := StrNew(Input) { then allocate a new one }
            else
              StrCopy(PCharPtr(ArgPtr)^, Input); { else copy to dest buffer }
          end else
            if FmtCmd <> '*' then
              Val(Input, n, code);

          if DelimPos <> nil then DelimPos^ := (Format+1)^; { set it back }
          case FmtCmd of
            's' : inc(ArgPtr, 4);
            '*' : ; { dummy }
          else
            if code <> 0 then Exit; { could not convert }
            if LongCmd then begin
              LongPtr(ArgPtr)^ := n;
              inc(ArgPtr, 4);
            end else begin
              WordPtr(ArgPtr)^ := LongRec(n).Lo;
              inc(ArgPtr, 2);
            end;
          end;
          Input := DelimPos; { move input pointer to delimiter }
        end;
      else
        Exit;
      end;
      inc(Format);
    end else begin
      if Input^ <> Format^ then Exit;
      inc(Format);
      inc(Input);
    end;
  end;
  sscanf := Input;
end;
