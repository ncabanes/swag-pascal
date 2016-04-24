(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0360.PAS
  Description: Pas to Rtf converter
  Author: MARTIN WALDENBURG
  Date: 01-02-98  07:33
*)

{+--------------------------------------------------------------------------+
 | Unit:   mwPasToRtf
 | Created:     09.97
 | Author:      Martin Waldenburg
 | Copyright    1997, all rights reserved.
 | Description: Pas to Rtf converter for syntax highlighting etc.
 | Version:     0.7 beta
 | Status:       FreeWare
 | DISCLAIMER:  This is provided as is, expressly without a warranty of any kind.
 |              You use it at your own risc.
 +--------------------------------------------------------------------------+}

unit mwPasToRtf;


interface

uses
  Windows,
  SysUtils,
  Messages,
  Classes,
  ComCtrls,
  Graphics,
  Dialogs,
  Registry;

type
  TTokenState = (tsAssembler, tsComment, tsCRLF, tsDirective, tsIdentifier,
                 tsKeyWord, tsNumber, tsSpace, tsString, tsSymbol, tsUnknown);

  TCommentState = (csAnsi, csBor, csNo, csSlashes);

type
  TPasConversion = class(TMemoryStream)
  private
    FDiffer: Boolean;
    FPreFixList, FPostFixList: array[tsAssembler..tsUnknown] of String;
    FComment: TCommentState;
    Prefix, TokenStr, Postfix: String;
    FBuffPos, TokenLen, FOutBuffSize, FStrBuffSize: Integer;
    FReadBuff, FOutBuff, FStrBuff, FStrBuffEnd, Run, RunStr, TokenPtr: PChar;
    FTokenState : TTokenState;
    FAssemblerFo: TFont;
    FCommentFo: TFont;
    FDirectiveFo: TFont;
    FIdentifierFo: TFont;
    FNumberFo: TFont;
    FKeyWordFo: TFont;
    FSpaceFo: TFont;
    FStringFo: TFont;
    FSymbolFo: TFont;
    function IsKeyWord(aToken: String):Boolean;
    function IsDirective(aToken: String):Boolean;
    function IsDiffKey(aToken: String):Boolean;
    procedure SetAssemblerFo(newValue: TFont);
    procedure SetCommentFo(newValue: TFont);
    procedure SetDirectiveFo(newValue: TFont);
    procedure SetIdentifierFo(newValue: TFont);
    procedure SetKeyWordFo(newValue: TFont);
    procedure SetNumberFo(newValue: TFont);
    procedure SetSpaceFo(newValue: TFont);
    procedure SetStringFo(newValue: TFont);
    procedure SetSymbolFo(newValue: TFont);
    procedure SetRTF;
    procedure WriteToBuffer(aString: String);
    procedure HandleAnsiC;
    procedure HandleBorC;
    procedure HandleCRLF;
    procedure HandleSlashesC;
    procedure HandleString;
    procedure ScanForRtf;
    procedure AllocStrBuff;
    procedure SetPreAndPosFix(aFont: TFont; aTokenState: TTokenState);
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure Init;
    procedure UseDelphiHighlighting(Ver: Integer);
    function ColorToRTF(aColor: TColor): String;
    function ConvertReadStream: Integer;
    function ConvertWriteStream(Stream: TStream; Buffer: PChar; BufSize: Integer):Integer;
    property AssemblerFo: TFont read FAssemblerFo write SetAssemblerFo;
    property CommentFo: TFont read FCommentFo write SetCommentFo;
    property DirectiveFo: TFont read FDirectiveFo write SetDirectiveFo;
    property IdentifierFo: TFont read FIdentifierFo write SetIdentifierFo;
    property KeyWordFo: TFont read FKeyWordFo write SetKeyWordFo;
    property NumberFo: TFont read FNumberFo write SetNumberFo;
    property SpaceFo: TFont read FSpaceFo write SetSpaceFo;
    property StringFo: TFont read FStringFo write SetStringFo;
    property SymbolFo: TFont read FSymbolFo write SetSymbolFo;
  published
  end;

