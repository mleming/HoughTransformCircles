function o = gaussian_derivative_computation(sigma, imagefile)

image = imread(imagefile);

dimensions = size(image);
height = dimensions(1);
width = dimensions(2);

FFT = fftn(image);



%image = arrayfun(@(x) exp(x.f1), image);
%imshow(image);


%IMAGE = ffts(image);
%IMAGE2 = log(abs(IMAGE));
%imshow(IMAGE2)