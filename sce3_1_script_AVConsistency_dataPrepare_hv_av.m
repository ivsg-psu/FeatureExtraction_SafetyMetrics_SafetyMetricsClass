function [statsRes,resampleStation] = sce3_1_script_AVConsistency_dataPrepare_hv_av(directory,fileRegExp,avID)
% this function is to process all data for scenario 3.1, for av or hv 
% following a working vehicle
% input:    
        % directory: path to access the csv file
        % fileRegExp: expression for a series of csv files, for av or hv
        % avID: avID for AV scenario, or hv id for HV scenario
% output: calulated statistics across all runs of simulations
          % resampleStation, from 0, 100, 200, ... 1500


pathXY = readtable('referenceline_20231016.csv');
pathXY = [pathXY.Var1,pathXY.Var2];

sensorRange = 100;
wzstart = 1067;
wzend = 1387; 

for kk = 1:1
files = dir(fullfile(directory, fileRegExp{kk}));
currentRegExp = fileRegExp{kk};
pattern = 'res_(.*?)_seed.*\.csv';
% Extract the matching substring
token = regexp(currentRegExp, pattern, 'tokens');
sim_name = token{1}{1};


for ii = 1:length(files)
% for ii = 1:1 
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
    % avID = 'av'; % Specify vehicle id to query, assume it's av
    [avData,otherVehData]= fcn_AVConsistency_getAVData(data,avID);% only for AV
    outputData(ii).data = data;
    outputData(ii).avData = avData;
    outputData(ii).otherVehData =  otherVehData;

    uniqVehID = unique(outputData(1).otherVehData.vehicle_id);
    

    % pick one human driven vehicle
    %hvID = 'f_lane_397.22';
    % ind = floor(length(uniqVehID)/4);
    % hvID = uniqVehID{ind};
    % 
    % [hvData,otherData2]= fcn_AVConsistency_getAVData(data,hvID);% only for HV
    % 
    % outputData(ii).hvData = hvData;


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

    % relativeTo = 'lead';
    % hvrelatestr = ['hv',relativeTo];
    % [hvTime,hvPosition,nearestVehID,speedDisparity,spacing] =  ...
    %     fcn_AVConsistency_SpeedDisparityAndSpacing(data, sensorRange, hvID, relativeTo);
    % 
    % outputData(ii).(hvrelatestr).timestep_time = hvTime;
    % outputData(ii).(hvrelatestr).snapStation = hvPosition;
    % outputData(ii).(hvrelatestr).nearestVehID = nearestVehID;
    % outputData(ii).(hvrelatestr).speedDisparity = speedDisparity;
    % outputData(ii).(hvrelatestr).spacing = spacing;    



    %% Calculate and plot follow spacing and speed disparity, av and human veh

    % relativeTo = 'follow';
    % avrelatestr = ['av',relativeTo];
    % [avTime,avPosition,nearestVehID,speedDisparity,spacing] =  ...
    %     fcn_AVConsistency_SpeedDisparityAndSpacing(data, sensorRange, avID, relativeTo);
    % outputData(ii).(avrelatestr).timestep_time = avTime;
    % outputData(ii).(avrelatestr).snapStation = avPosition;
    % outputData(ii).(avrelatestr).nearestVehID = nearestVehID;
    % outputData(ii).(avrelatestr).speedDisparity = speedDisparity;
    % outputData(ii).(avrelatestr).spacing = spacing;
    %% Calculate and plot follow spacing and speed disparity, human driven veh and following veh

    % relativeTo = 'follow';
    % hvrelatestr = ['hv',relativeTo];
    % [hvTime,hvPosition,nearestVehID,speedDisparity,spacing] =  ...
    %     fcn_AVConsistency_SpeedDisparityAndSpacing(data, sensorRange, hvID, relativeTo);
    % 
    % outputData(ii).(hvrelatestr).timestep_time = hvTime;
    % outputData(ii).(hvrelatestr).snapStation = hvPosition;
    % outputData(ii).(hvrelatestr).nearestVehID = nearestVehID;
    % outputData(ii).(hvrelatestr).speedDisparity = speedDisparity;
    % outputData(ii).(hvrelatestr).spacing = spacing;    

    %% Compute AV's total acceleration vector under different conditions

    filterFlag = 0; % not filtered data
    [station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_speed(avData,filterFlag);

    outputData(ii).avaccel.snapStation = station;
    outputData(ii).avaccel.acceleration_x=acceleration_x;
    outputData(ii).avaccel.acceleration_y=acceleration_y;
    %% Compute HV's total acceleration vector under different conditions

    % filterFlag = 0; % not filtered data
    % [station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_speed(hvData,filterFlag);
    % 
    % outputData(ii).hvaccel.snapStation = station;
    % outputData(ii).hvaccel.acceleration_x=acceleration_x;
    % outputData(ii).hvaccel.acceleration_y=acceleration_y;
end
%%


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


% for ii = 1:length(files_1AV)
%    temp.oneAV{ii} = fcn_AVConsistency_resampleVehData(oneAV(ii).data,columns.veh,resampleStation);
%    temp.oneHV{ii} = fcn_AVConsistency_resampleVehData(oneHV(ii).data,columns.veh,resampleStation);
% end
% 
% oneAVResampled = vertcat(temp.oneAV{:});
% oneHVResampled = vertcat(temp.oneHV{:});

clear temp;

statsRes.avResampled = fcn_AVConsistency_statistics(avResampled.vehicle_speed);
statsRes.otherVehResampled = fcn_AVConsistency_statistics(othervehResampled.vehicle_speed);
% statsRes.oneAV = fcn_AVConsistency_statistics(oneAVResampled.vehicle_speed);
% statsRes.oneHV = fcn_AVConsistency_statistics(oneHVResampled.vehicle_speed);

%% resample disparity

% circCols = {'avlead','avfollow','hvlead','hvfollow'};
circCols = {'avlead'};


for ii = 1:length(files)
    for colname = circCols
     
    temp.(colname{1}){ii} = fcn_AVConsistency_resampleDisparity(outputData(ii).(colname{1}), ...
        columns.lead,resampleStation);
    
    end
end

avleadResampled = vertcat(temp.avlead{:});
% avfollowResampled = vertcat(temp.avfollow{:});
% 
% hvleadResampled = vertcat(temp.hvlead{:});
% hvfollowResampled = vertcat(temp.hvfollow{:});

%%

% resampledNames = {'avleadResampled','avfollowResampled','hvleadResampled','hvfollowResampled'};
resampledNames = {'avleadResampled'};

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
    % temp.hvAccel{ii} = fcn_AVConsistency_resampleDisparity(outputData(ii).hvaccel,columns.accel,resampleStation);
end

avAccelResampled = vertcat(temp.avAccel{:});
% hvAccelResampled = vertcat(temp.hvAccel{:});

clear temp;
statsRes.avAccel.acceleration_x = fcn_AVConsistency_statistics(avAccelResampled.acceleration_x);
statsRes.avAccel.acceleration_y = fcn_AVConsistency_statistics(avAccelResampled.acceleration_y);
% statsRes.hvAccel.acceleration_x = fcn_AVConsistency_statistics(hvAccelResampled.acceleration_x);
% statsRes.hvAccel.acceleration_y = fcn_AVConsistency_statistics(hvAccelResampled.acceleration_y);

%%
% for ii = 1:length(files)
% 
%     temp.oneavAccel{ii} = fcn_AVConsistency_resampleDisparity(oneAV(ii).accel,columns.accel,resampleStation);
%     temp.onehvAccel{ii} = fcn_AVConsistency_resampleDisparity(oneHV(ii).accel,columns.accel,resampleStation);
% end
% oneAVAccelResampled = vertcat(temp.oneavAccel{:});
% oneHVAccelResampled = vertcat(temp.onehvAccel{:});
% 
% statsRes.oneavAccel.acceleration_x = fcn_AVConsistency_statistics(oneAVAccelResampled.acceleration_x);
% statsRes.oneavAccel.acceleration_y = fcn_AVConsistency_statistics(oneAVAccelResampled.acceleration_y);
% statsRes.onehvAccel.acceleration_x = fcn_AVConsistency_statistics(oneHVAccelResampled.acceleration_x);
% statsRes.onehvAccel.acceleration_y = fcn_AVConsistency_statistics(oneHVAccelResampled.acceleration_y);

  

end

