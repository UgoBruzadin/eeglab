function out = outlier(data,sdv)
% outputs the outlier given X sdv, works for FFT data

if nargin < 2
    sdv = 3;
end

m = mean(data);
v = var(data);
s = std(data);

out = abs(data) > sdv*abs(s) + abs(m);

end