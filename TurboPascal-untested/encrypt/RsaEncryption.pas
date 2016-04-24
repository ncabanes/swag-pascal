(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0017.PAS
  Description: RSA Encryption
  Author: SWAG SUPPORT TEAM
  Date: 08-27-93  21:35
*)

RSA encryption.

 The encryption key is:   C = M to the power of e MOD n

         where C is the encrypted byte(s)
               M is the byte(s) to be encrypted
               n is the product of p and q
               p is a prime number ( theoretically 100 digits long )
               q is a prime number ( theoretically 100 digits long )
               e is a number that  gcd(e,(p-1),(q-1)) = 1

  The decryption key is:   M = C to the power of d MOD n

         Where C is the encrypted byte(s)
               M is the original byte(s)
               n is the product of p and q
               p is a prime number ( must be the same as the encrypting one )
               q is a prime number ( "            "           "           " )
               d is the inverse of the modulo   e MOD (p-1)(q-1)


As you can see in order to crack the encrypted byte(s) you would need to know
the original prime #'s,  Even with the encryption key it would take a long time
to genetate the correct prime #'s needed....

an Example...

           C = M to the power of 13 MOD 2537

         2537 is the product of 43 and 59.

   the decryption key is

           M = C to the power of 937 MOD 2537

       937 is the inverse of  13 MOD (43 - 1)(59 - 1).


