function ticks2geo(ax,ax_opt)
% function ticks2geo(ax,ax_opt)
% ax_opt = 'x' or 'y' to change ticklabels only in these axis.
%         Function will do both if not specified.
% 
% Author: Gonzalo A. Ferrada (gonzalo-ferrada@uiowa.edu)
% May 2020
%
% v2 14-July-2020:
%   Adding ax_opt.
%
        

if ~exist('ax','var'); ax = gca; end
if ~exist('ax_opt','var'); ax_opt = 'all'; end
    
if strcmpi(ax_opt,'all') | strcmpi(ax_opt,'x')
% Fix X axis:
x_ticks = ax.XTick;
ix      = x_ticks < -180 | x_ticks > 180;
x_ticks(ix) = [];
for i = 1:numel(x_ticks)
   if x_ticks(i) < 0 
       x_label{i} = [num2str(abs(x_ticks(i))) char(176) 'W'];
   elseif x_ticks(i) > 0
       x_label{i} = [num2str(abs(x_ticks(i))) char(176) 'E'];
   elseif x_ticks(i) == 0
       x_label{i} = [num2str(abs(x_ticks(i))) char(176)];
   end
end
% xticks(ax,x_ticks)
% xticklabels(ax,x_label)
set(ax,'XTick',x_ticks,'XTickLabel',x_label)
end

if strcmpi(ax_opt,'all') | strcmpi(ax_opt,'y')
% Fix Y axis:
y_ticks = ax.YTick;
ix      = y_ticks < -90 | y_ticks > 90;
y_ticks(ix) = [];
for i = 1:numel(y_ticks)
   if y_ticks(i) < 0 
       y_label{i} = [num2str(abs(y_ticks(i))) char(176) 'S'];
   elseif y_ticks(i) > 0
       y_label{i} = [num2str(abs(y_ticks(i))) char(176) 'N'];
   elseif y_ticks(i) == 0
       y_label{i} = [num2str(abs(y_ticks(i))) char(176)];
   end
end
% yticks(ax,y_ticks)
% yticklabels(ax,y_label)
set(ax,'YTick',y_ticks,'YTickLabel',y_label)
end





end