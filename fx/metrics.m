function out = metrics(observation, modeled)
  % metrics calculates a bunch of commonly used metrics used to evaluate
  % the performance of a model against observation data.
  % Usage:
  % data = metrics(observation_data, modeled_data);
  %
  % output 'data' is a struct that contains the fields:
  % N         : Number of points that are not NaN
  % R         : Correlation coefficient
  % R2        : Coefficient of determination
  % MB        : Mean bias
  % NMB       : Normalized mean bias
  % MSE       : Mean squared error
  % RMSE      : Root mean squared error
  % Slope     : Slope of linear fitting
  % Intercept : Intercept of linear fitting
  % LinearX   : Sample X data of linear fitting
  % LinearY   : Sample Y data of linear fitting
  % Text      : Text with N, R, MB, NMB and RMSE (vertical)
  % TextH     : Text with N, R, MB, NMB and RMSE (horizontal)
  %
  % Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
  % September 2024
  %
  % First developed as comp_metrics in 2020 and completely redesigned
  % in September 2024, by including new metrics and linear fitting.
  %
  
  % Read input data:
  obs     = observation(:);
  model   = modeled(:);

  % Check for errors:
  if numel(obs) ~= numel(model)
      error('Inputs should have the same number of elements')
  end

  % Remove NaNs:
  I         = isnan(model) | isnan(obs);
  obs(I)    = [];
  model(I)  = [];

  % Calculate metrics:
  out.N     = numel(obs);
  % out.R     = corrcoef(obs, model);
  % out.R     = out.R(2,1);
  out.R     = sum((model - mean(model)) .* (obs - mean(obs))) / sqrt( sum((model - mean(model)) .^ 2 ) *  sum((obs - mean(obs)) .^ 2 ));
  out.R2    = out.R ^ 2;
  out.MB    = sum(model - obs) / out.N;
  out.NMB   = (sum(model - obs) / sum(obs)) * 100;
  out.MSE   = sum((model - obs) .^ 2) / out.N;
  out.RMSE  = sqrt( sum((model - obs) .^ 2) / out.N );

  % Calculate linear regression coefficients:
  out.Slope     = (out.N * sum(obs .* model) - sum(obs) * sum(model)) / (out.N * sum(obs .^ 2) - (sum(obs)) ^ 2);
  out.Intercept = (sum(model) - out.Slope * sum(obs)) / out.N;
  % using polyfit gives the same values.

  % Give some data sample to be ready to plot:
  mini = min([obs; model]) * 0.01;
  maxi = max([obs; model]) * 20;

  out.LinearX = linspace(mini, maxi, 500);
  out.LinearY = out.Slope .* out.LinearX + out.Intercept;

  % Text labels (metric-specific formatting):
  str.N    = sprintf('%d', out.N);
  str.R    = fmt_num(out.R,    3, false);
  str.MB   = fmt_num(out.MB,   3, false);
  str.NMB  = fmt_num(out.NMB,  3, true);   % includes %
  str.RMSE = fmt_num(out.RMSE, 3, false);

  % Vertical text: use padding for alignment.
  W = max([numel(str.N), numel(str.R), numel(str.MB), numel(str.NMB), numel(str.RMSE)]);
  line1    = ['   N = ' pad(str.N,    W, 'left')];
  line2    = ['   R = ' pad(str.R,    W, 'left')];
  line3    = ['  MB = ' pad(str.MB,   W, 'left')];
  line4    = [' NMB = ' pad(str.NMB,  W, 'left')];
  line5    = ['RMSE = ' pad(str.RMSE, W, 'left')];
  out.Text = {line1; line2; line3; line4; line5};

  % Horizontal text: no padding (compact).
  out.TextH = ['N=' str.N ...
               ' R=' str.R ...
               ' MB=' str.MB ...
               ' NMB=' str.NMB ...
               ' RMSE=' str.RMSE];

end

function s = fmt_num(x, ndp, isPercent)
%FMT_NUM Format numeric metrics with metric-specific precision.
% - Uses fixed-point with ndp decimals by default.
% - Switches to scientific notation when fixed-point would round to 0.
% - Optionally appends '%' for percent metrics.

  if nargin < 2 || isempty(ndp)
    ndp = 3;
  end
  if nargin < 3
    isPercent = false;
  end

  if isempty(x) || isnan(x)
    s = 'NaN';
  elseif isinf(x)
    if x > 0
      s = '+Inf';
    else
      s = '-Inf';
    end
  else
    ax = abs(x);

    % If fixed-point would print as 0.000... but value is nonzero, use scientific.
    tiny = 10^(-ndp);
    if ax > 0 && ax < tiny
      s = sprintf(['%+.' num2str(2) 'e'], x);
    else
      s = sprintf(['%+.' num2str(ndp) 'f'], x);
      % Trim trailing zeros and orphan decimal point.
      s = regexprep(s, '0+$', '');
      s = regexprep(s, '\.$', '');
    end
  end

  if isPercent
    s = [s(1:end-1) '%'];
  end
end