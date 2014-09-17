function [ Vx, Vy] = voter( x, y, theta, radius )
%Author: Matthew Leming
%A 
    Vy = round(radius*sind(theta) + y);
    Vx = round(radius*cosd(theta) + x);
end

