clear;close all;clc;
if ~exist('Fig','dir')
mkdir('./Fig');
end

% fileRegExp = {'res_highway_Site_1180_peak_seed*.csv',...
%     'res_highway_Site_1180_off-peak_seed*.csv',...
%     };
straight_line = false
if straight_line == true
    pathXY = readtable('straight.csv');
    pathXY = [pathXY.Var1,pathXY.Var2];
    directory = ['/Users/linlyu/Desktop/ADS/20230227_Wiedemann/straight/res/'];
fileRegExp = {'res_highway_Site_1180_peak_seed*.csv',...
    'res_highway_Site_1180_off-peak_seed*.csv',...
    'res_Arterial_Site_1136_peak_seed*.csv',...
    'res_Arterial_Site_1136_off-peak_seed*.csv',...
    'res_Urban_Site_1135_peak_seed*.csv',...
    'res_Urban_Site_1135_off-peak_seed*.csv'};
else   
    pathXY = readtable('referenceline_20231016.csv');
    pathXY = [pathXY.Var1,pathXY.Var2];
    
    directory = ['/Users/linlyu/Desktop/ADS/20230227_Wiedemann/Scenario1_1/res/'];
fileRegExp = {'res_highway_Site_1180_peak_seed*.csv',...
    'res_highway_Site_1180_off-peak_seed*.csv',...
    'res_Arterial_Site_1136_peak_seed*.csv',...
    'res_Arterial_Site_1136_off-peak_seed*.csv',...
    'res_Urban_Site_1135_peak_seed*.csv',...
    'res_Urban_Site_1135_off-peak_seed*.csv'};
end
sensorRange = 100;
wzstart = 1067;
wzend = 1387; 
snap_indicator = false;

for kk = 1:1
files = dir(fullfile(directory, fileRegExp{kk}));
currentRegExp = fileRegExp{kk};
pattern = 'res_(.*?)_seed.*\.csv';
% Extract the matching substring
token = regexp(currentRegExp, pattern, 'tokens');
sim_name = token{1}{1};

pattern2 = 'res_(.*?)_Site_';
% Extract the matching substring
token2 = regexp(currentRegExp, pattern2, 'tokens');
modality1 = token2{1}{1};
if strcmp(modality1,'highway')
fileRegExp_1AV = 'res_highway_Site_1180_seed*_AV_1veh.csv';
fileRegExp_1HV = 'res_highway_Site_1180_seed*_human_1veh.csv';
elseif strcmp(modality1,'Arterial')
fileRegExp_1AV = 'res_Arterial_Site_1136_seed*_AV_1veh.csv';
fileRegExp_1HV = 'res_Arterial_Site_1136_seed*_human_1veh.csv';
                  
elseif strcmp(modality1,'Urban')
fileRegExp_1AV = 'res_Urban_Site_1135_seed*_AV_1veh.csv';
fileRegExp_1HV = 'res_Urban_Site_1135_seed*_human_1veh.csv';

end

files_1AV = dir(fullfile(directory, fileRegExp_1AV));
files_1HV =  dir(fullfile(directory, fileRegExp_1HV));


for ii = 1:length(files)
% for ii = 1:1 
    tic;
    filePath = fullfile(directory, files(ii).name);
    data = readtable(filePath);

    % Check for NaN values
    data = rmmissing(data);

    % check if the map is a straight line
    % if straight_line == true
    %     pathXY = [data.vehicle_x,data.vehicle_y];
    % end

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

    uniqVehID = unique(outputData(1).otherVehData.vehicle_id);
    

    % pick one human driven vehicle
    %hvID = 'f_lane_397.22';
    ind = floor(length(uniqVehID)/4);
    hvID = uniqVehID{ind};
    
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
%%

