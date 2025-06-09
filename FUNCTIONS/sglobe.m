function h = sglobe(varargin)
    
    % sglobe plots a 3-D Earth spheroid with boundaries of coastlines or countries/regions/states.
    %
    % sglobe() displays a 3-D Earth spheroid
    %
    % sglobe(lon,lat,data) overlays custom data input over the 3-D spheroid.
    %
    % h = sglobe(...) returns a handle to the textured mapped data (if provided)
    %
    % Example:
    % sglobe('MapRes','h1','Color','y')
    % 
    % Optional inputs:
    % lon   : longitude array in degrees
    % lat   : latitude array in degrees
    % data  : data array
    % These 3 optional inputs must be the same size.
    %
    % Other options:
    % Color     : FaceColor of the 3-D spheroid
    % Colormap  : Colormap to be used for input data (if provided)
    % MapRes    : Resolution map ('help world' for different options)
    % MapColor  : Color of the boundaries/map lines
    %
    % Author: Gonzalo A. Ferrada (gferrada@utk.edu)
    % March 2023
    
    
    p = inputParser;
    
    addOptional(p,'lon',[])
    addOptional(p,'lat',[])
    addOptional(p,'data',[])
    
    addParameter(p,'MapRes','mc')
    addParameter(p,'MapColor',[1 1 1] * 0.25)
    addParameter(p,'Color',[1 1 1] * 0.92)
    addParameter(p,'Colormap',custom_colormap('gmao2',64))
    
    parse(p,varargin{:})

    opts = p.Results;
    
    % ================================================================
    
    if ~ishold
        clf
    end
    
    
    % Make Globe:
    hold on
    [x,y,z] = sphere(359);
    surface(x,y,z,'FaceColor',opts.Color,'EdgeColor','none','FaceAlpha',1);
    % set(gca, 'View', [45 30]); %view(3)
    set(gca,'Clipping','off','DataAspectRatio',[1 1 6378/6357])
    set(gcf,'Color',[1 1 1] * 0.5)
    set(gca, 'DataAspectRatioMode', 'manual', 'PlotBoxAspectRatioMode', 'manual'); %axis vis3d
    set(gca, 'Visible', 'off'); %axis off
    zoom(1.5)
    % view([0 0])
    set(gca, 'View', [0 0]);
    % axis([-1 1 -1 1 -1 1])
    
    % Plot data if provided:
    if ~isempty(opts.lon) & ~isempty(opts.lat) & ~isempty(opts.data)
        
        % Convert lat and lon to cartesian coordinates:
        [dx,dy,dz] = sph2cart(deg2rad(opts.lon - 90), deg2rad(opts.lat), 1.0005);
        if sum(isnan(opts.data(:))) > 0
            idx     = isnan(opts.data);
            dx(idx) = NaN;
            dy(idx) = NaN;
        end
        
        h = surface(dx,dy,dz,'FaceColor','texturemap','EdgeColor','none','Cdata',opts.data);
        view(double([mean(opts.lon(:), 'omitnan') mean(opts.lat(:), 'omitnan')]))
        colormap(opts.Colormap)
    else
        h = [];
    end
    
    
    % Plot country boundaries:
    % load world.mat
    w0 = load('world.mat',opts.MapRes);
    ww = w0.(opts.MapRes); clear w0
    for i = 1:numel(ww)
        lonm = ww{i}(:,1) - 90;
        latm = ww{i}(:,2);
        [mx,my,mz] = sph2cart(deg2rad(lonm),deg2rad(latm),1.001);
        plot3(mx,my,mz,'Color',opts.MapColor)
    end
    
    if nargout, handle = h; end
    
    
end