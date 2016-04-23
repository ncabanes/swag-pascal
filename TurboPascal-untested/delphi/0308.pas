
Using Windows's LockFileEx and UnlockFileEx functions with the
LOCKFILE_EXCLUSIVE_LOCK flag enabled you can lock exclusively a byte range
within your file.  But in your case, it's easier and more efficient create
the file using Windows's OpenFile this way:

  hFile := OpenFile(FileName, ofStruct, OF_CREATE or OF_READWRITE or
OF_SHARE_EXCLUSIVE);

You'll find more in WIN32.HLP.  Good luck!

Daniel Maltarolli.
