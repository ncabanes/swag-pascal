(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0135.PAS
  Description: Determining the Cursor Position in Memo
  Author: RANDY L. HABEN
  Date: 05-31-96  09:16
*)

{
> Is it possible to get the position of the cursor (lines and columns)
> for a memo field. If not, is there a component somewhere that will
> let me do this.

I had the same problem with an editor I wrote called TabNotes.  You can get this from:

 http://www.reusable.com

Anyway, here is how I got the info for a descendant of TMemo called TNotePad:

{The following two methods are used to get row/column coordinates.     }
{There are no messages that explicitly provide column information but the}
{EM_GETSEL message provides the position of the caret if a selection is  }
{not currently active. When text is selected the caret can be positioned at }
{the beginning or the end of the selection depending how it was selected.}
{Thus these methods may be slightly inaccurate while text is selected. }

function  TNotePad.GetColumn: SmallInt;
begin
  Result := (SelStart+SelLength) -        {Assume that caret is at end of Selection}
            Perform(EM_LINEINDEX, -1, 0); {Method version of SendMessage}
end;

function  TNotePad.GetRow: SmallInt;
begin
  Result := LongRec(Perform(EM_LINEFROMCHAR, -1, 0)).Lo; {Get Low word}
end;

