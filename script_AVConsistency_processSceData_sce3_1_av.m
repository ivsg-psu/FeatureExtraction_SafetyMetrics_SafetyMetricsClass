clear;close all;clc;
if ~exist('Fig','dir')
mkdir('./Fig');a
end
directory = ['/Users/linlyu/Desktop/ADS/20230227_Wiedemann/Scenario3_1/res/'];



% for av and working veh
fileRegExp_av = {'res_highway_Site_1180_av_seed*.csv',...
    'res_Arterial_Site_1136_av_seed*.csv',...
    'res_Urban_Site_1135_av_seed*.csv'};

% for hv and working veh
fileRegExp_hv = {'res_highway_Site_1180_hv_seed*.csv',...
    'res_Arterial_Site_1136_hv_seed*.csv',...
    'res_Urban_Site_1135_hv_seed*.csv'};
avID = 'av'; % Specify vehicle id to query, assume it's av
hvID = 'hv'; % Specify vehicle id to query, assume it's hv
[statsRes_av, resampleStation] = sce3_1_script_AVConsistency_dataPrepare_hv_av(directory,fileRegExp_av,avID)
[statsRes_hv, resampleStation] = sce3_1_script_AVConsistency_dataPrepare_hv_av(directory,fileRegExp_hv,hvID)


%% site specific speed: with traffic 
fileRegExp = {'res_highway_Site_1180_seed*.csv',...
    'res_Arterial_Site_1136_seed*.csv',...
    'res_Urban_Site_1135_seed*.csv'};
for kk = 1:1
files = dir(fullfile(directory, fileRegExp{kk}));
currentRegExp = fileRegExp{kk};
pattern = 'res_(.*?)_seed.*\.csv';
% Extract the matching substring
token = regexp(currentRegExp, pattern, 'tokens');
sim_name = token{1}{1};

close all;
sensorRange = 100;
wzstart = 1067;
wzend = 1387; 
yyflagplot = 0;
fignum = 100;

statsRes = statsRes_av % for av
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avResampled.meanData, ...
    statsRes.avResampled.upperBD,statsRes.avResampled.lowerBD,resampleStation,'theme3',fignum,yyflagplot);

[h3,h4] = fcn_AVConsistency_plotStats(statsRes.otherVehResampled.meanData, ...
    statsRes.otherVehResampled.upperBD,statsRes.otherVehResampled.lowerBD,resampleStation,'theme1',fignum,yyflagplot);

statsRes = statsRes_hv % for hv
[h5,h6] = fcn_AVConsistency_plotStats(statsRes.avResampled.meanData, ...
    statsRes.avResampled.upperBD,statsRes.avResampled.lowerBD,resampleStation,'theme4',fignum,yyflagplot);

% [h7,h8] = fcn_AVConsistency_plotStats(statsRes.otherVehResampled.meanData, ...
%     statsRes.otherVehResampled.upperBD,statsRes.otherVehResampled.lowerBD,resampleStation,'theme4',fignum,yyflagplot);

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]);


legend([h1,h2,h3,h5,h6,hstart,hend],{['Mean of ',avID], ...
    ['2-sigma boundary of ', avID],...
    'Working vehicle from av/hv scenario', ...
    ['Mean of ',hvID], ...
    ['2-sigma boundary of ', hvID],...
   'Start of work zone','End of work zone'},'location','best');
 
% xlim([wzstart wzend]);
ylim([0 35])

