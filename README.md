Author: Matthew Leming
COMP 775, Fall 2014, Steve Pizer
Generates a noisy image with random circles on
it, then runs a hough transform function that should find these circles. Most of the
interesting stuff happens in disk_discovery, but this outputs the actual
circle centers and the guessed circle centers, allowing numerical
comparison. disk_discovery outputs a number of images that allow one to
easily view the process it goes through. Comments in that function
explain it step by step.
The imDeriv functions were made by Nathan Roach.

To run everything, run "HW1_run.m" in MATLAB.
