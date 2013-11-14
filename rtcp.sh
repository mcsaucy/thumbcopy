#!/bin/sh
###############################################################################
#
#   UBRESTHUMB CREATION SCRIPT
#   Author:  Josh McSavaney (mcsaucy@csh.rit.edu)
#   If the drive is UBRESTHUMB capable (is large enough) it becomes one.
#   If it isn't large enough, it is just turned into a normal RESTHUMB.
#
###############################################################################

read -d '' BANNER << 'EOF'
[0;37m################################################################################[0m
[0;37m###[0m[48;5;202m              [0m[0;37m#################[0m[48;5;202m          [0m[0;37m############[0m[48;5;202m                    [0m[0;37m####[0m
[0;37m#####[0m[48;5;202m    [0m[0;37m######[0m[48;5;202m    [0m[0;37m##################[0m[48;5;202m    [0m[0;37m###############[0m[48;5;202m [0m[0;37m#######[0m[48;5;202m    [0m[0;37m#######[0m[48;5;202m [0m[0;37m####[0m
[0;37m######[0m[48;5;202m   [0m[0;37m#######[0m[48;5;202m    [0m[0;37m#################[0m[48;5;202m    [0m[0;37m#######################[0m[48;5;202m    [0m[0;37m############[0m
[0;37m######[0m[48;5;202m   [0m[0;37m#######[0m[48;5;202m   [0m[0;37m##################[0m[48;5;202m    [0m[0;37m#######################[0m[48;5;202m    [0m[0;37m############[0m
[0;37m######[0m[48;5;202m   [0m[0;37m#####[0m[48;5;202m   [0m[0;37m##########[0m[48;5;202m  [0m[0;37m########[0m[48;5;202m    [0m[0;37m#########[0m[48;5;202m  [0m[0;37m############[0m[48;5;202m    [0m[0;37m############[0m
[0;37m######[0m[48;5;202m         [0m[0;37m############[0m[48;5;202m  [0m[0;37m########[0m[48;5;202m    [0m[0;37m#########[0m[48;5;202m  [0m[0;37m############[0m[48;5;202m    [0m[0;37m############[0m
[0;37m######[0m[48;5;202m   [0m[0;37m####[0m[48;5;202m   [0m[0;37m#####################[0m[48;5;202m    [0m[0;37m#######################[0m[48;5;202m    [0m[0;37m############[0m
[0;37m######[0m[48;5;202m   [0m[0;37m#####[0m[48;5;202m   [0m[0;37m####################[0m[48;5;202m    [0m[0;37m#######################[0m[48;5;202m    [0m[0;37m############[0m
[0;37m######[0m[48;5;202m   [0m[0;37m######[0m[48;5;202m   [0m[0;37m###################[0m[48;5;202m    [0m[0;37m#######################[0m[48;5;202m    [0m[0;37m############[0m
[0;37m#####[0m[48;5;202m     [0m[0;37m#####[0m[48;5;202m     [0m[0;37m##############[0m[48;5;202m          [0m[0;37m###################[0m[48;5;202m      [0m[0;37m###########[0m
[0;37m################################################################################[0m
[0;37m###############################[0m[48;5;27m   [0m[0;37m####[0m[48;5;27m [0m[0;37m#########################################[0m
[0;37m#####################################[0m[48;5;27m  [0m[0;37m#########################################[0m
[0;37m###############################[0m[48;5;27m   [0m[0;37m#[0m[48;5;27m      [0m[0;37m##[0m[48;5;27m      [0m[0;37m###############################[0m
[0;37m###############################[0m[48;5;27m   [0m[0;37m###[0m[48;5;27m  [0m[0;37m####[0m[48;5;27m  [0m[0;37m###################################[0m
[0;37m###############################[0m[48;5;27m   [0m[0;37m###[0m[48;5;27m  [0m[0;37m#####[0m[48;5;27m   [0m[0;37m#################################[0m
[0;37m###############################[0m[48;5;27m   [0m[0;37m###[0m[48;5;27m  [0m[0;37m########[0m[48;5;27m  [0m[0;37m###############################[0m
[0;37m################################[0m[48;5;27m  [0m[0;37m###[0m[48;5;27m    [0m[0;37m##[0m[48;5;27m     [0m[0;37m################################[0m
[0;37m################################################################################[0m
EOF

echo "$BANNER\n"

FORCEUMOUNT="" #unset this if you don't want to forcefully unmount drives

DISKNAME="RESTHUMB"
TARTGTS="Ass* Removers* Drive* Gen* Anti* Mac* RIT* ResTool*"

THUMBIMG_RE='//\(.*@\)\?resthumb\(.resnet\)\?/thumbimage'
THUMBIMG='//resthumb@resthumb.resnet/thumbimage'
#Should the path of thumbimage ever change, update the above regex and path

TARLOC="${HOME}/resthumb.tar"
TARTMP="/tmp/resthumb.tar"

DMGLOC="/var/tmp/UBRESTHUMB.dmg"

THUMBDIR=`mount | grep -i "$THUMBIMG_RE" | cut -d\  -f3`
if [ -z "$THUMBDIR" ]; then
    THUMBDIR=/tmp/thumbimage   #   CHANGE ME TO FIT YOUR NEEDS!    #
    THMBMNTD=""
else
    THMBMNTD="MOUNTED"
fi

function wipe()
{
    diskutil eraseDisk MS-DOS "$DISKNAME" MBRFormat "$1" >/dev/null
}

function createThumb()
{
    diskutil mount "/dev/${1}s1" >/dev/null
    RC=$?
    MNTPT=`getMntpt ${1}s1`
    RC=$(( $RC | $? ))
    stat "$MNTPT" >/dev/null
    RC=$(( $RC | $? ))
    if [ $RC -ne 0 ]; then
        echo "Failed to either mount ${1}s1 or locate its mount point." >&2
        echo "Please make sure it is formatted and clean first." >&2
        false
    else
        cat "$TARLOC" | tar -xC "`getMntpt ${1}s1`"
        #TODO: see if we can have this use a status bar
    fi
}

function getMntpt()
{
    mount | sed -En "s/^.*$1 on ([\/a-zA-Z0-9]*( [0-9]*)?) \(.*$/\1/p"
}

function makePlain()
{
    MODEL=`diskutil info $1 | grep --color=never "Media Name" | \
        cut -d: -f2 | sed -En "s/[ \t]*([a-zA-Z0-9].*)/\1/p"`
    wipe $1
    createThumb $1
    if [ $? -ne 0 ]; then
        echo "Failed to image drive $1. It's probably worth retrying." >&2
        echo "The drive that failed was a $MODEL drive." >&2
        echo >&2
        RC=1
    else
        echo
        diskutil eject "$1"
        echo "$1 ($MODEL) has been successfully imaged.\a"
    fi
}

function makeUltra()
{
    MODEL=`diskutil info $1 | grep --color=never "Media Name" | \
        cut -d: -f2 | sed -En "s/[ \t]*([a-zA-Z0-9].*)/\1/p"`
    asr restore --source "$DMGLOC" --target "/dev/$1" --erase --noprompt
    if [ $? -ne 0 ]; then
        echo "Failed to apply "$DMGLOC" image to $1. Falling back to plain." >&2
        makePlain $1
    else
        createThumb $1
        if [ $? -ne 0 ]; then
            echo "Failed to image drive $1. It's probably worth retrying." >&2
            echo "The drive that failed was a $MODEL drive." >&2
            echo >&2
            RC=1
        else
            echo
            diskutil eject "$1"
            echo "$1 ($MODEL) has been imaged with UBCD support and ejected.\a"
        fi
    fi
}

if [ `id -u` != "0" ]; then
    echo "!!! This script is NOT being run as ROOT. Any drives made    !!!" >&2
    echo "!!! without root access will not have UBCD functionality.    !!!" >&2
    echo "\nAttempt to elevate? [y/N]  \c"
    read ELEVATE
    echo "yeah\nyup\nyep\ny\nyes\nsure\nok\ngo for it\naffirmative" | \
        grep -i "^$ELEVATE$" >/dev/null 2>/dev/null
    if [ $? -eq 0 ]; then
        exec sudo "$0" "$*"
    fi

    NONROOT="YUP"
fi

OUTPUT="$(diskutil list | \
    sed -En 's/\*([0-9.]*) G[Bi][ \t]*(disk[[:digit:]]+)$/#\1:\2/p' | \
    cut -d# -f2)"

for DISK in $OUTPUT; do
    SIZE=`echo $DISK | cut -d: -f1`
    NAME=`echo $DISK | cut -d: -f2`
    diskutil list $NAME | grep -i "$DISKNAME" >/dev/null 2>/dev/null
    if [[ $? == 0  ]]; then
        DISKS="${DISKS} $DISK"
        if [[ $SIZE > 1.9 ]]; then
            ULTRA="${ULTRA} $NAME"
        else
            PLAIN="${PLAIN} $NAME"
        fi
        diskutil unmountDisk $FORCEUMOUNT "$NAME"
        diskutil eject "DONOTUSE" >/dev/null 2>/dev/null
        diskutil eject "DO NOT USE" >/dev/null 2>/dev/null
        #The above line gets rid of annoying DO NOT USE partitions
    fi
done

if [ -n "$NONROOT" ]; then
    PLAIN="$PLAIN $ULTRA"
    ULTRA=""
fi

if [ -z "$DISKS" ]; then
    echo "No usable drives are present. Make sure the target drives all have"
    echo "$DISKNAME present in their volumes names. If you just want to do a"
    echo "dry run, press [RETURN]. This will also prepare files for future"
    echo "runs so it's not entirely pointless. If you want to cancel, just"
    echo "press Ctrl-C now and we'll pretend nothing happened. [CONTINUE?]"
    read
    BUILDTAR="a dry run has been initiated. Updating all files."
    GRABDMG="a dry run has been initiated. Updating all files."
fi

echo
echo "Finished enumerating devices. The device locations are below."
echo "Additionally, all $DISKNAME devices should have been unmounted."
echo 'Run `diskutil info $DISK` for detailed device information.'
echo '#########################################################################'
echo
echo DISKS -- $DISKS
echo ULTRA -- $ULTRA
echo PLAIN -- $PLAIN
echo

MTIME=`stat -f %m "$TARLOC" 2>/dev/null`
RC=$?

trap "{ killall tar 2>/dev/null >/dev/null; exit 255; }" SIGINT SIGTERM

if [ $RC -ne 0 ]; then
    BUILDTAR='one does not currently exist.'
else
    TIMEDIFF=$(( `date +%s` - $MTIME ))
    if [ $TIMEDIFF -lt 0 ]; then
        echo "You must be a wizard or know how to use touch or something..." >&2
        echo "FORCING REBUILD" >&2
        BUILDTAR='you are a sorcerer who must be purified with flame.'
    elif [ $TIMEDIFF -gt 21600 ]; then
        echo "Existing $TARLOC is older than 6 hours. Rebuilding."
        BUILDTAR='the existing archive has expired.'
    fi
fi

if [ -n "$BUILDTAR" -o -n "$GRABDMG" -o -z "$NONROOT" -a ! -e "$DMGLOC" ]; then
    mkdir $THUMBDIR >/dev/null 2>/dev/null
    stat $THUMBDIR >/dev/null 2>/dev/null
    RC=$?
    if [ $RC -ne 0 ]; then
        echo "Could not create the '$THUMBDIR' directory or it cannot" >&2
        echo "be accessed as is. Ensure that THUMBDIR is set properly" >&2
        echo "near the top of this file and that you have the required" >&2
        echo "privileges to create it." >&2
        exit $RC
    fi

    if [ -z "$THMBMNTD" ]; then
        echo "Preparing to mount thumbimage. Please enter the password"
        echo "for the thumbimage account when prompted."
        echo
        mount_smbfs "$THUMBIMG" "$THUMBDIR"
        RC=$?
        if [ $RC -ne 0 ]; then
            echo "Failed to mount thumbimage. Based upon previous checks," >&2
            echo "thumbimage is not already mounted. Make sure you didn't" >&2
            echo "fat-finger the password, that thumbimage isn't already" >&2
            echo "mounted, and that you can, in fact, access the server." >&2
            echo "If it's still not working...Well, you seem like a smart" >&2
            echo "enough kid. You figure it out..."
            exit $RC
        fi
    fi

    if [ -n "$BUILDTAR" ]; then
         echo "Building a $TARLOC because $BUILDTAR"
        echo "Note: this may take a while..."
        cd "$THUMBDIR"
        tar -cvf "$TARTMP" $TARTGTS
        mv "$TARTMP" "$TARLOC"
        #This extra step prevents an interrupted run from corrupting our tar.
        #This matters because we never check the integrity of the archive in
        #the interest of saving time and move operations are super optimized
        #since any sane implementation simply changes around inode information
        #instead of actually moving data blocks. Additionally, it doesn't look
        #like /tmp is a RAM disk for OS X (at least in 10.8). This isn't as 
        #viable for Linux (if this ever gets ported) and compression would be 
        #something worth looking into.
        RC=$?
        if [ $RC -ne 0 ]; then
            echo "Failed to create $TARLOC properly." >&2
            echo "Double check drive when complete." >&2
     else
            echo "Finished building $TARLOC"
        fi
    fi
    if [ -n "$GRABDMG" -o -z "$NONROOT" -a ! -e "$DMGLOC" ]; then
    echo "Copying over the UBCD image to ${DMGLOC}. This may take some time."
    cp "${THUMBDIR}/UBCD/UBRESTHUMB.dmg" "$DMGLOC"
    if [ $? -ne 0 ]; then
        echo "Failed to copy over ${DMGLOC}. Skipping all UBCD-capable drives." >&2
        NONROOT="Failed to copy"
    fi
    chmod a+rw "$DMGLOC"
    #everyone needs rw access for the imagescan to properly work
    asr imagescan --source "$DMGLOC"
    #now change it back
    chmod =rw "$DMGLOC"
fi

else
    echo "Using existing ${TARLOC}. Run with the BUILDTAR=force option if you"
    echo "want to force a rebuild of ${TARLOC}."
fi

echo "Preparing to image drives. If all goes as planned, the drivers will be"
echo "imaged asynchronously through separate processes. You will be notified"
echo "when a drive finishes or fails. Whichever comes first."
echo

for DISK in $PLAIN; do
    makePlain $DISK &
done

for DISK in $ULTRA; do
    makeUltra $DISK &
done
wait

echo
echo "Script is DONE! Thanks for playing. For the sake of mass, repeated"
echo "deployments, the thumbimage share is still mounted. The script does"
echo "check to see if the share is already mounted, so it shouldn't cause"
echo "any problems."


