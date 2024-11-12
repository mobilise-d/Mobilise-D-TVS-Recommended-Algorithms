
function [sub]=infocheck(GS)
    warning('off')
    BN = length([GS(:).Start]);
    sub=struct('temp',cell(1,BN));
    
    for i = 1:BN
        subInfo=GS(i).subInfo;
            
        if isfield(subInfo,'height')
            if isempty(subInfo.height) || ~isnumeric(subInfo.height) || any(isnan(subInfo.height)) 
                sub(i).height=170;
                warning('subject height in test is not determined, so it is set to 170 cm')
            else
                sub(i).height=subInfo.height;
            end
                
        else
            sub(i).height=170;
            warning('subject height in test is not determined, so it is set to 170 cm')
        end
        
        if isfield(subInfo,'weight')
            if isempty(subInfo.weight) || ~isnumeric(subInfo.weight) || any(isnan(subInfo.weight)) 
                sub(i).weight=70;
                warning('subject weight is not determined, so it is set to 70 kg')
            else
                sub(i).weight=subInfo.weight;
            end
                
        else
            sub(i).weight=70;
            warning('subject weight is not determined, so it is set to 70 kg')
        end
        
        if isfield(subInfo,'ThighL')    
            if isempty(subInfo.ThighL) || any(isnan(subInfo.ThighL)) || ~isnumeric(subInfo.ThighL)
                sub(i).L1=0.246 * sub(i).height;
            else
                sub(i).L1=subInfo.ThighL;
                warning('Subject ThighL is not determined, so it is set automatically')
          
            end
        else
            sub(i).L1=0.246 * sub(i).height;
            warning('Subject ThighL is not determined, so it is set automatically')
          
        end
        
        if isfield(subInfo,'KneeHeight') 
            if isempty(subInfo.KneeHeight) || any(isnan(subInfo.KneeHeight)) || ~isnumeric(subInfo.KneeHeight)
                sub(i).L2=0.245 * sub(i).height;
            else
                sub(i).L2=subInfo.KneeHeight;
                warning('Subject KneeHeight is not determined, so it is set automatically')
            
            end
        else
            sub(i).L2=0.245 * sub(i).height;
            warning('Subject KneeHeight is not determined, so it is set automatically')
            
        end
        
        if isfield(subInfo,'LBh') 
            if isempty(subInfo.LBh) || any(isnan(subInfo.LBh)) || ~isnumeric(subInfo.LBh)
                sub(i).LBh=(sub(i).L1+sub(i).L2+20)/100;
                warning('subject LBh (height of LB sensor) is not determined, so it is set automatically')
            else
                sub(i).LBh=subInfo.LBh/100;
            end
        else
            sub(i).LBh=(sub(i).L1+sub(i).L2+20)/100;
            warning('Subject LBh (height of LB sensor) is not determined, so it is set automatically')
            
        end

        if isfield(subInfo,'gender') 
            if ~isempty(subInfo.gender) && ~isnumeric(subInfo.gender)
                if strcmp(subInfo.gender,'M') || strcmp(subInfo.gender,'F')
                    sub(i).gender=subInfo.gender;
                else
                    sub(i).gender='M';
                    warning('subject gender is not determined, so it is set to M')
                end
            else
                sub(i).gender='M';
                warning('subject gender is not determined, so it is set to M')
            end
        else
            sub(i).gender='M';
            warning('subject gender is not determined, so it is set to M')
        end       
                 
        if isfield(subInfo,'age') 
            if isempty(subInfo.age) || any(isnan(subInfo.age)) ||  ~isnumeric(subInfo.age)
                sub(i).age=30;
                warning('subject age is not determined, so it is set to 30')
            else
                sub(i).age=subInfo.age;
            end
        else
            sub(i).age=30;
            warning('subject age is not determined, so it is set to 30')
            
        end
        
        if isfield(subInfo,'footSize')
            if isempty(subInfo.footSize) || any(isnan(subInfo.footSize)) || ~isnumeric(subInfo.footSize)
                sub(i).footSize=28;
                warning('subject foot size is not determined, so it is set to 28')
            else
                sub(i).footSize=subInfo.footSize;
            end  
        else
            sub(i).footSize=28;
            warning('subject foot size is not determined, so it is set to 28')
           
        end
    end
end