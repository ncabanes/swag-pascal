(* Program to demonstrate BlockRead and BlockWrite    *)
(* routines.                                          *)
Program BlockReadWriteDemo;
Uses
  Crt;
Type
  st20 = String[20];
  st40 = String[40];
  st80 = String[80];

  rcPersonInfo = Record
                   stFirst : st20;
                   stLast  : st20;
                   byAge   : Byte
                 end;
Const
  coRecSize = sizeof(rcPersonInfo);

Var
  wototalRecs : Word;
  rcTemp      : rcPersonInfo;
  fiData      : File;

  (***** Initialize Program Variables.                              *)
  Procedure Init;
  begin
    ClrScr;
    wototalRecs := 0;
    fillChar(rcTemp, coRecSize, 0);
    fillChar(fiData, sizeof(fiData), 0)
  end;        (* Init.                                              *)

  (***** Handle Program errors.                                     *)
  Procedure ErrorHandler(byErrorNumber : Byte; boHalt : Boolean);
  begin
    Case byErrorNumber of
      1 : Writeln('Error creating new data-File.');
      2 : Writeln('Error writing Record to data-File.');
      3 : Writeln('Record does not exist.');
      4 : Writeln('Error reading Record from data-File.');
      5 : Writeln('Error erasing Record in data-File.')
    end;      (* Case byErrorNumber of                              *)
    if boHalt then
      halt(byErrorNumber)
  end;        (* ErrorHandler.                                      *)

  (***** Create new data-File to hold Record data.                  *)
  Function CreateDataFile(Var fiData : File) : Boolean;
  begin
    {$I-}
    reWrite(fiData, 1);
    {$I+}
    if (ioresult = 0) then
      CreateDataFile := True
    else
      CreateDataFile := False
  end;        (* CreateDataFile.                                    *)

  (***** Open data-File.                                            *)
  Procedure OpenDataFile(Var fiData : File; stFileName : st80);
  begin
    assign(fiData, stFileName);
    {$I-}
    reset(fiData, 1);
    {$I+}
    if (ioresult <> 0) then
      begin
        if (CreateDataFile(fiData) = False) then
          ErrorHandler(1, True)
        else
          Writeln('New data-File ', stFileName, ' created.')
      end
    else
      Writeln('Data-File ', stFileName, ' opened.');
    wototalRecs := Filesize(fiData) div coRecSize
  end;        (* OpenDataFile.                                      *)

  (***** Add a Record to the data-File.                             *)
  Procedure AddRecord(woRecNum : Word; Var rcTemp : rcPersonInfo);
  Var
    woBytesWritten : Word;
  begin
    if (woRecNum > succ(wototalRecs)) then
      woRecNum := succ(wototalRecs);
    seek(fiData, (pred(woRecNum) * coRecSize));
    blockWrite(fiData, rcTemp, coRecSize, woBytesWritten);
    if (woBytesWritten = coRecSize) then
      inc(wototalRecs)
    else
      ErrorHandler(2, True)
  end;        (* AddRecord.                                         *)


(***  PART 2     *****)

  (***** Get a Record from the data-File.                           *)
  Procedure GetRecord(woRecNum : Word; Var rcTemp : rcPersonInfo);
  Var
    woBytesRead : Word;
  begin
    if (woRecNum > wototalRecs)
    or (woRecNum < 1) then
      begin
        ErrorHandler(3, False);
        Exit
      end;
    seek(fiData, (pred(woRecNum) * coRecSize));
    blockread(fiData, rcTemp, coRecSize, woBytesRead);
    if (woBytesRead <> coRecSize) then
      ErrorHandler(4, True)
  end;        (* GetRecord.                                         *)

  (***** Erase the contents of a data-File Record.                  *)
  Procedure EraseRecord(woRecNum : Word);
  Var
    woBytesWritten : Word;
    rcEmpty        : rcPersonInfo;
  begin
    if (woRecNum > wototalRecs)
    or (woRecNum < 1) then
      begin
        ErrorHandler(3, False);
        Exit
      end;
    fillChar(rcEmpty, coRecSize, 0);
    seek(fiData, (pred(woRecNum) * coRecSize));
    blockWrite(fiData, rcEmpty, coRecSize, woBytesWritten);
    if (woBytesWritten <> coRecSize) then
      ErrorHandler(5, True)
  end;        (* EraseRecord.                                       *)

  (***** Display a Record's fields.                                 *)
  Procedure DisplayRecord(Var rcTemp : rcPersonInfo);
  begin
    With rcTemp do
      begin
        Writeln;
        Writeln(' Firstname = ', stFirst);
        Writeln(' Lastname  = ', stLast);
        Writeln(' Age       = ', byAge);
        Writeln
      end
  end;        (* DisplayRecord.                                     *)

  (***** Enter data into a Record.                                  *)
  Procedure EnterRecData(Var rcTemp : rcPersonInfo);
  begin
    Writeln;
    With rcTemp do
      begin
        Write('Enter First-name : ');
        readln(stFirst);
        Write('Enter Last-name  : ');
        readln(stLast);
        Write('Enter Age        : ');
        readln(byAge)
      end;
    Writeln
  end;        (* EnterRecData.                                      *)

  (***** Obtain user response to Yes/No question.                   *)
  Function YesNo(stMessage : st40) : Boolean;
  Var
    chTemp : Char;
  begin
    Writeln;
    Write(stMessage, ' (Y/N) [ ]', #8#8);
    While KeyPressed do
      chTemp := ReadKey;
    Repeat
      chTemp := upCase(ReadKey)
    Until (chTemp in ['Y','N']);
    Writeln(chTemp);
    if (chTemp = 'Y') then
      YesNo := True
    else
      YesNo := False
  end;        (* YesNo.                                             *)

  (***** Compact data-File by removing empty Records.               *)
  Procedure PackDataFile(Var fiData : File);
  begin
    (* This one I'm leaving For you to Complete.                    *)
  end;        (* PackDataFile.                                      *)

(***** PART 3   *****)
              (* Main Program execution block.                      *)
begin
  Init;
  OpenDataFile(fiData, 'TEST.DAT');
  rcTemp.stFirst := 'Bill';
  rcTemp.stLast  := 'Gates';
  rcTemp.byAge   := 36;
  DisplayRecord(rcTemp);
  AddRecord(1, rcTemp);
  rcTemp.stFirst := 'Phillipe';
  rcTemp.stLast  := 'Khan ';
  rcTemp.byAge   := 39;
  DisplayRecord(rcTemp);
  AddRecord(2, rcTemp);
  GetRecord(1, rcTemp);
  DisplayRecord(rcTemp);
  EraseRecord(1);
  GetRecord(1, rcTemp);
  DisplayRecord(rcTemp);
  EnterRecData(rcTemp);
  AddRecord(1, rcTemp);
  DisplayRecord(rcTemp);
  close(fiData);
  if YesNo('Erase the Record data-File ?') then
    erase(fiData)
end.


