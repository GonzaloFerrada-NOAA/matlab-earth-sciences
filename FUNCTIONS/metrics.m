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
  out.NMB   = sum(model - obs) / sum(obs);
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

  % Text labels:
  str.N     = sprintf('%d',out.N);
  str.R     = sprintf('%+0.2f',out.R);
  str.MB    = sprintf('%+f',out.MB);
  str.NMB   = sprintf('%+f',out.NMB);
  str.RMSE  = sprintf('%f',out.RMSE);

  L = 6;
  if numel(str.N) > 6
    L = numel(str.N);
  end

  % Horizontal text:
  out.TextH = ['N=' str.N ' R= ' str.R ' MB=' str.MB(1:L) ' NMB=' str.NMB(1:L) ' RMSE=' str.RMSE(1:L)];

  % Vertical text:
  line1     = ['   N = ' pad(        str.N, L, 'left')];
  line2     = ['   R = ' pad(        str.R, L, 'left')];
  line3     = ['  MB = ' pad(  str.MB(1:L), L, 'left')];
  line4     = [' NMB = ' pad( str.NMB(1:L), L, 'left')];
  line5     = ['RMSE = ' pad(str.RMSE(1:L), L, 'left')];
  out.Text  = {line1; line2; line3; line4; line5};

end