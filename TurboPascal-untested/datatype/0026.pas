{
> I'm trying to come up with a registration keying routine for my
> software, but am at kind of a loss on how to do it and make it somewhat
> secure or a pain to crack.
> Here's a program that supposedly uses RSA encryption, but it must be for
> an older pascal because I couldn't get it to compile with version 7.0
> since it tries to use a declaration of Integer[36]. I tried it with
> just a regular Integer declaration and I couldn't get it to work (I
> think).

 OKay...  As I recall, that Integer[36] thingy was implemented on DEC
 VMS systems (possibly others) as kind of a work around for, faster than
 real, large (greater than maxint) integer math applications.  You might
 try declaring the variables as longint to test out the algorithm..
 It's 32 bit, but then it may be a hair too small even for the math
 tricks that your rsa is doing...  Making such large numbers that it
 needs 36 bit integers to avoid overflows..

   Anyway.  I was really wondering why you didn't want to implement an
 XOR type of encryption method..  It's really so much faster than any
 math trick type of implementation...As there is really no math
 involved..

 Encryption security has three basic concerns:

 It has to be secure when the enemy knows or has in possesion the method
 that you encrypted your target,
 It has to be secure when the enemy has in his possesion, your target,
 And it has to be secure if the enemy has in possesion, your method,
 your target and your key.

 Whatever the method you use, all you are really doing is changing the
 value of a byte (the simplest item) to some other value.  Or you are
 restructuring the method of access.

   Or in plain english, you compress your file, then mess it up with
 some encryption algorithm that uses a key to decrypt it.
 How you compress, and how you encrypt doesn't really matter.

   What matters, is the possible number of ways that you COULD have
 used.  If that number (of ways) is computable, then your encryption
 method is crackable.

   This number (of possible methods) is called the domain of solutions.
 If the domain of solutions can be written into a program then any
 method and combinations of methods is crackable.

   To be uncrackable, the domain of solutions must be uncomputable.
 Actually, it may very well BE crackable, but so long as it is
 uncomputable, the cracker has no way to determine where to begin
 cracking!  Thus the defence or security lies not in remaining
 uncrackable, but in remaining encrypted.  Making it take too long to
 crack.  In other words just how much time will it take to solve the
 puzzle and for how long does the puzzle have to remain unsolved before
 it is no longer relevant.

   The perfect encryption engine, would be something that has too vast
 of a number of methods to be computable, yet very simple to operate and
 use.  The answer to this seemingly paradoxical question is simple.  You
 have to introduce a non machine element into the engine.  The human
 element.  A human determined key sequence.  In other words, your key is
 defined not by position or elements, but in steps.  Or instructions on
 what to do that is not machine or engine readable.  Or in other words,
 it can't be automatic (one step) and secure.

 There are many methods, including weird math methods.  However, it has
 been shown that ALL weird math methods are no more secure than simply
 adding 1 to the value of any byte.  The proof of this was published in
 a mathamatical journal some years ago, sorry, I don't remember what it
 was..  But it basicly stated that any weird math method could be broken
 by a simple brute force program that shifted the values of varying
 lengths of bits of a small portion of the target until it found
 recognizable text or data.

 Practical concerns:
   You want a Keyed registration system.  You want to be able to send
 the registered user a post card with some instructions on it on how to
 make his program registered.  This instruction card must be unique to
 his copy of the program.  I assume that the unregistered version of the
 program will be massively distributed I.E. Shareware concept.  Simple.
 You have two maybe three steps involved.
 1 :  A uniqueness must be made in the program, something that
 identifies and connects that particular copy of the program to that
 particular registered user.  A name...
 2:  You need some method of securing the program to that particular
 registered user.  A number or code that interacts with the name to
 produce a file, or key that must then be present during operation for
 the program to work in the registered mode.
 3:  The program must be made aware that it has been registered and if
 the registration code is found to be missing, it will revert to an
 unregistered mode.

    What may happen: If the name and code is given out or stolen,
 it must not work with any other copy of the software.   This is the
 most difficult effect to produce and is not possible to implement
 without your direct involvement in the proccess.  Don't expect to be
 able to produce this effect without direct involvment.   In effect, you
 have to make a unique modification to the program unknown to the user.

 I once worked on a project that had to be totally secured in this
 manner.  The software had to be registered not only to a specific
 individual or company, but also had to be registered to a single
 machine.  We had to be absolutely sure that there were not multiple
 copies of the software executing on different machines, or indeed on
 the same machine or that there were multiple copies of the software
 that could be installed/deinstalled on the same machine.  It was a
 financial system and the possibility of using it to produce multiple
 books existed which we had to avoid at all costs.  It took a while but
 we solved the problem, unfortunately the software was never produced or
 used, as the company I created this system for went belly up before the
 project was installed and the project was cancelled.

   What we used was a regestration key file, that was modified by the
 software, so that it couldn't be used again, it couldn't be used by any
 other copy of the program.  However, if something adverse happened, the
 program knew that it was modified and the same copy of the software
 (that had been origionally registered) could use the key again.  Also,
 the key was time stamped, it was only good for a certain range of
 dates, it couldn't be used to register a copy of the program outside a
 3 day limit.   Also, the software wouldn't operate, even if it was
 registered, if it detected that the date was 30 days since it last
 operated.  It had to be in continuous use at least every 29 days for it
 to remain registered.  Remember that this was a financial package, and
 it had to remain updated to be relevant.  We also had planned to link
 to and download it's data every 30 days and provide a new key to
 operate for the next  30 days.  Thus if the software was installed, and
 the phone lines went down, or we went out of business, the software
 would refuse to operate ( in fact it would self destruct and encrypt
 all work in progress) after 30 days of no contact with home office.
 Also note that at no time did the end user ever have the key file
 before the program saw it first and got a chance to modify it.  Once
 that happened, it couldn't be used by some other copy.  Also, we
 planned on not telling the end users that the software would only work
 on one machine ( the machine it was installed on) We wanted them to
 attempt to pirate the software..
 Why?
   So that we could test their honesty as partners in the business...

   I suppose that this was somewhat mercenary on our part, but then, I
 didn't make those kinds of decisions, I just wrote the software....
}
