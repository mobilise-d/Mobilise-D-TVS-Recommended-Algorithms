function GSD = GSD_Iluz(imu)
% Copyright 2023 Center for the Study of Movement, Cognition, and Mobility. Tel Aviv Sourasky Medical Center, Tel Aviv, Israel.
% Licensed under the Apache License, Version 2.0 (the "License"); 
% you may not use this file except in compliance with the License. 
% You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0  
% Unless required by applicable law or agreed to in writing, software 
% distributed under the License is distributed on an "AS IS" BASIS, 
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
% See the License for the specific language governing permissions and
% limitations under the License.

plot_results = false; %true = plot gait detection output, false = no plot is provided

% sampling rate the algorithm is expecting
algorithm_target_fs = 100;
algorithm_output_fs = 100;

% Setting parameters
WinS=algorithm_target_fs*3; %window size
OL=WinS/2; %overlap of 50%
activity_thresh=0.01;%threshold for non activity

% preprocessing of imu data (making sure the sample frequency is 100Hz)
imu_preprocessed = preprocessing_standardized(imu,algorithm_target_fs);

% apply the GSD algorithm
try
    gait_sequences_bool = WBDet_Sine(imu_preprocessed,algorithm_target_fs,WinS,OL,activity_thresh,plot_results);
    % reformat the GSD result to json format and save it
    GSD = save_gsd_result(gait_sequences_bool,algorithm_output_fs);
catch
    warning('GSD algorithm did not run successfully. Writing empty result to output')
    GSD = [];
end
end