xlabel('Station (m)');
yyaxis left;
ylabel('Speed (m/s)');
yyaxis right;
ylabel('Speed (mph)');
grid on;
print(gcf,['.\Fig\',sim_name,'_siteSpecificSpeed_withtraffic'],'-dsvg');

%% site specific speed disparity: with traffic 

fignum = 150;
statsRes = statsRes_av % for av
siteSpeSpeedDis.MeanData = statsRes.avResampled.meanData - statsRes.otherVehResampled.meanData;
siteSpeSpeedDis.SD = sqrt(statsRes.avResampled.SD.^2 + statsRes.otherVehResampled.SD.^2);
siteSpeSpeedDis.upperBD = siteSpeSpeedDis.MeanData + 2 * siteSpeSpeedDis.SD;
siteSpeSpeedDis.lowerBD = siteSpeSpeedDis.MeanData -   2 * siteSpeSpeedDis.SD;
[h1,h2] = fcn_AVConsistency_plotStats(siteSpeSpeedDis.MeanData, ...
    siteSpeSpeedDis.upperBD,siteSpeSpeedDis.lowerBD,resampleStation,'theme3',fignum,yyflagplot);

statsRes = statsRes_hv % for av
siteSpeSpeedDis.MeanData = statsRes.avResampled.meanData - statsRes.otherVehResampled.meanData;
siteSpeSpeedDis.SD = sqrt(statsRes.avResampled.SD.^2 + statsRes.otherVehResampled.SD.^2);
siteSpeSpeedDis.upperBD = siteSpeSpeedDis.MeanData + 2 * siteSpeSpeedDis.SD;
siteSpeSpeedDis.lowerBD = siteSpeSpeedDis.MeanData -   2 * siteSpeSpeedDis.SD;

[h3,h4] = fcn_AVConsistency_plotStats(siteSpeSpeedDis.MeanData, ...
    siteSpeSpeedDis.upperBD,siteSpeSpeedDis.lowerBD,resampleStation,'theme4',fignum,yyflagplot);


% xlim([wzstart wzend]);
ylim([-5 30])
hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]);

legend([h1,h2,h3, h4,hstart,hend],{['Mean of speed disparity of ', avID, ' relative to working vehicle'], ...
    ['2-sigma boundary of speed disparity of ', avID, ' and working vehicle'],...
    ['Mean of speed disparity of ', hvID, ' relative to working vehicle'], ...
    ['2-sigma boundary of speed disparity of ', hvID, ' and working vehicle'],...
   'Start of work zone','End of work zone'},'location','best');
xlabel('Station (m)');
yyaxis left;
ylabel({['Speed disparity of ', avID, '/hv ', 'relative ', 'to working vehicle (m/s)']});
yyaxis right;
ylabel({['Speed disparity of ', avID, '/hv ',' relative ', 'to working vehicle (mph)']});
grid on;
print(gcf,['.\Fig\',sim_name,'_SpeedDisparity_withTraffic'],'-dsvg');


%% speed disparity to lead vehicle
% speed disparity of av relative to lead vehicle
fignum = 200;

statsRes = statsRes_av % for av
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avlead.speedDisparity.meanData, ...
    statsRes.avlead.speedDisparity.upperBD,statsRes.avlead.speedDisparity.lowerBD,resampleStation,'theme3',fignum,yyflagplot);

statsRes = statsRes_hv % for hv
[h3,h4] = fcn_AVConsistency_plotStats(statsRes.avlead.speedDisparity.meanData, ...
    statsRes.avlead.speedDisparity.upperBD,statsRes.avlead.speedDisparity.lowerBD,resampleStation,'theme4',fignum,yyflagplot);


% xlim([wzstart wzend]);
ylim([-5 30])
hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3, h4,hstart,hend],{ ...
    ['Mean of speed disparity of ', avID, ' relative to leading working vehicle'], ...
    ['2-sigma boundary of ', avID, ' relative to leading working vehicle'], ...
    ['Mean of speed disparity of ', hvID, ' relative to leading working vehicle'], ...
    ['2-sigma boundary of ', hvID, ' relative to leading working vehicle'], ...
   'Start of work zone', ...
   'End of work zone'},'location','best');

