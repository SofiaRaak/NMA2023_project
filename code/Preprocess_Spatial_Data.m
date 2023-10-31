%% extract data for the pfc-3 spatial task
% Code for NMA2023 project
% 
% Last updated on Oct 1st, 2023
% Written by Jiaxin Wang
% Contact: jx.wang@mail.bnu.edu.cn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load data
tablePath = [pwd '\SummaryDatabase.xlsx']; % load from pfc-3 table file
preTrainSpatial  = readtable(tablePath,'Sheet',1);
postTrainSpatial = readtable(tablePath,'Sheet',2);
spatialTaskList = [preTrainSpatial; postTrainSpatial];

%% import .mat data using for loop
dataPath    = 'D:\Study\MATLAB\NMA2023\pfc-3\data';
listing     = dir([dataPath '\*.mat']);
fileName    = struct2cell(listing)';
fileName    = fileName(:,1);
tableName   = {'Cue_onT','Sample_onT','Target_onT','Reward_onT','trialnum','IsMatch','TS'};
table_all = [];
for file = 1:size(listing,1)
    
    % name of file
    recordName = fileName{file,1}(1:8);
    neuronName = fileName{file,1}(10:13);
    
    % check if spatial task
    fileMatch   = find(contains(spatialTaskList.Filename, recordName, 'IgnoreCase', true));
    neuronMatch = find(spatialTaskList.Neuron == str2double(neuronName));
    index       = intersect(neuronMatch, fileMatch);
    
    if ~isempty(index)
        
        % sanity check
        if length(index) > 1
            sprintf('%d identical recordings for file %d', length(index), file)
            index = index(1);
        end
        
        % load the .mat file
        load([dataPath '\' fileName{file,1}]);
        
        % cues
        blockN = size(MatData.class,2);
        
        % sanity check
        if blockN ~= 9
            error('Wrong cue numbers');
        end
        
        % extract each block
        newTable = [];
        for blocki = 1:blockN
            trialN = size(MatData.class(blocki).ntr, 2);  % trial numbers
            tempTable = struct2table(MatData.class(blocki).ntr);
            
            Cue_position = blocki*ones(trialN,1);
            blockTable = table(Cue_position, 'VariableNames', {'Cue_position'});
            
            for vari = 1:length(tableName)
                flag = contains(tempTable.Properties.VariableNames, tableName(vari), 'IgnoreCase', true);
                
                if sum(flag) == 1
                    if isa(tempTable.(tableName{vari}), 'cell') && ~strcmp(tableName{vari}, 'TS')
                        if strcmp(tableName{vari}, 'IsMatch') || strcmp(tableName{vari}, 'Reward_onT')
                            empty = find(cellfun(@isempty, tempTable.(tableName{vari})));
                            tempTable.(tableName{vari})(empty) = {nan};
                            tempTable.(tableName{vari}) = cell2mat(tempTable.(tableName{vari}));
                        else
                            error('Check the field names')
                        end
                    end
                    blockTable = addvars(blockTable, tempTable.(tableName{vari}), 'NewVariableNames', tableName{vari});
                elseif sum(flag) == 0
                    if strcmp(tableName{vari},'Target_onT')
                        blockTable = addvars(blockTable, zeros(size(tempTable,1),1), 'NewVariableNames', tableName{vari});
                    elseif strcmp(tableName{vari}, 'Reward_onT')
                        blockTable = addvars(blockTable, zeros(size(tempTable,1),1), 'NewVariableNames', tableName{vari});
                    else
                        error('Check the field names')
                    end
                else
                    error('Repeated file names')
                end
            end
            newTable = [newTable; blockTable];
        end
        
        fileInfoTable = repmat(spatialTaskList(index,:), size(newTable,1), 1);
        newTable = [fileInfoTable newTable];
        table_all = [table_all; newTable];
    end
end % file loop
spatial_task = table_all;

%% save data for spatial task
TS = spatial_task.('TS');
table_info = spatial_task(:,1:end-1);
writetable(table_info, 'spatial_task.csv')
save TS

%% load data for calculating firing rates
loadPath = pwd;
load([loadPath '\spatial_task.mat'])
load([loadPath '\TS.mat'])

%% extract neurons of interst
training = spatial_task.('Training');
area = spatial_task.('Area');
cue = spatial_task.('Cue_position');
reward_onT = spatial_task.('Reward_onT');
target_onT = spatial_task.('Target_onT');
cue_onT = spatial_task.('Cue_onT');
neuronID = spatial_task.('Neuron');

postTrainTrials = cellfun(@(c) strcmp(c,'POST'), training);
dorsalNeuron = cellfun(@(c) strcmp(c,'dorsal'), area);
ventralNeuron = cellfun(@(c) strcmp(c,'ventral'), area);
cuePosition = cue == 3;

% exclude wrong trials (no reward)
wrongTrials = isnan(reward_onT);

% specify neurons of interest
NOI = postTrainTrials & dorsalNeuron & cuePosition & ~wrongTrials;

% obtain neuron ID
neuronID_NOI = neuronID(NOI);
neuronNum = length(unique(neuronID_NOI));
TS_NOI = TS(NOI);
target_onT_NOI = target_onT(NOI);
cue_onT_NOI = cue_onT(NOI);

% save data
save TS.m
