
% clear all;
% close all;

%This script illustrates detection of stride length from data recorded in
%real-life conditions 

load data;  %load standardised exemplary data provided by MobiliseD project
load infoForAlgo  % this inclues subject's data collected at measurement time

%extract IMU data and sampling freq
imu_acc=data.TimeMeasure1.Recording4.SU.LowerBack.Acc;
imu_gyr=data.TimeMeasure1.Recording4.SU.LowerBack.Gyr;
fs=data.TimeMeasure1.Recording4.SU.LowerBack.Fs.Acc; 
DATA=[imu_acc imu_gyr];

%apply Gait Sequence Detection algorithm
plot_results=1; % plot the procesesed acceleration data and detected gait sequences
GS = GSD_LowBackAcc(imu_acc, fs, plot_results);

%apply Step Detection algorithm 
% provide the initial contact(IC)/heel strike events within each detected gait sequence  
if length(GS)>1
    plot_results=1; %plot detected IC events on the processed acceleration signal 
    SD = StepDetection(imu_acc, GS, fs, plot_results);
    GS=SD;  %update the Gait Sequence structure with step detection results
else
    fprintf('Error: the Gait sequence (GS) input is empty \n');
end

%apply Cadence detection algorithm
algs={'Shin_Imp', 'HKLee_Imp'};  %list of algorithm, to select one of them
if length(GS)>1
    [CAD]=CADENCE(DATA, fs, GS, 'Shin_Imp'); % 
    GS=CAD;  %update the Gait Sequence structure with cadence results
else
    fprintf('Error: the Gait sequence (GS) input is empty \n');
end


%% %apply Stride Length estimation algorithm
alg_SL='zjilsV3';

%select the model name, trained for tuning the correction factor 'K' in
%Zijlstra's step length biomechanical

% available models are: 'MS_MS'; 'MS_ALL'; 'ICICLE_ALL'
modelName='MS_MS'; 

%update the GS structure with infoForAlgo 
for j=1:length(GS)
    GS(j).subInfo.LBh = infoForAlgo.TimeMeasure1.SensorHeight;   % sensor height (from ground to the sensor) in cm              
%     GS(j).subInfo.height = infoForAlgo.TimeMeasure1.Height;      % height of the subject in cm                                    
%     GS(j).subInfo.weight = infoForAlgo.TimeMeasure1.Weight;      % weight of the subject in kg                        
%     GS(j).subInfo.footSize = infoForAlgo.TimeMeasure1.FootSize;  % foot size in cm                                                                                                                                                            
end

[SL]=STRIDELEN(DATA, fs, GS, alg_SL, modelName);

GS=SL; %structure updated with stride length detection results 

%Optional: save the Gait Sequence structure 
save GS GS