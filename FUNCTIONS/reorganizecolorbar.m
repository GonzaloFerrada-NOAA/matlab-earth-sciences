function reorganizecolorbar(varargin)
    % REORGANIZECOLORBAR Adjusts the position and properties of the colorbar in the current figure.
    %
    % Usage:
    % reorganizecolorbar(colorbar_handle, nrows, ncols, ...)
    % reorganizecolorbar(nrows, ncols, ...)
    %
    % Inputs:
    % - colorbar_handle (optional): Handle to the colorbar. Automatically retrieved if not provided.
    % - nrows, ncols: Number of rows and columns in the subplot/tiled layout.
    % - Additional arguments (order is flexible):
    %     * location_option (string/char): 'top', 'bottom', 'left', 'right'.
    %     * proportion (scalar, 0 < proportion <= 1): Relative extent of the colorbar.
    %     * extent_axes (2-element vector): Extent of rows/columns covered by the colorbar.
    %
    % Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov) & ChatGPT-4
    % January 2025

    % Default values
    colorbar_handle = [];
    nrows = [];
    ncols = [];
    location_option = 'right';
    proportion = 1;
    extent_axes = [];

    % Parse input arguments
    for i = 1:numel(varargin)
        arg = varargin{i};
        if isempty(colorbar_handle) && isa(arg, 'matlab.graphics.illustration.ColorBar')
            colorbar_handle = arg;
        elseif isempty(nrows) && isnumeric(arg) && isscalar(arg)
            nrows = arg;
        elseif isempty(ncols) && isnumeric(arg) && isscalar(arg)
            ncols = arg;
        elseif ischar(arg) || isstring(arg)
            location_option = lower(string(arg));
        elseif isnumeric(arg) && isscalar(arg) && arg > 0 && arg <= 1
            proportion = arg;
        elseif isnumeric(arg) && numel(arg) == 2
            extent_axes = arg;
            if extent_axes(1) > extent_axes(2)
                error('extent_axes(1) is greater than extent_axes(2): %s', mat2str(arg));
            end
        else
            error('Unrecognized input argument: %s', mat2str(arg));
        end
    end

    % Validate required inputs
    if isempty(nrows) || isempty(ncols)
        error('Number of rows (nrows) and columns (ncols) must be specified.');
    end

    % Get colorbar handle if not provided
    if isempty(colorbar_handle)
        colorbar_handles = findall(gcf, 'Type', 'ColorBar');
        if isempty(colorbar_handles)
            error('No colorbar found in the current figure.');
        elseif numel(colorbar_handles) > 1
            error('Multiple colorbars found. Please specify the colorbar handle.');
        else
            colorbar_handle = colorbar_handles;
        end
    end

    % Map location_option to Orientation
    location_map = struct('top', 'northoutside', ...
                          'bottom', 'southoutside', ...
                          'left', 'westoutside', ...
                          'right', 'eastoutside', ...
                          'north', 'northoutside', ...
                          'south', 'southoutside', ...
                          'west', 'westoutside', ...
                          'east', 'eastoutside');
    if ~isfield(location_map, location_option)
        error('Invalid location option. Use: top, bottom, left, or right.');
    end
    colorbar_handle.Location = location_map.(location_option);

    % Default extent_axes
    if isempty(extent_axes)
        if strcmp(location_option, 'top') || strcmp(location_option, 'bottom')
            extent_axes = [1, ncols];
        else
            extent_axes = [1, nrows];
        end
    end

    % Get axes positions
    axes_handles = flipud(findall(gcf, 'Type', 'axes')); % Reverse to match subplot order
    if numel(axes_handles) ~= nrows * ncols
        error('Number of axes does not match specified nrows and ncols.');
    end

    % Compute start/end indices and position based on location_option
    switch location_option
        case {'top', 'north'}
            row_index = 1; % Always top row
            col_start = extent_axes(1);
            col_end = extent_axes(2);
            ax_start = axes_handles((row_index - 1) * ncols + col_start);
            ax_end = axes_handles((row_index - 1) * ncols + col_end);
            X = ax_start.Position(1);
            Y = ax_start.Position(2) + ax_start.Position(4) + 0.02;
            W = (ax_end.Position(1) + ax_end.Position(3) - ax_start.Position(1)) * proportion;
            H = colorbar_handle.Position(4);
            X = X + (1 - proportion) * (W / proportion) / 2;

        case {'bottom', 'south'}
            row_index = nrows; % Always bottom row
            col_start = extent_axes(1);
            col_end = extent_axes(2);
            ax_start = axes_handles((row_index - 1) * ncols + col_start);
            ax_end = axes_handles((row_index - 1) * ncols + col_end);
            X = ax_start.Position(1);
            Y = ax_start.Position(2) - 0.05;
            W = (ax_end.Position(1) + ax_end.Position(3) - ax_start.Position(1)) * proportion;
            H = colorbar_handle.Position(4);
            X = X + (1 - proportion) * (W / proportion) / 2;

        case {'left', 'west'}
            col_index = 1; % Always left-most column
            row_start = extent_axes(1);
            row_end = extent_axes(2);
            ax_start = axes_handles((row_end - 1) * ncols + col_index);
            ax_end = axes_handles((row_start - 1) * ncols + col_index);
            X = ax_start.Position(1) - 0.05;
            Y = ax_start.Position(2);
            W = colorbar_handle.Position(3);
            H = (ax_end.Position(2) + ax_end.Position(4) - ax_start.Position(2)) * proportion;
            Y = Y + (1 - proportion) * (H / proportion) / 2;

        case {'right', 'east'}
            col_index = ncols; % Always right-most column
            row_start = extent_axes(1);
            row_end = extent_axes(2);
            ax_start = axes_handles((row_end - 1) * ncols + col_index);
            ax_end = axes_handles((row_start - 1) * ncols + col_index);
            X = ax_start.Position(1) + ax_start.Position(3) + 0.02;
            Y = ax_start.Position(2);
            W = colorbar_handle.Position(3);
            H = (ax_end.Position(2) + ax_end.Position(4) - ax_start.Position(2)) * proportion;
            Y = Y + (1 - proportion) * (H / proportion) / 2;
    end

    % Set colorbar position
    colorbar_handle.Position = [X, Y, W, H];
end
