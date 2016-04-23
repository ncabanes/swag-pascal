{$A+,F+,I-,R-,S-,V-}

unit IniTV;  {unit for managing INI files using TurboVision/OWL}

{*********************************************}
{*              INITV.PAS  1.04              *}
{*      Copyright (c) Steve Sneed 1993       *}
{*********************************************}

{*
NOTE: This code was quickly adapted from some using Object Professional's
DoubleList object.
*}

{$IFNDEF Ver70}
  !! STOP COMPILE: This unit requires BP7 !!
{$ENDIF}

{if Object Professional is available, use its string routines}
{.$DEFINE UseOPro}

interface

uses
{$IFDEF UseOPro}
  OpString,
{$ENDIF}
  Objects;

const
  EncryptionKey : String[80] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  FBufSize = 4096;

type
  PLine = ^TLine;
  TLine =
    object(TObject)
      PL : PString;

      constructor Init(S : String);
      destructor Done; virtual;
      procedure Update(S : String);
    end;


  PIni = ^TIni;
  TIni =
    object(TCollection)
      IniName   : String;
      FBufr     : PChar;

      constructor Init(ALimit, ADelta : Integer;
                       FN : String;
                       Sparse, Create : Boolean);
        {-Construct our INI file object.  if Sparse=True, load only "active"
          lines (file is considered read-only.)  File always updates on
          changes; use SetFlushMode to control.}
      destructor Done; virtual;
        {-Destroy object when done}
      procedure Reload;
        {-Reload the INI file after it may have changed externally}
      procedure FlushFile;
        {-Force an update of the physical file from the current list}
      procedure SetFlushMode(Always : Boolean);
        {-Turn off/on auto-updating of file when an item is modified}
      procedure SetExitFlushMode(DoIt : Boolean);
        {-Turn off/on updating of file when the object is disposed}
      function GetProfileString(Title, Group, Default : String) : String;
        {-Return string item "Title" in "[Group]", or default if not found}
      function GetEncryptedProfileString(Title, Group, Default : String) : String;
        {-Same as GetProfileString but decrypts the found string}
      function GetProfileBool(Title, Group : String; Default : Boolean) : Boolean;
        {-Return boolean item "Title" in "[Group]", or default if not found}
      function GetProfileByte(Title, Group : String; Default : Byte) : Byte;
        {-Return byte item "Title" in "[Group]", or default if not
          found or Not A Number}
      function GetProfileInt(Title, Group : String; Default : Integer) : Integer;
        {-Return integer item "Title" in "[Group]", or default if not
          found or NAN}
      function GetProfileWord(Title, Group : String; Default : Word) : Word;
        {-Return word item "Title" in "[Group]", or default if not
          found or NAN}
      function GetProfileLong(Title, Group : String; Default : LongInt) : LongInt;
        {-Return longint item "Title" in "[Group]", or default if not
          found or NAN}
      function SetProfileString(Title, Group, NewVal : String) : Boolean;
        {-Change existing item "Title" in "[Group]" to "NewVal"}
      function SetEncryptedProfileString(Title, Group, NewVal : String) : Boolean;
        {-Change existing item "Title" in "[Group]" to "NewVal"}
      function AddProfileString(Title, Group, NewVal : String) : Boolean;
        {-Add new item "Title=NewVal" to "[Group]".  Creates [Group] if not
          found or if "Title" = '', else adds "Title=NewVal" as last item in
          [Group]}
      function AddEncryptedProfileString(Title, Group, NewVal : String) : Boolean;
        {-Same as AddProfileString but encrypts "NewVal" when adding}
      function KillProfileItem(Title, Group : String) : Boolean;
        {-Completely remove the "Title" entry in "[Group]"}
      function KillProfileGroup(Group : String) : Boolean;
        {-Kill the entire group "[Group]", including group header}
      function EnumGroups(P : PStringCollection; Clr : Boolean) : Boolean;
        {-Return P loaded with the names of all groups in the file.  Returns
          false only on error.  On return P is in file order rather than
          sorted order.}
      function EnumGroupItems(P : PStringCollection; Group : String; Clr : Boolean) : Boolean;
        {-Return P loaded with all items in group [Group].  Returns false
          if Group not found or error.  On return P is in file order rather
          than sorted order}

    private  {these used internally only}
      IniF      : Text;
      NeedUpd   : Boolean;
      AlwaysUpd : Boolean;
      IsSparse  : Boolean;
      ExitFlush : Boolean;

      function GetIniNode(Title, Group : String) : PLine;
      function GetLastNodeInGroup(Group : String) : PLine;
      function GetProfilePrim(Title, Group : String) : String;
    end;

