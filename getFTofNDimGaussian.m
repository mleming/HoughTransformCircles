function ftGaussian = getFTofNDimGaussian(dimensions, sigma)
%FTGAUSSIAN = GETFTOFNDIMGUASSIAN(DIMENSIONS, SIGMA)
%   INPUTS:
%       DIMENSIONS - An N x 1 input where N is the number of dimensions,
%       dimensions(x) will contain the amount of elements in the xth
%       dimension
%       SIGMA - The standard deviation of the gaussian to create
%   OUTPUTS:
%       FTGAUSSIAN - The fourier transform of the N dimensional gaussian
%       where in is the amount of dimensions specified in the input
%       dimensions.
%       
%   Calculates the FT of the N dimensional gaussian. Implemented for COMP
%   775 at the University of North Carolina at Chapel Hill - Medical Image
%   Analysis taught by Stephen Pfizer Fall 2014
%
%   Code Written by Nathan Roach
%   nproach@live.unc.edu
%   Theoretical basis provided by Stephen Pizer PhD.
%   pizer@cs.unc.edu

    numDims = size(dimensions,1);
    
    if numDims ~= 4
        if numDims > 4
            throw('Higher dimensions not yet supported');
        end
        difference = 4 - numDims;
        addition = ones(difference,1);
        dimensions = [dimensions; addition];
    end
    
    ftGaussian = zeros(dimensions(1),dimensions(2),dimensions(3),dimensions(4));
    ftOfGaussStorage = cell(numDims,1);
    
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
            
            for x = 1 : 1 : N_dim
                ftOf1DGaussInDim(x) =...
                    exp((-1/2)*((2*pi*sigma)^2)*(v_dim(x)^2));
            end
            
            ftOfGaussStorage{dim2} = ftOf1DGaussInDim;
        end
        for dim2 = numDims+1:1:4
            ftOfGaussStorage{dim2} = 1;
        end
        
        for x = 1:1:dimensions(1)
            for y = 1:1:dimensions(2)
                for z = 1:1:dimensions(3)
                    for t = 1:1:dimensions(4)
                        ftGaussian(x,y,z,t) =...
                            ftOfGaussStorage{1}(x)*ftOfGaussStorage{2}(y)*...
                            ftOfGaussStorage{3}(z)*ftOfGaussStorage{4}(t);
                    end
                end
            end
        end
    end
end