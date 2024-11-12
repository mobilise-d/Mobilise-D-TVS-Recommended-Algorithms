
function yResamp=resampInterp(y,fs_initial,fs_final)
%resampling using interpolation from fs_initial to fs_final
    recordingTime=length(y);
    x=(1:1:recordingTime)';
    xq = (1:(fs_initial/fs_final):recordingTime)';
    yResamp=interp1(x,y',xq);
end