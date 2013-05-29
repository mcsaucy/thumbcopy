Thumbcopy is a Mac shell script for deploying flash drives. The script pulls 
a series of files from a Samba share, tars them up, and unpacks them upon the
target flash drives. If the drives are large enough, their functionality is 
improved by the addition of UBCD.

REQUIREMENTS: all of your drives must have the same name or very similar names.
For example, RESTHUMB and UBRESTHUMB. Be VERY careful about what valuable disks
are labelled as. If you have a secondary partition named RESTHUMB on your hard
drive, it will be nuked. Secondly, your drives must be large enough for the 
fully unpacked tar file else the unpacking operation will fail.

The script will notify you when the operation is complete for each drive. The
script will attempt to elevate its privileges to root should the script not be
run with root access. Feature requests are welcome as are pull requests. 

Good luck.

--Josh McSavaney