const
  Keywords : array[0..98] of string =
            ('ABSOLUTE', 'ABSTRACT', 'AND', 'ARRAY', 'AS', 'ASM', 'ASSEMBLER',
             'AUTOMATED', 'BEGIN', 'CASE', 'CDECL', 'CLASS', 'CONST', 'CONSTRUCTOR',
             'DEFAULT', 'DESTRUCTOR', 'DISPID', 'DISPINTERFACE', 'DIV', 'DO',
             'DOWNTO', 'DYNAMIC', 'ELSE', 'END', 'EXCEPT', 'EXPORT', 'EXPORTS',
             'EXTERNAL', 'FAR', 'FILE', 'FINALIZATION', 'FINALLY', 'FOR', 'FORWARD',
             'FUNCTION', 'GOTO', 'IF', 'IMPLEMENTATION', 'IN', 'INDEX', 'INHERITED',
             'INITIALIZATION', 'INLINE', 'INTERFACE', 'IS', 'LABEL', 'LIBRARY',
             'MESSAGE', 'MOD', 'NAME', 'NEAR', 'NIL', 'NODEFAULT', 'NOT', 'OBJECT',
             'OF', 'OR', 'OUT', 'OVERRIDE', 'PACKED', 'PASCAL', 'PRIVATE', 'PROCEDURE',
             'PROGRAM', 'PROPERTY', 'PROTECTED', 'PUBLIC', 'PUBLISHED', 'RAISE',
             'READ', 'READONLY', 'RECORD', 'REGISTER', 'REPEAT', 'RESIDENT',
             'RESOURCESTRING', 'SAFECALL', 'SET', 'SHL', 'SHR', 'STDCALL', 'STORED',
             'STRING', 'STRINGRESOURCE', 'THEN', 'THREADVAR', 'TO', 'TRY', 'TYPE',
             'UNIT', 'UNTIL', 'USES', 'VAR', 'VIRTUAL', 'WHILE', 'WITH', 'WRITE',
             'WRITEONLY', 'XOR');

  Directives : array[0..10] of string =
              ('AUTOMATED', 'INDEX', 'NAME', 'NODEFAULT', 'READ', 'READONLY',
               'RESIDENT', 'STORED', 'STRINGRECOURCE', 'WRITE', 'WRITEONLY');

  DiffKeys: array[0..6] of string =
           ('END', 'FUNCTION', 'PRIVATE', 'PROCEDURE', 'PRODECTED', 'PUBLIC', 'PUBLISHED');


implementation

destructor TPasConversion.Destroy;
begin
  FAssemblerFo.Free;
  FCommentFo.Free;
  FDirectiveFo.Free;
  FIdentifierFo.Free;
  FKeyWordFo.Free;
  FNumberFo.Free;
  FSpaceFo.Free;
  FStringFo.Free;
  FSymbolFo.Free;
  ReAllocMem(FStrBuff, 0);
  inherited Destroy;
end;  { Destroy }

constructor TPasConversion.Create;
begin
  inherited Create;
  FAssemblerFo := TFont.Create;
  FCommentFo := TFont.Create;
  FDirectiveFo := TFont.Create;
  FIdentifierFo := TFont.Create;
  FKeyWordFo := TFont.Create;
  FNumberFo := TFont.Create;
  FSpaceFo := TFont.Create;
  FStringFo := TFont.Create;
  FSymbolFo := TFont.Create;
  Prefix:='';
  PostFix:='';
  FStrBuffSize:= 0;
  AllocStrBuff;
  Init;
  FDiffer:= False;
end;  { Create }

procedure TPasConversion.AllocStrBuff;
begin
  FStrBuffSize:= FStrBuffSize + 1024;
  ReAllocMem(FStrBuff, FStrBuffSize);
  FStrBuffEnd:= FStrBuff + 1023;
