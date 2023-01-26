
clear all;
close all;

load data;

%load IMU data
imu_acc=data.TimeMeasure1.Recording4.SU.LowerBack.Acc  ;
imu_gyr=data.TimeMeasure1.Recording4.SU.LowerBack.Gyr  ;
fs=data.TimeMeasure1.Recording4.SU.LowerBack.Fs.Acc; 
DATA=[imu_acc imu_gyr];
plot_results=1;
GS = GSD_LowBackAcc(imu_acc, fs, plot_results);

SD = StepDetection(imu_acc,GS, fs, plot_results);