%%
%STRIDELEN   Computes stride length (m) of a given gait sequences. It
%             needs a list which contains the start and end (in second)
%             of each sequence from the beginning of the input signal.
%
%   [output_sl] = STRIDELEN(DATA, fs, GS ,alg,codePath, modelName)
%
%   Inputs:
%    - DATA: is a matrix containing of:
%       + Accelerometer (g) in first three columns
%       + Gyroscope (d/s) in second three columns
%
%    - fs: sampling frequency of the input
%
%    - GS: a vector structure containing two fileds:
%       + GS(N).Start: start of N-th gait sequence (in second)in DATA
%       + GS(N).End : stop  of N-th gait sequence (in second)in DATA
%       + GS(N).IC   : IC moments (in second) of the N-th gait sequecne in
%                      DATA from the beginning of DATA
%       + GS(N).cadSec: cadence-per-second (steps/min) values within N-th
%                      gait sequence in DATA
%       + GS(N).subInfo: a structure containing the information about the subject as follows:
%           * GS(N).subInfo.height    : height of the subject in cm for the
%                                       N-th sequence
%           * GS(N).subInfo.weight    : weight of the subject in kg for the
%                                       N-th gait sequence
%           * GS(N).subInfo.LBh       : sensor height (from ground to the sensor) in cm for the
%                                       N-th gait sequence
%           * GS(N).subInfo.footSize  : foot size in cm for the
%                                       N-th gait sequence
%
%   - alg:  the algorithm used for cadence estimation
%        'zjilsV3'
%    - modelPath: path to the folder including trained model parameters
%    - modelName: specifies models trained on which population must be used
%                 for SL estimation. It can be one of the following names
%       ICICLE_ALL
%       ICICLE_HC
%       ICICLE_PD
%       MS_ALL
%       MS_HC
%       MS_MS
%       UNISS_ALL
%       UNISS_CH
%       UNISS_HC
%       UNISS_PD
%       UNISS_ST
%
%   Output:
%    - output_sl: a vector structure containing:
%       + output_sl(N).Start   : start of N-th gait sequence (in second) in DATA
%       + output_sl(N).End    : stop  of N-th gait sequence (in second) in DATA
%       + output_sl(N).slSec   : Estimated stridelength-per-second of N-th
%                                gait sequence (unit: m) in DATA
%       + output_sl(N).slMean  : mean of stride length estimated for N-th gait
%                                sequence (unit: m) in DATA
%       + output_sl(N).slSTD   : std of stride length estimated for N-th gait
%                                sequence (unit: m) in DATA
%       + output_sl(N).distance: covered distnace of N-th gait sequence
%                                (unit: m) in DATA
% References: 
% Soltani, A., et al. "Algorithms for walking speed estimation using a lower-back-worn inertial sensor:
% A cross-validation on speed ranges." IEEE TNSRE 29 (2021): 1955-1964.
%
% Zijlstra, W., & Hof, A. L. (2003). Assessment of spatio-temporal gait parameters from trunk accelerations during human walking.
% Gait & posture, 18(2), 1-10.
%
%   Authors:
%    - Abolfazl Soltani (abolfazl.soltani@epfl.ch)
%    - Anisoara Ionescu (anisoara.ionescu@epfl.ch)
%
%   Laboratory of Mvement Analysis and Measurement (LMAM), EPFL
%   Mobilise-D (https://www.mobilise-d.eu/)
%
% -------------------------------------------------------------------------
%%
function [output_sl]=STRIDELEN (DATA, fs, GS, alg, modelName)

%% Initialization

alg_num   =  1; % numbers of implemented algs

output_sl = GS;

[sub]=infocheck(GS);

%% Finding the models (loading or training)
%modeladd = [modelPath,'SLmodel_',modelName,'.mat'];

modeladd = ['SLmodel_',modelName,'.mat'];

load(modeladd);
fprintf('SL_main: Loading trained model correction factor K \n')

%% SL estimation
Accelerometer = DATA(:,1:3);
Gyroscope     = DATA(:,4:6);

BN = length([GS(:).Start]);
AHRS = MadgwickAHRS('SamplePeriod', 1/fs, 'Beta', 0.1);

for i = 1:BN
    try
        startsamp= floor (GS(i).Start.*fs);
        if startsamp < 1
            startsamp=1;
        end

        stopsamp = floor(GS(i).End.*fs);
        if stopsamp > length(Accelerometer)
            stopsamp=length(Accelerometer);
        end

        HS=[GS(i).IC];
        if size(HS,1)>size(HS,2)
            HS=HS';
        end

        nanHS=isnan(HS);
        diffHS=diff(nanHS);

        negHS=diffHS==-1;
        negHS=[false,negHS];
        posHS=diffHS==1;
        posHS=logical([posHS,false]);

        starttemp=HS(negHS);
        stoptemp=HS(posHS);

        if nanHS(1)==false
            if nanHS(2)==false
                starttemp=[GS(i).Start,starttemp];
            else
                stoptemp(1)=[];
            end
        end

        if nanHS(end)==false
            if nanHS(end-1)==false
                stoptemp=[stoptemp,GS(i).End];
            else
                starttemp(end)=[];
            end
        end

        HSrem=(stoptemp-starttemp)<=0;
        stoptemp(HSrem)=[];
        starttemp(HSrem)=[];
        allstart=starttemp-GS(i).Start;
        allstop=stoptemp-GS(i).Start;

        allstartsamp=floor(allstart.*fs);
        allstopsamp=floor(allstop.*fs);

        if allstartsamp(1)< 1
            allstartsamp(1)=1;
        end

        if allstopsamp(end) > stopsamp-startsamp+1
            allstopsamp(end) = stopsamp-startsamp+1;
        end

        %% Sensor alignment
        chosenacc=Accelerometer(startsamp: stopsamp,:);
        chosengyr=Gyroscope(startsamp: stopsamp,:);

        mytime        = (0:length(chosenacc)-1)./fs;
        quaternion    = zeros(length(mytime), 4);

        for t = 1:length(mytime)
            AHRS.UpdateIMUslt2(chosengyr(t,:) * (pi/180), chosenacc(t,:));	% gyroscope units must be radians
            quaternion(t,:) = AHRS.Quaternion;
        end

        av      = acceleration([chosenacc,chosengyr * (pi/180)], quaternion);

        pcaCoef = pca(chosenacc);
        newAcc  = chosenacc*pcaCoef;

        if mean(newAcc(:,1)) < 0
            newAcc(:,1) = -newAcc(:,1);
        end

        av_magpca      = av;
        av_magpca(:,1) = newAcc(:,1);

        %% Filtering
        vacc=9.8.*newAcc(:,1);

        fc=0.1;
        [df,cf] = butter(4,fc/(fs/2),'high');
        vacc_high=filter(df,cf,vacc);

        %% stride length estimation

        realtotalDur  =  floor(GS(i).End-GS(i).Start+(2/fs));
        SL = NaN(realtotalDur,1);
        SLgc=NaN(length([GS(i).IC])-1,1);
        
        for sb=1:length(allstart)
            totalDur = floor(allstop(sb)) - floor(allstart(sb));
            slmat    =  zeros(totalDur,alg_num);
            slinx    =  zeros(1,alg_num);

            B_vacc_high = vacc_high(allstartsamp(sb):allstopsamp(sb),:);

            HStime = GS(i).IC-GS(i).Start-allstart(sb);

            [m,I]=min(abs(HStime));
            if HStime(I)<0
                I=I+1;
            end

            [m,E]=min(abs(HStime-(allstop(sb)-allstart(sb))));
            if HStime(E)-(allstop(sb)-allstart(sb)) >0
                E=E-1;
            end

            HStime=HStime(I:E);

            Lslgc=length(HStime)-1;

            slgcmat  = NaN(Lslgc,alg_num);

            REFHSvalid=~(any(isnan(HStime)) | any(diff(HStime)<=0) | length(HStime)<=1);

            if REFHSvalid
                HSsamp=round(HStime*fs);

                if HSsamp(1)< 1
                    HSsamp(1)=1;
                end
                if HSsamp(end) > allstopsamp(sb)-allstartsamp(sb)
                    HSsamp(end) = allstopsamp(sb)-allstartsamp(sb);
                end
     

                %% estimate SL using biomechanical model 

                if any(strcmp(alg,'zjilsV3'))
                    sl_zjilstra_v3=zjilsV3(B_vacc_high,fs,model,HSsamp,sub(i).LBh);
                    [slSec_zjilstra_v3]=stride2sec(HStime,totalDur,sl_zjilstra_v3);

                    slgcmat(:,1)      = slgaitcycle(sl_zjilstra_v3,Lslgc);
                    slmat(:,1)        = slSec_zjilstra_v3(1:totalDur);
                    slinx (1)         =  1;
                end


                slinx                  = logical(slinx);
                mysl                   = slmat(:,slinx);
                myslgc                 = slgcmat(:,slinx);

                sltemp = zeros(size(mysl,1),1);
                sltempgc = zeros(size(myslgc,1),1);

                sltemp = mysl;
                sltempgc = myslgc;

                finaltemp=sltemp;
                if length(finaltemp) < totalDur
                    finaltemp = [finaltemp;repmat(finaltemp(end),totalDur-length(finaltemp),1)];
                elseif length(finaltemp) > totalDur
                    finaltemp = finaltemp(1:totalDur);
                end

                finaltemp(finaltemp < 0.1) = 0.1;
                finaltemp(finaltemp > 2.5) = 2.5;

                sltempgc(sltempgc < 0.1) = 0.1;
                sltempgc(sltempgc > 2.5) = 2.5;

                SLstart=floor(allstart(sb))+1;
                SLstop=floor(allstop(sb));

                SL(SLstart:SLstart+length(finaltemp)-1)=finaltemp;
                SLgc(I:E-1) = sltempgc;
            end
        end
        output_sl(i).slSec = SL;
        output_sl(i).slMean = nanmean(SL);
        output_sl(i).slSTD  = nanstd(SL);
        output_sl(i).distance   = nansum(SL);

    catch ME
        fprintf('Error on analysis of walking sequence : %s\n', ME.message);
        output_sl(i).slSec = NaN;
        output_sl(i).slMean = NaN;
        output_sl(i).slSTD  = NaN;
        output_sl(i).distance = NaN;
        continue;
    end

end

end




















