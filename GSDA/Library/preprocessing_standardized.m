function imu_preprocessed = preprocessing_standardized(IMU,algorithm_target_fs)

Acc = IMU.LowerBack.Acc;
Gyr = IMU.LowerBack.Gyr;
data_fs.Acc = IMU.LowerBack.Fs.Acc;

if algorithm_target_fs~=data_fs.Acc
    % resample data to algorithm_target_fs
    acc_resampled = resample(Acc,algorithm_target_fs*10,data_fs.Acc*10); % mulitply by ten to avoid float point numbers
    gyr_resampled = resample(Gyr,algorithm_target_fs*10,data_fs.Acc*10); % mulitply by ten to avoid float point numbers
    % wrap up to one imu matrix and return
    imu_preprocessed = [acc_resampled gyr_resampled];
else
    imu_preprocessed = [Acc Gyr];
end
end

