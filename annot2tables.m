%{
Convert .annot files to a structure with t/f behavior tables
dependency: bentoMAT, specifically the loadAnnotSheetTxt() function
bentoMAT: https://github.com/neuroethology/bentoMAT
input: fname, path to your .annot file
outputs: struct <annoTable> with fields as described below
    annoTables.meta is another struct containining fRate, fStart, and fStop
    annoTables.<channel>, there will be an n-by-m table for each channel
    where n is the number of annotated frames and m is the number of
    behaviors. For each time point, a behavior is marked 1 if the bheavior
    is demonstrated. As a note, if you have multiple channels with unused
    behaviors, you will have several columns of 0s that may need to be
    filtered out in later analysis.
%}
function  annoTables = annot2tables(fname)
    % try to use the full file path not just a relative path for fname
    [annot, f_start, f_stop, fr] = loadAnnotSheetTxt(fname);
    ch = fieldnames(annot);
    annoTables.meta.fRate = fr; % f here and below means frame
    annoTables.meta.fStart = f_start;
    annoTables.meta.fStop = f_stop;
    % feedback on non-loop method would be appreciated
    % loop through each annotation channel
    for i = 1:size(ch,1)
        bhv = fieldnames(annot.(ch{i}));
        % initilize full table of 0s. array2table was just the easiest way I could figure to do this
        annoTables.(ch{i}) = array2table(zeros([f_stop size(bhv,1)]), 'VariableNames', bhv);
        % loop through each behavior in a channel and add to table
        for j = 1:size(bhv,1)
            % when read into matlab, the behavior should be a table of
            % behavior onset and offset frames. The below loop goes through
            % each row of that table.
            for r = 1:size(annot.(ch{i}).(bhv{j}),1)
                row = annot.(ch{i}).(bhv{j})(r,:);
                annoTables.(ch{i}).(bhv{j})(row(1):row(2)) = 1;
            end
        end
    end
end