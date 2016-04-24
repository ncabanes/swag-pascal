(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0038.PAS
  Description: Fast
  Author: RYAN@EMIKO.IGCOM.NET
  Date: 05-31-96  09:16
*)

  unit MyMouse;
  { bare bones mouse unit used by the simulator -stolen from swag, sorta }

  interface

  uses dos;

  var
    mousex, mousey:integer;

  procedure initmouse(var buttons:byte; var is:boolean);
  Procedure showmouse;
  Procedure hidemouse;
  procedure getmousexy;
  procedure mouseto80;
  Procedure MouseExit;
  function mouserightpressed:boolean; {??}
  function mouseleftpressed:boolean;
  function mouserightdown:boolean;
  function mousebothdown:boolean;
  function mouseleftdown:boolean;

 implementation

 Var
   ExitPtr: pointer;
   Regs: registers;
   TempWord: word;

  procedure initmouse(var buttons:byte; var is:boolean);
  var msavailable:boolean;
      msbuttons:byte;
  begin
     msavailable:=false;
     Asm
       MOV MsButtons,0
       MOV AX,0000h
       INT 33h
       CMP AX,0000h
       JE  @Dne
       CMP AX,0FFFFh
       JNE @Dne
       MOV MsAvailable,True
       CMP BX,0002h
       JE  @Two
       CMP BX,0003h
       JE  @Thr
       CMP BX,0FFFFh
       JE  @Thr
 @Two: MOV MsButtons,2
       JMP @Dne
 @Thr: MOV MsButtons,3
 @Dne:
     End;
     buttons:=msbuttons;
     is:=msavailable;
  end;

  Procedure showmouse; Assembler;
  Asm
    MOV AX,0001h
    INT 33h
  end;

  Procedure Hidemouse; Assembler;
  Asm
    MOV AX,0002h
    INT 33h
  end;

  procedure getmousexy; Assembler;
  Asm
    MOV AX,0003h
    INT 33h
    MOV mousex,CX
    MOV mousey,DX
  end;

  procedure mouseto80;
  begin
    {makes it a number for 80x25 text mode}
    mousex:=(mousex div 8)+1;
    mousey:=(mousey div 8)+1;
  end;

  {dont know the diff between 'rghtDOWN and rightPRESSED'}

  function mouseleftpressed:boolean;
  begin
    asm
      MOV @Result,False
      MOV AX,0005h
      MOV BX,0000h
      INT 33h
      {MOV Count,BX} {what is count?}
      MOV mousex,CX
      MOV mousey,DX
      CMP AX,1
      JNE @Done
      MOV @Result,True
      @Done:
    end;
  end;

  function mouserightpressed:boolean;
  begin
    asm
      MOV @Result,False
      MOV AX,0005h
      MOV BX,0001h
      INT 33h
      {MOV Count,BX} {what is count?}
      MOV mousex,CX
      MOV mousey,DX
      CMP AX,2
      JNE @Done
      MOV @Result,True
      @Done:
    end;
  end;

  function mouserightdown:boolean;
  begin
    asm
      MOV @Result,False
      MOV AX,0003h
      INT 33h
      MOV mousex,CX
      MOV mousey,DX
      CMP BX,2
      JNE @Done
      MOV @Result,True
      @Done:
    end;
  end;

  function mousebothdown:boolean;
  begin
    asm
      MOV @Result,False
      MOV AX,0003h
      INT 33h
      MOV MouseX,CX
      MOV MouseY,DX
      CMP BX,3
      JNE @Done
      MOV @Result,True
      @Done:
    end;
  end;

  function mouseleftdown:boolean;
  begin
    Asm
      MOV @Result,False
      MOV AX,0003h
      INT 33h
      MOV mousex,CX
      MOV mousey,DX
      CMP BX,1
      JNE @Done
      MOV @Result,True
      @Done:
    end;
  end;

  Procedure MouseExit;
  begin
    ExitProc:=ExitPtr;
  end;

  begin
    ExitPtr:=ExitProc;
    ExitProc:=@MouseExit;
  End.

