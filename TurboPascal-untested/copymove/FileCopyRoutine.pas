(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0019.PAS
  Description: File Copy Routine
  Author: GUY MCLOUGHLIN
  Date: 10-28-93  11:33
*)


              (* Compiler directives.                               *)
 {$A+,B-,D-,E-,F-,I+,N-,O-,R-,S-,V+}

              (* STACK, HEAP memory directives.                     *)
 {$M 1024, 0, 0}

              (* Public domain file-copy program.                   *)
              (* Guy McLoughlin - August 23, 1992.                  *)
program MCopy;

uses          (* We need this unit for the paramcount, paramstr,    *)
  Dos;        (* fsearch, fexpand, fsplit routines.                 *)

const
              (* Carridge-return + Line-feed constant.              *)
  coCrLf = #13#10;

              (* Size of the buffer we're going to use.             *)
  coBuffSize = 61440;

type
              (* User defined file read/write buffer.               *)
  arBuffSize = array[1..coBuffSize] of byte;

var
              (* Path display width.                                *)
  byDispWidth : byte;

              (* Variable to record the number of files copied.     *)
  woCopyCount,
              (* Variable to record the number of bytes read.       *)
  woBytesRead,
              (* Variable to record the number of bytes written.    *)
  woBytesWritten : word;

              (* Variable to record the size in bytes of IN-file.   *)
  loInSize,
              (* Variable to record the number of bytes copied.     *)
  loByteProc : longint;

              (* Variables for TP "Fsplit" routine.                 *)
  stName : namestr;
  stExt  : extstr;

              (* Directory-string variables.                        *)
  stDirTo,
  stDirFrom : dirstr;

              (* Path-string variables.                             *)
  stPathTo,
  stPathFrom,
  stPathTemp : pathstr;

              (* Array used to buffer file reads/writes.            *)
  arBuffer : arBuffSize;

              (* Directory search-record.                           *)
  rcSearchTemp : searchrec;

              (* IN file-variable.                                  *)
  fiIN,
              (* OUT file-variable.                                 *)
  fiOUT : file;


   (***** Handle file errors.                                       *)
   procedure ErrorHandler( byErrorNum : byte);
   begin
     case byErrorNum of

       1 : begin
             writeln(coCrLf, ' (SYNTAX) MCOPY <path1><filespec1>' +
                             ' <path2><filename2>');
             writeln(coCrLf, ' (USAGE)  MCOPY c:\utils\*.doc' +
                             ' c:\temp\master.doc');
             writeln('          MCOPY   \utils\*.doc    ' +
                     '\temp\master.doc');
             writeln(coCrLf, ' (Copies all files with the ''.doc''' +
                             ' extension from ''c:\utils'')');
             writeln(' (directory, to ''master.doc'' in the ' +
                     '''c:\temp'' directory.    )');
             writeln(coCrLf, ' ( Public-domain utility by Guy ' +
                     'McLoughlin  \  August 1992  )')
           end;

       2 : writeln(coCrLf,
                  ' Error : <path1><filespec1> = <path2><filename2>');

       3 : writeln(coCrLf, ' Directory not found ---> ', stDirFrom);

       4 : writeln(coCrLf, ' Directory not found ---> ', stDirTo);

       5 : writeln(coCrLf, ' Error opening ---> ', stPathTo);

       6 : writeln(coCrLf, ' File copy aborted');

       7 : writeln(coCrLf, ' Error creating ---> ', stPathTo);

       8 : writeln(coCrLf, ' Error opening ---> ', stPathTemp);

       9 : writeln(coCrLf, ' Error with disk I/O ')

     end;     (* case byErrorNum.                                   *)

     halt
   end;       (* ErrorHandler.                                      *)


   (***** Determine if a file exists.                               *)
   function FileExist(FileName : pathstr) : boolean;
   begin
     FileExist := (FSearch(FileName, '') <> '')
   end;       (* FileExist.                                         *)


   (***** Determine if a directory exists.                          *)
   function DirExist(stDir : dirstr) : boolean;
   var
     woFattr : word;
     fiTemp  : file;
   begin
     assign(fiTemp, (stDir + '.'));
     getfattr(fiTemp, woFattr);
     if (doserror <> 0) then
       DirExist := false
     else
       DirExist := ((woFattr and directory) <> 0)
   end;       (* DirExist.                                          *)


   (***** Clear the keyboard-buffer.                                *)
   procedure ClearKeyBuff; assembler;
   asm
     @1: mov ah, 01h
         int 16h
         jz  @2
         mov ah, 00h
         int 16h
         jmp @1
     @2:
   end;       (* ClearKeyBuff                                       *)


   (***** Read a key-press.                                         *)
   function ReadKeyChar : char; assembler;
   asm
     mov ah, 00h
     int 16h
   end;        (* ReadKeyChar.                                      *)


   (***** Obtain user's choice.                                     *)
   function UserChoice : char;
   var
     Key : char;
   begin
     ClearKeyBuff;
     repeat
       Key := upcase(ReadKeyChar)
     until (Key in ['A', 'O', 'Q']);
     writeln(Key);
     UserChoice := Key
   end;       (* UserChoice.                                        *)


   (***** Returns all valid wildcard names for a specific directory.*)
   (*     When the last file is found, the next call will return an *)
   (*     empty string.                                             *)
   (*                                                               *)
   (* NOTE: Standard TP DOS unit must be listed in your program's   *)
   (*       "uses" directive, for this routine to compile.          *)

   function WildCardNames({ input}     stPath   : pathstr;
                                       woAttr   : word;
                          {update} var stDir    : dirstr;
                                   var rcSearch : searchrec)
                          {output}              : pathstr;
   var
              (* Fsplit variables.                                  *)
     stName : namestr;
     stExt  : extstr;
   begin
              (* If the search-record "name" field is empty, then   *)
              (* initialize it with the first matching file found.  *)
     if (rcSearch.name = '') then
       begin
              (* Obtain directory-string from passed path-string.   *)
         fsplit(stPath, stDir, stName, stExt);

              (* Find first match of path-string.                   *)
         findfirst(stPath, woAttr, rcSearch);

              (* If a matching file was found, then return full     *)
              (* path-name.                                         *)
         if (doserror = 0) and (rcSearch.name <> '') then
           WildCardNames := (stDir + rcSearch.name)
         else
              (* No match found, return empty string.               *)
           WildCardNames := ''
       end
     else
              (* Search-record "name" field is not empty, so        *)
              (* continue searching for matches.                    *)
       begin
         findnext(rcSearch);

              (* If no error occurred, then match was found...      *)
         if (doserror = 0) then
           WildCardNames := (stDir + rcSearch.name)
         else
              (* No match found. Re-set search-record "name" field, *)
              (* and return empty path-string.                      *)
           begin
             rcSearch.name := '';
             WildCardNames := ''
           end
       end
   end;


   (***** Pad a string with extras spaces on the right.             *)
   function PadR(stIn : string; bySize : byte) : string;
   begin
     fillchar(stIn[succ(length(stIn))], (bySize - length(stIn)) ,' ');
     inc(stIn[0], (bySize - length(stIn)));
     PadR := stIn
   end;       (* PadR.                                              *)


              (* Main program execution block.                      *)
BEGIN
              (* If too many or too few parameters, display syntax. *)
  if (paramcount <> 2) then
    ErrorHandler(1);

              (* Assign program parameters to string variables.     *)
  stPathFrom := paramstr(1);
  stPathTo   := paramstr(2);

              (* Make sure full path-string is used.                *)
  stPathFrom := fexpand(stPathFrom);
  stPathTo   := fexpand(stPathTo);
  stPathTemp := stPathFrom;

              (* Check if IN-Filename is the same as OUT-Filename.  *)
  if (stPathFrom = stPathTo) then
    ErrorHandler(2);

              (* Seperate directory-strings from path-strings.      *)
  fsplit(stPathFrom, stDirFrom, stName, stExt);
  fsplit(stPathTo, stDirTo, stName, stExt);

              (* Make sure that "From" directory exists.            *)
  if NOT DirExist(stDirFrom) then
    ErrorHandler(3);

              (* Make sure that "To" directory exists.              *)
  if NOT DirExist(stDirTo) then
    ErrorHandler(4);

              (* Determine the full path display width.             *)
  if (stDirFrom[0] > stDirTo[0]) then
    byDispWidth := length(stDirFrom) + 12
  else
    byDispWidth := length(stDirTo) + 12;

              (* Check if the OUT-File does exist, then...          *)
  if FileExist(stPathTo) then
    begin
              (* Ask if user wants to append/overwrite file or quit.*)
      writeln(coCrLf, ' File exists ---> ', stPathTo);
      write(coCrLf, ' Append / Overwrite / Quit  [A,O,Q]? ');

              (* Obtain user's response.                            *)
      case UserChoice of
        'A' : begin
              (* Open the OUT-file to write to it.                  *)
                assign(fiOUT, stPathTo);
                {$I-}
                reset(fiOUT, 1);
                {$I+}

              (* If there is an error opening the OUT-file, inform  *)
              (* the user of it, and halt the program.              *)
                if (ioresult <> 0) then
                  ErrorHandler(5);

              (* Seek to end of file, so that data can be appended. *)
                seek(fiOUT, filesize(fiOUT))
              end;

        'O' : begin
              (* Open the OUT-file to write to it.                  *)
                assign(fiOUT, stPathTo);
                {$I-}
                rewrite(fiOUT, 1);
                {$I+}

              (* If there is an error opening the OUT-file, inform  *)
              (* the user of it, and halt the program.              *)
                if (ioresult <> 0) then
                  ErrorHandler(5)
              end;

        'Q' : ErrorHandler(6)

      end     (* case UserChoice.                                   *)

    end

  else        (* OUT-file does not exist.                           *)

    begin
              (* Create the OUT-file to write to.                   *)
      assign(fiOUT, stPathTo);
      {$I-}
      rewrite(fiOUT, 1);
      {$I+}

              (* If there is an error creating the OUT-file, inform *)
              (* the user of it, and halt the program.              *)
      if (ioresult <> 0) then
        ErrorHandler(7)
    end;

              (* Clear the search-record, before begining.          *)
  fillchar(rcSearchTemp, sizeof(rcSearchTemp), 0);

              (* Initialize copy-counter.                           *)
  woCopyCount := 0;

              (* Set current file-mode to "read-only".              *)
  filemode := 0;

  writeln;

              (* Repeat... ...Until (stPathTemp = '').              *)
  repeat
              (* Search for vaild filenames.                        *)
    stPathTemp := WildCardNames(stPathTemp, archive, stDirFrom,
                                rcSearchTemp);

              (* If file search was successful, then...             *)
    if (stPathTemp <> '') then
      begin
              (* Open the IN-file to read it.                       *)
        assign(fiIN, stPathTemp);
        {$I-}
        reset(fiIN, 1);
        {$I+}

              (* If there is an error opening the IN-file, inform   *)
              (* the user of it, and halt the program.              *)
        if (ioresult <> 0) then
          begin
            close(fiOUT);
            erase(fiOUT);
            ErrorHandler(8)
          end;

              (* Determine the size of the IN-file.                 *)
        loInSize := filesize(fiIN);

              (* Set the number of bytes processed to 0.            *)
        loByteProc := 0;

              (* Repeat... ...Until the IN-file has been completely *)
              (* copied.                                            *)
        repeat

              (* Read the IN-file into the file-buffer.             *)
          blockread(fiIN, arBuffer, coBuffSize, woBytesRead);

              (* Write the file-buffer to the OUT-file.             *)
          blockwrite(fiOUT, arBuffer, woBytesRead, woBytesWritten);

              (* If there is a problem writing the bytes to the     *)
              (* OUT-file, let the user know, and halt the program. *)
          if (woBytesWritten <> woBytesRead) then
            begin
              close(fiIN);
              close(fiOUT);
              erase(fiOut);
              ErrorHandler(9)
            end
          else
              (* Advance the bytes-processed variable by the        *)
              (* number of bytes written to the OUT-file.           *)
            inc(loByteProc, woBytesWritten)

              (* Repeat... ...Until the complete IN-file has been   *)
              (* processed.                                         *)
        until (loByteProc = loInSize);

              (* Close the IN-file that has been copied.            *)
        close(fiIN);

              (* Increment copy-counter by 1.                       *)
        inc(woCopyCount);

              (* Let the user know that we've finished copying file.*)
        writeln(' ', PadR(stPathTemp, byDispWidth),' COPIED TO ---> ',
                stPathTo);

      end     (* If (stPathTemp <> '') then...                      *)

              (* Repeat... ...Until no more files are found.        *)
  until (stPathTemp = '');

              (* Close the OUT-file.                                *)
  close(fiOUT);

              (* Display the number of files copied.                *)
  if (woCopyCount = 0) then
    begin
      erase(fiOut);
      writeln(coCrLf, ' No matching files found ---> ', stPathFrom)
    end
  else
    writeln(coCrLf, ' ', woCopyCount, ' Files copied')
END.



