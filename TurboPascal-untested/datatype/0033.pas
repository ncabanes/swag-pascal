{
From: nick@langroep.wirehub.nl (Nick Vermeulen)

game of life, piece o' cake. i did a encryption from some c-source in pcmag.
it uses game of life to shuffle the key. this is done on bit-level though.

look at this:

Procedure Mutate(iKey: TKey; var oKey: TKey; aWidth, aHeight: Word);

it is called like:

Mutate(aKey, tempKey, 64, 64);

it does 1 generation on iKey and returnes it in oKey. the key is 512 bytes, is
4096 bits and presented as a 64x64 matrix.

i love this code ;) look at how i did the bit manupilation in getcell() and
setcell(), pascal is great . . .

}

Unit Crypt;

Interface

Uses
  Strings;

Const
  KeySize = 512; { DO NOT change !!! }

Type
  TKey = Array[0..KeySize] of Char;

Procedure CreateKey(aPassword: PChar; var aKey: TKey);
{ Block's maxlen = KeySize }
Procedure CryptBlock(    aKey   : TKey;
                     var aBlock : Array of Byte;
                         aSize  : Word);

Implementation

Procedure Mutate(iKey: TKey; var oKey: TKey; aWidth, aHeight: Word);
{}
  Function GetCell(aGrid: TKey; aWidth, aCol, aRow: Word): Boolean;
  {}
  Begin
    GetCell := Odd(Byte(aGrid[((aRow * aWidth + aCol) div 8) + 1]) shr
                  (aCol mod 8));
  End;

  Function SetCell(var aGrid: TKey; aWidth, aCol, aRow: Word; aState: Boolean):
Boolean;
  {}
  Var
    offset : Word;

  Begin
    offset := ((aRow * aWidth + aCol) div 8) + 1;
    If (aState) Then
      Byte(aGrid[offset]) :=Byte(aGrid[offset]) or (1 shl (aCol mod 8))
    Else
      Byte(aGrid[offset]) :=Byte(aGrid[offset]) and not (1 shl (aCol mod 8));
  End;

Var
  CurrentCellAlive  : Boolean;
  LastRow           ,
  NextRow           ,
  LastCol           ,
  NextCol           ,
  i                 ,
  j                 ,
  Neighbors         : Word;

Begin
  For i := 0 to (aHeight-1) Do
  Begin
    If (i = 0) Then
      LastRow := aHeight-1
    Else
      LastRow := i-1;
    If (i = (aHeight-1)) Then
      NextRow := 0
    Else
      NextRow := i+1;
    For j := 0 to (aWidth-1) Do
    Begin
      If (j = 0) Then
        LastCol := aWidth-1
      Else
        LastCol := j-1;
      If (j = (aWidth-1)) Then
        NextCol := 0
      Else
        NextCol := j+1;
      Neighbors := 0;

      If GetCell(iKey, aWidth, LastCol, LastRow) Then
        Inc(Neighbors);
      If GetCell(iKey, aWidth, j, LastRow) Then
        Inc(Neighbors);
      If GetCell(iKey, aWidth, NextCol, LastRow) Then
        Inc(Neighbors);

      If GetCell(iKey, aWidth, LastCol, i) Then
        Inc(Neighbors);
      If GetCell(iKey, aWidth, NextCol, i) Then
        Inc(Neighbors);

      If GetCell(iKey, aWidth, LastCol, NextRow) Then
        Inc(Neighbors);
      If GetCell(iKey, aWidth, j, NextRow) Then
        Inc(Neighbors);
      If GetCell(iKey, aWidth, NextCol, NextRow) Then
        Inc(Neighbors);

      CurrentCellAlive := GetCell(iKey, aWidth, j, i);

      If ( (CurrentCellAlive and (Neighbors in [2,3])) or
           (not CurrentCellAlive and (Neighbors=3))) Then
        SetCell(oKey, aWidth, j, i, True)
      Else
        SetCell(oKey, aWidth, j, i, False);
    End;
  End;
End;

Procedure CreateKey(aPassword: PChar; var aKey: TKey);
{}
Var
  iPasswLen   : Integer;
  iCount      ,
  i           ,
  j           : Integer;
  tempKey     : TKey;

Begin
  iPasswLen := StrLen(aPassword);
  i := 0;
  While (i < KeySize) Do
  Begin
    iCount := iPasswLen;
    If (iCount > (KeySize - i)) Then
      iCount := (KeySize - i);
    j := 0;
    While (j < iCount) Do
    Begin
      aKey[i] := aPassword[j];
      Inc(i);
      Inc(j);
    End;
  End;
  Mutate(aKey, tempKey, 64, 64);
  For i := 0 to (KeySize-1) Do
    aKey[i] := Char(Byte(aKey[i]) xor Byte(tempKey[i]));
  j := 0;
  For i := 0 to (iPasswLen-1) Do
    Inc(j, Byte(aPassword[i]));
  RandSeed := j;
  For i := 0 to (KeySize-1) Do
    aKey[i] := Char(Random(MaxInt) mod $100);
End;

{ Block's maxlen = KeySize }
Procedure CryptBlock(    aKey   : TKey;
                     var aBlock : Array of Byte;
                         aSize  : Word);
{}
Var
  index: Word;

Begin
  For index := 0 to (aSize-1) Do
    aBlock[index] := aBlock[index] xor Byte(aKey[index]);
End;

End.

