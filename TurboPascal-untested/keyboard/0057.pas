{
EDWIN CALIMBO

║ I need to know how I can clear the keyboard buffer.
║ The reason I need to do this is that in a loop I'm reading in
║ one Character and then calling a Procedure which returns to the
║ loop For the next Character to be read.  But sometimes it takes the
║ next Character in the buffer that my have been a result of just holding
║ down a key For to long.


  You can clear any keys in the keyboard buffer by using the following loop:
}
      While KeyPressed Do
        ch := ReadKey;
{
  Another way to clear the keyboard buffer is to set the keyboard head
  equal to the keyboard tail and the keyboard buffer as a circular buffer.
  You can set the tail equal to the head this way:
}
      MemW[$0000:$041C] := MemW[$0000:$041A];      { flush keyboard buffer }
