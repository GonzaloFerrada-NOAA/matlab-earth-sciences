function m = earthmean(data, gridarea, nanflag)
%EARTHMEAN gridarea-weighted global mean of a 2-D gridded variable
%
%   m = earthmean(data, gridarea)
%   m = earthmean(data, gridarea, 'omitnan')
%
%   Inputs:
%     data      - 2-D array of the variable
%     gridarea  - 2-D array of grid-cell areas (same size as data)
%     nanflag   -  optional, 'omitnan' to ignore NaNs (default: include NaNs)
%
%   Output:
%     m       - gridarea-weighted global mean

    narginchk(2,3)

    if ~isequal(size(data), size(gridarea))
        error('data and gridarea must have the same size.');
    end

    if nargin < 3
        nanflag = 'includenan';
    end

    switch lower(nanflag)
        case 'omitnan'
            mask = ~isnan(data) & ~isnan(gridarea);
            wsum = sum(gridarea(mask));
            m    = sum(data(mask) .* gridarea(mask)) / wsum;

        case 'includenan'
            wsum = sum(gridarea(:));
            m    = sum(data(:) .* gridarea(:)) / wsum;

        otherwise
            error("nanflag must be 'omitnan'.");
    end
end