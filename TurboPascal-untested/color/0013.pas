Unit palette;
{$O+}
Interface

Uses Dos,Crt;

Procedure Set_palette(slot:Word; sred,sgreen,sblue : Byte);
Procedure Get_palette(Var slot,gred,ggreen,gblue : Byte);
Procedure fade_in(dly : Word ; dvsr : Byte);   {Delay (ms),divisor (10-64)}
Procedure fade_out(dly : Word ; dvsr : Byte);
Procedure restore_palette;
Procedure swap_color(first,last:Byte);
Function VGASystem: Boolean;
Procedure remap;
Procedure restoremap;

Const
  sl     : Array[0..15] of Byte =(0,1,2,3,4,5,20,7,56,57,58,59,60,61,62,63);
  v_red  : Array[0..15] of Byte =(0,0,0,0,42,42,42,42,21,21,21,21,63,63,63,63);
  v_green: Array[0..15] of Byte =(0,0,42,42,0,0,21,42,21,21,63,63,21,21,63,63);
  v_blue : Array[0..15] of Byte =(0,42,0,42,0,42,0,42,21,63,21,63,21,63,21,63);

Var
  s_red, s_green, s_blue : Array[0..15] of Real;

Implementation

Procedure disable_refresh;
Var
  regs : Registers;
begin
  With regs do
  begin
    AH:=$12;
    BL:=$36;
    AL:=$01;
  end;
  Intr($10,regs);
end;

Procedure enable_refresh;
Var
  regs : Registers;
begin
  With regs do
  begin
    AH:=$12;
    BL:=$36;
    AL:=$00;
  end;
  Intr($10,regs);
end;

Function VGASystem: Boolean;
{}
Var  Regs : Registers;
begin
  With Regs do
  begin
    Ax := $1C00;
    Cx := 7;
    Intr($10,Regs);
    If Al = $1C then  {VGA}
    begin
      VGASystem := True;
      Exit;
    end;
    Ax := $1200;
    Bl := $32;
    Intr($10,Regs);
    If Al = $12 then {MCGA}
    begin
      VGASystem := True;
      Exit;
    end;
  end; {with}
end; {of func NoSnowSystem}

Procedure remap;
Var
  regs : Registers;
  idx  : Byte;
begin
  if VGASystem then
  begin
    With regs do
    begin
      AL:=0;
      AH:=11;
    end;
    For idx:=0 to 15 do
    begin
      regs.BH:=idx;
      regs.BL:=idx;
      Intr($10,Regs);
    end;
  end;
end;

Procedure restoremap;
Var
  regs : Registers;
  idx  : Byte;
begin
  if VGASystem then
  begin
    With regs do
    begin
      AL:=0;
      AH:=11;
    end;
    For idx:=0 to 15 do
    begin
      regs.BH:=sl[idx];
      regs.BL:=idx;
      Intr($10,Regs);
    end;
  end;
end;

Procedure Set_palette(slot:Word; sred,sgreen,sblue : Byte);
Var
  regs : Registers;
begin
  With regs do
  begin
    AL:=$10;
    AH:=$10;
    BX:=slot;
    DH:=sred;
    CH:=sgreen;
    CL:=sblue;
  end;
  Intr($10,Regs);
end;

Procedure Get_palette(Var slot,gred,ggreen,gblue : Byte);
Var
  regs : Registers;
begin
  With regs do
  begin
    AL:=21;
    AH:=16;
    BX:=slot;
  end;
  Intr($10,Regs);
  With regs do
  begin
    gred:=DH;
    ggreen:=CH;
    gblue:=CL;
  end;
end;

Procedure restore_palette;
Var index:Byte;
begin
  For index:=0 to 15 do
      set_palette(sl[index],v_red[index],v_green[index],v_blue[index]);
end;
Procedure fade_out(dly : Word ; dvsr : Byte);
Var index,idx : Byte;
begin
  For index:=0 to 15 do
  begin
    s_red[index]:=v_red[index];
    s_green[index]:=v_green[index];
    s_blue[index]:=v_blue[index];
  end;
  For idx:=1 to dvsr do
  begin
    For index:=0 to 15 do
    begin
      set_palette(sl[index],trunc(s_red[index]),trunc(s_green[index]),trunc(s_blue[index]));
      s_red[index]:=s_red[index]-(v_red[index]/dvsr);
      s_green[index]:=s_green[index]-(v_green[index]/dvsr);
      s_blue[index]:=s_blue[index]-(v_blue[index]/dvsr);
    end;
    Delay(dly)
  end;
end;

Procedure fade_in(dly : Word ; dvsr : Byte);
Var index,idx2:Byte;
begin
  FillChar(s_red,Sizeof(S_red),#0);
  FillChar(s_green,Sizeof(S_green),#0);
  FillChar(s_blue,Sizeof(s_blue),#0);
  For idx2:=1 to dvsr do
  begin
    For index:=0 to 15 do
    begin
      set_palette(sl[index],trunc(s_red[index]),trunc(s_green[index]),trunc(s_blue[index]));
      s_red[index]:=s_red[index]+(v_red[index]/dvsr);
      s_green[index]:=s_green[index]+(v_green[index]/dvsr);
      s_blue[index]:=s_blue[index]+(v_blue[index]/dvsr);
    end;
  Delay(dly);
  end;
end;

Procedure swap_color(first,last:Byte);
Var f1,f2,f3,l1,l2,l3:Byte;
begin
  Get_Palette(sl[first],f1,f2,f3);
  Get_Palette(sl[last],l1,l2,l3);
  Set_Palette(sl[first],l1,l2,l3);
  Set_Palette(sl[last],f1,f2,f3);
end;

begin
  restoremap;
end.
