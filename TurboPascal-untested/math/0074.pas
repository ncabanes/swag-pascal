{
─ Area: U-PASCAL      |61 ────────────────────────────────────────────────────
  Msg#: 5727                                         Date: 07-05-94  08:14
  From: Bschor@vms.cis.pitt.edu                      Read: Yes    Replied: No
    To: All                                          Mark:
  Subj: FFT Algorithm in Pascal
──────────────────────────────────────────────────────────────────────────────
From: bschor@vms.cis.pitt.edu

     Over the past several weeks, there have been questions about the Fast
Fourier Transform, including requests for a version of the algorithm.  The
following is one such implementation, optimized for clarity (??) at the
possible expense of a few percentage points in speed (it's pretty darn
fast).  It is written in "vanilla" Pascal, so it should work with all
variants of the language.

     Note that buried in the comments is a reasonable reference for the
algorithm.
   }


PROGRAM fft (input, output);

  {****************************************}
  {                                        }
  {         Bob Schor                      }
  {         Eye and Ear Institute          }
  {         203 Lothrop Street             }
  {         Pittsburgh, PA   15213         }
  {                                        }
  {****************************************}

  { test routine for FFT in Pascal -- includes real and complex }

  { Version 1.6 -- first incarnation }
  { Version 10.7 -- upgrade, allow in-place computation of coefficients }
  { Version 14.6 -- comments added for didactic purposes }
 
CONST
  version = 'FFT       Version 14.6';
 
CONST
  maxarraysize = 128;
  halfmaxsize = 64;
  maxfreqsize = 63;
TYPE
  dataindextype = 1 .. maxarraysize;
  cmpxindextype = 1 .. halfmaxsize;
  freqindextype = 1 .. maxfreqsize;
  complex = RECORD
              realpart, imagpart : real
            END;
  dataarraytype = RECORD
                    CASE (r, c) OF
                      r : (rp : ARRAY [dataindextype] OF real);
                      c : (cp : ARRAY [cmpxindextype] OF complex)
                  END;
  cstermtype = RECORD
                 cosineterm, sineterm : real
               END;
  fouriertype = RECORD
                  dcterm : real;
                  noiseterm : real;
                  freqterms : ARRAY [freqindextype] OF cstermtype
                END;
  mixedtype = RECORD
                CASE (dtype, ctype) OF
                  dtype : (dataslot : dataarraytype);
                  ctype : (coefslot : fouriertype)
              END;
 
CONST
  twopi = 6.2831853;
