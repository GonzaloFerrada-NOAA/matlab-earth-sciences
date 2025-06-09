function [lon_lambert,lat_lambert] = ll2lamb(proj_specs,data_lon,data_lat)
    %
    % Usage:
    %
    % [lon_lambert,lat_lambert] = ll2lamb(proj_specs,data_lon,data_lat)
    %
    % Converts latitudes and longitudes to lambert projection with constants specified in proj_specs.
    % Author: Gonzalo A. Ferrada (gonzalo-ferrada@uiowa.edu)
    %
    % proj_specs  : [TRUELAT1,TRUELAT2,CEN_LAT,CEN_LON] == [first_parallel,second_parallel,central_lat,central_lon];
    
    if numel(proj_specs) == 2
        proj_specs = [proj_specs(1) proj_specs(1) proj_specs(1) proj_specs(2)];
    end
    
    truelat1 = proj_specs(1);
    truelat2 = proj_specs(2);
    
    if truelat1 == truelat2; truelat1 = truelat1 + 1e-5; truelat2 = truelat2 - 1e-5; end
    % lamb = Lambert([truelat1,truelat2],proj_specs(3),proj_specs(4),400000,400000,6377397.15500000,299.152815351328);
    % lamb = Lambert([truelat1,truelat2],proj_specs(3),proj_specs(4),400,400,6377.39715500000,299.152815351328);
    lamb = Lambert([truelat1,truelat2],proj_specs(3),proj_specs(4),0,0,6377.39715500000,299.152815351328);
    
    [lon_lambert,lat_lambert] = lamb.geographic2cartesian(data_lat,data_lon);
end