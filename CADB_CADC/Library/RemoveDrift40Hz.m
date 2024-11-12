function s = RemoveDrift40Hz(x)
%   s = RemoveDrift40Hz(x)
% Removes gyro's drift using an IIR filter
s = filtfilt([1, -1], [1, -.9748], x);
end