xlabel('Station (m)');
yyaxis left;
ylabel('Speed relative to leading working vehicle (m/s)');
yyaxis right;
ylabel('Speed relative to leading working vehicle (mph)');
grid on;
print(gcf,['.\Fig\',sim_name,'_leadVehSpeedDisparity'],'-dsvg');


%% spacing to lead vehicle

% spacing of av to lead vehicle
fignum = 300;
statsRes = statsRes_av % for av
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avlead.spacing.meanData, ...
    statsRes.avlead.spacing.upperBD,statsRes.avlead.spacing.lowerBD,resampleStation,'theme3',fignum,0);

statsRes = statsRes_hv % for hv
[h3,h4] = fcn_AVConsistency_plotStats(statsRes.avlead.spacing.meanData, ...
    statsRes.avlead.spacing.upperBD,statsRes.avlead.spacing.lowerBD,resampleStation,'theme4',fignum,0);


% xlim([wzstart wzend]);
ylim([-110 -5])
hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3, h4, hstart,hend],{ ...
    ['Mean of spacing of ', avID, ' relative to leading working'], ...
    ['2-sigma boundary of ', avID, ' relative to leading working vehicle'], ...
    ['Mean of spacing of ', hvID, ' relative to leading working'], ...
    ['2-sigma boundary of ', hvID, ' relative to leading working vehicle'], ...
   'Start of work zone', ...
   'End of work zone'},'location','best');
xlabel('Station (m)');
ylabel('Spacing relative to leading workinh vehicle (m)');
grid on;
print(gcf,['.\Fig\',sim_name,'_leadVehSpacing'],'-dsvg');


%% acceleration x  with traffic 
fignum = 600;

statsRes = statsRes_av % for av
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avAccel.acceleration_x.meanData, ...
    statsRes.avAccel.acceleration_x.upperBD,statsRes.avAccel.acceleration_x.lowerBD,resampleStation,'theme3',fignum,0);

statsRes = statsRes_hv % for hv
[h3,h4] = fcn_AVConsistency_plotStats(statsRes.avAccel.acceleration_x.meanData, ...
    statsRes.avAccel.acceleration_x.upperBD,statsRes.avAccel.acceleration_x.lowerBD,resampleStation,'theme4',fignum,0);

% xlim([wzstart wzend]);
ylim([-2 2]);

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4, hstart,hend],{ ...
    ['Mean of ', avID, ' x acceleration'], ...
    ['2-sigma boundary of ', avID, ' x acceleration'], ...
    ['Mean of ', hvID, ' x acceleration'], ...
    ['2-sigma boundary of ', hvID, ' x acceleration'], ...
   'Start of work zone', ...
   'End of work zone'},'location','best');
xlabel('Station (m)');
ylabel('Acceleration in X direction (m/s^2)');
grid on;
print(gcf,['.\Fig\',sim_name,'_acceleration_x_withTraffic'],'-dsvg');


%% acceleration y with traffic 
fignum = 700;

statsRes = statsRes_av % for av
[h1,h2] = fcn_AVConsistency_plotStats(statsRes.avAccel.acceleration_y.meanData, ...
    statsRes.avAccel.acceleration_y.upperBD,statsRes.avAccel.acceleration_y.lowerBD,resampleStation,'theme3',fignum,0);

statsRes = statsRes_hv % for hv
[h3,h4] = fcn_AVConsistency_plotStats(statsRes.avAccel.acceleration_y.meanData, ...
    statsRes.avAccel.acceleration_y.upperBD,statsRes.avAccel.acceleration_y.lowerBD,resampleStation,'theme4',fignum,0);

xlim([wzstart wzend]);
ylim([-4 4]);

hstart=xline(wzstart, ':', 'LineWidth', 2,'color',[0.4660 0.6740 0.1880]);
hend=xline(wzend, ':', 'LineWidth', 2,'color',[0.6350 0.0780 0.1840]	);
legend([h1,h2,h3,h4,hstart,hend],{ ...
    ['Mean of ',avID, ' y acceleration'], ...
    ['2-sigma boundary of ', avID, ' y acceleration'], ...
    ['Mean of ',hvID, ' y acceleration'], ...
    ['2-sigma boundary of ', hvID, ' y acceleration'], ...
   'Start of work zone', ...
   'End of work zone'},'location','best');
xlabel('Station (m)');
ylabel('Acceleration in Y direction (m/s^2)');
grid on;
print(gcf,['.\Fig\',sim_name,'_acceleration_y_withTraffic'],'-dsvg');

disp('=============================')

end;


