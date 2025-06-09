function reorganizeaxes(nrows, ncols, width, height, spacing_horiz, spacing_vert, remove_tick_labels)
    % REORGANIZEAXES Adjusts axes in the current figure to specified sizes and spacing,
    % and adds margins for axis labels and titles.
    %
    % Usage:
    % reorganizeaxes(nrows, ncols, width, height, spacing_horiz, spacing_vert)
    % reorganizeaxes(nrows, ncols, width, height, spacing_horiz, spacing_vert, remove_tick_labels)
    %
    % Arguments:
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

    if nargin < 7
        remove_tick_labels = false;
    end

    % Define margin size in pixels
    margin = 120; % Margin on all sides of the figure

    % Get current figure and axes
    fig = gcf;
    axes_handles = flipud(findall(fig, 'Type', 'axes')); % Reverse the order
    num_axes = numel(axes_handles);

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