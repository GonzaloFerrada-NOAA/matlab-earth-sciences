function out = metrics(observation, modeled, garea, metricsToShow, numFormat)
  % metrics calculates a bunch of commonly used metrics used to evaluate
  % the performance of a model against observation data.
  % Usage:
  % data = metrics(observation_data, modeled_data);
  % data = metrics(observation_data, modeled_data, garea);
  % data = metrics(observation_data, modeled_data, garea, metricsToShow);
  % data = metrics(observation_data, modeled_data, garea, metricsToShow, numFormat);
  %
  % Optional input:
  % garea         : Weights for each point (same size as inputs). Metrics are
  %                 calculated as weighted averages using garea. Pass [] to
  %                 skip weighting while still specifying later arguments.
  % metricsToShow : Cell array of metric names to include in Text/TextH, and
  %                 in what order. Any of 'N', 'R', 'R2', 'MB', 'NMB', 'MSE',
  %                 'RMSE', 'cRMSE'. Default: {'N','R','MB','NMB','RMSE','cRMSE'}.
  % numFormat     : sprintf-style format spec (e.g. '%.4f') applied to all
  %                 float metrics in Text/TextH. NMB is formatted with one
  %                 fewer decimal place than numFormat to leave room for the
  %                 '%'. Not applied to N. Default ([] or ''): legacy
  %                 3-decimal formatting with a scientific-notation fallback
  %                 for tiny values.
  %
  % output 'data' is a struct that contains the fields:
  % N         : Number of points that are not NaN
  % R         : Correlation coefficient
  % R2        : Coefficient of determination
  % MB        : Mean bias
  % NMB       : Normalized mean bias
  % MSE       : Mean squared error
  % RMSE      : Root mean squared error
  % cRMSE     : Bias-removed (centered) root mean squared error
  % Slope     : Slope of linear fitting
  % Intercept : Intercept of linear fitting
  % LinearX   : Sample X data of linear fitting
  % LinearY   : Sample Y data of linear fitting
  % Text      : Text with the selected metrics (vertical)
  % TextH     : Text with the selected metrics (horizontal)
  %
  % Author: Gonzalo A. Ferrada (gonzalo.ferrada@noaa.gov)
  % September 2024
  %
  % First developed as comp_metrics in 2020 and completely redesigned
  % in September 2024, by including new metrics and linear fitting.
  %

  if nargin < 3
      garea = [];
  end
  if nargin < 4 || isempty(metricsToShow)
      metricsToShow = {'N', 'R', 'MB', 'NMB', 'RMSE', 'cRMSE'};
  end
  if nargin < 5
      numFormat = '';
  end

  allMetrics = {'N', 'R', 'R2', 'MB', 'NMB', 'MSE', 'RMSE', 'cRMSE'};
  unknown = metricsToShow(~ismember(metricsToShow, allMetrics));
  if ~isempty(unknown)
      error('Unknown metric(s) in metricsToShow: %s', strjoin(unknown, ', '))
  end

  % Read input data:
  obs     = observation(:);
  model   = modeled(:);
  useWeights = ~isempty(garea);

  % Check for errors:
  if numel(obs) ~= numel(model)
      error('Inputs should have the same number of elements')
  end
  if useWeights
      gareaVec = garea(:);
      if numel(gareaVec) ~= numel(obs)
          error('Inputs should have the same number of elements')
      end
      if ~isnumeric(gareaVec)
          error('garea must be numeric')
      end
      if any(gareaVec < 0)
          error('garea must be nonnegative')
      end
      invalidGarea = (isfinite(obs) | isfinite(model)) & isnan(gareaVec);
      if any(invalidGarea)
          error('garea contains NaNs where observation or modeled values are finite')
      end
  else
      gareaVec = [];
  end

  % Remove NaNs:
  nanMask    = isnan(model) | isnan(obs);
  obs(nanMask)    = [];
  model(nanMask)  = [];
  if useWeights
      gareaVec(nanMask) = [];
      if any(isnan(gareaVec))
          error('garea contains NaNs where observation or modeled values are finite')
      end
      weightSum = sum(gareaVec);
      if weightSum == 0
          error('garea weights sum to zero')
      end
      weights = gareaVec ./ weightSum;
  else
      weights = ones(size(obs)) ./ max(numel(obs), 1);
  end

  % Calculate metrics:
  out.N     = numel(obs);
  % out.R     = corrcoef(obs, model);
  % out.R     = out.R(2,1);
  meanModel = sum(weights .* model);
  meanObs   = sum(weights .* obs);
  out.R     = sum(weights .* (model - meanModel) .* (obs - meanObs)) / ...
              sqrt( sum(weights .* (model - meanModel) .^ 2 ) *  sum(weights .* (obs - meanObs) .^ 2 ));
  out.R2    = out.R ^ 2;
  out.MB    = sum(weights .* (model - obs));
  out.NMB   = (sum(weights .* (model - obs)) / sum(weights .* obs)) * 100;
  out.MSE   = sum(weights .* (model - obs) .^ 2);
  out.RMSE  = sqrt(out.MSE);
  out.cRMSE = sqrt(out.MSE - out.MB ^ 2); % bias-removed (centered) RMSE
  out.Weights = weights;

  % Calculate linear regression coefficients:
  out.Slope     = sum(weights .* (obs - meanObs) .* (model - meanModel)) / sum(weights .* (obs - meanObs) .^ 2);
  out.Intercept = meanModel - out.Slope * meanObs;
  % using polyfit gives the same values.

  % Give some data sample to be ready to plot:
  mini = min([obs; model]) * 0.01;
  maxi = max([obs; model]) * 20;

  out.LinearX = linspace(mini, maxi, 500);
  out.LinearY = out.Slope .* out.LinearX + out.Intercept;

  % Text labels (metric-specific formatting):
  values.N     = out.N;
  values.R     = out.R;
  values.R2    = out.R2;
  values.MB    = out.MB;
  values.NMB   = out.NMB;
  values.MSE   = out.MSE;
  values.RMSE  = out.RMSE;
  values.cRMSE = out.cRMSE;

  percentMetrics     = {'NMB'};
  nonnegativeMetrics = {'R2', 'MSE', 'RMSE', 'cRMSE'};
  signedMetrics      = {'R', 'MB', 'NMB'};

  nShow = numel(metricsToShow);
  strs  = cell(nShow, 1);
  for i = 1:nShow
      name = metricsToShow{i};
      if strcmp(name, 'N')
          strs{i} = sprintf('%d', out.N);
          continue
      end
      s = fmt_num(values.(name), 3, ismember(name, percentMetrics), numFormat);
      if ismember(name, nonnegativeMetrics) && ~isempty(s) && s(1) == '+'
          s = s(2:end); % Removing leading '+' since this metric is always >= 0
      elseif ismember(name, signedMetrics) && ~isempty(s) && s(1) >= '0' && s(1) <= '9'
          s = ['+' s]; % numFormat without a '+' flag: still show sign for +/- metrics
      end
      strs{i} = s;
  end

  % Vertical text: use padding for alignment.
  labelWidth = max(cellfun(@numel, metricsToShow));
  valueWidth = max(cellfun(@numel, strs));
  out.Text = cell(nShow, 1);
  for i = 1:nShow
      out.Text{i} = [pad(metricsToShow{i}, labelWidth, 'left') ' = ' pad(strs{i}, valueWidth, 'left')];
  end

  % Horizontal text: no padding (compact).
  parts = cell(nShow, 1);
  for i = 1:nShow
      parts{i} = [metricsToShow{i} '=' strs{i}];
  end
  out.TextH = strjoin(parts, ' ');

