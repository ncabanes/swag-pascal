(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0061.PAS
  Description: OS/2 COMM Dumb Terminal
  Author: B.J. GUILLOT
  Date: 05-26-95  23:23
*)

{
> I've been wondering this for quite awhile now - Is there a way to access
> the communication ports in OS/2 using Borland Pascal. I'd like to create
> a BBS app?

Here's some code that I've put toegether that should get you in the right
direction (it's a dumb terminal program for OS/2):
}
program dt2;

uses
  dosprocs, os2subs;

Const
  ExtKeyChar : Char = #0;

  Function KeyPressed : Boolean;
  Var
    KeyInfo : TKbdKeyInfo;
  Begin
    KbdPeek(KeyInfo,0);
    KeyPressed:= (ExtKeyChar <> #0) or ((KeyInfo.fbStatus And $40) <> 0);
  End;

  Function ReadKey : Char;
  Var
    KeyInfo : TKbdKeyInfo;
  Begin
    If ExtKeyChar <> #0 then
      Begin
        ReadKey:= ExtKeyChar;
        ExtKeyChar:= #0
      End
    else
      Begin
        KbdCharIn(KeyInfo,0,0);
        If KeyInfo.chChar = #0 then
          ExtKeyChar:= KeyInfo.chScan;
        ReadKey:= KeyInfo.chChar;
      End;
  End;

type
  mdmlinerec = record
    databits : byte;
    parity   : byte;
    stopbits : byte;
  end;
  mdmctlrec = record
    onmask   : byte;
    offmask  : byte;
  end;
  mdmdcbrec = record
    wtime    : word;
    rtime    : word;
    flags1   : byte;
    flags2   : byte;
    flags3   : byte;
    errchar  : byte;
    brkchar  : byte;
    xonchar  : byte;
    xoffchar : byte;
  end;
  siodterec = record
    dte      : longint;
    fraction : byte;
  end;
  bufstatrec = record
    bufused  : word;
    bufsize  : word;
  end;
  dtestatrec = record
    dterate  : longint;
    dtefract : byte;
    mindte   : longint;
    minfract : byte;
    maxdte   : longint;
    maxfract : byte;
  end;

var
  comh : word;
  mdmline : mdmlinerec; mdmctl : mdmctlrec; mdmdcb : mdmdcbrec;
  siodte : siodterec; bufstat : bufstatrec; dtestat : dtestatrec;

function si(s : string) : longint;
var
  i : longint; c : word;
begin
  si := 0;
  val(s, i, c);
  if c = 0 then
    si := i;
end;

procedure sendport(s : string);
var
  i, written : word;
begin
  for i := 1 to length(s) do
    doswrite(comh, s[i], 1, written);
end;

procedure funcall(s : string; w : word);
begin  { shows what DLL call generates error if any }
  if w > 0 then begin
    writeln('Error ['+s+']; result code: ', w);
    halt;
  end;
end;

function carrier : boolean;
var
  mdminsig : byte;
begin
  funcall('Check DCD', dosdevioctl(@mdminsig, nil, 103, 1, comh));
  if (mdminsig and 128) = 128 then
    carrier := true
  else
    carrier := false;
end;

function getdte : longint;
var
  baud : word;
begin
  funcall('SIO.SYS Grab DTE', dosdevioctl(@dtestat, nil, 99, 1, comh));
  { funcall('COM.SYS Get DTE', dosdevioctl(@baud, nil, $61, 1, comh)); }
  getdte := dtestat.dterate;
end;

function rcvbufused : word;
begin
  funcall('Check Rcv Buff', dosdevioctl(@bufstat, nil, 104, 1, comh));
  rcvbufused := bufstat.bufused;
end;

procedure initcomm(cport : byte; dte : longint);
var
   action, comerr : word;
  comstr : string[6];
  portz : array[1..5] of char;
begin
  { This routine is based off of OS2COMM.C's INITCOMM function done in
  1988 by Jim Gilliland }
  comerr := 0;
  comstr := 'COM'+chr(48+cport)+#0;
  move(comstr[1], portz, 5);
  funcall('Open Port', dosopen(@portz, comh, action, 0, 0, 1, 66, 0));
  { note: 66 means "deny none" access to com port }
  writeln('Initial DTE [', getdte, ']');
  if dte > 57600 then begin { for speeds > 57600, use SIO function 43h }
    siodte.dte := dte;  { I hope you are using SIO }
    siodte.fraction := 0;
    funcall('Set SIO DTE', dosdevioctl(nil, @siodte, 67, 1, comh));
  end else
    funcall('Set DTE Rate', dosdevioctl(nil, @dte, 65, 1, comh));
  mdmline.databits := 8;
  mdmline.parity := 0; { N-parity }
  mdmline.stopbits := 0; { 1-stop bit }
  funcall('Set N81', dosdevioctl(nil, @mdmline, 66, 1, comh));
  mdmctl.onmask := 3; { DTR/RTS on }
  mdmctl.offmask := 255; { nothing off }
  funcall('Set DTR/RTS', dosdevioctl(@comerr, @mdmctl, 70, 1, comh));
  mdmdcb.wtime := 10;
  mdmdcb.rtime := 10;
  mdmdcb.flags1 := 1;
  mdmdcb.flags2 := 64;
  mdmdcb.flags3 := 4;
  mdmdcb.errchar := 0;
  mdmdcb.brkchar := 0;
  mdmdcb.xonchar := 17;
  mdmdcb.xoffchar := 19;
  funcall('Set DCB', dosdevioctl(nil, @mdmdcb, 83, 1, comh));
end;

procedure dumbterm;
var
  i, w : word;
  ch : char;
  incom : array[1..512] of char;
begin
  writeln;
  writeln('[VERY DUMB TERMINAL/2 0.1] **** USE CTRL-Z TO EXIT THE PROGRAM ****');
  sendport('ATZ'+#13); { example initialization string }
  repeat
    if keypressed then begin
      ch := readkey;
      doswrite(comh, ch, 1, w);
    end else begin
      if dosread(comh, incom, 512, w) = 0 then begin
        for i := 1 to w do
          write(incom[i]);
      end;
    end;
  until(ch = #26);
end;

var
  dte : longint;
  cport : byte;
  version : word;
begin
  if paramcount < 2 then begin
    writeln(' Syntax: DT port dte');
    writeln('Example: DT 3 115200');
    halt;
  end;
  cport := si(paramstr(1));
  dte := si(paramstr(2));
  dosgetversion(version);
  writeln('Program written by B.J. Guillot [BGFAX author] Nov 1994');
  writeln('Fido 1:106/400   Internet email: bjg90783@jetson.uh.edu');
  writeln('Program written for German 16-bit OS/2 patch for BP 7.0');
  writeln;
  writeln('Port [', cport, ']  DTE [', dte, ']');
  initcomm(cport, dte); { initialies the port and grabs com handle }
  dumbterm;
  writeln('Closing port...');
  writeln(dosclose(comh));
end.


