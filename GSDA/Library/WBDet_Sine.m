function WBs_vector = WBDet_Sine(imu,SampleRate,WinS,OL,activity_thresh,plot_results)
% Copyright 2023 Center for the Study of Movement, Cognition, and Mobility. Tel Aviv Sourasky Medical Center, Tel Aviv, Israel.
% Licensed under the Apache License, Version 2.0 (the "License"); 
% you may not use this file except in compliance with the License. 
% You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0  
% Unless required by applicable law or agreed to in writing, software 
% distributed under the License is distributed on an "AS IS" BASIS, 
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
% See the License for the specific language governing permissions and
% limitations under the License.

%% Fast gait detection based on convolution with sine wave
%input:
% acc - 3D acceleration signal (v,ml,ap)
% SampleRate - sampling rate in Hz
% WinS - the convolution signal is buffered into small size windows in size of WinS 
% OL - overlap between the small size windows of the convolution signal
% activity_thresh - remove noise
%output:
% WBs_vector - vector containing 0 and 1 (1=gait)

acc = imu(:,1:3);

%----------Filtering the Signal---------------------------------------------------
Filter.low=0.5;
Filter.walk=3;
WS=WinS/SampleRate;
order=200;
cutoff=[Filter.low Filter.walk];
cutoffnorm=cutoff/(SampleRate/2);
[b,a]=fir1(order,cutoffnorm,'bandpass');
%Vertical Acc
filt_sig_V=filter(b,a,acc(:,1));
filt_sig_shift_V=filt_sig_V(1*SampleRate:end);
%Anterior-Posterior Acc
filt_sig_AP=filter(b,a,acc(:,3));
filt_sig_shift_AP=filt_sig_AP(1*SampleRate:end);

%-------------------------------------------------------------
%reshape the filtered data - each column is the size of WinS with overlap
%of OL to the previous window
%Vertical axis
filt_mat_V=buffer(filt_sig_shift_V,WinS,WinS-OL);

%find indexs in vertical acceleration where the STD of the signal is bigger than the thresholds
ActivityW=find(std(filt_mat_V)>activity_thresh);
filt_mat_V=filt_mat_V(:,ActivityW);%Keeping the windows that have enough activity
%AP
filt_mat_AP=buffer(filt_sig_shift_AP,WinS,WinS-OL);
filt_mat_AP=filt_mat_AP(:,ActivityW);

Sig_mat_V=buffer(acc(:,1)-1,WinS,WinS-OL);
Sig_mat_V_DC=buffer(acc(:,1),WinS,WinS-OL);%Keeping the DC (used to determine if the sensor is in an upright position).
Sig_mat_AP=buffer(acc(:,3),WinS,WinS-OL);

Act_mat_V=Sig_mat_V(:,ActivityW);
Sig_mat_V_DC=Sig_mat_V_DC(:,ActivityW);

%% convolving the Data with a sin template
SineGaitTemplate=sin(2*pi*(0:1/(SampleRate):1/2)*2);

