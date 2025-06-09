function h = colorlegend(X, Y, names, colors, horiz_opt)
  
  if ~exist('horiz_opt', 'var') | strcmpi(horiz_opt, 'horiz') | strcmpi(horiz_opt, 'h') | strcmpi(horiz_opt, 'horizontal')
    horiz_opt = true;
  else
    horiz_opt = false;
  end
  
  TAB = '    ';
  for i = 1:numel(names)
    
    string_rgb = ['\color[rgb]{' sprintf('%5.3f, %5.3f, %5.3f', colors(i,:)) '}'];
    
    if i == 1
      
      str = [string_rgb char(names{i})];
      
    elseif i > 1 %& i < numel(names)
      
      str = [str TAB string_rgb char(names{i})];
      
    end
    
  end
  
  FIG = get(gcf);
  
  axes('Visible','off','Position',[0 0 1 1]);
  axis([0 FIG.Position(3) 0 FIG.Position(4)])
  
  h = text(X, Y, strrep(str, '_', '\_'), 'Interpreter', 'tex', 'HorizontalAlignment', 'center');
  
end