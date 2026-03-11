function h = colorlegend(names, colors, varargin)
    % COLORLEGEND Creates a color-coded text legend in the current figure.
    %
    % Usage:
    % h = colorlegend(names, colors, nrows, ncols)
    % h = colorlegend(names, colors, nrows, ncols, location)
    % h = colorlegend(names, colors, nrows, ncols, num_columns)
    % h = colorlegend(names, colors, nrows, ncols, location, num_columns)
    %
    % Inputs:
    % - names: Cell array of legend labels.
    % - colors: Nx3 colormap in RGB units of [0,1].
    % - nrows, ncols: Number of rows and columns in the subplot layout.
    % - location: Optional. 'top', 'bottom', 'left', or 'right'. Default: 'bottom'.
    % - num_columns: Optional. Number of columns used to lay out legend items.
    %
    % Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)

    if nargin < 4
        error('Not enough input arguments.');
    end

    validatelegendinputs(names, colors);
    [nrows, ncols, location_option, num_columns, num_columns_specified] = parselayoutinputs(varargin{:});
    axes_handles = getlayoutaxes();
    if numel(axes_handles) ~= nrows * ncols
        error('Number of axes does not match specified nrows and ncols.');
    end

    if isempty(num_columns)
        if strcmp(location_option, 'left') || strcmp(location_option, 'right')
            num_columns = 1;
        else
            num_columns = numel(names);
        end
    end

    str = buildlegendstring(names, colors, num_columns, location_option, num_columns_specified);
    overlay_ax = createoverlayaxes();
    [horizontal_alignment, vertical_alignment] = getlegendalignment(location_option, num_columns, numel(names));

    h = text(overlay_ax, 0, 0, str, ...
        'Interpreter', 'tex', ...
        'Units', 'normalized', ...
        'HorizontalAlignment', horizontal_alignment, ...
        'VerticalAlignment', vertical_alignment, ...
        'Visible', 'off');

    drawnow
    extent = get(h, 'Extent');
    [X, Y] = getlegendposition(axes_handles, nrows, ncols, location_option, extent, horizontal_alignment, vertical_alignment);
    set(h, 'Position', [X Y 0], 'Visible', 'on');
end



function overlay_ax = createoverlayaxes()
    overlay_ax = axes('Visible', 'off', ...
                      'Units', 'normalized', ...
                      'Position', [0 0 1 1], ...
                      'XLim', [0 1], ...
                      'YLim', [0 1], ...
                      'Tag', 'colorlegend_overlay', ...
                      'HitTest', 'off', ...
                      'HandleVisibility', 'off');
end



function [nrows, ncols, location_option, num_columns, num_columns_specified] = parselayoutinputs(varargin)
    nrows = [];
    ncols = [];
    location_option = 'bottom';
    num_columns = [];
    num_columns_specified = false;

    for i = 1:numel(varargin)
        arg = varargin{i};
        if isempty(nrows) && isnumeric(arg) && isscalar(arg)
            nrows = arg;
        elseif isempty(ncols) && isnumeric(arg) && isscalar(arg)
            ncols = arg;
        elseif ischar(arg) || (isstring(arg) && isscalar(arg))
            location_option = normalizelocation(arg);
        elseif isempty(num_columns) && isnumeric(arg) && isscalar(arg)
            num_columns = arg;
            num_columns_specified = true;
        else
            error('Unrecognized input argument: %s', mat2str(arg));
        end
    end

    if isempty(nrows) || isempty(ncols)
        error('Number of rows (nrows) and columns (ncols) must be specified.');
    end
    if ~isempty(num_columns) && (num_columns < 1 || floor(num_columns) ~= num_columns)
        error('num_columns must be a positive integer.');
    end
end



function validatelegendinputs(names, colors)
    if ~iscell(names)
        error('names must be a cell array.');
    end
    if ~isnumeric(colors) || size(colors, 2) ~= 3
        error('colors must be an Nx3 numeric array.');
    end
    if size(colors, 1) ~= numel(names)
        error('names and colors must have the same number of elements.');
    end
end



function str = buildlegendstring(names, colors, num_columns, location_option, num_columns_specified)
    num_items = numel(names);
    num_columns = max(1, min(num_columns, num_items));
    num_rows = ceil(num_items / num_columns);
    labels = cellfun(@char, names, 'UniformOutput', false);
    labels = cellfun(@(x) strrep(x, '_', '\_'), labels, 'UniformOutput', false);

    column_widths = zeros(1, num_columns);
    for col = 1:num_columns
        widths = [];
        for row = 1:num_rows
            idx = (row - 1) * num_columns + col;
            if idx <= num_items
                widths(end+1) = strlength_compat(labels{idx}); %#ok<AGROW>
            end
        end
        if ~isempty(widths)
            column_widths(col) = max(widths);
        end
    end

    if ~num_columns_specified && any(strcmp(location_option, {'top', 'bottom'}))
        base_gap = 4;
    else
        base_gap = 6;
    end

    lines = cell(num_rows, 1);
    for row = 1:num_rows
        line = '';
        for col = 1:num_columns
            idx = (row - 1) * num_columns + col;
            if idx > num_items
                continue
            end

            string_rgb = ['\color[rgb]{' sprintf('%5.3f, %5.3f, %5.3f', colors(idx,:)) '}'];
            label = labels{idx};
            entry = [string_rgb label];

            if col < num_columns
                pad_n = column_widths(col) - strlength_compat(label) + base_gap;
                entry = [entry repmat(' ', 1, max(1, pad_n))]; %#ok<AGROW>
            end

            line = [line entry]; %#ok<AGROW>
        end
        lines{row} = line;
    end

    str = sprintf('%s\n', lines{:});
    str = str(1:end-1);
