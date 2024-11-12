
% clear all;
% close all;

load data;  %load standardised exemplary data provided by MobiliseD project

%extract IMU data and sampling freq
imu_acc=data.TimeMeasure1.Recording4.SU.LowerBack.Acc;
%imu_gyr=data.TimeMeasure1.Recording4.SU.LowerBack.Gyr;
fs=data.TimeMeasure1.Recording4.SU.LowerBack.Fs.Acc; 
%DATA=[imu_acc imu_gyr];

%apply Gait Sequence Detection algorithm
plot_results=1; % plot the procesesed acceleration data and detected gait sequences
GS = GSD_LowBackAcc(imu_acc, fs, plot_results);