(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0071.PAS
  Description: Detecting DeskView/OS2/Windows
  Author: BART BROERSMA
  Date: 09-04-95  10:50
*)

{
BB>   What code can I use to detect all three of the following:

BB>  1.  : DPMI
BB>  2.  : DeskView
BB>  3.  : Windows
BB>  4.  : OS/2


Detecting Windows ...
}

{   Copyright (C) 1991 by: NativSoft Computing
                           1155 College Ave.
                           Adrian, MI, 49221
                           CIS 71160,1045

    Based on information published in an article
    by Ben Myers of Spirit of Performance, Inc.
    (Dr. Dobb's Journal, #172, January, 1991, pg 116)

    Compiled with Turbo Pascal v6.

    Modified by Tom Clark.  Changed Errorlevel values.

    Return Errorlevel 0 if Windows not running,
                      1 if Windows 2.x,
                      2 if Windows 3 real or standard mode,
                      3 if Windows 3 enhanced mode.

}

program findwin;

var t     : byte;
    valu  : word;


BEGIN

  {Inline assembler or macro is necessary to make the multiplex (2Fh) call
   because Turbo Pascal only *fakes* INTR procedure -- i.e., this DOESN'T
   work:           var regs : registers;
                     ...
                   regs.ax := $1600;
                   intr($2F,regs);
                   valu := regs.al                                         
}

  ASM
    MOV AX, 1600h
    INT 2Fh
    MOV valu, AX
  END;

  case lo(valu) of
    $01,$FF : t := 1;  {win/386, ver 2.xx running}
    $00,$80 : begin    {Enhanced, WIN/386, or WIN ver 2.xx NOT RUNNING
                            ... so, test for real or standard win 3.x }
                ASM
                  MOV AX, 4680h
                  INT 2Fh
                  MOV valu, AX
                END;

                if valu = 0 then t := 2 {real or standard win 3.x running}
                else t := 0;            {apparently NO WIN is running}
              end;
    else t := 3;  {enhanced win 3.x running}
  end; {case}

END.

