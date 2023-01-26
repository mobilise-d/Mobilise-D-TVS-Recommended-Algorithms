
function sl_zjilstra_v3=zjilsV3(LB_vacc_high,fs,model,HSsamp,LBh)
%step length estimation using the biomechanical model propose by Zijlstra & Hof
%
% Zijlstra, W., & Hof, A. L. (2003). Assessment of spatio-temporal gait parameters from trunk accelerations during human walking.
% Gait & posture, 18(2), 1-10.
%
% Inputs:
%  - LB_vacc_high: vertical acceleration recorded on lower back, high-pass
%  filtered
%   - fs: sampling frequency of input data (acc signal)
%   - model: contains the correction factor 'K' estimated by data from
%   various clinical populations (training data)
%   - HSsamp: vector containing the timing of heal strikes (or initial contacts)
%   events (in samples)
%    - LBh: Low Back height, i.e., the distance from ground to sensor location on lower back (in cm) 
%
% Output: 
%   - sl_zjilstra_v3: estimated step length

vspeed=-cumsum(LB_vacc_high)./fs;

%drift removal (high pas filtering)
fc=1;
[df,cf] = butter(4,fc/(fs/2),'high');
speed_high=filter(df,cf,vspeed);

%estimate vertical displacement
vdis_high_v2=cumsum(speed_high)/fs;

h_jilstra_v3=zeros(length(HSsamp)-1,1);
for k=1:length(HSsamp)-1

    h_jilstra_v3(k)=abs(max(vdis_high_v2(HSsamp(k):HSsamp(k+1)))-min(vdis_high_v2(HSsamp(k):HSsamp(k+1))));

end

K=model.zjilsV3.K;
sl_zjilstra_v3=K*sqrt(abs((2*LBh*h_jilstra_v3)-(h_jilstra_v3.^2)));

end