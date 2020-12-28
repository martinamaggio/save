#!/bin/bash

# ----------------------------------------------------------------- #
# This script executes the compression case study: it takes all the #
# mp4 videos placed in the folder "mp4" and process them. The       #
# processing is done in two steps: prepare, and encode.             #
# The prepare step creates the folder structure needed to execute   #
# the rest and unpacks the video into frames that are stored in the #
# corresponding folder. The encode step executes the encoder        #
# alongside with the control strategy that sets the actuator values #
# to obtain the goals.                                              #
#                                                                   #
# For each of the frames, the two procedures use as actuators three #
# parameters of the convert system call:                            #
#   - quality (from 1 to 100)                                       #
#   - noise (from 0 to 5)                                           #
#   - sharpen (from 0 to 5)                                         #
#                                                                   #
# There are three adaptation strategies already designed:           #
#   - random: just select random values for the actuators           #
#   - bangbang: implements a bangbang controller                    #
#   - mpc: implements a model predictive controller                 #
#                                                                   #
# The controllers tries to achieve two objectives:                  #
#   - a setpoint on the similarity with the original frame (ssim)   #
#   - a setpoint on the frame size after the conversion             #
# ----------------------------------------------------------------- #

DIR_FRAMES=frames
DIR_FRAMES_ORIG=orig
DIR_FRAMES_PROC=proc
DIR_RESULTS=results
PROGRAM=./code/encoder.py

print_usage ()
{
  echo "<usage> call this script with parameters for the action:"
  echo "  ./run.sh clean"
  echo "  ./run.sh control setpoint_quality setpoint_framesize"
  exit
}

clean ()
{
	rm -rf ${DIR_FRAMES} # remove the directory with frames
	rm -rf ${DIR_RESULTS} # remove the directory with results
}

prepare ()
{
	# creating a directory for each video and two subdirs
	# with the original and processed frames
	V=$1
	BASIC_FRAMES=${DIR_FRAMES}/${V}; mkdir -p ${BASIC_FRAMES}
	BASIC_RESULTS=${DIR_RESULTS}/${V}; mkdir -p ${BASIC_RESULTS}
	ORIG=${DIR_FRAMES}/${V}/${DIR_FRAMES_ORIG}; mkdir -p ${ORIG}
	PROC=${DIR_FRAMES}/${V}/${DIR_FRAMES_PROC}; mkdir -p ${PROC}
	
	# unpacking frames if they have not been previously unpacked
	if find "${ORIG}" -mindepth 1 -print -quit | grep -q .; then
		  echo "  [prepare] $V already unpacked"
	else
		  echo "  [prepare] $V unpacking"
		  mplayer -vo jpeg:quality=100:outdir=${ORIG} \
		  	./mp4/$V.mp4 > /dev/null 2>&1
		  echo "  [prepare] $V unpacking terminated"
	fi
}

encode ()
{
	V=$1; METHOD=$2; QUALITY=$3; FRAMESIZE=$4;
	ORIG=${DIR_FRAMES}/${V}/${DIR_FRAMES_ORIG};
	BASIC_PROC=${DIR_FRAMES}/${V}/${DIR_FRAMES_PROC};
	BASIC_RESULTS=${DIR_RESULTS}/${V};
	
	if [[ -z "${QUALITY// }" ]]; then QUALITY=0.9; fi
	if [[ -z "${FRAMESIZE// }" ]]; then FRAMESIZE=8000; fi
	
	SUFFIX="${METHOD}-Q${QUALITY}-F${FRAMESIZE}"
	PROC="${BASIC_PROC}/${SUFFIX}"
	RESULTS="${BASIC_RESULTS}/${SUFFIX}"
	mkdir -p ${RESULTS}
	mkdir -p ${PROC}
	rm -rf ${RESULTS}/*
	rm -rf ${PROC}/*
	
	echo "  [encode] encoding of $V ($QUALITY, $FRAMESIZE)"
	python $PROGRAM $METHOD \
		$ORIG $PROC $RESULTS \
		$QUALITY $FRAMESIZE
	echo "  [encode] encoding of $V terminated"
	
	echo "  [encode] creating figure"
	cp ./code/latex/figure.tex $RESULTS/.
	cd $RESULTS
	pdflatex figure.tex &>/dev/null
	pdflatex figure.tex &>/dev/null
	rm -rf figure.tex figure.aux figure.log
	cd ../../..
	echo "  [encode] creating figure terminated"
}

convert () 
{
	V=$1; FOLDER_SRC=$2; FOLDER_DST=mp4;
	python3 ./conv.py $V $FOLDER_SRC

	# copy the converted file to mp4/ iff conv.py ended with no errors
	if [[ "$?" -eq 0 ]]; then
		echo "Copying $V.mp4 to $FOLDER_DST"
		cp "$FOLDER_SRC/$V.mp4" "$FOLDER_DST"
	fi

	echo "Deleting $V.mp4 from $FOLDER_SRC"
	rm -rf "$FOLDER_SRC/$V.mp4"
}

# ----------------------------------------------------------------- #
# basic handling of cleaning and usage printing
if [[ "$#" -eq 0 ]]; then
	print_usage;
	exit;
fi
if [[ "$1" == clean ]]; then
	clean;
	exit;
fi
# simple handling of file conversion
if [[ "$1" == convert ]]; then
	TO_CONVERT=to_convert/
	VIDEOS=`ls to_convert`
	for VIDEO in $VIDEOS; do
		# gets the extension of the file (the string after the last ".")
		filetype=`ls $TO_CONVERT$VIDEO | rev | cut -d . -f 1 | rev`	# maybe a convoluted solution, but it works for now
		if [[ "$filetype" != "mp4" ]]; then
			convert $VIDEO $TO_CONVERT;
		else
			echo "File $VIDEO already exists in desired format"
			echo "Copying $VIDEO to mp4/"
			cp "$TO_CONVERT$VIDEO" mp4
		fi
	done
	exit;
fi

# normal usage mode
VIDEOS=`ls mp4`
mkdir -p ${DIR_FRAMES}
mkdir -p ${DIR_RESULTS}

METHOD=$1
QUALITY=$2
FRAMESIZE=$3

for VIDEO in $VIDEOS; do
	V=`sed 's/.mp4//g' <<< $VIDEO`
	echo "Processing $VIDEO"
	prepare $V
	encode $V $METHOD $QUALITY $FRAMESIZE
done

# cleanup
rm -f ./code/*/*.pyc