VAR
  data : dataarraytype;
  didx : dataindextype;
  fidx : freqindextype;
  coefficients : fouriertype;
  mixed : mixedtype;
 
  { A note on declarations, above.  Pascal does not have a base type of
   "complex", but it is fairly simple, given the strong typing in the
   language, to define such a type.  One needs to write procedures (see
   below) that implement the common arithmetic operators.  Functions
   would be even better, from a logical standpoint, but the language
   standard does not permit returning a record type from a function.
   .     The FFT, strictly speaking, is a technique for transforming a
   complex array of points-in-time into a complex array of points-in-
   Fourier space (complex numbers that represent the gain and phase of
   the response at discrete frequencies).  One typically has data,
   representing samples taken at some fixed sampling rate, for which
   one wants the Fourier transform, to compute a power spectrum, for
   example.  Such data, of course, are "real" quantities.  One could
   take these N points, make them the real part of a complex array of
   size N (setting the imaginary part to zero), and take the FFT.
   However, in the interest of speed (the first F of FFT means "fast",
   after all), one can also do a trick where the N "real" points are
   identified with the real, imaginary, real, imaginary, etc. points of
   a complex array of size N/2.  The FFT now takes about half the time,
   and one needs to do some final twiddling to obtain the sine/cosine
   coefficients of the size N real array from the coefficients of the
   size N/2 complex array.
   .     To clarify the dual interpretation of the data array as either
   N reals or N/2 complex points, the tagged type "dataarraytype" was
   defined.  On input, it represents the complex data; on output from the
   complex FFT, it represents the complex Fourier coefficients.  A final
   transformation on these complex coefficients can convert them into a
   series of real sine/cosine terms; for this purpose, the tagged type
   "mixed" was defined for the real FFT.
   .     Finally, note that this, and most, FFT routines get their
   speed when the number of points is a power of 2.  This is because
   the speed comes from a divide-and-conquer approach -- to do an FFT
   of N points, do two FFTs of N/2 points and combine the results. }
 
 
  PROCEDURE fftofreal (VAR mixed : mixedtype;
                       realpoints : integer);
 
    { This routine performs a forward Fourier transform of an array
     "mixed", which on input is assumed to consist of "realpoints" data
     points and on output consists of a set of Fourier coefficients (a
     DC term, (N/2 - 1) sine and cosine terms, and a residual "noise"
     term). }
 
  CONST
    twopi = 6.2831853;
  VAR
    index, minusindex : freqindextype;
    temp1, temp2, temp3, w : complex;
    baseangle : real;
 
    { The following procedures implement complex arithmetic -- }
 
    PROCEDURE cadd (a, b : complex;
                    VAR c : complex);
 
      { c := a + b }
 
     BEGIN   { cadd }
       WITH c DO
        BEGIN
          realpart := a.realpart + b.realpart;
          imagpart := a.imagpart + b.imagpart
        END
     END;
 
    PROCEDURE csubtract (a, b : complex;
                         VAR c : complex);
 
      { c := a - b }
 
     BEGIN   { csubtract }
       WITH c DO
        BEGIN
          realpart := a.realpart - b.realpart;
          imagpart := a.imagpart - b.imagpart
        END
     END;
 
    PROCEDURE cmultiply (a, b : complex;
                         VAR c : complex);

      { c := a * b }
 
     BEGIN   { cmultiply }
       WITH c DO
        BEGIN
          realpart := a.realpart*b.realpart - a.imagpart*b.imagpart;
          imagpart := a.realpart*b.imagpart + b.realpart*a.imagpart
        END
     END;
 
    PROCEDURE conjugate (a : complex;
                         VAR b : complex);
 
      { b := a* }
 
     BEGIN   { conjugate }
       WITH b DO
        BEGIN
          realpart := a.realpart;
          imagpart := -a.imagpart
        END
     END;
 
    PROCEDURE forwardfft (VAR data : dataarraytype;
                          complexpoints : integer);
 

      { The basic FFT is a recursive routine that basically works as
       follows:
       1)  The FFT is a linear operator, so the FFT of a sum is simply
       .   the sum of the FFTs of each addend.
       2)  The FFT of a time series shifted in time is the FFT of the
       .   unshifted series adjusted by a twiddle factor which looks
       .   like a (complex) root of 1 (an nth root of unity).
       3)  Consider N points, equally spaced in time, for which you
       .   want an FFT.  Start by splitting the series into odd and
       .   even samples, giving you two series with N/2 points,
       .   equally spaced, but with the second series delayed in time
       .   by one sample.  Take the FFT of each series.  Using property
       .   2), adjust the FFT of the second series for the time delay.
       .   Now using property 1), since the original N points is simply
       .   the sum of the two N/2 series, the FFT we want is simply the
       .   sum of the FFTs of the two sub-series (with the adjustment
       .   in the second for the time delay).
       4)  This is essentially a recursive definition.  To do an N-point
       .   FFT, do two N/2 point FFTs and combine the answers.  All we
       .   need to stop the recursion is to know how to do a 2-point
       .   FFT: if a and b are the two (complex) input points, the
       .   two-point FFT equations are A := a+b; B := a-b.
       5)  The FFT is rarely coded in its fully-recursive form.  It
       .   turns out to be fairly simple to "unroll" the recursion and
       .   reorder it a bit, which simplifies the computation of the
       .   roots-of-unity complex twiddle factors.  The only drawback
       .   is that the output array ends up scrambled -- if the array
       .   indices are represented as going from 0 to M-1, then if one
       .   represents the array index as a binary number, one needs to
       .   bit-reverse the number to get the proper place in the array.
       .   Thus, the next step is to swap values by bit-reversing the
       .   indices.
       6)  There are numerous references on the FFT.  A reasonable one
       .   is "Numerical Recipes" by Press et al., Cambridge University
       .   Press, which I believe exists in several language flavors. }
 
    CONST
      twopi = 6.2831853;
 
      PROCEDURE docomplextransform;
 
      VAR
        partitionsize, halfsize, offset,
        lowindex, highindex : dataindextype;
        baseangle, angle : real;
        bits : integer;
        w, temp : complex;
 
       BEGIN   { docomplextransform }
         partitionsize := complexpoints;
         WITH data DO
          REPEAT
           halfsize := partitionsize DIV 2;
           baseangle := twopi/partitionsize;
           FOR offset := 1 TO halfsize DO
            BEGIN
              angle := baseangle * pred(offset);
              w.realpart := cos(angle);
              w.imagpart := -sin(angle);
              lowindex := offset;
               REPEAT
                highindex := lowindex + halfsize;
                csubtract (cp[lowindex], cp[highindex], temp);
                cadd (cp[lowindex], cp[highindex], cp[lowindex]);
                cmultiply (temp, w, cp[highindex]);
                lowindex := lowindex + partitionsize
               UNTIL lowindex >= complexpoints
            END;
           partitionsize := partitionsize DIV 2
          UNTIL partitionsize = 1
       END;
 
      PROCEDURE shufflecoefficients;
 
      VAR
        lowindex, highindex : dataindextype;
        bits : integer;
 
        FUNCTION log2 (index : integer) : integer;
 
          { Recursive routine, where "index" is assumed a power of 2.
           Note the routine will fail (by endless recursion) if
           "index" <= 0. }
 
         BEGIN   { log2 }
           IF index = 1
            THEN log2 := 0
            ELSE log2 := succ(log2(index DIV 2))
         END;

        FUNCTION bitreversal (index, bits : integer) : integer;
 
          { Takes an index, in the range 1 .. 2**bits, and computes a
           bit-reversed index in the same range.  It first undoes the
           offset of 1, bit-reverses the "bits"-bit binary number,
           then redoes the offset.  Thus if bits = 4, the range is
           1 .. 16, and bitreversal (1, 4) = 9,
           bitreversal (16, 4) = 16, etc. }
 
          FUNCTION reverse (bits, stib, bitsleft : integer) : integer;

            { Recursive bit-reversing function, transforms "bits" into
             bit-reversed "stib.  It's pretty easy to convert this to
             an iterative form, but I think the recursive form is
             easier to understand, and should entail a trivial penalty
             in speed (in the overall algorithm). }
 
           BEGIN   { reverse }
             IF bitsleft = 0
              THEN reverse := stib
              ELSE
              IF odd (bits)
               THEN reverse := reverse (bits DIV 2, succ (stib * 2),
                                        pred (bitsleft))
               ELSE reverse := reverse (bits DIV 2, stib * 2,
                                        pred (bitsleft))
           END;

         BEGIN   { bitreversal }
           bitreversal := succ (reverse (pred(index), 0, bits))
         END;
 
        PROCEDURE swap (VAR a, b : complex);
 
        VAR
          temp : complex;
 
         BEGIN   { swap }
           temp := a;
           a := b;
           b := temp
         END;
 
       BEGIN   { shufflecoefficients }
         bits := log2 (complexpoints);
         WITH data DO
         FOR lowindex := 1 TO complexpoints DO
          BEGIN
            highindex := bitreversal(lowindex, bits);
            IF highindex > lowindex
             THEN swap (cp[lowindex], cp[highindex])
          END
       END;
 
      PROCEDURE dividebyn;

      { This procedure is needed to get FFT to scale correctly. }
 
      VAR
        index : dataindextype;
 
       BEGIN   { dividebyn }
         WITH data DO
         FOR index := 1 TO complexpoints DO
         WITH cp[index] DO
          BEGIN
            realpart := realpart/complexpoints;
            imagpart := imagpart/complexpoints

          END
       END;
 
     BEGIN   { forwardfft }
       docomplextransform;
       shufflecoefficients;
       dividebyn
     END;
 
     { Note that the data slots and coefficient slots in the mixed
     data type share storage.  From the first complex coefficient,
     we can derive the DC and noise term; from pairs of the remaining
     coefficients, we can derive pairs of sine/cosine terms. }
 
 
   BEGIN   { fftofreal }
     forwardfft (mixed.dataslot, realpoints DIV 2);
     temp1 := mixed.dataslot.cp[1];
     WITH mixed.coefslot, temp1 DO
      BEGIN
        dcterm := (realpart + imagpart)/2;
        noiseterm := (realpart - imagpart)/2
      END;
     baseangle := -twopi/realpoints;
     FOR index := 1 TO realpoints DIV 4 DO
      BEGIN
        minusindex := (realpoints DIV 2) - index;
        WITH mixed.dataslot DO
         BEGIN
           conjugate (cp[succ(minusindex)], temp2);
           cadd (cp[succ(index)], temp2, temp1);
           csubtract (cp[succ(index)], temp2, temp2)
         END;
        w.realpart := sin(index*baseangle);
        w.imagpart := -cos(index*baseangle);
        cmultiply (w, temp2, temp2);
        cadd (temp1, temp2, temp3);
        csubtract (temp1, temp2, temp2);
        conjugate (temp2, temp2);
        WITH mixed.coefslot.freqterms[index], temp3 DO
         BEGIN
           cosineterm := realpart/2;
           sineterm := -imagpart/2
         END;
        WITH mixed.coefslot.freqterms[minusindex], temp2 DO
         BEGIN
           cosineterm := realpart/2;
           sineterm := imagpart/2
         END
      END
   END;
 
  FUNCTION omegat (f : freqindextype; t : dataindextype) : real;
 
    { computes omega*t for particular harmonic, index }

   BEGIN   { omegat }
     omegat := twopi * f * pred(t) / maxarraysize
   END;
 
  { main test routine starts here }
 
 BEGIN
   WITH mixed.dataslot DO
   FOR didx := 1 TO maxarraysize DO
   rp[didx] := (23
                + 13 * sin(omegat (7, didx))
                + 28 * cos(omegat (22, didx)));
   fftofreal (mixed, maxarraysize);
   WITH mixed.coefslot DO
   writeln ('DC = ', dcterm:10:2, ' ':5, 'Noise = ', noiseterm:10:2);
   FOR fidx := 1 TO maxfreqsize DO
    BEGIN
      WITH mixed.coefslot.freqterms[fidx] DO
      write (fidx:4, round(cosineterm):4, round(sineterm):4, ' ':4);
      IF fidx MOD 4 = 0
       THEN writeln
    END;
   writeln;
   writeln ('The expected result should have been:');
   writeln ('  DC = 23, noise = 0, ');
   writeln ('  sine 7th harmonic = 13, cosine 22nd harmonic = 28')
 END.
