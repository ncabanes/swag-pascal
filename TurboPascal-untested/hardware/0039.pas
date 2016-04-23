{
> Does anyone have experience reading data coming IN the parallel port?  I
> can't find any technical literature saying it can be done, yet I know
> there are tape backup machines that use the parallel port to backup and
> restore data.

First you'd need to find the correct port:
}
Var
  Lpt:Array[1..4] Of Word Absolute $40:$8;

{ Then you can access the port like so: }

WriteLn('LPT1 contains ',Port[Lpt[1]]);
WriteLn('LPT2 contains ',Port[Lpt[2]]);

{
The next step would be to capture messages of incoming data - I've never done
this successfully, but in theory it should be a matter of capturing Int $F
for LPT1, $E for LPT2. Lpt3 & 4 depend on the irq, unless I am mistaken.

However, this still leaves decoding of information. I wouldnt have a clue how
to do that. I imagine it's device-dependant.
}
