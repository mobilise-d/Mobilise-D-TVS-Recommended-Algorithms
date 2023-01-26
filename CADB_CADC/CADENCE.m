%CADENCE   Computes cadence (steps/min) of given gait sequences. It
%             needs a vector structure which contains the start and end (in second)
%             of each sequence from the beginning of the input signal.
%
%   Inputs:
%    - DATA: is a matrix containing of:
%       + Accelerometer (g) in first three columns
%       + Gyroscope (degrees/s) in second three columns
%    - fs: sampling frequency of the input data
%    - GS: a vector structure containing two fields:
%       + GS(N).start: start of N-th gait sequence (in second)
%       + GS(N).stop : stop  of N-th gait sequence (in second)
%    - algs: available algos (to select one between them):
%       + 'Shin_Imp'  
%       + 'HKLee_Imp'
%
%   Output:
%    - output_cadence: a vector structure containing:
%       + output_cadence(N).Start   : start of N-th gait sequence (in second)
%       + output_cadence(N).End    : end  of N-th gait sequence (in second)
%       + output_cadence(N).cadSec  : Estimated cadence-per-second of N-th
%                                    gait sequence (unit: steps/min)
%       + output_cadence(N).cadMean : mean of cadence estimated for N-th gait
%                                    sequence (unit: steps/min)
%       + output_cadence(N).cadSTD  : std of cadence estimated for N-th gait
%                                    sequence (unit: steps/min)
%       + output_cadence(N).steps   : Number of steps of N-th gait sequence
%
%   Authors:
%    - Abolfazl Soltani (abolfazl.soltani@epfl.ch)
%    - Anisoara Ionescu (anisoara.ionescu@epfl.ch)
%   Laboratory of Mouvement Analysis and Measurement (LMAM), EPFL 
%   Mobilise-D (https://www.mobilise-d.eu/)
%
% -------------------------------------------------------------------------

function [output_cadence]=CADENCE(DATA, fs, GS, algs)

%% Initialization
output_cadence = GS;
alg_num=2;
%% CADENCE ESTIMATION
Accelerometer = DATA(:,1:3);
%Gyroscope = DATA(:,4:6);      %not used by algorithms
BN = length([GS(:).Start]);
startvec=zeros(1,BN);
stopvec=zeros(1,BN);

for i = 1:BN
    try
        startvec(i) = floor(GS(i).Start.*fs);
        if startvec(i) < 1
            startvec(i) = 1;
        end
        
        stopvec(i) = floor(GS(i).End.*fs);
        if stopvec(i) > length(Accelerometer)
            stopvec(i) = length(Accelerometer);
        end
        
        chosenacc=Accelerometer(startvec(i): stopvec(i),:);
        
        warningflag=0;
        
        totalDur  =  floor(GS(i).End-GS(i).Start+(2/fs));
        
        cadmat    =  zeros(totalDur,alg_num);
        cadinx    =  zeros(1,alg_num);
        
        if any(strcmp(algs,'HKLee_Imp'))  % 1
            [IC_HKLee_improved]= HKLee_algo_improved(chosenacc, fs);
            [cadence_HKLee_imp] = cad2sec(IC_HKLee_improved,totalDur)/2;
            
            cadmat(:,1) = cadence_HKLee_imp(1:totalDur);
            cadinx (1)  = 1;
            
        end
        
        if any(strcmp(algs,'Shin_Imp'))  % 2
            
            [IC_Shin_improved] = Shin_algo_improved(chosenacc, fs);
            [cadence_Shin_improved] = cad2sec(IC_Shin_improved,totalDur)/2;
            
            cadmat(:,2)           = cadence_Shin_improved(1:totalDur);
            cadinx (2)            = 1;
            
        end
        
        
        cadinx                  = logical(cadinx);
        mycad                   = 120.*cadmat(:,cadinx);
        output_cadence(i).Start = startvec(i)./fs;
        output_cadence(i).End  = stopvec(i)./fs;
        output_cadence(i).cadSec = mycad;
        
        finaltemp=output_cadence(i).cadSec;
        if length(finaltemp) < totalDur
            finaltemp = [finaltemp;repmat(finaltemp(end),totalDur-length(finaltemp),1)];
        elseif length(finaltemp) > totalDur
            finaltemp = finaltemp(1:totalDur);
        end
        
        finaltemp(finaltemp < 30) = 30;
        finaltemp(finaltemp > 200) = 200;
        
        output_cadence(i).cadSec =finaltemp;
        output_cadence(i).cadMean = nanmean(output_cadence(i).cadSec);
        output_cadence(i).cadSTD  = nanstd(output_cadence(i).cadSec);
        output_cadence(i).steps   = round(nansum(finaltemp)./60);
        
    catch ME
        fprintf('Error on analysis of walking sequence : %s\n', ME.message);
        output_cadence(i).cadSec =NaN;
        output_cadence(i).cadMean = NaN;
        output_cadence(i).cadSTD  = NaN;
        output_cadence(i).steps   = NaN;
        continue;
    end
    
end

end %[Done]