for k1 = 1:length(files_1AV)
    filePath_1AV = fullfile(directory, files_1AV(k1).name);
    filePath_1HV = fullfile(directory, files_1HV(k1).name);
    data1 = rmmissing(readtable(filePath_1AV));
    % check if the map is a straight line
    % if straight_line == true
    %     pathXY = [data1.vehicle_x,data1.vehicle_y];
    % end

    % Pre-process the data by adding total station
    data1 = fcn_AVConsistency_preProcessData(data1,pathXY);
    % Cut the ending part of the vehicle trajectory, where it is snaped
    % backwards from the first road segment
    data1 = data1(data1.snapStation>0,:);
    oneAV(k1).data = data1; 

    data2 = rmmissing(readtable(filePath_1HV));

    % check if the map is a straight line
    % if straight_line == true
    %     pathXY = [data2.vehicle_x,data2.vehicle_y];
    % end

    % Pre-process the data by adding total station
    data2 = fcn_AVConsistency_preProcessData(data2,pathXY);
    % Cut the ending part of the vehicle trajectory, where it is snaped
    % backwards from the first road segment
    data2 = data2(data2.snapStation>0,:);
    oneHV(k1).data = data2;


    filterFlag = 0; % not filtered data
    [station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_speed(data1,filterFlag);

    oneAV(k1).accel.snapStation = station;
    oneAV(k1).accel.acceleration_x=acceleration_x;
    oneAV(k1).accel.acceleration_y=acceleration_y;

    [station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_speed(data2,filterFlag);

    oneHV(k1).accel.snapStation = station;
    oneHV(k1).accel.acceleration_x=acceleration_x;
    oneHV(k1).accel.acceleration_y=acceleration_y;

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


for ii = 1:length(files_1AV)
   temp.oneAV{ii} = fcn_AVConsistency_resampleVehData(oneAV(ii).data,columns.veh,resampleStation);
   temp.oneHV{ii} = fcn_AVConsistency_resampleVehData(oneHV(ii).data,columns.veh,resampleStation);
end

oneAVResampled = vertcat(temp.oneAV{:});
oneHVResampled = vertcat(temp.oneHV{:});

clear temp;

statsRes.avResampled = fcn_AVConsistency_statistics(avResampled.vehicle_speed);
statsRes.otherVehResampled = fcn_AVConsistency_statistics(othervehResampled.vehicle_speed);
statsRes.oneAV = fcn_AVConsistency_statistics(oneAVResampled.vehicle_speed);
statsRes.oneHV = fcn_AVConsistency_statistics(oneHVResampled.vehicle_speed);

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
    
    temp.avAccel{ii} = fcn_AVConsistency_resampleDisparity(outputData(ii).avaccel,columns.accel,resampleStation);
    temp.hvAccel{ii} = fcn_AVConsistency_resampleDisparity(outputData(ii).hvaccel,columns.accel,resampleStation);
end

avAccelResampled = vertcat(temp.avAccel{:});
hvAccelResampled = vertcat(temp.hvAccel{:});

clear temp;
statsRes.avAccel.acceleration_x = fcn_AVConsistency_statistics(avAccelResampled.acceleration_x);
statsRes.avAccel.acceleration_y = fcn_AVConsistency_statistics(avAccelResampled.acceleration_y);
statsRes.hvAccel.acceleration_x = fcn_AVConsistency_statistics(hvAccelResampled.acceleration_x);
statsRes.hvAccel.acceleration_y = fcn_AVConsistency_statistics(hvAccelResampled.acceleration_y);

%%
for ii = 1:length(files)
    
    temp.oneavAccel{ii} = fcn_AVConsistency_resampleDisparity(oneAV(ii).accel,columns.accel,resampleStation);
    temp.onehvAccel{ii} = fcn_AVConsistency_resampleDisparity(oneHV(ii).accel,columns.accel,resampleStation);
end
oneAVAccelResampled = vertcat(temp.oneavAccel{:});
oneHVAccelResampled = vertcat(temp.onehvAccel{:});

statsRes.oneavAccel.acceleration_x = fcn_AVConsistency_statistics(oneAVAccelResampled.acceleration_x);
statsRes.oneavAccel.acceleration_y = fcn_AVConsistency_statistics(oneAVAccelResampled.acceleration_y);
statsRes.onehvAccel.acceleration_x = fcn_AVConsistency_statistics(oneHVAccelResampled.acceleration_x);
statsRes.onehvAccel.acceleration_y = fcn_AVConsistency_statistics(oneHVAccelResampled.acceleration_y);


 %  _____  _      ____ _______ _____ 
 % |  __ \| |    / __ \__   __/ ____|
 % | |__) | |   | |  | | | | | (___  
 % |  ___/| |   | |  | | | |  \___ \ 
 % | |    | |___| |__| | | |  ____) |
 % |_|    |______\____/  |_| |_____/
  
%% site specific speed: with traffic 
close all;
yyflagplot = 1;
fignum = 100;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avResampled.meanData, ...
    statsRes.avResampled.upperBD,statsRes.avResampled.lowerBD,resampleStation,'theme1',fignum,yyflagplot);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.otherVehResampled.meanData, ...
    statsRes.otherVehResampled.upperBD,statsRes.otherVehResampled.lowerBD,resampleStation,'theme2',fignum,yyflagplot);


hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]);

legend([h1,h2,h3,h4,hstart,hend],{'Mean of autonomous vehicle with traffic interaction (N = 10)', ...
    '2-sigma boundary of Autonomous vehicle with traffic interaction',...
    'Mean of human driven vehicle with traffic interaction (N = 7300)', ...
    '2-sigma boundary of human driven vehicle with traffic interaction ',...
   'Start of work zone','End of work zone'},'location','best');
xlabel('Station (m)');
yyaxis left;
ylabel('Speed (m/s)');
yyaxis right;
ylabel('Speed (mph)');
grid on;
print(gcf,['.\Fig\',sim_name,'_siteSpecificSpeed_withtraffic'],'-dsvg');


%% site specific speed: without traffic 
fignum = 101;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.oneAV.meanData, ...
    statsRes.oneAV.upperBD,statsRes.oneAV.lowerBD,resampleStation,'theme3',fignum,yyflagplot);
[h3,h4] = fcn_AVConsistency_plotStats(statsRes.oneHV.meanData, ...
    statsRes.oneHV.upperBD,statsRes.oneHV.lowerBD,resampleStation,'theme4',fignum,yyflagplot);

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]);

legend([h1,h2,h3,h4,hstart,hend],{'Mean of autonomous vehicle without traffic interaction (N = 10)', ...
    '2-sigma boundary of Autonomous vehicle without traffic interaction',...
    'Mean of human driven vehicle without traffic interaction (N = 10)', ...
    '2-sigma boundary of human driven vehicle without traffic interaction ',...
   'Start of work zone','End of work zone'},'location','best');
xlabel('Station (m)');
yyaxis left;
ylabel('Speed (m/s)');
yyaxis right;
ylabel('Speed (mph)');
grid on;
print(gcf,['.\Fig\',sim_name,'_siteSpecificSpeed_withouttraffic'],'-dsvg');



%% site specific speed disparity: with traffic 
siteSpeSpeedDis.MeanData = statsRes.avResampled.meanData - statsRes.otherVehResampled.meanData;
siteSpeSpeedDis.SD = sqrt(statsRes.avResampled.SD.^2 + statsRes.otherVehResampled.SD.^2);
siteSpeSpeedDis.upperBD = siteSpeSpeedDis.MeanData + 2 * siteSpeSpeedDis.SD;
siteSpeSpeedDis.lowerBD = siteSpeSpeedDis.MeanData -   2 * siteSpeSpeedDis.SD;
fignum = 150;
[h1,h2] = fcn_AVConsistency_plotStats(siteSpeSpeedDis.MeanData, ...
    siteSpeSpeedDis.upperBD,siteSpeSpeedDis.lowerBD,resampleStation,'theme1',fignum,yyflagplot);
hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]);

