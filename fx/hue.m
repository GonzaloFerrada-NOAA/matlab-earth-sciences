% HUE is a powerful function that can return html colors to use in MATLAB.
% Returned value(s) are in the format of signed integers.
% HUE can use any of the 100+ HTML colors to create custom colormaps as well.
% Requirement:
% - htmlcolors.csv    Contains information related to HTML colors

function out = hue(varargin)
  
  % Initilize:
  iscolormap  = false;
  issingle    = false;
  N_hues      = 256;      % Default number of colors in output if colormap
  
  % Check inputs:
  lastarg     = cell2mat(varargin(nargin));
  
  % Required variables to be able to analyze inputs:
  colortable = readtable('htmlcolors.csv');
  cmaps = {'jet2','jet3','whitejet','gmao','cams','o3' ,'co','blh','clouds', ...
           'sat','oc','bc','rh','wind','ext','pm','pastel','temp','nox', ...
           'rainbow','frp','ncl','city','anom','anom2','anom3','anom4','pro','acc','gmao2', ...
           'finn','hum','aod','baod','emis','usgs','bright','daod','melt', ...
           'grav','ceres','giss','ppa'};
  %
  % Check if user specified the number of colors in output colormap, 
  % if not assing a default value:
  if isnumeric(lastarg) & numel(lastarg) == 1
    names  = varargin(1:end-1);
    N_hues = lastarg;
  else
    names  = varargin;
  end
  
  % Check inputs:
  if nargin == 1
    
    % This can be either a single html color -or- the user may be requesting
    % one of the multiple predefined colormaps:
    if ismember(names, cmaps)
      % User wants a predefined colormap:
      iscolormap    = true;
    else
      % This is a request for a single color input and output:
      issingle  = true;
      N_hues    = 1;
    end
    
  elseif nargin > 1
    
    iscolormap = true;
    
    % Check if user wants an specific number of colors in colormap:
    if isnumeric(lastarg) & numel(lastarg) == 1
      
      N_hues = lastarg;
      
    end
    
  end
  
  % Get names if predefined colormap:
  if iscolormap & numel(names) == 1 & ismember(names{1}, cmaps)

    switch names{1}
    case 'jet2'
      names = {'royalblue','cyan','yellow','red'};
    
    case 'jet3'
      names = {'dodgerblue','cyan','yellow','red'};
    
    case 'whitejet'
      names = {[254 254 254],'royalblue','cyan','yellow','red'};
    
    case 'gmao'
      names = {[254 254 254],[242 236 252],[228 217 251],[200 193 250],[171 168 248],[118 161 222], ...
                [134 207 169],[226 241 101],[239 213 92],[241 145 91],[230 102 112],[200 70 159]};
                    
    case 'cams'
      names = {[254 254 254],[134 144 189],[241 229 11],[248 115 6],'red'};
    
    case 'o3' 
      names = {[254 254 254],'skyblue',[145 204 113],'yellow','orange','salmon','mediumvioletred'};
    
    case 'co'
      names = {[254 254 254],'Wheat',[255 255 112],'orange','crimson','PaleVioletRed','MediumPurple','DarkTurquoise'};
  
    case 'blh'
      names = {'lightblue','lightyellow','sandybrown','chocolate'};
  
    case 'clouds'
      names = {'black','gray','whitesmoke','royalblue','limegreen','yellow','darkorange','firebrick','pink','lavender'};
 
    case 'sat'
      names = {[254 254 254],'lightblue','DarkTurquoise','royalblue','salmon','pink'};
  
    case 'oc'
      names = {[254 254 254],[145 204 113],'yellow','orangered','darkred'};
  
    case 'bc'
      names = {[254 254 254],[145 204 113],'yellow','orange','MediumVioletRed',[152 102 203]};
  
    case 'rh'
      names = {'tan','wheat',[254 254 254],'lightskyblue','royalblue'};
  
    case 'wind'
      names = {[254 254 254],'lightskyblue',[145 204 113],'yellow','tomato','pink'};
    
    case 'ext'
      names = {'black',[0 2 46],[10 38 75],[23 64 96],[37 93 119],[47 113 135],[57 132 151],[65 149 166],[79 177 187], ...
                [92 203 207],[101 223 223],[111 238 146],[171 246 77],[254 245 82],[244 208 72],[234 171 62],[225 135 52], ...
                [215 98 42],[205 61 32],[218 112 146],[255 181 192]};
  
    case 'pm'
      names = {[254 254 254],'wheat','yellow','tomato','crimson','darkred'};
  
    case 'pastel'
      names = {[254 254 254],[221 209 231],'skyBlue','yellow','tomato','pink'};
  
    case 'temp'
      names = {[215 190 215],[184 196 229],[151 202 243],[128 194 247],[114 172 242],[100 148 236],[145 204 113],[180 220 77], ...
                [216 237 40],[253 254 2],[255 196 0],[255 131 0],[255 69 0],[255 109 67],[255 150 134],[255 191 202]};
  
    case 'nox'
      names = {[254 254 254],[178 203 225],[157 176 178],[217 186 109],[230 176 92],[224 158 83],[199 117 59],[146 73 34],[78 31 9]};
  
    case 'rainbow'
      names = {'red', [255 119 58], [255 237 70], [0 248 57], [0 202 251], [18 51 249], [179 64 250]};
  
    case 'frp'
      names = {'lightyellow','orange',[232 50 35],'indigo'};
  
    case 'ncl'
      names = {[254 254 254],[179 227 247],[108 180 222],[ 58 136 177],[ 60 163  93],[153 199  84], ...
                [250 200  87],[248 110  54],[226  54  44],[187  25  38],[137  20  28]};
  
    case 'city'
      names = {[  2  32  44],[ 74  55 143],[167  85  118],[252 133  69],[232 244  97]};
    
    case 'anom4'
      names = {[91 81 157],[124 191 166],[223 244 163],[252 252 252],[250 224 150],[229 117 79],[146 29 67]};
  
    case 'anom3'
      names = {[91 81 157],[114 141 166],[186 200 227],[252 252 252],[250 214 150],[229 107 79],[146 29 67]};
      
    case 'anom'
      names = {[36 126 177],[146 190 216],[254 254 254],[251 136 83],[212 55 72]};
      
    case 'anom2'
      names = {[38 66 155],[88 197 219],[254 254 254],[255 148 99],[229 35 51]};
  
    case 'pro'
      names = {'black','midnightblue','CadetBlue','LemonChiffon','orange','red','darkred'};
  
    case 'acc'
      names = {[184 243 254],[149 231 253],[123 217 253],[ 43 196 252],[  6 162 226],[  0 109 224], ...
                [111  73 194],[181  94 177],[224  62 220],[240 152 221]};
  
    case 'gmao2'
      names = {[242 236 252],[228 217 251],[200 193 250],[171 168 248],[118 161 222], ...
                [134 207 169],[226 241 101],[239 213 92],[241 145 91],[230 102 112],[200 70 159]};
  
    case 'finn'
      names = {[247 246 246],[238 237 238],[229 223 232],[211 208 224],[192 196 220],[183 200 218],[178 219 217], ...
                [167 216 180],[158 218 128],[183 221 115],[230 232 109],[223 163  76],[216 80 47]};
  
    case 'hum'
      names = {[254 254 254],'blanchedalmond','wheat',[241 229 11],[145 204 113],'royalblue','plum'};
  
    case 'aod'
      names = {[254 254 254],[243 249 251],[153 210 239],[241 229 11],[239 194 16],[238 158 20],[236 122 25],[234 86 30],[232 50 35]};
  
    case 'baod'
      names = {[1 1 1],'skyblue','gold',[232 50 35],'darkred'};
  
    case 'emis'
      names = {[25 62 139],'skyblue',[145 204 113],'gold',[232 50 35]};
    
    case 'usgs'
      names = {[225,230,240],[199,204,225],[193,204,251],[183,216,251],[174,227,252],[165,240,253],[159,252,254],[156,252,203], ...
                [156,251,155],[201,252,106],[254,254,85],[251,226,76],[247,199,68],[244,173,61],[238 104 44] };

    % From Panoply: 
    case 'bright'
      names = {[241 248 250],[187 222 238],[150 191 220],[123 162 208],[ 97 131 195],[128  92 155], ...
                [184 111 143],[231 135 136],[254 170 138],[255 205 138],[255 238 199]};
  
    case 'daod'
      names = {[ 94  54 138],[127 112 166],[165 158 197],[198 197 220],[230 231 241],[250 250 250], ...
                [255 230 201],[255 202 147],[254 171  95],[231 129  50],[197  97  38]};
  
    case 'melt'
      names = {[  0  60 109],[  5  95 129],[ 64 128 154],[100 163 175],[137 196 199],[247 245 242], ...
                [255 200 154],[255 178 123],[255 156  91],[255 135  64],[255 114  47]};
  
    case 'grav'
      names = {[ 38  66 155],[  0 126 181],[ 48 178 207],[128 217 230],[205 241 246],[254 252 206], ...
                [255 229 164],[255 180 117],[255 116  81],[255  40  49],[229  35  51]};
  
    case 'ceres'
      names = {[ 36 126 177],[ 77 174 160],[131 204 157],[188 226 154],[233 244 158],[255 253 187], ...
                [255 225 146],[255 184 110],[251 136  83],[238  87  67],[212  55  72]};
  
    case 'giss'
      names = {[152   0  16],[197  21  24],[242  48  35],[242  76  44],[241 109  55],[241 145  67], ...
                [240 184  80],[239 231  95],[182 236  87],[111 228  80],[ 62 159 116],[  0  88 248], ...
                [ 47 120 248],[ 77 157 250],[111 194 251],[135 222 252]};
                              
    case 'ppa'
      names = {[184 119  60],[212 142  79],[234 196 142],[249 233 206],[254 254 254],[156 226 218], ...
                [ 59 186 175],[  0 148 140],[  0 134 125]};
    
    end % switch names predefined

  end
  
  % Debug:
  % names
  % N_hues
  % numel(names)
      
  % names has all the color names and/or rgb colors needed at this point.
  % It is time to produce the output:
  if issingle | numel(names) == 1
    
    out = getcolor(names, colortable);
    
    return
  end
  
  if iscolormap
    
    Xi = linspace( 1, N_hues, numel(names));
    
    for i = 1:numel(names)
      
      aux     = names{i};
      
      if ischar(aux) 
        
        outi(i,:) = getcolor(aux, colortable);
        
      else % isnumeric
        
        outi(i,:) = aux ./ 255;
        
      end % ischar or isnumeric
      
    end % i
    
    % Interpolate to desired number of colors:
    for j = 1:3
      
      out(:,j) = interp1( Xi, outi(:,j), 1:N_hues);
      
    end % j
    
  end % if iscolormap
  
end % main function





function out = getcolor(colorname, data)
  
  switch char(colorname)
  case 'k'
    out = [59  55  53];
  case 'r'
    out = [223  70  51];
  case 'b'
    out = [ 16 110 167];
  case 'g'
    out = [ 40 149  50];
  case 'lb'
    out = [ 68 157 208];
  case 'o'
    out = [222 130  48];
  case 'y'
    out = [246 211  72];
  case 'br'
    out = [156  95  62];
  case 'pk'
    out = [217 135 151];
  case 'p'
    out = [105  53 136];
  case 'lg'
    out = [143 188  86];
  case 'gy'
    out = [180 180 180];
    
  otherwise
    
    idx = find(strcmpi(colorname, data.Name));
  
    if isempty(idx)
      error('%s',['Requested color ''' colorname ''' does not exist.'])
    end
    out = [data.R(idx) data.G(idx) data.B(idx)];
    
  end % switch
    
  out = out ./ 255;
  
end