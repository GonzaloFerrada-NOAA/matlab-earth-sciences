function reorganizeaxes(varargin)
    % REORGANIZEAXES Adjusts axes in the current figure to specified sizes and spacing,
    % and adds margins for axis labels and titles.
    %
    % Usage:
    % reorganizeaxes(nrows, ncols, width, height, spacing_horiz, spacing_vert)
    % reorganizeaxes(nrows, ncols, width, height, spacing_horiz, spacing_vert, remove_tick_labels)
    % reorganizeaxes(ax, nrows, ncols, width, height, spacing_horiz, spacing_vert, ...)
    %
    % Arguments:
    % - ax: Optional. Array of axes handles in the order they should be placed
    %       (left to right, then top to bottom). If omitted, all axes in the
    %       current figure are used in creation order. If ax is a 2D array,
    %       ax(row, col) is placed at that row and column.
    % - nrows: Number of rows in the layout.
    % - ncols: Number of columns in the layout.
    % - width: Width of each axes in pixels.
    % - height: Height of each axes in pixels.
    % - spacing_horiz: Horizontal spacing between axes in pixels.
    % - spacing_vert: Vertical spacing between axes in pixels.
    % - remove_tick_labels: Optional. If true, removes tick labels from non-edge axes.
    %
    % Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
    % January 2025
    % REORGANIZEAXES is a completely made-over from the older REDISTRIBUTE_SUBPLOT function.

    % Check if the first argument is an axes array (graphics handles are not numeric,
    % so an integer nrows is never mistaken for a figure handle here)
    if nargin > 0 && ~isnumeric(varargin{1}) && all(isgraphics(varargin{1}, 'axes'), 'all')
        ax = varargin{1};
        varargin(1) = [];
    else
        ax = [];
    end

    if numel(varargin) < 6
        error('Not enough input arguments.');
    end
    [nrows, ncols, width, height, spacing_horiz, spacing_vert] = varargin{1:6};
    if numel(varargin) >= 7
        remove_tick_labels = varargin{7};
    else
        remove_tick_labels = false;
    end

    % Define margin size in pixels
    margin = 120; % Margin on all sides of the figure

    % Get figure and axes
    if isempty(ax)
        fig = gcf;
        axes_handles = flipud(findall(fig, 'Type', 'axes')); % Reverse the order
    else
        fig = ancestor(ax(1), 'figure');
        if isvector(ax)
            axes_handles = ax(:);
        else
            axes_handles = reshape(ax.', [], 1); % Row-major: ax(row, col)
        end
    end
    num_axes = numel(axes_handles);

    if isempty(width) && isempty(height)
        error('Either width or height must be specified.');
    end

    if isempty(width) || isempty(height)
        aspect_ratio = get(axes_handles(1), 'PlotBoxAspectRatio');
        if numel(aspect_ratio) < 2 || aspect_ratio(2) == 0
            error('Unable to determine axes aspect ratio from PlotBoxAspectRatio.');
        end

        if isempty(height)
            height = width * aspect_ratio(2) / aspect_ratio(1);
        else
            width = height * aspect_ratio(1) / aspect_ratio(2);
        end
    end

    % if num_axes ~= nrows * ncols
    %     error('The number of axes does not match the specified layout (%d rows x %d cols).', nrows, ncols);
    % end

    % Adjust figure size
    fig_width = ncols * width + (ncols - 1) * spacing_horiz + 2 * margin;
    fig_height = nrows * height + (nrows - 1) * spacing_vert + 2 * margin;
    fig.Position(3:4) = [fig_width, fig_height]; % Update width and height of figure

    % Rearrange axes
    for i = 1:num_axes
        % Compute row and column indices
        row = ceil(i / ncols);
        col = mod(i - 1, ncols) + 1;

        % Compute position for this axes
        left = margin + (col - 1) * (width + spacing_horiz);
        bottom = fig_height - margin - row * height - (row - 1) * spacing_vert;
        axes_handles(i).Position = [left / fig_width, bottom / fig_height, ...
                                    width / fig_width, height / fig_height];

        % Remove tick labels if specified
        if remove_tick_labels
            if col ~= 1 % Not in the first column
                axes_handles(i).YTickLabel = [];
            end
            if row ~= nrows % Not in the last row
                axes_handles(i).XTickLabel = [];
            end
        end
    end
end
