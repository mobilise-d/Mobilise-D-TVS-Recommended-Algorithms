function [mi, ma] = FindMinMax(s, thr)
%find min and max values in signal 's', bellow and above 'thr', respectivelly
d = diff(s);
f = find( d(2:end) .* d(1:end-1) <= 0);
f = f + 1;

mi = f(d(f)>=0);
ma = f(d(f)<0);

if nargin == 2
    ma = ma(s(ma) > thr);
    mi = mi(s(mi) < -thr);
end
end