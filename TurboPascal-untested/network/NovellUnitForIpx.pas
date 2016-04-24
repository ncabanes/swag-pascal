(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0061.PAS
  Description: Novell unit for IPX
  Author: KEN JOHNSON
  Date: 01-02-98  07:35
*)

{


 Ken Johnson's Novell unit.
 kjohnso3@chat.carleton.ca
 Some of this stuff may/maynot work. If something doesn't,
 email me.


}

Unit kjnet;
interface
Var
  error : byte;
Const
  week : array[0..6] of string = ('Sunday','Monday','Tuesday','Wednesday'
                                 ,'Thursday','Friday','Saturday');
  personal     = $05;{used for GETMESSAGE}
  broadcast    = $01;
  receiveall         = $00;{used for SETBROADCASTMODE}
  NoUsermessage      = $01;
  StoreServerMessage = $02;
  StoreAllMessages   = $03;

type
diskrec=record
  clockticks:longint;
  objectid:longint;
  diskspace:longint;
  enforced:Byte;
end;

  diskspacerec = record
    len : word;
    clockticks : longint;
    id : longint;
    diskleft : longint;
    restrict : byte;
  end;
  BinderyRec = Record
    ID : longint;
    objtype : word;
    Name : String;
    objectFlag : byte;
    securitylevel : byte;
    propertyflags : byte;
  end;

 NoReturn = record{when the function call}
    Len : Word;    {returns nothing.}
  End;
   Userrec = record
    Name      : string;
    objtype   : word;
    id        : longint;
    logindate : string;
    logintime : string;
    weekday   : string;
    Connection: Byte;
  end;
procedure delnulls(var s : string);
procedure Callint(Ahreg : byte;Var bufferin,bufferout;
                  Var error : Byte);
procedure getdisk(id:longint;var disk : diskrec);

Procedure GetBinderyAccess(var sec : byte;var id : longint);
Function  upcaseStr(s : string) : String;
procedure logout;
function  connectnum : byte;
procedure setbroadcastmode(mode : byte);
function  Getbroadcastmode : byte;
Procedure SendBroadCastMessage(Con : Byte;Message : String);
Function  GetMessage(Func : Byte) : String;
Procedure SendPersonalMessage(Con : Byte;Message : String);
procedure broadcastToConsole(message : string);
function  idnumber : longint;
procedure Getconnectioninfo(Con : byte;Var U : userrec);
function  Connect2ID(Con : byte) : longint;
{procedure getdiskspaceleft(id : longint;var bufferout : diskspacerec);}
procedure ClearConnection(c : byte);
procedure getopenfiles(c : word;var files : array of string;var numf : byte);
procedure scanbindery(objID : Longint;obj : word;name1 : string;
                      var Bin : binderyrec;var error:byte);
function name2id(name : string) : longint;

Function  ConsoleOperator : Boolean;
function fullname(Name : string) : string;
procedure callFint(con : word;var bufferin,bufferout;
                  var e : word);

implementation

Function fullname(Name : string) : string;
Type
  request = record
    len : word;
    sub : byte;
    objtype : word;
    data : array[1..65] of byte;
  end;
  reply = record
    len : word;
    value : array[1..128] of Byte;
    s : byte;
    f : byte;
  end;
var
  reaL:STRING;
  prop:string;
  bufferin : request;
  bufferout : reply;
  x,i : byte;
  Begin
    fillchar(Bufferin,sizeof(BUfferin),0);
    Fillchar(BufferOut,Sizeof(Bufferout),0);
    Bufferout.Len := Sizeof(BufferOut)-2;
    prop := 'IDENTIFICATION';
    with bufferin do
      begin
        Sub := $3d;
        objtype := 256;{I guess tis could be different.}
        i := 1;
        bufferin.data[i] := Length(Name);
        for x := 1 to length(name) do
          begin
            Inc(I);
            bufferin.daTa[i] := ord(name[x]);
          end;
        inc(i);
        bufferin.data[i] := 01;
        inc(i);
        bufferin.data[i] := length(Prop);
        for x := 1 to length(Prop) do
          begin
            Inc(i);
            bufferin.data[i] := ord(prop[x]);
          end;
      end;
    bufferin.len := 3+I;
   callint($e3,Bufferin,bufferout,error);
   i := 1;
   While Not(Chr(Bufferout.value[i]) = '') and not (I = 128)do
     begin
       real[i] := Chr(Bufferout.Value[i]);
       Inc(I);
     end;
     real[0] := chr(I);
     delnulls(real);
     fullname:=real;
  End;