end



function [horizontal_alignment, vertical_alignment] = getlegendalignment(location_option, num_columns, num_items)
    switch location_option
        case 'right'
            horizontal_alignment = 'left';
            vertical_alignment = 'middle';
        case 'left'
            horizontal_alignment = 'right';
            vertical_alignment = 'middle';
        case {'top', 'bottom'}
            if num_columns < num_items
                horizontal_alignment = 'left';
            else
                horizontal_alignment = 'center';
            end

            if strcmp(location_option, 'top')
                vertical_alignment = 'bottom';
            else
                vertical_alignment = 'top';
            end
        otherwise
            error('Invalid location option. Use: top, bottom, left, or right.');
    end
end



function [X, Y] = getlegendposition(axes_handles, nrows, ncols, location_option, extent, horizontal_alignment, vertical_alignment)
    padding = 0.012;
    text_width = extent(3);
    text_height = extent(4);

    switch location_option
        case 'top'
            row_index = 1;
            row_axes = axes_handles((row_index - 1) * ncols + (1:ncols));
            [left_bound, right_bound, bottom_bound, top_bound, tight_inset] = getaxesbounds(row_axes);
            Y = min(1 - padding - text_height, top_bound + tight_inset(4) + padding);

        case 'bottom'
            row_index = nrows;
            row_axes = axes_handles((row_index - 1) * ncols + (1:ncols));
            [left_bound, right_bound, bottom_bound, top_bound, tight_inset] = getaxesbounds(row_axes);
            Y = max(text_height + padding, bottom_bound - tight_inset(2) - padding);

        case 'left'
            col_index = 1;
            col_axes = axes_handles(col_index:ncols:end);
            [left_bound, right_bound, bottom_bound, top_bound, tight_inset] = getaxesbounds(col_axes);
            X = max(text_width + padding, left_bound - tight_inset(1) - padding);

        case 'right'
            col_index = ncols;
            col_axes = axes_handles(col_index:ncols:end);
            [left_bound, right_bound, bottom_bound, top_bound, tight_inset] = getaxesbounds(col_axes);
            X = min(1 - padding - text_width, right_bound + tight_inset(3) + padding);

        otherwise
            error('Invalid location option. Use: top, bottom, left, or right.');
    end

    if strcmp(horizontal_alignment, 'center')
        X = (left_bound + right_bound) / 2;
    elseif strcmp(horizontal_alignment, 'left')
        X = max(padding, (left_bound + right_bound - text_width) / 2);
    elseif strcmp(horizontal_alignment, 'right')
        X = min(1 - padding, (left_bound + right_bound + text_width) / 2);
    end

    if strcmp(vertical_alignment, 'middle')
        Y = (bottom_bound + top_bound) / 2;
    elseif strcmp(vertical_alignment, 'bottom') && strcmp(location_option, 'top')
        Y = min(1 - padding - text_height, Y);
    elseif strcmp(vertical_alignment, 'top') && strcmp(location_option, 'bottom')
        Y = max(text_height + padding, Y);
    end
end



function out = normalizelocation(location_option)
    location_option = lower(char(location_option));
    switch location_option
        case {'top', 'north'}
            out = 'top';
        case {'bottom', 'south'}
            out = 'bottom';
        case {'left', 'west'}
            out = 'left';
        case {'right', 'east'}
            out = 'right';
        otherwise
            error('Invalid location option. Use: top, bottom, left, or right.');
    end
end



function [left_bound, right_bound, bottom_bound, top_bound, tight_inset] = getaxesbounds(ax_group)
    positions = get(ax_group, 'Position');
    tight_insets = get(ax_group, 'TightInset');

    if iscell(positions)
        positions = cell2mat(positions);
    end
    if iscell(tight_insets)
        tight_insets = cell2mat(tight_insets);
    end

    left_bound = min(positions(:,1));
    right_bound = max(positions(:,1) + positions(:,3));
    bottom_bound = min(positions(:,2));
    top_bound = max(positions(:,2) + positions(:,4));
    tight_inset = max(tight_insets, [], 1);
end



function axes_handles = getlayoutaxes()
    axes_handles = flipud(findall(gcf, 'Type', 'axes', '-not', 'Tag', 'colorlegend_overlay'));
end



function out = strlength_compat(str)
    out = numel(char(str));
end
