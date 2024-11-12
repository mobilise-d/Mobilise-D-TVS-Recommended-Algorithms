function rFields=GetFields(data,CurrStructure,rFields)
% Copyright 2023 Center for the Study of Movement, Cognition, and Mobility. Tel Aviv Sourasky Medical Center, Tel Aviv, Israel.
% Licensed under the Apache License, Version 2.0 (the "License"); 
% you may not use this file except in compliance with the License. 
% You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0  
% Unless required by applicable law or agreed to in writing, software 
% distributed under the License is distributed on an "AS IS" BASIS, 
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
% See the License for the specific language governing permissions and
% limitations under the License.

%This function receive a structure and return the fields in a recursive
%process.
%Input:  data = the structure that the function will return it's fields
%        CurrStructure should be initiated as the main structure name (e.g.
%        for the structure "data.Timemeasure1.recording2...", CurrStructure='data'
%        rFields - should be initiated as empty structure {}
%Output: rFields - structure with the fields name

%e.g. GetFields(data,'data',{})
%Will return for the example data:
%rFields =
%  12ª1 cell array
%    {'data.TimeMeasure1.Recording1.SU.LowerBack.Acc'}
%    {'data.TimeMeasure1.Recording1.SU.LowerBack.Gyr'}
%    {'data.TimeMeasure1.Recording1.SU.LowerBack.Fs' }
%    {'data.TimeMeasure1.Recording2.SU.LowerBack.Acc'}
%     ....
warning off;
fields = eval(['fieldnames(' CurrStructure ')']);
for i = 1:numel(fields)
    field = fields{i};
    value = eval(CurrStructure).(field);
    if isstruct(value)
        NewCurrStructure=[CurrStructure '.' field];
        rFields=GetFields(data,NewCurrStructure,rFields);
    else
        rFields{end+1,1}=[CurrStructure '.' field];
    end
end
end

