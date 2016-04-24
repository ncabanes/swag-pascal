(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0064.PAS
  Description: Text files in pascal.
  Author: ITAI HANDLER
  Date: 11-22-95  13:27
*)


{ unit for reading text files up to 512K very quickly! }
{ Do whatever you like to this code, but please credit me somehow! }
{ by Itai Handler, FidoNet 2:406/120. }

Unit FastText;

Interface

const
  Text_Eof : Boolean = true;
  NoMem    : Boolean = false;

Function  Text_Load (FN:String):Boolean;  { init memory and read the file }
Procedure Text_ReadLine (var S:String);   { get line from text }
Procedure Text_GoBack (L:Word);           { updates pointer to L lines back }
Function  Text_Lines:LongInt;             { calculate how many lines in file }
Procedure Text_Reset;                     { reset file & seek to start }
Procedure Text_Dispose;                   { free memory }

Implementation

Type
  BufType=Array[1..64000] of char;

Const
  PUsed:Byte=0;                         { # of pointers currently in use }

Var
  P:Array[1..8] of ^BufType;            { array of 8 pointers (512kb) }
  TextSize:LongInt;                     { size of the text file in bytes }
  PSeek:LongInt;
  PCur:LongInt;

Function Text_Load (FN:String):Boolean; { init memory and read the file }
  Var
    FB:File of Byte;
    NumRead:Word;
    F:File;
    B:LongInt;
    FM:Byte;
    Tmp:LongInt;

  Begin
    FM:=FileMode;
    filemode:=64;
    Text_Load:=false;
    NoMem:=false;
    Assign(fb, FN);
    Reset(fb);
    TextSize:=FileSize(fb);
    Close(Fb);
    If MaxAvail>=TextSize then
      Begin
        Text_Load:=true;
        For B:=1 to 8 do if TextSize > (( Pred(B) )*64000) then
          Begin
            If B*64000>TextSize then Tmp:=(TextSize mod 64000) else
              Tmp:=64000;
            GetMem(P[B],Tmp);
            Inc(PUsed);
          End;
        Assign(f, FN);
        Reset(f,1);
        For B:=1 to PUsed do
          Begin
            If B*64000>TextSize then Tmp:=(TextSize mod 64000) else
              Tmp:=64000;
            BlockRead(F,P[B]^,Tmp,NumRead);
            {If NumRead<>Tmp then Text_Load:=false;}
          End;
        Close(F);
      End else NoMem:=true;
    FileMode:=FM;
  PSeek:=1;
  PCur:=1;
  Text_Eof:=false;
  End;

Procedure Text_ReadLine (var S:String); { get line from text }
  Var
    W:Word;
    B:LongInt;
    TS:String;
    Tmp:LongInt;
  Begin
  TS:='';
    If Not Text_Eof then
      Begin
      While (PUsed>=PCur) and (Length(TS)<=255) and
       (P[PCur]^[PSeek]<>#13) {and (P[PCur]^[PSeek]<>#10)} do
          Begin
            TS:=TS+P[PCur]^[PSeek];
            Inc(PSeek);
            If (PSeek>64000) and (PCur<8) then
              Begin
                PSeek:=1;
                Inc(PCur);
              End;
          End;
      If (P[PCur]^[PSeek]=#13) and (PUsed>=PCur) then
          begin
            Inc(PSeek,2);
            If (PSeek>64000) and (PCur<8) then
              Begin
                PSeek:=1;
                Inc(PCur);
              End;
          end;
      If (PCur>PUsed) or (Pred(PCur)*64000+PSeek>TextSize) then
        Text_Eof:=true;
    End;
  S:=TS;
  End;

Procedure Text_GoBack (L:Word);
Var
  Cnt  : Word;
Begin
  Cnt:=L;
  If Cnt>0 then
  Begin
    If PSeek>2 then Dec(PSeek,2) else
      If PCur>1 then Begin Dec(PCur); PSeek:=64000-PSeek+1; End;
    Repeat
      Dec(Cnt);
         Repeat
           If PSeek>0 then Dec(PSeek);
           If (PSeek=0) and (PCur>1) then
             Begin
               PSeek:=64000;
               Dec(PCur);
             End;
           If PSeek=0 then PSeek:=1;
         Until ((PSeek=1) and (PCur=1)) or (P[PCur]^[PSeek]=#13)
    Until Cnt=0;
    If not ((PSeek=1) and (PCur=1)) Then Inc(PSeek,2);
    If PSeek>64000 then PSeek:=PSeek-64000;
  End;
  Text_Eof:=false;
End;

Function Text_Lines:LongInt;
(* Asm procedure was made by Arie Vayner on the 9/2/95 *)
  Var
    W:Word;
    B:LongInt;
    L:Word;
    Tmp:Word;
    O:Word;
    S:Word;
  Begin
    L:=1;
    For B:=1 to PUsed do
      Begin
        If B*64000>TextSize then Tmp:=(TextSize mod 64000) else
          Tmp:=64000;
        O:=Ofs(P[B]^);
        S:=Seg(P[B]^);
        Asm
          Push DS
          Mov DS,S
          XOR DX,DX
          MOV CX,TMP
          MOV SI,O
          CLD
        @MAINLOOP:
          LODSB
          CMP AL,10
          JE @FOUND_ONE
          LOOP @MAINLOOP
          JMP @EXITLOOP
        @FOUND_ONE:
          INC DX
          LOOP @MAINLOOP
        @EXITLOOP:
          MOV AX,DX
          MOV TMP,AX
          POP DS
        END;
        Inc(L,TMP);
      End;
    Text_Lines:=L;
  End;

Procedure Text_Reset;                   { reset file & seek to start }
Begin
  Text_Eof:=false;
  PCur:=1;
  PSeek:=1;
End;

Procedure Text_Dispose;                 { free memory }
  Var
    B:LongInt;
    Tmp:LongInt;
  Begin
    For B:=1 to PUsed do if TextSize > (B*64000) then
      Begin
        If B*64000>TextSize then Tmp:=(TextSize mod 64000) else
          Tmp:=64000;
        FreeMem(P[B],Tmp);
      End;
    PUsed:=0;
  End;
End.