{--------------------------------------------------------------------------}
procedure getpriv(Var bufferin,bufferout;Var e : Byte);Assembler;
  asm
    push ds
    mov ah,$e3
    lds si,bufferin
    les di,bufferout
    int $21
    mov [byte ptr e],al
    pop ds
  end;
{----------------------------------------------------------------------}
function name2id(name : string) : longint;
type
  request=record
    len:word;
    sub:byte;
    obtype:word;
    name:array[1..49] of char;
  end;
  reply = record
    len:word;
    id:longint;
    objtype:word;
    name : array[1..48] of char;
  end;
var
 bufferin:request;
 bufferout:reply;
 x:byte;
  begin
    bufferin.len := 3+Length(name)+1;
    bufferin.sub:=$35;
    bufferin.obtype:=(256);
    for x := 0 to length(name) do
      begin
        bufferin.name[x+1] := name[x];
      end;

   fillchar(bufferout,sizeof(bufferout),0);
   bufferout.len:=$36;
   callint($e3,bufferin,bufferout,error);
   name2id := (bufferout.id);
  end;
{--------------------------------------------------------------------------}
Function ConsoleOperator : Boolean;
type
  request = record
    len : Word;
    Sub : Byte;
  end;
var
  bufferin : request;
  bufferout : noreturn;
  begin
    Bufferin.len := 1;
    bufferin.Sub := $c8;
    getpriv(bufferin,bufferout,error);
    if error = $c6 Then consoleoperator := False
    else consoleoperator := true;
  end;
{--------------------------------------------------------------------------}
procedure getdisk(id:longint;var disk : diskrec);
type
  request = record
    len:word;
    sub:byte;
    id1:Longint;
  end;
  reply = record
    len:word;
    a:array[1..3]of longint;
    enforced:byte;
  end;
var
  bufferin:request;
  bufferout:reply;
  u:userrec;
  begin

    bufferin.len:=5;
    bufferin.sub:=$e6;
    bufferin.id1:=(id);
    fillchar(Bufferout,sizeof(bufferout),0);
    bufferout.len:=sizeof(bufferout)-2;
    callint($e3,bufferin,bufferout,error);

    with bufferout do
      begin
        disk.clockticks := SWAP(a[1]);
        disk.objectid:=SWAP(a[2]);
        disk.diskspace:=swap(a[3]);
        disk.enforced:=enforced;
      end;
  end;

{--------------------------------------------------------------------------}
procedure scanbindery(objID : Longint;obj : word;name1 : string;
                      var Bin : binderyrec;var error : byte);
type
  request = record
    len : word;
    sub : byte;
    id  : longint;
    ot  : word;
    namelen : byte;
    namedata : array[1..47] of char;
  end;
  reply = record
    len : word;
    id  : longint;
    ot  : word;
   name : array[1..48] of char;
   flag : byte;
   lev  : byte;
   prop : byte;
  end;
