function [usersIDSel] = select_userID_fromSubtype(userSubtypeLUTFile, userSubtype)
% Select the appropriate userSubtype from the file userSubtypeLUTFile.
%
% Inputs:
%   userSubtypeLUTFile : string of the file to read 
%   userSubtype : string of the user subtype to load
%
% Outputs:
%   usersIDSel : cell of the scorer ID selected based on the userSubtype
% 
% Author: Karine Lacourse 2019-09-13
%   Changes log:
%   
%--------------------------------------------------------------------------

    userStats = readtext(userSubtypeLUTFile,'[,\t]','#','"','textual');
    userStatsHdr = userStats(1,:);
    userStatsData = userStats(2:end,:);
    if strcmp(userSubtype,'exp')
        userSubTypeLabel = 'psgTech';
    elseif strcmp(userSubtype,'re')
        userSubTypeLabel = 'researcher';
    else
        error('the userSubtype:%s is not expected', userSubtype);
    end
    userSubType = userStatsData(:,strcmp(userStatsHdr,'userSubType'));
    usersSel = strcmp(userSubType,userSubTypeLabel);
    usersID = userStatsData(:,strcmp(userStatsHdr,'userName'));
    usersIDSel = usersID(usersSel);
    
end

