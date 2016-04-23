
{
  Strings2 : routine di gestione stringhe tipo 'C' (PChar),
             gestione messaggi,
             help,
             common dialog,
             profiling,
             file .INI

  Versione 2.0A
}
unit Strings2;

{$V-}
{$IFDEF Final}
{$D-,I-,L-,R-,S-}
{$ELSE}
{$D+,I+,L+,R+,S+}
{$ENDIF}

interface

uses
  WinDos,
  Strings,
  OWindows;

{--------------------------------------------------------- Scansione stringhe }

function StrRTrimm(Str : PChar) : PChar;
  {- Elimina gli spazi alla fine della stringa Str.}

function StrLTrimm(Str : PChar) : PChar;
  {- Elimina gli spazi all'inizio della stringa Str.}

function StrToken(var Str : PChar; Delim : char) : PChar;
  {- Restituisce la parte di Str fino al primo carattere Delim. Modifica Str
     in modo che punti al primo carattere dopo Delim. Elimina gli spazi.}

function StrPasNil(P : PChar) : string;

{------------------------------------------------- Conversione numero/stringa }

function StrToInt(Str : PChar) : longint;
  {- Restituisce il valore intero rappresentato dalla stringa decimale Str.}

function StrToIntDef(Str : PChar; DefV : longint) : longint;
  {- Restituisce il valore intero rappresentato dalla stringa decimale Str.
     Se Str Φ nil o Φ vuota o non Φ corretta viene restituito DefV.}

function StrToReal(Str : PChar) : real;
  {- Restituisce il valore reale rappresentato dalla stringa decimale Str.}

function RealToStr(V : real; NDigits : integer; Dest : PChar) : PChar;
  {- In Dest la reappresentazione decimale di V con NDigits cifre dopo
     la virgola. Cifre '0' non significative vengono eliminate.}

function IntToStr(V : longint; Dest : PChar) : PChar;
  {- In Dest la rappresentazione decimale di V. Restituisce Dest.}

{--------------------------------------------------------- Gestione nomi file }

function GetFileName(FilePath : PChar) : PChar;
  {- Restituisce il nome del file FilePath.}

function GetExtension(FilePath : PChar) : PChar;
  {- Restituisce l'estensione (compreso il punto) del file FilePath.}

function HasWildCards(FilePath : PChar) : boolean;
  {- True se FilePath contiene wildcard: '*' o '?'.}

function HasPath(FilePath : PChar): boolean;
  {- True se FilePath contiene il nome di una directory e/o di un drive.}

function PutExtension(FilePath,NewExt : PChar) : PChar;
  {- Sostituisce l'estensione di FilePath con NewExt. FilePath deve
     avere il posto per mettere l'estensione. Se NewExt=nil l'estensione
     di FilePath viene eliminata.}

{--------------------------------------------------- Gestione file di profile }

function GetPrivateProfileFlag(Sec,Key : PChar; Default : boolean; FileName : PChar) : boolean;

function GetPrivateProfileLong(Sec,Key : PChar; Default : longint; FileName : PChar) : longint;

function GetPrivateProfileReal(Sec,Key : PChar; Default : real; FileName : PChar) : real;

function GetPrivateProfileText(Sec,Key : PChar;
                               Default,Dest : PChar; DestSize : integer;
                               FileName : PChar) : integer;

procedure WritePrivateProfileFlag(Sec,Key : PChar; V : boolean; FileName : PChar);

procedure WritePrivateProfileInt(Sec,Key : PChar; V : longint; FileName : PChar);

procedure WritePrivateProfileReal(Sec,Key : PChar; V : real; NDigits : integer; FileName : PChar);

procedure WritePrivateProfileText(Sec,Key : PChar; V : PChar; FileName : PChar);

{-------------------------------------------------------------- Gestione help }

procedure SetHelpFileName(FN : PChar);
  {- Setta il nome del file contenente l'help per il programma.}

function ExecHelp(Command : word; Data : longint) : boolean;
  {- Richiama l'help con comando Command e parametro Data.}

procedure CloseHelp;
  {- Chiude l'help associato al programma.}

{------------------------------------------------------------------ Profiling }

procedure StartProfile;
  {- Inizia il conteggio del tempo trascorso.}

procedure EndProfile;
  {- Visualizza il tempo trascorso dall'ultima StartProfile.}

{------------------------------------- Caricamento e visualizzazione messaggi }

const
  MParent = 65535;     {Valore di TitleH per avere come titolo la caption
                        di AParent.}

function MsgPtr(MsgH : word) : PChar;
  {- Restituisce il messaggio di codice MsgH. Il messaggio non pu≥ essere lungo pi∙
     di 80 caratteri.}

function MessageBoxH(AParent : PWindowsObject; MsgH,TitleH : word; BoxType : word) : integer;
  {- Visualizza un message box con caption di codice TitleH e messaggio di codice MsgH.
     BoxType Φ il tipo del message box da creare. Viene restituito il codice restituito dal
     message box.}

procedure ErrorMsg(AParent : PWindowsObject; MsgH,TitleH : word);
  {- Visualizza il messaggio di codice MsgH in un message box con caption di codice
     TitleH.}

procedure ParErrorMsg(AParent : PWindowsObject; MsgH,TitleH : word; ParS : PChar);
  {- Visualizza il messaggio di codice MsgH con parametro ParS ('%s' nella
     messaggio di errore) in un message box con caption di codice TitleH.}

procedure ParParErrorMsg(AParent : PWindowsObject; MsgH,TitleH : word; ParS1,ParS2 : PChar);
  {- Visualizza il messaggio di codice MsgH con parametri ParS1 e ParS2 ('%s' nella
     messaggio di errore) in un message box con caption di codice TitleH.}

procedure ErrorMsgStr(AParent : PWindowsObject; Msg : PChar; TitleH : word);
  {- Visualizza il messaggio Msg in un message box.}

procedure Panic(N : integer);
  {- Errore fatale non previsto: visualizza 'This can't happen' e interrompe
     l'esecuzione del programma.}

procedure Warning(N : integer);
  {- Errore non fatale non previsto: visualizza 'Warning' e prosegue.}

{------------------------------------------- Richiamo common dialog }

function GetOpenFName(AParent : PWindowsObject;
                      FName : PChar;
                      MCaption,MDesc : word;
                      MustExist : boolean) : boolean;

function GetSaveFName(AParent : PWindowsObject;
                      FName : PChar;
                      MCaption,MDesc : word) : boolean;

implementation {==============================================================}

uses
  WinTypes,
  WinProcs,
  CommDlg,
  Arit;

{--------------------------------------------------------- Scansione stringhe }

function StrRTrimm(Str : PChar) : PChar;
var
  EndS : PChar;
begin
  if Str = nil then StrRTrimm := nil
  else begin
    EndS := StrEnd(Str)-1;
    while (EndS >= Str) and (EndS^ = ' ') do dec(EndS);
    inc(EndS);
    EndS^ := #0;
    StrRTrimm := Str;
  end;
end; { StrRTrimm }

function StrLTrimm(Str : PChar) : PChar;
begin
  if Str = nil then StrLTrimm := nil
  else begin
    while (Str^ = ' ') do inc(Str);
    StrLTrimm := Str;
  end;
end; { StrLTrimm }

function StrToken(var Str : PChar; Delim : char) : PChar;
var
  DelimS : PChar;
begin
  if Str = nil then StrToken := nil
  else begin
    DelimS := StrScan(Str,Delim);
    if DelimS = nil then DelimS := StrEnd(Str)-1
    else DelimS^ := #0;
    StrToken := StrRTrimm(StrLTrimm(Str));
    Str := DelimS+1;
  end;
end; { StrToken }

function StrPasNil(P : PChar) : string;
begin
  if (P <> nil) then StrPasNil := StrPas(P)
  else StrPasNil := '';
end;  { StrPasNil }

{------------------------------------------------- Conversione numero/stringa }

function StrToInt(Str : PChar) : longint;
begin
  StrToInt := StrToIntDef(Str,-32768)
end; { StrToInt }

function StrToIntDef(Str : PChar; DefV : longint) : longint;
var
  V : longint;
  Code : integer;
begin
  if Str = nil then StrToIntDef := DefV
  else begin
    val(Str,V,Code);
    if Code <> 0 then V := DefV;
    StrToIntDef := V;
  end;
end; { StrToIntDef }

function StrToReal(Str : PChar) : real;
var
  V : real;
  Code : integer;
begin
  val(Str,V,Code);
  if Code <> 0 then V := -32768;
  StrToReal := V;
end; { StrToReal }

function RealToStr(V : real; NDigits : integer; Dest : PChar) : PChar;
var
  Buffer : array[0..20] of char;
  P : PChar;
begin
  Str(V:1:NDigits,Buffer);
  P := Buffer+StrLen(Buffer);
  while PChar(P-1)^ = '0' do dec(P);
  if PChar(P-1)^ = '.' then dec(P);
  P^ := #0;
  StrCopy(Dest,Buffer);
  RealToStr := Dest;
end; { RealToStr }

function IntToStr(V : longint; Dest : PChar) : PChar;
var
  Buffer : array[0..12] of char;
begin
  Str(V,Buffer);
  StrCopy(Dest,Buffer);
  IntToStr := Dest;
end; { IntToStr }

{--------------------------------------------------------- Gestione nomi file }

function GetFileName(FilePath : PChar) : PChar;
var
  P: PChar;
begin
  P := StrRScan(FilePath,'\');
  if P = nil then P := StrRScan(FilePath,':');
  if P = nil then GetFileName := FilePath else GetFileName := P + 1;
end; { GetFileName }

function GetExtension(FilePath : PChar) : PChar;
var
  P: PChar;
begin
  P := StrScan(GetFileName(FilePath),'.');
  if P = nil then GetExtension := StrEnd(FilePath)
  else GetExtension := P;
end; { GetExtension }

function HasWildCards(FilePath : PChar) : boolean;
begin
  HasWildCards := (StrScan(FilePath,'*') <> nil) or
                  (StrScan(FilePath,'?') <> nil);
end; { HasWildCards }

function HasPath(FilePath : PChar): boolean;
begin
  HasPath := (StrRScan(FilePath,'\') <> nil) or
             (StrRScan(FilePath,':') <> nil);
end;  { HasPath }

function PutExtension(FilePath,NewExt : PChar) : PChar;
var
  P : PChar;
begin
  P := GetExtension(FilePath);
  if (NewExt = nil) or
     (StrLen(NewExt) = 0) or
     (StrLen(NewExt) = 1) and (NewExt[0] = '.') then P^ := #0
  else begin
    if NewExt[0] <> '.' then begin
      P^ := '.';
      inc(P);
    end;
    StrLCopy(P,NewExt,4);
  end;
  PutExtension := FilePath;
end; { PutExtension }

{--------------------------------------------------- Gestione file di profile }

function GetPrivateProfileFlag(Sec,Key : PChar; Default : boolean; FileName : PChar) : boolean;
var
  Buffer : array[0..6] of char;
begin
  GetPrivateProfileString(Sec,Key,'',Buffer,SizeOf(Buffer),FileName);
  if StrLen(Buffer) = 0 then GetPrivateProfileFlag := Default
  else begin
    StrLower(Buffer);
    if (StrComp(Buffer,'0') = 0) or
       (StrComp(Buffer,'false') = 0) or
       (StrComp(Buffer,'off') = 0) then GetPrivateProfileFlag := false
    else if (StrComp(Buffer,'1') = 0) or
       (StrComp(Buffer,'true') = 0) or
       (StrComp(Buffer,'on') = 0) then GetPrivateProfileFlag := true
    else GetPrivateProfileFlag := Default;
  end;
end; { GetPrivateProfileFlag }

function GetPrivateProfileLong(Sec,Key : PChar; Default : longint; FileName : PChar) : longint;
var
  Buffer : array[0..20] of char;
  Code : integer;
  V : longint;
begin
  GetPrivateProfileString(Sec,Key,'',Buffer,SizeOf(Buffer),FileName);
  if StrLen(Buffer) = 0 then GetPrivateProfileLong := Default
  else begin
    Val(Buffer,V,Code);
    if Code <> 0 then GetPrivateProfileLong := Default
    else GetPrivateProfileLong := V;
  end;
end; { GetPrivateProfileLong }

function GetPrivateProfileReal(Sec,Key : PChar; Default : real; FileName : PChar) : real;
var
  Buffer : array[0..20] of char;
  Code : integer;
  V : real;
begin
  GetPrivateProfileString(Sec,Key,'',Buffer,SizeOf(Buffer),FileName);
  if StrLen(Buffer) = 0 then GetPrivateProfileReal := Default
  else begin
    Val(Buffer,V,Code);
    if Code <> 0 then GetPrivateProfileReal := Default
    else GetPrivateProfileReal := V;
  end;
end; { GetPrivateProfileReal }

function GetPrivateProfileText(Sec,Key : PChar;
                               Default,Dest : PChar; DestSize : integer;
                               FileName : PChar) : integer;
var
  BufPtr,Source : PChar;
  BufSize : integer;
  NumBuf : array[0..3] of char;
begin
  BufSize := DestSize*4;
  GetMem(BufPtr,BufSize);
  GetPrivateProfileString(Sec,Key,'',BufPtr,BufSize,FileName);
  if StrLen(BufPtr) = 0 then StrLCopy(Dest,Default,DestSize-1)
  else begin
    Source := BufPtr;
    while Source^ <> #0 do begin
      if Source^ <> '#' then begin
        Dest^ := Source^;
        inc(Source);
      end else begin
        inc(Source);
        Dest^ := chr(Min(255,StrToIntDef(StrLCopy(NumBuf,Source,3),ord(' '))));
        inc(Source,StrLen(NumBuf));
      end;
      inc(Dest);
    end;
    Dest^ := #0;
  end;
  GetPrivateProfileText := StrLen(Dest);
  FreeMem(BufPtr,BufSize);
end; { GetPrivateProfileText }

procedure WritePrivateProfileFlag(Sec,Key : PChar; V : boolean; FileName : PChar);
const
  ZU : array[false..true] of PChar = ('0','1');
begin
  WritePrivateProfileString(Sec,Key,ZU[V],FileName);
end; { WritePrivateProfileFlag }

procedure WritePrivateProfileInt(Sec,Key : PChar; V : longint; FileName : PChar);
var
  Buffer : array[0..12] of char;
begin
  WVSPrintF(Buffer,'%ld',V);
  WritePrivateProfileString(Sec,Key,Buffer,FileName);
end; { WritePrivateProfileInt }

procedure WritePrivateProfileReal(Sec,Key : PChar; V : real; NDigits : integer; FileName : PChar);
var
  Buffer : array[0..20] of char;
begin
  Str(V:1:NDigits,Buffer);
  WritePrivateProfileString(Sec,Key,Buffer,FileName);
end; { WritePrivateProfileReal }

procedure WritePrivateProfileText(Sec,Key : PChar; V : PChar; FileName : PChar);
var
  BufPtr,Dest : PChar;
  BufSize,I : integer;
begin
  if (V = nil) or (StrLen(V) = 0) then
    WritePrivateProfileString(Sec,Key,V,FileName)
  else begin
    BufSize := StrLen(V)*4+1;
    GetMem(BufPtr,BufSize);
    Dest := BufPtr;
    while V^ <> #0 do begin
      if not (V^ in [#1..#31,'#']) then begin
        Dest^ := V^;
        inc(Dest);
      end else begin
        I := ord(V^);
        WVSPrintF(Dest,'#%03d',I);
        Dest := StrEnd(Dest);
      end;
      inc(V);
    end;
    Dest^ := #0;
    WritePrivateProfileString(Sec,Key,BufPtr,FileName);
    FreeMem(BufPtr,BufSize);
  end;
end; { WritePrivateProfileText }

{-------------------------------------------------------------- Gestione help }

var
  HelpFile : array[0..fsPathName] of char;

procedure SetHelpFileName(FN : PChar);
begin
  StrLCopy(HelpFile,FN,fsPathName);
end; { SetHelpFileName }

function ExecHelp(Command : word; Data : longint) : boolean;
begin
  ExecHelp := not WinHelp(Application^.MainWindow^.HWindow,HelpFile,Command,Data);
end; { ExecHelp }

procedure CloseHelp;
begin
  ExecHelp(Help_Quit,0);
end; { CloseHelp }

{------------------------------------------------------------------ Profiling }

var
  Time : longint;

procedure StartProfile;
begin
  Time := GetCurrentTime;
end; { StartProfile }

procedure EndProfile;
var
  Buffer : array[0..80] of char;
  Value : longint;
begin
  Value := GetCurrentTime-Time;
  WVSPrintF(Buffer,'Tempo impiegato: %ldms',Value);
  MessageBox(GetFocus,Buffer,'',mb_Ok);
end; { EndProfile }

{------------------------------------- Caricamento e visualizzazione messaggi }

const
  MaxTitleLen = 50;   {Lunghezza massima dei titoli dei message box.}
  MaxMsgLen   = 80;   {Lunghezza massima dei messaggi dei message box
                       e dei messaggi caricati con la MsgPtr.}

var
  MsgBuffer : array[0..MaxMsgLen] of char;

function MsgPtr(MsgH : word) : PChar;
begin
  LoadString(hInstance,MsgH,MsgBuffer,SizeOf(MsgBuffer));
  MsgPtr := @MsgBuffer;
end; { MsgPtr }

function MessageBoxH(AParent : PWindowsObject; MsgH,TitleH : word; BoxType : word) : integer;
var
  Msg   : array[0..MaxMsgLen] of char;
  Title : array[0..MaxTitleLen] of char;
begin
  if (TitleH = MParent) and (AParent <> nil) then
    GetWindowText(AParent^.HWindow,Title,SizeOf(Title))
  else
    LoadString(hInstance,TitleH,Title,SizeOf(Title));
  LoadString(hInstance,MsgH,Msg,SizeOf(Msg));
  if AParent = nil then
    MessageBoxH := MessageBox(GetFocus,Msg,Title,BoxType)
  else
    MessageBoxH := MessageBox(AParent^.HWindow,Msg,Title,BoxType);
end; { MessageBoxH }

procedure ErrorMsg(AParent : PWindowsObject; MsgH,TitleH : word);
begin
  MessageBoxH(AParent,MsgH,TitleH,mb_IconExclamation);
end; { ErrorMsg }

procedure ParErrorMsg(AParent : PWindowsObject; MsgH,TitleH : word; ParS : PChar);
var
  Title : array[0..MaxTitleLen] of char;
  Msg,Buffer : array[0..MaxMsgLen] of char;
begin
  if (TitleH = MParent) and (AParent <> nil) then
    GetWindowText(AParent^.HWindow,Title,SizeOf(Title))
  else
    LoadString(hInstance,TitleH,Title,SizeOf(Title));
  LoadString(hInstance,MsgH,Msg,SizeOf(Msg));
  if ParS = nil then ParS := '';
  WVSPrintf(Buffer,Msg,ParS);
  if AParent = nil then
    MessageBox(GetFocus,Buffer,Title,mb_IconExclamation)
  else
    MessageBox(AParent^.HWindow,Buffer,Title,mb_IconExclamation);
end; { ParErrorMsg }

procedure ParParErrorMsg(AParent : PWindowsObject; MsgH,TitleH : word; ParS1,ParS2 : PChar);
var
  Title : array[0..MaxTitleLen] of char;
  Msg,Buffer : array[0..MaxMsgLen] of char;
  ParBuffer : array[1..2] of PChar;
begin
  if (TitleH = MParent) and (AParent <> nil) then
    GetWindowText(AParent^.HWindow,Title,SizeOf(Title))
  else
    LoadString(hInstance,TitleH,Title,SizeOf(Title));
  LoadString(hInstance,MsgH,Msg,SizeOf(Msg));
  if Pars1 <> nil then ParBuffer[1] := ParS1
  else ParBuffer[1] := '';
  if Pars2 <> nil then ParBuffer[2] := ParS2
  else ParBuffer[2] := '';
  WVSPrintf(Buffer,Msg,ParBuffer);
  if AParent = nil then
    MessageBox(GetFocus,Buffer,Title,mb_IconExclamation)
  else
    MessageBox(AParent^.HWindow,Buffer,Title,mb_IconExclamation);
end; { ParParErrorMsg }

procedure ErrorMsgStr(AParent : PWindowsObject; Msg : PChar; TitleH : word);
begin
  if AParent = nil then
    MessageBox(GetFocus,Msg,MsgPtr(TitleH),mb_IconExclamation)
  else
    MessageBox(AParent^.HWindow,Msg,MsgPtr(TitleH),mb_IconExclamation);
end; { ErrorMsgStr }

procedure Panic(N : integer);
var
  MsgBuffer : array[0..32] of char;
begin
  WVSPrintF(MsgBuffer,'This can''t happen (%d)',N);
  MessageBox(GetFocus,MsgBuffer,'Fatal error',mb_IconExclamation);
  halt(1);
end; { Panic }

procedure Warning(N : integer);
var
  MsgBuffer : array[0..32] of char;
begin
  WVSPrintF(MsgBuffer,'This shouldn''t happen (%d)',N);
  MessageBox(GetFocus,MsgBuffer,'Warning',mb_IconExclamation);
end; { Warning }

{----------------------------------------------------- Richiamo common dialog }

function GetOpenFName(AParent : PWindowsObject;
                      FName : PChar;
                      MCaption,MDesc : word;
                      MustExist : boolean) : boolean;
var
  OpenFileName : TOpenFileName;
  DefExt : array[0..fsExtension] of char;
  Filter : array[0..fsExtension+84] of char;
begin
  FillChar(OpenFileName,SizeOf(TOpenFileName),#0);
  StrCopy(DefExt,GetExtension(FName)+1);
  FillChar(Filter,SizeOf(Filter),#0);
  StrCopy(Filter,MsgPtr(MDesc));
  StrCopy(Filter+StrLen(Filter)+1,'*.');
  StrCat(Filter+StrLen(Filter)+1,DefExt);
  with OpenFileName do begin
    hInstance     := HInstance;
    hwndOwner     := AParent^.HWindow;
    lpstrDefExt   := DefExt;
    lpstrFile     := FName;
    lpstrFilter   := Filter;
    if MCaption <> 0 then lpstrTitle:= MsgPtr(MCaption);
    if MustExist then Flags := ofn_FileMustExist;
    Flags         := Flags or ofn_HideReadOnly;
    lStructSize   := sizeof(TOpenFileName);
    nFilterIndex  := 1;       {Index into Filter String in lpstrFilter}
    nMaxFile      := fsPathName+1;
  end;
  GetOpenFName := GetOpenFileName(OpenFileName); 
  AnsiLower(Fname);
end; { GetOpenFName }

function GetSaveFName(AParent : PWindowsObject;
                      FName : PChar;
                      MCaption,MDesc : word) : boolean;
var
  OpenFileName : TOpenFileName;
  DefExt : array[0..fsExtension] of char;
  Filter : array[0..fsExtension+84] of char;
begin
  FillChar(OpenFileName,SizeOf(TOpenFileName),#0);
  StrCopy(DefExt,GetExtension(FName)+1);
  FillChar(Filter,SizeOf(Filter),#0);
  StrCopy(Filter,MsgPtr(MDesc));
  StrCopy(Filter+StrLen(Filter)+1,'*.');
  StrCat(Filter+StrLen(Filter)+1,DefExt);
  with OpenFileName do begin
    hInstance     := HInstance;
    hwndOwner     := AParent^.HWindow;
    lpstrDefExt   := DefExt;
    lpstrFile     := FName;
    lpstrFilter   := Filter;
    if MCaption <> 0 then lpstrTitle:= MsgPtr(MCaption);
    Flags         := ofn_OverWritePrompt or ofn_HideReadOnly;
    lStructSize   := sizeof(TOpenFileName);
    nFilterIndex  := 1;       {Index into Filter String in lpstrFilter}
    nMaxFile      := fsPathName+1;
  end;
  GetSaveFName := GetSaveFileName(OpenFileName); 
  AnsiLower(FName);
end; { GetSaveFName }

{----------------------------------------------------------------------- Main }

end. { unit Strings2 }