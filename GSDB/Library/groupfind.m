function ind=groupfind(L)
%GROUPFIND   Find upper and lower indices of nonzero groups
%            with vectorized and simple code.
%   I = GROUPFIND(X) returns an N-by-2 matrix where N is the
%   number of groups, the first column gives the index where
%   each group starts, and the second column gives the index
%   where each group ends.  A group is a stretch of consecutive
%   nonzero values.
temp=find(L(:));           % make input a column vector, then find nonzeros
idx=find(diff(temp)>1);    % call find(diff(temp)>1) just once, not twice
ind(:,2)=temp([idx; end]); % create 2nd column first to allocate all memory
ind(:,1)=temp([1; idx+1]); %  needed for output once, not twice.
end