legend([h1,h2,hstart,hend],{'Mean of speed disparity of AV relative to human driven vehicle with traffic(N = 10)', ...
    '2-sigma boundary of speed disparity of AV and human driven vehicle with traffic',...
   'Start of work zone','End of work zone'},'location','best');
xlabel('Station (m)');
yyaxis left;
ylabel({'Speed disparity of AV relative', 'to human driven vehicle (m/s)'});
yyaxis right;
ylabel({'Speed disparity of AV relative', 'to human driven vehicle (mph)'});
grid on;
print(gcf,['.\Fig\',sim_name,'_SpeedDisparity_withTraffic'],'-dsvg');

%% site specific speed disparity: without traffic 


siteSpeOneveh.MeanData = statsRes.oneAV.meanData - statsRes.oneHV.meanData;
siteSpeOneveh.SD = sqrt(statsRes.oneAV.SD.^2 + statsRes.oneHV.SD.^2);
siteSpeOneveh.upperBD = siteSpeOneveh.MeanData + 2 * siteSpeOneveh.SD;
siteSpeOneveh.lowerBD = siteSpeOneveh.MeanData - 2 * siteSpeOneveh.SD;

fignum = 151;
[h1,h2] = fcn_AVConsistency_plotStats(siteSpeOneveh.MeanData, ...
    siteSpeOneveh.upperBD,siteSpeOneveh.lowerBD,resampleStation,'theme1',fignum,yyflagplot);
hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]);

legend([h1,h2,hstart,hend],{'Mean of speed disparity of AV relative to human driven vehicle without traffic (N = 10)', ...
    '2-sigma boundary of speed disparity of AV relative to human driven vehicle without traffic',...
   'Start of work zone','End of work zone'},'location','best');
xlabel('Station (m)');
yyaxis left;
ylabel({'Speed disparity of AV relative', 'to human driven vehicle (m/s)'});
yyaxis right;
ylabel({'Speed disparity of AV relative', 'to human driven vehicle (mph)'});
grid on;
print(gcf,['.\Fig\',sim_name,'_SpeedDisparity_withoutTraffic'],'-dsvg');


%% speed disparity to lead vehicle
% speed disparity of av relative to lead vehicle
fignum = 200;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avlead.speedDisparity.meanData, ...
    statsRes.avlead.speedDisparity.upperBD,statsRes.avlead.speedDisparity.lowerBD,resampleStation,'theme1',fignum,yyflagplot);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.hvlead.speedDisparity.meanData, ...
    statsRes.hvlead.speedDisparity.upperBD,statsRes.hvlead.speedDisparity.lowerBD,resampleStation,'theme2',fignum,yyflagplot);
xlim([0 1500]);

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,hstart,hend],{'Mean of speed disparity of AV relative to leading human driven vehicle (N = 10)', ...
    '2-sigma boundary of AV relative to leading human driven vehicle', ...
    'Mean of speed disparity of human driven vehicle relative to leading human driven vehicle (N = 10)',...
    '2-sigma boundary of human driven vehicle relative to leading human driven vehicle', ...
   'Start of work zone', ...
   'End of work zone'},'location','best');

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
%    'Start of work zone','End of work zone'},'location','best');
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
    statsRes.avlead.spacing.upperBD,statsRes.avlead.spacing.lowerBD,resampleStation,'theme1',fignum,0);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.hvlead.spacing.meanData, ...
    statsRes.hvlead.spacing.upperBD,statsRes.hvlead.spacing.lowerBD,resampleStation,'theme2',fignum,0);
