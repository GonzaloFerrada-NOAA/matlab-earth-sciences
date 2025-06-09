function colorbar_size(cb,rate)
    
    % Check arguments
    if ~exist('cb','var')
        % If no arguments are passed:
        % disp('If no arguments are passed:')
        cb      = flip(findobj(gcf, 'Type', 'Colorbar'));
        rate    = 0.8;
    elseif exist('cb','var') & ~exist('rate','var')
        switch class(cb)
        case {'single','double'}
            % cb is actually rate:
            % disp('cb is actually rate')
            rate = cb;
            cb   = flip(findobj(gcf, 'Type', 'Colorbar'));
        otherwise
            % cb is cb but rate is not provided:
            % disp('cb is cb but rate is not provided:')
            rate = 0.8;
        end
    end
    
    
    
    
    for i = 1:numel(cb)
        % i
        aux = cb(i).Position;
        x   = aux(1);
        y   = aux(2);
        w   = aux(3);
        h   = aux(4);

        d   = h - (h * rate);
        nh  = h * rate;
        nw  = w * rate ^ 3;
        nx  = x + w - nw;
        ny  = y + (h - nh)/2;

        set(cb(i),'Position',[nx ny nw nh])
        % set(ax(i),'Position',ax(i).Position)

    end
    
    
    
end
% function colorbar_size(cb,rate)
%
%     % Check arguments
%     if ~exist('cb','var')
%         % If no arguments are passed:
%         % disp('If no arguments are passed:')
%         cb      = flip(findobj(gcf, 'Type', 'Colorbar'));
%         rate    = 0.8;
%     elseif exist('cb','var') & ~exist('rate','var')
%         switch class(cb)
%         case {'single','double'}
%             % cb is actually rate:
%             % disp('cb is actually rate')
%             rate = cb;
%             cb   = flip(findobj(gcf, 'Type', 'Colorbar'));
%         otherwise
%             % cb is cb but rate is not provided:
%             % disp('cb is cb but rate is not provided:')
%             rate = 0.8;
%         end
%     end
%
%     % get axes handle:
%     ax   = flip(findobj(gcf, 'Type', 'Axes'));
%     axc  = get(ax,'Colorbar');
%     cbc  = arrayfun(@(x) ~isa(x, 'matlab.graphics.GraphicsPlaceholder'), cb);
%
%
%     c = 1;
%     for i = 1:numel(axc)
%         % i
%         if i == 1
%             axcc = axc;
%         else
%             axcc(i) = axc{i};
%         end
%     end
%     if numel(axc) == 0
%         error('There is no colorbar in current graphics.')
%     end
%     clear axc
%     axc = axcc;
%
%     for i = 1:numel(ax)
%         if ~isempty(axc(i)) % Current Axes HAS colorbar
%
%             while cbc(c) == 0
%                 c = c + 1;
%             end
%
%             aps = ax(i).Position;
%             aux = cb(c).Position;
%             x   = aux(1);
%             y   = aux(2);
%             w   = aux(3);
%             h   = aux(4);
%
%             d   = h - (h * rate);
%             nh  = h * rate;
%             nw  = w * rate ^ 3;
%             nx  = x;
%             ny  = y + (h - nh)/2;
%
%             set(cb(c),'Position',[nx ny nw nh])
%             set(ax(i),'Position',aps)
%
%             c = c + 1;
%
%         end
%     end
%
%
%
%
%     % for i = 1:numel(cb)
%     %     i
%     %     if ~isempty(axc{i})
%     %         i
%     %         aux = cb(i).Position;
%     %         x   = aux(1);
%     %         y   = aux(2);
%     %         w   = aux(3);
%     %         h   = aux(4);
%     %
%     %         d   = h - (h * rate);
%     %         nh  = h * rate;
%     %         nw  = w * rate ^ 2.5;
%     %         nx  = x;
%     %         ny  = y + (h - nh)/2;
%     %
%     %         set(cb(i),'Position',[nx ny nw nh])
%     %         set(ax(i),'Position',ax(i).Position)
%     %
%     %     end
%     %
%     % end
%
%
%
% end