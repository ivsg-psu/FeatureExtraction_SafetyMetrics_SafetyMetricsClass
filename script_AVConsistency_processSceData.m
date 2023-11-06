clear;close all;clc;
if ~exist('Fig','dir')
mkdir('./Fig');
end
directory = ['C:\Users\ccctt\OneDrive - The Pennsylvania State University\Documents\GitHub\' ...
    'TrafficSimulators_Project_SUMOSimulationForADSProject\Scenarios\Scenario1_1\res'];
fileRegExp = {'res_highway_Site_1180_peak_seed*.csv','res_highway_Site_1180_off-peak_seed*.csv',...
    'res_Arterial_Site_1136_peak_seed*.csv','res_Arterial_Site_1136_off-peak_seed*.csv',...
    'res_Urban_Site_1135_peak_seed*.csv','res_Urban_Site_1135_off-peak_seed*.csv'};


pathXY = readtable('referenceline_20231016.csv');
pathXY = [pathXY.Var1,pathXY.Var2];
sensorRange = 100;
wzstart = 1067;
wzend = 1387; 

for kk = 1
files = dir(fullfile(directory, fileRegExp{kk}));
currentRegExp = fileRegExp{kk};
pattern = 'res_(.*?)_seed.*\.csv';
% Extract the matching substring
token = regexp(currentRegExp, pattern, 'tokens');
sim_name = token{1}{1};
for ii = 1:length(files)
    tic;
    filePath = fullfile(directory, files(ii).name);

    data = readtable(filePath);

    % Check for NaN values
    data = rmmissing(data);

    % Pre-process the data by adding total station
    data = fcn_AVConsistency_preProcessData(data,pathXY);
    % Cut the ending part of the vehicle trajectory, where it is snaped
    % backwards from the first road segment
    data = data(data.snapStation>0,:);

    % pick one AV
    avID = 'AV'; % Specify vehicle id to query, assume it's av
    [avData,otherVehData]= fcn_AVConsistency_getAVData(data,avID);% only for AV
    outputData(ii).data = data;
    outputData(ii).avData = avData;
    outputData(ii).otherVehData =  otherVehData;


    % pick one human driven vehicle
    hvID = 'f_lane_397.22';

    [hvData,otherData2]= fcn_AVConsistency_getAVData(data,hvID);% only for AV

    outputData(ii).hvData = hvData;

    %% Compute and plot site-specific speed disparity for AV
    % fignum = 2;
    % speed_distribution = 1 % generate speed distribution plot across 100 increments snapstation
    % fcn_AVConsistency_siteSpecificSpeedDisparity(data,avID,fignum,speed_distribution);


    %% Calculate and plot lead spacing and speed disparity, av and leading veh

    relativeTo = 'lead';
    avrelatestr = ['av',relativeTo];
    [avTime,avPosition,nearestVehID,speedDisparity,spacing] =  ...
        fcn_AVConsistency_SpeedDisparityAndSpacing(data, sensorRange, avID, relativeTo);
    outputData(ii).(avrelatestr).timestep_time = avTime;
    outputData(ii).(avrelatestr).snapStation = avPosition;
    outputData(ii).(avrelatestr).nearestVehID = nearestVehID;
    outputData(ii).(avrelatestr).speedDisparity = speedDisparity;
    outputData(ii).(avrelatestr).spacing = spacing;

    %% Calculate and plot lead spacing and speed disparity, human driven veh and leading veh

    relativeTo = 'lead';
    hvrelatestr = ['hv',relativeTo];
    [hvTime,hvPosition,nearestVehID,speedDisparity,spacing] =  ...
        fcn_AVConsistency_SpeedDisparityAndSpacing(data, sensorRange, hvID, relativeTo);

    outputData(ii).(hvrelatestr).timestep_time = hvTime;
    outputData(ii).(hvrelatestr).snapStation = hvPosition;
    outputData(ii).(hvrelatestr).nearestVehID = nearestVehID;
    outputData(ii).(hvrelatestr).speedDisparity = speedDisparity;
    outputData(ii).(hvrelatestr).spacing = spacing;    



    %% Calculate and plot follow spacing and speed disparity, av and human veh

    relativeTo = 'follow';
    avrelatestr = ['av',relativeTo];
    [avTime,avPosition,nearestVehID,speedDisparity,spacing] =  ...
        fcn_AVConsistency_SpeedDisparityAndSpacing(data, sensorRange, avID, relativeTo);
    outputData(ii).(avrelatestr).timestep_time = avTime;
    outputData(ii).(avrelatestr).snapStation = avPosition;
    outputData(ii).(avrelatestr).nearestVehID = nearestVehID;
    outputData(ii).(avrelatestr).speedDisparity = speedDisparity;
    outputData(ii).(avrelatestr).spacing = spacing;
    %% Calculate and plot follow spacing and speed disparity, human driven veh and following veh

    relativeTo = 'follow';
    hvrelatestr = ['hv',relativeTo];
    [hvTime,hvPosition,nearestVehID,speedDisparity,spacing] =  ...
        fcn_AVConsistency_SpeedDisparityAndSpacing(data, sensorRange, hvID, relativeTo);

    outputData(ii).(hvrelatestr).timestep_time = hvTime;
    outputData(ii).(hvrelatestr).snapStation = hvPosition;
    outputData(ii).(hvrelatestr).nearestVehID = nearestVehID;
    outputData(ii).(hvrelatestr).speedDisparity = speedDisparity;
    outputData(ii).(hvrelatestr).spacing = spacing;    

    %% Compute AV's total acceleration vector under different conditions

    filterFlag = 0; % not filtered data
    [station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_speed(avData,filterFlag);

    outputData(ii).avaccel.snapStation = station;
    outputData(ii).avaccel.acceleration_x=acceleration_x;
    outputData(ii).avaccel.acceleration_y=acceleration_y;
    %% Compute HV's total acceleration vector under different conditions

    filterFlag = 0; % not filtered data
    [station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_speed(hvData,filterFlag);

    outputData(ii).hvaccel.snapStation = station;
    outputData(ii).hvaccel.acceleration_x=acceleration_x;
    outputData(ii).hvaccel.acceleration_y=acceleration_y;
end
%% resample speed 
resampleStation = [0:10:1500,wzstart,wzend];
resampleStation = sort(resampleStation);
columns.veh = {'vehicle_speed', 'speed_filtered', 'snapStation', 'vehicle_x', 'vehicle_y', ...
    'vehicle_x_filtered', 'vehicle_y_filtered'};
columns.lead = {'speedDisparity','spacing'};
columns.follow = columns.lead;
columns.accel = {'acceleration_x','acceleration_y'};
                 
for ii = 1:length(files)
   temp.avresample{ii}= fcn_AVConsistency_resampleVehData(outputData(ii).avData,columns.veh,resampleStation);
   temp.othervehresample{ii} = fcn_AVConsistency_resampleVehData(outputData(ii).otherVehData,columns.veh,resampleStation);

end
avResampled = vertcat(temp.avresample{:});
othervehResampled = vertcat(temp.othervehresample{:});

clear temp;

statsRes.avResampled = fcn_AVConsistency_statistics(avResampled.vehicle_speed);
statsRes.otherVehResampled = fcn_AVConsistency_statistics(othervehResampled.vehicle_speed);



%% resample disparity

circCols = {'avlead','avfollow','hvlead','hvfollow'};


for ii = 1:length(files)
    for colname = circCols
     
    temp.(colname{1}){ii} = fcn_AVConsistency_resampleDisparity(outputData(ii).(colname{1}), ...
        columns.lead,resampleStation);
    
    end
end

avleadResampled = vertcat(temp.avlead{:});
avfollowResampled = vertcat(temp.avfollow{:});

hvleadResampled = vertcat(temp.hvlead{:});
hvfollowResampled = vertcat(temp.hvfollow{:});

%%

resampledNames = {'avleadResampled','avfollowResampled','hvleadResampled','hvfollowResampled'};
spdOrSpc = {'speedDisparity','spacing'};
for k1 = 1:length(circCols)
    currentColName = circCols{k1};
    currentResampleName = resampledNames{k1};
    for k2 = 1:length(spdOrSpc)
        currentspdOrSpc = spdOrSpc{k2};
        temp2 = eval(currentResampleName).(currentspdOrSpc);
        statsRes.(currentColName).(currentspdOrSpc) = fcn_AVConsistency_statistics(temp2);
    end
end


%% resample acceleration



for ii = 1:length(files)
    
    temp.avaccel{ii} = fcn_AVConsistency_resampleDisparity(outputData(ii).avaccel,columns.accel,resampleStation);
    temp.hvaccel{ii} = fcn_AVConsistency_resampleDisparity(outputData(ii).hvaccel,columns.accel,resampleStation);
end

avAccelResampled = vertcat(temp.avAccel{:});
hvAccelResampled = vertcat(temp.hvAccel{:});

clear temp;
statsRes.avAccel.acceleration_x = fcn_AVConsistency_statistics(avAccelResampled.acceleration_x);
statsRes.avAccel.acceleration_y = fcn_AVConsistency_statistics(avAccelResampled.acceleration_y);
statsRes.hvAccel.acceleration_x = fcn_AVConsistency_statistics(hvAccelResampled.acceleration_x);
statsRes.hvAccel.acceleration_y = fcn_AVConsistency_statistics(hvAccelResampled.acceleration_y);



 %  _____  _      ____ _______ _____ 
 % |  __ \| |    / __ \__   __/ ____|
 % | |__) | |   | |  | | | | | (___  
 % |  ___/| |   | |  | | | |  \___ \ 
 % | |    | |___| |__| | | |  ____) |
 % |_|    |______\____/  |_| |_____/
close all;  
%% site specific speed 
yyflagplot = 1;
fignum = 100;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avResampled.meanData, ...
    statsRes.avResampled.upperBD,statsRes.avResampled.lowerBD,resampleStation,'av',fignum,yyflagplot);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.otherVehResampled.meanData, ...
    statsRes.otherVehResampled.upperBD,statsRes.otherVehResampled.lowerBD,resampleStation,'other',fignum,yyflagplot);

