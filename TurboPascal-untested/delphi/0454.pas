
From: "Mark Goodrich" <mgood@ns.net>


--------------------------------------------------------------------------------

uses
   Registry, Windows;

var
   TheReg: TRegistry;
   KeyName: String;
   ValueStr: String;

begin
   TheReg := TRegistry.Create;
   try
      TheReg.RootKey := HKEY_CURRENT_USER;
      KeyName := 'Software\MyTinyApp\StartUp;
      if TheReg.OpenKey(KeyName, False) then
      begin
         ValueStr := TheReg.ReadString('WorkPath');
         TheReg.CloseKey;
      end;
   finally
      TheReg.Free;
   end;
end;

--------------------------------------------------------------------------------

Also note, the correct place to store the path to your application's EXE under the Win95 registry is in:


--------------------------------------------------------------------------------

HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\AppPaths\MYAPP.EXE

--------------------------------------------------------------------------------

Store the complete path to your app as the default value under that key.

Regstr.pas defines a constant for this path up through ...\App Paths\ as REGSTR_PATH_APPPATHS.

Storing the path to your application's EXE here will allow a user to simply type MYAPP (or whatever its name is) in Start|Run on the taskbar and your application will launch. Here's an example of how to create it:


--------------------------------------------------------------------------------

uses
   Registry, Regstr;

var
   TheReg: TRegistry;
   KeyName: String;

begin
   TheReg := TRegistry.Create;
   try
      {Check AppPath setting, update if necessary}
      TheReg.RootKey := HKEY_LOCAL_MACHINE;
      KeyName := REGSTR_PATH_APPPATHS + ExtractFileName(Application.ExeName);
      if TheReg.OpenKey(KeyName, True) then
      begin
         if CompareText(TheReg.ReadString(''), Application.ExeName) <> 0 then
            TheReg.WriteString('', Application.ExeName);
         TheReg.CloseKey;
      end;
   finally
      TheReg.Free;
   end;
end;
