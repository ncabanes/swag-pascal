program chkpath;

Uses Dos;

Procedure GetNextPath ( var Path, CurrPath : String );

Var
   SemiPos : Byte;

Begin


   SemiPos := Pos(';',Path);

   If SemiPos = 0 then
      Begin
         CurrPath := Path;
         Path := '';
      End
   Else
      Begin
         CurrPath := Copy(Path,1,SemiPos - 1);
         Path := Copy(Path,SemiPos + 1, Length(Path));
      End;
End;

Function CheckPath( Path : String ) : Boolean;

Var
   Result : Integer;

Begin

{$I-}
   ChDir(Path);
{$I-}

   Result := IOResult;

   CheckPath := (Result = 0);

End;

Var
   PathStr  : String;
   CurrPath : String;
   SaveDir  : String;
   Count    : Byte;

Begin

   WriteLn('Check Path : By Tony Nelson : FreeWare 1993');
   WriteLn('Checking your current path for nonexistent entries...');
   WriteLn;

   GetDir(0,SaveDir);

   PathStr := GetEnv('Path');

   While (PathStr) <> '' do
      Begin
         GetNextPath(PathStr, CurrPath);

         If not CheckPath(CurrPath) then
            Begin
               WriteLn(CurrPath,' is invalid!');
               Inc(Count);
            End;
      End;


   If Count <> 0 then
      WriteLn;

   WriteLn('Found ',Count,' nonexistent entries.');


   ChDir(SaveDir);

End.