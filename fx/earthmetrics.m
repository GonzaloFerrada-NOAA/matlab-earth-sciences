function M = earthmetrics(obs, model, metric, nanflag)
%EARTHMETRICS Gridpoint metrics for 3-D observed vs modeled fields
%
%   M = earthmetrics(obs, model, metric)
%   M = earthmetrics(obs, model, metric, 'omitnan')
%
%   Computes a requested metric at each grid point across the 3rd dimension
%   (e.g., time/ensemble/member), returning a 2-D field.
%
%   Inputs
%   ------
%   obs    : 3-D numeric array (ny x nx x nt) of observations
%   model  : 3-D numeric array (ny x nx x nt) of model values (same size as obs)
%   metric : char/string, case-insensitive. Supported:
%              'bias'  : mean(model - obs)
%              'nmb'   : normalized mean bias = 100 * sum(model-obs)/sum(obs)
%              'rmse'  : sqrt(mean((model-obs).^2))
%              'sd'    : standard deviation of (model - obs)
%              'r'     : Pearson correlation coefficient between model and obs
%              'r2'    : R.^2
%              'meano' : mean(obs)    (optional convenience)
%              'meanm' : mean(model)  (optional convenience)
%   nanflag: optional 'omitnan' to ignore NaNs pairwise at each grid point.
%            Default is 'includenan' (any NaN in the series yields NaN metric).
%
%   Output
%   ------
%   M : 2-D numeric array (ny x nx) containing the metric at each grid point.
%
%   Notes
%   -----
%   - Metrics are computed along dimension 3.
%   - For 'omitnan', only time steps where BOTH obs and model are finite are used.
%   - For correlation, if fewer than 2 valid samples exist, result is NaN.
%
%   Example
%   -------
%   RMSE = earthmetrics(obs, mod, 'rmse', 'omitnan');

    narginchk(3,4)

    if ~isequal(size(obs), size(model))
        error('obs and model must be the same size (ny x nx x nt).');
    end
    if ndims(obs) ~= 3
        error('obs and model must be 3-D (ny x nx x nt).');
    end

    metric = lower(string(metric));

    if nargin < 4
        nanflag = 'includenan';
    end
    nanflag = lower(string(nanflag));
    useOmit = (nanflag == "omitnan");

    % Basic derived arrays
    D = model - obs;

    switch metric
        case "bias"
            if useOmit
                M = mean(D, 3, 'omitnan');
            else
                M = mean(D, 3);
            end

        case "rmse"
            if useOmit
                M = sqrt(mean(D.^2, 3, 'omitnan'));
            else
                M = sqrt(mean(D.^2, 3));
            end

        case "sd"
            % SD of the error (model-obs) across dim 3
            if useOmit
                M = std(D, 0, 3, 'omitnan');
            else
                M = std(D, 0, 3);
            end

        case "nmb"
            % 100 * sum(model-obs)/sum(obs)
            if useOmit
                % pairwise omit: keep only where both are finite
                mask = isfinite(obs) & isfinite(model);
                num  = sum((model - obs) .* mask, 3);
                den  = sum(obs .* mask, 3);
            else
                num  = sum(model - obs, 3);
                den  = sum(obs, 3);
            end
            M = 100 * (num ./ den);
            M(den == 0) = NaN;

        case "r"
            M = local_corr2d(obs, model, useOmit);

        case "r2"
            R = local_corr2d(obs, model, useOmit);
            M = R.^2;

        case "meano"
            if useOmit
                M = mean(obs, 3, 'omitnan');
            else
                M = mean(obs, 3);
            end

        case "meanm"
            if useOmit
                M = mean(model, 3, 'omitnan');
            else
                M = mean(model, 3);
            end

        otherwise
            error("Unsupported metric '%s'. Try: bias, nmb, rmse, sd, r, r2.", metric);
    end
end

function R = local_corr2d(A, B, useOmit)
% Pearson correlation at each (y,x) across dim 3.
% Pairwise omit: uses only indices where both are finite.

    if ~useOmit
        % Fast path: if any NaN exists along dim3, correlation becomes NaN
        % (handled naturally by sums below if NaNs propagate).
        mask = true(size(A));
    else
        mask = isfinite(A) & isfinite(B);
    end

    % Replace invalid with 0 so masked sums work
    A0 = A; B0 = B;
    A0(~mask) = 0;
    B0(~mask) = 0;

    n = sum(mask, 3);

    % Means (masked)
    muA = sum(A0, 3) ./ n;
    muB = sum(B0, 3) ./ n;

    % Centered (masked)
    Ac = A0 - muA;
    Bc = B0 - muB;
    Ac(~mask) = 0;
    Bc(~mask) = 0;

    Sxx = sum(Ac.^2, 3);
    Syy = sum(Bc.^2, 3);
    Sxy = sum(Ac .* Bc, 3);

    R = Sxy ./ sqrt(Sxx .* Syy);

    % Not enough points or zero variance -> NaN
    R(n < 2) = NaN;
    R(Sxx == 0 | Syy == 0) = NaN;
end