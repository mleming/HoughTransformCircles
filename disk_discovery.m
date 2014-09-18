function [imageout, circle_coords] = disk_discovery(image, radius, intensity_polarity, gradient_magnitude_threshold, parzen_standard_deviation, sigmoid_mean, sigmoid_standard)%, intensity_gradient_scale)
% Author: Matthew Leming
% This function finds the center of circles in a grayscale image, given the
% estimated radius of those circles. Uses the hough transform.
% It takes in the following parameters:
% -image: a grayscale image, hopefully with circles on it
% -radius: the radius of the circles in the image.
% -intensity_polarity: if the circles are lighter than the background, this
%       ought to be 0. If the circles are darker than the background, it
%       ought to be 1.
% -gradient_magnitude_threshold: Determines the minimum relative gradient
%       magnitude for which a vote is cast on the accumulator space in the
%       hough transform. Ideally should be sigmoid_mean -
%       3*sigmoid_standard
% -parzen_standard_deviation: how much the image should be blurred to
%       remove noise. Ideally ought to be something like 15.
% -sigmoid_mean: a parameter to the sigmoid function that translates gradients
%       into votes. One value that was found to work well was 0.4.
% -sigmoid_standard: the second parameter to the sigmoid function. 0.1 is a
%       good parameter value.
%
% The intensity gradient scale was omitted in favor of adjusting the
% gradients based on a maximum gradient value in the image


% STEP 1: Set up the proper variables
dims = size(image);
accumulator = zeros([dims(1) dims(2)]);
%imwrite(image, '1_original_image.png');


% STEP 2: Blur the original image
G = fspecial('gaussian',[15 15],parzen_standard_deviation);
image_blur = imfilter(image,G,'same');

imwrite(image_blur,'2_blurred_image.png');


% STEP 3: Take the derivative of the blurred image and calculate the
% gradient direction and magnitude from the x and y derivatives.
image_derivatives = imDeriv(image_blur, 1);

image_derivative_x = cell2mat(image_derivatives(1));
image_derivative_y = cell2mat(image_derivatives(2));

Gmag = (image_derivative_x.^2 + image_derivative_y.^2).^(.5);
Gdir = atan2d(image_derivative_y, image_derivative_x);

imwrite(Gmag, '3_gradient_intensity.png'); %Note: poor representation, numbers above 1 are set to 1. See step 4.

% STEP 4: Scale gradient intensities Find the maximum value of the array,
% then scale all other gradient values by that, so that the maximum value
% is 1.
% IMPORTANT NOTE: In my version of MATLAB, I did not use the built-in
% max() function because that appears to have some errors. So, I am just
% doing it like this.
% Also note that this removes the need for a gradient scale intensity input

max_gradient = 0;
for i=1:size(Gmag(:))
	if Gmag(i) > max_gradient
		max_gradient = Gmag(i);
	end
end
for i=1:size(Gmag(:))
	Gmag(i) = Gmag(i)/max_gradient;
end
imwrite(Gmag, '4_gradient_intensity_scaled.png');


% STEP 5: Cast votes to accumulator
% Casts votes to the accumulator. This employs MATLAB's sigmf (sigmoid
% function) to translate the gradient magnitude into a proper vote. The
% gradient magnitude threshold is ideally set to sigmoid_mean -
% 3*sigmoid_standard outside of this function. The voter function
% translates an x, y, theta, and radius into a location to be voted on,
% and, if that vote fits inside of the image and the corresponding gradient
% magnitude is high enough, it is cast.
for x=1:dims(1)
	for y=1:dims(2)
		theta = Gdir(x,y) + 180*intensity_polarity; % The theta direction is reversed, depending on the polarity of the image
		Vy = round(radius*sind(theta) + y);
		Vx = round(radius*cosd(theta) + x);
		if Vx > 0 && Vx < dims(1) && Vy > 0 && Vy < dims(2) && Gmag(x,y) > gradient_magnitude_threshold
			accumulator(Vx, Vy) = accumulator(Vx, Vy) + sigmf(Gmag(x,y), [sigmoid_standard sigmoid_mean]);
		end
	end
