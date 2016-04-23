{
Ever been in a situation where you want to secure a PC (for example in a
network environment) by using menus from which you can't exit and
user/software companies keep coming with software with the Shell to DOS
option?

Here's a simple solution which works with a lot of programs which shell
by using COMSPEC.

This program called execute patches it's own environment with a
replacement COMSPEC, Does an EXEC and restores the original environment.
It's done by making fetching all environment strings, replace comspec
with the first commandline parameter (which should be shorter than the
original comspec, so I use the program called EXIT located in the
same directory as COMMAND.COM). Than it does an plain TP Exec (without
swapping to EMS/XMS/DISK etc) of the second commandline parameter with
the rest of the commandline as it's parameters.

I used patching the original environment of EXECUTE because the program
executed inherits it and EXECUTE needs comspec only to exit itself (and
return to a menu for example). Because of this construction it's
possible to exit the program started normally and return to a menu but
you'll be unable to shell to dos and type something like FORMAT C:.

An example EXIT.PAS is also supplied. Pressing CTRL-BREAK etc doesn't
matter, you'll always return to the application from which you tried to
shell. Beware that some programs like SPSS and VP-Planner have
difficulties with R/O attributes on EXIT.EXE (and COMMAND.COM), so keep
it R/W.

So to for example disable the Turbo Pascal File/Dos use :

EXECUTE C:\DOS\EXIT.EXE C:\TURBO55\TURBO.EXE TEST.PAS

instead of

C:\TURBO55\TURBO TEST.PAS

If COMSPEC was C:\DOS\COMMAND.COM and Turbo Pascal was located in
the C:\TURBO55 directory.


Remember the extensions .EXE or .COM are necessary!

------------------------<cut here

{---------------------------------------------------------}
{  Project : Exec with Temporaryly changed 'COMSPEC'      }
{          : the exec routine itself                      }
{  Auteur  : Ir. G.W. van der Vegt                        }
{---------------------------------------------------------}
{  Datum .tijd  Revisie                                   }
{  921118.0930  Creatie.                                  }
{---------------------------------------------------------}
{ This program patches the COMSPEC environment variable   }
{ with a new value (ie EXIT.EXE) and executes the         }
{ program. After execution it restores the environment    }
{                                                         }
{ Syntax :                                                }
{                                                         }
{ EXECUTE temporary_comspec program_name [paramaters]     }
{                                                         }
{ Limits :-Only maxenv environments strings can be stored,}
{          each with a maximum length of 128 characters.  }
{         -The temporary comspec must be shorter than the }
{          original one.                                  }
{         -Environment must be smaller than 32k           }
{---------------------------------------------------------}

{$M 4096,0,0}

Program Execute;

Uses
  Crt,
  Dos;


Const
  Maxenv = 64;

Type
  psp = Record
          int20adr : Word;
          endofmem : Word;
          res1     : Byte;
          callfar  : Array[1..5] OF Byte;
          int22    : Pointer;
          Int23    : Pointer;
          Int24    : Pointer;
          parentpsp: Word;
          handles  : Array[1..20] OF Byte;
          envseg   : Word;
        {----More follows}
        End;

  env = array[1..32678] OF Char;

Var
  e      : ^env;
  p      : ^psp;
  addcnt : Word;                           {----no of additional strings}
  i      : Integer;                        {----loop counter}
  envar  : Array[1..maxenv] of String[128];{----environment string storage}
  noenv  : Integer;                        {----no strings in environment}
  cmdline: STRING;                         {----command line of program to start}
  comspec: STRING;                         {----original comspec storage}
  ch     : CHAR;

{---------------------------------------------------------}

Procedure Read_env;

Var
  i,k : Integer;

begin
  p:=Ptr(prefixseg,0);
  noenv:=0;

{----Show environment strings}
  e:=Ptr(p^.envseg,0);
  i:=1;
  Inc(noenv);
  envar[noenv]:='';
  Repeat
    If (e^[i]<>#0)
      Then envar[noenv]:=envar[noenv]+e^[i]
      Else
        Begin
          Inc(noenv);
          If (noenv>=maxenv)
            THEN
              BEGIN
                Writeln('Only ',maxenv:0,' environment strings can be stored.');
                Halt;
              END;

          envar[noenv]:='';
        End;
    Inc(i);
  Until (e^[i]=#00) AND (e^[i]=e^[i-1]);

{----Show Additional environment strings}
  Inc(i);
  addcnt:=Word(Ord(e^[i])+256*Ord(e^[i+1]));
  Inc(i);
  Inc(i); {----eerste character additional strings}
  k:=addcnt;

  If (noenv+addcnt>=maxenv)
    THEN
      BEGIN
        Writeln('Only ',maxenv:0,' (additional)environment strings can be stored');
        Halt;
      END;

  Repeat
    If (e^[i]<>#0)
      Then envar[noenv]:=envar[noenv]+e^[i]
      Else
        Begin
          Inc(noenv);
          envar[noenv]:='';
          Dec(k);
        End;
    Inc(i);
  Until (k<=0);

  dec(noenv);

 {Writeln(' Environment Strings : ',noenv-addcnt);
  for j:=1 to noenv-addcnt do
    writeln('e ',envar[j]);
  Writeln(' Additional Strings : ',addcnt);
  for j:=noenv-addcnt+1 to noenv do
    writeln('a ',envar[j]);
  writeln;}
end; {of Read_env}

{---------------------------------------------------------}

Procedure Patch_env(envst,newval : STRING);

Var
  i,j,k : Integer;

BEGIN
{----change an envronment string}
  for i:=1 to noenv do
    begin
      if (pos(envst+'=',envar[i])=1)
        THEN
          begin
            Delete(envar[i],Pos('=',envar[i])+1,Length(envar[i])-Pos('=',envar[i]));
            envar[i]:=envar[i]+newval;
          end;
    end;

{----patch environment strings}
  i:=1;
  for j:=1 to noenv-addcnt do
    begin
      for k:=1 to Length(envar[j]) do
        begin
          e^[i]:=envar[j][k];
          inc(i);
        end;
      e^[i]:=#0;
      inc(i);
    end;

{----patch environment string end}
  e^[i]:=#0;                  inc(i);
{----patch additional string count}
  e^[i]:=Chr(addcnt mod 256); inc(i);
  e^[i]:=Chr(addcnt div 256); inc(i);

{----patch additional strings}
  for j:=noenv-addcnt+1 to noenv do
    begin
      for k:=1 to Length(envar[j]) do
        begin
          e^[i]:=envar[j][k];
          inc(i);
        end;
      e^[i]:=#0;
      inc(i);
    end;
end; {of Patch_env}

{---------------------------------------------------------}

Begin
  If (Paramcount<2)
    THEN
      BEGIN
        Writeln('Syntax : EXECUTE temporary_comspec program_name [program_param]');
        Halt;
      END;

  checkbreak:=false;

  comspec:=Getenv('COMSPEC');

  If (Length(Paramstr(1))>Length(comspec))
    THEN
      BEGIN
        Writeln('Path&name of temporary COMSPEC should be shorter than the original');
        Halt;
      END;

  Read_env;

  Patch_env('COMSPEC',Paramstr(1));

  cmdline:='';
  FOR i:=3 to Paramcount DO
    cmdline:=cmdline+' '+Paramstr(i);

  Swapvectors;
  Exec(Paramstr(2),cmdline);
  Swapvectors;

  WHILE Keypressed DO ch:=Readkey;

  Patch_env('COMSPEC','C:\COMMAND.COM');
end.


------------------------<cut here


Program Exit;

Uses
  CRT;

Begin
 Clrscr;
 GotoXY(20,12);
 Write('Sorry, SHELLing to DOS not Possible.');
End.
