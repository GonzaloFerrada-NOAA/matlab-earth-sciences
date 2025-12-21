function  geoticks(ax, lon_spacement, lat_spacement, projection, origin)
    
    % Defaults:
    if ~exist('ax','var'); ax = gca; else ax = ax(:); end
    if ~exist('lon_spacement','var'); origin = 10; end
    if ~exist('lat_spacement','var'); origin = 10; end
    if ~exist('projection','var'); projection = 0; end % latlon
    if projection == 2
        if ~exist('origin','var')
            error('Origin argument must be passed if projection is Lambert.')
        else
            if length(origin) == 2
                origin = [origin(1) origin(1) origin(1) origin(2)];
            elseif length(origin) ~= 2 | length(origin) ~= 4
                error('Origin must have 2 or 4 elements for Lambert projection.')
            end
        end
    end
    
    % Grid line specifications:
    gridopt.alpha = 0.5;
    gridopt.style = '-';
    
    % Determine initial ticks:
    lon_ticks0 = -180:lon_spacement:180;
    lat_ticks0 =  -90:lat_spacement:90;
    
    % Loop through each axes:
    for i = 1:numel(ax)
    
        % Get current gca axis limits:
        xl = ax.XLim;
        yl = ax.YLim;
        
        % Determine ticks and labels:
        if projection == 0 % latlon
            % if lat lon we just set the intial ticks and we do not 
            % plot grid lines - if the user desires this can do "grid on"
            lon_ticks = lon_ticks0;
            lat_ticks = lat_ticks0;
            lon_labels = geoticklabels(lon_ticks, 'lon');
            lat_labels = geoticklabels(lat_ticks, 'lat');
            p = [];
            
        elseif projection == 1 % Robinson
            % For Robinson, the user input for lon_ and lat_spacement is
            % ignored, since Robinson plots are always global.
            axis tight
            lon_ticks = -120:60:120;
            lat_ticks = -60:30:60;
            lon_labels = geoticklabels(lon_ticks, 'lon');
            lat_labels = geoticklabels(lat_ticks, 'lat');
            
            plotgridlines(lon_ticks, lat_ticks, gridopt, 1)
            
            % Determine where in the plot X and Y axis these ticks cross,
            % i.e., the actual ticks in the plot box:
            [lon_ticks, lat_ticks] = ll2rob(lon_ticks, lat_ticks)
            
        elseif projection == 2 % Lambert
            
            lon_ticks = lon_ticks0;
            lat_ticks = -80:lat_spacement:80;
            lon_labels = geoticklabels(lon_ticks, 'lon');
            lat_labels = geoticklabels(lat_ticks, 'lat');
            
            p = plotgridlines(lon_ticks, lat_ticks, gridopt, 2, origin);
            
            % Determine where in the plot X and Y axis these ticks cross,
            % i.e., the actual ticks in the plot box:
            % for i = 1:numel
            [lon_ticks, lat_ticks] = ll2lamb(origin, lon_ticks, lat_ticks)
            
        end
        
        set(ax, 'XTick', lon_ticks/2, 'YTick', lat_ticks)
        % set(ax, 'XTickLabel', lon_labels, 'YTickLabel', lat_labels)
        
    end % i ax
    
    
    % if nargout == 1
    %     gridlines = p;
    % end

    
end





function p = plotgridlines(lon, lat, opt, proj, ps)
    
    c = [.15, .15, .15, opt.alpha];
    k = 1;
    % Meridians:
    for i = 1:numel(lon)
        y = linspace(min(lat), max(lat), 100);
        x = ones(size(y)) .* lon(i);
        if proj == 1
            [x,y] = ll2rob(x, y);
        elseif proj == 2
            [x,y] = ll2lamb(ps, x, y);
        end
        p(k) = plot(x, y, opt.style, 'Color', c);
        k = k + 1;
    end
    % Parallels:
    for i = 1:numel(lat)
        x = linspace(min(lon), max(lon), 100);
        y = ones(size(x)) .* lat(i);
        if proj == 1
            [x,y] = ll2rob(x, y);
        elseif proj == 2
            [x,y] = ll2lamb(ps, x, y);
        end
        p(k) = plot(x, y, opt.style, 'Color', c);
        k = k + 1;
    end
end


function labels = geoticklabels(ticks, opt)
    
    switch opt
        case 'lon'
            for i = 1:numel(ticks)
                if ticks(i) < 0
                    labels{i} = [num2str(abs(ticks(i))) char(176) 'W'];
                elseif ticks(i) > 0
                    labels{i} = [num2str(abs(ticks(i))) char(176) 'E'];
                elseif ticks(i) == 0
                    labels{i} = [num2str(abs(ticks(i))) char(176)];
                end
            end
        
        case 'lat'
            for i = 1:numel(ticks)
                if ticks(i) < 0
                    labels{i} = [num2str(abs(ticks(i))) char(176) 'S'];
                elseif ticks(i) > 0
                    labels{i} = [num2str(abs(ticks(i))) char(176) 'N'];
                elseif ticks(i) == 0
                    labels{i} = [num2str(abs(ticks(i))) char(176)];
                end
            end
    end
end 

