
-------------------------------------------------------------------------------
Message From 
-------------------------------------------------------------------------------
Group #2 - Fidonet
Conference #9 - Pascal
Message Date: 08-08-97 14:58:08

To:      Joe Percy
From:    Leonard Erickson
Subject: Re: Unix time Conversions
-------------------------------------------------------------------------------

-=> Quoting Joe Percy to All <=-

 JP> I would like to know if someone could show me how to read a unix Time
 JP> stamp from within a file and convert it to the actual date and time
 JP> that it stands for? Say like, convert 89012831 into the actual date and
 JP> time. 

Unix timestamps are the number of *seconds* since midnight Jan 1, 1970.

     days := timestamp div 86400;
timestamp := timestamp mod 86400;
    hours := timestamp div 3600;
timestamp := timestamp mod 3600;
  minutes := timestamp div 60;
  seconds := timestamp mod 60;

Day 0 is Jan 1, 1970. Day 1 is Jan 2, 1970, etc.

Converting the day count to a date is left as an excercise for the student.

Also, be aware that since you'll have to be reading the timestamp into
a longint, the value goes *negative* in 2038 (actually it just rolls
over into the highest bit, but TP longints use that for storing the sign.

--- Blue Wave/DOS v2.30
 * Origin: Shadowshack (1:105/51)