h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]);

legend([h1,h2,h3,h4,h5,h6],{'Autonomous vehicle mean (N = 10)', 'Autonomous vehicle 2-sigma boundary',...
    'Human driven vehicle mean (N = 7300)', 'Human driven vehicle 2-sigma boundary',...
   'Start of work zone','End of work zone'},'location','southwest');
xlabel('Station (m)');
yyaxis left;
ylabel('Speed (m/s)');
yyaxis right;
ylabel('Speed (mph)');
grid on;
print(gcf,['.\Fig\',sim_name,'_siteSpecificSpeed'],'-dsvg');


%% site specific speed disparity 
siteSpeSpeedDis.MeanData = statsRes.avResampled.meanData - statsRes.otherVehResampled.meanData;
siteSpeSpeedDis.SD = sqrt(statsRes.avResampled.SD.^2 + statsRes.otherVehResampled.SD.^2);
siteSpeSpeedDis.upperBD = siteSpeSpeedDis.MeanData + 2 * siteSpeSpeedDis.SD;
siteSpeSpeedDis.lowerBD = siteSpeSpeedDis.MeanData -   2 * siteSpeSpeedDis.SD;
fignum = 150;
[h1,h2] = fcn_AVConsistency_plotStats(siteSpeSpeedDis.MeanData, ...
    siteSpeSpeedDis.upperBD,siteSpeSpeedDis.lowerBD,resampleStation,'av',fignum,yyflagplot);
h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]);

