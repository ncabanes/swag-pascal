(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0039.PAS
  Description: DOS Environment Unit
  Author: MARUIS ELLEN
  Date: 11-26-93  17:04
*)

{
From: MARIUS ELLEN
Subj: DOS Environment
}

Program Environment;
{$M $1000,32776,32776 }
{    1K stack, 32k+8 bytes heap }
{$T- No @ Typed checking}
{$X+ Extended function syntax}
{$Q- No overflow checking}
{$A+ Word align data}
{$S+ Stack checking}

uses

    dos,
    strings;

type

    PJFTRec = ^TJFTRec;
    TJFTRec = record
      JFTtable : array[1..20] of byte;
    end;


    PMCBrec = ^TMCBrec;
    TMCBrec = record
      Next     : char;      {4d "M", of 5a "Z"}
      PSPOwner : word;
      Length   : word;
      Filler   : array[0..10] of byte;
    end;


    PPSPrec = ^TPSPrec;
    TPSPrec = record       {ofs, length }
      INT20   :word;       {00h  2 BYTEs   INT 20 instruction for CP/M CALL 0
                                           program termination the CDh 20h
                                           here is often used as a signature
                                           for a valid PSP }
      FreeSeg :word;       {02h    WORD    segment of first byte beyond
                                           memory allocated to program}
      UnUsed04:byte;       {04h    BYTE    unused filler }
      CMPCall :byte;       {05h    BYTE    CP/M CALL 5 service request
                                           (FAR JMP to 000C0h) BUG: (DOS 2+)
                                           PSPs created by INT 21/AH=4Bh
                                           point at 000BEh}
      CPMSize :word;       {06h    WORD    CP/M compatibility--size of
                                           first segment for .COM files}
      CPMrem  :word;       {08h  2 BYTEs   remainder of FAR JMP at 05h}
      INT22   :pointer;    {0Ah    DWORD   stored INT 22 termination address}
      INT23   :pointer;    {0Eh    DWORD   stored INT 23 control-Break addr.}
      INT24   :pointer;    {12h    DWORD   DOS 1.1+ stored INT 24 address}
      ParPSP  :word;       {16h    WORD    segment of parent PSP}
      JFT     :TJFTRec;    {18h 20 BYTEs   DOS 2+ Job File Table, one byte
                                           per file handle, FFh = closed}
      SEGEnv  :word;       {2Ch    WORD    DOS 2+ segment of environment
                                           for process}
      SSSP    :pointer;    {2Eh    DWORD   DOS 2+ process's SS:SP on entry
                                           to last INT 21 call}
      JFTCount:word;       {32h    WORD    DOS 3+ number of entries in JFT
                                           (default is 20)}
      JFTPtr  :pointer;    {34h    DWORD   DOS 3+ pointer to JFT
                                           (default PSP:0018h)}
      PrevPSP :pointer;    {38h    DWORD   DOS 3+ pointer to previous PSP
                                           (default FFFFFFFFh in 3.x)
                                           used by SHARE in DOS 3.3}
      UnUsed3c:byte;       {3Ch    BYTE    apparently unused by DOS
                                           versions <= 6.00}
      UnUsed3d:byte;       {3Dh    BYTE    apparently used by some versions
                                           of APPEND}
      NovFlag :byte;       {3Eh    BYTE    (Novell NetWare) flag: next byte
                                           initialized if CEh}
      NovTask :byte;       {3Fh    BYTE    (Novell Netware) Novell task
                                           number if previous byte is CEh}
      DosVers :word;       {40h  2 BYTEs   DOS 5+ version to return on
                                           INT 21/AH=30h}
      NextPSP :word;       {42h    WORD    (MSWin3) selector of next PSP
                                           (PDB) in linked list. Windows
                                           keeps a linked list of Windows
                                           programs only}
      UnUsed44:pointer;    {44h  4 BYTEs   unused by DOS versions <= 6.00}
      WinFlag :byte;       {48h    BYTE    (MSWindows3) bit 0 set if non-
                                           Windows application (WINOLDAP)}
      UnUsed49:string[6];  {49h  7 BYTEs   unused by DOS versions <= 6.00}
      RETF21  :string[2];  {50h  3 BYTEs   DOS 2+ service request (INT
                                           21/RETF instructions)}
      UnUsed53:word;       {53h  2 BYTEs   unused in DOS versions <= 6.00}
      UnUsed55:string[6];  {55h  7 BYTEs   unused in DOS versions <= 6.00;
                                           can be used to make first FCB
                                           into an extended FCB }
      FCB1    :string[15]; {5Ch 16 BYTEs   first default FCB, filled in
                                           from first commandline argument
                                           overwrites second FCB if opened}
      FCB2    :string[15]; {6Ch 16 BYTEs   second default FCB, filled in
                                           from second commandline
                                           argument, overwrites beginning
                                           of commandline if opened}
      UnUsed7c:pointer;    {7Ch  4 BYTEs   unused}
      DTAArea :string[127];{80h 128 BYTEs  commandline / default DTA
                                           command tail is BYTE for length
                                           of tail, N BYTEs for the tail,
                                           followed by a BYTE containing
                                           0Dh}
    end;


    PMCBPSPrec = ^TMCBPSPrec;
    TMCBPSPrec = record
      MCB :TMCBRec;
      PSP :TPSPRec;
    end;

