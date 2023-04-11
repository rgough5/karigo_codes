%% Generates a Bento annotation given a video file and usv call file
function annot = foundAnnot(vidFile)
    v = VideoReader(vidFile);
    fCount = round(v.Duration * v.FrameRate); %so the NumFrame property doesn't really work
    fRate = v.FrameRate;

    [p, n, x] = fileparts(vidFile);
    % if ~exist(strcat(p, 'annotations/'), 'dir') %need to make directory if it doesn't already exist
    %    mkdir(strcat(p, 'annotations/'))
    % end
    if isempty(p)
        p = '.';
    end

    annot = strcat(p, filesep, n, '.annot');
    copyfile('base.annot', annot) %this makes a new annot file and names it after the mp4 file
    freeline(annot, 'Stimulus name:', strcat('Annotation stop frame: ', string(fCount))); %see below for notes on this function
    freeline(annot, 'Stimulus name:', strcat('Annotation framerate: ', string(fRate)));
    delete temp*.txt
end

%% This function is necessary to add the channel and annotations
% It first searches for a <section> e.g. "List of channels". After finding
% the correct section it adds the text <new_ch> before the next blank line

function [findCounter, writeCounter] = freeline(file, section, new_ch)
    %find file
    fid = fopen(file);
    tline = fgetl(fid);
    findCounter = 1;
    while ischar(tline)
        if contains(tline, section)
            while ischar(tline)
                if strcmp(tline, '')%find first line without a channel
                    break;
                end
                tline = fgetl(fid);
                findCounter = findCounter + 1;
            end
            break;
        end
        % Read next line
        tline = fgetl(fid);
        findCounter = findCounter + 1;
    end
    fclose(fid);

    %write to file in the jankiest way possible because Matlab is trash
    rid = fopen(file, 'r');
    wid = fopen('temptext.txt', 'wt');
    tline = fgetl(rid);
    writeCounter = 1;
    while ischar(tline)
        if writeCounter < findCounter
            fprintf(wid, strcat(tline, '\n'));
            tline = fgetl(rid);
            writeCounter = writeCounter + 1;
        elseif writeCounter == findCounter
            fprintf(wid, strcat(new_ch,'\n')); %the new text
            writeCounter = writeCounter + 1;
        else
            fprintf(wid, strcat(tline, '\n'));
            tline = fgetl(rid);
        end
    end
    fclose(rid);
    fclose(wid);
    newf = fileread('temptext.txt');
    writelines(newf, file);

end
