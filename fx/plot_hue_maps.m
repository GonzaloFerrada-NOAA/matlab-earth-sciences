clear; close all; clc

cname = {... 
... % white friendly
'jet2', 'jet3', 'gmao', 'hrrr', 'cams', 'aod', 'ncl', 'o3', 'co', 'sat', 'oc', 'bc', 'hum', 'wind', 'pm', 'pastel', 'nox',  ...
... % full color
'emis', 'finn', 'usgs', 'blh', 'temp', 'rainbow', 'ww', 'giss', 'acc', 'frp', 'bright', ...
... % black friendly
'ext', 'pro', 'city', 'clouds', ...
... % divergent
'ssta', 'sea', 'pan', 'ufs', 'br1', 'br2', 'br3', 'br4', 'cpc', 'rh', 'daod', 'melt', 'grav', 'ceres', 'ppa', 'pp2' ...
};



figure; set(gcf,'Position',[1e5 1e5 1100 850]); 

Nrows = 3; 
Ncols = ceil(numel(cname) / Nrows);


for i = 1:numel(cname)
    ax(i) = subplot(Nrows, Ncols, i);
    tt(i) = title(cname{i}, 'FontWeight', 'normal'); hold on
    cm    = hue(cname{i}, 64);
    rgb   = repmat(reshape(cm, [size(cm,1), 1, 3]), 1, 1, 1);
    imagesc([0 1], [0 1], rgb)
    
    drawnow
end

set(ax, 'YDir', 'normal')
set(ax, 'XLim', [0 1], 'YLim', [0 1])
set(ax, 'XTick', [], 'YTick', [], 'Box', 'on', 'Layer', 'top')
set(tt, 'FontSize', 15)
reorganizeaxes(Nrows, Ncols, 20, 200, 40, 40)

% exportgraphics(gcf, '~/Desktop/hue.png', 'Resolution', 300)
exportgraphics(gcf, '~/Desktop/hue.pdf', 'ContentType', 'vector')
close