% Vertical
ConvV=conv(acc(:,1)-1,SineGaitTemplate);%Convolution between the acceleration signal and sine template
ConvVMat=buffer(ConvV(length(SineGaitTemplate):end),WinS,WinS-OL);%Buffering the convolved signal
ConvVMat=ConvVMat(:,ActivityW);%Taking only the windows with activity (reduces noises that are detected as gait)
Peak_Vec_V=[];
PeakAmp_Vec_V=[];
CM_V=zeros(WinS,size(filt_mat_V,2));
Num_Peak_V=zeros(1,size(filt_mat_V,2));
for i=1:size(filt_mat_V,2)
    CM_V=ConvVMat(:,i);
    if sum(CM_V>0.4)%checking if there is enough amplitude in the convolved window to search for peaks. Otherwise it is not gait.
        [PLoc]=Find_Peaks(CM_V,SampleRate/10,0);%Detecting how many possible peaks (steps) exist in the signal
        PAmp=CM_V(PLoc);%Peaks amplitude
        PeakLoc=find(PAmp>0.4);%Taking only strong peaks
        Peak_V=PAmp(PeakLoc);
    else
        Peak_V=[];PeakLoc=[];
    end
    
    Num_Peak_V(i)=length(Peak_V);
    loc_vec_V=(PeakLoc+WinS*(i-1))';
    Peak_Vec_V=[Peak_Vec_V loc_vec_V];
    PeakAmp_Vec_V=[PeakAmp_Vec_V Peak_V'];
end

%%
Noise_V=find(Num_Peak_V<WS | Num_Peak_V>(WS*3));%Setting threshold on the expected number of steps per window. In the vertical axis, for 1 sec window, the number of steps should be between 1 to 3.
Gait_conv_V=setdiff(1:size(Act_mat_V,2),Noise_V);%Keeping only the windows that have logical amount of steps
mean_Act_mat_V=mean(Act_mat_V,1);%Mean of each window
mean_Act_mat_V=repmat(mean_Act_mat_V,WinS,1);%Each vector in the matrix contains the mean of the windos
Norm_sig_V=Act_mat_V-mean_Act_mat_V;%Removing the mean from each window2
Noise_mean_V=find(mean(Norm_sig_V)<=-0.1);
Noise_mean2_V=find(mean(Sig_mat_V_DC)<=0.5); %check DC. While standing the DC in the vertical axis should be larger than 0.5 (close to 1)
Gait_mean_V=setdiff(1:size(Act_mat_V,2),[Noise_mean_V Noise_mean2_V]);
GaitWindows_V=intersect(Gait_mean_V,Gait_conv_V);

%% AP - performing equivalent gait detection on the AP direction.
ConvAP=conv(acc(:,3),SineGaitTemplate);
ConvAPMat=buffer(ConvAP(length(SineGaitTemplate):end),WinS,WinS-OL);

Peak_Vec_AP=[];
PeakAmp_Vec_AP=[];
Num_Peak_AP=zeros(1,size(filt_mat_AP,2));

ConvAPMat=ConvAPMat(:,ActivityW);
Act_mat_AP=Sig_mat_AP(:,ActivityW);

for i=1:size(filt_mat_AP,2)
    
    CM_AP=ConvAPMat(:,i);
    
    if sum(CM_AP> 1.5)
        [PLoc]=Find_Peaks(CM_AP,SampleRate/10,0);
        PAmp=CM_AP(PLoc);
        PeakLoc=find(PAmp>1.5);
        Peak_AP=PAmp(PeakLoc);
    else
        Peak_AP=[]; PeakLoc=[];
    end
    Num_Peak_AP(i)=length(Peak_AP);
    loc_vec_AP=(PeakLoc+WinS*(i-1))';
    Peak_Vec_AP=[Peak_Vec_AP loc_vec_AP];
    PeakAmp_Vec_AP=[PeakAmp_Vec_AP Peak_AP'];
end

Noise_AP=find(Num_Peak_AP<=(WS-2) | Num_Peak_AP>(WS*3));
GaitWindows_AP=setdiff(1:size(Act_mat_AP,2),Noise_AP);

%% returns the data common to both Gait_conv_V and Gait_conv_AP, with no repetitions.
GaitWindows=intersect(GaitWindows_V,GaitWindows_AP);
GaitWindows=ActivityW(GaitWindows);
%%
WBs_vector=zeros(1,size(acc(:,1),1));
gw=GaitWindows*OL+OL;
vAcc=acc(:,1);
for i=1:length(gw)-1
    %To prevent transitions (e.g. sit to stand) to be detected as gait
    %another threshold was added on vAcc - in a gait window (gw) of 3 sec we
    %expect that the first and the last sec will have similar means (15
    %precent was chosen arbitrary)
    try
    mean_first_sec=mean(vAcc(gw(i)-WinS+1:gw(i)-(WinS*2/3)));%the first sec in the 3 sec gait window
    mean_last_sec=mean(vAcc(gw(i)-(WinS/3)+1:gw(i)));%the last sec in the 3 sec gait window
    if abs(mean_first_sec-mean_last_sec)*100<15 %we allow 15% difference between the two means
        WBs_vector(gw(i)-WinS+1:gw(i))=1;
    end
    catch
        WBs_vector(gw(i)-WinS+1:gw(i))=1;
    end
end

WBs_vector(size(acc(:,1))+1:end)=[];

%Remove bouts with less than 5 sec
a = diff(WBs_vector);
segmentsStartInd = find(a == 1);
segmentsEndInd = find(a == -1);
if WBs_vector(1) == 1
    segmentsStartInd = [1 ,segmentsStartInd];
end
if WBs_vector(end) == 1
    % output
    segmentsEndInd = [segmentsEndInd , size(acc(:,1),1)-1];
end
% Discard WB segments less than the minimum length threshold
segmentsEndInd = segmentsEndInd - 1;
segmentsLength = segmentsEndInd - segmentsStartInd;
segmentsStartInd = segmentsStartInd(segmentsLength >= floor(SampleRate*5));
segmentsEndInd = segmentsEndInd(segmentsLength >= floor(SampleRate*5));
WBs_vector=zeros(1,size(acc(:,1),1));
for segment_index = 1:length(segmentsStartInd)
    try
        WBs_vector(segmentsStartInd(segment_index):segmentsEndInd(segment_index)) = 1;
    catch
    end
end

% plot results if the flag was set to true
if plot_results
    figure;
    plot(acc)
    hold on
    plot(WBs_vector)
    legend('Acc_V','Acc_ML','Acc_AP','Walking')
end

end

