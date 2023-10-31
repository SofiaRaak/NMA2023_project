%% PCA analysis of pfc-3 spatial task
% Code for NMA2023 project
% 
% Last updated on Oct 1st, 2023
% Written by Jiaxin Wang
% Contact: jx.wang@mail.bnu.edu.cn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load data
loadPath = pwd;
load([loadPath '\spatial_task.mat'])
load([loadPath '\TS.mat'])

%% modify monkey's name
% for fi = 1:length(spatial_task.('Filename'))
%     if strcmp(spatial_task.('Filename'){fi}(1:3), 'Elv')
%         spatial_task.('Filename'){fi}(1:3) = 'ELV';
%     end
% end
    
%% extract neurons of interst
training = spatial_task.('Training');
area = spatial_task.('Area');
cue = spatial_task.('Cue_position');
reward_onT = spatial_task.('Reward_onT');
target_onT = spatial_task.('Target_onT');
cue_onT = spatial_task.('Cue_onT');
neuronID = spatial_task.('Neuron');
matchFlag = spatial_task.('IsMatch');
FileID = spatial_task.('Filename');
trialID = spatial_task.('trialnum');
trialN = max(trialID);
monkeyName = {'ADR','ELV','BEN'};

postTrainTrials = cellfun(@(c) strcmp(c,'POST'), training);
dorsalNeuron = cellfun(@(c) strcmp(c,'dorsal'), area);
ventralNeuron = cellfun(@(c) strcmp(c,'ventral'), area);

% exclude wrong trials (no reward)
wrongTrials = isnan(reward_onT);
match(:,1) = ~isnan(matchFlag) & matchFlag == 1;
match(:,2) = ~isnan(matchFlag) & matchFlag == 0;

%% calculate firing rates
num_points = 1000;
kernel_sigma = 0.1;
time_range = [0, 10];
alldata = [];
alldataFlag = [];
for monkeyi = 1:length(monkeyName)
    monkeyIDmatch = cellfun(@(c) strcmp(c(1:3), monkeyName{monkeyi}), FileID);
    
    for matchi = 1:size(match,2)
        
        for cuei = 1:9
            cuePosition = cue == cuei;

            % neurons of interest
            % tempNOI = postTrainTrials & dorsalNeuron & cuePosition & ~wrongTrials & match(:,matchi) & monkeyIDmatch;
            tempNOI = postTrainTrials & cuePosition & ~wrongTrials & match(:,matchi) & monkeyIDmatch;
            
            if any(tempNOI)
                % obtain neuron ID
                tempNeuronID_NOI = neuronID(tempNOI);
                tempNeuronNum = length(unique(tempNeuronID_NOI));
                tempTS_NOI = TS(tempNOI);
                tempTarget_onT_NOI = target_onT(tempNOI);
                tempCue_onT_NOI = cue_onT(tempNOI);
                
                % get firing rates
                TS_smooth = zeros(length(tempTS_NOI), num_points);
                for ni = 1:length(tempTS_NOI)
                    if ~isempty(tempTS_NOI{ni})
                        tempTS = tempTS_NOI{ni};
                        TS_smooth(ni,:) = kernel_smooth_spike_data(tempTS, time_range, kernel_sigma, num_points);
                    else
                        TS_smooth(ni,:) = zeros(1, num_points);
                    end
                end

                % extract time window from Cue_on to Target_on
                tempTimeLength = (0.5 + 4 + 0.5) * num_points / (time_range(2) - time_range(1));
                tempTimeWin = [0, 0];
                tempTS_smooth_timeWin = zeros(length(tempTS_NOI), tempTimeLength);
                
                for ni = 1:length(tempTS_NOI)
                    tempTimeWin(1) = round((tempCue_onT_NOI(ni) - 0.5) * num_points / (time_range(2) - time_range(1)));
                    tempTimeWin(2) = tempTimeWin(1) + (5 * num_points / (time_range(2) - time_range(1)));
                    tempDur = tempTimeWin(1) : tempTimeWin(2) - 1;
                    tempTS_smooth_timeWin(ni,:) = TS_smooth(ni, tempDur);
                end

                % store for each neuron
                tempNeuronID_unique = unique(tempNeuronID_NOI);
                tempTS_smooth_timeWin_neuron = cell(size(tempNeuronID_unique));
                tempTS_smooth_timeWin_neuron_avTrial = zeros(length(tempNeuronID_unique), size(tempTS_smooth_timeWin, 2));
                for ni = 1:length(tempNeuronID_unique)
                    tempLoc = tempNeuronID_NOI == tempNeuronID_unique(ni);
                    if find(tempLoc) < 5
                        print('too few trials') % examine trial numbers
                        tempTS_smooth_timeWin_neuron{ni,1} = tempTS_smooth_timeWin(tempLoc,:);
                    else
                        tempTS_smooth_timeWin_neuron{ni,1} = tempTS_smooth_timeWin(tempLoc,:);
                        % tempTS_smooth_timeWin_neuron_avTrial(ni,:) = mean(TS_smooth_timeWin(loc,:), 1);
                    end
                end
                alldata{monkeyi,matchi}(:,cuei) = tempTS_smooth_timeWin_neuron;
                alldataFlag{monkeyi,matchi}(:,cuei) = tempNOI;
            end
        end % cue
    end % match
