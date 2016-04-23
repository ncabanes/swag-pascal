{
DAVID DRZYZGA

> And I can't seem to get the OpDir system to work With multiple Files, or
> at least I can't get the "tagging" Function to work.

Here's a somewhat stripped snipit of code from one of my apps that will give
you a clear example of how to use the multiple pick Function of the DirList
Object:
}

Program DirTest;

{$I OPDEFINE.INC}

Uses
  Dos,
  OpRoot,
  OpConst,
  OpString,
  OpCrt,
  OpCmd,
  OpFrame,
  OpWindow,
  OpPick,
  OpDir,
  OpColor;

Const
  SliderChar    = '▓';
  ScrollBarChar = '░';
  Frame1        : FrameArray = '┌└┐┘──││';
  Counter       : Word = 1;

Var
  Dir          : DirList;
  Finished     : Boolean;
  SelectedItem : Word;
  DirWinOpts   : LongInt;
  I            : Integer;

Procedure ProcessFile(FileName : String);
begin
  {This is where you would process each of the tagged Files}
end;

begin
  DirWinOpts := DefWindowOptions+wBordered;
  if not Dir.InitCustom(20, 4, 50, 19, {Window coordinates}
                        DefaultColorSet,  {ColorSet}
                        DirWinOpts,    {Window options}
                        MaxAvail,      {Heap space For Files}
                        PickVertical,  {Pick orientation}
                        MultipleFile)  {Command handler}
  then
  begin
    WriteLn('Failed to Init DirList,  Status = ', InitStatus);
    Halt;
  end;

  {Set desired DirList features}
  With Dir do
  begin
    wFrame.AddShadow(shBR, shSeeThru);
    wFrame.AddCustomScrollBar(frRR, 0, MaxLongInt, 1, 1, SliderChar,
                              ScrollBarChar, DefaultColorSet);

    SetSelectMarker(#251' ', '');
    SetPosLimits(1, 1, ScreenWidth, ScreenHeight-1);
    SetPadSize(1, 1);
    diOptionsOn(diOptimizeSize);
    AddMaskHeader(True, 1, 30, heTC);
    SetSortOrder(SortDirName);
    SetNameSizeTimeFormat('<dir>', 'Mm/dd/yy', 'Hh:mmt');
    SetMask('*.*', AnyFile);
  end;

  {<AltP>: process selected list}
  PickCommands.AddCommand(ccUser0, 1, $1900, 0);

  {Pick Files}
  Finished := False;
  Repeat
    Dir.Process;
    Case Dir.GetLastCommand of
      ccSelect : ;
      ccError  : ;
      ccUser0  :
      begin
        Counter := 1;
        if Dir.GetSelectedCount > 0 then
        begin
          Dir.InitSequence(SelectedItem);
          While Dir.HaveSelected(SelectedItem) do
          begin
            ProcessFile(Dir.GetMultiPath(SelectedItem));
            Inc(Counter);
            Dir.NextSelected(SelectedItem);
            Dir.ResetList;
          end;
        end
      end;

      ccQuit : Finished := True;
    end;
  Until Finished;

  Dir.Erase;
  ClrScr;
  Dir.Done;
end.
