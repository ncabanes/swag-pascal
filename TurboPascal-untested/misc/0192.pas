{
Here's a solution! I'm using Borland Pascal 7.0 and MS-DOS, so see the
comments to adjust it to other compilers and platforms (especially the
Assembly language part...)

The code may be cut/copied and pasted anywhere you like it. No royalty is
needed. (I can't believe I said that, but it's true!)

Save the code as PUZZLE.PAS and create your own dictionary file as WORDS.DIC
in the current directory. A sample WORDS.DIC (generated from my big
WORDS.DIC using PUZZLE SHIFTED) is also given. Note that PUZZLE.PAS is
case-insensitive, you can use upper/lowercase. Every word should be on its
own line and must not have spaces in it. Sorting is optional, the output
depends on the order found in the file.

After you save PUZZLE.PAS and the sample WORDS.DIC, try PUZZLE SHIFT to get
13 words.

I have a big WORDS.DIC containing approximately 91,529 words. It is 979,045
bytes. PKZIP -ex produces a 251,926 bytes ZIP file. UUENCODE-ing the ZIP
file gives 6 files totaling 353,616 bytes. Anyone interested in it may mail
me. Note: The file was not created by me, although I was the one who sorted
it. I'm sure I found it somewhere on the net, but I forgot where exactly it was.

START OF WORDS.DIC [420 bytes under MS-DOS, CRLF pair is used]
deft
dei
deist
des
die
dies
diet
diets
dif
dis
dish
dite
edit
edith
edits
edt
eft
efts
est
fed
feds
fetid
fetish
fid
fie
fish
fished
fist
fisted
fit
fits
heft
hefts
heist
hid
hide
hides
hie
hied
hies
his
hist
hit
hits
ides
set
she
shed
shied
shift
shifted
sid
side
sift
sifted
sit
site
sited
std
stied
ted
the
thief
this
tide
tides
tie
tied
ties
tis
END OF WORDS.DIC

START OF PUZZLE.PAS [2,913 bytes under MS-DOS, CRLF pair is used]
{ If you aren't using Borland Pascal 7.0 and MS-DOS, try using just $I-. }

{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y-}
{$M 1024,0,0}

Program Puzzle;

Var
    F : Text;
    S, W : String;
    I : LongInt;

{ If you aren't using Borland Pascal 7.0 and MS-DOS try this instead:

Function StrLwr(S : String) : String;
Var
    I : Byte;
Begin
    For I := 1 To Length(S) Do
        If (S[I] >= 'A') And (S[I] <= 'Z') Then
            Inc(S[I], $20);
    StrLwr := S
End;

StrLwr(S) returns S in all lowercase.
}

Function StrLwr(Const S : String) : String; Assembler;
Asm
    PUSH DS
    LDS SI, S
    LES DI, @Result
    CLD
    LODSB
    STOSB
    XCHG CX, AX
    MOV CH, 0
    JCXZ @3
@1: LODSB
    CMP AL, 'A'
    JB @2
    CMP AL, 'Z'
    JA @2
    OR AL, 20H
@2: STOSB
    LOOP @1
@3: POP DS
End;

{ If you aren't using Borland Pascal 7.0 change the function header to:

    Function IsSolution(S, W : String) : Boolean;

(Borland Pascal 7.0 tip:)
Using Const on String arguments saves stack space and disables modifying the
String. (To modify Const S : String you use String((@S)^) in place of S.)

  S is the list of legal characters.
  W is a legal word from the dictionary file.

IsSolution(S, W) returns True if W can be formed from the letters in S.

This time S may have unused letters. If must use all letters from S change:
    IsSolution := True
(last line of function) to:
    IsSolution := S[0] = #0
or:
    IsSolution := S = ''
(The former is faster, the latter is simpler.)
}

Function IsSolution(S : String; Const W : String) : Boolean;
Var
    I, J : Byte;
Begin
    IsSolution := False;
    For I := 1 To Length(W) Do Begin
        J := Pos(W[I], S);
        If J = 0 Then Exit;
        Delete(S, J, 1)
    End;
    IsSolution := True
End;

{ The main block. }

Begin
    If ParamCount <> 1 Then Begin
        WriteLn('PUZZLE - Idea from Campbell Basset <vr@aztec.co.za>');
        WriteLn('Created by Andy Kurnia <akur@indo.net.id> in 1996');
        WriteLn;
        WriteLn('Syntax:   PUZZLE listofletters');
        WriteLn('Argument: case-insensitive, example allows max. two E');
        WriteLn('Example:  PUZZLE RSTLNEfghiev');
        WriteLn('Requires: WORDS.DIC (text file containing words)');
        Halt(1)
    End;
    Assign(F, 'WORDS.DIC');
    Reset(F);
    If IOResult <> 0 Then Begin
        WriteLn('WORDS.DIC not found!');
        Halt(2)
    End;
    S := StrLwr(ParamStr(1));
    I := 0;
    While Not EOF(F) Do Begin
        ReadLn(F, W);
        If IsSolution(S, StrLwr(W)) Then Begin
            Inc(I);
            WriteLn(I : 10, '. ', W)
        End
    End;
    Close(F);
    If I = 0 Then
        WriteLn('No words found.')
    Else If I = 1 Then
        WriteLn('1 word found.')
    Else
        WriteLn(I, ' words found.')
End.