xlim([0 1500]);

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,hstart,hend],{'Mean of spacing of AV relative to leading human driven vehicle (N = 10)', ...
    '2-sigma boundary of AV relative to leading human driven vehicle', ...
    'Mean of spacing of human driven vehicle relative to leading human driven vehicle (N = 10)',...
    '2-sigma boundary of human driven vehicle relative to leading human driven vehicle', ...
   'Start of work zone', ...
   'End of work zone'},'location','best');
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
%    'Start of work zone','End of work zone'},'location','best');
% xlabel('Station (m)');
% ylabel('Spacing of human driven vehicle relative to leading human driven vehicle (m)');
% grid on;
% print(gcf,['.\Fig\',sim_name,'_leadVehSpacing_hv2hv'],'-dsvg');




%% speed disparity to following vehicle

% speed disparity of av relative to follow vehicle
fignum = 400;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avfollow.speedDisparity.meanData, ...
    statsRes.avfollow.speedDisparity.upperBD,statsRes.avfollow.speedDisparity.lowerBD,resampleStation,'theme1',fignum,yyflagplot);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.hvfollow.speedDisparity.meanData, ...
    statsRes.hvfollow.speedDisparity.upperBD,statsRes.hvfollow.speedDisparity.lowerBD,resampleStation,'theme2',fignum,yyflagplot);
xlim([0 1500]);

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,hstart,hend],{'Mean of speed disparity of AV relative to following human driven vehicle (N = 10)', ...
    '2-sigma boundary of AV relative to following human driven vehicle', ...
    'Mean of speed disparity of human driven vehicle relative to following human driven vehicle (N = 10)',...
    '2-sigma boundary of human driven vehicle relative to following human driven vehicle', ...
   'Start of work zone', ...
   'End of work zone'},'location','best');

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
%    'Start of work zone','End of work zone'},'location','best');
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
    statsRes.avfollow.spacing.upperBD,statsRes.avfollow.spacing.lowerBD,resampleStation,'theme1',fignum,0);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.hvfollow.spacing.meanData, ...
    statsRes.hvfollow.spacing.upperBD,statsRes.hvfollow.spacing.lowerBD,resampleStation,'theme2',fignum,0);
xlim([0 1500]);

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,hstart,hend],{'Mean of spacing of AV relative to following human driven vehicle (N = 10)', ...
    '2-sigma boundary of AV relative to following human driven vehicle', ...
    'Mean of spacing of human driven vehicle relative to following human driven vehicle (N = 10)',...
    '2-sigma boundary of human driven vehicle relative to following human driven vehicle', ...
   'Start of work zone', ...
   'End of work zone'},'location','best');
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
%    'Start of work zone','End of work zone'},'location','best');
% xlabel('Station (m)');
% ylabel('Spacing of human driven vehicle relative to following human driven vehicle (m)');
% grid on;
% print(gcf,['.\Fig\',sim_name,'_followVehSpacing'],'-dsvg');




%% acceleration x  with traffic 
fignum = 600;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avAccel.acceleration_x.meanData, ...
    statsRes.avAccel.acceleration_x.upperBD,statsRes.avAccel.acceleration_x.lowerBD,resampleStation,'theme1',fignum,0);
[h3,h4] = fcn_AVConsistency_plotStats(statsRes.hvAccel.acceleration_x.meanData, ...
    statsRes.hvAccel.acceleration_x.upperBD,statsRes.hvAccel.acceleration_x.lowerBD,resampleStation,'theme2',fignum,0);

xlim([0 1500]);
ylim([-2 2]) % Set the y-axis range from -1 to 1

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,hstart,hend],{'Mean of AV acceleration with traffic interaction (N = 10)', ...
    '2-sigma boundary of AV acceleration with traffic interaction', ...
    'Mean of human drive vehicle acceleration with traffic interaction (N = 10)', ...
    '2-sigma boundary of human driven acceleration with traffic interaction', ...
   'Start of work zone', ...
   'End of work zone'},'location','best');