var{this works man}
  bufferin : request;
  bufferout : reply;
  x,i : byte;
  name:string;
  begin
    name:=name1;
    upcaseStr(name);
    fillchar(Bufferin,sizeof(Bufferin),0);
    with bufferin do
      begin
        sub := $37;
        id := objid;
        ot := obj;
        i := 0;
        namelen := length(name);
        for x := 1 to length(Name) do
          begin
            inc(i);
            namedata[i] := name[x];
          end;
        len := length(Name)+8;
      end;
    bufferout.len := sizeof(Bufferout)-2;
   callint($e3,bufferin,bufferout,error);
   With BUfferout do
     begin
       bin.id := id;
       bin.objtype := ot;
       for i := 1 to 48 do
         bin.name[i] := bufferout.name[i];
       bin.name[0] := chr(i);
       bin.objectflag := flag;
       bin.securitylevel := lev;
       bin.propertyflags := prop;
     end;
  end;
{------------------------------------------------------------------------}
procedure callFint(con : word;var bufferin,bufferout;
                  var e : word);assembler;
  asm
    push ds
    mov ax,$f217
    mov cx,con
    lds si,bufferin
    les di,bufferout
    int $21
    mov [word ptr e],ax
    pop ds
  end;
{------------------------------------------------------------------------}
procedure sortthese(num : word;B : array of byte;var files : array of string);
var
  W,x,i : integer;
  len : byte;
  oldi : integer;
  begin
    i := 16;
    x := -1;
      repeat
         INC(x);
         files[x][0] := chr(B[i]);{length}
         len := b[i];
         inc(i);
         OldI := i;
         for w := 1 to len do
           begin
             files[x][w] := chr(b[i]);
             inc(i);
             if oldI > i+16 Then Break;
           end;
         inc(I,16);

      until x = num;

  end;
{------------------------------------------------------------------------}
procedure getopenfiles(c : word;var files : array of string;var numf : byte);
type
  request = record
    len : word;
    sub : byte;
    con : word;
    lastrec : word;
  end;
  reply = record
    nextrecord : word;
    numberofrecords : word;
    RawReplyData : array[1..508] of Byte;
  end;
var
  bufferin  : request;
  bufferout : reply;
  i,x,l : word;
  error : word;
  begin
    fillchar(files,sizeof(Files),0);
    for i := 11 to 13 do
       begin
         fillchar(Bufferin,sizeof(Bufferin),0);
         fillchar(Bufferout,sizeof(Bufferout),0);
         with bufferin do
           begin
             len := $5;
             sub := $eb;
             con := c;
             lastrec := $00;
           end;
         callFint(bufferin.con,bufferin,bufferout,error);
         if (Bufferout.numberofrecords > 0) Then
            begin
              numf := bufferout.numberofrecords;
              sortthese(bufferout.numberofrecords,bufferout.rawreplydata,files);
              exit;
            end;
   end;
   end;

{------------------------------------------------------------------------}
procedure ClearConnection(c : byte);
type
  request = record
    len : word;
    sub : byte;
    con : byte;
  end;
var
  bufferin : request;
  bufferout : noreturn;
  begin
    bufferin.len := 2;
    bufferin.sub := $d2;
    bufferin.con := c;
    callint($e3,bufferin,bufferout,error);
  end;
{------------------------------------------------------------------------}
function  Connect2ID(Con : byte) : longint;
var
  u : userrec;
  begin
    getconnectioninfo(con,u);
    connect2id := u.id;
  end;
{------------------------------------------------------------------------}
procedure getdiskspaceleft(id : longint;var bufferout : diskspacerec);
type
  request = record
    len : word;
    sub : byte;
    oid : longint;
  end;                {works. page 367}
var
  bufferin : request;
  begin
    with bufferin do
      begin
        len := 5;
        sub := $e6;
        oid := id;
      end;
  fillchar(Bufferout,sizeof(Bufferout),0);
  bufferout.len := sizeof(Bufferout)-2;
  callint($e3,bufferin,bufferout,error);
  end;
{------------------------------------------------------------------------}
procedure delnulls(var s : string);
var
  x : byte;
  temp : string;
  begin
    for x := 1 to length(S) do
      begin
        if s[x] = #0 Then
          Begin
            s[0] := chr(X-1);
            exit;
          End;
      end;
  end;
{------------------------------------------------------------------------}
procedure Callint(Ahreg : byte;Var bufferin,bufferout;
                  Var error : Byte);assembler;
