% Function to get variable from WRF-Chem outputs.
% Designed for MOZART-4 and MOSAIC 4 bins mechanisms.
% Author: Gonzalo A. Ferrada (gonzalo-ferrada@uiowa.edu)
% April 2020
%
% [var_out z dz pressure rho] = get_wrf_variable(file,varid,pres_lev);
%
% varid       Description:                        Dim:    Units:
% -----------------------------------------------------------------
% Z or H      Mid-level altitude                  3D      m
% DZ          Layer thickness                     3D      m
% PRES        Layer pressure                      3D      hPa
% RHO         Air density                         3D      kg/m3
%
% CLDFRA      Cloud fraction                      3D
% CLDFRATOT   Average cloud fraction              2D
% PBLH        Boundary layer height               2D      m
% PBLHASL     Boundary layer height a.s.l.        2D      m 
% T2C         2-m temperature                     2D      C
% TC          Temperature                         3D      C
% RH          Relative humidity                   3D      %
% U,V,W       u,v or w wind speed (unstaggered)   3D      m/s
% CLDBASE     Cloud base                          2D      m
% CLDTOP      Cloud top                           2D      m
% WSPD        Horizontal wind speed (unstaggered) 2D      m/s
% CLDTEMP     Cloud top temperature (IR-like)     2D      C
%
% AOD550      Aerosol optical depth 550nm         2D
% TAU550      Optical depth 550 nm                3D 
% EXT550      Extinction coeff. 550nm             3D      1/Mm
% EXT532      Extinction coeff. 532nm             3D      1/Mm
% BC          Black carbon                        3D      ug/m3
% OC          Organic carbon                      3D      ug/m3
% NH4         Ammonium                            3D      ug/m3
% NO3         Nitrate                             3D      ug/m3
% OIN         Other inorganics                    3D      ug/m3
% SO4         Sulfate                             3D      ug/m3
% PM25        PM 2.5                              3D      ug/m3
% PM10        PM 10                               3D      ug/m3
% CO          Carbon monoxide                     3D      ppbv
% CO2         Carbon dioxide                      3D      ppbv
% SO2         Sulfur dioxide                      3D      ppbv
% O3          Ozone                               3D      ppbv
% NO          NO                                  3D      ppbv
% NO2         NO2                                 3D      ppbv
% NOX         NO+NO2                              3D      ppbv
% PLUMETOP    Smoke plume top                     2D      m
% PLUMEBASE   Smoke plume base                    2D      m
% -----------------------------------------------------------------
%
% v1.1: May 2020
% Added functionality to interpolate (cubic) to desired pressure level
% specified by adding a third input argument called pres_lev. Note: this
% pressure level should be indicated in mb or hPa units.
%
% v1.2: June 2020
% Added horizontal wind speed (WSPD).
%

