# SuperDir
A very old File Manager for the CP/M OS, written in Turbo Pascal

This file manager has a total of 10 functions: 
* select drive
* show file
* print file
* rename file
* delete file
* undelete file
* copy file
* mark file read-only/read-write
* delete selected files 
* copy selected files.

Note that reading the directory was done by actually reading the 128-byte disk sectors at the beginning of the disk and figuring out the 32-byte data structure describing each file. Names and extensions were fixed at 8.3 characters at the time.

Also, there were no graphics in this system, so this was all done with standard ASCII characters on a 24x80 screen. 

I'm not particularly proud of the pre-allocated arrays for storing the data. My sort function was also pretty lame. But hey, I wrote this in the 1980 when I was only starting to learn programming...
