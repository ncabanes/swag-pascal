(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0028.PAS
  Description: Binary Tree Example
  Author: SWAG SUPPORT TEAM
  Date: 08-26-94  08:32
*)

PROGRAM BinaryTreeSample ( INPUT, OUTPUT );

USES Crt;

TYPE NodePtr     = ^Node;

     Node        = RECORD
                    Left,
                    Parent,
                    Right     : WORD;
                    KeyWord   : POINTER;   { Will hold in STRING format }
                   END;                    { Where 1st byte is length   }

     Comparison  = (Less, Greater, Equal);


VAR NewWord  : STRING;                     { Holds word typed in        }
    StartMem : LONGINT;                    { Holds starting memory      }
    Counter,                               { Used for FOR Loop          }
    LastNode : WORD;                       { Holds last node stored     }
    BTree    : ARRAY[1..16000] OF NodePtr; { Entire Binary Tree         }



FUNCTION PtrStr ( Ptr    : POINTER ) : STRING; { Ptr --> String conversion }

VAR Str : STRING;

BEGIN
 Move( Ptr^, Str, Mem[Seg(Ptr^):Ofs(Ptr^)]+1 );   { +1 to copy count byte }
 PtrStr := Str;
END;


PROCEDURE Destroy ( VAR P : POINTER );
BEGIN
 FreeMem (P,Mem[Seg(P^):Ofs(P^)]+1);              { Dispose ptr to free mem }
END;


FUNCTION Compare( Ptr1,                            { Compares two ptrs like }
                  Ptr2   : POINTER ) : Comparison; { strings, returning: <, }
                                                   { >, or =                }
VAR Str1,
    Str2   : STRING;
    Result : Comparison;

BEGIN
 Move( Ptr1^, Str1, Mem[Seg(Ptr1^):Ofs(Ptr1^)]+1 );
 Move( Ptr2^, Str2, Mem[Seg(Ptr2^):Ofs(Ptr2^)]+1 );
 IF Str1=Str2 THEN
  Result := Equal
 ELSE
  IF Str1>Str2 THEN
   Result := Greater
  ELSE
   Result := Less;
 Compare := Result;
END;


PROCEDURE Str_To_Pointer (     Str : STRING;      { Converts Str to Ptr }
                           VAR Ptr : POINTER  );

BEGIN
 GetMem(Ptr,Ord(Str[0])+1);
 Move (Str,Ptr^,Ord(Str[0])+1);
END;


PROCEDURE PlaceWord ( Str : STRING );  { Sort through binary tree, and if }
                                       { the word does not exist, add the }
VAR NewNode        : Node;             { node to the binary tree          }
    Index          : WORD;
    Found,
    SearchFinished : BOOLEAN;
    Comp           : Comparison;

BEGIN
 SearchFinished := (LastNode=0);
 Found := FALSE;
 Index := 1;
 WITH NewNode DO                        { Constructs initial full node     }
  BEGIN
   Left := 0;                           { Don't know yet                   }
   Right := 0;                          {  "      "   "                    }
   Parent := 0;                         {  "      "   "                    }
   Str_To_Pointer ( Str, KeyWord );     { This should store the word in ^  }
  END;
 IF SearchFinished THEN
  BEGIN
   Inc(LastNode);                          { Increase LastNode +1    }
   New(BTree[LastNode]);                   { Create next node        }
   BTree[LastNode]^ := NewNode;            { Store new node now      }
  END;
 WHILE NOT (SearchFinished OR Found) DO
  BEGIN
   Comp := Compare(NewNode.Keyword,BTree[Index]^.KeyWord);
   IF Comp=EQUAL THEN
    Found := TRUE
   ELSE
    IF Comp=Less THEN
     BEGIN
      IF BTree[Index]^.Left = 0 THEN            { IF Last branch then     }
       BEGIN                                    { .. lets make a new one  }
        Inc(LastNode);                          { Increase LastNode +1    }
        New(BTree[LastNode]);                   { Create next node        }
        BTree[Index]^.Left := LastNode;         { Point left to next node }
        NewNode.Parent := Index;                { Set parent to index     }
        BTree[LastNode]^ := NewNode;            { Store new node now      }
        SearchFinished := TRUE                  { All finished!           }
       END
      ELSE
       Index := BTree[Index]^.Left
     END
    ELSE                                        { Must be greater then }
     BEGIN
      IF BTree[Index]^.Right = 0 THEN           { IF Last branch then..   }
       BEGIN                                    { .. lets make a new one  }
        Inc(LastNode);                          { Increase LastNode +1    }
        New(BTree[LastNode]);                   { Create next node        }
        BTree[Index]^.Right := LastNode;        { Point left to next node }
        NewNode.Parent := Index;                { Set parent to index     }
        BTree[LastNode]^ := NewNode;            { Store new node now      }
        SearchFinished := TRUE                  { All finished!           }
       END
      ELSE
       Index := BTree[Index]^.Right
     END;
  END;
END;

PROCEDURE Init;
BEGIN
 LastNode := 0;
END;


PROCEDURE DisposeAll;

VAR Counter : WORD;

BEGIN
 FOR Counter := 1 TO LastNode DO
  BEGIN
   Destroy(BTree[Counter]^.KeyWord);
   Dispose(BTree[Counter]);
  END
END;


BEGIN
 ClrScr;
 StartMem := MemAvail;
 Init;
 REPEAT
  Write ('Insert new word ["stop" to finish] : ');
  Readln (NewWord);
  IF NewWord <> 'stop' THEN
   PlaceWord ( NewWord );
 UNTIL NewWord='stop';
 Writeln;
 Writeln ('  Node    Left     Parent     Right      Word');
 Writeln ('-----------------------------------------------');
 FOR Counter := 1 TO LastNode DO
  WITH BTree[Counter]^ DO
   Writeln (Counter:5,Left:8,Parent:11,Right:10,'       ',PtrStr(KeyWord));
 Writeln;
 Writeln ('Initial memory availible        : ',StartMem);
 Writeln ('Memory availible before dispose : ',MemAvail);
 DisposeAll;
 Writeln ('Memory availible after clean-up : ',MemAvail);
 Readln;
END.

