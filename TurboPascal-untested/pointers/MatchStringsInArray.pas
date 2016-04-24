(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0023.PAS
  Description: Match Strings in Array
  Author: MARK GAUTHIER
  Date: 08-24-94  13:58
*)


{* Stack Research string for turbo pascal unit *}
{* Public Domain, 21/07/94 by Mark Gauthier.   *}
{* Fidonet 1:242/818.5, FM 101:190/805.5       *}

Unit Search;

{ What for?, it use stack function to search for a matching string
  in an array. }

Interface

Const

        MaxString : Word = 4096;
        MaxStack  : Word = 500;

Var
        StrAddr         : Array[1..4096] of Pointer;
        { Addresse for all strings. }

        TotalStr        : Word;
        { Curent strings number }

        StrFreq         : Array[1..4096] of Word;
        { Search frequence for each string }

        procedure ClearAllStack;
        { Clear stack.  You must call this procedure to tell unit
          you will change the searchstring. }

        procedure AddString (S:String);
        { Add a string in array, only if totalstr if < maxstring. }

        function  SearchString (S:String) : boolean;
        { Search for a string, if stack is not clear previous search as
          been made. Example: you search for 'ABC' and this function
          return true.  If you search for 'ABCD' then this function
          will go in stack and get all the old addr for 'ABC' and see
          if 'D' is the next letter for the check strings.

          * This unit is usefull to build compression unit.
        }

implementation

Var
        SearchStr       : Pointer;
        LastFound       : Word;
        CurentStack     : Byte;
        StackPos        : Array[1..2] of Word;
        StackData       : Array[1..2,1..500] of Word;

{*===================================================================*}

{ Return true is stack is empty }
function StackIsEmpty:boolean;
begin
     StackIsEmpty := false;
     if StackPos[CurentStack] = 0 then StackIsEmpty := true;
end;

{*===================================================================*}

{ Pop an element from stack }
function MgPop:Word;
begin
     MgPop := 0;
     If Not StackIsEmpty then
     begin
          MgPop := StackData[CurentStack, StackPos[CurentStack]];
          Dec(StackPos[CurentStack]);
     end;
end;

{*===================================================================*}

{ Push an element on stack }
procedure MgPush(Number:word);
var x:byte;
begin
     if CurentStack = 1 then x := 2 else x := 1;
     If StackPos[x] < MaxStack then
     begin
          Inc(StackPos[x]);
          StackData[x, StackPos[x]] := Number;
     end;
end;

{*===================================================================*}

{ Clear the curent stack }
procedure ClearStack;
begin
     StackPos[CurentStack] := 0;
end;

{*===================================================================*}

{ Inverse pop and push stack }
procedure InverseStack;
begin
     ClearStack;
     If CurentStack = 1 then CurentStack := 2 else CurentStack := 1;
end;

{*===================================================================*}

{ Compare SearchStr(global var) and DATA(parameter) }
{$F+}
function Compare(Data:Pointer):boolean;assembler;
asm
          push      bp
          mov       bp,sp

          push      ds

          lds       si,SearchStr
          lodsb
          mov       cl,al
          mov       ch,0

          les       di,[Bp+8]
          inc       di

          mov       al,0
          cld
          repe      cmpsb
          jne       @NotMatch
          mov       al,1

@NotMatch:

          pop       ds
          pop       bp
end;
{$F-}

{*===================================================================*}

{ Search procedure execute this procedure if stack is not empty. }
function SearchWhitPop:boolean;
Var Start : Word;
begin
     SearchWhitPop := false;
     While not StackIsEmpty do
     begin
          Start := MgPop;
          if Compare(StrAddr[Start]) then
          begin
                LastFound := Start;
                SearchWhitPop := true;
                MgPush(Start);
                Inc(StrFreq[Start]);
          end;
     end;
     InverseStack;
end;

{*===================================================================*}

{ Search procedure execute this procedure if stack is empty. }
function CompleteSearchPush:boolean;
var i : word;
begin
     CompleteSearchPush := false;
     For i := 1 to TotalStr do
     begin
          if Compare(StrAddr[i]) then
          begin
                LastFound := i;
                CompleteSearchPush := true;
                MgPush(i);
                Inc(StrFreq[i]);
          end;
     end;
     InverseStack;
end;

{*===================================================================*}

{ Public Search routine }
function SearchString(S:String):boolean;
begin
     SearchStr := Addr(S);
     If StackIsEmpty
     then SearchString := CompleteSearchPush
     else SearchString := SearchWhitPop;
end;

{*===================================================================*}

{ Add a string in heap }
procedure AddString(S:String);
begin
     Inc(TotalStr);
     GetMem(StrAddr[TotalStr], Length(S));
     Move(S,StrAddr[TotalStr]^, Length(S)+1);
end;

{*===================================================================*}

{ Clear pop and push stack }
procedure ClearAllStack;
begin
     InverseStack;
     ClearStack;
end;

{*===================================================================*}

{ Unit Initialisation }
var i : word;
Begin
     TotalStr    := 0;
     CurentStack := 0;
     StackPos[1] := 0;
     StackPos[2] := 0;
     for i := 1 to 4096 do StrFreq[i] := 0;
End.