asm
  xor ax,ax

  push ds
  mov ah,ahreg
  lds si,bufferin
  les di,bufferout
  int 21h
  pop ds
  mov [byte ptr error],al
end;
{------------------------------------------------------------------------}
Procedure GetBinderyAccess(var sec : byte;var id : longint);
Type
  request = record
    len : word;
    sub : byte;
  end;
 reply = record
   len : word;
   level : byte;
   oid : longint;
 end;
var
  bufferin : request;
  bufferout : reply;
  Begin
    bufferin.len := 1;{page 328. works}
    bufferin.sub := $46;
    fillchar(Bufferout,sizeof(bufferout),0);
    bufferout.len := 5;
    callint($e3,bufferin,bufferout,error);
    sec := bufferout.level;
    id := bufferout.oid;
  End;
{------------------------------------------------------------------------}
Function upcaseStr(s : string) : String;
var x : byte;
  begin
    for x := 1 to Length(s) do
    S[x] := Upcase(S[x]);
    upcaseStr := s;
  end;
{------------------------------------------------------------------------}
procedure logout;assembler;
  asm
    mov ah,$d7
    int 21h
    mov [byte ptr error],al
  end;
{------------------------------------------------------------------------}
function connectnum : byte;assembler;
  asm
    mov ah,$dc
    int 21h{connectnum stored in al. should return}
  end;
{------------------------------------------------------------------------}
procedure setbroadcastmode(mode : byte);assembler;
  asm
    mov ah,$de
    mov dl,mode{page 374}
    int 21h
  end;
{------------------------------------------------------------------------}
function Getbroadcastmode : byte;assembler;
  asm
    mov ah,$de
    mov dl,$04           {page 374}
    int 21h{broadcastmode stored in al}
  end;
{------------------------------------------------------------------------}
Procedure SendBroadCastMessage(Con : Byte;Message : String);
Type
  Request = Record
    Len : Word;
    sub : byte;
    Stuff : array[1..157] of byte;
  End;
  reply = record
    len : word;
    num : byte;
    list : array[1..100] of byte;
  end;
Var
  Bufferin : request;
  bufferout : reply;
  i,x : byte;
  Begin
    fillchar(Bufferin,Sizeof(Bufferin),0);
    fillchar(BufferOut,Sizeof(BufferOut),0);
    With Bufferin do
      begin
        len := Length(message)+4;
        Sub := $00;                          {works. page 374}
        I := 1;
        Stuff[i] := 1;{connect num}
        Inc(I);
        Stuff[i] := Con;
        Inc(I);
        Stuff[i] := Length(Message);
        Inc(I);
        for x := 1 to Length(Message) do
          Begin
            stuff[i] := ord(Message[x]);
            inc(I);
          end;
      end;
    callInt($e1,Bufferin,Bufferout,Error);
  End;
{------------------------------------------------------------------------}
Function GetMessage(Func : Byte) : String;
Type
  Request = Record
    Len : Word;
    Sub : Byte;
  End;
  Reply = Record
    Len  : Word;
    messlen : Byte;
    mess : array[1..126] of byte;
  End;
Var                      {page 376 & 375}
  Bufferin : request;
  BufferOut : Reply;
  duh,x : byte;
  Begin
    getmessage := '';
    fillchar(Bufferin,Sizeof(Bufferin),0);
    Fillchar(Bufferout,Sizeof(Bufferout),0);
    Bufferin.Len := 1;
    Bufferin.Sub := Func;{a personal message or a broadcast message}
    bufferout.Len := 128;
    CallInt($e1,Bufferin,BufferOut,Error);

    duh := bufferout.messlen;
    getmessage[0] := chr(duh);
    for x := 1to duh do
        Getmessage[x] := chr(bufferout.mess[x]);
  End;
{------------------------------------------------------------------------}
Procedure SendPersonalMessage(Con : Byte;Message : String);
Type
  request = Record
    Len : Word;
    Sub : Byte;
    Data : array[1..228] Of Byte;
  End;                        {likely works. page 375-376}
  Reply = Record
    Len : word;
    Num : Byte;
    Results : Array[1..100] of byte;
  End;
