(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0093.PAS
  Description: Get Run-time addr of virtual methods
  Author: EGOR EGOROV
  Date: 05-31-96  09:17
*)


PROGRAM Tst_VMT;

Type   TAObject = object
                   constructor Init;
                   procedure   MethodA; virtual;
                   procedure   MethodB; virtual;
                  end;
Type   TBObject = object(TAObject)
                   procedure   MethodA; virtual;
                  end;

Var    MethodAOffsetInVMT,
       MethodBOffsetInVMT  : integer;
       ItIsAObject         : TAObject;
       ItIsBObject         : TBObject;

{--- TAObject -------------------------------------------------------}

Constructor TAObject.Init;

Begin
End;

{--------------------------------------------------------------------}

Procedure TAObject.MethodA;

Begin
    Writeln('It is method A !!!');
End;

{--------------------------------------------------------------------}

Procedure TAObject.MethodB;

Begin
    Writeln('It is method B !!!');
End;

{--- TAObject -------------------------------------------------------}

Procedure TBObject.MethodA;

Begin
    Writeln('It is method A (some changed) !!!');
End;

{--------------------------------------------------------------------}

Function GetOffsetInVMT(VMTAddr : pointer; MethodAddr : pointer): integer;

Type   TAddrRec       = record  Offs,Segm : word  end;

Const  VMTHeaderSize  = 8;     { This is a size of VMT header     }
       MaxMethodsOffs = 100 * SizeOf(pointer) + VMTHeaderSize;
                       { Maximal offset of method in VMT (abstract) }

Var    VMTOffs        : word;
       CurAddr        : ^pointer;

Begin
    VMTOffs := VMTHeaderSize;
    While (VMTOffs < MaxMethodsOffs) and
          (pointer( Ptr(TAddrRec(VMTAddr).Segm,
                        TAddrRec(VMTAddr).Offs + VMTOffs)^
                  ) <> MethodAddr) do
     Inc(VMTOffs, SizeOf(pointer));
    If VMTOffs >= MaxMethodsOffs
     then  GetOffsetInVMT := 0   { Damn, there is no such method! }
     else  GetOffsetInVMT := VMTOffs;
End;

{--------------------------------------------------------------------}

Begin
    ItIsAObject.Init;
    ItIsBObject.Init;
    ItIsAObject.MethodA;
    ItIsAObject.MethodB;
    MethodAOffsetInVMT := GetOffsetInVMT(TypeOf(TAObject),
                                         @TAObject.MethodA);
    MethodBOffsetInVMT := GetOffsetInVMT(TypeOf(TAObject),
                                         @TAObject.MethodB);
    Writeln(MethodAOffsetInVMT);
    Writeln(MethodBOffsetInVMT);

    { --- Let's call TBObject.MethodA  }
    asm
      mov  di,offset ItIsBObject
      push ds              { Pushing @Self for object in stack }
      push di
      mov  di,[di]         { VMT offset in data segment }
      add  di,[MethodAOffsetInVMT]  { Adding method offset in VMT }
      call dword ptr [di]
    end;
End.


