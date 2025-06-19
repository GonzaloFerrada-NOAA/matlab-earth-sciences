function image2mp4(video_filename,path_figures,framerate,loop_opt,reverse_opt)
% Function to create .mp4 video at 100% quality.
%
% Usage: make_mp4(video_filename,path_figures,framerate)
%
% Inputs needed:
% video_filename  : path/video filename.
% path_figures    : path to directory where figures are. Default will read
%                     all *png files.
% framerate       : (optional) frame rate for video. Default is 16.
% loop_opt        : (optional) set video loop (default =1)
% reverse_opt     : (optional) set to 1 to loop frames back to first frame.
%
% Author: Gonzalo A. Ferrada (gonzalo-ferrada@uiowa.edu)
% November 2020
                        
% Set defaults:
if ~exist('framerate','var'); framerate = 16; end
if ~exist('loop_opt','var');  loop_opt  = 1; end
if ~exist('reverse_opt','var'); reverse_opt  = 0; end
    
if loop_opt > 1 & reverse_opt ~= 0
    error('video can either be reversed or looped. Not both.')
end
    
if ~strcmp(path_figures(end-3:end),'.png') &&  ~strcmp(path_figures(end-3:end),'.jpg')
    path_search = [path_figures '*.png'];
else
    path_search = path_figures;
end

dinfo       =  dir(path_search);
pngs        =  {dinfo.name};
parentdir   =  {dinfo.folder};

v           = VideoWriter(video_filename,'MPEG-4');
v.Quality   = 100;
v.FrameRate = framerate;
open(v)


for ll = 1:loop_opt
for vv = 1:numel(pngs)
    
    figure_aux  = [parentdir{vv} '/' pngs{vv}];
    disp(figure_aux)
    % disp(figure_aux)
    [X,map] = imread(figure_aux);
    %v.Colormap = map;
    writeVideo(v,X)
    % add a frozen image for better looking at the beggining:
    if ll == 1 & vv == 1
        for kk = 1:round(framerate/2)
            writeVideo(v,X)
        end
    end
    % add a frozen image for better looking at the end:
    if vv == numel(pngs)
        if loop_opt > 1
            for kk = 1:round(framerate)
                writeVideo(v,X)
            end
        else
            for kk = 1:round(framerate/2)
                writeVideo(v,X)
            end
        end
    end
end
end

if reverse_opt == 1
    
    for vv = numel(pngs):-1:1
        figure_aux  = [parentdir{vv} '/' pngs{vv}];
        % disp(figure_aux)
        [X,map] = imread(figure_aux);
        %v.Colormap = map;
        writeVideo(v,X)
    end
    
end

close(v)


    
end