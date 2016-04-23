{│o│ I want to make my buffer For the BlockRead command as       │o║
│o│ large as possible. When I make it above 11k, I get an       │o║
│o│ error telling me "too many Variables."                      │o║
Use dynamic memory, as in thanks a heap.
}


if memavail > maxint  { up to 65520 }
then bufsize := maxint
else bufsize := memavail;
if i<128
then Exitmsg('No memory')
else getmem(buf,bufsize);


