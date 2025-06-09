function [lonm,latm] = ll2mer(lon,lat,center_lon)
    
    if ~exist('center_lon','var'); center_lon = 0;end
    if center_lon ~= 0
        warning('Shifting the origin meridian is not implemented yet.')
    end
        
    R =  6370; % Earth radius in km
    
    % if center_lon > 0
    %
    %     % % c = 1;
    %     % lon2 = [];
    %     % for i = 1:numel(lon)-1
    %     %
    %     %     if lon(i) < center_lon & lon(i+1) > center_lon
    %     %
    %     %         lon2 = [lon2 NaN lon]
    %     %
    %     %     elseif| (lon(i) > center_lon & lon(i+1) < center_lon)
    %     %         lon2 = [lon2  ]
    %     %     else
    %     %         lon2 = [lon2 lon(i)];
    %     %     end
    %     %
    %     %
    %     % end
    %     %
    %     %
    %     %
    %     %
    %     %
    %     %
    %     % % lon(lon == center_lon)    = NaN;
    %     % %
    %     % % for i = 1:numel(lon)-1
    %     % %     if (lon(i) < center_lon & lon(i+1) > center_lon) | (lon(i) > center_lon & lon(i+1) < center_lon)
    %     % %
    %     % %         lon2
    %     % %
    %     % %     end
    %     % % end
    %     %
    %     % % size1       = size(lon)
    %     % % lon         = lon(:);
    %     %
    %     % idx         = lon < -180 + center_lon;
    %     % lon         = [lon; NaN; lon(idx) + 180 + center_lon];
    %     % lat         = [lat; NaN; lat(idx)];
    %     %
    %
    %     % idx         = lon < -180 + center_lon;
    %     % lon(idx)    = lon(idx) + 360 ;
    % end
    
    
    lonm = (pi * R / 180 ) .* (lon - center_lon);
    % lonm = (pi * R / 180 ) .* lon;
    latm = R .* log( tand( 45 + (lat ./2 )) );
    
    
    
end
