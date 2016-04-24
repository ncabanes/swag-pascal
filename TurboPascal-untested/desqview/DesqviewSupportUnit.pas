(*
  Category: SWAG Title: DESQVIEW ROUTINES
  Original name: 0004.PAS
  Description: DESQVIEW Support Unit
  Author: JOEL BERGEN
  Date: 02-09-94  11:50
*)

(* ------------------------------------------------------------ *)

{ This unit adds support for the DESQview" multi-tasking enviroment
  By Joel Bergen  last revised: 9/17/90  }

{$A+,B-,D+,E+,F-,I+,L+,N-,O+,R+,S+,V+}
{$M 1024,0,0}

UNIT DESQview;

INTERFACE

USES DOS;

VAR
  Dv_Loaded  : BOOLEAN; {True if running under DESQview                  }
  Dv_Version : WORD;    {DESQview" version number                        }
                        {Returns "0" if DESQview" is not loaded.         }
                        {Use:                                            }
                        {WRITELN(Hi(Dv_Version)+Lo(Dv_Version)/100:4:2); }
                        {to display the version of "Desqview" correctly. }


FUNCTION  Dv_There : BOOLEAN;     {True if Desqview loaded. Sets Dv_Version}
PROCEDURE Dv_Pause;               {Give up the rest of our timeslice}
PROCEDURE Dv_Begin_Critical;      {Turn switching off for time critical ops}
PROCEDURE Dv_End_Critical;        {Turn switching back on}
FUNCTION  Dv_Video_Buffer : WORD; {returns address of video buffer}

IMPLEMENTATION

VAR
  Reg : REGISTERS;

FUNCTION Dv_There;
BEGIN
  Reg.CX:=$4445;
  Reg.DX:=$5351;
  Reg.AX:=$2B01;
  INTR($21,Reg);
  Dv_Loaded:=(Reg.AL<>$0FF);
  IF Dv_Loaded THEN Dv_Version:=Reg.BX ELSE Dv_Version:=0;
  Dv_There:=Dv_Loaded;
END;

PROCEDURE Dv_Pause;
BEGIN
  IF DV_Loaded THEN BEGIN
    Reg.AX:=$1000;
    INTR($15,Reg);
  END;
END;

PROCEDURE Dv_Begin_Critical;
BEGIN
  IF DV_Loaded THEN BEGIN
    Reg.AX:=$101B;
    INTR($15,Reg);
  END;
END;

PROCEDURE Dv_End_Critical;
BEGIN
  IF DV_Loaded THEN BEGIN
    Reg.AX:=$101C;
    INTR($15,Reg);
  END;
END;

FUNCTION DV_Video_Buffer;
BEGIN
  Reg.AH:=$0F;
  INTR($10,Reg);
  IF Reg.AL=7 THEN Reg.ES:=$B000 ELSE Reg.ES:=$B800;
  IF DV_Loaded THEN BEGIN
    Reg.DI:=0;
    Reg.AX:=$FE00;
    INTR($10,Reg);
  END;
  DV_Video_Buffer:=Reg.ES;
END;

BEGIN { Checks to see if desqview is loaded at startup. }
  Dv_Loaded:=Dv_There;
END.