legend([h1,h2,h5,h6],{'Speed disparity (N = 10)', '2-sigma boundary',...
   'Start of work zone','End of work zone'},'location','southwest');
xlabel('Station (m)');
yyaxis left;
ylabel({'Speed disparity of AV relative', 'to human driven vehicle (m/s)'});
yyaxis right;
ylabel({'Speed disparity of AV relative', 'to human driven vehicle (mph)'});
grid on;
print(gcf,['.\Fig\',sim_name,'_SpeedDisparity'],'-dsvg');




%% speed disparity to lead vehicle
% speed disparity of av relative to lead vehicle
fignum = 200;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avlead.speedDisparity.meanData, ...
    statsRes.avlead.speedDisparity.upperBD,statsRes.avlead.speedDisparity.lowerBD,resampleStation,'av',fignum,yyflagplot);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.hvlead.speedDisparity.meanData, ...
    statsRes.hvlead.speedDisparity.upperBD,statsRes.hvlead.speedDisparity.lowerBD,resampleStation,'other',fignum,yyflagplot);
xlim([0 1500]);

h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,h5,h6],{'Mean of speed disparity of AV relative to leading human driven vehicle (N = 10)', ...
    '2-sigma boundary of AV relative to leading vehicle', ...
    'Mean of speed disparity of human driven vehicle relative to leading human driven vehicle (N = 10)',...
    '2-sigma boundary of human driven vehicle relative to leading human driven vehicle', ...
   'Start of work zone', ...
   'End of work zone'},'location','southwest');