var

    MainEnvSeg:word;
    MainEnvSize:word;


{$ifndef TryAssembler}
    {Find DOS master environment, command/4dos etc...}
    procedure GetMainEnvironment(var envseg,envsize:word);
    var R:PMCBPSPrec;
      Rrec:array[0..1] of word absolute R;
    begin
      asm
        mov     ah,52h            {Get First MCB, }
        int     $21               {DOS Memory Control Block (MCB)}
        mov     ax,es:[bx-2]      {Bevind zich 2 terug}
        mov     R.word[0],0       {Offset is altijd 0}
        mov     R.word[2],ax      {MCB:=first DOS mcb}
      end;

      while true do begin
        if pos(R^.mcb.next,'MZ')=0
        then halt(7);             {Memory control block destroyed}

        if R^.mcb.PSPOwner=R^.PSP.ParPSP then begin {found}
          EnvSeg :=R^.PSP.SegEnv;
          R:=Ptr(EnvSeg-1,0);
          EnvSize:=R^.mcb.length shl 4;
          if EnvSize>32767
          then halt(10);          {Environment invalid (usually >32K)}
          exit;
        end;
        if R^.mcb.next='Z'
        then halt(9);             {Memory block address invalid}
                                  {Er moet een environment zijn!}
        R:=ptr((Rrec[1]+(R^.mcb.length)+1),0);
      end;
    end;


