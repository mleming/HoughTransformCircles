function [ derivImgs ] = imDeriv( image, sigma, repetitions)
%DERIVIMGS = IMDERIV (IMAGE, SIGMA, REPETITIONS (optional) )
%   INPUTS:
%       IMAGE - N dimensional image with values at every location;
%       SIGMA - Scale of Guassian Kernal to use in derivative;
%       REPETITIONS - (optional) N if Nth derivative is desired;
%   OUTPUTS:
%       DERIVIMGS - n x 1 cell array if Image is a n dimensional image. Nth
%       cell contains the image derivative with respect to the Nth dimension.
%
%   Implementation of derivative determination using fourier transform
%   space for COMP 775 at the University of North Carolina at Chapel Hill -
%   Medical Image Analysis taught by Stephen Pfizer Fall 2014
%
%   Code Written by Nathan Roach
%   nproach@live.unc.edu
%   Theoretical basis provided by Stephen Pizer PhD.
%   pizer@cs.unc.edu

    if nargin ~= 3
        %Take first derivatives, else take number specified.
        repetitions = 1;
    end
    
    %determine the dimensionality of the input image
    numDims = ndims(image);
    
    if numDims > 4
        throw('Higher dimensions not yet supported');
    end
    
    dimensions = size(image)';
    
    %allocate output memory
    derivImgs = cell(numDims, 1);
    
    %Find FT(I)
    fftImage = fftn(image);
    
    %Find FT(G)
    ft_G = getFTofNDimGaussian(dimensions,sigma);
    
    if numDims < 4
        difference = 4-numDims;
        addition = ones(difference,1);
        dimensions = [dimensions;addition];
    end
    
    %Confident in code up to this point
    for dim = 1:1:numDims
        %iterate through the number of dimensions of the input image
        
        %allocate the memory for the derivative image in the dimth
        %dimension
        derivImg = zeros(dimensions(1), dimensions(2),dimensions(3),dimensions(4));
        
        %look up the total number of points in current dimension
        N_dim = dimensions(dim);
        
        %allocate memory for distribution in x.
        v_dim = getV_xFT(N_dim);
        for x = 1:1:dimensions(1)
            for y = 1:1:dimensions(2)
                for z = 1:1:dimensions(3)
                    for t = 1:1:dimensions(4)
                        if dim == 1 
                            idx = x;
                        elseif dim == 2
                            idx = y;
                        elseif dim == 3
                            idx = z;
                        elseif dim == 4
                            idx = t;
                        end
                        derivImg(x,y,z,t) = ...
                            ((2*pi*1i*v_dim(idx))^repetitions)...
                            *fftImage(x,y,z,t)*ft_G(x,y,z,t);
                    end
                end
            end
        end
        derivImgs{dim} = real(ifftn(derivImg));
    end
end