function f = mixgamma(x,p)
% g = mixgamma(x,p)
% f=p(5)*gampdf(x, p(1), p(2))+(1-p(5))*gampdf(x, p(3), p(4));
% alpha1 =  p(1)
% beta1 =   p(2)
% alpha2 =  p(3)
% beta2 =   p(4)
% gamma =   p(5)
f=p(5)*gampdf(x, p(1), p(2))+(1-p(5))*gampdf(x, p(3), p(4));
