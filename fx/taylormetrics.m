function metrics = taylormetrics(obs, model)
% TAYLORMETRICS  Core metrics for Taylor diagram from paired obs & model.
% Usage:
%   metrics = taylormetrics(obs, model)
%
% Inputs:
%   obs, model : same size arrays (any dimensionality). User handles any
%                regridding/area weighting beforehand. NaN pairs are ignored.
%
% Output (struct):
%   metrics.r      : correlation coefficient (Pearson)
%   metrics.nrmse  : centered RMSE normalized by sigma_obs
%   metrics.sigma  : normalized std = sigma_model / sigma_obs
%
% Definitions (population form):
%   mu_x      = mean(x)
%   sigma_x   = sqrt(mean((x - mu_x).^2))
%   cov_xy    = mean((x - mu_x).*(y - mu_y))
%   r         = cov_xy / (sigma_x * sigma_y)
%   cRMSE     = sqrt(mean(((x - mu_x) - (y - mu_y)).^2))
%   nRMSE     = cRMSE / sigma_obs

    % ---- input checks ----
    if ~isequal(size(obs), size(model))
        error('obs and model must have the same size.');
    end

    % Vectorize and keep only paired finite samples
    obs   = obs(:);
    model = model(:);
    mask  = isfinite(obs) & isfinite(model);
    if nnz(mask) < 2
        error('Not enough valid paired samples to compute metrics.');
    end
    o = obs(mask);
    m = model(mask);

    % Means (population)
    mu_o = mean(o);
    mu_m = mean(m);

    % Anomalies
    oa = o - mu_o;
    ma = m - mu_m;

    % Population standard deviations
    sig_o = std(o);
    sig_m = std(m);

    if sig_o == 0 || sig_m == 0
        % Degenerate case: one series has no variability
        metrics.r     = NaN;
        % cRMSE still well-defined:
        cRMSE         = sqrt(mean((ma - oa).^2));
        metrics.nrmse = (sig_o==0) * NaN + (sig_o>0) * (cRMSE / sig_o);
        metrics.sigma = (sig_o==0) * NaN + (sig_o>0) * (sig_m / sig_o);
        return
    end

    % Correlation (Pearson, population form)
    cov_om = mean(oa .* ma);
    r = cov_om / (sig_o * sig_m);

    % Centered RMSE and normalized versions
    cRMSE  = sqrt(mean((ma - oa).^2));
    nsigma = sig_m / sig_o;

    % Pack results
    metrics.r     = r;
    metrics.cRMSE = cRMSE;
    metrics.nSTD  = nsigma;
    
end