(*
  Category: SWAG Title: DOS REDIRECTION ROUTINES
  Original name: 0007.PAS
  Description: Redirect output
  Author: TODD A. JACOBS
  Date: 08-25-94  09:10
*)

{ From: tjacobs@clark.net (Todd A. Jacobs) }
unit Redir;
 
interface
 
uses
  Dos;
 
function SetOutput(FileName: PathStr): Boolean;
procedure CancelOutput;
 
implementation
 
const
  OutRedir: Boolean = False;
 
function SetOutput(FileName: PathStr): Boolean;
begin
  FileName:=FileName+#0;
  SetOutput:=False;
  asm
    push  ds
    mov   ax, ss
    mov   ds, ax
    lea   dx, FileName[1]
    mov   ah, 3Ch
    int   21h
    pop   ds
    jnc   @@1
    ret
@@1:
    push  ax
    mov   bx, ax
    mov   cx, Output.FileRec.Handle
    mov   ah, 46h
    int   21h
    mov   ah, 3Eh
    pop   bx
    jnc   @@2
    ret
@@2:
    int   21h
  end;
  OutRedir:=True;
  SetOutput:=True;
end;

procedure CancelOutput;
var
  FileName: String[4];
begin
  if not OutRedir then Exit;
  FileName:='CON'#0;
  asm
    push  ds
    mov   ax, ss
    mov   ds, ax
    lea   dx, FileName[1]
    mov   ax, 3D01h
    int   21h
    pop   ds
    jnc   @@1
    ret
@@1:
    push  ax
    mov   bx, ax
    mov   cx, Output.FileRec.Handle
    mov   ah, 46h
    int   21h
    mov   ah, 3Eh
    pop   bx
    int   21h
  end;
  OutRedir:=False;
end;

end.
{
Standard output will be changed to FileName. The FileName can be NUL.
When your
executed program is using int $10, all is hardly. In your main program use:

SetOutput('NUL');
Exec(....);
CancelOutput;
}


