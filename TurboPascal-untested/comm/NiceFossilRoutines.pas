(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0093.PAS
  Description: Nice Fossil Routines
  Author: MICHAEL HOENIE
  Date: 11-22-95  13:27
*)

{
Since there has been a couple people asking for COMM routines here, I
thought I would post my source code from my DOOR game GRUNT! They are
FOSSIL routines that will work well with BNU.
}
 (*
 ┌─┐┌─────────────────────────────────────────────────────────────────────────┐
 │*││▄█████▄ ██████▄ ██   ██ ▄█████▄ ███████                                  │
 │*││██  ▄▄▄ ██   ██ ██   ██ ██   ██   ▐█▌                                    │
 │*││██   ██ ██████  ██   ██ ██   ██   ▐█▌                                    │
 │*││▀█████▀ ██  ▀██ ▀█████▀ ██   ██   ▐█▌                                    │
 └─┘└─────────────────────────────────────────────────────────────────────────┘
 ┌─┐┌─────────────────────────────────────────────────────────────────────────┐
 │*││ (c)1995 by Michael S. Hoenie - All Rights Reserved.                     │
 └─┘└─────────────────────────────────────────────────────────────────────────┘
  *)

  unit fossil;

  {$S-,V-,R-}

  interface uses dos;

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

  procedure fossil_send(ch: char);
  procedure fossil_send_string(S:STRING);
  function fossil_receive(var ch: char): boolean;
  function fossil_carrier_drop: boolean;
  function fossil_carrier_present: boolean;
  function fossil_buffer_check: boolean;
  function fossil_init_fossil: boolean;
  procedure fossil_deinit_fossil;
  procedure fossil_flush_output;
  procedure fossil_purge_output;
  procedure fossil_purge_input;
  procedure fossil_set_dtr(state: boolean);
  procedure fossil_watchdog_on;
  procedure fossil_watchdog_off;
  procedure fossil_warm_reboot;
  procedure fossil_cold_reboot;
  procedure fossil_Set_baud(n: integer);
  procedure fossil_set_flow(SoftTran,Hard,SoftRecv: boolean);
  procedure fossil_Buffer_Status(var Insize,Infree,OutSize,Outfree: word);

  implementation

  procedure fossil_send(ch: char);
  var
   regs: registers;
  begin;
   regs.al:=ord(ch);
   regs.dx:=port_num;
   regs.ah:=1;
   intr($14,regs);
  end;

  procedure fossil_send_string(S:STRING);
  var
   a: integer;
  begin;
   for a:=1 to length(s) do fossil_send(s[a]);
  end;

  function fossil_receive(var ch: char): boolean;
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
    fossil_receive:=true;
   end else fossil_receive:=false;
  end;

  function fossil_carrier_drop: boolean;
  var
   regs: registers;
  begin;
   regs.ah:=3;
   regs.dx:=port_num;
   intr($14,regs);
   if (regs.al and $80)<>0 then
     fossil_carrier_drop:=false
       else fossil_carrier_drop:=true;
  end;

  function fossil_carrier_present: boolean;
  var
   regs: registers;
  begin;
   regs.ah:=3;
   regs.dx:=port_num;
   intr($14,regs);
   if (regs.al and $80)<>0 then
      fossil_carrier_present:=true else
        fossil_carrier_present:=false;
  end;

  function fossil_buffer_check: boolean;
  var
   regs: registers;
  begin;
   regs.ah:=3;
   regs.dx:=port_num;
   intr($14,regs);
   if (regs.ah and 1)=1 then fossil_buffer_check:=true else
     fossil_buffer_check:=false;
  end;

  function fossil_init_fossil: boolean;
  var
   regs: registers;
  begin;
   regs.ah:=4;
   regs.bx:=0;
   regs.dx:=port_num;
   intr($14,regs);
   if regs.ax=$1954 then fossil_init_fossil:=true else
     fossil_init_fossil:=false;
  end;

  procedure fossil_deinit_fossil;
  var
   regs: registers;
  begin;
   regs.ah:=5;
   regs.dx:=port_num;
   intr($14,regs);
  end;

  procedure fossil_set_dtr(state: boolean);
  var
   regs: registers;
  begin;
   regs.ah:=6;
   if state then regs.al:=1 else regs.al:=0;
   regs.dx:=port_num;
   intr($14,regs);
  end;

  procedure fossil_flush_output;
  var
   regs: registers;
  begin;
   regs.ah:=8;
   regs.dx:=port_num;
   intr($14,regs);
  end;

  procedure fossil_purge_output;
  var
   regs: registers;
  begin;
   regs.ah:=9;
   regs.dx:=port_num;
   intr($14,regs);
  end;

  procedure fossil_purge_input;
  var
   regs: registers;
  begin;
   regs.ah:=$0a;
   regs.dx:=port_num;
   intr($14,regs);
  end;

  procedure fossil_watchdog_on;
  var
   regs: registers;
  begin;
   regs.ah:=$14;
   regs.al:=01;
   regs.dx:=port_num;
   intr($14,regs);
  end;

  procedure fossil_watchdog_off;
  var
   regs: registers;
  begin;
   regs.ah:=$14;
   regs.al:=00;
   regs.dx:=port_num;
   intr($14,regs);
  end;

  procedure fossil_warm_reboot;
  var
   regs: registers;
  begin;
   regs.ah:=$17;
   regs.al:=01;
   intr($14,regs);
  end;

  procedure fossil_cold_reboot;
  var
   regs: registers;
  begin;
   regs.ah:=$17;
   regs.al:=00;
   intr($14,regs);
  end;

  procedure fossil_set_baud(n: integer);
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
    else regs.al:=regs.al or $00;
   end;
   intr($14,regs);
  end;

  procedure fossil_set_flow(SoftTran,Hard,SoftRecv: boolean);
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

  procedure fossil_get_fossil_data;
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

  procedure fossil_Buffer_Status(var Insize,Infree,OutSize,Outfree: word);
  begin;
   fossil_get_fossil_data;
   insize:=fossildata.ibufr;
   infree:=fossildata.ifree;
   outsize:=fossildata.obufr;
   outfree:=fossildata.ofree;
  end;

  end.


