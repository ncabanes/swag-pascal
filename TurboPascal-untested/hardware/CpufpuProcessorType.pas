(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0025.PAS
  Description: CPU/FPU processor type
  Author: GREG VIGNEAULT
  Date: 01-27-94  13:31
*)

(*-------------------------------------------------------------------*)
 UNIT CPUID; {CPUID.PAS} { determine CPU and FPU processor types }
 Interface               { Copyright 1992 Gregory S. Vigneault }

 Const        CpuType :Array[0..10] of String[7] = ('8088','8086','NEC V20',
        'NEC V30','80186','80188','80286','386DX','386SX','486DX','486SX');

        FpuType :Array[0..4] of String[5] = ('None','8087','80287','80387',
        '80487');

 FUNCTION GetCPU( VAR FPUtype :BYTE ) :BYTE;
 { GetCPU codes:
    0 = 8088      |   6 = 80286
    1 = 8086      |   7 = 386DX   or older/undetected 386SX
    2 = NEC V20   |   8 = 386SX   * not always detected in all modes
    3 = NEC V30   |   9 = 486DX   or (486SX with 487SX)
    4 = 80186     |   10= 486SX
    5 = 80188     |
  FPUtype codes: 0 = none
                 1 = 8087
                 2 = 80287
                 3 = 80387   * 387DX or 387SX
                 4 = 80487   * 487SX or 486DX
                 17= undetermined copro reported by BIOS }
 Implementation  { Mar.9.92 }
 {$L GETCPU.OBJ}
 FUNCTION GetCPU( VAR FPUtype :BYTE ) :BYTE; EXTERNAL;
 END.    { Unit CPUID }
(*-------------------------------------------------------------------*)
(*-------------------------------------------------------------------*)
 PROGRAM ProcessorID; {PID.PAS   determine CPU & FPU (NDP) types }
 USES    CPUID;
 VAR     FPUtype, CPUtype     :BYTE;
 BEGIN
        WriteLn( #10,' PID v0.2, 1992 G.S.Vigneault',#10);
        Write(' CPU type: ');
        CASE GetCPU( FPUtype ) OF
            0   : WriteLn('8088');
            1   : WriteLn('8086');
            2   : WriteLn('NEC V20');
            3   : WriteLn('NEC V30');
            4   : WriteLn('80188');
            5   : WriteLn('80186');
            6   : WriteLn('80286');
            7   : WriteLn('386DX');
            8   : WriteLn('386SX');
            9   : WriteLn('486DX');
            10  : WriteLn('486SX')
            END; {case GetCPU}
        Write(' FPU type: ');
        CASE FPUtype OF
            0   : WriteLn('none');
            1   : WriteLn('8087');
            2   : WriteLn('80287');
            3   : WriteLn('80387');
            4   : WriteLn('80487');
            17  : WriteLn('in equipment byte');
            END; {case FPUtype}
 END.    {ProcessorID}
(*-------------------------------------------------------------------*)

