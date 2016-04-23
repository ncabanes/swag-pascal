{$A+,B+,D+,E-,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T+,V-,X+,Y+}
{$M 65520,100000,655360}
{
  Copyright 1993 Mark Ouellet. All rights reserved.

  May be freely distributed and incorporated in your own code, in part
  or in it's entirety as long as due credit is given to it's author

  All I ask is that you state my name if you use ALL or PART of it in
  your own code.
}

Program FastAnagrams;

Uses
  Crt;

Type
  StrPointer = ^String;
  NodePtr = ^Node;
  Node    = Record
    Anagram : StrPointer;
    Next    : NodePtr;
  end;

Var
  OldAnagrams : NodePtr;
  NewAnagrams : NodePtr;
  OldCursor : NodePtr;
  NewCursor : NodePtr;
  InputStr : String;

Procedure GetInput;
begin
  ClrScr;
  Write('Input your String: ');
  readln(InputStr);
end;

Procedure FindAnagrams;

Var
  OldIndex : Word;
  NewIndex : Word;

begin
  OldAnagrams := NIL;
  OldCursor   := NIL;
  NewAnagrams := NIL;
  NewCursor   := NIL;

  New(OldCursor);
  OldCursor^.Next := OldAnagrams;
  GetMem(OldCursor^.Anagram, 2);
  OldCursor^.Anagram^ := Copy(InputStr, 1, 1);
  OldAnagrams := OldCursor;

  For OldIndex := 2 to Ord(InputStr[0]) do
  begin
    OldCursor := OldAnagrams;
    While OldCursor <> NIL do
    begin
      For NewIndex := 1 to Ord(OldCursor^.Anagram^[0])+1 do
      begin
        New(NewCursor);
        NewCursor^.Next := NewAnagrams;
        getmem(NewCursor^.Anagram, sizeof(OldCursor^.Anagram^)+1);
        NewCursor^.Anagram^ := OldCursor^.Anagram^;
        Insert(Copy(InputStr, OldIndex, 1),
          NewCursor^.Anagram^, NewIndex);
        NewAnagrams := NewCursor;
      end;
      OldCursor := OldCursor^.Next;
      FreeMem(OldAnagrams^.Anagram, Ord(OldAnagrams^.Anagram^[0])+1);
      OldAnagrams^.Anagram := nil;
      Dispose(OldAnagrams);
      OldAnagrams := OldCursor;
    end;
    OldAnagrams := NewAnagrams;
    OldCursor   := OldAnagrams;
    NewAnagrams := NIL;
    NewCursor   := NIL;
  end;
end;

Procedure OutputAnagrams;
Var
  Count : Word;
begin
  Count := 0;
  OldCursor := OldAnagrams;
  While OldCursor <> NIL do
  begin
    OldCursor := OldCursor^.Next;
    Writeln(OldAnagrams^.Anagram^);
    FreeMem(OldAnagrams^.Anagram, sizeof(OldAnagrams^.Anagram^));
    dispose(OldAnagrams);
    OldAnagrams := OldCursor;
    Inc(Count);
  end;
  Writeln;
  Writeln(Count, ' Anagrams found.');
end;

begin
  GetInput;
  Writeln;
  Writeln(MaxAvail, ' Available memory.');
  Writeln;
  FindAnagrams;
  OutputAnagrams;
end.
