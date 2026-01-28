function h = basemap(varargin)
%BASEMAP Overlay an image as a basemap on existing axes (uses imagesc).
%
%   basemap(file)
%   basemap(file, x_extent, y_extent)
%   basemap(ax, file)
%   basemap(ax, file, x_extent, y_extent)
%
% Inputs
%   ax        (optional) axes handle or array of axes handles
%   file      image file path (jpg/png/tif/...)
%   x_extent  (optional) [xmin xmax] to span image in x
%   y_extent  (optional) [ymin ymax] to span image in y
%
% Output
%   h         image handle(s) (only returned if requested)
%
% Notes
%   - Converts indexed/grayscale images to truecolor RGB so it does NOT
%     touch the user's colormap.
%   - Sends the image to the bottom of the stack (uistack bottom).

    % ---- Parse inputs ----------------------------------------------------
    ax = [];
    if nargin < 1
        error('basemap:NotEnoughInputs','You must provide at least an image file.');
    end

    k = 1;
    if isAxesLike(varargin{1})
        ax = varargin{1};
        k = 2;
        if nargin < 2
            error('basemap:NotEnoughInputs','If first input is axes, second must be file.');
        end
    end

    file = varargin{k}; k = k + 1;
    if ~(ischar(file) || (isstring(file) && isscalar(file)))
        error('basemap:BadFile','file must be a char or scalar string.');
    end
    file = char(file);

    x_extent = [];
    y_extent = [];
    if (nargin - (k-1)) >= 1
        x_extent = varargin{k}; k = k + 1;
    end
    if (nargin - (k-1)) >= 1
        y_extent = varargin{k}; k = k + 1;
    end
    if (nargin - (k-1)) >= 1
        error('basemap:TooManyInputs','Too many inputs.');
    end

    if isempty(ax)
        ax = gca;
    end

    if ~isempty(x_extent)
        validateattributes(x_extent, {'numeric'}, {'vector','numel',2,'finite','real'});
        x_extent = double(x_extent(:)).';
    end
    if ~isempty(y_extent)
        validateattributes(y_extent, {'numeric'}, {'vector','numel',2,'finite','real'});
        y_extent = double(y_extent(:)).';
    end
    
    path_static = getenv('MATLAB_STATIC');
    if ~isempty(path_static)
        addpath(path_static)
    end

    % ---- Read + convert image to truecolor RGB ----------------------------
    [I, map] = imread(file);

    % Convert to RGB so we never need to change the colormap
    I_rgb = toTrueColorRGB(I, map);  % uint8 or double, size MxNx3

    % ---- Apply to each axes ----------------------------------------------
    ax = ax(:);
    h_local = gobjects(numel(ax), 1);

    for ia = 1:numel(ax)
        a = ax(ia);
        if ~ishandle(a) || ~strcmp(get(a,'Type'),'axes')
            error('basemap:BadAxes','Invalid axes handle(s).');
        end

        % Decide extents: use provided, otherwise current axis limits
        if isempty(x_extent)
            xl = xlim(a);
        else
            xl = x_extent;
        end
        if isempty(y_extent)
            yl = ylim(a);
        else
            yl = y_extent;
        end

        % Preserve key axes state
        oldNextPlot = a.NextPlot;
        oldXLim = xlim(a);
        oldYLim = ylim(a);
        oldYDir = a.YDir;

        % Make sure we don't blow away existing content
        a.NextPlot = 'add';

        % Draw image
        h_img = imagesc(a, xl, flip(yl), I_rgb);

        % Keep it from interfering with user interactions/legends
        set(h_img, 'HandleVisibility','off', 'HitTest','off', 'PickableParts','none');

        % Send to bottom
        uistack(h_img, 'bottom');

        % Restore axes properties that imagesc may modify
        a.YDir = oldYDir;

        % If user didn't specify extents, restore original limits exactly
        if isempty(x_extent), xlim(a, oldXLim); end
        if isempty(y_extent), ylim(a, oldYLim); end

        a.NextPlot = oldNextPlot;

        h_local(ia) = h_img;
    end

    if nargout > 0
        h = h_local;
    end
end

% -------------------------------------------------------------------------
function tf = isAxesLike(x)
    tf = false;
    if isempty(x), return; end
    if isa(x, 'matlab.graphics.axis.Axes')
        tf = true;
        return;
    end
    if all(ishandle(x(:)))
        try
            t = get(x(:), 'Type');
            if ischar(t)
                tf = strcmp(t, 'axes');
            elseif iscell(t)
                tf = all(strcmp(t, 'axes'));
            end
        catch
            tf = false;
        end
    end
end

function I_rgb = toTrueColorRGB(I, map)
    % Convert any imread output into truecolor RGB without relying on colormap.

    if ndims(I) == 3 && size(I,3) == 3
        % Already RGB
        I_rgb = I;
        return;
    end

    if ~isempty(map)
        % Indexed image: I is indices into map
        % ind2rgb expects double indices starting at 1 for uint8/uint16,
        % and uses colormap rows.
        I_rgb = ind2rgb(I, map);   % returns double in [0,1]
        return;
    end

    % Grayscale or other 2-D intensity image: replicate to RGB
    if isfloat(I)
        % assume already in [0,1] or any float range; replicate
        I_rgb = cat(3, I, I, I);
    else
        % uint8/uint16/etc.
        I_rgb = repmat(I, 1, 1, 3);
    end
end