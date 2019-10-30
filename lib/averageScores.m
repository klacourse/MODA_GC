function averageScores(pathOutput, annotScoreFolderName, ...
    scoreVectorAvgFileName, nTotSamples_seg)
% Average the scores across annotators.
%
% Inputs:
%   pathOutput : string of the path to save outputs
%   annotScoreFolderName : string, the folder name to save .mat score vector
%       for each annotator.
%   scoreVectorAvgFileName : string of the filename of the average score
%       vector to save.
%   nTotSamples_seg : double, total number of samples in the score vector.
% 
% Author: Karine Lacourse 2019-09-16
%   Changes log:
%   
%------------------------------------------------------------------------    


    % Load the scoredVectorByAnnot with spindles marked
    scorerFolderPath = [pathOutput,annotScoreFolderName,'/'];
    scorerFileNameList = generateRealListFromPath(scorerFolderPath,'.mat');
    nAnnotators = length(scorerFileNameList);
    
    % Preallocation
    scoreSum	= nan(nTotSamples_seg,1);   % Average scores vector
    nAnnotsSum	= zeros(nTotSamples_seg,1); % number of annotators
    for iAnnot = 1 : nAnnotators
        % Load the ScoredVectorByAnnot file
        fileName2Load = sprintf([pathOutput, annotScoreFolderName,...
            '/', scorerFileNameList{iAnnot}]);
        tmp = load(fileName2Load);
        scoredVectorByAnnot_seg = tmp.(char(fieldnames(tmp)));
        if length(scoredVectorByAnnot_seg) ~= nTotSamples_seg
            error('%s : length is %i and should be %i', scorerFileNameList{iAnnot},...
                length(scoredVectorByAnnot_seg), nTotSamples_seg);
        end
        % Group consensus : number of annotators
        nAnnotsSum(~isnan(scoredVectorByAnnot_seg)) = ...
            nAnnotsSum(~isnan(scoredVectorByAnnot_seg)) + 1;
        % Group consensus vector is the sum of every score (nan omitted)
        scoreSum    = sum([scoreSum,scoredVectorByAnnot_seg],2,'omitnan');
    end

    % Average the scores from all the annonators 
    % (the sum is divided by the number of annonators who have seen the epoch)
    % If no annotator has seen the epoch, 0./0 = NaN, then it is perfect
    scoreVectorAvg = scoreSum ./ nAnnotsSum;    
    % Save the average score vector
    save([pathOutput,scoreVectorAvgFileName], 'scoreVectorAvg','-v7.3');    
end

