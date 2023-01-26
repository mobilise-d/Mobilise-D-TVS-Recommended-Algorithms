
function [IC] = Shin_algo_improved(imu_acc, fs)
% 
% Inputs:
% imu_acc: 3D acceleration signal
%   imu_acc(:,1) : Vertical 
%   imu_acc(:,2) : Medio-lateral
%   imu_acc(:,3) : Antero-Posterior
% fs:  sampling frequency of input data (acc)
%
%Output: 
%IC:vector with timing of initial foot contacts (in seconds)
%
%References:
% Method based on acc norm, multi-processed (filtered)
% [1] Shin, Seung Hyuck, and Chan Gook Park. "Adaptive step length estimation algorithm
%using optimal parameters and movement status awareness.
%" Medical engineering & physics 33.9 (2011): 1064-1071.
%
%[2] Paraschiv-Ionescu, A. et al.
%"Real-world speed estimation using single trunk IMU:
%methodological challenges for impaired gait patterns". IEEE EMBC (2020): 4596-4599.
%
%Author(s):
%    - Anisoara Ionescu (anisoara.ionescu@epfl.ch)
%   
%   Laboratory of Movement Analysis and Measurement (LMAM), EPFL 
%   Mobilise-D (https://www.mobilise-d.eu/)
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IC=[];
IC_lowSNR=[];

acc=imu_acc;
accN=sqrt(acc(:,1).^2+acc(:,2).^2+acc(:,3).^2);

%resample to 40Hz to process with custom designed FIR filters 
algorithm_target_fs=40;

accN40=resampInterp(accN,fs,algorithm_target_fs);

%filter designed for low SNR, impaired, asymmetric and slow gait
load FIR-2-3Hz-40;  %filter coefficients

%padding to cope with short data (e.g., when the number of samples of gait
%sequence is lower than the number of filter coefficients
len_padd=4*length(Num);  %Num: FIR filter coeffs
accN40_zp=padarray(accN40,len_padd,'circular','both');

%Apply various filters to enhance the aceleration signal
% when low SNR, impaired, asymmetric and slow gait
accN_filt1=sgolayfilt(accN40_zp,7,21);
accN_filt2 = filtfilt(Num, 1, RemoveDrift40Hz(accN_filt1));
accN_filt3=cwt(accN_filt2,10,'gaus2',1/40);
accN_filt4=sgolayfilt(accN_filt3,5,11);
accN_filt5=cwt(accN_filt4,10,'gaus2',1/40);
accN_filt6=smoothdata(accN_filt5,'gaussian',10);
accN_filt7=smoothdata(accN_filt6,'gaussian',10);
accN_filt8=smoothdata(accN_filt7,'gaussian',15);
accN_MultiFilt_rmp=accN_filt8(len_padd:end-len_padd);     %remove padding 

%%resample to 50Hz for consistency with the original paper
fs_new=50;
accN_MultiFilt_rmp50=resampInterp(accN_MultiFilt_rmp,algorithm_target_fs,fs_new);

%initial contacts timmings (heel strike events) detected as positive slopes zero-crossing 
[IC_lowSNR,~]=zerocros(accN_MultiFilt_rmp50,'p');
IC_lowSNR=round(IC_lowSNR);
IC=IC_lowSNR/fs_new; %in seconds

%plot to verify accuracy of step detection (IC in samples)
% figure
% plot((1:length(accN_MultiFilt_rmp50)),accN_MultiFilt_rmp50, IC_lowSNR, accN_MultiFilt_rmp50(IC_lowSNR), 'gs','LineWidth',1.4);
% legend('accNorm (processed)','Initial Contacts (IC)');
end

