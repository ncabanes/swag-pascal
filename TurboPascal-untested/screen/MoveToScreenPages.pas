(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0042.PAS
  Description: Move to Screen Pages
  Author: GREG ESTABROOKS
  Date: 11-02-93  08:25
*)

{ Updated SCREEN.SWG on November 2, 1993 }

{
GREG ESTABROOKS

>I know how to block-Write directly into $B800:0000, which is the Video
>page, using the MOVE command. Is there a way to do this to a specific
>Page (ie. Page 1, or Page 2)? I've tried it With my routines, but it
>just sends it to whatever page I'm looking at - I assume becuase it is a
>direct access.

  Actually if you understand how to use MOVE to blockmove
  everything into $B800:0000 then you already know how to move
  it into the other pages. All you need to do is calculate the
  offsets of the different pages.
  Page 0 = $B800:$0000
  Page 1 = $B800:$0FA0
  Page 2 = $B800:$1F40
  Page 3 = $B800:$2EE0
  (Note These might differ if your using 43/50 line modes)

  So if you wanted to move/copy a screen from a buffer to page 1
  you'd do it like this:
}

Const
  PageOffs : Array [0..3] of Word = ($0000, $0FA0, $1F40, $2EE0);

  Move(Buffer[1], Mem[$B800 : PagesOffs[1]], 4000);

{ Or from screen 1 to 0 then : }

  Move(Mem[$B800 : PageOffs[1]], Mem[$B800 : PageOffs[0]], 4000);