end;  { AllocStrBuff }

procedure TPasConversion.SetAssemblerFo(newValue: TFont);
begin
  FAssemblerFo.Assign(newValue);
  SetPreAndPosFix(newValue, tsAssembler);
end;  { SetAssemblerFo }

procedure TPasConversion.SetCommentFo(newValue: TFont);
begin
  FCommentFo.Assign(newValue);
  SetPreAndPosFix(newValue, tsComment);
end;  { SetCommentFo }

procedure TPasConversion.SetDirectiveFo(newValue: TFont);
begin
  FDirectiveFo.Assign(newValue);
  SetPreAndPosFix(newValue, tsDirective);
end;  { SetDirectiveFo }

procedure TPasConversion.SetIdentifierFo(newValue: TFont);
begin
  FIdentifierFo.Assign(newValue);
  SetPreAndPosFix(newValue, tsIdentifier);
end;  { SetIdentifierFo }

procedure TPasConversion.SetKeyWordFo(newValue: TFont);
begin
  FKeyWordFo.Assign(newValue);
  SetPreAndPosFix(newValue, tsKeyWord);
end;  { SetKeyWordFo }

procedure TPasConversion.SetNumberFo(newValue: TFont);
begin
  FNumberFo.Assign(newValue);
  SetPreAndPosFix(newValue, tsNumber);
end;  { SetNumberFo }

procedure TPasConversion.SetSpaceFo(newValue: TFont);
begin
  FSpaceFo.Assign(newValue);
  SetPreAndPosFix(newValue, tsSpace);
end;  { SetSpaceFo }

procedure TPasConversion.SetStringFo(newValue: TFont);
begin
  FStringFo.Assign(newValue);
  SetPreAndPosFix(newValue, tsString);
end;  { SetStringFo }

procedure TPasConversion.SetSymbolFo(newValue: TFont);
begin
  FSymbolFo.Assign(newValue);
  SetPreAndPosFix(newValue, tsSymbol);
end;  { SetSymbolFo }

function TPasConversion.ColorToRTF(aColor: TColor): String;
begin
  aColor:=ColorToRGB(aColor);
  Result:='\red'+IntToStr(GetRValue(aColor))+
          '\green'+IntToStr(GetGValue(aColor))+
          '\blue'+IntToStr(GetBValue(aColor))+';';
end; { ColorToRTF }

procedure TPasConversion.UseDelphiHighlighting(Ver: Integer);

  {Delphi Editor settings are a comma delimited list of seven
   values as follows:

   0 - Foreground color
   1 - Background color
   2 - font style
   3 - Foreground Default
   4 - Background Default
   6 - Unknown
   7 - Unknown

   Currently this routine only handles setting the Bold, Italic, Underline}

  procedure SetDelphiRTF(S: String; aTokenState: TTokenState);
  var
    Ed_List: TStringList;
    Font: TFont;
  Begin
    Font:=TFont.Create;
    Ed_List:=TStringList.Create;
    Try
      Ed_List.CommaText:=S;
      if pos('B',Ed_List[2])>0 then
        Font.Style:=Font.Style+[fsBold];
      if pos('I',Ed_List[2])>0 then
        Font.Style:=Font.Style+[fsItalic];
      if pos('U',Ed_List[2])>0 then
        Font.Style:=Font.Style+[fsUnderLine];
      SetPreAndPosFix(Font,aTokenState);
    finally
    Ed_List.Free;
    Font.Free;
    End;
  End;

const Delphi_Editor: array[0..10] of string=('Assembler','Comment','IGNORE',
           'IGNORE','Identifier','Reserved_Word','Number','Whitespace','String',
           'Symbol','Plain_Text');
var
  RegIni: TRegIniFile;
  Ed_Setting: String;
  i: Integer;
