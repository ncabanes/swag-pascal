{$A+,B-,F-,G+,I-,P-,Q-,R-,S-,T-,V-,X+,Y+}
Program H2Pas;
{ Program:   H2PAS
  Version:   1.21
  Purpose:   convert C header files to some kind of Pascal units

  Developer: Peter Sawatzki (ps) (c) 1993
             Buchenhof 3, 58091 Hagen, Germany
 CompuServe: 100031,3002

  revision history:
  date       version  author   modification
  11/03/93   1.00     ps       written
  05/10/94   1.10     ps       add EXEHDR import support
  06/29/94   1.2x     ps       minor modifications
}
Uses
  Objects,
  Strings;

Const
  Version = 'H2Pas v.1.21';
  H2PasIni= 'H2Pas.Ini';
  CRLF = #13#10;
  StdUses: pChar = 'Uses'+CRLF+
                   '  WinTypes,'+CRLF+
                   '  WinProcs;';
  HasImports: Boolean = False;
  WhichBlock: (Undefd, InConst, InType, InVar, InFunc) = Undefd;
Var
  DstName,
  Imports: String[67];

  Function WordCount(aStr, Delims: pChar): Integer;
  Var
    Count: Integer;
    EndStr: pChar;
  Begin
    EndStr:= StrEnd(aStr);
    Count:= 0;
    While aStr<=EndStr Do Begin
      While (aStr<=EndStr) And (StrScan(Delims, aStr[0])<>Nil) Do Inc(aStr);
      If aStr<=EndStr Then Inc(Count);
      While (aStr<=EndStr) And (StrScan(Delims, aStr[0])=Nil) Do Inc(aStr)
    End;
    WordCount:= Count
  End;

  Function WordPosition (aStr, Delims: pChar; No: Integer): pChar;
  Var
    Count: Integer;
    EndStr: pChar;
  Begin
    EndStr:= StrEnd(aStr);
    Count:= 0;
    WordPosition:= Nil;
    While (aStr<=EndStr) And (Count<>No) Do Begin
      While (aStr<=EndStr) And (StrScan(Delims, aStr[0])<>Nil) Do Inc(aStr);
      If aStr<=EndStr Then Inc(Count);
      If Count<>No Then
        While (aStr<=EndStr) And (StrScan(Delims, aStr[0])=Nil) Do Inc(aStr)
      Else
        WordPosition:= aStr
    End
  End;

  Function ExtractWord (aDst, aStr, Delims: pChar; No: Integer): pChar;
  Var
    EndStr: pChar;
  Begin
    ExtractWord:= aDst;
    aStr:= WordPosition(aStr, Delims, No);
    If Assigned(aStr) Then Begin
      EndStr:= StrEnd(aStr);
      While (aStr<=EndStr) And (StrScan(Delims, aStr[0])=Nil) Do Begin
        aDst[0]:= aStr[0];
        Inc(aStr);
        Inc(aDst)
      End
    End;
    aDst[0]:= #0
  End;

  Function Trim (aDst, aSrc: pChar): pChar;
  Var
    EndStr: pChar;
  Begin
    Trim:= aDst;
    If Not Assigned(aSrc) Or (aSrc[0]=#0) Then
      aDst[0]:= #0
    Else Begin
      EndStr:= StrEnd(aSrc);
      While (aSrc<EndStr) And (aSrc[0]<=' ') Do
        Inc(aSrc);
      StrCopy(aDst, aSrc);
      EndStr:= StrEnd(aDst);
      While (EndStr>aDst) And (EndStr[0]<=' ') Do Begin
        EndStr[0]:= #0;
        Dec(EndStr)
      End
    End
  End;

  Function Pad (aDst, aSrc: pChar; Count: Integer): pChar;
  Begin
    Pad:= aDst;
    If aDst<>aSrc Then
      StrCopy(aDst, aSrc);
    Count:= Count-StrLen(aDst);
    aDst:= StrEnd(aDst);
    While Count>0 Do Begin
      aDst[0]:= ' ';
      Inc(aDst);
      Dec(Count)
    End;
    aDst[0]:= #0
  End;

Function StrIPos(Str1, Str2: PChar): PChar;
Var
  EndStr: pChar;
  Len: Integer;
Begin
  StrIPos:= Nil;
  EndStr:= StrEnd(Str1);
  Len:= StrLen(Str2);
  Repeat
    Str1:= StrScan(Str1, Str2[0]);
    If Str1=Nil Then Exit;
    If StrLIComp(Str1, Str2, Len)=0 Then Begin
      StrIPos:= Str1;
      Exit
    End;
    Inc(Str1)
  Until Str1>EndStr
End;

  Function JustFilename(PathName : string) : string;
  {-Return just the filename of a pathname}
  Var
    I: Word;
  Begin
    I:= Succ(Word(Length(PathName)));
    Repeat
      Dec(I);
    Until (PathName[I] in  ['\', ':', #0]) or (I = 0);
    JustFilename := Copy(PathName, Succ(I), 64);
  End;

  function JustName(PathName : string) : string;
    {-Return just the name (no extension, no path) of a pathname}
  var
    DotPos : Byte;
  begin
    PathName := JustFileName(PathName);
    DotPos := Pos('.', PathName);
    if DotPos > 0 then
      PathName := Copy(PathName, 1, DotPos-1);
    JustName := PathName;
  end;

  Function JustPath(aName: string): string;
  {-Return just the path of a filename}
  Var
    I: Word;
  Begin
    I:= Succ(Word(Length(aName)));
    Repeat
      Dec(I);
    Until (aName[I] in  ['\', ':', #0]) or (I = 0);
    JustPath:= Copy(aName, 1, I)
  End;

  Procedure Fatal (aMsg: pChar);
  Begin
    WriteLn(aMsg);
    Halt(255)
  End;

  Function GetLine (aDst: pChar; Var aFile: Text): pChar;
  Var
    aString: String;
    p,i: Integer;
  Begin
    {$i-}
    ReadLn(aFile, aString);
    If IoResult<>0 Then Fatal('Read error.');
    p:= Pos('//', aString);
    If p>0 Then Begin
      aString[p+1]:= '*';
      aString:= aString+' */'
    End;
    p:= Pos(#9, aString);
    While p>0 Do Begin
      aString[p]:= ' ';
      For i:= 1 To 7-((p-1) Mod 8) Do
        Insert(' ', aString, p);
      p:= Pos(#9, aString)
    End;
    GetLine:= StrPCopy(aDst, aString)
  End;

  Procedure OutLn (Var aFile: Text; OutStr: pChar);
  Var
    oc: Char;
  Begin
    While OutStr[0]<>#0 Do Begin
      oc:= OutStr[0];
      Case oc Of
        '/': If OutStr[1]='*' Then Begin
               oc:= '{';
               Inc(OutStr,1)
             End;
        '*': If OutStr[1]='/' Then Begin
               oc:= '}';
               Inc(OutStr)
             End
      End;
      Write(aFile, oc);
      If IoResult<>0 Then Fatal('Write error.');
      Inc(OutStr)
    End;
    Write(aFile,CRLF);
    If IoResult<>0 Then Fatal('Write error.')
  End;

Procedure HeaderInfo (Var aFile: Text);
Var
  aLine: Array[0..100] Of Char;
Begin
  WriteLn(aFile, '{ Unit: ',DstName);
  WriteLn(aFile, '  Version: 1.00');
  WriteLn(aFile, '  translated from file ',DstName,'.H');
  WriteLn(aFile, '  raw translation using '+Version+', (c) Peter Sawatzki');
  WriteLn(aFile, '  fine tuned by:');
  WriteLn(aFile, '    (fill in)');
  WriteLn(aFile, ' ');
  WriteLn(aFile, '  revision history:');
  WriteLn(aFile, '  Date:    Ver: Author: Mod:');
  WriteLn(aFile, '  xx/xx/94 1.00 <name>  <modification>');
  WriteLn(aFile, '}');
  WriteLn(aFile, 'Unit ',DstName,';');
  WriteLn(aFile, 'Interface');
  If StrLen(StdUses)<>0 Then
    WriteLn(aFile, StdUses);
End;

{-the collection part}
Type
  pImportEntry = ^tImportEntry;
  tImportEntry = Record
    TheName,
    TheDLL,
    TheOrd: pChar
  End;
  pImportCollection = ^tImportCollection;
  tImportCollection = Object(tSortedCollection)
    Function KeyOf(Item: Pointer): Pointer; Virtual;
    Function Compare(Key1, Key2: Pointer): Integer; Virtual;
    Procedure FreeItem(Item: Pointer); Virtual;
  End;

  pTypeMap = ^tTypeMap;
  tTypeMap = Record
    F, T: pChar;
  End;
  pTypeMapCollection = ^tTypeMapCollection;
  tTypeMapCollection = Object(tSortedCollection)
    Function KeyOf(Item: Pointer): Pointer; Virtual;
    Function Compare(Key1, Key2: Pointer): Integer; Virtual;
    Procedure FreeItem(Item: Pointer); Virtual;
  End;

Function tImportCollection.KeyOf(Item: Pointer): Pointer;
Begin
  KeyOf:= pImportEntry(Item)^.TheName
End;

Function tImportCollection.Compare(Key1, Key2: Pointer): Integer;
Begin
  Compare:= StrIComp(Key1, Key2)
End;

Procedure TImportCollection.FreeItem(Item: Pointer);
Begin
  StrDispose(pImportEntry(Item)^.TheName);
  StrDispose(pImportEntry(Item)^.TheDLL);
  StrDispose(pImportEntry(Item)^.TheOrd);
  Dispose(pImportEntry(Item))
End;

Function tTypeMapCollection.KeyOf(Item: Pointer): Pointer;
Begin
  KeyOf:= pTypeMap(Item)^.F
End;

Function tTypeMapCollection.Compare(Key1, Key2: Pointer): Integer;
Begin
  Compare:= StrIComp(Key1, Key2)
End;

Procedure tTypeMapCollection.FreeItem(Item: Pointer);
Begin
  StrDispose(pTypeMap(Item)^.F);
  StrDispose(pTypeMap(Item)^.T);
  Dispose(pTypeMap(Item))
End;

Const
  TheImports: pImportCollection = Nil;
  TheFuncs: pStrCollection = Nil;
  TheStructs: pStrCollection = Nil;
  TheTypeMap: pTypeMapCollection = Nil;
  TheModMap: pStrCollection = Nil;

Procedure CreateCollections;
Begin
  TheImports:= New(pImportCollection, Init(100, 50));
  TheFuncs:= New(pStrCollection, Init(10, 20));
  TheStructs:= New(pStrCollection, Init(10, 20));
  TheTypeMap:= New(pTypeMapCollection, Init(10, 10));
  TheModMap:= New(pStrCollection, Init(10, 10));
End;

Procedure DestroyCollections;
Begin
  If Assigned(TheImports) Then Dispose(TheImports, Done);
  If Assigned(TheFuncs)   Then Dispose(TheFuncs,   Done);
  If Assigned(TheStructs) Then Dispose(TheStructs, Done);
  If Assigned(TheTypeMap) Then Dispose(TheTypeMap, Done);
  If Assigned(TheModMap)  Then Dispose(TheModMap,  Done);
End;

Procedure AddImport (aName, aDLL, anOrd: pChar);
Var
  anEntry: pImportEntry;
Begin
  anEntry:= New(pImportEntry);
  anEntry^.TheName:= StrNew(aName);
  anEntry^.TheDLL:= StrNew(aDLL);
  anEntry^.TheOrd:=  StrNew(anOrd);
  TheImports^.Insert(anEntry)
End;

Procedure AddFunc (aName: pChar);
Begin
  TheFuncs^.Insert(StrNew(aName))
End;

Procedure AddStruct (aName: pChar);
Begin
  TheStructs^.Insert(StrNew(aName))
End;

Procedure AddType (aSrc, aDst: pChar);
Var
  anEntry: pTypeMap;
Begin
  anEntry:= New(pTypeMap);
  anEntry^.F:= StrNew(aSrc);
  anEntry^.T:= StrNew(aDst);
  TheTypeMap^.Insert(anEntry)
End;

Procedure AddMod (aName: pChar);
Begin
  TheModMap^.Insert(StrNew(aName))
End;

Function GetOrdDLL (aName, RetDLL, RetOrd: pChar): Boolean;
Var
  Index: Integer;
Begin
  If TheImports^.Search(aName, Index) Then
    With pImportEntry(TheImports^.At(Index))^ Do Begin
      GetOrdDLL:= True;
      StrCopy(RetDLL, TheDLL);
      StrCopy(RetOrd, TheOrd)
    End
  Else
    GetOrdDLL:= False
End;

Procedure ReadImports (aFileName: String);
Var
  aFile: Text;
  aLine: Array[0..500] Of Char;
  aName,
  aDLL,
  anOrd: Array[0..60] Of Char;
  aWord: Array[0..60] Of Char;
Begin
  {$i-} Assign(aFile, aFileName); Reset(aFile);
  If IoResult<>0 Then Exit;
  HasImports:= True;
  StrCopy(aDLL, '?');
  While Not Eof(aFile) Do Begin
    GetLine(aLine, aFile);
    If StrComp(ExtractWord(aWord, aLine, ' ', 1),'Library:')=0 Then
      ExtractWord(aDLL, aLine, ' ', 2)
    Else
    If StrComp(ExtractWord(aWord, aLine, ' ', 5),'exported,')=0 Then Begin
      ExtractWord(anOrd, aLine, ' ', 1);
      ExtractWord(aName, aLine, ' ', 4);
      AddImport(aName, aDLL, anOrd)
    End
  End;
  Close(aFile)
End;

Procedure ReadIni;
Var
  IniFile: Text;
  aStr: String;
  aLine, Word1, Word2: Array[0..255] Of Char;
  rm: (rmNone, rmTypeMap, rmModMap);
  p: Integer;
Begin
  {$i-}
  Assign(IniFile, H2PasIni); Reset(IniFile);
  If IoResult<>0 Then Begin
    Assign(IniFile, JustPath(ParamStr(0))+'\'+H2PasIni);
    Reset(IniFile);
    If IoResult<>0 Then
      Exit
  End;
  rm:= rmNone;
  While Not Eof(IniFile) Do Begin
    ReadLn(IniFile, aStr);
    p:= Pos(';', aStr); If (p>0) Then aStr[0]:= Chr(p-1);
    StrPCopy(aLine, aStr); Trim(aLine, aLine);
    If StrLen(aLine)=0 Then
      Continue;
    If aLine[0]='[' Then Begin
      If StrIComp(aLine, '[TypeMap]')=0 Then rm:= rmTypeMap Else
      If StrIComp(aLine, '[ModMap]')=0 Then rm:= rmModMap Else
        rm:= rmNone;
      Continue
    End;
    Case rm Of
      rmTypeMap: AddType(Trim(Word1, ExtractWord(Word1, aLine, '=', 1)),
                         Trim(Word2, ExtractWord(Word2, aLine, '=', 2)));
      rmModMap:  AddMod(aLine);
    End
  End;
  Close(IniFile)
End;

Function Modifier (aPart: pChar): Boolean;
Var
  Index: Integer;
Begin
  Modifier:= TheModMap^.Search(aPart, Index)
End;

Function TypeConvert (aDst, aSrc: pChar): pChar;
Var
  aWord, ToParse: Array[0..79] Of Char;
  i, anInt, anError: Integer;
  aTemp: Array[0..79] Of Char;
  Index: Integer;
Begin
  TypeConvert:= aDst;
  aDst[0]:= #0;
  ExtractWord(aTemp, aSrc, '[]', 2);
  If StrLen(aTemp)>0 Then Begin
    Val(aTemp, anInt, anError);
    If anError=0 Then Begin
      Str(anInt-1:0, aTemp);
      StrCat(StrCat(StrCat(aDst,'Array[0..'), aTemp),'] Of ');
    End Else
      StrCat(StrCat(StrCat(aDst,'?'), aTemp),'?')
  End;
  ExtractWord(ToParse, aSrc, '[]', 1);
  aTemp[0]:= #0;
  For i:= 1 To WordCount(ToParse, ' ') Do Begin
    ExtractWord(aWord, ToParse, ' ', i);
    If aWord[0]='*' Then Begin
      StrCat(aTemp,'* ');
      aWord[0]:= ' ';
      Trim(aWord, aWord)
    End;
    If (aWord[0]<>#0) And Not Modifier(aWord) Then
      StrCat(StrCat(aTemp, aWord),' ');
  End;

  Trim(aTemp, aTemp);
  If TheTypeMap^.Search(@aTemp, Index) Then
    With pTypeMap(TheTypeMap^.At(Index))^ Do
      StrCopy(aTemp, T);
  StrCat(aDst, aTemp)
End;

Const
  IdMax = 50;
Type
  tIdTable = Array[1..IdMax] Of
    Record
      TheId,
      TheType: Array[0..79] Of Char;
      TheComment: Array[0..300] Of Char
    End;
Var
  IdCnt: Integer;
  IdTable: tIdTable;

  Procedure InitId;
  Begin
    IdCnt:= 0
  End;

  Procedure AddId (anId, aType, aComment: pChar);
  Begin
    If IdCnt=IdMax Then Begin
      WriteLn('Error: Id Table full. HALT.');
      Halt(1)
    End;
    Inc(IdCnt);
    With IdTable[IdCnt] Do Begin
      Trim(TheId, anId);
      TypeConvert(TheType, aType);
      Trim(TheComment, aComment)
    End
  End;

  Function ParseComment(Var Inf: Text; InStr, OutStr: pChar): Boolean;
  Var
    aWord: Array[0..40] Of Char;
  Begin
    ParseComment:= False;
    If StrPos(StrLCopy(aWord, InStr, 5),'/*')=Nil Then Exit;
    While StrPos(InStr, '*/')=Nil Do Begin
      StrCat(OutStr, InStr);
      GetLine(InStr, Inf)
    End;
    StrCat(OutStr, InStr);
    ParseComment:= True
  End;

  Function ParseDefine(InStr, OutStr: pChar): Boolean;
  Const
    DefineDelim = ' ';
  Var
    aWord: Array[0..512] Of Char;
    Rest, p: pChar;
    isConst: Boolean;
    i: Integer;
  Begin
    ParseDefine:= False;
    If WordCount(InStr, DefineDelim)<3 Then Exit;
    If  (ExtractWord(aWord, InStr, DefineDelim, 1)<>Nil)
    And (StrIComp(aWord, '#define')=0) Then Begin
      isConst:= False;
      If WhichBlock<>InConst Then
        StrCopy(OutStr,CRLF+'Const'+CRLF+'  ')
      Else
        StrCopy(OutStr,'  ');
      ExtractWord(StrEnd(OutStr), InStr, DefineDelim, 2);
      StrCat(Pad(OutStr, OutStr, 35), '= ');
      Rest:= WordPosition(InStr, DefineDelim, 3);
      StrCopy(aWord, Rest);
      p:= StrPos(aWord,'/*'); If Assigned(p) Then p^:= #0;
      Trim(aWord, aWord);
      If StrLen(aWord)>15 Then Exit;
      p:= StrPos(aWord, '0x');
      While Assigned(p) Do Begin
        isConst:= True;
        p[0]:= ' ';
        p[1]:= '$';
        p:= StrPos(p, '0x')
      End;
      p:= StrScan(aWord, 'L');  {get rid of the f*cking 'L'}
      While Assigned(p) Do Begin
        If (p>aWord) Then Begin
          Dec(p);
          If p^ In ['0'..'9','A'..'F','a'..'f'] Then Begin
            p[1]:= ' ';
            IsConst:= True
          End;
          Inc(p)
        End;
        p:= StrScan(p+1, 'L')
      End;
      If Not IsConst Then
        For i:= 0 To StrLen(aWord)-1 Do
          If aWord[i] In ['0'..'9'] Then Begin
            IsConst:= True;
            Break
          End;
      If Not IsConst Then
        Exit;
      Trim(aWord, aWord);
      StrCat(StrCat(OutStr, aWord), ';');
      p:= StrPos(Rest,'/*');
      If Assigned(p) Then
        StrCat(Pad(OutStr,OutStr, 60), p);
      WhichBlock:= InConst;
      ParseDefine:= True
    End
  End;

  Function ParseStruct(Var Inf: Text; InStr, OutStr: pChar): Boolean;
  Var
    aWord,
    aComment,
    RecComment,
    RecName,
    anId, aType,
    Rest: Array[0..300] Of Char;
    possibleArray: Array[0..60] Of Char;
    p, cp: pChar;
    i: Integer;
  Begin
    ParseStruct:= False;
    If  (StrIComp(ExtractWord(aWord, Instr, ' ', 1), 'struct')<>0)
    And (StrIComp(ExtractWord(aWord, Instr, ' ', 2), 'struct')<>0) Then
      Exit;
    p:= Instr;
    Instr:= StrScan(InStr, '{');
    If Not Assigned(InStr) Then Exit;

    {-try to parse the structure}
    InStr^:= #0;
    ExtractWord(RecName, p, ' ', WordCount(p,' '));
    Inc(InStr);
    Trim(InStr, InStr);
    If (InStr[0]='/') And (InStr[1]='*') Then
      StrCopy(RecComment, InStr)
    Else
      RecComment[0]:= #0;
    InStr:= StrEnd(InStr);
    cp:= InStr;
    Repeat
      GetLine(cp, Inf);
      p:= StrScan(cp, '}');
      cp:= StrEnd(cp);
      cp^:= ' '; Inc(cp); cp^:= #0
    Until Assigned(p);
    If WordCount(p+1,' ;')>0 Then
      ExtractWord(RecName, p+1, ' ;', 1);
    pChar(p-1)^:= #0;
    InitId;
    p:= InStr;
    Repeat
      cp:= p;
      p:= StrScan(p, ';');
      If Assigned(p) Then Begin
        Trim(aWord, ExtractWord(aWord, cp, ';', 1));
        {extract possible comment}
        cp:= StrPos(aWord, '/*');
        If Assigned(cp) Then Begin
          StrCopy(aComment, cp);
          cp^:= #0
        End Else
          aComment[0]:= #0;
        {-extract id and type}
        cp:= WordPosition(aWord, ' *', WordCount(aWord, ' *')); {last word}
        StrCopy(anId, cp);
        ExtractWord(possibleArray, anId,'[]',2);
        ExtractWord(anId, anId, '[]', 1);
        cp^:= #0;
        StrCopy(aType, aWord);
        If StrLen(possibleArray)>0 Then
          StrCat(StrCat(StrCat(aType,'['),possibleArray),']');
        {-extract comment if after ';'}
        Inc(p);
        While p^=' ' Do Inc(p);
        While (p[0]='/') And (p[1]='*') Do Begin
          {append comment}
          cp:= StrEnd(aComment);
          Repeat
            cp^:= p^;
            Inc(p);
            Inc(cp)
          Until (p[0]=#0) Or ((p[0]='*') And (p[1]='/'));
          cp[0]:= #0; StrCat(Trim(aComment, aComment),' */');
          If p[0]<>#0 Then
            Inc(p,2);
          While p^=' ' Do Inc(p)
        End;
        AddId(anId, aType, aComment)
      End
    Until Not Assigned(p);

    {-output the structure}
    If WhichBlock<>InType Then Begin
      StrCopy(OutStr,CRLF+'Type'+CRLF);
      OutStr:= StrEnd(OutStr)
    End;
    StrCopy(OutStr,'  ');
    StrCat(OutStr, RecName);
    StrCat(OutStr,' = Record');
    If RecComment[0]<>#0 Then
      StrCat(Pad(OutStr, OutStr, 40), RecComment);
    StrCat(OutStr,CRLF);
    For i:= 1 To IdCnt Do Begin
      OutStr:= StrEnd(OutStr);
      With IdTable[i] Do Begin
        StrCopy(OutStr,'    ');
        {If StrIComp(TheId, TheType)=0 Then StrCat(OutStr, '_');} {it works as is}
        StrCat(OutStr, TheId);
        If (i<IdCnt) And (StrIComp(IdTable[i].TheType, IdTable[i+1].TheType)=0) Then
          StrCat(OutStr,', ')
        Else Begin
          StrCat(StrCat(OutStr,': '),TheType);
          If i<IdCnt Then
            StrCat(OutStr,'; ')
        End;
        If TheComment[0]<>#0 Then Begin
          Pad(OutStr, OutStr, 40);
          StrCat(OutStr, TheComment)
        End;
        StrCat(OutStr,CRLF)
      End
    End;
    StrCat(OutStr,'  End;');
    AddStruct(RecName);
    WhichBlock:= InType;
    ParseStruct:= True
  End;

  Function ParseAPI(Var Inf: Text; InStr, OutStr: pChar): Boolean;
  Var
    FHead,
    aWord,
    Res,
    FuncComment,
    FuncName,
    anId, aType, aComment: Array[0..200] Of Char;
    p, cp, cp2, pStart: pChar;
    i, Indent: Integer;
    IsFunc: Boolean;
    Unknown: Integer;

    Function ParseWordAndComment (aComment, aWord, Src: pChar; Delim: Char): pChar;
    {parse Src, search for delim. append comments to aComment, source to aWord}
    Var
      cp: pChar;
    Begin
      Repeat
        While Src^=' ' Do Inc(Src);
        While (Src[0]='/') And (Src[1]='*') Do Begin
          {append comment}
          cp:= StrEnd(aComment);
          Repeat
            cp^:= Src^;
            Inc(Src);
            Inc(cp)
          Until (Src[0]=#0) Or ((Src[0]='*') And (Src[1]='/'));
          cp[0]:= #0; StrCat(Trim(aComment, aComment),' */');
          If Src[0]<>#0 Then
            Inc(Src,2);
          While Src^=' ' Do Inc(Src)
        End;
        cp:= StrEnd(aWord);
        While Not(Src^ In [#0,',','/']) Do Begin
          cp^:= Src^; Inc(Src); Inc(cp)
        End;
        cp^:= #0;
        If Src^=#0 Then Begin
          ParseWordAndComment:= Src;
          Exit
        End
      Until Src^=',';
      Inc(Src);
      While Src^=' ' Do Inc(Src);
      While (Src[0]='/') And (Src[1]='*') Do Begin
        {append comment}
        cp:= StrEnd(aComment);
        Repeat
          cp^:= Src^;
          Inc(Src);
          Inc(cp)
        Until (Src[0]=#0) Or ((Src[0]='*') And (Src[1]='/'));
        cp[0]:= #0; StrCat(Trim(aComment, aComment),' */');
        If Src[0]<>#0 Then
          Inc(Src,2);
        While Src^=' ' Do Inc(Src)
      End;
      ParseWordAndComment:= Src
    End;

  Begin
    ParseAPI:= False;
    IsFunc:= False;
    FuncName[0]:= #0;
    Res[0]:= #0;
    If (StrPos(InStr,'typedef')<>Nil)
    Or (StrPos(InStr,'#define')<>Nil)
    Or (StrPos(InStr,'#if')<>Nil)
    Or (StrPos(InStr,'#el')<>Nil) Then Exit;
    pStart:= StrScan(InStr, '(');
    If Not Assigned(pStart) Then Exit;
    pStart^:= #0;
    Trim(FuncName, ExtractWord(FuncName, InStr, ' ', WordCount(InStr, ' ')));
    cp:= WordPosition(InStr, ' ', WordCount(InStr, ' '));
    If Assigned(cp) Then Begin
      cp[0]:= #0;
      Trim(Res, TypeConvert(Res, InStr))
    End Else
      StrCopy(Res, '?????');
    InStr:= pStart+1;
    cp:= InStr;
    p:= StrScan(cp, ';');
    While Not Assigned(p) Do Begin
      cp:= StrEnd(cp);
      cp^:= ' '; Inc(cp);
      GetLine(cp, Inf);
      p:= StrScan(cp, ';')
    End;
    StrCopy(FuncComment, p+1);
    Repeat
      Dec(p)
    Until (p<=InStr) Or (p^=')');
    p^:= #0;

    InitId;
    Unknown:= 0;
    p:= InStr;
    While p^<>#0 Do Begin
      aComment[0]:= #0;
      aWord[0]:= #0;
      p:= ParseWordAndComment(aComment, aWord, p, ',');
      Trim(aWord, aWord);
      TypeConvert(aType, aWord);
      anId[0]:= #0;
      cp:= WordPosition(aWord, ' *', WordCount(aWord, ' *')); {last word}
      If (WordCount(aWord,' *')=1)
      Or (Assigned(cp) And (StrIComp(cp, TypeConvert(aType, cp))<>0)) Then Begin
      {non-Ansi declaration}
        Inc(Unknown);
        Str(Unknown, anId);
        Move(anId[0], anId[3], StrLen(anId)+1);
        anId[0]:= 'P'; anId[1]:= 'a'; anId[2]:= 'r';
      End Else Begin
        If Assigned(cp) Then Begin
          StrCopy(anId, cp);
          cp^:= #0
        End;
        TypeConvert(aType, aWord)
      End;
      AddId(anId, aType, aComment)
    End;

    StrCopy(OutStr, '  Function ');
    StrCat(OutStr, FuncName);
    StrCat(OutStr, ' (');
    Indent:= StrLen(OutStr);
    OutStr:= StrEnd(OutStr);
    aWord[0]:= #0;
    For i:= 1 To IdCnt Do
      With IdTable[i] Do Begin
        StrCat(aWord, TheId);
        If (i<IdCnt) And (StrIComp(IdTable[i].TheType, IdTable[i+1].TheType)=0) Then
          StrCat(aWord, ', ')
        Else Begin
          StrCat(StrCat(aWord, ': '), TheType);
          If i<IdCnt Then StrCat(aWord, '; ')
        End;
        Trim(aWord, aWord);
        If TheComment[0]<>#0 Then
          StrCat(Pad(aWord, aWord, 60-Indent), TheComment);
        If (Indent+StrLen(aWord)>90) Or (TheComment[0]<>#0) Then Begin
          StrCopy(OutStr, aWord); OutStr:= StrEnd(OutStr);
          If i<IdCnt Then Begin
            StrCat(OutStr, CRLF);
            Pad(OutStr, OutStr, 2+Indent)
          End;
          OutStr:= StrEnd(OutStr);
          aWord[0]:= #0
        End
      End;
    StrCat(StrCat(StrCat(StrCat(StrCat(OutStr, aWord),'): '), Res),';'), FuncComment);
    AddFunc(FuncName);
    WhichBlock:= InFunc;
    ParseAPI:= True
  End;

  Procedure GenerateReport (Var Out: Text);
    Procedure RepFunc (Item: Pointer); Far;
    Var
      aDLL, anOrd: Array[0..60] Of Char;
      aLine: Array[0..200] Of Char;
    Begin
      StrCopy(aDLL,'?');
      StrCopy(anOrd, '?');
      If HasImports Then
        GetOrdDLL(Item, aDLL, anOrd);
      StrCat(StrCat(StrCopy(aLine,'  Function '), pChar(Item)),';');
      StrCat(Pad(aLine, aLine, 42),'External ''');
      StrCat(StrCat(aLine, aDLL), '''');
      StrCat(Pad(aLine, aLine, 62),'Index ');
      StrCat(StrCat(Pad(aLine, aLine, 72-StrLen(anOrd)), anOrd),';');
      WriteLn(Out,aLine)
    End;
    Procedure VeriPascal (Item: Pointer); Far;
    Var
      aLine: Array[0..200] Of Char;
      aName: Array[0..60] Of Char;
    Begin
      Pad(aName, Item, 35);
      StrCat(StrCopy(aLine,'  veri('''), aName);
      StrCat(StrCat(StrCat(aLine,''',sizeof('),aName),'));');
      WriteLn(Out,aLine)
    End;
    Procedure VeriC (Item: Pointer); Far;
    Var
      aLine: Array[0..200] Of Char;
      aName: Array[0..60] Of Char;
    Begin
      Pad(aName, Item, 35);
      StrCat(StrCopy(aLine,'  veri("'), aName);
      StrCat(StrCat(StrCat(aLine,'",sizeof('),aName),'));');
      WriteLn(Out,aLine)
    End;
  Begin
    WriteLn(Out, 'Implementation');
    TheFuncs^.ForEach(@RepFunc);
    WriteLn(Out, 'End.');
    WriteLn(Out);
    WriteLn(Out, '--- snip --- snip --- snip ---');
    WriteLn(Out,CRLF+CRLF+'{Pascal verification program for '+Dstname+' }');
    WriteLn(Out,'Program VeriP;'+CRLF+
                'Uses'+CRLF+
                '  '+DstName+';'+CRLF);
    WriteLn(Out,'Procedure Veri (aStr: pChar; aSize: Integer);');
    WriteLn(Out,'Begin');
    WriteLn(Out,'  WriteLn(''Size of '',aStr,''= '',aSize:5);');
    WriteLn(Out,'End;'+CRLF);
    WriteLn(Out,'Begin');
    WriteLn(Out,'  WriteLn(''verification of '+DstName+' for Pascal:'');');
    TheStructs^.ForEach(@VeriPascal);
    WriteLn(Out,'End.');
    WriteLn(Out);
    WriteLn(Out,CRLF+CRLF+'/* C verification program for '+DstName+' */');
    WriteLn(Out,'#include <stdio.h>'+CRLF+
                '#include "'+DstName+'.h"'+CRLF+
                'void veri (char *aStr, int aSize)'+CRLF+
                '{ printf("Size of %s= %5i\n",aStr,aSize); }'+CRLF);
    WriteLn(Out,'void main (void)'+CRLF+
                '{ printf("verification of '+DstName+' for C:\n");');
    TheStructs^.ForEach(@VeriC);
    WriteLn(Out,'}');
  End;

Const
  LineBufSize = 5000;
  IoBufSize   = 32*1024;
Type
  IoBuf = Array[0..IoBufSize-1] Of Char;
  pIoBuf = ^IoBuf;
Var
  Inf, Out: Text;
  InStr,
  OutStr: pChar;
Begin
  WriteLn(Version,', written 1993 by P. Sawatzki');
  If Not (ParamCount In [2,3]) Then Begin
    WriteLn('Usage: H2Pas InFile OutFile [ImportList]');
    Halt
  End;
  CreateCollections;
  ReadIni;
  If ParamStr(3)<>'' Then
    Imports:= ParamStr(3)
  Else
    Imports:= JustName(ParamStr(1))+'.Imp';
  {$i-}
  Assign(Inf, ParamStr(1)); Reset(Inf);
  If IoResult<>0 Then Fatal('Input file not found');
  Assign(Out, ParamStr(2)); ReWrite(Out);
  If IoResult<>0 Then Fatal('Unable to create output file');
  DstName:= JustName(ParamStr(2));
  GetMem(InStr,  LineBufSize);
  GetMem(OutStr, LineBufSize);
  Write('Processing files...');
  HeaderInfo(Out);
  While Not Eof(Inf) Do Begin
    GetLine(InStr, Inf);
    OutStr[0]:= #0;
    If ParseComment(Inf, InStr, OutStr)
    Or ParseDefine(InStr, OutStr)
    Or ParseStruct(Inf, InStr, OutStr)
    Or ParseAPI(Inf, InStr, OutStr) Then
      OutLn(Out, OutStr)
    Else
      OutLn(Out, InStr)
  End;
  WriteLn('Done.');
  Write('Reading import file ',Imports,'...');
  ReadImports(Imports);
  If HasImports Then
    WriteLn('Done.')
  Else
    WriteLn('Not found.'+CRLF+
            '(generate an import file using "EXEHDR File.DLL >'+JustName(ParamStr(1))+
            '.Imp")');
  Write('Appending report...');
  GenerateReport(Out);
  WriteLn('Done.');
  DestroyCollections;
  FreeMem(InStr,  LineBufSize);
  FreeMem(OutStr, LineBufSize);
  Close(Inf);
  Close(Out)
End.

{ -------------  INFO ON THIS PROGRAM ------------------ }

ReadMe.Txt for H2Pas
====================

H2Pas is a quick and dirty hack to convert C-Header files to Pascal units.

If you make modifications, please drop me a copy at
  Peter Sawatzki, CompuServe 100031,3002

In it's current implementation (1.20) H2Pas does the following:

- convert structs
- convert constant defines
- convert procedure/function headers
- 'convert' comments of style /* xxxx */ to { xxxx }
  and comments of style // yyyy to { yyy }
- make use of IMPort files to resolve DLL index entries
- output C and Pascal code to verify correctness of C and Pascal
  structure sizes

How to use and generate import files:
-------------------------------------

if a EXEHDR type .IMP file is present for the DLL with information
about the entry points of a function, H2Pas outputs an unit implementation
section with entries of the form:

  Function Ctl3DEnabled;                  External 'CTL3D'    Index    5;

where the appropriate indices are resolved from information gathered
from the .IMP file.

To generate the .IMP file for a DLL -say CTL3D.DLL- one must do the following:

  EXEHDR CTL3D.DLL >CTL3D.IMP


How to execute H2Pas
--------------------

Usage:

H2Pas Ctl3D.H Ctl3D.Pas [Ctl3D.Imp]

where Ctl3D.H is the source C header file,
      Ctl3D.Pas is the destination pascal unit to be generated
  and Ctl3D.Imp is an optional import file generated from EXEHDR

H2Pas.Ini
---------

currently H2Pas.Ini has two areas for customization:

[TypeMap]
C-Type = Pascal-Type

maps a certain C-type to a Pascal type (see sample H2Pas.Ini)

[ModMap]
modifier

a list of modifiers that H2Pas should ignore (see sample H2Pas.Ini)

written by

  Peter Sawatzki
  Buchenhof 3
  58091 Hagen / Germany
  CompuServe: 100031,3002





 { ------------------  SAMPLE INI FILE NEED FOR THIS UNIT ---------- }
 { CUT and Save as H2PAS.INI                                         }

[TypeMap]
unsigned        = Word
unsigned int    = Word
char            = Char
unsigned long   = LongInt
int             = Integer
char far *      = pChar
unsigned char   = Byte
byte            = Byte
char *          = pChar
long            = LongInt
WORD            = Word
DWORD           = LongInt
ULONG           = LongInt
BOOL            = Bool
UINT            = Word
void *          = Pointer
; Windows stuff
BITMAPINFO      = tBitmapInfo
HANDLE          = tHandle
HWINDOW         = hWindow
COLORREF        = tColorRef

[ModMap]
WINAPI
WINGAPI
APIENTRY
EXPENTRY
EXPORT
EXTERN
PASCAL
FAR
_FAR
const

