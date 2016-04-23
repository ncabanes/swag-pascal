
Hello Nick,
That's way to use INI-files
1. Add the Inifile Unit to your interface uses-section
2. create a new unit with your INI-defaultvalues !!!
3. Use the OnCreate-event to read your INI-file
   procedure TForm1.FormCreate(Sender : TObject);
   var
       Ini : TInifile;
   begin
     Try
     Ini:=TInfile.Create(write the path and the name of your INI-file here);
     CheckBox1.Checked:=Ini.ReadBool('CheckBox','Checked',DefaultCheckBoxValue);
     MyString:=Ini.ReadString('MyString','Value',DefaultMyStringValue);
     ...
     Ini.Free;
     Except
       On Exception do
       MessageDLG('Can't read the INI-File',mtError,[mbOk],0);
     end;{Try/Except}
   end;
4. Create a new Form with an INI-Dialog with the standard dialog-elements
   Use the OnClick-event of your OkBtn to write to your INI-file
   procedure TIniForm.OkBtnClick(Sender : TObject);
   var
       Ini : TIniFile;
   begin
    Try
     Ini:=TInfile.Create(write the path and the name of your INI-file here);
     Ini.WriteBool('CheckBox','Checked',CheckBox1.Checked);
     Ini.ReadString('MyString','Value',MyString);
     ...
     Ini.Free;
     Except
       On Exception do
       MessageDLG('Can't read the INI-File',mtError,[mbOk],0);
     end;{Try/Except}
   end;
