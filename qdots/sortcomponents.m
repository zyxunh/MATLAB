function [sx, isx] = sortcomponents(x)
% [sx, isx] = sortcomponents(x)
% fx = mean (x,2);
% ts = testimportance(reshape(dpixc, peval.nx*peval.ny, peval.nt), res.w, res.h);

fx= sum(x.^2,1);

[sx, isx] = sort(fx, 'descend');
