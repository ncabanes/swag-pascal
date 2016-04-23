
{
Answering a msg of <Thursday May 19 1994>, from Elad Nachman to Per-Eric
Larsson:
}

program environ;

uses dos,crt;

Const
  Multiplex = $2f;
  std_dos   = $21;


var
  regs        : registers;
  {windows information variables}
  winstall    : boolean;
  hi_winver   : integer;
  lo_winver   : integer;
  _386enh     : boolean;
  Ver_mach    : word;
  {OS information Variables}
  _4dosinst    : boolean;
  Hi_4d_ver   : integer;
  Lo_4d_ver   : integer;
  shell_num   : integer;
  Hi_dosver   : integer;
  Lo_dosver   : integer;
  {DesqView Information variables}
  dv_inst     : boolean;
  Hi_dv_ver   : integer;
  Lo_dv_ver   : integer;


 procedure v_id; {return windows 3.x 386enh mode virtual machine number}

   begin
     regs.ax:=$1638;
     intr(multiplex,regs);
     ver_mach := regs.bx;
   end;

 procedure winstal;{check for windows 3.x install}

   begin
     regs.ax:=$160A;
     intr(multiplex,regs);
     if regs.ax = $0000 then
       begin
         winstall  := true;
         Hi_winver := regs.bh;
         lo_winver := regs.bl;
         if regs.cx = $0003 then
           begin
             _386enh := true;
             v_id;
           end
         else
           begin
             _386enh := false;
             ver_mach := 0;
           end;
       end
      else
        begin
          {
            this point is only reached if windows isNOT
            detected we therefore set ALL windows id vars
            to impossible numbers.
          }
          winstall  := false;
          Hi_winver := 0;
          lo_winver := 0;
          ver_mach  := 0;
        end;
   end;

  procedure dvinstall;{check for dv}

    begin
      if winstall then
        begin
          dv_inst := false;
          exit;
        end;
      regs.ax := $2b00;
      regs.cx := $4445;
      regs.dx := $5351;
      regs.ax := $0001;
      intr(std_dos,regs);
      if regs.al<>$ff then
        begin
          hi_dv_ver := regs.bh;
          lo_dv_ver := regs.bl;
          dv_inst   := true;
        end
      else
        begin
          Hi_dv_ver := 0;
          Lo_dv_ver := 0;
          dv_inst   := false;
        end;
    end; { dv install check}

  procedure I_4dos;

    begin
      regs.ax := $d44d;
      regs.bx := $0000;
      intr(std_dos,regs);
      if regs.ax = $44dd then
        begin
          hi_4d_ver := regs.bh;
          lo_4d_ver := regs.bl;
          _4dosinst  := true;
          shell_num := regs.dl;
        end
      else
        begin { no 4dos }
          _4dosinst  := false;
          hi_4d_ver := 0;
          lo_4d_ver := 0;
          shell_num := -1;
        end;
    end;

  procedure dos_ver; {get dos version}

    begin
      regs.ax:=$3001;
      intr(std_dos,regs);
      hi_dosver:=regs.al;
      lo_dosver:=regs.ah;
    end;

  procedure display_info;
    begin
      clrscr;
      gotoxy(4,5);
      writeln('Os information');
      gotoxy(4,12);
      writeln('Windows 3.x information');
      gotoxy(4,17);
      writeln('Dv information');
      if _4dosinst then
        begin
          gotoxy(6,7);
          writeln('4dos version: ',hi_4d_ver,':',lo_4d_ver);
          gotoxy(6,8);
          writeln('4dos subshell#: ',shell_num);
          gotoxy(6,9);
          writeln('MSdos version: ',hi_dosver,':',lo_dosver);
        end
      else
        begin
          gotoxy(6,7);
          writeln('MSdos version: ',hi_dosver,':',lo_dosver);
          gotoxy(6,8);
          writeln('4dos.com not detected in this window.');
        end;
      if winstall then
        begin
          gotoxy(6,13);
          writeln('Windows Version: ',Hi_winver,':',lo_winver);
          gotoxy(6,14);
          if _386enh then
            begin
              writeln('Running in 386 enhanced mode');
              gotoxy(6,15);
              writeln('386Enh virtual machine ID: ',ver_mach);
            end
          else
            begin
              writeln('Running in Standard mode');
              gotoxy(6,15);
              writeln('386Enh Virtual Machine ID: Not applicable in standard mode');
            end;
          end
        else
          begin
            gotoxy(6,13);
            writeln('Microsoft windows not installed');
          end;
      if dv_inst then
        begin
          gotoxy(6,18);
          writeln('Desqview Version: ',hi_dv_ver,':',lo_dv_ver);
        end
      else
        begin
          gotoxy(6,18);
          writeln('DesqView not installed');
        end;
    end;

  begin
    winstal;
    I_4dos;
    dos_ver;
    dvinstall;
    display_info;
    repeat
    until readkey = #27;
  end.

