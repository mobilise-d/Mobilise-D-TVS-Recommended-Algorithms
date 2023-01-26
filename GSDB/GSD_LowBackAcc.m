function GSD_Output = GSD_LowBackAcc(imu_acc, fs, plot_results)
% 
% Inputs:
% imu_acc: 3D acceleration signal
%   imu_acc(:,1) : Vertical 
%   imu_acc(:,2) : Medio-lateral
%   imu_acc(:,3) : Antero-Posterior
% fs:  sampling frequency 
% plot_results: make it 1 if you want a plot and 0 when you dont want a plot

%Outputs:
% GSD_Output: structure containing the Start and End of each detected gait
% sequence

%References:
%[1] Paraschiv-Ionescu, A.  et al.
%"Locomotion and cadence detection using a single trunk-fixed accelerometer:
%validity for children with cerebral palsy in daily life-like conditions." JNER 16.1 (2019): 1-11.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GSD_Output=struct();
acc = imu_acc;
algorithm_target_fs=40;

accN=sqrt(acc(:,1).^2+acc(:,2).^2+acc(:,3).^2);

%resample from fs to algorithm_target_fs
accN40=resampInterp(accN,fs,algorithm_target_fs);

%filter designed for low SNR, impaired, asymmetric and slow gait
load FIR-2-3Hz-40;

%Apply various filters to enhance the aceleration signal
% when low SNR, impaired, asymmetric and slow gait
accN_filt1=sgolayfilt(accN40,7,21);
accN_filt2 = filtfilt(Num, 1, RemoveDrift40Hz(accN_filt1));
accN_filt3=cwt(accN_filt2,10,'gaus2',1/40);
accN_filt4=sgolayfilt(accN_filt3,5,11);
accN_filt5=cwt(accN_filt4,10,'gaus2',1/40);
accN_filt6=smoothdata(accN_filt5,'gaussian',10);
accN_filt7=smoothdata(accN_filt6,'gaussian',10);
accN_filt8=smoothdata(accN_filt7,'gaussian',15);
accN_filt9=smoothdata(accN_filt8,'gaussian',10);

sigDetActv=accN_filt9;

%find pre-detection of 'active' periods in order to estimate the amplitude
%of acceleration peaks
alarm=[];
[alarm,~] = hilbert_envelop(sigDetActv,round(algorithm_target_fs),1,round(algorithm_target_fs),0);
walkLowBack=0;
if ~isempty(alarm)
    idx=groupfind(alarm>0);
    for j=1:length(idx(:,1))
        if idx(j,2)-idx(j,1)<=3*algorithm_target_fs
            alarm(idx(j,1):idx(j,2))=0;
        else
            walkLowBack=[walkLowBack sigDetActv(idx(j,1):idx(j,2))];
        end
    end
    pksp = findpeaks((walkLowBack));
    pksn = findpeaks((-walkLowBack));
    pks=[pksp(find(pksp>0)) pksn(find(pksn>0))];
    
    th=prctile(pks,5);  %data adaptive threshold
    f=sigDetActv';
else
    th=0.15;        % if hilbert envelope fails to detect 'active' try version [1]
    f=accN_filt4';
end
%mid-swing detection
[MinPeaks, MaxPeaks] = FindMinMax(f, th);

d = diff(MaxPeaks);
t1 = FindPulseTrains(MaxPeaks);
t1([t1.steps] < 4) = [];

d = diff(MinPeaks);
t2 = FindPulseTrains(MinPeaks);
t2([t2.steps] < 4) = [];

t_final = Intersect(ConvertWtoSet(t1), ConvertWtoSet(t2));


if isempty(t_final)
    w = [];
    MidSwing = [];
else
    [w,MidSwing] = PackResults(t_final, MaxPeaks);
    
    if ~isempty(w)
        w(1).start = max([1, w(1).start]);
        w(end).end = min([w(end).end max(size(sigDetActv))]);
    end
end

n=max(size(w));
w_new = [];
k=0;
for j=1:n
    if w(j).steps>=5
        k=k+1;
        w_new(k).start=w(j).start;
        w_new(k).end=w(j).end;
    end
end

walkLabel=zeros(1,length(sigDetActv));
n=max(size(w_new));
for j=1:n
    walkLabel(w_new(j).start:w_new(j).end)=1;
end

%merge walking bouts if break less than 3 seconds
ind_noWk=[];
ind_noWk=groupfind(walkLabel==0);
if ~isempty(ind_noWk)
    for j=1:length(ind_noWk(:,1))
        if ind_noWk(j,2)-ind_noWk(j,1)<=algorithm_target_fs*3
            walkLabel(ind_noWk(j,1):ind_noWk(j,2))=1;
        end
    end
end

ind_Wk=[];
if find(walkLabel==1)
    ind_Wk=groupfind(walkLabel==1);
    if ~isempty(ind_Wk)
        for j=1:length(ind_Wk(:,1))
            walk(j).start = ind_Wk(j,1);
            walk(j).end = ind_Wk(j,2);  
        end
    end

    n=max(size(walk));
    for j=1:n
        GSD_Output(j).Start=walk(j).start/algorithm_target_fs;
        GSD_Output(j).End=walk(j).end/algorithm_target_fs;
        GSD_Output(j).fs=fs;
    end
