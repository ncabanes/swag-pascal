(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0250.PAS
  Description: List all files on disk in DELPHI
  Author: MIHAEL KUKEC
  Date: 05-30-97  18:17
*)


{
I was looking for some procedure or unit that would list file in directory
and all its subdirectories. I have found one procedure in SWAG that should
do something like DELTREE but it didn't work as I wanted, well it did work
but after some number of directories exception EInOutError occurred when
trying to change to directory and then I wrote this... It's recursive
procedure that will list files and directories in given directory and
all its subdirectories. Filenames and directories will be listed in
specified ListBox

From: Mihael.Kukec@public.srce.hr
Homepage and my programs : http://jagor.srce.hr/~mkukec
}

procedure TForm1.ListDir(Path:String; List:TListBox);
{Path : string that contains start path for listing filenames and directories
 List : List box in which found filenames are going to be stored }
var
SearchRec:TsearchRec;
Result:integer;
S:string; { Used to hold current directory, GetDir(0,s) }
begin
     try {Exception handler }
        ChDir(Path);
     except on EInOutError do
            begin
                 MessageDlg('Error occurred by trying to change directory',mtWarning,[mbOK],0);
                 Exit;
            end;
     end;
     if length(path)<> 3 then path:=path+'\';   { Checking if path is root, if not add }
     FindFirst(path+'*.*',faAnyFile,SearchRec); { '\' at the end of the string         }
                                                { and then add '*.*' for all file     }
     Repeat
           if SearchRec.Attr=faDirectory then   { if directory then }
           begin
                if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then { Ignore '.' and '..' }
                begin
                     GetDir(0,s); { Get current dir of default drive }
                     if length(s)<>3 then s:=s+'\'; { Checking if root }
                     List.Items.Add(s+SearchRec.Name); { Adding to list }
                     ListDir(s+SearchRec.Name,List); { ListDir found directory }
                end;
           end
           else { if not directory }
           begin
                GetDir(0,s); { Get current dir of default drive }
                if length(s)<>3 then List.items.add(s+'\'+SearchRec.Name) { Checking if root }
                   else List.items.add(s+SearchRec.Name); { Adding to list }
           end;
           Result:=FindNext(SearchRec);
           Application.ProcessMessages;
     until result<>0; { Found all files, go out }
     GetDir(0,s);
     if length(s)<>3 then ChDir('..'); { if not root then go back one level }
end;