end % monkey

%% average all cues for each neuron
avgCue = [];
for monkeyi = 1:size(alldata,2)
    for matchi = 1:size(match,2)
        if ~isempty(alldata{monkeyi,matchi})
            neuronN = size(alldata{monkeyi,matchi}, 1);
            tempNeuron_avgT = nan(neuronN, 500);
            for ni = 1:size(alldata{monkeyi,matchi},1)
                tempData = cell2mat(alldata{monkeyi,matchi}(ni,:)');
                tempNeuron_avgT(ni,:) = mean(tempData, 1);
            end
            avgCue{monkeyi,matchi} = tempNeuron_avgT;
        else
            avgCue{monkeyi,matchi} = [];
        end
    end % match
end % monkey

%% PCA in a global space (match + non-match)
combined_data{1,1} = cellfun(@(a,b) [a;b], alldata{1,1}, alldata{1,2}, 'UniformOutput', false);
combined_data{2,1} = cellfun(@(a,b) [a;b], alldata{2,1}, alldata{2,2}, 'UniformOutput', false);
combined_avgCue = [];
for monkeyi = 1:size(combined_data,1)
    if ~isempty(combined_data{monkeyi,1})
        neuronN = size(combined_data{monkeyi,1}, 1);
        tempNeuron_avgT = nan(neuronN, 500);
        for ni = 1:size(combined_data{monkeyi,1},1)
            tempData = cell2mat(combined_data{monkeyi,1}(ni,:)');
            tempNeuron_avgT(ni,:) = mean(tempData, 1);
        end
        combined_avgCue{monkeyi,1} = tempNeuron_avgT;
    else
        combined_avgCue{monkeyi,1} = [];
    end
end % monkey

% matchData_all = cell2mat(combined_avgCue); % all monkeys
matchData_all = combined_avgCue{2}; % monkeyID 2
[coeff_all,score_all,latent_all,~,explained_all,~] = pca(matchData_all', 'NumComponents', 10);

%% firing rate for each monkey 
monkey1 = combined_avgCue{1,1};
plot(mean(monkey1,1))
hold on
monkey2 = combined_avgCue{2,1};
plot(mean(monkey2,1))

%% PCA for each condition
% matchData1 = cell2mat(avgCue(:,1));
% matchData2 = cell2mat(avgCue(:,2)); % all monkeys
matchData1 = cell2mat(avgCue(2,1));
matchData2 = cell2mat(avgCue(2,2)); % monkeyID 2
[coeff1,score1,~,~,explained1,~] = pca(matchData1', 'NumComponents', 10);
[coeff2,score2,~,~,explained2,~] = pca(matchData2', 'NumComponents', 10);

% project on the global PCA
matchData2_center = (matchData2 - mean(matchData2,2));
score2_global = matchData2_center' * coeff_all;
matchData1_center = (matchData1 - mean(matchData1,2));
score1_global = matchData1_center' * coeff_all;

%% plot PCA on global
figure
scatter3(score1_global(:,1),score1_global(:,2),score1_global(:,3),20)
hold on
scatter3(score2_global(:,1),score2_global(:,2),score2_global(:,3),20)
timePoints = [50, 100, 250, 300, 450];
for ti = 1:length(timePoints)
    scatter3(score1_global(timePoints(ti),1), score1_global(timePoints(ti),2), score1_global(timePoints(ti),3), 100, 'g', 'filled')
    scatter3(score2_global(timePoints(ti),1), score2_global(timePoints(ti),2), score2_global(timePoints(ti),3), 100, 'g', 'filled')
end
axis square

%% animated plot: PCA and distance between trajectories
color1 = [0.00,0.45,0.74];
color2 = [0.85,0.33,0.10];

x1 = score1_global(:,1);
y1 = score1_global(:,2);
z1 = score1_global(:,3);
x2 = score2_global(:,1);
y2 = score2_global(:,2);
z2 = score2_global(:,3);

% distance between neural trajectories
dist = sqrt(sum((score1_global(:,1:6) - score2_global(:,1:6)).^2, 2));

% figure
set(gcf,'position',[400,400,1000,500])
set(gcf,'color','white')

subplot(1,2,1)
set(gca,'Linewidth',2,'FontSize',16)
axis([-50,50,-50,50,-50,50])
axis square
grid on
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')
hold on
for ti = 1:length(timePoints)
    scatter3(score1_global(timePoints(ti),1), score1_global(timePoints(ti),2), score1_global(timePoints(ti),3), 50, 'g', 'filled')
    scatter3(score2_global(timePoints(ti),1), score2_global(timePoints(ti),2), score2_global(timePoints(ti),3), 50, 'g', 'filled')
end
h1 = animatedline('Color',color1,'LineWidth',0.5,'Marker','o','MarkerSize',4);
h2 = animatedline('Color',color2,'LineWidth',0.5,'Marker','o','MarkerSize',4);

subplot(1,2,2)
set(gca,'Linewidth',2,'FontSize',16,'XTick',0:100:500,'XTickLabel',string((0:100:500)/100))
axis([0,500,0,15])
axis square
xlabel('Time (s)')
ylabel('Distance')
hold on
plot(timePoints, dist(timePoints), 'LineStyle','none', 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'g')
h3 = animatedline('Color','r','LineWidth',0.5,'Marker','o','MarkerSize',3);

grid on
for k = 1:length(x1)
    addpoints(h1,x1(k),y1(k),z1(k));
    addpoints(h2,x2(k),y2(k),z2(k));
    addpoints(h3, k, dist(k));
    pause(0.005);
    drawnow;
end

%% figures
% explained variance
figure;
plot(cumsum(explained_all(1:10)),'Marker','o')
axis square

% distance and plot
distIn = sqrt(sum((score1_global(:,1:3) - score2_global(:,1:3)).^2, 2));
plot(distIn,'r','LineWidth',3)
hold on
plot(timePoints, distIn(timePoints), 'LineStyle','none', 'Marker', 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'g')
axis square

%% gaussian kernel
function output = gaussian_kernel(x, sigma)
output = exp(-(x.^2) / (2*sigma.^2)) / (sigma*sqrt(2*pi()));
end

%% smooth spike train
function smoothed_signal = kernel_smooth_spike_data(spike_times, time_range, kernel_sigma, num_points)
time_points = linspace(time_range(1), time_range(2), num_points);
smoothed_signal = zeros(size(time_points));

for ip = 1:length(spike_times)
    kernel = gaussian_kernel(time_points - spike_times(ip), kernel_sigma);
    smoothed_signal = smoothed_signal + kernel;
end
end