else
    fprintf('No gait sequence(s) detected\n');
end

% plot results if set to true
if plot_results
    figure;
    plot(sigDetActv)
    hold on
    plot(walkLabel,'r','LineWidth',2)
    legend('filtered accNorm','Walking')
    xlabel('samples(40Hz)')
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------
% Algorithm library
%----------------------------------------
function [w,MidSwing] = PackResults(periods, peaks)
n = length(periods);
w = struct('start', num2cell(periods(:,1)), 'end', num2cell(periods(:,2)), ...
    'steps', num2cell(zeros(n,1)), 'MidSwing', cell(n,1));
MidSwing = [];
for i=1:n
    steps = peaks(peaks >= w(i).start & peaks <= w(i).end);
    w(i).steps = length(steps);
    w(i).MidSwing = steps;
    MidSwing = [MidSwing; steps];
    
    %increase the duration of reported walking periods by half a step_time
    %before the first and after the last step
    if length(steps) > 2
        step_time = mean(diff(steps));
        w(i).start = fix(w(i).start - 1.5*step_time/2);
        w(i).end = fix(w(i).end + 1.5*step_time / 2);
    end
end
MidSwing = sort(MidSwing);

% check to see if any two consecutive detected walking periods are
% overlapped; if yes, join them. (This should not normally happen though!)
i = 1;
while i < n
    if w(i).end >= w(i+1).start
        w(i).end = w(i+1).end;
        w(i).steps = w(i).steps + w(i+1).steps;
        w(i).MidSwing = [w(i).MidSwing ; w(i+1).MidSwing];
        w(i+1) = [];
        n = n - 1;
    else
        i = i + 1;
    end
end
end


%----------------------------------------
function w = FindPulseTrains(x)
w = [];
walkflag = 0;
THD = 3.5 * 40;
n = 1;

if length(x) > 2
    for i=1:length(x)-1
        if x(i+1) - x(i) < THD
            if walkflag == 0
                w(n).start = x(i);
                w(n).steps = 1;
                walkflag = 1;
            else
                w(n).steps = w(n).steps + 1;
                THD = 1.5*40 + (x(i) - w(n).start)/w(n).steps;
            end
        else
            if walkflag == 1
                w(n).end = x(i-1);
                n = n + 1;
                walkflag = 0;
                THD = 3.5 * 40;
            end
        end
    end
end

if walkflag == 1
    if x(end) - x(end-1) < THD
        w(end).end = x(end);
        w(n).steps = w(n).steps + 1;
    else
        w(end).end = x(end-1);
    end
end
end


%----------------------------------------
function s = ConvertWtoSet(w)

s = zeros(length(w),2);
s(:,1) = [w.start];
s(:,2) = [w.end];
end


%----------------------------------------
function c = Intersect(a, b)
na = size(a, 1);
nb = size(b, 1);

c = [];

if na == 0 || nb == 0
    return
end

k = 1;
ia = 1;
ib = 1;
state = 3;

while ia <= na && ib <= nb
    switch state
        case 1
            if a(ia, 2) < b(ib, 1)
                ia = ia + 1;
                state = 3;
            elseif a(ia,2) < b(ib, 2)
                c(k,1) = b(ib, 1);
                c(k,2) = a(ia, 2);
                k = k + 1;
                ia = ia + 1;
                state = 2;
            else
                c(k, :) = b(ib, :);
                k = k + 1;
                ib = ib + 1;
            end
        case 2
            if b(ib, 2) < a(ia, 1)
                ib = ib + 1;
                state = 3;
            elseif b(ib,2) < a(ia, 2)
                c(k,1) = a(ia, 1);
                c(k,2) = b(ib, 2);
                k = k + 1;
                ib = ib + 1;
                state = 1;
            else
                c(k, :) = a(ia, :);
                k = k + 1;
                ia = ia + 1;
            end
        case 3
            if a(ia, 1) < b(ib, 1)
                state = 1;
            else
                state = 2;
            end
    end
end
end

%---------------------------------------
function [mi, ma] = FindMinMax(s, thr)
d = diff(s);
f = find( d(2:end) .* d(1:end-1) <= 0);
f = f + 1;

mi = f(d(f)>=0);
ma = f(d(f)<0);

if nargin == 2
    ma = ma(s(ma) > thr);
    mi = mi(s(mi) < -thr);
end
end


%------------------------------------------------
function s = RemoveDrift40Hz(x)
%   s = RemoveDrift40Hz(x)
% Removes drift using an IIR filter
s = filtfilt([1, -1], [1, -.9748], x);
end


%--------------------------------------------------
function a = amp(x)
[m, n] = size(x);

s = zeros(m,1);
for i=1:n
    s = s + x(:,i).^2;
end

a = sqrt(s);
end




