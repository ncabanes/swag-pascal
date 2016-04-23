(*
From: IAN HUNTER
Subj: LZW Compression Unit
*)

Unit IHLZW;
  {- Unit to handle data compression }
Interface
Const
  StackOverFlow = 1;
  DeniedWrite = 2;
Type
  GetCharFunc = Function (Var Ch : Char) : Boolean;
  PutCharProc = Procedure (Ch : Char);
  LZW = Object
          GetChar : GetCharFunc;
          PutChar : PutCharProc;
          LastError : Word;
          Constructor Init;
          Function Get_Hash_Code (PrevC, FollC : Integer) : Integer;
          Procedure Make_Table_Entry (PrevC, FollC: Integer);
          Procedure Initialize_String_Table;
          Procedure Initialize;
          Function Lookup_String (PrevC, FollC : Integer) : Integer;
          Procedure Get_Char (Var C : Integer);
          Procedure Put_Char (C : Integer);
          Procedure Compress;
          Procedure Decompress;
          End;

Implementation
Const
  MaxTab   = 4095;
  No_Prev  = $7FFF;
  EOF_Char = -2;
  End_List = -1;
  Empty    = -3;

Type
  AnyStr = String;
  String_Table_Entry = Record
    Used : Boolean;
    PrevChar : Integer;
    FollChar : Integer;
    Next : Integer;
    End;

Var
  String_Table : Array [0..MaxTab] Of String_Table_Entry;
  Table_Used     : Integer;
  Output_Code    : Integer;
  Input_Code     : Integer;
  If_Compressing : Boolean;

Constructor LZW.Init;
Begin
  LastError := 0;
End;

Function LZW.Get_Hash_Code (PrevC, FollC : Integer) : Integer;
Var
  Index  : Integer;
  Index2 : Integer;
Begin
  Index := ((PrevC SHL 5) XOR FollC) AND MaxTab;
  If (Not String_Table [Index].Used)
    Then
      Get_Hash_Code := Index
    Else
      Begin
        While (String_Table[Index].Next <> End_List) Do
          Index := String_Table[Index].Next;
        Index2 := (Index + 101) And MaxTab;
        While (String_Table[Index2].Used) Do
          Index2 := Succ (Index2) AND MaxTab;
        String_Table[Index].Next := Index2;
        Get_Hash_Code := Index2;
      End;
End;

Procedure LZW.Make_Table_Entry (PrevC, FollC: Integer);
Begin
  If (Table_Used <= MaxTab )
    Then
      Begin
         With String_Table [Get_Hash_Code (PrevC , FollC)] Do
           Begin
             Used     := True;
             Next     := End_List;
             PrevChar := PrevC;
             FollChar := FollC;
           End;
         Inc (Table_Used);
(*
         IF ( Table_Used > ( MaxTab + 1 ) ) THEN
            BEGIN
               WRITELN('Hash table full.');
            END;
*)
      End;
End;

Procedure LZW.Initialize_String_Table;
Var
  I : Integer;
Begin
  Table_Used := 0;
  For I := 0 to MaxTab Do
    With String_Table[I] Do
      Begin
        PrevChar := No_Prev;
        FollChar := No_Prev;
        Next := -1;
        Used := False;
      End;
  For I := 0 to 255 Do
    Make_Table_Entry (No_Prev, I);
End;

Procedure LZW.Initialize;
Begin
  Output_Code := Empty;
  Input_Code := Empty;
  Initialize_String_Table;
End;

Function LZW.Lookup_String (PrevC, FollC: Integer) : Integer;
Var
  Index  : Integer;
  Index2 : Integer;
  Found  : Boolean;
Begin
  Index := ((PrevC Shl 5) Xor FollC) And MaxTab;
  Lookup_String := End_List;
  Repeat
    Found := (String_Table[Index].PrevChar = PrevC) And
             (String_Table[Index].FollChar = FollC);
    If (Not Found)
      Then
        Index := String_Table [Index].Next;
  Until Found Or (Index = End_List);
  If Found
    Then
      Lookup_String := Index;
End;

Procedure LZW.Get_Char (Var C : Integer);
Var
  Ch : Char;
Begin
  If Not GetChar (Ch)
    Then
      C := EOF_Char
    Else
      C := Ord (Ch);
End;

Procedure LZW.Put_Char (C : Integer);
Var
  Ch : Char;
Begin
  Ch := Chr (C);
  PutChar (Ch);
End;

Procedure LZW.Compress;
  Procedure Put_Code (Hash_Code : Integer);
  Begin
    If (Output_Code = Empty)
      Then
        Begin
          Put_Char ((Hash_Code Shr 4) And $FF);
          Output_Code := Hash_Code And $0F;
        End
      Else
        Begin
          Put_Char (((Output_Code Shl 4) And $FF0) +
                   ((Hash_Code Shr 8) And $00F));
          Put_Char (Hash_Code And $FF);
          Output_Code := Empty;
        End;
  End;


  Procedure Do_Compression;
  Var
    C : Integer;
    WC : Integer;
    W : Integer;
  Begin
    Get_Char (C);
    W := Lookup_String (No_Prev, C);
    Get_Char (C);
    While (C <> EOF_Char) Do
      Begin
        WC := Lookup_String (W, C);
        If (WC = End_List)
          Then
            Begin
              Make_Table_Entry (W, C );
              Put_Code (W);
              W := Lookup_String (No_Prev, C);
            End
          Else
            W := WC;
        Get_Char( C );
      End;
    Put_Code (W);
  End;

