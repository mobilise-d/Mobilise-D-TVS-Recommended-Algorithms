
function [cadSec]=cadsteps2sec(cadgait,ICtime,duration)
  
        N=floor(duration);
        winstart=[1:N]-0.5;
        winstop=[1:N]+0.5;
       
        cadSec=zeros(N,1);
        
        for j=1:1
            for i=1:N
                if winstop(i) < ICtime(1)
                    cadSec(i,j)=-1;
                elseif winstart(i) > ICtime(end)
                    cadSec(i,j)=-2;
                else
                    ind=(winstart(i) <= ICtime) & (ICtime <= winstop(i));
                    if sum (ind)==0
                        inx= winstart(i) >= ICtime;
                        aa=cadgait(logical(abs([diff(inx); 0])),j);

                        iny=ICtime >= winstop(i);
                        bb=cadgait(logical(abs([0 ;diff(iny)])),j);
                        cadSec(i,j)=(aa+bb)/2;
                    else
                        cadSec(i,j)=nanmean(cadgait(ind,j));
                    end
                end
            end
        end
        
        myInx=cadSec(:,1)==-1;
        tempax=1:N;
        tempax2=tempax(~myInx);
        
        cadSec(myInx,1)=cadSec(tempax2(1),1);
        
        myInd=cadSec(:,1)==-2;
        tempax3=tempax(~myInd);
        cadSec(myInd,1)=cadSec(tempax3(end),1);  
        
        cadSec=hampel(cadSec,2);        
end