Var
  Bufferin : request;
  Bufferout : reply;
  x,i : byte;
  Begin
    fillchar(Bufferin,Sizeof(Bufferin),0);
    Fillchar(Bufferout,Sizeof(Bufferout),0);
    Bufferin.sub := $04;
    i := 1;
    bufferin.data[i] := 1;{num of connections}
    Inc(i);
    Bufferin.Data[i] := Con;{which connection number?}
    inc(I);
    Bufferin.data[i] := length(message);{length of message}
    Inc(i);
    For X := 1 to Length(Message) do{actual message}
      Begin
        bufferin.data[i] := ord(message[x]);
        inc(i);
      End;
    Bufferin.Len := 4+Length(message);
    callint($e1,bufferin,bufferout,error);{call the int}
  End;
{------------------------------------------------------------------------}
procedure broadcastToConsole(message : string);
Type
  request = record
    len : word;
    sub : byte;
    Messlen : byte;
    mess : array[1..$3c] of byte;
  end;
var
  bufferin  : request;
  bufferout : noreturn;
  x : byte;
  Begin
    fillchar(Bufferin,Sizeof(Bufferin),0);
    Fillchar(Bufferout,Sizeof(Bufferout),0);
    bufferin.len := 2+length(message);
    bufferin.sub := $09;
    Bufferin.messlen := Length(Message);
    for x := 1 to Length(Message) do
    Bufferin.Mess[x] := ord(message[x]);
    callint($e1,bufferin,bufferout,error);
  End;
{------------------------------------------------------------------------}
function idnumber : longint;
var
  id : longint;
  l : byte;
  begin
    getbinderyaccess(L,id);{just uses this routine}
    idnumber := id;
  end;
{------------------------------------------------------------------------}
procedure Getconnectioninfo(Con : byte;Var U : userrec);
type
  request = record
    len : word;                              {this routine}
    sub : byte;                              {will get all}
    connect : byte;                          {info about a}
  end;                                       {connection..}
  reply = record
    len : word;
    id : longint;
    ot :word;
    stuff : array[1..48] of byte;
    log  : array[0..6] of byte;
  end;
var
  bufferin : request;
  bufferout : reply;
  x,i : byte;
  t1,t2 : string;
  year : string;
  date : string;
  begin
    bufferin.len := 2;
    bufferin.sub := $16;
    bufferin.connect := con;
    fillchar(Bufferout,sizeof(Bufferout),0);
    bufferout.len := sizeof(Bufferout)-2;
    callint($e3,bufferin,bufferout,error);
    u.objtype := bufferout.ot;
    u.id := bufferout.id;
    t1 := '';
    t1[0] := chr(48);
    i := 1;
    for x := 1 to 48 do
      begin
        t1[x] := chr(bufferout.stuff[i]);
        inc(i);
      end;
   t2 := '';
   t2[0] := chr(7);
   i := 48;
   u.name := t1;
   t1 := '';
   with bufferout do
     begin
       str(log[1],t1);{month}
       date := t1+'\';
       str(log[2],t1);
       date := date+t1+'\'; {day}
       str(log[0],t1); {year}
       date := date+t1;
       u.logindate := date;
       str(log[3],t1);{hour}
       date := t1+':';
       str(log[4],t1);
       date := date+T1+':';{min}
       str(log[5],t1);{sec}
       date := date+t1;
       u.logintime := t1;
       u.weekday := Week[log[6]];
     end;
  delnulls(u.name);
  u.connection := con;
  end;
{------------------------------------------------------------------------}
Begin
End.

