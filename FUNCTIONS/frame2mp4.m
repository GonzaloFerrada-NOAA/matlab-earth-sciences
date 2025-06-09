function frame2mp4(video_filename,frames_struct,framerate,loop_opt,repeat_1stend)
% Function to create .mp4 video at 100% quality.
%
% Usage: make_mp4(video_filename,path_figures,framerate)
%
% Inputs needed:
% video_filename  : path/video filename.
% frames_struct   : struct with frames (gotten with getframe(gcf)).
% framerate       : (optional) frame rate for video. Default is 16.
% loop_opt        : (optional) set to 1 to loop frames back to first frame.
% repeat_1stend   : (optional) set to 1 (or higher integer) to repeat 1st and last frames 4 times.
%
% Author: Gonzalo A. Ferrada (gonzalo-ferrada@uiowa.edu)
% November 2020
                        
% Set defaults:
if ~exist('framerate','var');       framerate       = 16; end
if ~exist('loop_opt','var');        loop_opt        = 0; end
if ~exist('repeat_1stend','var');   repeat_1stend   = 0; end

v           =  VideoWriter(video_filename,'Uncompressed AVI'); % MPEG-4 does not produce a good result anymore
% v.Quality   =  100;
v.FrameRate =  framerate;

open(v)

if repeat_1stend > 0
    for i = ones(1,repeat_1stend)
        writeVideo(v,frames_struct(i))
    end
end

writeVideo(v,frames_struct)

if loop_opt == 1
    
    if repeat_1stend > 0
        for i = ones(1,repeat_1stend)
            writeVideo(v,frames_struct(end))
        end
    end
    
    writeVideo(v,frames_struct(end:-1:1))
    
    if repeat_1stend > 0
        for i = ones(1,repeat_1stend)
            writeVideo(v,frames_struct(i))
        end
    end
    
else
    if repeat_1stend > 0
        for i = ones(1,repeat_1stend)
            writeVideo(v,frames_struct(end))
        end
    end
end



close(v)

disp([' ' video_filename])
disp([' Video duration   : ' sprintf('%6.2f',v.Duration) ' s '])
disp([' Video frame rate : ' sprintf('%6.1f',v.FrameRate) ' fps '])
disp([' Video resolution : ' num2str(v.Width) ' x ' num2str(v.Height) ' pixels'])

    
end