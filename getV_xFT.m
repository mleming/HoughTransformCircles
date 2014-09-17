function [ v_x ] = getV_xFT(N)
%V_X = GETV_X(N)
%   INPUTS:
%       N - Size of the desired frequency range
%   OUTPUTS:
%       V_X - Range of frequencies of size N
%       
%   Generates a list of frequencies that need to be examined in fourier
%   space
%
%   Code Written by Nathan Roach
%   nproach@live.unc.edu
%   Theoretical basis provided by Stephen Pizer PhD.
%   pizer@cs.unc.edu

    j = zeros(N,1);
    j(2 : N/2 + 1) = 1:1:N/2;
    j(N/2 + 2: N) = (-N/2 + 1 : 1 : -1); 

    v_x = j/N;

end

