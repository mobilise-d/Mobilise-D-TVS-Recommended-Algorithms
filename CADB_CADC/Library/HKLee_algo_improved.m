
function [IC]=HKLee_algo_improved(imu_acc, fs)
% 
% Inputs:
% imu_acc: 3D acceleration signal
%   imu_acc(:,1) : Vertical 
%   imu_acc(:,2) : Medio-lateral
%   imu_acc(:,3) : Antero-Posterior
% fs:  sampling frequency 
%
%Output: 
%IC:vector with timing of initial foot contacts (in seconds)

%References:
% method based on multi-processed acc norm (detrended, LP filtered and cwt and several gaussin smoothers) 
% & morphological filters
%[1] Lee, H-K., et al. "Computational methods to detect step events for normal and pathological
%gait evaluation using accelerometer." Electronics letters 46.17 (2010): 1185-1187.
%
%[2]Paraschiv-Ionescu, A. et al.
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


%%resample to 120Hz for consistency with the original paper & selection of
% parameters for morphological filters [Lee et all]
fs_new=120;
accN_MultiFilt_rmp120=resampInterp(accN_MultiFilt_rmp,algorithm_target_fs,fs_new);

%apply morphological filters
%SE is the stuctured element
SE_closing=ones(1,32);
SE_opening=ones(1,18);
C=imclose(accN_MultiFilt_rmp120',SE_closing);
O=imopen(C,SE_opening);
R=C-O;

if find(R>0)
    idx=groupfind(R>0);
    IC_lowSNR=zeros(length(idx(:,1)),1);
    for j=1:length(idx(:,1))
        [~, imax]=max(R(idx(j,1):idx(j,2)));
        if j<length(idx(:,1))
            IC_lowSNR(j)=idx(j,1)+imax;
        else
           IC_lowSNR(j)=idx(j,1);
        end
    end
end

%IC in seconds
IC=IC_lowSNR/fs_new;

%plot to verify accuracy of step detection (IC in samples)
% figure
% ax1=subplot(211),plot((1:length(accN_MultiFilt_rmp120)),accN_MultiFilt_rmp120,'k',IC_lowSNR, accN_MultiFilt_rmp120(IC_lowSNR),'ro','LineWidth',1.4);
% legend('accNorm (pre-processed)','Initial Contacts (IC)');
% ax2=subplot(212),hold on;plot(R,'r');hold off 
% legend('accNorm (pre-processed and applied morphological filters)');
% linkaxes([ax1 ax2],'x');
end