Begin
  If_Compressing := True;
  Initialize;
  Do_Compression;
End;

Procedure LZW.Decompress;
Const
  MaxStack = 4096;
Var
  Stack : Array [1..MaxStack] Of Integer;
  Stack_Pointer : Integer;

  Procedure Push (C : Integer);
  Begin
    Inc (Stack_Pointer);
    Stack [Stack_Pointer] := C;
    If (Stack_Pointer >= MaxStack)
      Then
        Begin
          LastError := 1;
          Exit;
        End;
  End;

  Procedure Pop (Var C : Integer);
  Begin;
    If (Stack_Pointer > 0)
      Then
        Begin
          C := Stack [Stack_Pointer];
          Dec (Stack_Pointer);
        End
      Else
        C := Empty;
  End;

  Procedure Get_Code (Var Hash_Code : Integer);
  Var
    Local_Buf : Integer;
  Begin
    If (Input_Code = Empty)
      Then
        Begin
          Get_Char (Local_Buf);
          If (Local_Buf = EOF_Char)
            Then
              Begin
                Hash_Code := EOF_Char;
                Exit;
              End;
          Get_Char (Input_Code);
          If (Input_Code = EOF_Char)
            Then
              Begin
                Hash_Code := EOF_Char;
                Exit;
              End;
          Hash_Code := ((Local_Buf Shl 4) And $FF0) +
                       ((Input_Code Shr 4) And $00F);
          Input_Code := Input_Code And $0F;
        End
      Else
        Begin
          Get_Char (Local_Buf);
          If (Local_Buf = EOF_Char)
            Then
              Begin
                Hash_Code := EOF_Char;
                Exit;
              End;
          Hash_Code := Local_Buf + ((Input_Code Shl 8) And $F00);
          Input_Code := Empty;
        End;
  End;

  Procedure Do_Decompression;
  Var
    C : Integer;
    Code : Integer;
    Old_Code : Integer;
    Fin_Char : Integer;
    In_Code : Integer;
    Last_Char : Integer;
    Unknown : Boolean;
    Temp_C : Integer;
  Begin
    Stack_Pointer := 0;
    Unknown := False;
    Get_Code (Old_Code);
    Code := Old_Code;
    C := String_Table[Code].FollChar;
    Put_Char (C);
    Fin_Char := C;
    Get_Code (In_Code);
    While (In_Code <> EOF_Char) Do
      Begin
        Code := In_Code;
        If (Not String_Table [Code].Used)
          Then
            Begin
              Last_Char := Fin_Char;
              Code := Old_Code;
              Unknown := TRUE;
            End;
        While (String_Table [Code].PrevChar <> No_Prev) Do
          With String_Table[Code] Do
            Begin
              Push (FollChar);
              If (LastError <> 0)
                Then
                  Exit;
              Code := PrevChar;
            End;
        Fin_Char := String_Table [Code].FollChar;
        Put_Char (Fin_Char);
        Pop (Temp_C);
        While (Temp_C <> Empty) Do
          Begin
            Put_Char (Temp_C);
            Pop (Temp_C);
          End;
        If Unknown
          Then
            Begin
              Fin_Char := Last_Char;
              Put_Char (Fin_Char);
              Unknown := FALSE;
            End;
        Make_Table_Entry (Old_Code, Fin_Char);
        Old_Code := In_Code;
        Get_Code( In_Code );
      End;
  End;

Begin
  If_Compressing := False;
  Initialize;
  Do_Decompression;
End;

End.

(* *****************************     TEST PROGRAM    ****************** *)

Program LZWTest;
{ program to demo/test the LZW object }
Uses
  IHLZW;  { Only needs this }
Var
  C : LZW; { The Star of the Show; the Compression Object }

{$F+} Function GetTheChar (Var Ch : Char) : Boolean; {$F-}
{ Make your GetChar routine's declaration look exactly like this }

Begin
  If Not Eof (Input) { End of Input? }
    Then
      Begin
        Read (Input, Ch); { Then read one character into Ch and ... }
        GetTheChar := True; { ... Return True }
      End
    Else
      GetTheChar := False; { Otherwise return False }
End;

{$F+} Procedure PutTheChar (Ch : Char); {$F-}
{ Make your PutChar routine's declaration look exactly like this }

Begin
  Write (Output, Ch); { Write Ch to Output file }
End;

Begin
  { Open data files }
  Assign (Input, ''); { Standard Input; requires redirection to be useful }
  Assign (Output, ''); { Standard Output; requires redirection to be useful }
  Reset (Input);
  Rewrite (Output);
  { Can't fail yet -- maybe a descendant could, though... }
  If not C.Init
    Then
      Halt;
  { Assign I/O routines }
  C.GetChar := GetTheChar; { Set LZW's GetChar to routine GetTheChar }
  C.PutChar := PutTheChar; { Set LZW's PutChar to routine PutTheChar }
  { are we compressing or decompressing? }
  If (ParamCount = 0)
    Then
      C.Compress { compress }
    Else
      C.Decompress; { decompress }
  { All Done! }
End.

