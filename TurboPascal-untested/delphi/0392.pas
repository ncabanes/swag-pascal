
> I would like to get the details of a table's indexes and save the
> details to a  file. Could someone please advise and possibly please
> provide a snippet of code

Here is a bit of code from one of my apps.
It walks through a table extracting all the index information for hat 
table, and then writes it to a ini file, so that I can read it back 
in later when the indexes become corrupted..

Hope this helps..


procedure TForm1.WriteIndexesToFile(TN:string);
begin
      with Table1 do
       begin
        Close;
        TableName := TN;
        Exclusive := TRUE;
        Open;
        Indexdefs.Update;
        ini.WriteInteger(TN,'Num_Indexes',Indexdefs.Count);
        for i := 0 to Indexdefs.Count-1 do
         begin
          ini.writeString(TN,'Name_'+IntToStr(i),IndexDefs.Items[
          I].Name);
          ini.writeString(TN,'Fields_'+IntToStr(i),IndexDefs.Item
          s[I].Fields); 
          s1 := '';
          s1 := GetOptions (IndexDefs.items[i].Options); {Converts 
the IndexDefs' options into a spintable string, so that can save them 
to file }
          ini.WriteString(TN,'Options_'+IntToStr(i),s1);
         end;
        close;
       end;
end;

