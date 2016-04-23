{
You could easily add a doubble precision to the object HugeMatrix in my unit
Huge, which handles arrays larger than 64 KB.
From: perivar@ibg.uit.no (Per Ivar Steinsund)
}

Unit Huge;

(***********************************************)
(* Unit for making dynamic arrays and matrix.  *)
(* The elementsize has a limit of 64 kB, but   *)
(* the total size of each array/matrix is only *)
(* limited by available memory.                *)
(*                                             *)
(* Per Ivar Steinsund (1994)                   *)
(*                                             *)
(* Example of use:                             *)
(*                                             *)
(* var J:longint;                              *)
(*     Arr:PHugeRealArray;                     *)
(*                                             *)
(* begin                                       *)
(*    Arr:=new(PHugeRealArray,Init(0,200000,   *)
(*             SizeOf(Real),true));            *)
(*    if Arr^.Data<>nil then                   *)
(*       for J:=0 to 200000 do Arr^.I(J)^:=J/5;*)
(*    Arr^.Done;                               *)
(* end;                                        *)
(*                                             *)
(***********************************************)

interface

uses  Objects,WinAPI,OMemory,WinTypes;

Const
    SegSize=$FFFF;

Type
    Adr=record
       Off,Seg:Word;
    end;

    PHugeArray=^THugeArray;
    THugeArray=Object(TObject)
       Data:Pointer;
       MinX,MaxX:LongInt;
       ElementSize,ElementsPerSeg:LongInt;
       constructor Init(Min,Max:LongInt; Size:Word; Message:boolean);
       function ChangeSize(Min,Max:LongInt; Message:boolean):boolean;
       function I(X:LongInt):Pointer;
       destructor done; virtual;
       procedure GrabMem(var NewData:Pointer; Range:LongInt;
Change,Message:boolean);
       function GetPtr(Pos:LongInt):Pointer;
    end;

    PReal=^Real;

    PHugeRealArray=^THugeRealArray;
    THugeRealArray=Object(THugeArray)
       function I(X:LongInt):PReal;
    end;

    PHugeMatrix=^THugeMatrix;
    THugeMatrix=Object(THugeArray)
       MinY,MaxY,RangeY:LongInt;
       constructor Init(Min1,Max1,Min2,Max2:LongInt; Size:Word;
Message:boolean);
       function ChangeSize(Min1,Max1,Min2,Max2:LongInt;
Message:boolean):boolean;
       function I(X,Y:LongInt):Pointer;
    end;

    PHugeWordMatrix=^THugeWordMatrix;
    THugeWordMatrix=Object(THugeMatrix)
       function I(X,Y:LongInt):PWord;
    end;

implementation

    constructor THugeArray.Init(Min,Max:LongInt; Size:Word; Message:boolean);

    begin
       MinX:=Min;
       MaxX:=Max;
       ElementSize:=Size;
       GrabMem(Data,MaxX-MinX+1,false,Message);
    end;

    destructor THugeArray.done;

    begin
       GlobalFreePtr(Data);
    end;

    function THugeArray.I(X:LongInt):Pointer;

    begin
       I:=GetPtr(X-MinX);
{$IFOPT R+}
       if (X<MinX) or (X>MaxX) then
          if id_No=MessageBox(0,'Error in huge array, continue?','Index out of
range!',
                              mb_YesNo or mb_IconQuestion) then
          begin
             Done;
             Halt;
          end;
{$ENDIF}
    end;

    function THugeArray.ChangeSize(Min,Max:LongInt; Message:boolean):boolean;

    var NewData:Pointer;

    begin
       MinX:=Min;
       MaxX:=Max;
       GrabMem(NewData,MaxX-MinX+1,true,Message);
       if NewData<>nil then
       begin
          ChangeSize:=true;
          Data:=NewData;
       end
       else ChangeSize:=false;
    end;

    procedure THugeArray.GrabMem(var NewData:Pointer; Range:LongInt;
Change,Message:boolean);

    var MemSize:LongInt;

    begin
       MemSize:=Range*ElementSize;
       if not Change then ElementsPerSeg:=SegSize div ElementSize;
       if (MemSize>SegSize) and (SegSize mod ElementSize<>0) then
          MemSize:=(Range div ElementsPerSeg)*SegSize+ElementSize*(Range mod
ElementsPerSeg);
       if Change then NewData:=GlobalReAllocPtr(Data,MemSize,Gmem_Moveable or
Gmem_NoDiscard)
                 else NewData:=GlobalAllocPtr(Gmem_Moveable or
Gmem_NoDiscard,MemSize);
       if (NewData=nil) and Message then
          MessageBox(0,'It is not possible to allocate enough memory.',
                     'Error',mb_OK or mb_IconInformation);
    end;

    function THugeArray.GetPtr(Pos:LongInt):Pointer;

    begin
       GetPtr:=Ptr(Adr(Data).Seg+(Pos div ElementsPerSeg)*SelectorInc,
                   Adr(Data).Off+(Pos mod ElementsPerSeg)*ElementSize);
    end;

    function THugeRealArray.I(X:LongInt):PReal;

    begin
       I:=inherited I(X);
    end;

    constructor THugeMatrix.Init(Min1,Max1,Min2,Max2:LongInt; Size:Word;
Message:boolean);

    begin
       MinX:=Min1;
       MaxX:=Max1;
       MinY:=Min2;
       MaxY:=Max2;
       RangeY:=1+MaxY-MinY;
       ElementSize:=Size;
       GrabMem(Data,(MaxX-MinX+1)*(MaxY-MinY+1),false,Message);
    end;

    function THugeMatrix.ChangeSize(Min1,Max1,Min2,Max2:LongInt;
Message:boolean):boolean;

    var NewData:Pointer;

    begin
       MinX:=Min1;
       MaxX:=Max1;
       MinY:=Min2;
       MaxY:=Max2;
       RangeY:=1+MaxY-MinY;
       GrabMem(NewData,(MaxX-MinX+1)*(MaxY-MinY+1),true,Message);
       if NewData<>nil then
       begin
          ChangeSize:=true;
          Data:=NewData;
       end
       else ChangeSize:=false;
    end;

    function THugeMatrix.I(X,Y:LongInt):Pointer;

    begin
       I:=GetPtr(Y-MinY+RangeY*(X-MinX));
{$IFOPT R+}
       if (X<MinX) or (X>MaxX) or (Y<MinY) or (Y>MaxY) then
          if id_No=MessageBox(0,'Error in huge matrix, continue?','Index out of
range!',
                              mb_YesNo or mb_IconQuestion) then
          begin
             Done;
             Halt;
          end;
{$ENDIF}
    end;

    function THugeWordMatrix.I(X,Y:LongInt):PWord;

    begin
       I:=inherited I(X,Y);
    end;

end.

