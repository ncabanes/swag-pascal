(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0167.PAS
  Description: Re: Registration Key unit
  Author: TOM MOORE
  Date: 02-21-96  21:03
*)


{Here is the source code to my unit called EASYKEY: }


{ ********************************************************************* }
{ *************       Easy Key version 1.0a        ******************** }
{ *************           Copyrite 1995            ******************** }
{ *************  by Thomas Moore of Stillwater Ok  ******************** }
{ ********************************************************************* }
{ ********************************************************************* }
{ ********  You may freely use this source code without  ************** }
{ ********  fees or royalities, but you may not compile  ************** }
{ ********  this as your REGISTRATION KEY program to be  ************** }
{ ********  sold.  You may however use this unit in your ************** }
{ ********  programs that you sell as registerable.      ************** }
{ ********************************************************************* }
{ ********************************************************************* }

unit EasyKey;

Interface
const registered: boolean = false;
      regfile: string = 'easykey.reg';

const regcode: array[1..5] of string[40] = ('', '', '', '', '');
const regkey: string[40] = 'KihILijlipienkhppo98656jj;ajggu88k7899o9';
type RegStr = string[40];

procedure CheckRegCode(reg_code: regstr);
procedure CheckForReg;
procedure MakeRegFile(filename, sysop_name, bbs_name: string);

Implementation

var sysop, bbs: string;

procedure MakeRegFile(filename, sysop_name, bbs_name: string);
var rgfil: text;
    i: shortint;
begin
     assign(rgfil, filename);
     rewrite(rgfil);
     writeln(rgfil, sysop_name);
     writeln(rgfil, bbs_name);
     CheckRegCode(sysop_name);
     for i := 1 to 5 do writeln(rgfil, regcode[i]);
     CheckRegCode(bbs_name);
     for i := 1 to 5 do writeln(rgfil, regcode[i]);
     close(rgfil);
end;

procedure CheckForReg;
var reg: text;
    reginfo: array[1..10] of regstr;
    i: integer;
begin
     registered := false;
     begin
          registered := false;
          assign(reg, regfile);
          {$I-} reset(reg) {I+};
          registered := false;
          if ioresult <> 0 then exit;
          {$I-} readln(reg, sysop) {I+};
          Registered := false;
          if ioresult <> 0 then exit;
          while length(sysop) < 40 do sysop := sysop + #32;
          {$I-} readln(reg, bbs) {I+};
          Registered := false;
          if ioresult <> 0 then exit;
          while length(bbs) < 40 do bbs := bbs + #32;
          for i := 1 to 10 do
          begin
               {$I-} readln(reg, reginfo[i]) {I+};
               Registered := false;
               if ioresult <> 0 then exit;
          end;
     end;
     CheckRegCode(sysop);
     for i := 1 to 5 do
        if regcode[i] <>  reginfo[i] then exit;
     Registered := false;
     CheckRegCode(bbs);
     for i := 6 to 10 do
        if regcode[i - 5] <> reginfo[i] then exit;
     registered := true;
end;


procedure CheckRegCode(reg_code: regstr);
var i, x: integer;
    tstr: string[4];
begin
     for i := 1 to 5 do regcode[i] := '';
     while length(reg_code) < 40 do
           Reg_Code := Reg_Code + #32;
     while length(regkey) < 40 do regkey := regkey + regkey;
     for i := 1 to 40 do
     begin
          case i of
            1..8: begin
                      if reg_code[i] < regkey[i] then
                      begin
                         str((ord(regkey[i]) - ord(reg_code[i]))
                             + 1000, tstr);
                         regcode[1] := regcode[1] + tstr + #32;
                      end
                      else
                      if reg_code[i] > regkey[i] then
                      begin
                         str((ord(reg_code[i]) - ord(regkey[i]))
                             + 2000, tstr);
                         regcode[1] := regcode[1] + tstr + #32;
                      end
                      else
                      begin
                           str(ord(regkey[i]) + 3000, tstr);
                           regcode[1] := regcode[1] + tstr + #32;
                      end;
                   end;
            9..16: begin
                      if reg_code[i] < regkey[i] then
                      begin
                         str((ord(regkey[i]) - ord(reg_code[i]))
                             + 1000, tstr);
                         regcode[2] := regcode[2] + tstr + #32;
                      end
                      else
                      if reg_code[i] > regkey[i] then
                      begin
                         str((ord(reg_code[i]) - ord(regkey[i]))
                             + 2000, tstr);
                         regcode[2] := regcode[2] + tstr + #32;
                      end
                      else
                      begin
                           str(ord(regkey[i]) + 3000, tstr);
                           regcode[2] := regcode[2] + tstr + #32;
                      end;
                    end;
            17..24: begin
                      if reg_code[i] < regkey[i] then
                      begin
                         str((ord(regkey[i]) - ord(reg_code[i]))
                             + 1000, tstr);
                         regcode[3] := regcode[3] + tstr + #32;
                      end
                      else
                      if reg_code[i] > regkey[i] then
                      begin
                         str((ord(reg_code[i]) - ord(regkey[i]))
                             + 2000, tstr);
                         regcode[3] := regcode[3] + tstr + #32;
                      end
                      else
                      begin
                           str(ord(regkey[i]) + 3000, tstr);
                           regcode[3] := regcode[3] + tstr + #32;
                      end;
                    end;
            25..32: begin
                      if reg_code[i] < regkey[i] then
                      begin
                         str((ord(regkey[i]) - ord(reg_code[i]))
                             + 1000, tstr);
                         regcode[4] := regcode[4] + tstr + #32;
                      end
                      else
                      if reg_code[i] > regkey[i] then
                      begin
                         str((ord(reg_code[i]) - ord(regkey[i]))
                             + 2000, tstr);
                         regcode[4] := regcode[4] + tstr + #32;
                      end
                      else
                      begin
                           str(ord(regkey[i]) + 3000, tstr);
                           regcode[4] := regcode[4] + tstr + #32;
                      end;
                    end;
            33..40: begin
                      if reg_code[i] < regkey[i] then
                      begin
                         str((ord(regkey[i]) - ord(reg_code[i]))
                             + 1000, tstr);
                         regcode[5] := regcode[5] + tstr + #32;
                      end
                      else
                      if reg_code[i] > regkey[i] then
                      begin
                         str((ord(reg_code[i]) - ord(regkey[i]))
                             + 2000, tstr);
                         regcode[5] := regcode[5] + tstr + #32;
                      end
                      else
                      begin
                           str(ord(regkey[i]) + 3000, tstr);
                           regcode[5] := regcode[5] + tstr + #32;
                      end;
                    end;
          end;
     end;
end;

begin
end.


I also have a doc file that comes with it if you would like to FREQ it from 
my system it is in a file called EASYKEY.ZIP.

SWAG TEAM, if you would like to include this in a swag packett, I would be
delighted.

Regards,
Tom Moore


