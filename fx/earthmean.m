function m = earthmean(data, gridarea, nanflag)
%EARTHMEAN Area-weighted global mean of a 2-D gridded variable
%
%   m = earthmean(data, gridarea)
%   m = earthmean(data, gridarea, 'omitnan')
%   m = earthmean(data, gridarea, 'includenan')
%
% Inputs:
%   data     - 2-D array
%   gridarea - 2-D array of grid-cell areas (same size as data)
%   nanflag  - optional: 'omitnan' or 'includenan' (default: 'includenan')
%
% Output:
%   m - area-weighted mean

    narginchk(2,3)

    if ~isequal(size(data), size(gridarea))
        error('data and gridarea must have the same size.');
    end

    if any(gridarea(:) < 0, 'all')
        error('gridarea must be nonnegative.');
    end

    if nargin < 3 || isempty(nanflag)
        nanflag = 'includenan';
    end

    switch lower(nanflag)
        case 'omitnan'
            mask = ~isnan(data) & ~isnan(gridarea);
            wsum = sum(gridarea(mask));
            if wsum == 0
                m = NaN;
                return
            end
            m = sum(data(mask) .* gridarea(mask)) / wsum;

        case 'includenan'
            wsum = sum(gridarea(:));
            if wsum == 0
                m = NaN;
                return
            end
            m = sum(data(:) .* gridarea(:)) / wsum;

        otherwise
            error("nanflag must be 'omitnan' or 'includenan'.");
    end
end