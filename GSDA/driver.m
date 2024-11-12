function [status] = driver(indir, outdir)
% Copyright 2023 Center for the Study of Movement, Cognition, and Mobility. Tel Aviv Sourasky Medical Center, Tel Aviv, Israel.
% Licensed under the Apache License, Version 2.0 (the "License"); 
% you may not use this file except in compliance with the License. 
% You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0  
% Unless required by applicable law or agreed to in writing, software 
% distributed under the License is distributed on an "AS IS" BASIS, 
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
% See the License for the specific language governing permissions and
% limitations under the License.

%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Gait sequence detection (GSD) - sine based template
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This work is part of the MOBILISE-D Project (https://www.mobilise-d.eu/)
%
% Author code:  Center for the Study of Movement, Cognition and Mobility (CMCM)
%               Neurological Institute,
%               Tel Aviv Sourasky Medical Center, Tel Aviv, Israel
%               
%               email: CMCM@tlvmc.gov.il
%
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
% This main script detects gait sequences in acceleration signals from
% devices placed on the lower back. The structure of the data and the
% output are detailed in the README.docx that is supplied with the code.
% 
% Exemplary data is provided (data.mat). The gait detection output for this data
% is provided in two possible formats: Matlab (GSD_Output.mat) and Json (GSD_Output.json)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Inputs: 
%Indir: the directory with the data.mat file that contains the walks.
%Outdir: Output directoey for storing the gait detection output
%
%REMARKS:
%1. The script will run on any structure as long as the data's last two fields
%are LowerBack.Acc (e.g. for Mobilise-D: data.TimeMeasure1.Test2.Trial5.SU.LowerBack.Acc)
%The acceleration should contain 3 columns (1=Vertical axis,2=ML axis, 3=AP axis)
%2. Sensor orientation: the vertical axis should provide values around 1[g]
%while standing still. If the sensor provides -1 [g] while standing, then the orientation 
%of the sensor should be flipped prior to using the GSD.

status = 'error';%status will be changed to 'ok' at the end of the driver, after completing the detection algorithm

%Adding library of needed function
Path=path;
LibraryFolder=fullfile(pwd,'Library');
if ~contains(Path,LibraryFolder)
    addpath(LibraryFolder);
end

%Loading the data
%The acceleration is, for example, under the hierarchy: data.TimeMeasure1.Test1.Trial1.SU.LowerBack.Acc
load(fullfile(indir,'data.mat'));%Loading the data
% AllFields=fieldnamesr(data,10);%Reading all fields in the data structure
AllFields=GetFields(data,'data',{});
AllFields=AllFields(find(contains(AllFields,'LowerBack.Acc')));%Searching for the Acc information
AllFields(find(contains(AllFields,'SU_INDIP')))=[];%Removing INDIP information (reference system) if exist.

Trials_list = AllFields;%Contains all the locations in the data with acceleration signal from trails.
GSD_Output=struct();
output_struct = struct();
output_struct_json = struct();
%Going over all the trials
for Trials_list_Index = 1:length(Trials_list)
    %Getting the SU.LowerBack data
    Fields_split=strsplit(AllFields{Trials_list_Index},'.');
    imu=getfield(data,Fields_split{2:end-2});%imu contains under Lowerback the fields: Acc,Gyr and Fs
    gsd_result = GSD_Iluz(imu);
    Fields_split{end}='GSD';%Storing the GSD data in for example: GSD_Output.TimeMeasure1.Test1.Trial1.SU.LowerBack.GSD
    GSD_Output=setfield(GSD_Output,(Fields_split{2:end}),gsd_result);
end

%Saving results
%%%%%%%%%%%%%
%Saving .json file
try
    output_struct_json = struct('GSDA_Output',GSD_Output);
    json_string = jsonencode(output_struct_json);
    filename = 'GSDA_Output.json';
    fid = fopen(fullfile(outdir,filename),'wt');
    fprintf(fid,json_string);
    fclose(fid);
end
try
    %Saving .mat file
    filename = 'GSDA_Output.mat';
    save(fullfile(outdir,filename), 'GSD_Output');
end
status = 'ok';%Finished status will be changed to the error message