Begin
  if Ver=2 then
    RegIni:=TRegIniFile.Create('Software\Borland\Delphi\2.0')
  else if Ver=3 then
    RegIni:=TRegIniFile.Create('Software\Borland\Delphi\3.0')
  else
    Raise Exception.Create('Only syntax highlighting from Delphi 2 and 3 are supported');

  Try
    for i:=0 to 10 do
      if Delphi_Editor[i]<>'IGNORE' then
        Begin
        Ed_Setting:=RegIni.ReadString('HighLight',Delphi_Editor[i],'0,0,,0,0,0,0');
        SetDelphiRTF(Ed_Setting,TTokenState(i));
        End;
  finally
  RegIni.Free;
  End;
End;

procedure TPasConversion.SetPreAndPosFix(aFont: TFont; aTokenState: TTokenState);
begin
   { Here you need to set the Pre - and PostFix
     accordingly to the aFont value }
  FPreFixList[aTokenState]:= '';
  FPostFixList[aTokenState]:= '';
  if (fsBold in aFont.Style) then
    FPreFixList[aTokenState]:=FPreFixList[aTokenState]+'\b ';
  if (fsItalic in aFont.Style) then
    FPreFixList[aTokenState]:=FPreFixList[aTokenState]+'\i ';
  if (fsUnderline in aFont.Style) then
    FPreFixList[aTokenState]:=FPreFixList[aTokenState]+'\u ';

  if FPreFixList[aTokenState]<>'' then
    FPreFixList[aTokenState]:='{'+FPreFixList[aTokenState];

  if FPreFixList[aTokenState]<>'' then
    FPostFixList[aTokenState]:='}'
end;  { SetPreAndPosFix }

procedure TPasConversion.ScanForRtf;
var
  i: Integer;
begin
  RunStr:= FStrBuff;
  FStrBuffEnd:= FStrBuff + 1023;
  for i:=1 to TokenLen do
  begin
    Case TokenStr[i] of
      '\', '{', '}':
        begin
          RunStr^:= '\';
          inc(RunStr);
        end
    end;
    if RunStr >= FStrBuffEnd then AllocStrBuff;
    RunStr^:= TokenStr[i];
    inc(RunStr);
  end;
  RunStr^:= #0;
  TokenStr:= FStrBuff;
end;  { ScanForRtf }

procedure TPasConversion.HandleAnsiC;
begin
  while Run^ <> #0 do
  begin
    Case Run^ of
      #13:
        begin
          if TokenPtr <> Run then
          begin
            FTokenState:= tsComment;
            TokenLen:= Run - TokenPtr;
            SetString(TokenStr, TokenPtr, TokenLen);
            ScanForRtf;
            SetRTF;
            WriteToBuffer(Prefix + TokenStr + Postfix);
            TokenPtr:= Run;
          end;
          HandleCRLF;
          dec(Run);
        end;

      '*': if (Run +1 )^ = ')' then begin  inc(Run, 2); break; end;
    end;
    inc(Run);
  end;
  FTokenState:= tsComment;
  TokenLen:= Run - TokenPtr;
  SetString(TokenStr, TokenPtr, TokenLen);
  ScanForRtf;
  SetRTF;
  WriteToBuffer(Prefix + TokenStr + Postfix);
  TokenPtr:= Run;
  FComment:= csNo;
end;  { HandleAnsiC }

procedure TPasConversion.HandleBorC;
begin
  while Run^ <> #0 do
  begin
    Case Run^ of
      #13:
        begin
          if TokenPtr <> Run then
          begin
            FTokenState:= tsComment;
            TokenLen:= Run - TokenPtr;
            SetString(TokenStr, TokenPtr, TokenLen);
            ScanForRtf;
            SetRTF;
            WriteToBuffer(Prefix + TokenStr + Postfix);
            TokenPtr:= Run;
          end;
          HandleCRLF;
          dec(Run);
        end;

      '}': begin  inc(Run); break; end;

    end;
    inc(Run);
  end;
  FTokenState:= tsComment;
  TokenLen:= Run - TokenPtr;
  SetString(TokenStr, TokenPtr, TokenLen);
  ScanForRtf;
  SetRTF;
  WriteToBuffer(Prefix + TokenStr + Postfix);
  TokenPtr:= Run;
  FComment:= csNo;
