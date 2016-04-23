
{
TSRUNIT v1.10
Copyright (c) 1995 Nir Sofer, All rights reserved
For using with Turbo Pascal 6.0/7.0

You are allowed to copy, modify and share this program with others. But when
you give TSRUNIT source code to other people (or upload it to a BBS) always
give them the whole original files which is included in TSRUNIT package.

For questions, comments or bugs report: Send me a message by one of the
following ways:

1. Internet: nir@netvision.net.il
2. FidoNet:  Nir Sofer, at 2:403/138.0
3. Ordinary mail:

  Nir Sofer
  5 Shderot Hashoshanim St.
  52583 Ramat Gan
  ISRAEL

All mail will be answered. If you don't get a reply after a week, please
send it again. Mail may be lost somethimes...

READ TSRUNIT.DOC BEFORE USING THIS UNIT !

New in this version:

* Problems with MS-DOS 6.xx fixed by adding INT28 support.
* Check if the TSR has already installed before.
* The type of TsrProcedue variable is a procedure instead of pointer, so you
  don't have to add @ operator.
* Consts for all keyboard flags and keyboard scan codes.
* The TsrProcedure variable automatically assigned by InstallTsr procedure

}

unit tsrunit;
{$s-,r-}

interface
type
  ProcedureType = procedure;
const
  TSRUNITsignature = $DAAD;
  RightShift = 1;
  LeftShift  = 2;
  Ctrl       = 4;
  Alt        = 8;

  _esc  = 1;     _a    = 30;     _f7    = 65;
  _1    = 2;     _s    = 31;     _f8    = 66;
  _2    = 3;     _d    = 32;     _f9    = 67;
  _3    = 4;     _f    = 33;     _f10   = 68;
  _4    = 5;     _g    = 34;     _numlock = 69;
  _5    = 6;     _h    = 35;     _scrlock = 70;
  _6    = 7;     _j    = 36;     _home    = 71;
  _7    = 8;     _k    = 37;     _up = 72;
  _8    = 9;     _l    = 38;     _pgup     = 73;
  _9    = 10;    _lshift = 42;   _left     = 75;
  _0    = 11;    _z    = 44;     _right    = 77;
  _minus = 12;   _x    = 45;     _end      = 79;
  _plus  = 13;   _c    = 46;     _down     = 80;
  _bksp  = 14;   _v    = 47;     _pgdn     = 81;
  _tab   = 15;   _b    = 48;     _insert   = 82;
  _q      = 16;  _n    = 49;     _delete   = 83;
  _w      = 17;  _m    = 50;
  _e      = 18;  _rshift = 54;
  _r      = 19;  _alt    = 56;
  _t      = 20;  _space  = 57;
  _y      = 21;  _capslock = 58;
  _u      = 22;  _f1  = 59;
  _i      = 23;  _f2  = 60;
  _o      = 24;  _f3  = 61;
  _p      = 25;  _f4  = 62;
  _enter  = 28;  _f5  = 63;
  _ctrl   = 29;  _f6  = 64;

var
  keysc         : byte;    {Keyboard scan code variable}
  keyflag       : byte;  {Keyboard flag variable}
  TsrProcedure  : ProcedureType;
  UserSignature : word;
  SignatureReturn : word;
procedure SetUserSignature(Check,Return:word);
procedure InstallTsr(tsrproc: ProcedureType);  {Make your program resident}
procedure RemoveTsr;   {Remove your resident program}
function CheckIntVectors:boolean; {Check if interrupt vectors are still
                         ours, if yes you are allowed to remove your TSR}
function InstallationCheck:boolean;

implementation
uses dos;
var
  old08,old09,old10,old1b,old24,old28,turbo24:pointer;
  indosflag,currint:pointer;
  active,request,idle:byte;
  savesp,savess:word;
  busyflag:byte;
{$f+}
{**********************************************************************}
procedure int1b;assembler;
asm
  iret   {Cancel CTRL-BREAK interrupt}
end;
{**********************************************************************}
procedure int10;assembler;
asm
                jmp     @cont1