procedure SetEncryptionKey(NewKey : String);
  {-define the encryption key}

implementation

  function NewStr(const S: String): PString;
    {-NOTE: The default NewStr returns a nil pointer for empty strings.  This
      will cause problems, so we define a NewStr that always allocates a ptr.}
  var
    P: PString;
  begin
    GetMem(P, Length(S) + 1);
    P^ := S;
    NewStr := P;
  end;

  procedure CleanHexStr(var S : string);
    {-handle ASM- and C-style hex notations}
  var
    SLen : Byte absolute S;
  begin
    while S[SLen] = ' ' do
      Dec(SLen);
    if (SLen > 1) and (Upcase(S[SLen]) = 'H') then begin
      Move(S[1], S[2], SLen-1);
      S[1] := '$';
    end
    else if (SLen > 2) and (S[1] = '0') and (Upcase(S[2]) = 'X') then begin
      Dec(SLen);
      Move(S[3], S[2], SLen-1);
      S[1] := '$';
    end;
  end;

{$IFNDEF UseOPro}
{-If we're not using OPro, define the string manipulation routines we need.}

const
  Digits : Array[0..$F] of Char = '0123456789ABCDEF';

  function HexB(B : Byte) : string;
    {-Return hex string for byte}
  begin
    HexB[0] := #2;
    HexB[1] := Digits[B shr 4];
    HexB[2] := Digits[B and $F];
  end;

  function Trim(S : string) : string;
    {-Return a string with leading and trailing white space removed}
  var
    I : Word;
    SLen : Byte absolute S;
  begin
    while (SLen > 0) and (S[SLen] <= ' ') do
      Dec(SLen);

    I := 1;
    while (I <= SLen) and (S[I] <= ' ') do
      Inc(I);
    Dec(I);
    if I > 0 then
      Delete(S, 1, I);

    Trim := S;
  end;

  function StUpcase(S : String) : String;
    {-Convert a string to all uppercase.  Ignores internationalization issues}
  var
    I : Byte;
  begin
    for I := 1 to Length(S) do
      S[i] := Upcase(S[i]);
    StUpcase := S;
  end;
{$ENDIF}

  function StripBrackets(S : String) : String;
  var
    B : Byte absolute S;
  begin
    S := Trim(S);
    if S[b] = ']' then
      Dec(B);
    if S[1] = '[' then begin
      Move(S[2], S[1], B-1);
      Dec(B);
    end;
    StripBrackets := StUpcase(S);
  end;

  procedure SetEncryptionKey(NewKey : String);
    {-Define the encryption key to use}
  begin
    EncryptionKey := NewKey;
  end;

  function Crypt(S : String) : String;
    {-simple self-reversing xor encryption}
  var
    SI, KI : Byte;
    T : String;
  begin
    T := '';
    KI := 1;
    for SI := 1 to Length(S) do begin
      T := T + Chr(Byte(S[SI]) xor Byte(EncryptionKey[KI]));
      Inc(KI);
      if KI > Length(EncryptionKey) then
        KI := 1;
    end;
    Crypt := T;
  end;

  function Encrypt(S : String) : String;
    {-Convert S to XOR-encrypted string, then "hex-ize"}
  var
    T, U : String;
    I : Integer;
  begin
    U := '';
    T := Crypt(S);
    for I := 1 to Length(T) do
      U := U + HexB(Byte(T[i]));
    Encrypt := U;
  end;

  function Decrypt(S : String) : String;
    {-Convert "hex-ized" string to encrypted raw string, and decrypt}
  var
    T,U : String;
    I,C : Integer;
  begin
    T := '';
    while S <> '' do begin
      U := '$'+Copy(S, 1, 2);
      Delete(S, 1, 2);
      Val(U, I, C);
      T := T + Char(I);
    end;
    Decrypt := Crypt(T);
  end;

{---------------------------------------------------------------------------}

  constructor TLine.Init(S : String);
  begin
    inherited Init;
    PL := NewStr(S);
  end;

  destructor TLine.Done;
  begin
    DisposeStr(PL);
    inherited Done;
  end;

  procedure TLine.Update(S : String);
  begin
    DisposeStr(PL);
    PL := NewStr(S);
  end;

{---------------------------------------------------------------------------}

  constructor TIni.Init(ALimit, ADelta : Integer;
                        FN : String;
                        Sparse, Create : Boolean);
  var
    P : PLine;
    S : String;
  begin
    inherited Init(ALimit, ADelta);
    GetMem(FBufr, FBufSize);

    IsSparse := Sparse;
    NeedUpd := False;
    AlwaysUpd := False;
    ExitFlush := False;

    {load INI file}
    IniName := FN;
    Assign(IniF, IniName);
    SetTextBuf(IniF, FBufr[0], FBufSize);
    Reset(IniF);
    if IOResult <> 0 then begin
      {file doesn't yet exist; drop out}
      if not Create then begin
        Done;
        Fail;
      end
      else begin
        NeedUpd := True;
        Exit;
      end;
    end;

    while not EOF(IniF) do begin
      ReadLn(IniF, S);
      if IOResult <> 0 then begin
        {read error here means something is wrong; bomb it}
        Close(IniF);  if IOresult = 0 then ;
        Done;
        Fail;
      end;

      {add the string to the collection}
      S := Trim(S);
      if (not(Sparse)) or ((S <> '') and (S[1] <> ';')) then begin
        New(P, Init(S));
        if P = nil then begin
          {out of memory, bomb it}
          Close(IniF);
          if IOResult = 0 then ;
          Done;
          Fail;
        end;
        Insert(P);
      end;
    end;
    Close(IniF);
    if IOResult = 0 then ;

    AlwaysUpd := True;
    ExitFlush := True;
  end;

  destructor TIni.Done;
  begin
    if (NeedUpd) and (ExitFlush) then
      FlushFile;
    FreeMem(FBufr, FBufSize);
    inherited Done;
  end;

  procedure TIni.Reload;
  var
    P : PLine;
    S : String;
  begin
    FreeAll;
    Assign(IniF, IniName);
    SetTextBuf(IniF, FBufr[0], FBufSize);
    Reset(IniF);
    if IOResult <> 0 then
      Exit;

    while not EOF(IniF) do begin
      ReadLn(IniF, S);
      if IOResult <> 0 then begin
        {read error here means something is wrong; bomb it}
        Close(IniF);  if IOresult = 0 then ;
        Exit;
      end;

      S := Trim(S);
      if (not(IsSparse)) or ((S <> '') and (S[1] <> ';')) then begin
        New(P, Init(S));
        if P = nil then begin
          {out of memory, bomb it}
          Close(IniF);  if IOResult = 0 then ;
          Exit;
        end;
        Insert(P);
      end;
    end;
    Close(IniF);
    if IOResult = 0 then ;
  end;

  procedure TIni.SetFlushMode(Always : Boolean);
  begin
    AlwaysUpd := Always;
  end;

  procedure TIni.SetExitFlushMode(DoIt : Boolean);
  begin
    ExitFlush := DoIt;
  end;

  procedure TIni.FlushFile;
    {-Force the INI file to be rewritten}
  var
    S : String;
    P : PLine;
    I : Integer;
  begin
    if IsSparse then
      Exit;

    Assign(IniF, IniName);
    SetTextBuf(IniF, FBufr[0], FBufSize);
    Rewrite(IniF);
    if IOResult <> 0 then
      Exit;

    I := 0;
    while I < Count do begin
      P := PLine(At(I));
      WriteLn(IniF, P^.PL^);
      if IOResult <> 0 then begin
        Close(IniF);
        if IOResult = 0 then ;
        exit;
      end;
      Inc(I);
    end;

    Close(IniF);
    if IOResult = 0 then ;
    NeedUpd := False;
  end;

  function TIni.GetIniNode(Title, Group : String) : PLine;
    {-Return the Title node in Group, or nil if not found}
  var
    P : PLine;
    S : String;
    I : Integer;
    GroupSeen : Boolean;
  begin
    GetIniNode := nil;
    if Count = 0 then exit;

    {fixup strings as needed}
    if Group[1] <> '[' then
      Group := '['+Group+']';
    Group := StUpcase(Group);
    Title := StUpcase(Title);

    {search}
    GroupSeen := False;
    I := 0;
    while I < Count do begin
      P := PLine(At(I));
      if P^.PL^[1] = '[' then begin
        {a group header...}
        if StUpcase(P^.PL^) = Group then
          {in our group}
          GroupSeen := True
        else if GroupSeen then
          {exhausted all options in our group; get out}
          exit;
      end
      else if (GroupSeen) and (P^.PL^[1] <> ';') then begin
        {in our group, see if the title matches}
        S := Copy(P^.PL^, 1, Pos('=', P^.PL^)-1);
        S := Trim(S);
        S := StUpcase(S);
        if Title = S then begin
          GetIniNode := P;
          exit;
        end;
      end;
      Inc(I);
    end;
  end;

  function TIni.GetLastNodeInGroup(Group : String) : PLine;
    {-Return the last node in Group, or nil if not found}
  var
    P,Q : PLine;
    S : String;
    I : Integer;
    GroupSeen : Boolean;
  begin
    GetLastNodeInGroup := nil;
    if Count = 0 then exit;

    {fixup strings as needed}
    if Group[1] <> '[' then
      Group := '['+Group+']';
    Group := StUpcase(Group);

    {search}
    GroupSeen := False;
    Q := nil;
    I := 0;
    while I < Count do begin
      P := PLine(At(I));
      if P^.PL^[1] = '[' then begin
        {a group header...}
        if StUpcase(P^.PL^) = Group then
          {in our group}
          GroupSeen := True
        else if (GroupSeen) then begin
          {exhausted all lines in our group, return the last pointer}
          if Q = nil then
            Q := PLine(At(I-1));
          I := IndexOf(Q);
          while (I >= 0) and (PLine(At(I))^.PL^ = '') do
            Dec(I);
          if I < 0 then
            GetLastNodeInGroup := nil
          else
            GetLastNodeInGroup := PLine(At(I));
          exit;
        end;
      end;
      Q := P;
      Inc(I);
    end;
    if GroupSeen then
      GetLastNodeInGroup := Q
    else
      GetLastNodeInGroup := nil;
  end;

  function TIni.GetProfilePrim(Title, Group : String) : String;
    {-Primitive to return the string at Title in Group}
  var
    P : PLine;
    S : String;
    B : Byte absolute S;
  begin
    P := GetIniNode(Title, Group);
    if P = nil then
      GetProfilePrim := ''
    else begin
      S := P^.PL^;
      S := Copy(S, Pos('=', S)+1, 255);
      S := Trim(S);
      if (S[1] = '"') and (S[b] = '"') then begin
        Move(S[2], S[1], B-1);
        Dec(B, 2);
      end;
      GetProfilePrim := S;
    end;
  end;

  function TIni.KillProfileItem(Title, Group : String) : Boolean;
    {-Removes Title item in Group from the list}
  var
    P : PLine;
  begin
    KillProfileItem := False;
    if IsSparse then Exit;

    P := GetIniNode(Title, Group);
    if P <> nil then begin
      Free(P);
      KillProfileItem := True;
      if AlwaysUpd then
        FlushFile
      else
        NeedUpd := True;
    end;
  end;

  function TIni.KillProfileGroup(Group : String) : Boolean;
    {-Removes all items in Group from the list}
  var
    P : PLine;
    I : Integer;
    S : String;
  begin
    KillProfileGroup := False;
    if IsSparse then Exit;

    {fixup string as needed}
    if Group[1] <> '[' then
      Group := '['+Group+']';
    Group := StUpcase(Group);

    {search}
    I := 0;
    while I < Count do begin
      P := PLine(At(I));
      if (P^.PL^[1] = '[') and (StUpcase(P^.PL^) = Group) then begin
        Inc(I);
        while (I < Count) and (PLine(At(I))^.PL^[1] <> '[') do
          Free(At(I));
        Free(P);
        KillProfileGroup := True;
        if AlwaysUpd then
          FlushFile
        else
          NeedUpd := True;
        Exit;
      end;
      Inc(I);
    end;
  end;

  function TIni.GetProfileString(Title, Group, Default : String) : String;
    {-Returns Title item in Group, or Default if not found}
  var
   S : String;
  begin
    S := GetProfilePrim(Title, Group);
    if S = '' then
      S := Default;
    GetProfileString := S;
  end;

  function TIni.GetEncryptedProfileString(Title, Group, Default : String) : String;
    {-Returns decrypted Title item in Group, or Default if not found}
  var
   S : String;
  begin
    S := GetProfilePrim(Title, Group);
    if S = '' then
      S := Default
    else
      S := DeCrypt(S);
    GetEncryptedProfileString := S;
  end;

  function TIni.GetProfileBool(Title, Group : String; Default : Boolean) : Boolean;
  var
    S : String;
  begin
    S := Trim(GetProfilePrim(Title, Group));
    if S <> '' then begin
      S := StUpcase(S);
      if (S = 'TRUE') or (S = '1') or (S = 'Y') or (S = 'YES') or (S = 'ON') then
        GetProfileBool := True
      else if (S = 'FALSE') or (S = '0') or (S = 'N') or (S = 'NO') or (S = 'OFF') then
        GetProfileBool := False
      else
        GetProfileBool := Default;
    end
    else
      GetProfileBool := Default;
  end;

  function TIni.GetProfileByte(Title, Group : String; Default : Byte) : Byte;
  var
    S : String;
    C : Integer;
    B : Byte;
  begin
    S := Trim(GetProfilePrim(Title, Group));
    if S <> '' then begin
      CleanHexStr(S);
      Val(S, B, C);
      if C = 0 then
        GetProfileByte := B
      else
        GetProfileByte := Default;
    end
    else
      GetProfileByte := Default;
  end;

  function TIni.GetProfileInt(Title, Group : String; Default : Integer) : Integer;
  var
    S : String;
    I,C : Integer;
  begin
    S := Trim(GetProfilePrim(Title, Group));
    if S <> '' then begin
      CleanHexStr(S);
      Val(S, I, C);
      if C = 0 then
        GetProfileInt := I
      else
        GetProfileInt := Default;
    end
    else
      GetProfileInt := Default;
  end;

  function TIni.GetProfileWord(Title, Group : String; Default : Word) : Word;
  var
    S : String;
    W : Word;
    C : Integer;
  begin
    S := Trim(GetProfilePrim(Title, Group));
    if S <> '' then begin
      CleanHexStr(S);
      Val(S, W, C);
      if C = 0 then
        GetProfileWord := W
      else
        GetProfileWord := Default;
    end
    else
      GetProfileWord := Default;
  end;

  function TIni.GetProfileLong(Title, Group : String; Default : LongInt) : LongInt;
  var
    S : String;
    I : LongInt;
    C : Integer;
  begin
    S := Trim(GetProfilePrim(Title, Group));
    if S <> '' then begin
      CleanHexStr(S);
      Val(S, I, C);
      if C = 0 then
        GetProfileLong := I
      else
        GetProfileLong := Default;
    end
    else
      GetProfileLong := Default;
  end;

  function TIni.SetProfileString(Title, Group, NewVal : String) : Boolean;
  var
    S : String;
    P : PLine;
  begin
    SetProfileString := False;
    if IsSparse then exit;

    P := GetIniNode(Title, Group);
    if P = nil then
      SetProfileString := AddProfileString(Title, Group, NewVal)
    else begin
      S := P^.PL^;
      System.Delete(S, Pos('=', S)+1, 255);
      S := S + NewVal;
      P^.Update(S);
      SetProfileString := True;
      if AlwaysUpd then
        FlushFile
      else
        NeedUpd := True;
    end;
  end;

  function TIni.SetEncryptedProfileString(Title, Group, NewVal : String) : Boolean;
  var
    S : String;
    P : PLine;
  begin
    SetEncryptedProfileString := False;
    if IsSparse then exit;

    P := GetIniNode(Title, Group);
    if P = nil then
      SetEncryptedProfileString := AddEncryptedProfileString(Title, Group, NewVal)
    else begin
      S := P^.PL^;
      System.Delete(S, Pos('=', S)+1, 255);
      S := S + EnCrypt(NewVal);
      P^.Update(S);
      SetEncryptedProfileString := True;
      if AlwaysUpd then
        FlushFile
      else
        NeedUpd := True;
    end;
  end;

  function TIni.AddProfileString(Title, Group, NewVal : String) : Boolean;
    {-add new node and/or group to the list}
  var
    P : PLine;
    I : Integer;
  begin
    AddProfileString := False;
    if IsSparse then exit;

    {fixup strings as needed}
    if Group[1] <> '[' then
      Group := '['+Group+']';

    P := GetLastNodeInGroup(Group);
    if P = nil then begin
      {group not found, create a new one}
      {add a blank line for spacing}
      New(P, Init(''));
      if P = nil then Exit;
      Insert(P);
      New(P, Init(Group));
      if P = nil then Exit;
      Insert(P);
      I := Count;
    end
    else
      I := IndexOf(P)+1;

    {add our new element after}
    if Title = '' then
      AddProfileString := True
    else begin
      New(P, Init(Title+'='+NewVal));
      if P <> nil then begin
        AtInsert(I, P);
        AddProfileString := True;
        if AlwaysUpd then
          FlushFile
        else
          NeedUpd := True;
      end;
    end;
  end;

  function TIni.AddEncryptedProfileString(Title, Group, NewVal : String) : Boolean;
    {-add new encrypted node and/or group to the list}
  var
    P,Q : PLine;
    I : Integer;
  begin
    AddEncryptedProfileString := False;
    if IsSparse then exit;

    {fixup strings as needed}
    if Group[1] <> '[' then
      Group := '['+Group+']';

    P := GetLastNodeInGroup(Group);
    if P = nil then begin
      {group not found, create a new one}
      {add a blank line for spacing}
      New(P, Init(''));
      if P = nil then Exit;
      Insert(P);
      New(P, Init(Group));
      if P = nil then Exit;
      Insert(P);
      I := Count;
    end
    else
      I := IndexOf(P)+1;

    {add our new element after}
    if Title = '' then
      AddEncryptedProfileString := True
    else begin
      New(P, Init(Title+'='+Encrypt(NewVal)));
      if P <> nil then begin
        AtInsert(I, P);
        AddEncryptedProfileString := True;
        if AlwaysUpd then
          FlushFile
        else
          NeedUpd := True;
      end;
    end;
  end;

  function TIni.EnumGroups(P : PStringCollection; Clr : Boolean) : Boolean;
    {-Return P loaded with the names of all groups in the file.  Returns
      false only on error.  Uses AtInsert rather than Insert so collection
      items are in file order rather than sorted order.}
  var
    Q : PLine;
    R : PString;
    I : Integer;
  begin
    EnumGroups := False;
    if Clr then
      P^.FreeAll;

    I := 0;
    while I < Count do begin
      Q := PLine(At(I));
      if Q^.PL^[1] = '[' then begin
        R := NewStr(StripBrackets(Q^.PL^));
        P^.AtInsert(P^.Count, R);
      end;
      Inc(I);
    end;
    EnumGroups := True;
  end;

  function TIni.EnumGroupItems(P : PStringCollection; Group : String; Clr : Boolean) : Boolean;
    {-Return P loaded with all items in group [Group].  Returns false
      if Group not found or error.  Uses AtInsert rather than Insert so
      collection items are in file order rather than sorted order.}
  var
    Q : PLine;
    R : PString;
    S : String;
    I : Integer;
  begin
    EnumGroupItems := False;
    if Clr then
      P^.FreeAll;

    {fixup strings as needed}
    if Group[1] <> '[' then
      Group := '['+Group+']';
    Group := StUpcase(Group);

    I := 0;
    while I < Count do begin
      Q := PLine(At(I));
      if StUpcase(Q^.PL^) = Group then begin
        Inc(I);
        while (I < Count) and (PLine(At(I))^.PL^[1] <> '[') do begin
          S := Trim(PLine(At(I))^.PL^);
          if (S <> '') and (S[1] <> ';') then begin
            if Pos('=', S) > 0 then
              S[0] := Char(Pos('=', S)-1);
            S := Trim(S);
            R := NewStr(S);
            P^.AtInsert(P^.Count, R);
          end;
          Inc(I);
        end;
        EnumGroupItems := True;
        Exit;
      end;
      Inc(I);
    end;
  end;

end.
