(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0045.PAS
  Description: Fossil Driver
  Author: SCOTT BAKER
  Date: 05-26-94  07:29
*)

unit ddfossil;
{$S-,V-,R-}

interface
uses dos;

const
 name='Fossil drivers for TP 4.0';
 author='Scott Baker';
type
 fossildatatype = record
                   strsize: word;
                   majver: byte;
                   minver: byte;
                   ident: pointer;
                   ibufr: word;
                   ifree: word;
                   obufr: word;
                   ofree: word;
                   swidth: byte;
                   sheight: byte;
                   baud: byte;
                  end;
var
 port_num: integer;
 fossildata: fossildatatype;

procedure async_send(ch: char);
procedure async_send_string(s: string);
function async_receive(var ch: char): boolean;
function async_carrier_drop: boolean;
function async_carrier_present: boolean;
function async_buffer_check: boolean;
function async_init_fossil: boolean;
procedure async_deinit_fossil;
procedure async_flush_output;
procedure async_purge_output;
procedure async_purge_input;
procedure async_set_dtr(state: boolean);
procedure async_watchdog_on;
procedure async_watchdog_off;
procedure async_warm_reboot;
procedure async_cold_reboot;
procedure async_Set_baud(n: integer);
procedure async_set_flow(SoftTran,Hard,SoftRecv: boolean);
procedure Async_Buffer_Status(var Insize,Infree,OutSize,Outfree: word);

implementation

procedure async_send(ch: char);
var
 regs: registers;
begin;
 regs.al:=ord(ch);
 regs.dx:=port_num;
 regs.ah:=1;
 intr($14,regs);
end;

procedure async_send_string(s: string);
var
 a: integer;
begin;
 for a:=1 to length(s) do async_send(s[a]);
end;

function async_receive(var ch: char): boolean;
var
 regs: registers;
begin;
 ch:=#0;
 regs.ah:=3;
 regs.dx:=port_num;
 intr($14,regs);
 if (regs.ah and 1)=1 then begin;
  regs.ah:=2;
  regs.dx:=port_num;
  intr($14,regs);
  ch:=chr(regs.al);
  async_receive:=true;
 end else async_receive:=false;
end;

function async_carrier_drop: boolean;
var
 regs: registers;
begin;
 regs.ah:=3;
 regs.dx:=port_num;
 intr($14,regs);
 if (regs.al and $80)<>0 then async_carrier_drop:=false else async_carrier_drop:=true;
end;

function async_carrier_present: boolean;
var
 regs: registers;
begin;
 regs.ah:=3;
 regs.dx:=port_num;
 intr($14,regs);
 if (regs.al and $80)<>0 then async_carrier_present:=true else async_carrier_present:=false;
end;

function async_buffer_check: boolean;
var
 regs: registers;
begin;
 regs.ah:=3;
 regs.dx:=port_num;
 intr($14,regs);
 if (regs.ah and 1)=1 then async_buffer_check:=true else async_buffer_check:=false;
end;

function async_init_fossil: boolean;
var
 regs: registers;
begin;
 regs.ah:=4;
 regs.bx:=0;
 regs.dx:=port_num;
 intr($14,regs);
 if regs.ax=$1954 then async_init_fossil:=true else async_init_fossil:=false;
end;

procedure async_deinit_fossil;
var
 regs: registers;
begin;
 regs.ah:=5;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_set_dtr(state: boolean);
var
 regs: registers;
begin;
 regs.ah:=6;
 if state then regs.al:=1 else regs.al:=0;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_flush_output;
var
 regs: registers;
begin;
 regs.ah:=8;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_purge_output;
var
 regs: registers;
begin;
 regs.ah:=9;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_purge_input;
var
 regs: registers;
begin;
 regs.ah:=$0a;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_watchdog_on;
var
 regs: registers;
begin;
 regs.ah:=$14;
 regs.al:=01;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_watchdog_off;
var
 regs: registers;
begin;
 regs.ah:=$14;
 regs.al:=00;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_warm_reboot;
var
 regs: registers;
begin;
 regs.ah:=$17;
 regs.al:=01;
 intr($14,regs);
end;

procedure async_cold_reboot;
var
 regs: registers;
begin;
 regs.ah:=$17;
 regs.al:=00;
 intr($14,regs);
end;

procedure async_set_baud(n: integer);
var
 regs: registers;
begin;
 regs.ah:=00;
 regs.al:=3;
 regs.dx:=port_num;
 case n of
  300: regs.al:=regs.al or $40;
  1200: regs.al:=regs.al or $80;
  2400: regs.al:=regs.al or $A0;
  4800: regs.al:=regs.al or $C0;
  9600: regs.al:=regs.al or $E0;
  19200: regs.al:=regs.al or $00;
 end;
 intr($14,regs);
end;

procedure async_set_flow(SoftTran,Hard,SoftRecv: boolean);
var
 regs: registers;
begin;
 regs.ah:=$0F;
 regs.al:=00;
 if softtran then regs.al:=regs.al or $01;
 if Hard then regs.al:=regs.al or $02;
 if SoftRecv then regs.al:=regs.al or $08;
 regs.al:=regs.al or $F0;
 Intr($14,regs);
end;

procedure async_get_fossil_data;
var
 regs: registers;
begin;
 regs.ah:=$1B;
 regs.cx:=sizeof(fossildata);
 regs.dx:=port_num;
 regs.es:=seg(fossildata);
 regs.di:=ofs(fossildata);
 intr($14,regs);
end;

procedure Async_Buffer_Status(var Insize,Infree,OutSize,Outfree: word);
begin;
 async_get_fossil_data;
 insize:=fossildata.ibufr;
 infree:=fossildata.ifree;
 outsize:=fossildata.obufr;
 outfree:=fossildata.ofree;
end;

end.

