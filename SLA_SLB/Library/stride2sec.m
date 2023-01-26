


function [stSec]=stride2sec(ICtime,duration,stl)

    if length(ICtime) > 1
%         figure;
%         plot(av_filt8)
%         hold on
%         plot(2*IC_orig,av_filt8(2*IC_orig),'o')
%         xticks(totalMoments2)
%         grid on

        if size(ICtime,1) < size(ICtime,2)
            ICtime=ICtime';
        end
        
        if size(stl,1) < size(stl,2)
            stl=stl';
        end
        
        if length(stl)<length(ICtime)
            stl=[stl;repmat(stl(end),length(ICtime)-length(stl),1)];
        end
        
        
        
        remInx=isnan(stl) | isnan(ICtime);
        
        stl(remInx)   =[];
        ICtime(remInx)=[];
        
        
        stl=hampel(stl,2);
        

        
        N=floor(duration);
        winstart=[1:N]-0.5;
        winstop=[1:N]+0.5;
       
        stSec=zeros(N,1);
        

        for i=1:N
            if winstop(i) < ICtime(1)
                stSec(i)=-1;
            elseif winstart(i) > ICtime(end)
                stSec(i)=-2;
            else
                ind=(winstart(i) <= ICtime) & (ICtime <= winstop(i));
                if sum (ind)==0
                    inx= winstart(i) >= ICtime;
                    aa=stl(logical(abs([diff(inx); 0])));

                    iny=ICtime >= winstop(i);
                    bb=stl(logical(abs([0 ;diff(iny)])));
                    stSec(i)=(aa+bb)/2;
                else
                    stSec(i)=nanmean(stl(ind));

                end
            end
        end

        
        myInx=stSec(:,1)==-1;
        tempax=1:N;
        tempax2=tempax(~myInx);
        
        stSec(myInx,1)=stSec(tempax2(1),1);
        
        myInd=stSec(:,1)==-2;
        tempax3=tempax(~myInd);
        stSec(myInd,1)=stSec(tempax3(end),1);  
        
        stSec=hampel(stSec,2);
        
    else
        stSec=NaN;
    end
    
    if length(stSec) < duration
        stSec = [stSec; repmat(stSec(end),duration-length(stSec),1)];
    elseif length(stSec) > duration
        stSec = stSec(1:duration);
    end
        
        
%         figure;
%         stem(ICtime,cadgait)
%         hold on
%         stem([1:N],cadSec)
        
        
        
end