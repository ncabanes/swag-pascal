(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0290.PAS
  Description: Dealing with the Registry
  Author: CARLOS SOLA-LLONCH
  Date: 05-30-97  18:17
*)


{----------- Original message follows -----------
I'm having trouble finding out the correct way to use the TRegistry to
insert data into the registry.  I figured out how to change the root key and
create a new key, but how do I insert my data in that key?  How do I retrieve it?
Couldsomeone post some sample code on how to do this?


Thanks
}

procedure TSettings.LoadSettings;
var
   Reg: TRegistry;
begin
     Reg:= TRegistry.Create;
     try
        Reg.OpenKey(sCALLTRAKKEY, False);
        if Reg.ValueExists(sEXECPATH) then
           fExecPath:= Reg.ReadString(sEXECPATH);
        if Reg.ValueExists(sDBASEPATH) then
           fDbasePath:= Reg.ReadString(sDBASEPATH);
        if Reg.ValueExists(sEMAILPATH) then
           fEmailPath:= Reg.ReadString(sEMAILPATH);
     finally
        Reg.CloseKey;
        Reg.Free;
     end;
end;


procedure TSettings.UpdateSettings;
var
   Reg: TRegistry;
begin
     PrefDlg:= TPreferences.Create(Application);
     with PrefDlg do
     begin
        Edit1.Text:= fExecPath;
        Edit2.Text:= fDbasePath;
        Edit3.Text:= fEmailPath;
        if ShowModal = mrOk then
           try
              Reg.OpenKey(SCALLTRAKKEY, True);  {open the key or create
it if it doesn't exist}
              Reg.WriteString(sEXECPATH, fExecPath);
              Reg.WriteString(sDBASEPATH, fDbasePath);
              Reg.WriteString(sEMAILPATH, fEmailPath);
              fChanged:= True;
           finally
              Reg.CloseKey;
              Reg.Free;
           end;
     end;
     PrefDlg.Free;
end;

