
function [IC, FC] = SD_algo_AMC(accV,fs)
% Inputs
% accV: vertical acc
% fs: sampling frequency 
%
%Outputs: 
%IC: timimg of initial contacts (in sec)
%FC: timing of final contacts (in sec)
%
%References:
% [1] McCamley, J., Donati, M., Grimpampi, E., & Mazzà, C. (2012).
% An enhanced estimate of initial contact and final contact instants of time using
% lower trunk inertial sensor data. Gait & posture, 36(2), 316-318.
%
% [2]Paraschiv-Ionescu, A. et al.
%"Real-world speed estimation using single trunk IMU:
%methodological challenges for impaired gait patterns". IEEE EMBC (2020): 4596-4599.
%
%Author(s):
%    - Anisoara Ionescu (anisoara.ionescu@epfl.ch)
%   
%   Laboratory of Movement Analysis and Measurement (LMAM), EPFL 
%   Mobilise-D (https://www.mobilise-d.eu/)
%      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

algorithm_target_fs=40;


%resample to 40Hz to process with custom designed FIR filters 
accV40=resampInterp(accV,fs,algorithm_target_fs);

%filter designed for low SNR, impaired, asymmetric and slow gait
load FIR-2-3Hz-40;  %filter coefficients

%padding to cope with short data (e.g., when the number of samples of gait
%sequence is lower than the number of filter coefficients
len_padd=10000*length(Num);  %Num: FIR filter coeffs
accV40_zp=padarray(accV40,len_padd,'circular','both');

accV40_lpf = filtfilt(Num, 1, RemoveDrift40Hz(accV40_zp));
accV40_lpf_rmzp=accV40_lpf(len_padd:end-len_padd);

accVLPInt=cumtrapz(accV40_lpf_rmzp)/algorithm_target_fs;
accVLPIntCwt=cwt(accVLPInt,9,'gaus2',1/algorithm_target_fs);
accVLPIntCwt=accVLPIntCwt-mean(accVLPIntCwt);
[pks1, ipks1] = MaxPeaksBetweenZC(accVLPIntCwt');
indx1=pks1<0;
IC=ipks1(indx1);
IC=IC/algorithm_target_fs;  %in seconds

accVLPIntCwt2=cwt(accVLPIntCwt,9,'gaus2',1/algorithm_target_fs);
accVLPIntCwt2=accVLPIntCwt2-mean(accVLPIntCwt2);
[pks2, ipks2] = MaxPeaksBetweenZC(accVLPIntCwt2');
indx2=pks2>0;
FC=ipks2(indx2);
FC=FC/algorithm_target_fs;  %in seconds

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Utilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mi, ma] = FindMinMax(s, thr)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = RemoveDrift40Hz(x)
%   s = RemoveDrift40Hz(x)
% Removes gyro's drift using an IIR filter
s = filtfilt([1, -1], [1, -.9748], x);
end