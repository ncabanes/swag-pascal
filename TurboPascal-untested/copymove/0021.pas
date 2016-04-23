{
 MC> That's really important, for what you've tested and shown.
 MC> However, your specific values don't apply to everyone, as smaller HDs
 MC> have smaller sector sizes (4096, 2048, etc.).  In order for your thesis
 MC> to work best, the code/logic should also determine the HD sector size,
 MC> before allocating buffers and trying to maximize performance to this
 MC> degree.  That gets down into some pretty low-level code...

     It wouldn't be "that" tough really (if you wanted to do it). You simply
make the buffer as large as the optimum size for the smallest cluster size
which is 64512 (1024*63). Then do your blockread/blockwrites based on the
optimal number for the current cluster size. It is, after all, the size of the
block to read/write which is adversely affecting the speed, and not the size
of the buffer itself.
     It would look something like this.
}

Uses Dos;

Const
maxarray = 64512;

Var
regs        :registers;
buf         :array[1..maxarray] of char;
fil1,
fil2        :file;
maxread,
numread,
numwritten,
clustSize   :word;

begin
   regs.cx := 0;                        {set for error-checking}
   regs.ax := $3600;                    {get free space}
   regs.dx := 0;                        {0=current, 1=a:, 2=b:, etc.}
   msDos (regs);
   clustsize := regs.ax * regs.cx;      {cluster size}
   maxread := maxarray - (maxarray mod clustsize);
             {the largest number of bytes ("char"s) evenly divisible
              by the cluster size that will fit in our array}
   assign(fil1,paramstr(1));
   assign(fil2,paramstr(2));
   reset(fil1,1);
   rewrite(fil2,1);
   repeat
      blockread(fil1,buf,maxread,numread);
      blockwrite(fil2,buf,numread,numwritten);
      until ((eof(fil1)) or (numwritten=0));
   close(fil1);
   close(fil2);
   end.

Error checking not included!!

     You may wish to redefine "regs.dx" above if the copy drive is other than
current, but you will likely find this gives you the fastest "copy" regardless
of the cluster size of the medium. With the noteable exception that if you
had a medium with 512 byte clusters, the above optimal number "could" be
increased by 512 if the variables were otherwise defined. (Placing the buffer
in the heap for instance.) Not that any drive with a 512 byte cluster is
really worth the trouble <G> but if you were going to put "buf" in the heap
then you should consider using maxarray = 65024 (127*512) instead of 64512.

Dave...

--- GEcho 1.11+
 * Origin: Forbidden Knights Systems * (905)820-7273 * Dual * (1:259/423.0)
SEEN-BY: 250/99 101 201 301 401 470 501 601 701 801 901 259/0
SEEN-BY: 259/99 200 303 400 423 500 396/1 3615/50 51
PATH: 259/423 400 99 250/99 3615/50
