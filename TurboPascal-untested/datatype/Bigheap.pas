(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0002.PAS
  Description: BIGHEAP.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{    ...Here is a demo Program that will read-in up to 15,000 Records
    onto the HEAP memory pool.
}

{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V-,X-,Y-}
{$M 4096,0,655360}

Program Large_Array_Structure_Demo;

Type
              (* Type definitions.                                    *)
  st_8    = String[8];
  inar_4  = Array[0..4] of Integer;

  rc_zlog = Record
              date      : String[8];
              userbaud  : inar_4;
              active    : Integer;
              calls     : Integer;
              newusers  : Integer;
              pubpost   : Integer;
              privpost  : Integer;
              netpost   : Integer;
              criterr   : Integer;
              uploads   : Integer;
              downloads : Integer;
              uk        : LongInt;
              dk        : LongInt
            end;

Const
              (* Maximum number of Records to read-in.                *)
  co_rcMax   = 15000;
              (* Byte size of 1 Record.                               *)
  co_rcSize  = sizeof(rc_zlog);

Type
              (* Pointer of zlog Record Type.                         *)
  porc_zlog  = ^rc_zlog;
              (* Array of 15,000 of zlog-Record Pointers.             *)
  poar_15K   = Array[1..co_rcMax] of porc_zlog;

Var
              (* Use to store "ioresult" value.                       *)
  by_Error          : Byte;
              (* Loop control Variable.                               *)
  wo_Index,
              (* Total number of Records in the data File.            *)
  wo_RecTotal,
              (* Number of Bytes read using "BlockRead" routine.      *)
  wo_BytesRead      : Word;
              (* Pointer to mark the bottom of the HEAP.              *)
  po_HeapBottom     : Pointer;
              (* Array of 15,000 zlog-Record Pointers.                *)
  poar_RcBuffer     : poar_15K;
              (* File Variable to be assigned to the data File.       *)
  fi_Data           : File;

begin
              (* Try to open the data File.                           *)
  assign(fi_Data, 'ZLOG.DAT');
  {$I-}
  reset(fi_Data, 1);
  {$I+}
              (* Check For File errors.                               *)
  by_Error := ioresult;
  if (by_Error <> 0) then
  begin
    Writeln('Error ', by_Error, ' opening ZLOG.DAT File');
    halt
  end;

              (* Calculate the number of Records in data File.        *)
  wo_RecTotal := (Filesize(fi_Data) div co_rcSize);
              (* Initialize loop control Variable.                    *)
  wo_Index := 1;
              (* Record the address of the HEAP "bottom".             *)
  mark(po_HeapBottom);
              (* While free memory is greater than size of 1 Record   *)
  While (maxavail > co_rcSize)
              (* And, not all Records have been read in...            *)
  and   (wo_Index < wo_RecTotal)
              (* And, less than maximum number of Records to read-in. *)
  and   (wo_Index < co_rcMax) do
  begin
            (* Allocate room For 1 Record on the HEAP.              *)
    new(poar_RcBuffer[wo_Index]);
            (* Read 1 Record from data File into new HEAP Variable. *)
    blockread(fi_Data, poar_RcBuffer[wo_Index]^, co_rcSize, wo_BytesRead);
            (* Check For "BlockRead" error.                         *)
    if (wo_BytesRead <> co_rcSize) then
    begin
      Writeln('BLOCKREAD error!');
      halt
    end;
            (* Advance loop control Variable by 1.                  *)
    inc(wo_Index)
  end;
              (* Close the data File.                                 *)
  close(fi_Data);
              (* Display the amount of free HEAP memory left.         *)
  Writeln('Free HEAP memory = ', maxavail, ' Bytes');
              (* Display the number of Records read onto the HEAP.    *)
  Writeln('Records placed on the HEAP = ', wo_Index);
              (* Release all the HEAP memory used to store Records.   *)
  release(po_HeapBottom);
              (* Display the amount of free HEAP memory left, again.  *)
  Writeln('Free HEAP memory = ', maxavail, ' Bytes');

end.

