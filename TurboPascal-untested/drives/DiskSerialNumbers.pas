(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0025.PAS
  Description: Disk Serial Numbers
  Author: LAWRENCE JOHNSTONE
  Date: 07-17-93  07:29
*)

(*
Date: 07-10-93 (02:15)
From: LAWRENCE JOHNSTONE
Subj: DISK'S SERIAL NUMBER.
This will work under DOS 4.0 or later, according to Microsoft's MS-DOS
Programmer's Reference (earlier versions of DOS didn't give disks
serial numbers).
*)

UNIT MediaID;

INTERFACE

TYPE
  TMediaID = RECORD
    InfoLvl:   WORD;
    SerialNum: LONGINT;
    VolLabel:  ARRAY [1..11] OF CHAR;
    FileSys:   ARRAY [1..8] OF CHAR;
  END;

FUNCTION GetMediaID( Drive: WORD; VAR MID:  TMediaID ): BOOLEAN;
  (* Drive:  0=default, 1=A, 2=B, etc. *)

FUNCTION SetMediaID( Drive: WORD; CONST MID: TMediaID ): BOOLEAN;

IMPLEMENTATION

FUNCTION GetMediaID( Drive: WORD; VAR MID: TMediaID ): BOOLEAN;  ASSEMBLER;
  ASM
    push ds
    mov  bx, [Drive]
    mov  ch, $08       (* Device category (must be 08h) *)
    mov  cl, $66       (* Minor code for Get Media ID function *)
    lds  dx, [MID]     (* DS:DX -> TMediaID structure *)
    mov  ax, $440D     (* Function 44 (IOCTL), subfunction 0D *)
    int  $21
    pop  ds
    mov  ax, 0         (* Assume function failed *)
    jc   @@Done
    inc  ax            (* Didn't fail -- return TRUE *)
  @@Done:
  END;

FUNCTION SetMediaID( Drive: WORD; CONST MID: TMediaID ): BOOLEAN;  ASSEMBLER;
  ASM
    push ds
    mov  bx, [Drive]
    mov  ch, $08       (* Device category (must be 08h) *)
    mov  cl, $46       (* Minor code for Set Media ID function *)
    lds  dx, [MID]     (* DS:DX -> TMediaID structure *)
    mov  ax, $440D     (* Function 44 (IOCTL), subfunction 0D *)
    int  $21
    pop  ds
    mov  ax, 0         (* Assume function failed *)
    jc   @@Done
    inc  ax            (* Didn't fail -- return TRUE *)
  @@Done:
  END;


END.


