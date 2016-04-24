(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0058.PAS
  Description: Nice Keyboard unit
  Author: STEVEN PIGEON
  Date: 11-26-93  17:14
*)


Unit keybx;
 
 interface
 
 uses errors;
 
 
 const     Right_shift     = $0001;
           Left_shift      = $0002;
           Ctrl            = $0004;
           Alt             = $0008;
           Scroll_locked   = $0010;
           Num_locked      = $0020;
           Caps_locked     = $0040;
           Insert_locked   = $0080;
 
           Right_ctrl      = $0100;
           left_alt        = $0200;
           sysreq          = $0400;
           Pause_locked    = $0800;
           Scroll_pressed  = $1000;
           Num_pressed     = $2000;
           Caps_pressed    = $4000;
           Ins_pressed     = $8000;
 
           Space           = $3920;
 
           Enter           = $1C0D;
           Ctrl_Enter      = $1C0A;
           Shift_Enter     = $1C0D;
           Alt_Enter       = $1C00;
 
           gray_Enter      = $E00D;
           Ctrl_Gray_Enter = $E00A;
           Shift_Gray_Enter= $E00D;
           Alt_Gray_Enter  = $A600;

           gray_Plus       = $4E2B;
           Ctrl_gray_plus  = $9000;
           Shift_gray_plus = $4E2B;
           alt_gray_plus   = $4E00;
 
           gray_Minus      = $4A2D;
           Ctrl_gray_minus = $8E00;
           Shift_gray_minus= $4A2D;
           alt_gray_minus  = $4A00;
 
           _Esc            = $011B;
           Ctrl_Esc        = $011B;
           Shift_Esc       = $011B;
           Alt_Esc         = $0100;
 
           Backspace       = $0E08;
           Ctrl_Backspace  = $0E7F;
           Shift_Backspace = $0E08;
           Alt_Backspace   = $0E00;

 
           _Tab            = $0F09;
           Ctrl_Tab        = $9400;
           Shift_Tab       = $0F00;
           Alt_Tab         = $A500;
 
           _Up             = $4800;
           _Down           = $5000;
           _Left           = $4B00;
           _Right          = $4D00;
           _Home           = $4700;
           _End            = $4F00;
           _PgUp           = $4900;
           _PgDn           = $5100;
           _Five           = $4C00;
           _Ins            = $5200;
           _del            = $5300;
 
           Ctrl_Up         = $8D00;
           Ctrl_Down       = $9100;
           Ctrl_Left       = $7300;
           Ctrl_Right      = $7400;
           Ctrl_Home       = $7700;
           Ctrl_End        = $7500;
           Ctrl_PgUp       = $8400;
           Ctrl_PgDn       = $7600;
           Ctrl_Five       = $8F00;
           Ctrl_Del        = $9300;
           Ctrl_Ins        = $9200;
 
 
           shift_Up        = $4838;
           shift_Down      = $5032;
           shift_Left      = $4B34;
           shift_Right     = $4D36;
           shift_Home      = $4737;
           shift_End       = $4F31;
           shift_PgUp      = $4939;
           shift_PgDn      = $5133;
           shift_Five      = $4C35;
           shift_ins       = $5230;
           shift_del       = $532E;
 
           gray_Up         = $48E0;
           gray_Down       = $50E0;
           gray_Left       = $4BE0;
           gray_Right      = $4DE0;
           gray_Home       = $47E0;
           gray_End        = $4FE0;
           gray_PgUp       = $49E0;
           gray_PgDn       = $51E0;
           gray_ins        = $52E0;
           gray_del        = $53E0;
 
           Ctrl_gray_Up    = $8DE0;
           Ctrl_gray_Down  = $91E0;
           Ctrl_gray_Left  = $73E0;
           Ctrl_gray_Right = $74E0;
           Ctrl_gray_Home  = $77E0;
           Ctrl_gray_End   = $75E0;
           Ctrl_gray_PgUp  = $84E0;
           Ctrl_gray_PgDn  = $76E0;
           Ctrl_Gray_Ins   = $92E0;
           Ctrl_Gray_del   = $93E0;
 
           shift_gray_Up   = $48E0;
           shift_gray_Down = $50E0;
           shift_gray_Left = $4BE0;
           shift_gray_Right= $4DE0;
           shift_gray_Home = $47E0;
           shift_gray_End  = $4FE0;
           shift_gray_PgUp = $49E0;
           shift_gray_PgDn = $51E0;
           Shift_gray_Ins  = $52E0;
           Shift_gray_del  = $53E0;
 
           Alt_gray_Up     = $9800;
           Alt_gray_Down   = $A000;
           Alt_gray_Left   = $9B00;
           Alt_gray_Right  = $9D00;
           Alt_gray_Home   = $9700;
           Alt_gray_End    = $9F00;
           Alt_gray_PgUp   = $9900;
           Alt_gray_PgDn   = $A100;
           Alt_gray_Ins    = $A200;
           Alt_gray_del    = $A300;
 
           _f1             = $3B00;
           _f2             = $3C00;
           _f3             = $3D00;
           _f4             = $3E00;
           _f5             = $3F00;
           _f6             = $4000;
           _f7             = $4100;
           _f8             = $4200;
           _f9             = $4300;
           _f10            = $4400;
           _f11            = $8500;
           _f12            = $8600;

           Shift_f1        = $5400;
           Shift_f2        = $5500;
           Shift_f3        = $5600;
           Shift_f4        = $5700;
           Shift_f5        = $5800;
           Shift_f6        = $5900;
           Shift_f7        = $5A00;
           Shift_f8        = $5B00;
           Shift_f9        = $5C00;
           Shift_f10       = $5D00;
           Shift_f11       = $8700;
           Shift_f12       = $8800;
 
           Ctrl_f1         = $5E00;
           Ctrl_f2         = $5F00;
           Ctrl_f3         = $6000;
           Ctrl_f4         = $6100;
           Ctrl_f5         = $6200;
           Ctrl_f6         = $6300;
           Ctrl_f7         = $6400;
           Ctrl_f8         = $6500;
           Ctrl_f9         = $6600;
           Ctrl_f10        = $6700;
           Ctrl_f11        = $8900;
           Ctrl_f12        = $8A00;
 
           Alt_f1          = $6800;
           Alt_f2          = $6900;
           Alt_f3          = $6A00;
           Alt_f4          = $6B00;
           Alt_f5          = $6C00;
           Alt_f6          = $6D00;
           Alt_f7          = $6E00;
           Alt_f8          = $6F00;
           Alt_f9          = $7000;
           Alt_f10         = $7100;
           Alt_f11         = $8B00;
           Alt_f12         = $8C00;
 
           Alt_a           = $1E00;
           Alt_b           = $3000;
           Alt_c           = $2E00;
           Alt_d           = $2000;
           Alt_e           = $1200;
           Alt_f           = $2100;
           Alt_g           = $2200;
           Alt_h           = $2300;
           Alt_i           = $1700;
           Alt_j           = $2400;
           Alt_k           = $2500;
           Alt_l           = $2600;
           Alt_m           = $3200;
           Alt_n           = $3100;
           Alt_o           = $1800;
           Alt_p           = $1900;
           Alt_q           = $1000;
           Alt_r           = $1300;
           Alt_s           = $1F00;
           Alt_t           = $1400;
           Alt_u           = $1600;
           Alt_v           = $2F00;
           Alt_w           = $1100;
           Alt_x           = $2D00;
           Alt_y           = $1500;
           Alt_z           = $2C00;
 
           Ctrl_a          = $1E01;
           Ctrl_b          = $3002;
           Ctrl_c          = $2E03;
           Ctrl_d          = $2004;
           Ctrl_e          = $1205;
           Ctrl_f          = $2106;
           Ctrl_g          = $2207;
           Ctrl_h          = $2308;
           Ctrl_i          = $1709;
           Ctrl_j          = $240A;
           Ctrl_k          = $250B;
           Ctrl_l          = $260C;
           Ctrl_m          = $320D;
           Ctrl_n          = $310E;
           Ctrl_o          = $180F;
           Ctrl_p          = $1910;
           Ctrl_q          = $1011;
           Ctrl_r          = $1312;
           Ctrl_s          = $1F13;
           Ctrl_t          = $1414;
           Ctrl_u          = $1615;
           Ctrl_v          = $2F16;
           Ctrl_w          = $1117;
           Ctrl_x          = $2D18;
           Ctrl_y          = $1519;
           Ctrl_z          = $2C1A;
 
 
           Key_a           = $1E61;
           Key_b           = $3062;
           Key_c           = $2E63;
           Key_d           = $2064;
           Key_e           = $1265;
           Key_f           = $2166;
           Key_g           = $2267;
           Key_h           = $2368;
           Key_i           = $1769;
           Key_j           = $246A;
           Key_k           = $256B;
           Key_l           = $266C;
           Key_m           = $326D;
           Key_n           = $316E;
           Key_o           = $186F;
           Key_p           = $1970;
           Key_q           = $1071;
           Key_r           = $1372;
           Key_s           = $1F73;
           Key_t           = $1474;
           Key_u           = $1675;
           Key_v           = $2F76;
           Key_w           = $1177;
           Key_x           = $2D78;
           Key_y           = $1579;
           Key_z           = $2C7A;
 
           Key_0           = $0B30;
           Key_1           = $0231;
           Key_2           = $0332;
           Key_3           = $0433;
           Key_4           = $0534;
           Key_5           = $0635;
           Key_6           = $0736;
           Key_7           = $0837;
           Key_8           = $0938;
           Key_9           = $0A39;
 
 
           Shift_Key_a     = $1E41;
           Shift_Key_b     = $3042;
           Shift_Key_c     = $2E43;
           Shift_Key_d     = $2044;
           Shift_Key_e     = $1245;
           Shift_Key_f     = $2146;
           Shift_Key_g     = $2247;
           Shift_Key_h     = $2348;
           Shift_Key_i     = $1749;
           Shift_Key_j     = $244A;
           Shift_Key_k     = $254B;
           Shift_Key_l     = $264C;
           Shift_Key_m     = $324D;
           Shift_Key_n     = $314E;
           Shift_Key_o     = $184F;
           Shift_Key_p     = $1950;
           Shift_Key_q     = $1051;
           Shift_Key_r     = $1352;
           Shift_Key_s     = $1F53;
           Shift_Key_t     = $1454;
           Shift_Key_u     = $1655;
           Shift_Key_v     = $2F56;
           Shift_Key_w     = $1157;
           Shift_Key_x     = $2D58;
           Shift_Key_y     = $1559;
           Shift_Key_z     = $2C5A;

           Shift_Key_0     = $0B29;
           Shift_Key_1     = $0221;
           Shift_Key_2     = $0340;
           Shift_Key_3     = $0423;
           Shift_Key_4     = $0524;
           Shift_Key_5     = $0625;
           Shift_Key_6     = $075E;
           Shift_Key_7     = $0826;
           Shift_Key_8     = $092A;
           Shift_Key_9     = $0A28;
 
           No_Key_At_all   = $FFFF;
           No_Key          = $FFFE;
           Ctrl_Break      = $0000;
 
 
 function  Readkey:char;
 function  keypressed:boolean;
 
 function  Extended_Keypressed:boolean;
 function  Extended_Readkey:word;
 procedure Extended_Writekey(scan_code:word);
 function  Extended_Browsekey:word;
 procedure Flush_That_Key;
 
 function  Ctrl_Break_pressed:boolean;
 procedure Clear_Ctrl_Break;
 
 function  get_shift_status:word;
 function  shift_status_is(mask:word):boolean;
 function  Get_char(w:word):char;
 
 
 Var Touche_Residuelle:byte;
     Last_key:word;
 
 
 implementation
 
 (*===========*)
 function  Get_char(w:word):char; assembler;
  asm
   mov ax,w
  end;
 
 (*===========*)
 function  Readkey:char; assembler;
  asm
   mov al,Touche_residuelle
   or  al,al
   jz  @ici
   mov touche_residuelle,0
   jmp @exit
   @ici:
   mov ah,$10
   int $16
   mov last_key,ax
   or  al,al
   jnz @exit
   mov Touche_residuelle,ah
   @exit:
  end;
 
 
 (*===========*)
 function  keypressed:boolean; assembler;
  asm
   mov ah,$11
   int $16
   mov al,0
   jz  @exit
   mov al,1
   @exit:
  end;
 
 
 (*===========*)
 function get_shift_status:word; assembler;
  asm
   xor ax,ax
   mov es,ax
   mov ax,es:[$417]
  end;
 
 (*===========*)
 function  shift_status_is(mask:word):boolean; assembler;
  asm
   xor ax,ax
   mov es,ax
   mov ax,es:[$417]
   and ax,mask
   jz  @exit
   mov al,1
   @exit:
  end;
 
 
 (*===========*)
 procedure Clear_Ctrl_Break; assembler;
  asm
   xor ax,ax
   mov es,ax
   mov byte ptr es:[$471],0
  end;
 
 
 (*===========*)
 function Ctrl_Break_pressed:boolean; assembler;
  asm
   xor ax,ax
   mov es,ax
   mov al,es:[$471]
   shr al,7
  end;
 
 
 (*===========*)
 function extended_keypressed:boolean; assembler;
  asm
   mov ah,$11
   int $16
   lahf
   and ah,$4
   not ah
   mov al,ah
  end;
 
 (*===========*)
 function  Extended_Browsekey:word; assembler;
  asm
   mov ah,$11;
   int $16
   jnz @exit
   xor ax,ax
   @exit:
  end;
 
 (*===========*)
 function extended_readkey:word; assembler;
  asm
   mov ah,$10
   int $16
   mov last_key,ax
  end;
 
 (*===========*)
 procedure flush_that_key; assembler;
  asm
   mov ah,$10
   int $16
  end;
 
 (*===========*)
 procedure extended_writekey(scan_code:word); assembler;
  asm
   mov ah,5
   mov cx,scan_code
   int $16
  end;
 
 
 
 begin
  Touche_residuelle:=0;
  Last_key:=no_key_at_all;
  Clear_Ctrl_Break;
 end.