@localds:
                nop
                nop       {Reserved for ds value}
@localint10:
                nop
                nop
                nop
                nop       {Reserved for old int10 address}

@cont1:
                push    ds
                mov     ds,word ptr [cs:@localds]
                inc     busyflag
                pop     ds
                pushf
                call    dword ptr [cs:@localint10]  {Call old interrupt}
                push    ds
                mov     ds,word ptr [cs:@localds]
                cmp     ax,tsrunitsignature
                je      @TsrUnitCall
@cont100:
                dec     busyflag
                pop     ds
                iret
@TsrUnitCall:
                cmp     bx,UserSignature
                jne     @cont100
                mov     cx,SignatureReturn
                jmp     @cont100
end;
{**********************************************************************}
procedure swap1;
begin     {Swap vectors before running TsrProcedure}
  getintvec($1b,old1b);
  setintvec($1b,@int1b);
  getintvec($24,old24);
  setintvec($24,turbo24);
end;
{**********************************************************************}
procedure swap2;
begin     {Swap vectors after running TsrProcedure}
  setintvec($24,old24);
  setintvec($1b,old1b);
end;
{**********************************************************************}
procedure activate;assembler;
asm
                jmp     @start
@localss:
                nop
                nop   {Reserved for ss value}
@localsp:
                nop
                nop   {Reserved for sp value}
@start:
                cmp     request,1      {Request by INT09 ?}
                jne     @notrequested
                cmp     idle,1
                je      @cont500
                les     di,indosflag
                cmp     word ptr [es:di],0   {Check indos flag}
                jne     @notrequested
@cont500:
                cmp     busyflag,0           {INT10 busy ?}
                jne     @notrequested
                mov     active,1             {The tsr is active now}
                mov     request,0
                mov     savess,ss
                mov     savesp,sp
                cli
                mov     ss,word ptr [cs:@localss]
                mov     sp,word ptr [cs:@localsp]  {Set ss and sp registers of TP}
                sti
                push    bx
                push    cx
                push    dx
                push    si
                push    bp
                call    [swap1]  {Swap CTRL-BREAK and critical error handler vectors}
                call    [TsrProcedure]       {call your procedure}
                call    [swap2]  {Swap CTRL-BREAK and critical error handler vectors}
                pop     bp
                pop     si
                pop     dx
                pop     cx
                pop     bx
                cli
                mov     ss,savess
                mov     sp,savesp                  {Set old ss and sp registers}
                sti
                mov     active,0

@notrequested:
end;
{**********************************************************************}
procedure int28;assembler;
asm
                jmp     @cont1
@localds:
                nop
                nop
@localint28:
                nop
                nop
                nop
                nop
@cont1:
                push    es
                push    ds
                push    ax
                push    di

                push    ds
                mov     ds,word ptr [cs:@localds]
                inc     idle
                pop     ds
                pushf
                call    dword ptr [cs:@localint28]  {Call old interrupt}
                mov     ds,word ptr [cs:@localds]
                call    activate
                dec     idle
                pop     di
                pop     ax
                pop     ds
                pop     es
                iret

end;
{**********************************************************************}
procedure int08;assembler;
asm
                jmp     @cont1
@localds:
                nop
                nop   {Reserved for ds value}

@cont1:
                push    es
                push    ds
                push    ax
                push    di
                mov     ds,word ptr [cs:@localds]
                pushf
                call    [old08]  {Call old interrupt}
                call    activate
                pop     di
                pop     ax
                pop     ds
                pop     es
                iret
end;
{**********************************************************************}
procedure int09;assembler;
asm
                jmp     @cont1
@localds:
                nop
                nop       {Reserved for ds value}

@cont1:
                push    es
                push    ax
                push    ds
                mov     ds,word ptr [cs:@localds]
                pushf
                call    [old09]  {Call old INT09}
                in      al,60h
                cmp     al,keysc   {Check scan code key}
                jne     @notourkey
                xor     ax,ax
                mov     es,ax
                mov     al,[es:1047]
                and     al,keyflag
                cmp     al,keyflag   {Check alt\ctrl\shift keys}
                jne     @notourkey
                cmp     active,1   {Check if already active}
                je      @notourkey
                mov     request,1  {Request activity}