end
imwrite(accumulator, '5_initial_accumulator.png');

% STEP 6: Blur the accumulator and take its maximum value
accumulator_blur = imfilter(accumulator,G,'same');
max_blur = -1;
for i=1:size(accumulator_blur(:))
	if accumulator_blur(i) > max_blur
        	max_blur = accumulator_blur(i);
	end
end
imwrite(accumulator_blur, '6_blurred_accumulator.png');


% STEP 7: Cancel out any votes from the accumulator if the corresponding
% space in the blurred accumulator is below a certain fraction of the
% maximum value
% NOTE: The threshold was selected based on what appeared to work most
% successfully in test cases. It can certainly be tested more in the
% future.
vote_threshold = max_blur/10;
for i=1:size(accumulator_blur(:))
	if accumulator_blur(i) < vote_threshold
		accumulator(i) = 0;
	end
end
imwrite(accumulator, '7_corrected_accumulator.png');


% STEP 8: Take any areas on the accumulator that are at 0 and set them as
% coordinates for a k-means clustering procedure. Then, from each of these
% points, take the point with the highest overall votes from each cluster
% and set that up as a "center". Repeat a few times until you have a beefy
% list of approximate cluster centers. Of course, this produces many
% "centers", but these are merged in the next step.

k_means_indice = [];
for x=1:dims(1)
	for y=1:dims(2)
		if accumulator(x,y) > 0
			k_means_indice = [k_means_indice [x y]'];
		end
	end
end

k_overestimated_value = 15;
k_repetitions = 3;
center_list = [];

for e=0:k_repetitions
	indices = kmeans(k_means_indice', k_overestimated_value, 'emptyaction', 'drop');
	for k=1:k_overestimated_value
		xmax = -1;
		xmaxindice = -1;
		for i=1:size(indices)
			if indices(i) == k && accumulator(k_means_indice(1,i), k_means_indice(2,i)) > xmax
				xmax = accumulator(k_means_indice(1,i), k_means_indice(2,i));
				xmaxindice = [k_means_indice(2,i) k_means_indice(1,i)];
			end
		end
		if xmaxindice ~= -1
			center_list = [center_list xmaxindice'];
		end
	end
end
% This is purely to display all of the points we're currently working with
point_display = accumulator(:,:);
for i=1:size(center_list,2)
	point_display = insertShape(point_display, 'FilledCircle', [center_list(:,i)' 2], 'Opacity', 1, 'Color', 'green');
end
imwrite(point_display,'8_k_estimates_display.png');



% STEP 9: Merge centers. As you can see from the output of the previous
% image, this produces a number of dots on the image. However, these dots
% are predictably close to one another. This simply averages the dots that
% are under a certain distance threshold (15 pixels is what I decided on).

merged_center_list = [];
pixel_distance_threshold = 15;

for i=1:size(center_list,2)
	is_in_list = 0;
	for j=1:size(merged_center_list,2)
		p1 = merged_center_list(:,j);
		p2 = center_list(:,i);
		if pdist([p1(1) p1(2) ; p2(1) p2(2)], 'euclidean') < pixel_distance_threshold
			merged_center_list(:,j) = [((p1(1) + p2(1))/2) ((p1(2) + p2(2))/2)]';
			is_in_list = 1;
		end
	end
	if is_in_list == 0
		merged_center_list = [merged_center_list center_list(:,i)];
	end
end

% Display the centers on both the accumulator and the initial image
accumulator_center_display = accumulator(:,:);
for i=1:size(merged_center_list,2)
	accumulator_center_display = insertShape(accumulator_center_display, 'FilledCircle', [merged_center_list(:,i)' 4], 'Opacity', 1, 'Color', 'green');
end
imwrite(accumulator_center_display,'9A_accumulator_center_display.png');


image_center_display = image(:,:);
for i=1:size(merged_center_list,2)
	image_center_display = insertShape(image_center_display, 'FilledCircle', [merged_center_list(:,i)' 4], 'Opacity', 1, 'Color', 'green');
end
imwrite(image_center_display,'9B_final_center_display.png');


% Outputs
imageout = accumulator;
circle_coords = merged_center_list;
end
