% function var_out = get_cams_variable(file,var_id)
%
% This function will read a variable from a CAMS output and reorganize the long

function var_out = get_cams_variable(file,var_id,i_start,i_count)
    
    % Check Longitude and Latidude:
    out_st  = check_var_netcdf(file,'lon');
    if out_st == 1; 
        lon = ncread(file,'lon');
        lat = ncread(file,'lat');
    else
        lon = ncread(file,'longitude');
        lat = ncread(file,'latitude');
    end
    
    % Fix longitude from 0-360 to -180-+180
    lon     = mod((lon+180),360)-180;
    idx_lon = lon < 0;
    lon     = [lon(idx_lon);lon(~idx_lon)];
    
    [lon2,lat2] = ndgrid(lon,lat);
    
    % get variables:
    switch var_id
    case 'lon'
        var_out = lon2;
    case 'lat'
        var_out = lat2;
    case {'pressure','pres','p'}
        hyam = ncread(file,'hyam');
        hybm = ncread(file,'hybm');
        p0   = double(ncread(file,'P0')); % Pa
        ps   = ncread(file,'PS');         % Pa
        for i = 1:numel(hybm)
            var_aux(:,:,i,:) = hyam(i) * p0 + ps .* hybm(i);
        end
        var_out = [var_aux(idx_lon,:,:,:);  var_aux(~idx_lon,:,:,:)]; % Pa
    case {'rho','dens','density'}
        hyam = ncread(file,'hyam');
        hybm = ncread(file,'hybm');
        temp = ncread(file,'T');          % K
        p0   = double(ncread(file,'P0')); % Pa
        ps   = ncread(file,'PS');         % Pa
        for i = 1:numel(hybm)
            pressure(:,:,i,:) = hyam(i) * p0 + ps .* hybm(i); % Pa
        end
        var_aux  = (28.9645 * pressure)./ (1000 * 8.314472 * temp);     % kg/m3
        var_out = [var_aux(idx_lon,:,:,:);  var_aux(~idx_lon,:,:,:)]; % kg/m3
    case {'height','h','alt','z'}
        hyam = ncread(file,'hyam');
        hybm = ncread(file,'hybm');
        temp = ncread(file,'T');          % K
        q    = ncread(file,'Q');          % kg/kg
        p0   = double(ncread(file,'P0')); % Pa
        ps   = ncread(file,'PS');         % Pa
        Tv   = temp .* (1 + 0.61 .* q);   % K
        zi   = ncread(file,'PHIS') ./ 9.80665; % m
        for i = 1:numel(hybm)
            pressure(:,:,i,:) = hyam(i) * p0 + ps .* hybm(i); % Pa
        end
        pressure(:,:,i+1,:) = ps;
        % Hypsometric equation:
        for i = 1:numel(hybm)
            dz(:,:,i,:) = (287.06 .* Tv(:,:,i,:) ./ 9.81) .* log(pressure(:,:,i+1,:) ./ pressure(:,:,i,:));
        end
        % Calculate altitude:
        for i = numel(hybm):-1:1
            if i == numel(hybm)
                var_aux(:,:,i,:) = dz(:,:,i,:) ./ 2 + permute(zi,[1 2 4 3]);
            else
                var_aux(:,:,i,:) = dz(:,:,i,:) ./ 2 + var_aux(:,:,i+1,:);
            end
        end
        var_out = [var_aux(idx_lon,:,:,:);  var_aux(~idx_lon,:,:,:)]; % kg/m3
    otherwise
        out_st  = check_var_netcdf(file,var_id);
        if out_st == 0; error(' Variable %s does not exist on file.',var_id);end
        if ~exist('i_start','var') & ~exist('i_count','var')
            var_aux = ncread(file,var_id);
        else
            var_aux = ncread(file,var_id,i_start,i_count);
        end
        var_out = [var_aux(idx_lon,:,:,:);  var_aux(~idx_lon,:,:,:)];
    end
    
    % flip variable on 3rd dimension:
    [nx,ny,nz,nt] = size(var_out);
    if nz > 20 % using 20 levels as minimum
        var_out = flip(var_out,3);
    end

end


function out_stat = check_var_netcdf(file,var_name)
    finfo    = ncinfo(file);
    fvars    = {finfo.Variables.Name};
    out_stat = 0;
    
    for i = 1:numel(fvars)
        if strcmp(var_name,fvars{i}); out_stat = 1; return; end
    end
end