@notourkey:
                pop     ds
                pop     ax
                pop     es
                iret
end;
{**********************************************************************}
procedure InstallTsr(tsrproc: ProcedureType);
begin
  TsrProcedure:=tsrproc;
  getintvec($28,old28);
  getintvec($8,old08);
  getintvec($9,old09);
  getintvec($10,old10);
  getintvec($24,turbo24);  {Get interrupt vectors}
  memw[seg(int10):ofs(int10)+4]:=memw[seg(old10):ofs(old10)];
  memw[seg(int10):ofs(int10)+6]:=memw[seg(old10):ofs(old10)+2];
  memw[seg(int28):ofs(int28)+4]:=memw[seg(old28):ofs(old28)];
  memw[seg(int28):ofs(int28)+6]:=memw[seg(old28):ofs(old28)+2];
{Put interrupt $10 address in INT10 procedure}
  memw[seg(activate):ofs(activate)+4]:=sptr;
{Save stack pointer for using when TSR is active}
  setintvec($8,@int08);
  setintvec($9,@int09);
  setintvec($10,@int10);
  setintvec($28,@int28);
{Set new interrupt vectors}
  asm
                mov     dx,prefixseg
                mov     es,dx
                mov     ax,[es:$2c]
                cmp     ax,0
                jz      @cont
                mov     es,ax
                mov     ah,$49
                int     $21  {Release environment block}
@cont:
  end;
  swapvectors; {Swap TP vectors with old vectors}
  keep(0);  {Terminate and stay resident}
end;
{**********************************************************************}
function CheckIntVectors:boolean;
{If CheckIntVectors=false, do not remove the tsr !!}
begin
  CheckIntVectors:=false;
  getintvec($8,currint);
  if currint<>@int08 then exit;
  getintvec($9,currint);
  if currint<>@int09 then exit;
  getintvec($10,currint);
  if currint<>@int10 then exit;
  CheckIntVectors:=true;
end;
{**********************************************************************}
procedure RemoveTsr;
begin
  setintvec($8,old08);
  setintvec($9,old09);
  setintvec($10,old10);
  setintvec($1b,old1b);
  setintvec($28,old28);
{set old interrupt vectors}
  asm
    mov    dx,prefixseg
    mov    es,dx
    mov    ah,$49
    int    $21    {Release memory block}
  end;
  asm
    mov    ax,$4c00
    int    $21     {Terminate program}
  end;
end;
{**********************************************************************}
procedure SetUserSignature(Check,Return:word);assembler;
asm
  mov   ax,check
  mov   UserSignature,ax {The value to send to INT 10h}
  mov   ax,return
  mov   SignatureReturn,ax  {The value that INT 10h will return}
end;
{**********************************************************************}
function InstallationCheck:boolean;assembler;
asm
  mov   ax,TSRUNITsignature
  mov   bx,UserSignature
  xor   cx,cx
  int   010h
  xor   al,al
  cmp   cx,SignatureReturn {Did you get the return value}
  jne   @tend
  mov   al,1               {If yes, your TSR already installed !}
@tend:
end;
{**********************************************************************}
begin
  setusersignature($eeaa,$aaff);
  busyflag:=0;
  idle:=0;
  memw[seg(int08):ofs(int08)+2]:=dseg;
  memw[seg(int09):ofs(int09)+2]:=dseg;
  memw[seg(int10):ofs(int10)+2]:=dseg;
  memw[seg(int28):ofs(int28)+2]:=dseg;
  memw[seg(activate):ofs(activate)+2]:=sseg;
{Set local data segments}
  keysc:=_a;
  keyflag:=Alt + Ctrl; {Default key combination}
  active:=0;
  request:=0;
  asm
    mov   ah,$34
    int   $21
    mov   ax,es
    sub   bx,1
    sbb   ax,0
    mov   word ptr [indosflag],bx
    mov   word ptr [indosflag+2],ax  {Get indos flag address}
  end;
end.