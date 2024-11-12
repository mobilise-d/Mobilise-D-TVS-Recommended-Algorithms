function[P_L]=Find_Peaks(VEC,th,Plot)
% Copyright 2023 Center for the Study of Movement, Cognition, and Mobility. Tel Aviv Sourasky Medical Center, Tel Aviv, Israel.
% Licensed under the Apache License, Version 2.0 (the "License"); 
% you may not use this file except in compliance with the License. 
% You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0  
% Unless required by applicable law or agreed to in writing, software 
% distributed under the License is distributed on an "AS IS" BASIS, 
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
% See the License for the specific language governing permissions and
% limitations under the License.

%% Fast detction of peaks
%Inputs:
%VEC: Input signal
%th: minimun distance between two close zero crossing points 
%Plot (0=no plot, 1=plot signals and peaks)

P_L=[];
VEC_S=VEC-mean(VEC);    %norm
A=[0 ;VEC_S].*[VEC_S ;0]; %find intersection with zeros (two close signal points with different sign will give negative multiplication result)
[Z,~]=find(A<0);
if length(Z)~=0%Continue only if zero crossing points were detected
    MinDistP=find(([Z ;0]-[0; Z])>th); % min distance between the intersect points
    Bump=Z(MinDistP);
    Bp=Bump(1:2:end);
    DiffBp=[Bp ;0]-[0; Bp]; % detect if the distance between two point is to large (20% then the mean step time, not using the first and last step).
    MissP=find((DiffBp(2:end-1))>1.2*mean(DiffBp(2:end-1)))+1;
    if length(MissP)~=0
        Bn=sort([Bp; Bp(MissP-1)+round((Bp(MissP)-Bp(MissP-1))/2)]);
    else
        Bn=Bp;
    end
 
    L_Bp=length(Bn);

    if L_Bp~=0
        if length(VEC_S)>Bn(end)+2
            Bn=[Bn; length(VEC_S)];
        else
            L_Bp=L_Bp-1;
        end
        DutySycle=Bn(1:2:end);
        %Finding the max points between two valid zero crossing points
        for z=1:L_Bp
            [~,P_l(z)]=max(VEC_S(Bn(z)+1:Bn(z+1)-1));
            P_L(z)=Bn(z)+P_l(z);
        end
        if Plot==1
            figure;plot(VEC_S);hold on;stem(P_L,VEC_S(P_L),'.r');stem(Bn,VEC_S(Bn),'.g')
        end
    else
        P_L=[];
    end
else
    P_L=[];
end
end