xlabel('Station (m)');
yyaxis left;
ylabel('Speed relative to leading human driven vehicle (m/s)');
yyaxis right;
ylabel('Speed relative to leading human driven vehicle (mph)');
grid on;
print(gcf,['.\Fig\',sim_name,'_leadVehSpeedDisparity'],'-dsvg');

% % speed disparity of human vehicle to lead vehicle 
% fignum = 250;
% [h1,h2] = fcn_AVConsistency_plotStats(statsRes.hvlead.speedDisparity.meanData, ...
%     statsRes.hvlead.speedDisparity.upperBD,statsRes.hvlead.speedDisparity.lowerBD,resampleStation,'av',fignum,yyflagplot);
% 
% xlim([0 1500]);
% 
% h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
% h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
% legend([h1,h2,h5,h6],{'Mean of speed disparity (N = 10)','2-sigma boundary', ...
%    'Start of work zone','End of work zone'},'location','southwest');
% xlabel('Station (m)');
% yyaxis left;
% ylabel('Speed of a human driven vehicle to leading human driven vehicle (m/s)');
% yyaxis right;
% ylabel('Speed of a human driven vehicle to leading human driven vehicle (mph)');
% grid on;
% print(gcf,['.\Fig\',sim_name,'_leadVehSpeedDisparity_hv2hv'],'-dsvg');

%% spacing to lead vehicle

% spacing of av to lead vehicle
fignum = 300;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avlead.spacing.meanData, ...
    statsRes.avlead.spacing.upperBD,statsRes.avlead.spacing.lowerBD,resampleStation,'av',fignum,0);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.hvlead.spacing.meanData, ...
    statsRes.hvlead.spacing.upperBD,statsRes.hvlead.spacing.lowerBD,resampleStation,'other',fignum,0);
xlim([0 1500]);

h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,h5,h6],{'Mean of spacing of AV relative to leading human driven vehicle (N = 10)', ...
    '2-sigma boundary of AV relative to leading vehicle', ...
    'Mean of spacing of human driven vehicle relative to leading human driven vehicle (N = 10)',...
    '2-sigma boundary of human driven vehicle relative to leading human driven vehicle', ...
   'Start of work zone', ...
   'End of work zone'},'location','southwest');
xlabel('Station (m)');
ylabel('Spacing relative to leading human driven vehicle (m)');
grid on;
print(gcf,['.\Fig\',sim_name,'_leadVehSpacing'],'-dsvg');

% % spacing of hv to lead vehicle
% fignum = 350;
% [h1,h2] = fcn_AVConsistency_plotStats(statsRes.hvlead.spacing.meanData, ...
%     statsRes.hvlead.spacing.upperBD,statsRes.hvlead.spacing.lowerBD,resampleStation,'av',fignum,0);
% 
% xlim([0 1500]);
% 
% h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
% h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
% legend([h1,h2,h5,h6],{'Mean of vehicle spacing (N = 10)','2-sigma boundary', ...
%    'Start of work zone','End of work zone'},'location','southwest');
% xlabel('Station (m)');
% ylabel('Spacing of human driven vehicle relative to leading human driven vehicle (m)');
% grid on;
% print(gcf,['.\Fig\',sim_name,'_leadVehSpacing_hv2hv'],'-dsvg');




%% speed disparity to following vehicle

% speed disparity of av relative to follow vehicle
fignum = 400;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avfollow.speedDisparity.meanData, ...
    statsRes.avfollow.speedDisparity.upperBD,statsRes.avfollow.speedDisparity.lowerBD,resampleStation,'av',fignum,yyflagplot);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.hvfollow.speedDisparity.meanData, ...
    statsRes.hvfollow.speedDisparity.upperBD,statsRes.hvfollow.speedDisparity.lowerBD,resampleStation,'other',fignum,yyflagplot);
xlim([0 1500]);

h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,h5,h6],{'Mean of speed disparity of AV relative to following human driven vehicle (N = 10)', ...
    '2-sigma boundary of AV relative to following vehicle', ...
    'Mean of speed disparity of human driven vehicle relative to following human driven vehicle (N = 10)',...
    '2-sigma boundary of human driven vehicle relative to following human driven vehicle', ...
   'Start of work zone', ...
   'End of work zone'},'location','southwest');

