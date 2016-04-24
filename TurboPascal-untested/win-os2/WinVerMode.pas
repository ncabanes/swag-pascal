(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0084.PAS
  Description: WIN VER & MODE
  Author: CAMERON CLARK
  Date: 02-21-96  21:04
*)


unit win_ver; {detect Windows = present, version, & mode }
  {NOTE: use post 3.1 version detection before pre 3.1}
interface
  {post 3.1}
  procedure windows_version( var major, minor : byte );
  procedure windows_mode( var mode : byte );
  {pre 3.1}
  procedure enhanced_mode_present ( var present : boolean);
  procedure windows_present( var present : boolean );
  procedure windows_386_present( var present : boolean );
  procedure windows_3_0_mode( var mode : byte );
implementation
  {win 3.1+ only}
  procedure windows_version( var major, minor : byte ); {0,0 = not detected}
  begin asm
       push es;
       mov ax, 160ah; int 2fh

       cmp ax,0
       je  @windows_present
       @windows_not_present:
       mov byte ptr major, 0; mov byte ptr minor, 0
       jmp @end_procedure
       @windows_present:
       mov al, bh; les di, major; stosB
       mov al, bl; les di, minor; stosB

       @end_procedure:
       pop es
  end; end;
  {win 3.1+ only}
  procedure windows_mode(var mode : byte ); {0=unknown}
  begin asm
       push es
       mov ax, 160ah; int 2fh

       cmp ax,0
       jne  @windows_not_present
       @windows_present:
       mov ax, cx;
       jmp @end_procedure
       @windows_not_present:
       mov ax, 0
       @end_procedure:
       les di, mode; stosB
       pop es
  end; end;
  {pre win 3.1}
  { ax=1600h := windows not running  }
  { ax=80h or ffh := win/386 running }
  procedure enhanced_mode_present (var present : boolean);
  begin asm
       push es
       mov ax, 1600h; int 2fh

       cmp ax, 1600h
       jne @enhanced_mode_present
       @not_endhanced_mode:
       mov ax, 0
       jmp @end_function
       @enhanced_mode_present:
       mov ax, 0ffffh

       @end_function:
       les di, present; stosB
       pop es
  end; end;
  {pre win 3.1}
  {al = ff or 80 = windows/386 running}
  procedure windows_386_present( var present : boolean );
  begin asm
       push es
       mov ax,4680h; int 2fh

       cmp ax,0
       jne @not_present
       cmp al,0ffh
       je   @present
       cmp al,080h
       jne  @not_present
       @present:
       mov ax, 0ffffh
       jmp @end_procedure
       @not_present:
       mov ax, 0

       @end_procedure:
       les di, present; stosB
       pop es
  end; end;
  {pre win 3.1}
  procedure windows_present( var present : boolean );
  begin asm
       push es
       mov ax,4680h; int 2fh

       cmp ax,0
       jne @not_present
       @present:
       mov ax, 0ffffh
       jmp @end_function
       @not_present:
       mov ax, 0h

       @end_function:
       les di, present; stosB
       pop es
  end; end;
  { call only if 3.0 has been identified }
  { mode = 2 := real mode } { mode = 1 := standard mode }
  { mode = 0 := unknown }
  procedure windows_3_0_mode(var mode : byte);
  begin asm
       push es
       mov ax,1605h; xor cx,cx; int 2fh  {simulate "windows restart"}

       cmp cx, 0ffffh
       jne @real_mode
       @standard_mode:
       mov ax, 2              { 2 = standard mode }
       jmp @end_procedure
       @real_mode:
       cmp cx,0
       je  @is_real_mode
       mov ax, 0              { 0 = mode unknown }
       jmp @end_procedure
       @is_real_mode:
       mov ax, 1              { 1 = real mode }

       @end_procedure:
       les di, mode; stosB
       {termination notice should be here!}
       pop es
  end; end;
end.

{  --------- Test driver for win_ver ---------------- }

uses win_ver;  var maj, min, mode : byte; bol:boolean;
begin
  windows_version( maj, min );
  writeln(' win maj.min ',maj,'.',min);
  windows_mode( mode );
  writeln(' win mode :[3=enhance,2=standard,1=real(not_supported)] =',mode);
  enhanced_mode_present( bol );
  writeln(' enhanced mode? ',bol);
  windows_present( bol );
  writeln(' windows present (pre 3.1) ? ',bol);
  windows_386_present( bol );
  writeln(' windows 386 present(pre 3.1) ? ',bol);
  windows_3_0_mode( mode );
  writeln(' 3.0 mode [2 = standard, 1 = real, 0 = ?] = ',mode);
end.

