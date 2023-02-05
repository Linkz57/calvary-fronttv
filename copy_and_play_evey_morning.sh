#!/bin/bash


## should this script be automatically updated every time it runs?
## note: this doesn't stop you from manually typing
  ## cd fronttv_script ; git pull
## but without the two leading ## symbols
autoUpdate=false
## set the above variable to either true or false



directoryOfThisScript='/home/fronttv/fronttv_script'



## stop any videos that are currently playing before syncing down changes
killall vlc



if $autoUpdate
then
	echo "checking for updates"
	## check for updates to this script
	showMeWhatYouGot="$(
		cd "$directoryOfThisScript" &&
		git fetch 2> /dev/null &&
		git diff "$(git symbolic-ref HEAD |
		cut -d'/' -f3)" FETCH_HEAD --name-only |
		cat
	)"
	if [ -z "$showMeWhatYouGot" ]
	then
		## no update found
		echo "no updates found; continuing"
	else
		## update found
		if cd "$directoryOfThisScript" && git pull
		then
			echo "found an update; I'm gonna run this whole script again."
			bash "$directoryOfThisScript/copy_and_play_evey_morning.sh"
			exit 0
		else
			echo "pulling changes failed; continuing anyway..."
		fi ## updating
	fi ## if no update found
fi ## is auto update enabled







## test to see if there's any files in there
if rclone ls dropbox:/front_tv
then
	## if files were found where I expect, then copy them down.

	## copy all files in the dropbox folder "front_tv" to this thing's local storage.
	## also delete from this thing's local storage any files that weren't in the Dropbox folder.
	rclone sync --delete-after dropbox:/front_tv/ /home/fronttv/local_copy_of_cloud_videos/

	## since the above rclone test succeeded, let's tell VLC to play in fullscreen
	maybeFullscreen='--fullscreen'
else
	## IF I found files in the cloud where I expected, do the above stuff.
	## ELSE, if files have been NOT been found, copy them down and play them.

	( 

		## Show a graphical error box.
		## Generally, `\n` means "Newline", like hitting the enter key in a text editor, it puts the following text on a new line.
		zenity --display ':0' --title "error: no webbernets" --error --text "Nope.\nCan't find any files in the folder I expect. Read this text file to learn more:\n\n$0" --width=500 &


		sleep 1m
		xdotool search --name "error: no webbernets" windowmove 0 0

		xdotool search --name "error: no webbernets" windowraise
	) &


	## however, zenity won't show over-top VLC when it's playing in fullscreen (without doing extra work, that is)
	## so let's tell VLC to not run in fullscreen since above mount-test failed.
	maybeFullscreen='--no-fullscreen'

	## a failed mount can cause its own problems, so just in case let's unmount the google drive twice.
	## It's totally possible that zero unmounts would also be fine.
	sudo umount /home/fronttv/googledrive >/dev/null 2>&1
	## >/dev/null means "redirect all regular output (AKA: stdout) to
	## the 'null device' which is a black hole of nothingness forever;
	## an infinite trash can of instant deletion.
	sudo umount /home/fronttv/googledrive >/dev/null 2>&1 ## 2>&1 means "redirect all error messages (AKA: stderr) to the regular output (stdout) which in this case ALSO sends it to null

	## Now that we're done failing, it's time to exit the script.
	## Traditionally: any "exit code" other than zero means "error".
	## One is a different number than zero, so here you go.
	## As implimented, this exit code does nothing, but it makes future integration slightly easier.
	#exit 1
fi


## no matter if the mount succeeded or failed, play what we've already got downloaded.

## then play all things (videos, music, whatever. possibly pictures too) 
## with fullscreen, no On Screen Display, loop forever, and including subfolders.
vlc $maybeFullscreen --no-osd --loop --recursive --open /home/fronttv/local_copy_of_cloud_videos/


