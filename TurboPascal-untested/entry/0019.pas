{$IFDEF VER70}
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X-}
{$ELSE}
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S+,V-,X-}
{$ENDIF}
{$M 8192,0,0}

Unit Edit;

INTERFACE

Uses Crt;

Const
  BS   =  #8;
  CR   = #13;
  SP   = #32;
  Esc  = #27;

  LeftKey  = #75;     HomeKey = #71;
  RightKey = #77;     EndKey  = #79;
  InsKey   = #82;     DelKey  = #83;

Procedure GetString(Size : Byte ; Var Str : String;Fill : Char);

IMPLEMENTATION

{----------------------------------------------------------------------------}

Procedure GetString(Size : Byte ; Var Str: String;Fill : Char);

  Var
    CurrLen   : Byte absolute Str;
    X, Y,
    CurrPos   : Byte;
    Insert    : Boolean;
    I         : Integer;
    T         : Char;

  Begin   {GetString}
    Insert  := True;
    X       := WhereX;                                 {X-pos of first char}
    Y       := WhereY;
    CurrLen := 0;
    CurrPos := 0;                                 {position of current char}
    Repeat
      GotoXY(X,Y);
      Write(Str);
      For I := CurrLen+1 To Size Do 
        Write(Fill);                                    {filler on screen}
      GotoXY(X+CurrPos,Y);
      T := ReadKey;
      If T = #0 Then             {special keys <-, ->, Ins, Home, End, Del}
        Begin   {If}
          T := ReadKey;
          Case T Of
            LeftKey  : If CurrPos > 0 Then Dec(CurrPos);
            RightKey : If (CurrPos < CurrLen) And
                          (CurrPos < Size) Then
                            Inc(CurrPos);
            InsKey   : Insert := Not Insert;
            HomeKey  : CurrPos := 0;
            EndKey   : CurrPos := CurrLen;
            DelKey   : If CurrLen > CurrPos Then
                         Begin   {If}
                           For I := CurrPos+1 To CurrLen-1 Do 
                             Str[I] := Str[I+1];
                           Dec(CurrLen)
                         End    {If}
          End    {Case T Of}
        End    {If}
      Else
        Begin   {Else}
          Case T Of
            BS       : If CurrPos > 0 Then                {delete currpos}
                         Begin   {If}
                           For I := CurrPos To CurrLen-1 Do 
                             Str[i] := Str[i+1];
                           Dec(CurrPos);
                           Dec(CurrLen)
                         End;    {If}
            SP..'~'  : If CurrLen < Size Then          {add new character}
                         Begin   {If}
                           Inc(CurrPos);
                           If insert Then
                             Begin   {If}
                               For I := CurrLen DownTo CurrPos Do
                                 Str[i+1] := Str[i];
                               Inc(CurrLen)
                             End;
                           Str[CurrPos] := T
                         End;    {If}
          End;   {Case T Of}
        End;   {Else}
    Until (T = CR) or (T = Esc);
    If T = Esc Then
      Halt;
    WriteLn;
  End    {GetString};

{----------------------------------------------------------------------------}

End.    {Edit Unit}

Program TestEdit;

Uses
   Crt,
   Edit;

Type
   TRec      = Record
      First,
      Mid,
      Last,
      Add,
      City,
      State,
      Zip    : String;
   End;    {TRec}

Var
   T    : TRec;
   Ch,
   Fill : Char;

{----------------------------------------------------------------------------}

Procedure Init(Var T : TRec);

   Begin   {Init}
      T.Last     := '';
      T.Mid      := '';
      T.First    := '';
      T.Add      := '';
      T.City     := '';
      T.State    := '';
      T.Zip      := '';
   End;    {Init}

{----------------------------------------------------------------------------}

Begin   {Main}
   Fill := '▒';
   Init(T);
   TextBackGround(Blue);
   TextColor(15);
   ClrScr;
   GotoXY(1,5);
   Write('FIRST NAME  : ');
   TextColor(7);
   GetString(20, T.First, Fill);
   TextColor(15);
   Write('MIDDLE NAME : ');
   TextColor(7);
   GetString(20, T.Mid, Fill);
   TextColor(15);
   Write('LAST NAME   : ');
   TextColor(7);
   GetString(20, T.Last, Fill);
   TextColor(15);
   Write('ADDRESS     : ');
   TextColor(7);
   GetString(40, T.Add, Fill);
   TextColor(15);
   Write('CITY        : ');
   TextColor(7);
   GetString(30, T.City, Fill);
   TextColor(15);
   Write('STATE       : ');
   TextColor(7);
   GetString(5, T.State, Fill);
   TextColor(15);
   Write('ZIP-CODE    : ');
   TextColor(7);
   GetString(10, T.Zip, Fill);
   TextBackGround(Black);
   TextColor(LightGray);
   ClrScr;
   GotoXY(1,5);
   WriteLn(T.First,' ',T.Mid,' ',T.Last);
   WriteLn(T.Add);
   WriteLn(T.City,', ',T.State,'   ',T.Zip);
   WriteLn;
   WriteLn('Good-Bye');
   WriteLn;
   WriteLn('Press any key...');
   Ch := ReadKey;
End.    {Main}