xlabel('Station (m)');
ylabel('Acceleration in X direction (m/s^2)');
grid on;
print(gcf,['.\Fig\',sim_name,'_acceleration_x_withTraffic'],'-dsvg');


%% acceleration x without traffic 
fignum = 601;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.oneavAccel.acceleration_x.meanData, ...
    statsRes.oneavAccel.acceleration_x.upperBD,statsRes.oneavAccel.acceleration_x.lowerBD,resampleStation,'theme3',fignum,0);
[h3,h4] = fcn_AVConsistency_plotStats(statsRes.onehvAccel.acceleration_x.meanData, ...
    statsRes.onehvAccel.acceleration_x.upperBD,statsRes.onehvAccel.acceleration_x.lowerBD,resampleStation,'theme4',fignum,0);

xlim([0 1500]);
ylim([-2 2]) % Set the y-axis range from -1 to 1
hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,hstart,hend],{'Mean of AV acceleration without traffic interaction (N = 10)', ...
    '2-sigma boundary of AV acceleration without traffic interaction', ...
    'Mean of human driven vehicle acceleration without traffic interaction (N = 10)', ...
    '2-sigma boundary of human driven vehicle acceleration without traffic interaction', ...
   'Start of work zone', ...
   'End of work zone'},'location','best');
xlabel('Station (m)');
ylabel('Acceleration in X direction (m/s^2)');
grid on;
print(gcf,['.\Fig\',sim_name,'_acceleration_x_withoutTraffic'],'-dsvg');


%% acceleration y with traffic 
fignum = 700;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avAccel.acceleration_y.meanData, ...
    statsRes.avAccel.acceleration_y.upperBD,statsRes.avAccel.acceleration_y.lowerBD,resampleStation,'theme1',fignum,0);
[h3,h4] = fcn_AVConsistency_plotStats(statsRes.hvAccel.acceleration_y.meanData, ...
    statsRes.hvAccel.acceleration_y.upperBD,statsRes.hvAccel.acceleration_y.lowerBD,resampleStation,'theme2',fignum,0);

xlim([0 1500]);
ylim([-2 4]) % Set the y-axis range from -1 to 1

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,hstart,hend],{'Mean of AV acceleration with traffic interaction (N = 10)', ...
    '2-sigma boundary of AV acceleration with traffic interaction', ...
    'Mean of human drive vehicle acceleration with traffic interaction (N = 10)', ...
    '2-sigma boundary of human driven acceleration with traffic interaction', ...
   'Start of work zone', ...
   'End of work zone'},'location','best');
xlabel('Station (m)');
ylabel('Acceleration in Y direction (m/s^2)');
grid on;
print(gcf,['.\Fig\',sim_name,'_acceleration_y_withTraffic'],'-dsvg');


%% acceleration y without traffic 
fignum = 701;
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.oneavAccel.acceleration_y.meanData, ...
    statsRes.oneavAccel.acceleration_y.upperBD,statsRes.oneavAccel.acceleration_y.lowerBD,resampleStation,'theme3',fignum,0);
[h3,h4] = fcn_AVConsistency_plotStats(statsRes.onehvAccel.acceleration_y.meanData, ...
    statsRes.onehvAccel.acceleration_y.upperBD,statsRes.onehvAccel.acceleration_y.lowerBD,resampleStation,'theme4',fignum,0);

xlim([0 1500]);
ylim([-2 4]) % Set the y-axis range from -1 to 1

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,hstart,hend],{'Mean of AV acceleration without traffic interaction (N = 10)', ...
    '2-sigma boundary of AV acceleration without traffic interaction', ...
    'Mean of human driven vehicle acceleration without traffic interaction (N = 10)', ...
    '2-sigma boundary of human driven vehicle acceleration without traffic interaction', ...
   'Start of work zone', ...
   'End of work zone'},'location','north');
xlabel('Station (m)');
ylabel('Acceleration in Y direction (m/s^2)');
grid on;
print(gcf,['.\Fig\',sim_name,'_acceleration_y_withoutTraffic'],'-dsvg');

toc;
disp('=============================')

end

