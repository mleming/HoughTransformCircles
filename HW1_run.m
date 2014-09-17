% Author: Matthew Leming
% COMP 775, Fall 2014, Steve Pizer
% This runs a function which generates a noisy image with random circles on
% it, then runs a function that should find these circles. Most of the
% interesting stuff happens in disk_discovery, but this outputs the actual
% circle centers and the guessed circle centers, allowing numerical
% comparison. disk_discovery outputs a number of images that allow one to
% easily view the process it goes through. Comments in that function
% explain it step by step.
% The imDeriv functions were made by Nathan Roach.

radius = 50;
intensity_polarity = 0; % 0 for white circles, 1 for black circles
sigmoid_mean = 0.4;
sigmoid_standard = 0.1;
parzen_standard_deviation = 15; %Blurring radius
gradient_magnitude_threshold = sigmoid_mean - 3*sigmoid_standard;


[image, actual_coords] = image_generator(radius, [0.3 1], 10, 1, 0.5, 500, 500, intensity_polarity);
   
if size(image, 3) == 3
    image = rgb2gray(image);
end
   
[image_votes, estimated_coords] = disk_discovery(image, radius, intensity_polarity, gradient_magnitude_threshold, parzen_standard_deviation, sigmoid_mean, sigmoid_standard);

actual_coords
estimated_coords