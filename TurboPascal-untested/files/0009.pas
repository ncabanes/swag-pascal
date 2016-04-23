Program ShareVolation;
Uses Dos,Crt;

Function FileOpen(S:String):Boolean; Assembler;
{ -returns True if File already is open (Access denied) ..}
Asm
  PUSH DS             { changes are in all caps }
  mov  ah,03dh
  xor  al,al
  LDS  DX, S
  INC  DX          { point to contents of String }
  int  21h
  mov  bx,ax
  mov  al,0  { FileOpen = False }
  jnc  @end
  cmp  bx,05h  { Access denied}
  jz   @Open
  jmp  @end

@Open:
  mov al,1  { FileOpen = True}
@end:
   POP DS
end; { FileOpen }


Var
   F : Text ;

begin
   FileMode := $10 ;                 { deny read/Write ?? }
   Assign( F, 'C:\TEST.TXT' ) ;
   ReWrite( F ) ;

   WriteLn(FileOpen('C:\TEST.TXT'+ #0));  { SHARE is loaded }
   Close( F ) ;
end.
