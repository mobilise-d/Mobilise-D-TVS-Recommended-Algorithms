function gait_sequences = save_gsd_result(walking_bool_vector, algorithm_output_fs)
% save_gsd_result    
% saves the gait sequence detection result accoring to
% MOBILISE-D requiremnents
%
% gait_sequences = save_gsd_result(walking_bool_vector,
% algorithm_output_fs) Takes a boolean vector walking_bool_vector with
% 1==walking and 0==non-walking and saves it into gait_sequences with
% start and end points of walking sequences in seconds, using the sampling
% rate of the algorithm algorithm_output_fs

if unique(walking_bool_vector) == 0
    gait_sequences.GaitSequence_Start = nan;
    gait_sequences.GaitSequence_End=nan;
    gait_sequences.GSD_fs = algorithm_output_fs;
else
    
    % transpose walking_bool_vector to row vector if applicable
    if size(walking_bool_vector,1) < size(walking_bool_vector,2)
        walking_bool_vector = walking_bool_vector';
    end
    
    % convert to standardized output
    walking_label_borders = diff(walking_bool_vector);
    walking_start_points = find(walking_label_borders == 1)/algorithm_output_fs;
    walking_end_points = find(walking_label_borders == -1)/algorithm_output_fs;
    
    % if recording starts with walking, add 1 to walking_start_points
    if walking_bool_vector(1) == 1
        walking_start_points = [0; walking_start_points];
    end
    
    % if recording ends with walking, add last sample to walking_end_points
    if walking_bool_vector(end) == 1
        walking_end_points = [walking_end_points; length(walking_bool_vector)/algorithm_output_fs];
    end
    
    % save results to subject individual struct
    gait_sequences = struct('GaitSequence_Start',[],'GaitSequence_End',[],'GSD_fs',[]);
    
    if isempty(walking_end_points)
        gait_sequences(1).GSD_fs = algorithm_output_fs;
    end
    
    % reformat to output struct
    for gs = 1:length(walking_end_points)
        gait_sequences(gs).GaitSequence_Start = walking_start_points(gs);
        gait_sequences(gs).GaitSequence_End = walking_end_points(gs);
        gait_sequences(gs).GSD_fs = algorithm_output_fs;
    end
end