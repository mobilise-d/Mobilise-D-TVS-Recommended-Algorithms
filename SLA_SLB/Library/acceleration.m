function a = acceleration(IMU, q)

% N=size(q,1);
% 
% a=zeros(N,3);
% accdata=IMU(:,1:3);

% for i = 1:N
%     
%     a(i,:) = quaterot(q(i,:),accdata(i,:));
%     
% end
% 


a = quatrotate(quatconj(q),IMU(:,1:3));
% a(:,3) = a(:,3) - 1;
stopsamp=200;
if stopsamp > size(a,1)
    stopsamp=size(a,1);
end
gr = mean(a(1:stopsamp,3));
a(:,3) = a(:,3) - gr;
% figure;plot(a)

end

% function qr = quaterot(q,r)
% qr = quatmultiply(q,quatmultiply([0 r],quatconj(q)));
% qr = qr(2:4)';
% end