end;  { HandleBorC }

procedure TPasConversion.HandleCRLF;
begin
  if Run^ = #0 then exit;
  inc(Run, 2);
  FTokenState:= tsCRLF;
  TokenLen:= Run - TokenPtr;
  SetString(TokenStr, TokenPtr, TokenLen);
  SetRTF;
  WriteToBuffer(Prefix + TokenStr + Postfix);
  TokenPtr:= Run;
  fComment:= csNo;
  FTokenState:= tsUnKnown;
  if Run^ = #13 then HandleCRLF;
  end;  { HandleCRLF }

procedure TPasConversion.HandleSlashesC;
begin
  FTokenState:= tsComment;
  while (Run^ <> #13) and (Run^ <> #0) do inc(Run);
  TokenLen:= Run - TokenPtr;
  SetString(TokenStr, TokenPtr, TokenLen);
  ScanForRtf;
  SetRTF;
  WriteToBuffer(Prefix + TokenStr + Postfix);
  TokenPtr:= Run;
  FComment:= csNo;
end;  { HandleSlashesC }

procedure TPasConversion.HandleString;
begin
  FTokenState:= tsSTring;
  FComment:= csNo;
  repeat
    Case Run^ of
      #0, #10, #13: raise exception.Create('Invalid string');
    end;
    inc(Run);
  until Run^ = #39;
          inc(Run);
          TokenLen:= Run - TokenPtr;
          SetString(TokenStr, TokenPtr, TokenLen);
          ScanForRtf;
          SetRTF;
          WriteToBuffer(Prefix + TokenStr + Postfix);
          TokenPtr:= Run;
end;  { HandleString }

function TPasConversion.IsKeyWord(aToken: String):Boolean;
var
  First, Last, I, Compare: Integer;
  Token: String;
begin
  First := 0;
  Last := 98;
  Result := False;
  Token:= UpperCase(aToken);
  while First <= Last do
  begin
    I := (First + Last) shr 1;
    Compare := CompareStr(Keywords[i],Token);
    if Compare = 0 then
      begin
        Result:=True;
        break;
      end
    else
    if Compare < 0  then First := I + 1 else Last := I - 1;
  end;
end;  { IsKeyWord }

function TPasConversion.IsDiffKey(aToken: String):Boolean;
var
  First, Last, I, Compare: Integer;
  Token: String;
begin
  First := 0;
  Last := 6;
  Result := False;
  Token:= UpperCase(aToken);
  while First <= Last do
  begin
    I := (First + Last) shr 1;
    Compare := CompareStr(DiffKeys[i],Token);
    if Compare = 0 then
      begin
        Result:=True;
        break;
      end
    else
    if Compare < 0  then First := I + 1 else Last := I - 1;
  end;
end;  { IsDiffKey }

function TPasConversion.IsDirective(aToken: String):Boolean;
var
  First, Last, I, Compare: Integer;
  Token: String;
begin
  First := 0;
  Last := 10;
  Result := False;
  Token:= UpperCase(aToken);
  if CompareStr('PROPERTY', Token) = 0 then FDiffer:= True;
  if IsDiffKey(Token) then FDiffer:= False;
  while First <= Last do
  begin
    I := (First + Last) shr 1;
    Compare := CompareStr(Directives[i],Token);
    if Compare = 0 then
      begin
        Result:= True;
        if FDiffer then
        begin
          Result:= False;
          if CompareStr('NAME', Token) = 0 then Result:= True;
          if CompareStr('RESIDENT', Token) = 0 then Result:= True;
          if CompareStr('STRINGRESOURCE', Token) = 0 then Result:= True;
        end;
        break;
      end
    else
    if Compare < 0  then First := I + 1 else Last := I - 1;
  end;
end;  { IsDirective }

procedure TPasConversion.SetRTF;
begin
  prefix:=FPreFixList[FTokenState];
  postfix:=FPostFixList[FTokenState];
  Case FTokenState of
    tsAssembler: FTokenState:= tsUnknown;

    tsComment: FTokenState:= tsUnknown;

    tsCRLF:
      begin
        PostFix:= '\par ';
        FTokenState:= tsUnknown;
        FComment:= csNo;
      end;

    tsDirective: FTokenState:= tsUnknown;

    tsIdentifier: FTokenState:= tsUnknown;

    tsNumber: FTokenState:= tsUnknown;

    tsKeyWord: FTokenState:= tsUnknown;

    tsSpace: FTokenState:= tsUnknown;

    tsString: FTokenState:= tsUnknown;

    tsSymbol: FTokenState:= tsUnknown;

  end;
end;  { SetRTF }

procedure TPasConversion.WriteToBuffer(aString: String);
var
  Count, Pos: Longint;
begin
  Count:= Length(aString);
  if (FBuffPos >= 0) and (Count >= 0) then
  begin
    Pos := FBuffPos + Count;
    if Pos > 0 then
    begin
      if Pos >= FOutBuffSize then
        begin
           Try
             FOutBuffSize:= FOutBuffSize + 16384;
             ReAllocMem(FOutBuff, FOutBuffSize);
           except
             raise exception.Create('conversions buffer to small');
           end;
        end;
        {System.Write(aString);}
      StrECopy((FOutBuff + FBuffPos), PChar(aString));
      FBuffPos:= FBuffPos + Count;
      FOutBuff[FBuffPos]:= #0;
    end;
  end;
end;  { WriteToBuffer }

function TPasConversion.ConvertReadStream: Integer;
begin
  FTokenState:= tsUnknown;
  FOutBuffSize:= size+3;
  ReAllocMem(FOutBuff, FOutBuffSize);
  FComment:= csNo;
  FBuffPos:= 0;
  FReadBuff:= Memory;
  {Write leading RTF}
  WriteToBuffer('{\rtf1\ansi\deff0\deftab720{\fonttbl{\f0\fswiss MS SansSerif;}{\f1\froman\fcharset2 Symbol;}{\f2\fmodern Courier New;}}'+#13+#10);
  WriteToBuffer('{\colortbl\red0\green0\blue0;}'+#13+#10);
  WriteToBuffer('\deflang1033\pard\plain\f2\fs20 ');

  Result:= Read(FReadBuff^, Size);
  FReadBuff[Result]:= #0;
  if Result > 0 then
  begin
  Run:= FReadBuff;
  TokenPtr:= Run;
  while Run^ <> #0 do
  begin
    Case Run^ of

      #13:
        begin
          FComment:= csNo;
          HandleCRLF;
        end;

      #1..#9, #11, #12, #14..#32:
        begin
          while Run^ in [#1..#9, #11, #12, #14..#32] do inc(Run);
              FTokenState:= tsSpace;
              TokenLen:= Run - TokenPtr;
              SetString(TokenStr, TokenPtr, TokenLen);
              SetRTF;
              WriteToBuffer(Prefix + TokenStr + Postfix);
              TokenPtr:= Run;
        end;

      'A'..'Z', 'a'..'z', '_':
        begin
          FTokenState:= tsIdentifier;
          inc(Run);
          while Run^ in ['A'..'Z', 'a'..'z', '0'..'9', '_'] do inc(Run);
          TokenLen:= Run - TokenPtr;
          SetString(TokenStr, TokenPtr, TokenLen);
          if IsKeyWord(TokenStr) then
          begin
            if IsDirective(TokenStr) then FTokenState:= tsDirective
              else FTokenState:= tsKeyWord;
          end;
          SetRTF;
          WriteToBuffer(Prefix + TokenStr + Postfix);
          TokenPtr:= Run;
        end;

      '0'..'9':
        begin
          inc(Run);
          FTokenState:= tsNumber;
          while Run^ in ['0'..'9', '.', 'e', 'E'] do inc(Run);
          TokenLen:= Run - TokenPtr;
          SetString(TokenStr, TokenPtr, TokenLen);
          SetRTF;
          WriteToBuffer(Prefix + TokenStr + Postfix);
          TokenPtr:= Run;
        end;

      '{':
        begin
          FComment:= csBor;
          HandleBorC;
        end;
      
      '!','"', '%', '&', '('..'/', ':'..'@', '['..'^', '`', '~' :
        begin
          FTokenState:= tsSymbol;
          while Run^ in ['!','"', '%', '&', '('..'/', ':'..'@', '['..'^', '`', '~'] do
          begin
            Case Run^ of
              '/': if (Run + 1)^ = '/' then
                   begin
                     TokenLen:= Run - TokenPtr;
                     SetString(TokenStr, TokenPtr, TokenLen);
                     SetRTF;
                     WriteToBuffer(Prefix + TokenStr + Postfix);
                     TokenPtr:= Run;
                     FComment:= csSlashes;
                     HandleSlashesC;
                     break;
                   end;

              '(': if (Run + 1)^ = '*' then
                   begin
                     TokenLen:= Run - TokenPtr;
                     SetString(TokenStr, TokenPtr, TokenLen);
                     SetRTF;
                     WriteToBuffer(Prefix + TokenStr + Postfix);
                     TokenPtr:= Run;
                     FComment:= csAnsi;
                     HandleAnsiC;
                     break;
                   end;
            end;
            inc(Run);
          end;
          TokenLen:= Run - TokenPtr;
          SetString(TokenStr, TokenPtr, TokenLen);
          SetRTF;
          WriteToBuffer(Prefix + TokenStr + Postfix);
          TokenPtr:= Run;
        end;

      #39: HandleString;

      '#':
        begin
          FTokenState:= tsString;
          while Run^ in ['#', '0'..'9'] do inc(Run);
          TokenLen:= Run - TokenPtr;
          SetString(TokenStr, TokenPtr, TokenLen);
          SetRTF;
          WriteToBuffer(Prefix + TokenStr + Postfix);
          TokenPtr:= Run;
        end;

      '$':
        begin
          FTokenState:= tsNumber;
          while Run^ in ['$','0'..'9', 'A'..'F', 'a'..'f'] do inc(Run);
          TokenLen:= Run - TokenPtr;
          SetString(TokenStr, TokenPtr, TokenLen);
          SetRTF;
          WriteToBuffer(Prefix + TokenStr + Postfix);
          TokenPtr:= Run;
        end;

    else
      begin
        if Run^ <> #0 then
        begin
          inc(Run);
          TokenLen:= Run - TokenPtr;
          SetString(TokenStr, TokenPtr, TokenLen);
          SetRTF;
          WriteToBuffer(Prefix + TokenStr + Postfix);
          TokenPtr:= Run;
        end else break;
      end;
    end;
  end;


  WriteToBuffer(#13+#10+'\par }{'+#13+#10);
end;
  Clear;
  SetPointer(FOutBuff, fBuffPos-1) ;
end;  { ConvertReadStream }

function TPasConversion.ConvertWriteStream(Stream: TStream; Buffer: PChar; BufSize:
Integer): Integer;
begin
  {FBuffPos:= 0;
  FOutBuffSize:= BufSize;
  FOutBuff:= StrAlloc(FOutBuffSize);
  Run:= Buffer;
  while Run^ <> #0 do
  begin

  end;
  Result := Stream.Write(FOutBuff^, BufSize);
  StrDispose(FOutBuff);}
end;  { ConvertWriteStream }

procedure TPasConversion.Init;
begin
end;  { Initialize }

end.

