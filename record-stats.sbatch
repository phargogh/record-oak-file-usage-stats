#!/bin/bash
#SBATCH --job-name=oak-stat-cron
#SBATCH --begin=now+1days
#SBATCH --dependency=singleton
#SBATCH --time=00:20:00
#SBATCH --mail-type=FAIL

set -ex

module load system rclone

# This assumes that we are running GNU stat, not BSD stat.
TARGET_FILE="$SCRATCH/$(date +"%F_%R").txt"

# https://unix.stackexchange.com/a/628259/14137
# --terse is the equivalent of
# %n %s %b %f %u %g %D %i %h %t %T %X %Y %Z %W %o
# %n file name
# %s total size, in bytes
# %b number of blocks allocated
# %f raw mode in hex
# %u user ID of owner
# %g group ID of owner
# %D device number in hex
# %i inode number
# %h number of hard links
# %t major device type in hex, for character/block device special files
# %T minor device type in hex, for character/block device special files
# %X time of last access, seconds since Epoch
# %Y time of last modification, seconds since Epoch
# %Z time of last change, seconds since Epoch
# %W time of file birth, seconds since Epoch; 0 if unknown
# %o optimal I/O transfer size hint
find "$OAK" -print0 | xargs -0 stat --terse > "$TARGET_FILE"

RCLONE_REMOTE="oak-stat-files-gdrive"
rclone copy "$TARGET_FILE" "$RCLONE_REMOTE:/"

rm "$TARGET_FILE"

sbatch "$0"