{$else}
    procedure HaltIndirect(error:word);
    begin
      halt(error);
    end;


    {Find DOS master environment, command/4dos etc...}
    procedure GetMainEnvironment(var envsegP,envsizeP:word);
    assembler;
    var mcb:pointer;
    asm
        mov     ah,52h            {Get First MCB, }
        int     $21               {DOS Memory Control Block (MCB)}
        sub     bx,2
        xor     dx,dx             {offset altijd 0000}
        mov     ax,es:[bx]
        mov     mcb.word[0],dx
        mov     mcb.word[2],ax    {MCB:=first DOS mcb}

    @repeat:
        les     di,mcb
        mov     bl,es:[di]
        cmp     bl,4dH
        je      @MCBOk
        cmp     bl,5aH            {was het de laatste MCB}
        jne     @MCBError         {zo ja dan halt(9)}
    @MCBOk:
        mov     ax,es:[01h]       {is segment v/h prg bij deze MCB}
        cmp     ax,es:[26h]       {gelijk aan EnvSegment van het prg}
        je      @found            {zo ja dan is ie gevonden}

        cmp     bl,5ah            {is dit de laatste mcb ?}
        je      @MCBMissing       {!?!? MCB main env weg!?!?}
        les     di,mcb            {volgende MCB zit op}
        mov     ax,es             {oude MCB+next}
        add     ax,es:[3]         {+volgende}
        inc     ax                {+1}
        mov     mcb.word[2],ax
        jmp     @repeat           {herhaal tot gevonden}

    @MCBError:
        mov     al,7              {Memory control block destroyed}
        db      0a9h              {skip next mov al,xx=opcode test ax,w}
    @MCBMissing:
        mov     al,9              {Memory block address invalid}
        db      0a9h              {kan ook environment not found zijn!}
    @SizeErr:
        mov     al,10             {Environment invalid (usually >32K)}
        push    ax
        call    HaltIndirect

    @found:
        mov     ax,es:[3ch]       {Get segment environment}
        mov     dx,es             {save es}
        les     di,EnvSegP        {ptr van VAR parameter}
        mov     es:[di],ax        {Store environment segment}
        mov     es,dx             {rest es}

        dec     ax                {MCB van env. is 1 paragraaf terug}
        mov     es,ax             {Get Size van env. uit MCB}
        mov     ax,es:[3]         {deze is in paragrafen}
        mov     cl,4              {en wordt geconverteerd}
        shl     ax,cl             {naar bytes..}

        les     di,EnvSizeP       {ptr van VAR parameter}
        mov     es:[di],ax        {Store environment size}
        cmp     ax,32768          {size moet <32k}
        jae     @SizeErr          {anders een foutmelding}
    end;
{$endif}

    {Seperate Variable and return parameters}
    function StripEnvVariable(Variable:pchar):pchar;
    const stop='='#32#0;
    begin
      While pos(Variable^,stop)=0 do inc(Variable);
      StripEnvVariable:=Variable+1;
      Variable^:=#0;
    end;


    {like bp's getenv, this time removing spaces}
    function GetMainEnv(variable:string):string;
    var MainPtr,Params:pchar;
      data:array[0..512] of char;
    begin
      MainPtr:=ptr(MainEnvSeg,0);
      StrPCopy(@variable,variable);
      StrUpper(@variable);
      StripEnvVariable(@variable);

      if variable[0]<>#0 then begin
        while (MainPtr^<>#0) do begin
          StrCopy(Data,MainPtr);
          Params:=StripEnvVariable(data);
          if StrComp(Data,@Variable)=0 then begin
            GetMainEnv:=StrPas(Params);
            exit;
          end;
          MainPtr:=StrEnd(MainPtr)+1;
        end;
      end;
      GetMainEnv:='';
    end;


    {like bp's EnvCount}
    function MainEnvCount:integer;
    var MainPtr:pchar;
      index:integer;
    begin
      index:=0;
      MainPtr:=ptr(MainEnvSeg,0);
      while (MainPtr^<>#0) do begin
        MainPtr:=StrEnd(MainPtr)+1;
        inc(index);
      end;
      MainEnvCount:=index;
    end;


    {like bp's EnvStr}
    function MainEnvStr(index:integer):string;
    var MainPtr:pchar;
    begin
      MainPtr:=ptr(MainEnvSeg,0);
      while (MainPtr^<>#0) do begin
        dec(index);
        if index=0 then begin
          MainEnvStr:=StrPas(MainPtr);
          exit;
        end;
        MainPtr:=StrEnd(MainPtr)+1;
      end;
      MainEnvStr:='';
    end;


    {change environment "variable", returning succes}
    function MainEnvChange(variable:string; param:string):boolean;
    var data:array[0..512] of char;
      Mem,MainPtr,EnvPtr:pchar;
      NewSize:word absolute EnvPtr;
      EnvPtrLong:^Longint absolute EnvPtr;


      procedure EnvStrCopy(src:pchar);
      begin
        if NewSize+StrLen(src)<=MainEnvSize-4
        then begin
          StrCopy(EnvPtr,Src);
          EnvPtr:=StrEnd(EnvPtr)+1;
        end
        else MainEnvChange:=false;
      end;

      procedure PutVariable;
      begin
        if (Variable[0]<>#0) and (param[0]<>#0) then begin
          StrCopy(Data,@variable);
          StrCat(Data,'=');
          StrCat(Data,@param);
          EnvStrCopy(Data);
          variable[0]:=#0;
        end;
      end;

    begin
      getmem(Mem,MainEnvSize);
      MainPtr:=ptr(MainEnvSeg,0);
      EnvPtr:=Mem;

      StrPCopy(@variable,variable);
      StrUpper(@variable);
      StripEnvVariable(@variable);
      StrPCopy(@param,param);
      MainEnvChange:=variable[0]<>#0;

      while MainPtr^<>#0 do begin
        StrCopy(Data,MainPtr);
        StripEnvVariable(data);
        if StrComp(Data,@Variable)=0
        then PutVariable
        else EnvStrCopy(MainPtr);
        MainPtr:=StrEnd(MainPtr)+1;
      end;

      if variable[0]<>#0
      then PutVariable;

      EnvPtrLong^:=0; {4 terminating zero's}
      {1 byte terminating environment}
      {2 word counting trailing strings}
      {1 byte terminating the strings}
      {. last three disables paramstr(0)}
      move(Mem^,Ptr(MainEnvSeg,0)^,NewSize+4);
      freeMem(Mem,MainEnvSize);
    end;


var oldprmp:string;
begin
  GetMainEnvironment(MainEnvSeg,MainEnvSize);
  memw[prefixseg:$2c]:=MainEnvSeg;

  oldprmp:=GetMainEnv('fprompt');
  MainEnvChange('prompt','Please type EXIT!'#13#10+'$p$g');

  swapvectors;
  exec(GetMainEnv('comspec'),'');
  swapvectors;

  MainEnvChange('prompt',oldprmp);
end.

