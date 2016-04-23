{
From: STEVE ROGERS
Subj: Rebooting
Here's some code to make both warmboot and coldboot com files. If you
want to make them TP procs, just enter them as inline code.

------------------------------------------------------------------------
{Makes two COM files: WARMBOOT & COLDBOOT }

const
  Warm_Boot : array[1..17] of byte =  { inline code for warm boot }
                                     ($BB,$00,$01,$B8,$40,$00,
                                      $8E,$D8,$89,$1E,$72,$00,
                                      $EA,$00,$00,$FF,$FF);

  Cold_Boot : array[1..17] of byte =  { inline code for cold boot }
                                     ($BB,$38,$12,$B8,$40,$00,
                                      $8E,$D8,$89,$1E,$72,$00,
                                      $EA,$00,$00,$FF,$FF);

var
  f : file;

begin
  assign(f,'warmboot.com');
  rewrite(f,1);
  blockwrite(f,warm_boot,17);
  close(f);

  assign(f,'coldboot.com');
  rewrite(f,1);
  blockwrite(f,cold_boot,17);
  close(f);
end.
