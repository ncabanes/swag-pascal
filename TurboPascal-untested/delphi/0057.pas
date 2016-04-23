{
        How to expand a path to a TOutlineNode referenced by Index

This is a routine from my forthcoming application Information Manager V1.0.
I thought that it might be interesting to others, so I'm contributing it to
the public.

The purpose I wrote this routine was, that I had an index from a TOutlineNode
(which was the result of search) and wanted to expand a path to the node
without expanding unnecessary trees.

The following routine accepts an index as a parameter and expands the path
to the TOutlineNode with this index.

The routine assumes a TOutline object named Outline.
}

var
  Outline: TOutline;

procedure TSearchDlg.ExpandPathToFoundItem(const FoundItemIndex: Longint);
{------------------------------------------------------------------------------
 Expands a path to a given item (item is specified by the index number). Only
 the parents needed to get to the specified item will be expanded.
 -----------------------------------------------------------------------------}
var
  ItemIndex:   Longint;
  Found:       Boolean;
  LastCh:      Longint;
  Path:        String;
  ItemText:    String;
  SepPos:      Integer;
  OldSep:      String;
begin
  {Save the old ItemSpearator}
  OldSep:=Outline.ItemSeparator;
  {Set the new ItemSeparator}
  Outline.ItemSeparator:='\';
  {Get the full path to the TOutlineNode and add a '\'. This is done, because it
   simplifies the whole algorithm}
  Path:=Outline.Items[FoundItemIndex].FullPath+'\';
  {As long as the end of the path has not been reached}
  while Length(Path) > 0 do begin
    {Determine the position of the first '\' in the path}
    SepPos:=Pos('\',Path);
    {Isolate the TOutlineNode item}
    ItemText:=Copy(Path,1,SepPos-1);
    {Determine the index of the TOutlineNode}
    ItemIndex:=Outline.GetTextItem(ItemText);
    {Expand it}
    Outline.Items[ItemIndex].Expand;
    {Cut the expanded TOutlineNode from the string}
    Path:=Copy(Path,SepPos+1,Length(Path)-SepPos+1);
  end;
  {Restore original ItemSeparator}
  Outline.ItemSeparator:=OldSep;
end;


DETAILS

Let's assume the full path to the desired item is:

        "My Computer\Hardware\SoundCard\Base Adress"

The first step returns the above path. Then the substring "My Computer" is
isolated. Then the index of the TOutlineNode "My Computer" is determined by
using the "GetTextItem" method. The "Expand" method expands this tree.
Afterwards "My Computer" is cut from the path resulting in the new path
"Hardware\SoundCard\Base Adress".

Then the index of "Hardware" is determined, expanded and again, cut away.
This procedure repeats until there is no path left to expand. Then the path
to the given TOutlineNode will be expanded.

If you have any questions or comments, you can reach me by e-mail at
Christian.Feichtner@jk.uni-linz.ac.at or you might want to have a look
at my homepage: http://www.cam.org/~psarena/cfeichtner
