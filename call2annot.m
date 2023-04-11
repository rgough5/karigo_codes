%pretty similair to led2annot but adds a call channel instead
function outFile = call2annot(callFile, annotFile, outFile)
    if not(strcmp(annotFile, outFile))
        copyfile(annotFile, outFile)
    end

    calls = load(callFile);
    calls = calls.Calls;
    start = calls.Box(:,1);
    duration = calls.Box(:,3);
    stop = calls.Box(:,1) + calls.Box(:,3);
    T = table(start, stop, duration); %table of timings for .annot file
    writetable(T, 'tempcalltimings.txt','Delimiter','\t')

    channel = 'Usvs';
    annot1 = 'usv1';
    
    %this section and the while loop below finds the line number where channels
    %start being listed
    freeline(outFile, 'List of channels', channel); %add channel name
    freeline(outFile, 'List of annotations', annot1); %annot name
    
    writelines(strcat(channel, '----------'), outFile, WriteMode='append')
    
    writelines(strcat('>', 'usv1'), outFile, WriteMode='append')
    t = readlines('tempcalltimings.txt');
    writelines(t, outFile, WriteMode='append');
    writelines('', outFile, WriteMode='append');
    writelines('', outFile, WriteMode='append');

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