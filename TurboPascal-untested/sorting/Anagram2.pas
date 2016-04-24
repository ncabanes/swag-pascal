(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0003.PAS
  Description: ANAGRAM2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{ ANAGRAM. --------------------------------------------------------------------
  Raphaël Vanney, 01/93

  Purpose : Reads a list of Words 4 to 10 Characters long from a File
            named 'LIST.#1', outputs a list of anagrams founds in a
            specified format to a File named 'ANAGRAM.RES'.

  Note    : I commented-out the source using a langage, say English, which
            I'm not Really fluent in ; please forgive mistakes.
------------------------------------------------------------------------------}

{$m 8192,65536,655360}
{$a+,d+,e-,f-,g+,i+,l+,n-,o-,q-,r-,s-,v+}

{$b-}     { Turns off complete Boolean evaluation ; this allows easiest
            combined Boolean tests. }

Uses Crt,
     Objects ;

Const
     MaxWordLen     = 10 ;              { Offically specified by GP !      }
     CntAnagrams    : Word = 0 ;        { Actually, this counter shows the }
                                        { number of Words found in the     }
                                        { output File.                     }
     OutFileName    = 'ANAGRAM.RES' ;


Type TWordString    = String[MaxWordLen] ;

     { TWordCollection.
       This Object will be used to store the Words in a sorted fashion. As
       long as the input list is already sorted, it could have inherited
       from TCollection, put there is no big penalty using a sorted one.   }

     TWordCollection =
     Object (TSortedCollection)
          Function  KeyOf(Item : Pointer) : Pointer ; Virtual ;
          Function  Compare(Key1, Key2 : Pointer) : Integer ; Virtual ;
          Procedure FreeItem(Item : Pointer) ; Virtual ;
     end ;
     PWordCollection = ^TWordCollection ;

     { TWord.
       This is the Object we'll use to store a Word. Each Word knows :
       - it's 'Textual form'  : It
       - the first of it's anagrams, if it has been found to be the
         anagram of another Word,
       - the next of it's anagrams, in the same condition.                 }

     PWord     = ^TWord ;
     TWord     =
     Object
          It             : TWordString ;
          FirstAng       : PWord ;
          NextAng        : PWord ;

          Constructor    Init(Var Wrd  : TWordString) ;
          Destructor     Done ;
     end ;

Var  WordsList : PWordCollection ;      { The main list of Words           }
     OrgMem    : LongInt ;              { Original MemAvail                }
     UsedMem   : LongInt ;              { Amount of RAM used               }

{-------------------------------------- TWord --------------------------------}

Constructor TWord.Init ;
begin
     It:=Wrd ;
     FirstAng:=Nil ;
     NextAng:=Nil ;
end ;

Destructor TWord.Done ;
begin
end ;

{-------------------------------------- TWordCollection ----------------------}
{ The following methods are not commented out, since they already are in
  Turbo-Pascal's documentations, and they do nothing unusual.              }

Function TWordCollection.KeyOf ;
begin
     KeyOf:=Addr(PWord(Item)^.It) ;
end ;

Function TWordCollection.Compare ;
Var  k1   : PString Absolute Key1 ;
     k2   : PString Absolute Key2 ;
begin
     If k1^>k2^
     Then Compare:=1
     Else If k1^<k2^
          Then Compare:=-1
          Else Compare:=0 ;
end ;

Procedure TWordCollection.FreeItem ;
begin
     Dispose(PWord(Item), Done) ;
end ;

{-------------------------------------- Utilities ----------------------------}

Procedure CleanUp(Var Wrd : TWordString) ;
{ Cleans-up a Word, in Case there would be dirty Characters in the input File }
Var  i    : Integer ;
begin
     { Removes trailing spaces ; not afraid of empty Strings }
     While Wrd[Length(Wrd)]=' ' Do Dec(Wrd[0]) ;
     { Removes any suspect Character }
     i:=1 ;
     While (i<=Length(Wrd)) Do
     begin
          If Wrd[i]<#33 Then Delete(Wrd, i, 1)
                        Else Inc(i) ;
     end ;
end ;

Function PadStr(St : TWordString ; Len : Integer) : String ;
{ Returns a String padded With spaces, of the specified length }
Var  i    : Integer ;
     Tmp  : String ;
begin
     Tmp:=St ;
     For i:=Length(Tmp)+1 To Len Do Tmp[i]:=' ' ;
     Tmp[0]:=Chr(Len) ;
     PadStr:=Tmp ;
end ;

{-----------------------------------------------------------------------------}

Function AreAnagrams(Var WordA, WordB : TWordString) : Boolean ;
{ Tells whether two Words are anagrams of each other ; assumes the Words
  are 'clean' (No Up/Low Case checking, no dirty Characters...)

  Optimizing hint : Passing parameters by address _greatly_ enhances overall
  speed ; anyway, we'll use a local copy of one of the two, since the used
  algorithms needs to modify one of the two Words.                         }

Assembler ;
Var  WordC     : TWordString ;          { Local copy of WordB              }
Asm
     Push DS                            { Let's save the Data segment...   }
     LDS  SI, WordA                     { Load WordA's address in ES:DI    }
     Mov  AL, [SI]                      { Load length Byte into AL         }
     LDS  SI, WordB                     { Load WordB's address             }
     Cmp  AL, [SI]                      { Compare lengthes                 }
     JNE  @NotAng                       { <>lengthes, not anagrams         }

     LDS  SI, WordB

     { Let's make a local copy of WordB ; enhanced version of TP's "Move"  }
     ClD                                { Clear direction flag             }
     Push SS
     Pop  ES                            { Segment part of WordC's address  }
     LEA  DI, WordC                     { Offset part of it                }
     Mov  CL, DS:[SI]                   { Get length Byte                  }
     XOr  CH, CH                        { Make it a Word                   }
     Mov  DL, CL                        { Save length For later use        }
     Inc  CX                            { # of Bytes to store the String   }
     ShR  CX, 1                         { We'll copy Words ; CF is importt }
     Rep  MovSW                         { Copy WordB to WordC              }
     JNC  @NoByte
     MovSB                              { Copy last Byte                   }
@NoByte:
     LDS  SI, WordA                     { DS:SI contains WordA's address   }
     Inc  SI                            { SI points to first Char of WordA }
     Mov  DH, DL                        { Use DH as a loop counter         }
     LEA  BX, WordC                     { Load offset of WordC in BX       }
     Inc  BX                            { Skip length Byte                 }
     { For each letter in WordA, search it in WordB ; if found, mark it as
       'used' in WordB, then proceed With next.
       If a letter is not found, Words are not anagrams ; if all are
       found, Words are anagrams.                                          }
{ Registers usage :
     AL        : scratch For SCAS
     AH        : unused
     BX        : offset part of WordC's address
     CX        : will be used as a counter For SCAS
     DL        : contains length of Strings ; 'll be used to reset CX
     DH        : loop counter ; initially =DL
     ES        : segment part of WordC's address
     DI        : scratch For SCAS
     DS:SI     : Pointer to next Char to process in WordA
}
@Bcle:
     LodSB                              { Load next Char of WordA in AL    }
     Mov  CL, DL                        { Load length of String in CX      }
     Mov  DI, BX                        { Copy offset of WordC to DI       }
     RepNE ScaSB                        { Scan WordC For AL 'till found    }
     JNE  @NotAng                       { Char not found, not anagrams     }
     Dec  DI                            { Back-up to matching Char         }
     Mov  Byte Ptr ES:[DI], '*'         { Mark the Character as 'used'     }
     Dec  DH                            { Dec loop counter                 }
     Or   DH, DH                        { Done all Chars ?                 }
     JNZ  @Bcle                         { No, loop                         }

     { All Chars done, the Words are anagrams                              }
     Mov  AL, 1                         { Result=True                      }
     Or   AL, AL                        { Set accordingly the ZF           }
     Jmp  @Done
@NotAng:
     XOr  AL, AL                        { Result=False                     }
@Done:
     Pop  DS                            { Restore DS                       }
end ;

Function ReadWordsFrom(FName : String) : Boolean ;
Var  InF  : Text ;                      { Input File                       }
     Buf  : Array[1..2048] Of Byte ;    { Speed-up Text buffer             }
     Lig  : String ;                    { Read line                        }
     Wrd  : String ;                    { Word gotten from parsed Lig      }
     WSt  : TWordString ;               { Checked version of Wrd           }
     p    : Integer ;                   { Work                             }
     Cnt  : LongInt ;                   { Line counter                     }
begin
     ReadWordsFrom:=False ;             { 'till now, at least !            }
     WordsList:=New(PWordCollection, Init(20, 20)) ;
     Assign(InF, FName) ;
     {$i-}
     ReSet(InF) ;
     {$i+}
     If IOResult<>0 Then Exit ;
     SetTextBuf(InF, Buf, SizeOf(Buf)) ;
     Cnt:=0 ;

     While Not EOF(InF) Do
     begin
          Inc(Cnt) ;
          ReadLn(InF, Lig) ;
          While Lig<>'' Do
          begin
               { Let's parse the read line into Words }
               p:=Pos(',', Lig) ;
               If p=0 Then p:=Length(Lig)+1 ;
               Wrd:=Copy(Lig, 1, p-1) ;
               { Check of overflowing Word length }
               If Length(Wrd)>MaxWordLen Then
                    WriteLn('Word length > ', MaxWordLen, ' : ', Wrd) ;
               WSt:=Wrd ;
               CleanUp(WSt) ;
               If WSt<>'' Then WordsList^.Insert(New(PWord, Init(WSt))) ;
               Delete(Lig, 1, p) ;
          end ;
     end ;
     {$i-}
     Close(InF) ;
     {$i+}
     If IOResult<>0 Then ;
     ReadWordsFrom:=True ;

     WriteLn(Cnt, ' lines, ', WordsList^.Count, ' Words found.') ;
end ;

Procedure CheckAnagrams(i : Integer) ;
{ This Procedure builds, if necessary (i.e. not already done), the anagrams
  list For Word #i of the list. }
Var  Org  : PWord ;                     { Original Word (1st of list)      }
     j    : Integer ;                   { Work                             }
     Last : PWord ;                     { Last anagram found               }
begin
     Org:=WordsList^.Items^[i] ;
     If Org^.FirstAng<>Nil Then
     begin
          { This Word is already known to be the anagram of at least another
            one ; don't re-do the job. }
          { _or_ this Word is known to have no anagrams in the list }
          Exit ;
     end ;

     { Search anagrams }
     Last:=Org ;
     Org^.FirstAng:=Org ;               { This Word is the first of it's   }
                                        { own anagrams list ; normal, no ? }
     For j:=Succ(i) To Pred(WordsList^.Count) Do
     { Don't search the begining of the list, of course ! }
     begin
          { Let's skip anagram checking if lengths are <> }
          If Org^.It[0]=PWord(WordsList^.Items^[j])^.It[0] Then
          If AreAnagrams(Org^.It, PWord(WordsList^.Items^[j])^.It) Then
          begin
               { Build chained list of anagrams }
               Last^.NextAng:=WordsList^.Items^[j] ;
               Last:=WordsList^.Items^[j] ;
               Last^.FirstAng:=Org ;
          end ;
     end ;
     Last^.NextAng:=Nil ;               { Unusefull, but keep carefull     }
end ;

Procedure ScanForAnagrams ;
{ This Procedure scans the list of Words For anagrams, and do the outputing
  to the 'ANAGRAM.RES' File. }

Var  i         : Integer ;              { Work                             }
     Tmp       : PWord ;                { Temporary Word                   }
     Out       : Text ;                 { Output File                      }
     Comma     : Boolean ;              { Helps dealing With commas        }
     Current   : PWord ;                { Currently handled Word           }
begin
     Assign(Out, OutFileName) ;
     ReWrite(Out) ;

     With WordsList^ Do
     For i:=0 To Pred(Count) Do
     begin
          Current:=Items^[i] ;
          CheckAnagrams(i) ;
          { We're now gonna scan the chained list of known anagrams for
            this Word. }
          If (Current^.NextAng<>Nil) Or (Current^.FirstAng<>Current) Then
          { This Word has at least an anagram other than itself }
          begin
               Write(Out, PadStr(Current^.It, 12)) ;
               Inc(CntAnagrams) ;
               Comma:=False ;
               Tmp:=Current^.FirstAng ;
               While Tmp<>Nil Do
               begin
                    If Tmp<>Current Then { Don't reWrite it... }
                    begin
                         If Comma Then Write(Out, ', ') ;
                         Comma:=True ;
                         Write(Out, Tmp^.It) ;
                         Inc(CntAnagrams) ;
                    end ;
                    Tmp:=Tmp^.NextAng ;
               end ;
               WriteLn(Out) ;
          end ;
     end ;

     Close(Out) ;
end ;

Var  Tmp       : LongInt ;

begin
  { Check command line parameter }

  If ParamCount<>1 Then
  begin
    WriteLn('Anagram. Raphaël Vanney, 01/93 - Anagram''s contest entry.');
    WriteLn ;
    WriteLn('Anagram <input_File>') ;
    WriteLn ;
    WriteLn('Please specify input File name.') ;
    Halt(1) ;
  end ;

  OrgMem:=MemAvail ;

  { Read Words list from input File }

  If Not ReadWordsFrom(ParamStr(1)) Then
  begin
       WriteLn('Error reading Words from input File.') ;
       Halt(1) ;
  end ;

  { Display statistics stuff }

  WriteLn('Reading and sorting done.') ;
  UsedMem:=OrgMem-MemAvail ;
  WriteLn('Used RAM                       : ', UsedMem, ' Bytes') ;
  Tmp := Trunc(1.0 * MemAvail / (1.0 * UsedMem / WordsList^.Count)) ;
  If Tmp > 16383 Then
    Tmp := 16383 ;
  WriteLn('Potential Words manageable     : ', Tmp) ;

  { Scan For anagrams, create output File }

  ScanForAnagrams ;
  WriteLn('Anagrams scanning & output done.') ;
  WriteLn(CntAnagrams, ' Words written to ', OutFileName) ;

  { Clean-up }
  Dispose(WordsList, Done) ;
end.
{

------------------------------------------------------------------------------

Okay, this is my entry For the 'anagram contest' !

The few things I'd like to point-out about it :

. I chosed to use OOP, in contrast to seeking speed. I wouldn't say my
  Program is Really slow (7.25 secs on my 386-33), but speed was not my
  first concern.
. It fully Uses one of the interresting points of OOP in TP, i.e.
  reusability, through inheritance,
. When a Word (A) has been found to be an anagram of another (B), the
  Program never searches again For the anagrams of (A) ; this
  highly reduces computing time... but I believe anybody does the same.
. I also quite like the assembly langage Function 'AreAnagrams'.

------------------------------------------------------------------------------

The Words list is stored in memory in the following maner :
. A collection (say, a list) of the Words,
. Within this list, anagrams are chained as a list
. Each Word knows the first and the next of its anagrams

------------------------------------------------------------------------------

For the sake of speed, I did something I'm quite ashamed of ; but it
saves 32% of execution time, so...
The usual way to access element #i of a TCollection is to call Function At
with parameter i (i.e. At(i)) ; there is also another way, which is not Really
clean, but which I chosed to use : access it directly through Items^[i].

