# MATLAB scripts and functions for Earth Sciences applications
Author: **Gonzalo Ferrada** (*gonzalo.ferrada@noaa.gov*)

Codes developed since 2017. First shared in Github: June 2025.

## Installation
In your machine, go to the directory/folder where you want to store the scripts and data and do:

`git clone https://github.com/GonzaloFerrada-NOAA/matlab-earth-sciences.git`

This will download all these scripts in a newly created `matlab-earth-sciences` folder.

In your `.bashrc` or `.bash_profile` (located in your `$HOME`), you need to add the following environment variable:

`export MATLABPATH=$( find /path/to/dir/matlab-earth-sciences -type d | awk '{ printf ":%s", $1; }' )`

Resource the profile:

`source ~/.bashrc`

You can now start a fresh MATLAB session and you can use these functions and scripts.

## Test installation

To check whether MATLAB is *aware* of the scripts, you can do:

`help spatial`

It should prompt the documentation of the `spatial` plot function.

## Troubleshot

If the test does not work, i.e., the prompt is an error saying that the function or variable do not exist, then you can add the following in your init.m script placed in your MATLAB directory (commonly .../Documents/MATLAB):

`addpath('/path/to/dir/matlab-earth-sciences/FUNCTIONS')`

`addpath('/path/to/dir/matlab-earth-sciences/LARGE')`

In this way, MATLAB will always add those paths at initialization to search for scripts, functions or data.

Alternatively, you can add the above lines to your current script.


