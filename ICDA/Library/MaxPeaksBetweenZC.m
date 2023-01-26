

function [pks, ipks] = MaxPeaksBetweenZC(x)
% peaks and locations from vector x between zero crossings and location
if size(x,1)==1,       error('X must be a column vector'), end
if numel(x)~=length(x),error('X must be a column vector'), end
ix=find(abs(diff(sign(x)))==2)+1;     % zero crossing loc's
L=length(ix)-1;                       % one less peak than x'ings
ipk=accumarray([1:L]',[1:L]',[], @(i) imax(abs(x(ix(i):ix(i+1)-1))) );
ipks=ix(1:L)+ipk-1;                   % max loc in original vector  
pks=x(ipks);                          % and signed max/min value
end

function idx=imax(x)
%  Return max() indices as first argument
    [~,idx]=max(x);
end

