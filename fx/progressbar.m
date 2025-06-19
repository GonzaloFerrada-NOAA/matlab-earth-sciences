function progressbar(currentindex,totalindex)
    % progressbar(currentindex,totalindex)
    
    
    increment   = 100 * [1:totalindex] ./ totalindex;
    
    if currentindex == 1
        
        disp(char(32))
        fprintf('            10%%       20%%       30%%       40%%       50%%       60%%       70%%       80%%       90%%       100%%\n')
        fprintf('    ')
        for i = 1:round(increment(currentindex))
            fprintf('=')
        end
        
    elseif currentindex > 1 & currentindex ~= totalindex
        
        % for i = currentindex:round(increment(currentindex))
        for i = 1:round(increment(currentindex))-round(increment(currentindex-1))
            fprintf('=')
        end
        
    elseif currentindex == totalindex
        
        % for i = currentindex:round(increment(currentindex))
        for i = 1:ceil(increment(currentindex))-round(increment(currentindex-1))
            fprintf('=')
        end
        
        fprintf(' completed!\n')
        disp(char(32))
    end
    
        
end
