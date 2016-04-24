(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0029.PAS
  Description: DOS Redirection
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  10:06
*)

{
 RG> I am writing a simple program which executes other programs. I am using
 RG> the function

 RG> EXEC(ProgramName,CmdLine)

 RG> which is working just fine. However, I would like to somehow prevent the
 RG> executed program from writing to the screen, rather I just want to display
 RG> in my program something like

 RG> Working...

 RG> While still maintaining the screen which the program is using for output.
 RG> So my questions is, how would I go about doing this?

Try this unit! }

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
push ds
mov  ax, ss
mov  ds, ax
lea  dx, FileName[1]
mov  ah, 3Ch
int  21h
pop  ds
jnc  @@1
ret
@@1:
push ax
mov  bx, ax
mov  cx, Output.FileRec.Handle
mov  ah, 46h
int  21h
mov  ah, 3Eh
pop  bx
jnc  @@2
ret
@@2:
int  21h
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
push ds
mov  ax, ss
mov  ds, ax
lea  dx, FileName[1]
mov  ax, 3D01h
int  21h
pop  ds
jnc  @@1
ret
@@1:
push ax
mov  bx, ax
mov  cx, Output.FileRec.Handle
mov  ah, 46h
int  21h
mov  ah, 3Eh
pop  bx
int  21h
 end;
 OutRedir:=False;
end;

end.

________________

Standard output will be changed to FileName. The FileName can be NUL. When your
executed program is using int $10, all is hardly. In your main program use:

SetOutput('NUL');
Exec(....);
CancelOutput;

 {change the dos prompt when Shelling to DOS without
 having to change the current or master enviroment(It makes it's own).}

