# Instructions for how to run the experiment code

## PREREQUISITES:

- In a normal ubuntu distribution (LTS), you need to install the
   packages:
     python-imaging, python-numpy, python-scipy, python-matplotlib,
     python-cvxopt, mplayer, texlive-base, texlive-latex-extra,
     texlive-pictures
      
## STEP-BY-STEP PREREQUISITES INSTALLATION:

    sudo apt-get install mplayer
    sudo apt-get install imagemagick
    sudo apt-get install python-imaging python-numpy python-scipy
    sudo apt-get install python-matplotlib python-cvxopt
    sudo apt-get install texlive-base texlive-pictures
    sudo apt-get install texlive-latex-extra
   
## INSTRUCTIONS:

1. Copy any mp4 video in the folder mp4
   for example download a video from youtube using services like
   http://en.savefrom.net/1-how-to-download-youtube-video/
   video used for the experiments available here
   https://www.youtube.com/watch?v=nv9NwKAjmt0
   
2. Execute the tests running
     "./run.sh controller setpoint_ssim setpoint_size"

   example: "./run.sh mpc 0.9 50000" where 0.9 is the setpoint for the
   quality (ssim) and 50000 is the setpoint for the frame size

   example: "./run.sh random 0.4 10000" where 0.4 is the ssim setpoint
   and 10000 is the size setpoint
   
3. The tests results will be available in the directory results under
   a folder with the video name and a subfolder with the method name
   and the two given setpoints. Both the csv and a pdf figure
   representing the data will be available. The figure may not be
   adjusted to zoom (because it is constructed to be general). The
   tikz code that generated the figure can be modified to zoom in
   certain areas (found in the file code/latex/figure.tex).

4. To be able to use the video converter, please refer to the scripts/ folder first to install dependencies
   
