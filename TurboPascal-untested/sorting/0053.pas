Unit sorter;
{┌──────────────────────────────────────────────────────────────────────────┐
 │ This unit provides a tool for sorting arrays                             │
 │ The array may be of any data type! all you have to do is to provide      │
 │ a 'key function' by which the array elements are compared                │
 │ such key functions are provided for the standard data types              │
 │ You may write your own key functions in order to sort complex data types │
 │ such as records, to reverse the sort order or to create multipile sort   │
 │ keys for record elements.                                                │
 │ Note: the key function must be compiled with $F+ (far calls on)          │
 ├──────────────────────────────────────────────────────────────────────────┤
 │ Written by: Erez Amir CompuServe ID: 100274,701    Fax. (+9723)517-1077  │
 │ May be used freely, as long as this notice is kept!                      │
 ├──────────────────────────────────────────────────────────────────────────┤
 │           M O D I F I C A T I O N    H I S T O R Y                       │
 │                                                                          │
 │ Ver   Date        By             what                                    │
 │ ---   ------      -------------- -------------------------------         │
 │ 1.0   Sep-94      Erez Amir      Written, Debugged                       │
 │ Add your update details here...                                          │
 │                                                                          │
 ├──────────────────────────────────────────────────────────────────────────┤
 │ Examples:                                                                │
 │    /* Simple char array */                                               │
 │    Var a:array[1..m] of char                                             │
 │ ->   Sort(a,n,SizeOf(a[1]),CharComp);                                    │
 │                                                                          │
 │    Type MyRec=Record Month,Day:integer end;                              │
 │         MyRecPtr=^MyRec;                                                 │
 │    Var MyArray: array[1..100] of MyRec;                                  │
 │    /* have to write your oun key */                                      │
 │     Function MyComp(p1,p2:Pointer):Boolean;                              │
 │       Var                                                                │
 │         v1:MyRecPtr absolute p1;                                         │
 │         v2:MyRecPtr absolute p2;                                         │
 │       Begin                                                              │
 │         MyComp:=(V1^.Month>V2^.Month) or                                 │
 │                 (V1^.Month=V2^.Month) and (V1^.Day=V2^.day);             │
 │       End;                                                               │
 │ ->   Sort(MyArray,100,SizeOf(MyRec),MyComp);                             │
 └──────────────────────────────────────────────────────────────────────────┘}
Interface
Type
  CompFunc=Function(V1,V2:Pointer):Boolean;

Procedure Sort(Var Struct;      { array of any Type }
               Num,             { Number of elements }
               Size:Integer;    { Size of each element ( byte ) }
               Comp:CompFunc);

{ Basic type compare functions }
Function IntComp(I1,I2:Pointer):Boolean;   far;
Function RealComp(r1,r2:Pointer):Boolean;  far;
Function ByteComp(b1,b2:Pointer):Boolean;  far;
Function CharComp(c1,c2:Pointer):Boolean;  far;
Function StringComp(s1,s2:Pointer):Boolean;far;

Implementation

Procedure Sort{...};

  var
    Temp:Pointer;
    StructBase:Array[0..0] of Byte Absolute Struct;

  Function VLoc(n:integer):Pointer;
    { Note that no range check is performed! }
    Begin
      {$R-}
      VLoc:=Addr(structBase[n*Size]);
      {$R+}
    End;

  Procedure Swap(n1,n2:Integer);
    { swap two elements }
    Begin
      Move(VLoc(n1)^,Temp^,Size);
      Move(VLoc(n2)^,VLoc(n1)^,Size);
      Move(Temp^,VLoc(n2)^,Size);
    End;

  { Quick sort routine }
  Procedure Qsort(l,r:Integer);
    Var
      i,j:Integer;
      Pivot:Pointer;
    Begin
      i:=l;
      j:=r;
      GetMem(Pivot,Size);  { Hopefully, the midpoint}
      Move(Vloc((L+r) div 2)^,Pivot^,Size);
      Repeat
        while Comp(Pivot,Vloc(i)) do inc(i);
        while Comp(Vloc(J),pivot) do Dec(j);
        if i<=j then
          Begin
            Swap(i,j);
            Inc(i);
            Dec(j);
          End;
      until i>j;
      if j>l then Qsort(l,j); { recoursive call }
      if i<r then Qsort(i,r);
      FreeMem(Pivot,Size);
    End;
  begin
    GetMem(Temp,Size);   { Temp is used for swap }
    if num>1 then
      Qsort(0,Num-1);
    FreeMem(Temp,Size);
  end;

Function IntComp(I1,I2:Pointer):Boolean;
  Type
    IntPtr=^Integer;
  Var
    v1:IntPtr absolute I1;
    v2:IntPtr absolute I2;
  Begin
    IntComp:=V1^>V2^;
  End;
Function RealComp(r1,r2:Pointer):Boolean;
  Type
    RealPtr=^Real;
  Var
    v1:RealPtr absolute r1;
    v2:RealPtr absolute r2;
  Begin
    RealComp:=V1^>V2^;
  End;
Function ByteComp(b1,b2:Pointer):Boolean;
  Type
    BytePtr=^Byte;
  Var
    v1:BytePtr absolute b1;
    v2:BytePtr absolute b2;
  Begin
    ByteComp:=V1^>V2^;
  End;
Function CharComp(c1,c2:Pointer):Boolean;
  Begin
    CharComp:=ByteComp(c1,c2); { Byte and char are the same! }
  End;
Function StringComp(s1,s2:Pointer):Boolean;
  Type
    StringPtr=^String;
  Var
    v1:StringPtr absolute s1;
    v2:StringPtr absolute s2;
  Begin
    StringComp:=V1^>V2^;
  End;

end.