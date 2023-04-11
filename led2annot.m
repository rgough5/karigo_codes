%appends a light annotation to an EXISTING annotation file
%input (in this order) video file, the annotation file, and the name of the
%desired output file. If you would rather overwrite the annotation file
%just input the exact same "outFile" as the "annotFile"

function outFile = led2annot(vidFile, annotFile, outFile)
    if not(strcmp(annotFile, outFile))
        copyfile(annotFile, outFile)
    end
    [l1, l2] = detectLEDmp4(vidFile); %takes a hot minute
    writetable(l1, 'tempannotl1.txt','Delimiter','\t')
    writetable(l2, 'tempannotl2.txt','Delimiter','\t')
    channel = 'Light';
    annot1 = 'light1';
    annot2 = 'light2';
    %this section and the while loop below finds the line number where channels
    %start being listed
    freeline(outFile, 'List of channels', channel); %add channel name
    freeline(outFile, 'List of annotations', annot1); %add annotation names
    freeline(outFile, 'List of annotations', annot2);
    
    %Add new channel section
    writelines(strcat(channel, '----------'), outFile, WriteMode='append')
    %Add first annotation
    writelines(strcat('>', annot1), outFile, WriteMode='append')
    t = readlines('tempannotl1.txt');
    writelines(t, outFile, WriteMode='append');
    writelines('', outFile, WriteMode='append');

    %Add second annotation
    writelines(strcat('>', annot2), outFile, WriteMode='append')
    t = readlines('tempannotl2.txt');
    writelines(t, outFile, WriteMode='append');
    writelines('', outFile, WriteMode='append');
    writelines('', outFile, WriteMode='append');
    
    delete temp*.txt
end

%% This function detects the led(s)

% This code assumes that there are lights in the lower left and
% right corners of the videos. You can add a few lines at the beginning to
% detect the lights or change the lights locations below
% honestly not very efficient
function [lite1, lite2] = detectLEDmp4(fName)
    %lite1 is the left light. lite2 is the right
    
    lite1 = [];
    lite2 = [];
    
    %read in file
    v = VideoReader(fName);
    h = v.Height;
    w = v.Width;
    
    litestate = 0;
    
    while hasFrame(v)
        t = v.CurrentTime; %it would be more efficient not to save t everytime, but "CurrentTime" is the time of the frame about to be read in
        frame = rgb2gray(readFrame(v));
        frame = frame > 245;
        
        %if no light is on
        if litestate == 0 
            if mean(mean(frame(h-60:h, w-60:w))) >= 0.1 %check for right light
                litestate = 2;
                ont = t;
                continue
            elseif mean(mean(frame(h-60:h, 1:60))) >= 0.1 %check left
                litestate = 1;
                ont = t;
                continue
            else % if neither light is on
                continue
            end
        end
        
        %if left light is on
        if litestate == 1
            if mean(mean(frame(h-60:h, 1:60))) < 0.1 %check if light is finally off
                litestate = 0;
                offt = t;
                lite1 = [lite1; ont, offt, offt-ont];
                continue
            else % if left light is still on
                continue
            end
        end
    
        %if right light is on
        if litestate == 2
            if mean(mean(frame(h-60:h, w-60:w))) < 0.1 %check if right is finally off
                litestate = 0;
                offt = t;
                lite2 = [lite2; ont, offt, offt-ont];
                continue
            else % if left light is still on
                continue
            end
        end
    
    end
    
    %I convert to table here because just because I didn't want to think
    if isempty(lite1)
        warning('light 1 was not detected, introducing placeholder')
        lite1 = [0 0 0];
    end
    if isempty(lite2)
        warning('light 2 was not detected, introducing placeholder')
        lite2 = [0 0 0];
    end
    lite1 = array2table(lite1, 'VariableNames', {'Start', 'Stop', 'Duration'});
    lite2 = array2table(lite2, 'VariableNames', {'Start', 'Stop', 'Duration'});
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