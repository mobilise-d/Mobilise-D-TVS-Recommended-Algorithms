 function [t,s]=zerocros(y,m,x)
 %V_ZEROCROS finds the zeros crossings in a signal [T,S]=(Y,M,X)
 % Inputs:  y = input waveform
 %          m = mode string containing:
 %              'p' - positive crossings only
 %              'n' - negative crossings only
 %              'b' - both (default)
 %              'r' - round to sample values
 %          x = x-axis values corresponding to y [default 1:length(y)]
 %
 % Outputs: t = x-axis positions of zero crossings
 %          s = estimated slope of y at the zero crossing
 %
 % This routine uses linear interpolation to estimate the position of a zero crossing
 % A zero crossing occurs between y(n) and y(n+1) iff (y(n)>=0) ~= (y(n+1)>=0)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 if nargin<2 || ~numel(m)
     m='b';
 end
 s=y>=0;
 k=s(2:end)-s(1:end-1);
 if any(m=='p')
     f=find(k>0);
 elseif any(m=='n')
     f=find(k<0);
 else
     f=find(k~=0);
 end
 s=y(f+1)-y(f);
 t=f-y(f)./s;
 if any(m=='r')
     t=round(t);
 end
 if nargin>2
     tf=t-f; % fractional sample
     t=x(f).*(1-tf)+x(f+1).*tf;
     s=s./(x(f+1)-x(f));
 end
 if ~nargout
     n=length(y);
     if nargin>2
         plot(x,y,'-b',t,zeros(length(t),1),'or');
     else
         plot(1:n,y,'-b',t,zeros(length(t),1),'or');
     end
     v_axisenlarge([-1 -1.05]);
 end