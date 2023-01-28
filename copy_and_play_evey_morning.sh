#!/bin/bash


directoryOfThisScript='/home/fronttv/fronttv_script'

## stop any videos that are currently playing before syncing down changes
killall vlc



# ## check for updates to this script
# showMeWhatYouGot="$(
# 	cd "$directoryOfThisScript" &&
# 	git fetch 2> /dev/null &&
# 	git diff "$(giot symbolic-ref HEAD |
# 	cut -d'/' -f3)" FETCH_HEAD --name-only |
# 	cat
# )"
# if [ -z "$showMeWhatYouGot" ]
# then
# 	## no update found
# 	true
# else
# 	## update found
# 	if cd "$directoryOfThisScript" && git pull
# 	then
# 		bash "$directoryOfThisScript/copy_and_play_evey_morning.sh"
# 		exit 0
# 	else
# 		## pulling changes failed; continuing anyway
# 		true
# 	fi ## updating
# fi ## if no update found





## mount the drive now. Maybe it'll work,
## maybe it'll complain it's already mounted,
## maybe the authenticaton will have failed, who knows.
/home/fronttv/.opam/default/bin/google-drive-ocamlfuse /home/fronttv/googledrive


## test to see if there's any files in there
if [ -z "$(find '/home/fronttv/googledrive/Slide Shows/fronttv/' -type f)" ]
then
	## if not, then run the authentication program, which might pop up a browser screen asking for a login
	/home/fronttv/.opam/default/bin/google-drive-ocamlfuse

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
else
	## IF the mount failed, do the above stuff. ELSE, if the mount succeeded then do this rsync stuff.

	## copy all files in the Google Drive folder "Slide Shows / frontv" to this thing's local storage.
	## also delete from this thing's local storage any files that weren't in the Google Drive folder.
	rsync -a --delete-after '/home/fronttv/googledrive/Slide Shows/fronttv/.' /home/fronttv/local_copy_of_googledrive_videos/


	## since the mount-test succeeded, let's tell VLC to play in fullscreen
	maybeFullscreen='--fullscreen'
fi


## no matter if the mount succeeded or failed, play what we've already got downloaded.

## then play all things (videos, music, whatever. possibly pictures too) 
## with fullscreen, no On Screen Display, loop forever, and including subfolders.
vlc $maybeFullscreen --no-osd --loop --recursive --open /home/fronttv/local_copy_of_googledrive_videos/ 


