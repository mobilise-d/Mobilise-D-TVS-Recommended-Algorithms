
% clear all;
% close all;

%This script illustrates detection of walking cadence from data recorded in
%real-life conditions 

load data;  %load standardised exemplary data provided by MobiliseD project

%extract IMU data and sampling freq
imu_acc=data.TimeMeasure1.Recording4.SU.LowerBack.Acc;
imu_gyr=data.TimeMeasure1.Recording4.SU.LowerBack.Gyr;
fs=data.TimeMeasure1.Recording4.SU.LowerBack.Fs.Acc; 
DATA=[imu_acc imu_gyr];

%apply Gait Sequence Detection algorithm
plot_results=1; % plot the procesesed acceleration data and detected gait sequences
GS = GSD_LowBackAcc(imu_acc, fs, plot_results);

%apply Cadence detection algorithm
algs={'Shin_Imp', 'HKLee_Imp'};  %list of algorithm
if length(GS)>1
    [CAD]=CADENCE(DATA, fs, GS, 'Shin_Imp'); % 
    GS=CAD;  %update the Gait Sequence structure with cadence results
else
    fprintf('Error: the Gait sequence (GS) input is empty \n');
end

%Optional: save the Gait Sequence structure 
%save GS GS