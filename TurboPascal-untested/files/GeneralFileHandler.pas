(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0033.PAS
  Description: General File Handler
  Author: GUY MCLOUGHLIN
  Date: 11-02-93  05:42
*)

{
GUY MCLOUGHLIN

  ...Here's one way of creating generic routines to handle any type
  of file...
}

program Demo_Handle_Many_File_Types;

uses
  crt;

type          (* Path string type definition.                         *)
  st_79 = string[79];

              (* Enumerated type of the file types we want to handle. *)
  FileType = (Fchar, FrecA, FrecB, Ftext, Funty);

              (* First record type definition.                        *)
  recA = record
           Name : string;
           Age  : word
         end;

              (* Second record type definition.                       *)
  recB = record
           Unit : word;
           City : string
         end;

              (* Case-varient multi-file type definition.             *)
  rc_FileType = record
                  case FT : FileType of
                    Fchar : (Fchar1 : file of char);
                    FrecA : (FrecA1 : file of recA);
                    FrecB : (FrecB1 : file of recB);
                    Ftext : (Ftext1 : text);
                    Funty : (Funty1 : file)
                  end;


  (***** Display I/O error message.                                   *)
  (*                                                                  *)
procedure ErrorMessage({input }
                          by_Error : byte;
                          st_Path  : st_79);
var
  ch_Temp : char;
begin
            (* If an I/O error occured, then...                     *)
  if (by_Error <> 0) then
  begin
    writeln;
    case by_Error of
        2 : writeln('File not found ---> ', st_Path);
        3 : writeln('Path not found ---> ', st_Path);
        4 : writeln('Too many files open');
        5 : writeln('File access denied ---> ', st_Path);
      100 : writeln('Disk read error');
      103 : writeln('File not open ---> ', st_Path)
          (* NOTE: The full error code listing code be            *)
          (*       implemented if you like.                       *)
    end;
          (* Clear keyboard-buffer.                               *)
    while keypressed do
      ch_Temp := readkey;

          (* Pause for key-press.                                 *)
    writeln('Press any key to continue');
    repeat until keypressed
  end
end;        (* ErrorMessage.                                        *)

(***** Generic open routine to handle many different file types.    *)
(*                                                                  *)
procedure OpenFile({input } st_Path   : st_79;
                            bo_Create : boolean;
                        var rc_File   : rc_FileType);
begin
  {$I-}
            (* Handle appropriate file type.                        *)
  case rc_File.FT of
    Fchar : begin
              assign(rc_File.Fchar1, st_Path);
              if bo_Create then
                rewrite(rc_File.Fchar1)
              else
                reset(rc_File.Fchar1)
            end;
    FrecA : begin
              assign(rc_File.FrecA1, st_Path);
              if bo_Create then
                rewrite(rc_File.FrecA1)
              else
                reset(rc_File.FrecA1)
            end;
    FrecB : begin
              assign(rc_File.FrecB1, st_Path);
              if bo_Create then
                rewrite(rc_File.FrecB1)
              else
                reset(rc_File.FrecB1)
            end;
    Ftext : begin
              assign(rc_File.Ftext1, st_Path);
              if bo_Create then
                rewrite(rc_File.Ftext1)
              else
                reset(rc_File.Ftext1)
            end;
    Funty : begin
              assign(rc_File.Funty1, st_Path);
              if bo_Create then
                rewrite(rc_File.Funty1, 1)
              else
                reset(rc_File.Funty1, 1)
            end
  end;
  {$I+}
            (* Check for I/O error, and display message if needed.  *)
  ErrorMessage(ioresult, st_Path)

end;        (* OpenFile.                                            *)


var           (* Array of 5 mulit-file type records.                  *)
  FileArray : array[1..5] of rc_FileType;

              (* Main program execution block.                        *)
BEGIN
              (* Clear the screen.                                    *)
  clrscr;
              (* Clear the multi-file type array.                     *)
  fillchar(FileArray, sizeof(FileArray), 0);

              (* Initialize each file-variable to it's own type.      *)
  FileArray[1].FT := Fchar;
  FileArray[2].FT := FrecA;
  FileArray[3].FT := FrecB;
  FileArray[4].FT := Ftext;
  FileArray[5].FT := Funty;

              (* Create a new file of type CHAR.                      *)
  OpenFile('D:\TMP18\CHAR.TST', true,  FileArray[1]);

              (* Create a new file of type RecA.                      *)
  OpenFile('D:\TMP18\RECA.TST', true,  FileArray[2]);

              (* Open an existing file of type RecB.                  *)
  OpenFile('D:\TMP18\RECB.TST', false, FileArray[3]);

              (* Open an existing TEXT file.                          *)
  OpenFile('D:\TMP18\TEXT.TST', false, FileArray[4]);

              (* Open an existing un-typed file.                      *)
  OpenFile('D:\TMP18\BIN.DAT', false, FileArray[5]);

END.