function [var_out z dz pressure rho] = wrf(file,varid,pres_lev)
    
    % First, check if lambert projection specifications are requested.
    % This avoids reading any other variables that may not be included,
    % e.g., T, P, PH... from geo_em.d01.nc or other wrf related files.
    if strcmpi(varid,'lambert');
        proj = ncreadatt(file,'/','MAP_PROJ');
        if proj ~= 1; error(' This WRF file is not in Lambert projection'); end
        truelat1    =  double(ncreadatt(file,'/','TRUELAT1'));
        truelat2    =  double(ncreadatt(file,'/','TRUELAT2'));
        cen_lat     =  double(ncreadatt(file,'/','CEN_LAT'));
        cen_lon     =  double(ncreadatt(file,'/','CEN_LON'));
        var_out     =  [truelat1 truelat2 cen_lat cen_lon];
        return
    end
    
    
    % Get common variables:
    pressure = ncread(file,'P') + ncread(file,'PB'); % Pa
    tempk    = (ncread(file,'T') + 300).* (pressure./100000).^(2/7) ; % K
    rho      = (28.97 * pressure)./ (1000 * 8.314472 * tempk); % kg/m3
    zi       = (ncread(file,'PHB') + ncread(file,'PH')) ./ 9.81; % m
    for i = 2:size(zi,3); z(:,:,i-1)  = (zi(:,:,i-1) + zi(:,:,i)) ./ 2;end % fixing z
    for i = 2:size(zi,3); dz(:,:,i-1) = zi(:,:,i)-zi(:,:,i-1);end % m
        
    % General:
    if strcmpi(varid,'Z') | strcmpi(varid,'H');var_model = z; 
    elseif strcmpi(varid,'DZ');var_model = dz; 
    elseif strcmpi(varid,'PRES');var_model = pressure ./ 100;  % hPa
    elseif strcmpi(varid,'RHO');var_model = rho; 
    
    % Meteorology:
    elseif strcmp(varid,'CLDFRA');var_model = ncread(file,'CLDFRA'); 
    elseif strcmp(varid,'CLDFRATOT');cf3d = ncread(file,'CLDFRA') .* (dz./sum(dz,3)); var_model = sum(cf3d,3);
    elseif strcmp(varid,'PBLH');var_model = ncread(file,'PBLH');  % m
    elseif strcmp(varid,'T2C');var_model = ncread(file,'T2') - 273.15; 
    elseif strcmp(varid,'TC');var_model = tempk - 273.15; 
    elseif strcmp(varid,'RH');es = 10*0.6112*exp(17.67*(tempk-273.15)./(tempk-29.65));
                          qvs = 0.622 * ( es./(0.01*pressure - (1-0.622).*es));
                          qv = ncread(file,'QVAPOR');qv(qv<0) = 0;var_model = (qv./qvs)*100;  % % percent
    elseif strcmp(varid,'U');u=ncread(file,'U');for i=1:size(u,1)-1;var_model(i,:,:)=0.5.*(u(i,:,:)+u(i+1,:,:));end; 
    elseif strcmp(varid,'V');v=ncread(file,'V');for i=1:size(v,2)-1;var_model(:,i,:)=0.5.*(v(:,i,:)+v(:,i+1,:));end; 
    elseif strcmp(varid,'W');w=ncread(file,'W');for i=1:size(w,3)-1;var_model(:,:,i)=0.5.*(w(:,:,i)+w(:,:,i+1));end;
    elseif strcmp(varid,'WSPD');u=ncread(file,'U');for i=1:size(u,1)-1;u_unstgd(i,:,:)=0.5.*(u(i,:,:)+u(i+1,:,:));end;
                                v=ncread(file,'V');for i=1:size(v,2)-1;v_unstgd(:,i,:)=0.5.*(v(:,i,:)+v(:,i+1,:));end;
                                wspd = sqrt(u_unstgd.^2 + v_unstgd.^2); var_model = wspd;
    elseif strcmp(varid,'CLDBASE');qtot=ncread(file,'QICE')+ncread(file,'QCLOUD');ind=(qtot>1e-5);
                          for i = 1:size(qtot,3);cloud(:,:,i)=(ind(:,:,i)==1).*z(:,:,i);end;cloud(cloud==0) = NaN;
                          for i = 1:size(qtot,1);for j = 1:size(qtot,2)
                          var_model(i,j) = min(cloud(i,j,:));end;end;
    elseif strcmp(varid,'CLDTOP');qtot=ncread(file,'QICE')+ncread(file,'QCLOUD');ind=(qtot>1e-5);
                          for i = 1:size(qtot,3);cloud(:,:,i)=(ind(:,:,i)==1).*z(:,:,i);end;cloud(cloud==0) = NaN;
                          for i = 1:size(qtot,1);for j = 1:size(qtot,2)
                          var_model(i,j) = max(cloud(i,j,:));end;end;
    elseif strcmp(varid,'LWP');qtot=ncread(file,'QICE')+ncread(file,'QCLOUD');qtot=qtot.*rho.*dz.*1000; var_model = sum(qtot,3);
    elseif strcmp(varid,'CLDTEMP');cld=ncread(file,'CLDFRA');t2=ncread(file,'T2')-273.15;tc=tempk-273.15;idx_cld=cld>0.5;
        t_cld=idx_cld.*tc;t_cld(t_cld==0)=NaN;var_model=min(t_cld,[],3);var_model(isnan(var_model))=t2(isnan(var_model));
        
        
        
    % elseif strcmpi(varid,'lambert');
    %     proj = ncreadatt(file,'/','MAP_PROJ');
    %     if proj ~= 1; error(' This WRF file is not in Lambert projection'); end
    %     truelat1    =  double(ncreadatt(file,'/','TRUELAT1'));
    %     truelat2    =  double(ncreadatt(file,'/','TRUELAT2'));
    %     cen_lat     =  double(ncreadatt(file,'/','CEN_LAT'));
    %     cen_lon     =  double(ncreadatt(file,'/','CEN_LON'));
    %     var_model   =  [truelat1 truelat2 cen_lat cen_lon];

    
    % Chemistry and aerosols:
    elseif strcmp(varid,'AOD550');tau2=ncread(file,'TAUAER2');tau3=ncread(file,'TAUAER3');
                          aexp=-(log(tau2)-log(tau3))./(log(400/600));var_model=sum(tau2.*((400/550).^(aexp)),3);
    elseif strcmp(varid,'TAU550');tau2=ncread(file,'TAUAER2');tau3=ncread(file,'TAUAER3');
                        aexp=-(log(tau2)-log(tau3))./(log(400/600));var_model=tau2.*((400/550).^(aexp)); 
    elseif strcmp(varid,'EXT550');tau2=ncread(file,'TAUAER2');tau3=ncread(file,'TAUAER3');
                          aexp=-(log(tau2)-log(tau3))./(log(400/600));tau550=tau2.*((400/550).^(aexp));var_model=tau550.*(1e6./dz);
    elseif strcmp(varid,'EXT532');tau2=ncread(file,'TAUAER2');tau3=ncread(file,'TAUAER3');
                        aexp=-(log(tau2)-log(tau3))./(log(400/600));tau532=tau2.*((400/532).^(aexp));var_model=tau532.*(1e6./dz);  
    elseif strcmp(varid,'BC');
        var_model = ncread(file,'bc_a01')+ncread(file,'bc_a02')+ncread(file,'bc_a03')+ncread(file,'bc_a04'); % ug/kg
        var_model = var_model .* rho ;  % ug/m3
    elseif strcmp(varid,'OC');
        var_model = ncread(file,'oc_a01')+ncread(file,'oc_a02')+ncread(file,'oc_a03')+ncread(file,'oc_a04'); % ug/kg
        var_model = var_model .* rho ;  % ug/m3
    elseif strcmp(varid,'NH4');
        var_model = ncread(file,'nh4_a01')+ncread(file,'nh4_a02')+ncread(file,'nh4_a03')+ncread(file,'nh4_a04'); % ug/kg
        var_model = var_model .* rho ;  % ug/m3
    elseif strcmp(varid,'NO3');
        var_model = ncread(file,'no3_a01')+ncread(file,'no3_a02')+ncread(file,'no3_a03')+ncread(file,'no3_a04'); % ug/kg
        var_model = var_model .* rho ;  % ug/m3
    elseif strcmp(varid,'OIN');
        var_model = ncread(file,'oin_a01')+ncread(file,'oin_a02')+ncread(file,'oin_a03')+ncread(file,'oin_a04'); % ug/kg
        var_model = var_model .* rho ;  % ug/m3
    elseif strcmp(varid,'SO4');
        var_model = ncread(file,'so4_a01')+ncread(file,'so4_a02')+ncread(file,'so4_a03')+ncread(file,'so4_a04'); % ug/kg
        var_model = var_model .* rho ;  % ug/m3
    elseif strcmp(varid,'SS');
        var_model = ncread(file,'na_a01')+ncread(file,'na_a02')+ncread(file,'na_a03')+ncread(file,'na_a04')+...
                    ncread(file,'cl_a01')+ncread(file,'cl_a02')+ncread(file,'cl_a03')+ncread(file,'cl_a04'); % ug/kg
        var_model = var_model .* rho ;  % ug/m3
    elseif strcmp(varid,'CO'); var_model = ncread(file,'co')  .* 1000;  % ppbv
    elseif strcmp(varid,'CO2');var_model = ncread(file,'co2') .* 1000;  % ppbv
    elseif strcmp(varid,'O3'); var_model = ncread(file,'o3')  .* 1000;  % ppbv
    elseif strcmp(varid,'SO2');var_model = ncread(file,'so2') .* 1000;  % ppbv
    elseif strcmp(varid,'NO');var_model = ncread(file,'no') .* 1000;  % ppbv
    elseif strcmp(varid,'NO2');var_model = ncread(file,'no2') .* 1000;  % ppbv
    elseif strcmp(varid,'NOX');var_model = (ncread(file,'no2')+ncread(file,'no')) .* 1000;  % ppbv
    elseif strcmp(varid,'PM25');var_model = ncread(file,'PM2_5_DRY');  % ug/m3
    elseif strcmp(varid,'PM10');var_model = ncread(file,'PM10');  % ug/m3
    elseif strcmp(varid,'PLUMETOP');
        bc = ncread(file,'bc_a01')+ncread(file,'bc_a02')+ncread(file,'bc_a03')+ncread(file,'bc_a04'); % ug/kg
        bc = bc .* rho; % ug/m3
        tau2=ncread(file,'TAUAER2');tau3=ncread(file,'TAUAER3');
        aexp=-(log(tau2)-log(tau3))./(log(400/600));aod550=sum(tau2.*((400/600).^(aexp)),3);
        % co_fire = ncread(file,'co_fire');
        INDEX = bc(:,:,:) >= 0.2;  % 0.2 ug/m3 or 200 ng/m3
        % INDEX = bc(:,:,:) >= 0.2 & aod550(:,:,1) > 0.05 ;  % 0.15 ug/m3 or 150 ng/m3
        % INDEX = bc(:,:,:) >= 0.2 & co_fire(:,:,:) > 0.02;  %bc and co from fire treshold
        BC_HEIGHT = INDEX .* z;BC_HEIGHT(BC_HEIGHT==0) = NaN;var_model(:,:,:) = max(BC_HEIGHT,[],3); % m
    elseif strcmp(varid,'PLUMEBASE');
        bc = ncread(file,'bc_a01')+ncread(file,'bc_a02')+ncread(file,'bc_a03')+ncread(file,'bc_a04'); % ug/kg
        bc = bc .* rho; % ug/m3
        tau2=ncread(file,'TAUAER2');tau3=ncread(file,'TAUAER3');
        aexp=-(log(tau2)-log(tau3))./(log(400/600));aod550=sum(tau2.*((400/600).^(aexp)),3);
        % co_fire = ncread(file,'co_fire');
        INDEX = bc(:,:,:) >= 0.2;  % 0.2 ug/m3 or 200 ng/m3
        % INDEX = bc(:,:,:) >= 0.2 & aod550(:,:,1) > 0.05 ;  % 0.15 ug/m3 or 150 ng/m3
        % INDEX = bc(:,:,:) >= 0.2 & co_fire(:,:,:) > 0.02;  %bc and co from fire treshold
        BC_HEIGHT = INDEX .* z;BC_HEIGHT(BC_HEIGHT==0) = NaN;var_model(:,:,:) = min(BC_HEIGHT,[],3); % m
    elseif strcmp(varid,'PBLHASL'); hgt = zi(:,:,1);var_model = ncread(file,'PBLH') + hgt; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    % elseif strcmp(varid,'');var_model = ; 
    
    % Read generic variable not listed here:
    else
        var_model = ncread(file,varid);
    end
    
    % v1.1: Interpolation to desired pressure level indicated in pres_lev:
    if exist('pres_lev','var') & size(var_model,3) > 1
        [Nx,Ny,Nz] = size(rho);
        p_mb = pressure ./ 100;
        
        for i = 1:Nx
            for j = 1:Ny
                local_p = p_mb(i,j,:);
                local_p = permute(local_p,[3 1 2]); % 1D
                local_v = var_model(i,j,:);
                local_v = permute(local_v,[3 1 2]); % 1D
        
                % scatter(local_v,local_p)
                aux_v = interp1(local_p,local_v, pres_lev ,'pchip');
        
                out_v(i,j) = aux_v;
            end
        end
        var_out = out_v;
    else
        var_out = var_model;
    end
    
    
end