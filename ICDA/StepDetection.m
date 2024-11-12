function SD_Output = StepDetection(imu_acc,GS, fs, plot_results)
%
% Inputs:
% imu_acc: 3D acceleration signal
%   imu_acc(:,1) : Vertical 
%   imu_acc(:,2) : Medio-lateral
%   imu_acc(:,3) : Antero-Posterior
% fs:  sampling frequency of input data (acc)
% GS: a vector structure containing two fields:
%       + GS(N).start: start of N-th gait sequence (in second)
%       + GS(N).stop : stop  of N-th gait sequence (in second)
% plot_results: make it 1 if you want a plot and 0 when you dont want a plot
%
% Output:
%    SD_Output: a vector structure containing:
%       + SD_Output(N).Start  :start of N-th gait sequence (in second)
%       + SD_Output(N).End    : end  of N-th gait sequence (in second)
%       + SD_Output(N).IC     : timing of initial contacts detected in N-th gait sequence (in second)  
% 
% Author(s):
%    - Anisoara Ionescu (anisoara.ionescu@epfl.ch)
%   Laboratory of Mouvement Analysis and Measurement (LMAM), EPFL 
%   Mobilise-D (https://www.mobilise-d.eu/)
%
% -------------------------------------------------------------------------

AccV=imu_acc(:,1); %vertical acceleration

if isstruct(GS) && ~isempty(fieldnames(GS))
    % create an empty struct for the output
    SD_Output = struct();
    
    % iterate over the gait sequences in the trial
    for j = 1:length(GS)
        start=round(fs*GS(j).Start);
        stop=round(fs*GS(j).End);
        accV_GS=AccV(start:stop);
        % apply the sd algorithm
        try
            [IC_rel,~] = SD_algo_AMC(accV_GS,fs);
            IC=GS(j).Start+IC_rel;
            GS(j).IC=IC;
        catch
            warning('SD algorithm did not run successfully. Returning an empty vector of ICs')
            IC = [];
            GS(j).IC=[];
        end
    end
    SD_Output=GS;
else
    % In case there was not gait sequence, return an emptpy refined one
    SD_Output = [];
    return
end

%plot to verify accuracy of step detection 
if plot_results
    load FIR-2-3Hz-40;
    fs_algo=40;
    IC_allSig=vertcat(GS.IC);
    ICs=round(IC_allSig*fs);

    accV40=resampInterp(AccV,fs,fs_algo);
    accV40_lpf = filtfilt(Num, 1, RemoveDrift40Hz(accV40));
    accVLPInt=cumtrapz(accV40_lpf)/fs_algo;
    accVLPIntCwt=cwt(accVLPInt,9,'gaus2',1/fs_algo);
    accVLPIntCwt=accVLPIntCwt-mean(accVLPIntCwt);
    accV_processed=resampInterp(accVLPIntCwt,fs_algo,fs);
    
    figure
    plot((1:length(accV_processed)),accV_processed,'b', ICs, accV_processed(ICs),'ro','LineWidth',1.2);
    legend('accV (processed)','Initial Contacts (IC)');
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Utilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = RemoveDrift40Hz(x)
%   s = RemoveDrift40Hz(x)
% Removes gyro's drift using an IIR filter
s = filtfilt([1, -1], [1, -.9748], x);
end
