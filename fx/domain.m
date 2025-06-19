% Plot domain boundaries from WRF file.
% function wrf_domain(lon,lat,line_color,line_width)
%       lon        :  Longitude array (1-D or 2-D)
%       lat        :  Latitude array (1-D or 2-D)
%       line_color :  Line color. Default is [.15 .15 .15]
%       line_width :  Line width. Default is 1.
%
% Author: Gonzalo A. Ferrada (gonzalo-ferrada@uiowa.edu)
%
% Change log:
% Previously called wrf_domain which accepted a wrf file to look for XLAT and XLONG.
% Since August 2020

function domain(lon,lat,line_color,line_width)

hold on

if ~exist('line_color','var');  line_color = [.15 .15 .15]; end
if ~exist('line_width','var');  line_width = 1; end

[Nx,Ny,Nz,Nt] = size(lon);

if Nz ~= 1 | Nt ~= 1
    error(' lon and lat inputs should be 1-D or 2-D.')
end

if (Nx ~= 1 & Ny == 1) | (Nx == 1 & Ny ~= 1)  % lon and lat are 1-D
    [lon,lat] = ndgrid(lon,lat);
end
    
% x = [lon(:,end); flip(lon(end,:))'; lon(:,1); lon(1,:)'];
% y = [lat(:,end); flip(lat(end,:))'; lat(:,1); lat(1,:)'];
x = [lon(:,end); flip(lon(end,:))'; flip(lon(:,1)); lon(1,:)'];
y = [lat(:,end); flip(lat(end,:))'; flip(lat(:,1)); lat(1,:)'];
patch(x,y,'r','FaceColor','none','LineWidth',line_width,'EdgeColor',line_color)


end
