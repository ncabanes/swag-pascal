(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0018.PAS
  Description: STROBJ.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

Program KenTest;
{ a short program to check out collecting TObject Descendents, as
  opposed to binding data types directly to a collection object}

Uses Objects;
Type
    PBaseData = ^BaseData;
     BaseData = Object(TObject)
                   name : PString;
                   DType: Word;
                   Data : Pointer;
                   Constructor Init(AName:String;Var AData);
                   Procedure PutData(Var S:TStream); virtual;
                   Function GetData(Var S:TStream):Pointer; virtual;
                   Procedure SetData(Var ADAta); virtual;
                   Constructor Load(Var S:TStream);
                   Procedure Store(Var S:TStream); virtual;
                   Destructor Done; virtual;
                 end;
Constructor BaseData.Init(AName:String;Var AData);
   Begin
     Name := NewStr(Aname);
     Data := Nil;
     SetData(AData);
   End;
Constructor BaseData.Load(Var S:TStream);
   Begin
     Name := S.ReadStr;
     S.Read(DType,2);
     Data := GetData(S);
   End;
Procedure BaseData.SetData(Var AData);
   Begin
     DType := 0;
   End;
Procedure BaseData.Store(Var S:TStream);
   Begin
     S.WriteStr(Name);
     S.Write(DType,2);
     PutData(S);
   End;
Function BaseData.GetData(Var S:TStream):Pointer;
   Begin
     GetData := Nil;
   End;
Procedure BaseData.PutData(Var S:TStream);
   Begin
   End;
Destructor BaseData.Done;
  Begin
    DisposeStr(Name);
  End;

Type
   PStrData = ^StrData;
   StrData = Object(BaseData)
                   Procedure PutData(Var S:TStream); virtual;
                   Function GetData(Var S:TStream):Pointer; virtual;
                   Procedure SetData(Var ADAta); virtual;
                   Destructor Done; virtual;
                end;
   LongPtr   = ^LongInt;
   PNumData = ^NumData;
   NumData = Object(BaseData)
                   Procedure PutData(Var S:TStream); virtual;
                   Function GetData(Var S:TStream):Pointer; virtual;
                   Procedure SetData(Var ADAta); virtual;
                   Destructor Done; virtual;
                end;

Procedure StrData.PutData(Var S:TStream);
   Begin
     S.WriteStr(PString(Data));
   End;
Function StrData.GetData(Var S:TStream):Pointer;
   Begin
     GetData := S.ReadStr;
   End;
Procedure StrData.SetData(Var AData);
   Var S:String Absolute AData;
   Begin
     Data := NewStr(S);
     DType := 1;
   End;
Destructor StrData.Done;
   Begin
     DisposeStr(PString(Data));
     Inherited Done;
   End;

Procedure NumData.PutData(Var S:TStream);
   Begin
     S.Write(LongPtr(Data)^,SizeOf(LongInt));
   End;
Function NumData.GetData(Var S:TStream):Pointer;
   Var L : LongPtr;
   Begin
     New(L);
     S.Read(L^,SizeOf(LongInt));
     GetData := L;
   End;
Procedure NumData.SetData(Var AData);
   Var L:LongInt Absolute AData;
   Begin
     DType := 2;
     New(LongPtr(Data));
     LongPtr(Data)^ := L;
   End;
Destructor NumData.Done;
   Begin
     Dispose(LongPtr(Data));
     Inherited Done;
   End;

Const
RStrDataRec : TStreamRec = (ObjType : 19561;
                             VMTLink : Ofs(TypeOf(StrData)^);
                             Load    : @StrData.Load;
                             Store   : @StrData.Store);

RNumDataRec : TStreamRec = (ObjType : 19562;
                             VMTLink : Ofs(TypeOf(NumData)^);
                             Load    : @NumData.Load;
                             Store   : @NumData.Store);

Procedure ShowStuff(P:PCollection);
   Procedure ShowName(P:PBaseData); far;
      Begin
        if P^.Name <> Nil
        then Write(P^.Name^,'   ');
        Case P^.DType of
           1 : if PString(P^.Data) <> Nil then Writeln(PString(P^.Data)^);
           2 : writeln(LongPtr(P^.Data)^);
         end;
      end;
   Begin
     P^.ForEach(@ShowName);
   End;

Var
  P : PCollection;
  Ps : PDosStream;
  m : Longint;
  S : String;
  I : LongInt;
Begin
  m := MaxAvail;
  RegisterType(RCollection);
  RegisterType(RStrDataRec);
  RegisterType(RNumDataRec);
  New(P,init(5,5));
  if P <> Nil then
      Begin
        S := 'String data # 1';
        P^.insert(New(PStrData,init('A string data type ',S)));
        S := 'String data # 2';
        P^.insert(New(PStrData,init('A second string data type ',S)));
        I := 1234567;
        P^.Insert(New(PNumData,init('Numeric Data Type',I)));
        S := 'String Data #3';
        P^.Insert(New(PStrData,init('A third string data type ',S)));
        I := 987654;
        P^.Insert(New(PNumData,init('A second Numeric data type ',I)));
        New(Ps,init('Test1.dta',StCreate));
        if Ps <> Nil then
            begin
              P^.Store(Ps^);
              dispose(P,Done);
              Dispose(Ps,Done);
              if maxavail = m then writeln('mem disposed')
                              else writeln('Failed to release memory');
              new(Ps,init('test1.dta',stopenread));
              if Ps <> Nil then
                 Begin
                   New(P,Load(Ps^));
                   dispose(Ps,done);
                   if P <> Nil then showstuff(P);
                   if p <> Nil then dispose(P,done);
                 end;
            end;
     end;
  if maxavail = m then writeln('mem disposed')
                  else writeln('Failed to release memory');
End.

...ken
---
 * Origin: Telos Point of Source. Replied From Saved Mail.  (Max 1:249/201.21)
       
