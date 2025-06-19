function redistribute_subplot(nrows,ncols,borders_opt,deleteax_opt)
% Re-distributes subplot figures to optimize the use of space.
% includes options for borders and add single colorbar
% Author: Gonzalo A. Ferrada
% June 2019
%
% redistribute_subplot(nrows,ncols,borders_opt,deleteax_opt)
% borders_opt = [x_left x_right y_bottom y_top gap_figs];

% Set defaults:
if ~exist('deleteax_opt','var'); deleteax_opt = 'off'; end
if numel(borders_opt) == 1
    border_x = borders_opt;     border_y = borders_opt;
    separ_x  = borders_opt;     separ_y  = borders_opt;
elseif numel(borders_opt) == 2
    border_x = borders_opt(1);     border_y = borders_opt(1);
    separ_x  = borders_opt(2);     separ_y  = borders_opt(2);
elseif numel(borders_opt) == 4
    border_x = borders_opt(1);     border_y = borders_opt(2);
    separ_x  = borders_opt(3);     separ_y  = borders_opt(4);
else
    error('foo:bar', [' borders_opt has has to be a single value, two values or four values:\n ' ...
    '[border_fig_horizontal border_fig_vertical separation_subplot_horizontal separation_subplot_vertical]'])
end
% warning('foo:bar',['This function assumes that subplots were created in order from top-left to bottom-right.\n ' ...
% 'If subplots were not created in order, then this function will disorganize them.'])

% Get figure size:
figure_size   =  get(gcf,'Position');

% Get Aspect ratio of data from first subplot:
ax    = subplot(nrows,ncols,1);
% a_r = ax.DataAspectRatio(2) / ax.DataAspectRatio(1);
% a_r = (ax.YLim(2) - ax.YLim(1)) / (ax.XLim(2) - ax.XLim(1));
% a_r = ax.Position(4) / ax.Position(3)
a_r   = ax.PlotBoxAspectRatio(2) / ax.PlotBoxAspectRatio(1);

% if a_r < 1
% % Determine size of subplots based on width:
% sp_width   =  (figure_size(3) - 2*border_x - (ncols-1)*separ_x) / (ncols);
% sp_height  =  a_r * sp_width;
% elseif  a_r >= 1
% Determine size of subplots based on height:
sp_height  =  (figure_size(4) - 2*border_y - (nrows-1)*separ_y) / (nrows);
sp_width   =  sp_height / a_r;
% end

disp([' Figure size is: ' num2str(figure_size(3)) ' x ' num2str(figure_size(4)) ' pixels.'])
disp([' Subplot size is: ' num2str(sp_width) ' x ' num2str(sp_height) ' pixels.'])

% Fix position xx:
xx(1:nrows,1) = border_x;
for i = 2:ncols
    xx(1:nrows,i) = border_x + (separ_x+sp_width)*(i-1);
end
for i = 2:nrows
    yy(i,1:ncols) = border_y + (separ_y+sp_height)*(i-1);
end
yy(1,1:ncols) = border_y;
yy = flipud(yy);
xx = reshape(xx',1,nrows*ncols);
yy = reshape(yy',1,nrows*ncols);


% Get axes of each subplot:
for i = 1:nrows*ncols
    sp{i} = subplot(nrows,ncols,i);
    sp{i}.Units  = 'pixels';
end
for i = 1:nrows*ncols
    aux_position(i,:) = [xx(i) yy(i) sp_width sp_height];
    sp{i}.Position = [xx(i) yy(i) sp_width sp_height];
    % sp{i}.Position = [xx(i) yy(i) sp_width sp_height];
end

% Remove additional axis tick labels:
switch deleteax_opt
case 'on'
    % To know what index is what subplot:
    sp_idx        = 1:nrows*ncols;
    sp_idx_matrix = reshape(sp_idx,ncols,nrows)';
    % Remove XTickLabel:
    sp_idx_matrix(end,:) = [];
    sp_idx_x = reshape(sp_idx_matrix',1,numel(sp_idx_matrix));
    for i = sp_idx_x
        sp{i}.XTickLabel = '';
        xlabel(sp{i},'')
    end
    % Remove YTickLabel:
    sp_idx_matrix = reshape(sp_idx,ncols,nrows)';
    sp_idx_matrix(:,1) = [];
    sp_idx_y = reshape(sp_idx_matrix',1,numel(sp_idx_matrix));
    for i = sp_idx_y
        sp{i}.YTickLabel = '';
        ylabel(sp{i},'')
    end
end



end