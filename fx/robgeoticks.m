function t = robgeoticks(center_lon,int_lon,int_lat)

grid off

% Defaults:
if ~exist('center_lon','var');  center_lon = 0; end
if ~exist('int_lon','var');     int_lon = 60;   end
if ~exist('int_lat','var');     int_lat = 30;   end

% Font specifications:
font_size = get(gca,'FontSize');
font_name = get(gca,'FontName');

% Grid line specifications:
grid_alpha = 0.1;
grid_style = '-';

cc = 1; % counter for text labels

% Plot meridians (constant longitude)
lons = 0:int_lon:180;
lons = [-flip(lons(2:end)) lons];
lats = -90:.1:90;

for i = 1:numel(lons)
    
    lat = lats;
    lon = ones(size(lats)) .* lons(i);
    
    [lon,lat] = ll2rob(lon,lat);
    
    % Plot
    p = plot(lon,lat,grid_style,'LineWidth',0.5);
    p.Color = [.15,.15,.15,grid_alpha];
    
    % Determine xtick labels:
    if lons(i) < 0
        degr = [num2str(abs(lons(i))) char(176) 'W'];
    elseif lons(i) == 0
        degr = [num2str(abs(lons(i)))  char(176)];
    elseif lons(i) > 0
        degr = [num2str(abs(lons(i)))  char(176) 'E'];
    end
    
    % Text with labels:
    t(cc) = text(lon(1),lat(1),degr,'VerticalAlignment','top','HorizontalAlignment','center');
    
    cc = cc + 1;
end

% Plot parallels (constant latitude)
lons = -180:0.1:180;
lats = 0:int_lat:89.999;
lats = [-flip(lats(2:end)) lats];

for i = 1:numel(lats)
    
    lon = lons;
    lat = ones(size(lons)) .* lats(i);
    
    [lon,lat] = ll2rob(lon,lat);
    
    % Plot
    p = plot(lon,lat,grid_style,'LineWidth',0.5);
    p.Color = [.15,.15,.15,grid_alpha];
    
    % Determine ytick labels:
    if lats(i) < 0
        degr = [num2str(abs(lats(i))) char(176) 'S'];
    elseif lats(i) == 0
        degr = [num2str(abs(lats(i)))  char(176)];
    elseif lats(i) > 0
        degr = [num2str(abs(lats(i)))  char(176) 'N'];
    end
    
    % Text with labels:
    offx = double(diff(xlim) * abs(lat(1)) * 0.012 / 60);
    t(cc) = text(lon(1)-offx,lat(1),degr,'VerticalAlignment','middle','HorizontalAlignment','right');
    
    cc = cc + 1;
end

set(t,'FontName',font_name,'FontSize',font_size)
set(gca,'XColor','none','YColor','none','TickLength',[0 0])






