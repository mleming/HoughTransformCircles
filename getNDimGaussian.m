function [ gaussian ] = getNDimGaussian( dimensions, sigma )
%GAUSSIAN = GETNDIMGAUSSIAN(DIMENSIONS, SIGMA)
%   INPUTS:
%       DIMENSIONS - An N x 1 input where N is the number of dimensions,
%       dimensions(x) will contain the amount of elements in the xth
%       dimension
%       SIGMA - The standard deviation of the gaussian to create
%   OUTPUTS:
%       GAUSSIAN - The N dimensional gaussian where n is the amount of
%       dimensions specified in the input dimensions
    
    numDims = size(dimensions,1);
    
    if numDims ~= 4
        if numDims > 4
            throw('Higher dimensions not yet supported');
        end
        difference = 4 - numDims;
        addition = ones(difference,1);
        dimensions = [dimensions; addition];
    end
    
    gaussian = zeros(dimensions(1), dimesions(2), dimensions(3), dimensions(4)); 
    gaussianStorage = cell(numDims);
    
    for dim1 = 1:1:numDims
        %iterate through the number of dimensions being examined. At nth
        %dimension return derivImgs{n} = resulting derivative.
        
        %Gaussian in 1d is G(x) = (1/(sqrt(2\pi)*\sigma))* e^-((x^2)/(2*(sigma)^2)
        %FT of 1d Gaussian G_ft(x) = exp(-(1/2)([2*\pi*\sigma]^2)*(v_x)^2)
        %2D ft of deriv in x = (ft of 1D gauss in y)*(ft of 1D guass in x)
        %*(2*\pi*i*v_x in x)
        
        for dim2 = 1:1:numDims
            N_dim = dimensions(dim2);
            
            v_dim = getV_xFT(N_dim);
            ftOf1DGaussInDim = zeros(N_dim, 1);
            
            ftOfGaussStorage{dim2} = ftOf1DGaussInDim;
        end
        for dim2 = numDims+1:1:4
            ftOfGaussStorage{dim2} = 1;
        end
    end
end

