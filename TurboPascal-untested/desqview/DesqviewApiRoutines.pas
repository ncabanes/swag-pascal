(*
  Category: SWAG Title: DESQVIEW ROUTINES
  Original name: 0005.PAS
  Description: DESQVIEW API Routines
  Author: MIKE DICKSON
  Date: 05-25-94  08:11
*)

{
********************************************************************
*                                                                  *
*  DESQview API routines                                           *
*  for Turbo Pascal 6.0                                            *
*  by Jonathan L. Zarate                                           *
*  Released to the Public Domain                                   *
*                                                                  *
********************************************************************
}
{
  ** Please refer to Ralf Brown's Interrupt List
  ** for additional information.
}

Unit DV;

Interface

Type
 Msg_Write2 = record
               len : longint;
               str : pointer;
              end;
 Msg_Write2_NewWin = record
                      len    : longint;
                      str    : pointer;
                      handle : pointer;
                     end;

const
{ Stream Types }
 WinStream     = $00;
 QueryStream   = $01;
 ManagerStream = $10;

{ Manager Streams }
 MStream_MoveHoriz    = $00;     { horizontal movement  }
 MStream_MoveVert     = $01;     { vertical movement  }
 MStream_ChangeWidth  = $02;     { width change  }
 MStream_ChangeHeight = $03;     { height change  }
 MStream_ScrollHoriz  = $04;     { horizontal scroll  }
 MStream_ScrollVert   = $05;     { vertical scroll  }
 MStream_CloseWindow  = $06;     { close window option }
 MStream_HideWindow   = $07;     { hide window option }
 MStream_FreezeApp    = $08;     { freeze window option }
 MStream_ScissorsMenu = $0E;     { scissors menu }
 MStream_MainMenu     = $10;     { main DESQview menu }
 MStream_SwitchWinMenu= $11;     { switch windows menu }
 MStream_OpenWinMenu  = $12;     { open windows menu }
 MStream_QuitMenu     = $13;     { quit menu }

{ Window/Query streams }
 WStream_CursorRow    = $A0;     { Cursor row }
 WStream_CursorColumn = $A1;     { Cursor Column }
 WStream_ScrollTopRow = $A2;     { Top row of scrolling region }

{ DVError Constants }
 DVErrorMouEither   = 00;        { use either mouse buttons to remove window }
 DVErrorMouRight    = 32;        { use right mouse button to remove window }
 DVErrorMouLeft     = 64;        { use left mouse button to remove window }
 DVErrorBeep        = 128;       { beep on error }
{ ----------------------- }

const
 InDV        : boolean = false;  { In DESQview flag }
 DV_Version  : word = $0000;     { DESQview version }

var
 DVArray     : array[1..80] of byte; { stream array }

function  DVInit : pointer;
procedure DVGetVersion;
function  DVGetShadowSeg( VideoSeg : word ) : word;
procedure DVPause;
procedure DVBeginC;
procedure DVEndC;
function  DVAPPNum : word;
procedure DVSendMsg( Handle : pointer; _bh, _bl : byte; size : word; var param);
procedure DVStream( Handle : pointer; mode : byte; params : string );
function  DVGetHandle( HandleType : byte ) : pointer;
procedure DVSound( Handle : pointer; frequency, duration : word );
procedure DVError( Handle : pointer; xsize, ysize : byte; msg : string; params:byte);
procedure DVAPILevel( major, minor : byte );
procedure DVWrite( Handle : pointer; s : string );
procedure DVWriteln( Handle : pointer; s : string );
function  DVNewWin( x, y : word ) : pointer;
procedure DVFree( var Handle : pointer );
function  DVTimer_New : pointer;
procedure DVTimer_Start( Handle : pointer; Time : longint );
function  DVTimer_Len( Handle : pointer ) : longint;
{ ---- Window Streams ---- }
procedure DVClear( Handle : pointer );
procedure DVRedraw( Handle : pointer );
procedure DVResize( Handle : pointer; x, y : byte );
procedure DVMove( Handle : pointer; x, y : shortint );
procedure DVTitle( Handle : pointer; title : string );
procedure DVMove2( Handle : pointer; x, y : shortint );
procedure DVResize2( Handle : pointer; x, y : shortint );
procedure DVSetAttr( Handle : pointer; color : byte );
procedure DVFrameAttr( Handle : pointer; color : byte );
procedure DVFrameOn( Handle : pointer; b : boolean );
procedure DVWinUnHide( Handle : pointer );
procedure DVWinHide( Handle : pointer );
procedure DVGotoXY( Handle : pointer; x, y : byte );
procedure DVSetVirtualWinSize( Handle : pointer; x, y : byte );
{ -- Manager Streams -- }
procedure DVAllow( Handle : pointer; command : byte );
procedure DVDisallow( Handle : pointer; command : byte );
procedure DVForeOnly( Handle : pointer; b : boolean );
procedure DVMinWinSize( Handle : pointer; x, y : byte );
procedure DVMaxWinSize( Handle : pointer; x, y : byte );
procedure DVForceForeground( Handle : pointer );
procedure DVForceBackground( Handle : pointer );
procedure DVTopProcess( Handle : pointer );
procedure DVBottomProcess( Handle : pointer );
{ ---- Query Streams ---- }
procedure DVQSize( Handle : pointer; var x, y : byte );
procedure DVQPos( Handle : pointer; var x, y : shortint );
procedure DVQVirtualWinSize( Handle : pointer; var x, y : byte );
function  DVWhereX( Handle : pointer ) : shortint;
function  DVWhereY( Handle : pointer ) : shortint;

