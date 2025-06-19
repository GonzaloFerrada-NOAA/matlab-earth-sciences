function cb = densityscatter(X, dataX, dataY, varargin)
  
  p = inputParser;
  p.CaseSensitive = false;
  
  addRequired(p, 'X');
  addRequired(p, 'dataX');
  addRequired(p, 'dataY');
  addOptional(p, 'logopt', 'linear', @(x) any(validatestring(x,{'linear', 'log'})));
  
  addParameter(p, 'Levels',   [])
  addParameter(p, 'Colorbar', 'off')
  addParameter(p, 'Colormap', hue('gmao2'))
  
  p.KeepUnmatched = false;

  parse(p, X, dataX, dataY, varargin{:})

  opts = p.Results;
  
  % ------------------------------------------------------------------------
  
  % logarithmic flag:
  islog = strcmpi(opts.logopt, 'log');
  
  % Check whether we need to construct X:
  if numel(X) == 2
    if islog
      X = logspace(log10(X(1)), log10(X(2)), 100);
    else
      X = linspace(X(1), X(2), 100);
    end
  end
  
  % Order data:
  dataX = dataX(:);
  dataY = dataY(:);
  
  if numel(dataX) ~= numel(dataY)
    error('dataX and dataY should have the same number of elements.')
  end
  
  % Filter NaN data:
  idx         = isnan(dataX) | isnan(dataY);
  dataX(idx)  = [];
  dataY(idx)  = [];
  
  % Initialization:
  data = zeros(numel(X), numel(X));
  
  % Find index in grid - Matlab approach:
  for i = 1:numel(dataX)
    
    [~,x]     = min(abs(X - dataX(i)));
    [~,y]     = min(abs(X - dataY(i)));
    data(x,y) = data(x,y) + 1;
    
  end
  
  % To resize (smooth) data:
  % data = imresize(data, [1 1] * 2000);
  
  % Last fixes:
  data(data == 0) = NaN;
  data            = data';
  
  % Check is user wants specific levels in colorbar:
  if ~( isempty(opts.Levels) )
    
      [data, cbartick, cbarticklabel] = data2levels(data, opts.Levels);
      opts.Colorbar = 'on';
      
  end
  
  % Plot:
  imagesc([X(1) X(end)], [X(1) X(end)], data, 'AlphaData', ~isnan(data))
  hold on
  set(gca,'YDir','normal', 'TickDir', 'both')
  set(gca,'Colormap', opts.Colormap)
  axis square
  
  set(gca,'ColorScale','log')
  
  if islog
    
    set(gca,'XLim', [X(1) - (X(2) - X(1)) X(end) + (X(end) - X(end-1))], 'YLim', [X(1) - (X(2) - X(1)) X(end) + (X(end) - X(end-1))])
    set(gca,'YScale', 'log', 'XScale', 'log')
    XT = [.001 .002 .005 .01 .02 .05 .1 .2 .5 1 2 5 10 20 50 100 200 500 1e3 2e3 5e3 1e4 2e4 5e4 1e5];
    set(gca,'XTick', XT, 'YTick', XT)
    plot([1e-10 1e10], [1e-10 1e10], 'Color', [1 1 1] * 0.15)
    
  else
    
    plot([-1 1] * 1e6, [-1 1] * 1e6, 'Color', [1 1 1] * 0.15)
    
  end
  
  % Colorbar:
  switch opts.Colorbar
  case 'on'
      cb = colorbar('TickDirection','both');
      
      if ~(isempty(opts.Levels))
          set(gca,'CLim',[cbartick(1) cbartick(end)])
          set(cb,'YTick',cbartick,'YTickLabel',cbarticklabel)
          set(gca,'ColorScale','linear')
      end
      
  otherwise
      cb = [];
  end
  
  % Figure properties:
  set(gca,'Layer','top','Box','on')
  set(gcf,'InvertHardcopy', 'off')
  

end






function [dataout, cbarticks, clabels] = data2levels(datain, levels)
  
  % Prepare data:
  dataout   = nan(size(datain));
  cbarticks = 1:numel(levels);
  clabels   = num2str(levels');
  
  % Data values < levels(1):
  dataout( datain < levels(1) )   = 1;
  
  for i = 1:numel(levels) - 1
    
    idx = datain >= levels(i) & datain < levels(i + 1);
    dataout( idx ) = i;
    
  end
  
  % Data values >= levels(end):
  dataout( datain >= levels(end)) = numel(levels);
  
end