end

function s = fmt_num(x, ndp, isPercent, numFormat)
%FMT_NUM Format numeric metrics with metric-specific precision.
% - If numFormat is given (non-empty), uses that sprintf format spec
%   (e.g. '%.4f'); percent values use one fewer decimal than numFormat
%   to leave room for the '%'.
% - Otherwise, uses fixed-point with ndp decimals by default, switching
%   to scientific notation when fixed-point would round to 0, and percent
%   values replace their last digit with '%' to make room for it.

  if nargin < 2 || isempty(ndp)
    ndp = 3;
  end
  if nargin < 3 || isempty(isPercent)
    isPercent = false;
  end
  if nargin < 4
    numFormat = '';
  end

  if isempty(x) || isnan(x)
    s = 'NaN';
  elseif isinf(x)
    if x > 0
      s = '+Inf';
    else
      s = '-Inf';
    end
  elseif ~isempty(numFormat)
    if isPercent
      fmt = adjust_precision(numFormat, -1);
    else
      fmt = numFormat;
    end
    s = sprintf(fmt, x);
    if isPercent
      s = [s '%'];
    end
    return
  else
    ax = abs(x);

    % If fixed-point would print as 0.000... but value is nonzero, use scientific.
    tiny = 10^(-ndp);
    if ax > 0 && ax < tiny
      s = sprintf(['%+.' num2str(2) 'e'], x);
    else
      s = sprintf(['%+.' num2str(ndp) 'f'], x);
    end
  end

  if isPercent
    s = [s(1:end-1) '%'];
  end
end

function fmt = adjust_precision(numFormat, delta)
%ADJUST_PRECISION Shift the precision (digits after '.') of a sprintf
% format spec like '%.4f' by delta, clamped at 0. Specs without an
% explicit precision are returned unchanged.

  tok = regexp(numFormat, '\.(\d+)', 'tokens', 'once');
  if isempty(tok)
    fmt = numFormat;
    return
  end
  newPrec = max(str2double(tok{1}) + delta, 0);
  fmt = regexprep(numFormat, '\.(\d+)', ['.' num2str(newPrec)], 'once');
end