Implementation

function DVInit : pointer;
begin
 { get DESQview version & get our window handle }
 DVGetVersion;
 if InDV then DVInit:=DVGetHandle(1);
end;

procedure DVGetVersion; assembler;
asm
 { get DESQview version/set InDV flag }
 mov cx,'DE'
 mov dx,'SQ'
 mov ax,2b01h
 int 21h
 cmp al,0ffh
 je @GV1
 mov DV_Version,bx
 mov InDV,True
 jmp @GV2
@GV1:
 mov InDV,False
@GV2:
end;

function DVGetShadowSeg( VideoSeg : word ) : word; assembler;
asm
 { get task's shadow buffer & start shadowing }
 mov ax,VideoSeg
 mov es,ax
 mov di,0
 mov ah,0feh
 int 10h
 mov ax,es
 { di=offset ??don't know if used?? }
end;

procedure DVPause; assembler;
asm
 { give up CPU time }
 mov ax,1000h
 int $15
end;

procedure DVBeginC; assembler;
asm
 { begin critical region }
 mov ax,101bh
 int $15
end;

procedure DVEndC; assembler;
asm
 { end critical region }
 mov ax,101ch
 int $15
end;

function DVAPPNum : word; assembler;
asm
 { get application's switch number }
 mov ax,0de07h
 int 15h
end;

procedure DVSendMsg( Handle : pointer; _BH, _BL : byte;
                      size : word; var param ); assembler;
asm
 std           { string goes backwards }
 mov dx,sp     { save sp }

 mov cx,size   { load size of param }
 jcxz @SM2     { if zero then don't push anything }

 mov bx,ds     { save ds }

 lds si,param  { load address of param }
 add si,cx     { start from the top }
 dec si        { minus 2 }
 dec si        { ^^^^^^^ }
 shr cx,1      { cx:=cx div 2 }
@SM1:
 lodsw         { load 1 word }
 push ax       { push it }
 loop @SM1      { if cx > 0 loop }

 mov ds,bx     { restore ds }
@SM2:
 les di,Handle { get handle }
 mov ax,es     { move es to ax for compare }
 cmp ax,0      { if segment is 0 then }
 je @SM3       { don't push handle }
 push es       { push segment }
 push di       { push offset }
@SM3:
 mov ah,$12
 mov bh,_bh
 mov bl,_bl
 int $15       { call dv }

 cld           { string goes forward }
 mov ax,sp     { calculate the number of }
 mov cx,dx     { returned parameter(s) }
 sub cx,ax     { in stack }

 jcxz @SMX      { exit if none }
 les di,param  { load address of param }
 add di,size
 shr cx,1      { cx:=cx div 2 }
@SM4:
 pop ax
 stosw
 loop @SM4
@SMX:
end;

function DVGetHandle( HandleType : byte ) : pointer; assembler;
asm
 { return object handle }
 mov ah,$12
 mov bh,$00
 mov bl,HandleType
 int $15
 pop ax
 pop dx
end;

procedure DVSound( Handle : pointer; frequency, duration : word ); assembler;
asm
 { generate a sound }
 mov ax,$1019
 mov bx,frequency
 mov cx,duration   { in 18.2 ticks/sec }
 int $15
end;

procedure DVError( handle : pointer; xsize, ysize : byte; msg : string; params: byte);
assembler;
asm
 { pop-up an error box }
 {
   use DVERRORxxxxx for PARAMS
   example: DVError(Handle1, 80, 25, 'Don't Touch That!',
                    DVErrorMouEither+DVErrorBeep);
 }
 mov ch,xsize
 mov cl,ysize;
 mov bh,params
 les dx,Handle
 mov dx,es
 les di,msg
 mov bl,es:[di]
 inc di
 mov ax,$101F
 int $15
end;

procedure DVAPILevel( major, minor : byte ); assembler;
asm
 { define the minimum API revision level than the program requires }
 mov bh,major
 mov bl,minor
 mov ax,0de0bh
 int 15h
end;

procedure DVStream( handle : pointer; mode : byte; params : string );
var
 Msg : Msg_Write2;
begin
 { send a stream of opcode(s) }
 DVArray[1]:=$1B;
 DVArray[2]:=mode; { stream mode }
 DVArray[3]:=length(params);
 DVArray[4]:=00;
 move(params[1],DVArray[5],length(params));
 with Msg do
  begin
   Str:=@DVArray;
   Len:=Length(params)+4;
  end;
 DVSendMsg(Handle, $05, ord((handle=nil)), sizeof(Msg), Msg);
 { Meaning of "ord((handle=nil))" }
 { If handle=nil then return 1 else return 0 }
end;

procedure DVWrite( Handle : pointer; s : string );
var
 Msg : Msg_Write2;
begin
 { write a string }
 with Msg do
  begin
   str:=@s[1];
   len:=length(s);
  end;
 DVSendMsg(Handle, $05, Ord((Handle=Nil)),  Sizeof(Msg), Msg );
end;

procedure DVWriteln( Handle : pointer; s : string );
begin
 DVWrite(Handle, s+#13#10 );
end;

function DVNewWin( x, y : word ) : pointer;
var
 Msg : Msg_Write2_NewWin;
begin
 { allocate new window ( X and Y are the window's size & virtual size }
 DVArray[1]:=$1B;
 DVArray[2]:=$00;
 DVArray[3]:=$04;
 DVArray[4]:=$00;
 DVArray[5]:=$E6;
 DVArray[6]:=y; { Y-Size }
 DVArray[7]:=x; { X-Size }
 With Msg do
  begin
   Len:=$07;
   Str:=@DVArray;
   Handle:=Nil;
   DVSendMsg( Nil, $05, $01, Sizeof(Msg)-4, Msg);
   DVNewWin:=Handle;
  end;
end;

procedure DVFree( var Handle : pointer );
begin
 { free a handle (close a window/free a timer/etc..) }
 DVSendMsg(Handle, $02, $00, $00, Handle );
 Handle:=Nil;
end;

function DVTimer_New : pointer;
var
 Handle : pointer;
begin
 { allocate a new timer }
 DVSendMsg( Nil, $01, $0B, $00, Handle );
 DVTimer_New:=Handle;
end;

procedure DVTimer_Start( Handle : pointer; Time : longint );
begin
 { start a timer countdown (TIME is in 1/100 of a second) }
 DVSendMsg(Handle, $0a, $00, sizeof(Time), Time);
end;

function DVTimer_Len( Handle : pointer ) : longint;
var
 Len : longint;
begin
 { get current timer value (in 1/100 of a second) }
 DVSendMsg(Handle, $09, $00, $00, Len);
 DVTimer_Len:=Len;
end;

{ ---- Window Streams ---- }

procedure DVClear( Handle : pointer );
begin
 { clear window }
 DVStream(Handle, WinStream, chr($E3))
end;

procedure DVRedraw( Handle : pointer );
begin
 { redraw window }
 DVStream(Handle, WinStream, chr($E4))
end;

procedure DVResize( Handle : pointer; x, y : byte );
begin
 { resize window }
 DVStream(Handle, WinStream, chr($C3)+chr(y)+chr(x));
end;

procedure DVMove( Handle : pointer; x, y : shortint );
begin
 { move the window }
 DVStream(Handle, WinStream, chr($C2)+chr(y)+chr(x))
end;

procedure DVTitle( Handle : pointer; title : string );
begin
 { change window title }
 DVStream(Handle, WinStream, chr($EF)+title[0]+title)
end;

procedure DVMove2( Handle : pointer; x, y : shortint );
begin
 { set window position relative to the current position  }
 { use negative (-1) values to move up/left }
 DVStream(Handle, WinStream, chr($CA)+chr(y)+chr(x));
end;

procedure DVResize2( Handle : pointer; x, y : shortint );
begin
 { set window size relative to the current size  }
 { use negative (-1) values to shrink window }
 DVStream(handle, WinStream, chr($CB)+chr(y)+chr(x));
end;

procedure DVSetAttr( Handle : pointer; color : byte );
begin
 { set the output color }
 DVStream(Handle, WinStream, chr($E2)+chr(color));
end;

procedure DVFrameAttr( Handle : pointer; color : byte );
begin
 { set the frame color }
 DVStream(Handle, WinStream, chr($ED)+chr($FF)+chr($08)+
          chr(color)+chr(color)+chr(color)+chr(color)+
          chr(color)+chr(color)+chr(color)+chr(color));
end;

procedure DVFrameOn( Handle : pointer; b : boolean );
begin
{ must use DVRedraw to remove the frame }
 if b then DVStream(Handle, WinStream, chr($D6))
  else DVStream(Handle, WinStream, chr($D7))
end;

procedure DVWinUnHide( Handle : pointer );
begin
 { unhide a window }
 DVStream(Handle, WinStream, chr($D4));
end;

procedure DVWinHide( Handle : pointer );
begin
 { hide a window }
 DVStream(Handle, WinStream, chr($D5));
end;

procedure DVGotoXY( Handle : pointer; x, y : byte );
begin
 { positions the cursor at X, Y }
 DVStream(Handle, WinStream, chr($C0)+chr(y-1)+chr(x-1));
end;

procedure DVSetVirtualWinSize( Handle : pointer; x, y : byte );
begin
 { set window's virtual size }
 DVStream(Handle, WinStream, chr($AB)+chr(x));
 DVStream(Handle, WinStream, chr($AA)+chr(y));
end;

{ ---- Query Streams ---- }

procedure DVQSize( Handle : pointer; var x, y : byte );
begin
 { get the window size }
 DVStream(Handle, QueryStream, chr($C3));
 { result is in DVArray[6..7] }
 y:=DVArray[6];
 x:=DVArray[7];
end;

procedure DVQPos( Handle : pointer; var x, y : shortint );
begin
 { get the window position }
 DVStream(Handle, QueryStream, chr($C2));
 { result is in DVArray[6..7] }
 y:=DVArray[6];
 x:=DVArray[7];
end;

procedure DVQVirtualWinSize( Handle : pointer; var x, y : byte );
begin
 { get virtual window size }
 DVStream(Handle, QueryStream, chr($AA));
 Y:=DVArray[6];
 DVStream(Handle, QueryStream, chr($AB));
 X:=DVArray[6];
end;

function DVWhereX( Handle : pointer ) : shortint;
begin
 { return the cursor's X position }
 DVStream( Handle, QueryStream, chr($A1) );
 DVWhereX:=DVArray[6];
end;

function DVWhereY( Handle : pointer ) : shortint;
begin
 { return the cursor's Y position }
 DVStream( Handle, QueryStream, chr($A0) );
 DVWhereY:=DVArray[6];
end;

{ --- Manager Stream Procedures --- }

procedure DVAllow( Handle : pointer; command : byte );
begin
 { disallow a command (see constants "MStream_xxxxxx") }
 DVStream(Handle, ManagerStream, chr(command));
end;

procedure DVDisallow( Handle : pointer; command : byte );
begin
 { disallow a command (see constants "MStream_xxxxxx") }
 DVStream(Handle, ManagerStream, chr(command+$20));
end;

procedure DVForeOnly( Handle : pointer; b : boolean );
begin
 { B=TRUE if application runs on foreground only }
 if b then DVStream(Handle, ManagerStream, chr($86))
  else DVStream(Handle, ManagerStream, chr($87));
end;

procedure DVMinWinSize( Handle : pointer; x, y : byte );
begin
 { define window's minimum size }
 DVStream(Handle, ManagerStream, chr($88)+chr(y)+chr(x));
end;

procedure DVMaxWinSize( Handle : pointer; x, y : byte );
begin
 { define window's maximum size }
 DVStream(Handle, ManagerStream, chr($89)+chr(y)+chr(x));
end;

procedure DVForceForeground( Handle : pointer );
begin
 { force process to run into foreground }
 DVStream(Handle, ManagerStream, chr($C1));
end;

procedure DVForceBackground( Handle : pointer );
begin
 { force process to run into background }
 DVStream(Handle, ManagerStream, chr($C9));
end;

procedure DVTopProcess( Handle : pointer );
begin
 { make current window topmost in process }
 DVStream( Handle, ManagerStream, chr($C2) );
end;

procedure DVBottomProcess( Handle : pointer );
begin
 { make current window bottom-most in process }
 DVStream( Handle, ManagerStream, chr($CA) );
end;

end.

