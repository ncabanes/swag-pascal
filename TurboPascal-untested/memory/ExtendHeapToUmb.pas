(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0016.PAS
  Description: Extend HEAP to UMB
  Author: GAYLE DAVIS
  Date: 05-29-93  22:25
*)

{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S+,V-,X-}

Unit UMB_Heap;

{----------------------------------------------------------------------------}

interface

  Procedure Extend_Heap;        { Use Upper Memory Blocks (UMB) to extend    }
                                { the Turbo Pascal 6.0 heap.  This procedure }
                                { should be called as soon as possible in    }
                                { your code.                                 }
  var
    UMB_Heap_Debug : Boolean;   { If true, releases UMBs immediately to make }
                                { sure they're available for the next run    }
                                { without rebooting.  Used when debugging in }
                                { the IDE.  If not used then, the UMBs may   }
                                { not get freed between executions.          }

{----------------------------------------------------------------------------}

implementation

const
  Max_Blocks = 4;              { It's not likely more than 4 UMBs are needed }

type
  PFreeRec = ^TFreeRec;      {  From pg. 216 of the TP6 programmer's guide.  }
  TFreeRec = record          {  It's used for traversing the free blocks of  }
    Next : PFreeRec;         {  the heap.                                    }
    Size : Pointer;
  end;

var
  XMS_Driver : Pointer;      {  Pointer to the XMS driver.  }
  Num_Blocks : Word;
  Block_Address,
  Block_Size : Array[1..Max_Blocks+1] of Pointer;
  SaveExitProc : Pointer;

{----------------------------------------------------------------------------}

{  Swap to pointers.  Needed when sorting the UMB addresses.  }

Procedure Pointer_Swap(var A,B : Pointer);
  var
    Temp : Pointer;
  Begin
    Temp := A;
    A := B;
    B := Temp;
  End;

{----------------------------------------------------------------------------}

Function XMS_Driver_Present : Boolean;  { XMS software present? }
  var
    Result : Boolean;
  Begin
    Result := False;      { Assume no XMS driver }
    asm
      @Begin:
        mov ax,4300h
        int 2Fh
        cmp al,80h
        jne @Fail
        mov ax,4310h
        int 2Fh
        mov word ptr XMS_Driver+2,es       { Get the XMS driver entry point }
        mov word ptr XMS_Driver,bx
        mov Result,1
        jmp @End
      @Fail:
        mov Result,0
      @End:
    end;
    XMS_Driver_Present := Result;
  End;

{----------------------------------------------------------------------------}

Procedure Allocate_UMB_Heap;         { Add the four largest UMBs to the heap }
  var
    i,j : Word;
    UMB_Strategy,
    DOS_Strategy,
    Segment,Size : Word;
    Get_Direct : Boolean;   { Get UMB direct from XMS if TRUE, else from DOS }
  Begin
    Num_Blocks := 0;

    for i := 1 to Max_Blocks do
      begin
        Block_Address[i] := nil;
        Block_Size[i] := nil;
      end;

    asm
      mov ax,5800h
      int 21h                     { Get and save the DOS allocation strategy }
      mov [DOS_Strategy],ax
      mov ax,5802h
      int 21h                     { Get and save the UMB allocation strategy }
      mov [UMB_Strategy],ax
      mov ax,5801h
      mov bx,0000h
      int 21h                      { Set the DOS allocation strategy so that }
      mov ax,5803h                 { it uses only high memory                }

                                   { DON'T TRUST THIS FUNCTION.  DOS WILL GO }
                                   { AHEAD AND TRY TO ALLOCATE LOWER MEMORY  }
                                   { EVEN AFTER YOU TELL IT NOT TO!          }
      mov bx,0001h
      int 21h                      { Set the UMB allocation strategy so that }
    end;                           { UMBs are added to the DOS mem chain     }

    Get_Direct := True;            { Try to get UMBs directly from the XMS   }
                                   { if possible.                            }
    for i := 1 to Max_Blocks do
      begin
        Segment := 0;
        Size := 0;

        if Get_Direct then         { Get a UMB direct from the XMS driver.   }
          begin
            asm
              @Begin:
                mov ax,01000h         
                mov dx,0FFFFh         { Ask for the impossible to ...        }
                push ds               { Get the size of the next largest UMB }
                mov cx,ds
                mov es,cx
                call es:[XMS_Driver]
                cmp dx,100h           { Don't bother with anything < 1K      }
                jl @End
                mov ax,01000h
                call es:[XMS_Driver]  { Get the next largest UMB }
                cmp ax,1
                jne @End
                cmp bx,0A000h         { It better be above 640K }
                jl @End               { We can't trust DOS 5.00 }
                mov [Segment],bx
                mov [Size],dx
              @End:
                pop ds
            end;
            if ((i = 1) and (Size = 0)) then  { if we couldn't get the UMB  }
              Get_Direct := False;            { from the XMS driver, don't  }
          end;                                { try again the next time.    }

        if (not Get_Direct) then   { Get a UMB via DOS }
          begin
            asm
              @Begin:
                mov ax,4800h
                mov bx,0FFFFh         { Ask for the impossible to ...        }
                int 21h               { Get the size of the next largest UMB }
                cmp bx,100h           { Don't bother with anything < 1K      }
                jl @End
                mov ax,4800h
                int 21h               { Get the next largest UMB }
                jc @End
                cmp ax,0A000h         { It better be above 640K }
                jl @End               { We can't trust DOS 5.00 }
                mov [Segment],ax
                mov [Size],bx
              @End:
            end;
          end;

        if (Segment > 0) then                      { Did it work? }
          begin
            Block_Address[i] := Ptr(Segment,0);
            Inc(Num_Blocks);
          end;
        Block_Size[i] := Ptr(Size,0);
      end;
    if (Num_Blocks > 0) then               { Sort the UMB addrs in ASC order }
      begin
        for i := 1 to Num_Blocks-1 do
          for j := i+1 to Num_Blocks do
            if (Seg(Block_Address[i]^) > Seg(Block_Address[j]^)) then
              begin
                Pointer_Swap(Block_Address[i],Block_Address[j]);
                Pointer_Swap(Block_Size[i],Block_Size[j]);
              end;
      end;
    asm
      mov ax,5803h
      mov bx,[UMB_Strategy]
      int 21h                          { Restore the UMB allocation strategy }
      mov ax,5801h
      mov bx,[DOS_Strategy]
      int 21h                          { Restore the DOS allocation strategy }
    end;
  End;

{----------------------------------------------------------------------------}

Procedure Release_UMB; far;                 { Exit procedure to release UMBs }
  var
    i : Word;
    Segment : Word;
  Begin
    ExitProc := SaveExitProc;
    if (Num_Blocks > 0) then
      begin
        asm
          mov ax,5803h
          mov bx,0000h
          int 21h                       { Set the UMB status to release UMBs }
        end;
        for i := 1 to Num_Blocks do
          begin
            Segment := Seg(Block_Address[i]^);
            if (Segment > 0) then
              asm
                mov ax,$4901
                mov bx,[Segment]
                mov es,bx
                int 21h                                    { Release the UMB }
              end;
          end;
      end;
  End;

{----------------------------------------------------------------------------}

Procedure Extend_Heap;
  var
    i : Word;
    Temp : PFreeRec;
  Begin
    if XMS_Driver_Present then
      begin
        Allocate_UMB_Heap;
        if UMB_Heap_Debug then
          Release_UMB;
        if (Num_Blocks > 0) then
          begin                             { Attach UMBs to the FreeList    }
            for i := 1 to Num_Blocks do
              PFreeRec(Block_Address[i])^.Size := Block_Size[i];
            for i := 1 to Num_Blocks do
              PFreeRec(Block_Address[i])^.Next := Block_Address[i+1];

            PFreeRec(Block_Address[Num_Blocks])^.Next := nil;

            if (FreeList = HeapPtr) then
              with PFreeRec(FreeList)^ do
                begin
                  Next := Block_Address[1];
                  Size := Ptr(Seg(HeapEnd^)-Seg(HeapPtr^),0);
                end
            else
              with PFreeRec(HeapPtr)^ do
                begin
                  Next := Block_Address[1];
                  Size := Ptr(Seg(HeapEnd^)-Seg(HeapPtr^),0);
                end;

            { HEAPPTR MUST BE IN THE LAST FREE BLOCK SO
              THAT TP6 DOESN'T TRY TO USE ANY MEMORY BETWEEN
              640K AND HEAPPTR }

            HeapPtr := Block_Address[Num_Blocks];
            HeapEnd := Ptr(Seg(Block_Address[Num_Blocks]^)+Seg(Block_Size[Num_Blocks]^),0);
          end;
      end;
  End;

{----------------------------------------------------------------------------}

BEGIN
  UMB_Heap_Debug := False;
  Num_Blocks := 0;
  SaveExitProc := ExitProc;
  ExitProc := @Release_UMB;
END.

{----------------------------------------------------------------------------}

