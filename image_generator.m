function [image, coords] = image_generator(radius, possible_disk_intensities, number_of_disks, blurring_sigma, noise_intensity, width, height, intensity_polarity)
% IMAGE GENERATOR: Generates a number of blurred, random-location circles
% of fixed radius, then add noise to the picture


% If the intensity polarity is 1, black circles on a white background;
% otherwise (preferably, if the polarity is 0), it is white circles on a
% black background.
if intensity_polarity == 1
   image = ones([width height]);
   circle_color = 'black';
else
   image = zeros([width height]);
   circle_color = 'white';
end

% Add circles to the image
centers_list = zeros([2 number_of_disks]);
for i=1:number_of_disks
    random_coordinates = [rand*height rand*width];
    centers_list(:,i) = random_coordinates';
    opacity = (possible_disk_intensities(2)-possible_disk_intensities(1))*rand(1)+possible_disk_intensities(1);
    image = insertShape(image, 'FilledCircle', [random_coordinates radius], 'Opacity', opacity, 'Color', circle_color);
end
image = rgb2gray(image);

% Blur the image
G = fspecial('gaussian', [10 10], blurring_sigma);
image = imfilter(image, G, 'same');

% Add noise
noise = rand([width height]);
image = (noise*noise_intensity + image)/(noise_intensity + 1);

% Output the circle center coordinates
coords = centers_list;