{
> In a program I am writing I need to create a very large array to store
> infomation in I need an array[1..4096] of string and turbo pascal will

Try my unit. My unit uses a TEMSStream to store the information.
Look at the demo how to store your 4096 strings.
}

(* Unit LongArray - large arrays in EMS
   PUBLIC DOMAIN  1993 by Holger Daehre 2:248/317.88
   Running: TP 6.0 or above. *)

Unit LongArr;

Interface

Uses  Objects;

Var
   Lo_element,ElementSize:LongInt;

(* Create_Array creates  Array[Low..High] of Size *)
Procedure Create_Array(Var ps:pStream;Low,High,Size:LongInt);

(* Read_Array loads one element from INDEX into Buf *)
Procedure Read_Array(Var ps:pStream;Index:LongInt;Var Buf);

(* Write_Array stores the information of Buf in Index *)
Procedure Write_Array(Var ps:pStream;Index:LongInt;Var Buf);

(* Dispose_Array releases the allocated EMS memory *)
Procedure Dispose_Array(Var ps:pStream);

Implementation

Procedure Create_Array(Var ps:pStream;Low,High,Size:LongInt);
Var
   Elements,ArraySize:LongInt;
Begin
   Lo_element:=Low;
   Elements:=High-Low+1;
   ArraySize:=Elements * Size;
   ElementSize:=Size;
   ps := New(pEMSStream, Init(ArraySize,ArraySize));
   If ps^.status <> stOk Then
    Begin
      Dispose(ps, Done);
      ps := NIL;
    End;
End;

Procedure Read_Array(Var ps:pStream;Index:LongInt;Var Buf);
Begin
 If ps<>nil Then
 Begin
  ps^.Seek((Index-Lo_element)*ElementSize);
  ps^.Read(Buf,ElementSize);
 End;
End;

Procedure Write_Array(Var ps:pStream;Index:LongInt;Var Buf);
Begin
 If ps<>nil Then
 Begin
  ps^.Seek((Index-Lo_element)*ElementSize);
  ps^.Write(Buf,ElementSize);
 End;
End;

procedure Dispose_Array(Var ps:pStream);
Begin
 Dispose(ps,Done);
 ps:=NIL;
End;

End.




Program LongArrayDemo;
Uses Objects,LongArr;
Var MyArr:PStream;
    S:String;
    I:Word;
Begin
  Create_Array(MyArr,0,4096,SizeOf(String));
  If MyArr=nil Then
  Begin
   WriteLn('Couldn''t create array in EMS');
   Halt;
  End;
  S:='This is a TEST !';
  For I:=0 To 4096 Do  Write_Array(MyArr,I,S);
  s:='';
  Randomize;
  Read_Array(MyArr,Random(4096),S);
  WriteLn(S);
  Dispose_Array(MyArr);
End.