xlabel('Station (m)');
yyaxis left;
ylabel('Speed relative to following human driven vehicle (m/s)');
yyaxis right;
ylabel('Speed relative to following human driven vehicle (mph)');
grid on;
print(gcf,['.\Fig\',sim_name,'_followVehSpeedDisparity'],'-dsvg');

% % speed disparity of hv relative to follow vehicle
% fignum = 450;
% [h1,h2] = fcn_AVConsistency_plotStats(statsRes.hvfollow.speedDisparity.meanData, ...
%     statsRes.hvfollow.speedDisparity.upperBD,statsRes.hvfollow.speedDisparity.lowerBD,resampleStation,'av',fignum,yyflagplot);
% 
% xlim([0 1500]);
% 
% h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
% h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
% legend([h1,h2,h5,h6],{'Mean of speed disparity (N = 10)','2-sigma boundary', ...
%    'Start of work zone','End of work zone'},'location','southwest');
% xlabel('Station (m)');
% yyaxis left;
% ylabel('Speed of human driven vehicle relative to following human driven vehicle (m/s)');
% yyaxis right;
% ylabel('Speed of human driven vehicle relative to following human driven vehicle (mph)');
% grid on;
% print(gcf,['.\Fig\',sim_name,'_followVehSpeedDisparity_hv2hv'],'-dsvg');



%% spacing to following vehicle 

fignum = 500;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avfollow.spacing.meanData, ...
    statsRes.avfollow.spacing.upperBD,statsRes.avfollow.spacing.lowerBD,resampleStation,'av',fignum,0);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.hvfollow.spacing.meanData, ...
    statsRes.hvfollow.spacing.upperBD,statsRes.hvfollow.spacing.lowerBD,resampleStation,'other',fignum,0);
xlim([0 1500]);

h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,h5,h6],{'Mean of spacing of AV relative to following human driven vehicle (N = 10)', ...
    '2-sigma boundary of AV relative to following vehicle', ...
    'Mean of spacing of human driven vehicle relative to following human driven vehicle (N = 10)',...
    '2-sigma boundary of human driven vehicle relative to following human driven vehicle', ...
   'Start of work zone', ...
   'End of work zone'},'location','southwest');
xlabel('Station (m)');
ylabel('Spacing relative to following human driven vehicle (m)');
grid on;
print(gcf,['.\Fig\',sim_name,'_followVehSpacing'],'-dsvg');

% fignum = 550;
% [h1,h2] = fcn_AVConsistency_plotStats(statsRes.hvfollow.spacing.meanData, ...
%     statsRes.hvfollow.spacing.upperBD,statsRes.hvfollow.spacing.lowerBD,resampleStation,'av',fignum,0);
% 
% xlim([0 1500]);
% 
% h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
% h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
% legend([h1,h2,h5,h6],{'Mean of vehicle spacing (N = 10)', '2-sigma boundary',...
%    'Start of work zone','End of work zone'},'location','southwest');
% xlabel('Station (m)');
% ylabel('Spacing of human driven vehicle relative to following human driven vehicle (m)');
% grid on;
% print(gcf,['.\Fig\',sim_name,'_followVehSpacing'],'-dsvg');




%%
fignum = 600;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.acceleration_x.meanData, ...
    statsRes.acceleration_x.upperBD,statsRes.acceleration_x.lowerBD,resampleStation,'av',fignum,0);

xlim([0 1500]);

h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h5,h6],{'Mean of acceleration (N = 10)','2-sigma boundary', ...
   'Start of work zone','End of work zone'},'location','southwest');
xlabel('Station (m)');
ylabel('Acceleration in X direction (m/s^2)');
grid on;
print(gcf,['.\Fig\',sim_name,'_acceleration_x'],'-dsvg');

%%
fignum = 700;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.acceleration_y.meanData, ...
    statsRes.acceleration_y.upperBD,statsRes.acceleration_y.lowerBD,resampleStation,'av',fignum,0);
y_limits = ylim;
xlim([0 1500]);

h5=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
h6=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h5,h6],{'Mean of acceleration (N = 10)','2-sigma boundary', ...
   'Start of work zone','End of work zone'},'location','southwest');
xlabel('Station (m)');
ylabel('Acceleration in Y direction (m/s^2)');
grid on;
print(gcf,['.\Fig\',sim_name,'_acceleration_y'],'-dsvg');

toc;
disp('=============================')

end

