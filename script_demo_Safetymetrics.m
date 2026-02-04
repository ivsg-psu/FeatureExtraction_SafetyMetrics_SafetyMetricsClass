
%% Introduction to and Purpose of the Code
% This is a demonstration script to show the primary functionality of the
% safety Metrics code
%
% This is the explanation of the code that can be found by running
%       script_demo_Safetymetrics.m
%
% This is a script to demonstrate the functions within the LoadWZ code
% library. This code repo is typically located at:
%
%   https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass
%
% If you have questions or comments, please contact Sean Brennan at
% sbrennan@psu.edu or Marcus (mvp5724@psu.edu)

% REVISION HISTORY:
% 
% 2023_06_05 - mvp5724@psu.edu
% - converting what was done before to this documation structure.
% - Adding the correct code to allow for dependecies 

% TO-DO:
% 

%% Make sure we are running out of root directory
st = dbstack; 
thisFile = which(st(1).file);
[filepath,name,ext] = fileparts(thisFile);
cd(filepath);

%%% START OF STANDARD INSTALLER CODE %%%%%%%%%

%% Clear paths and folders, if needed
if 1==1
    clear flag_SafetyMetrics_Folders_Initialized
end

if 1==0
    fcn_INTERNAL_clearUtilitiesFromPathAndFolders;
end

if 1==0
    % Resets all paths to factory default
    restoredefaultpath;
end

%% Install dependencies
% Define a universal resource locator (URL) pointing to the repos of
% dependencies to install. Note that DebugTools is always installed
% automatically, first, even if not listed:
clear dependencyURLs dependencySubfolders
ith_repo = 0;

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary';
dependencySubfolders{ith_repo} = {'Functions','Data'};

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotRoad';
dependencySubfolders{ith_repo} = {'Functions','Data'};

%% Do we need to set up the work space?
if ~exist('flag_SafetyMetrics_Folders_Initialized','var')
    
    % Clear prior global variable flags
    clear global FLAG_*

    % Navigate to the Installer directory
    currentFolder = pwd;
    cd('Installer');
    % Create a function handle
    func_handle = @fcn_DebugTools_autoInstallRepos;

    % Return to the original directory
    cd(currentFolder);

    % Call the function to do the install
    func_handle(dependencyURLs, dependencySubfolders, (0), (-1));

	% % Does LargeData exist?
	% if ~exist(fullfile(pwd,'LargeData'),'dir')
	% 	mkdir('LargeData');
	% end

    % Add this function's folders to the path
    this_project_folders = {...
        'Functions','Data'};
    fcn_DebugTools_addSubdirectoriesToPath(pwd,this_project_folders)

    flag_OSM2SHP_Folders_Initialized = 1;
end

%%% END OF STANDARD INSTALLER CODE %%%%%%%%%

%% Set environment flags for input checking in Laps library
% These are values to set if we want to check inputs or do debugging
setenv('MATLABFLAG_SAFETYMETRICS_FLAG_CHECK_INPUTS','1');
setenv('MATLABFLAG_SAFETYMETRICS_FLAG_DO_DEBUG','0');

%% Set environment flags that define the ENU origin
% This sets the "center" of the ENU coordinate system for all plotting
% functions
% Location for Test Track base station
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.86368573');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-77.83592832');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');


%% Set environment flags for plotting
% These are values to set if we are forcing image alignment via Lat and Lon
% shifting, when doing geoplot. This is added because the geoplot images
% are very, very slightly off at the test track, which is confusing when
% plotting data
setenv('MATLABFLAG_PLOTROAD_ALIGNMATLABLLAPLOTTINGIMAGES_LAT','-0.0000008');
setenv('MATLABFLAG_PLOTROAD_ALIGNMATLABLLAPLOTTINGIMAGES_LON','0.0000054');

%% Test the repo
if 1==0
	fcn_DebugTools_testRepoForRelease('_SafetyMetrics_');
end


%% Start of Demo Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____ _             _            __   _____                          _____          _
%  / ____| |           | |          / _| |  __ \                        / ____|        | |
% | (___ | |_ __ _ _ __| |_    ___ | |_  | |  | | ___ _ __ ___   ___   | |     ___   __| | ___
%  \___ \| __/ _` | '__| __|  / _ \|  _| | |  | |/ _ \ '_ ` _ \ / _ \  | |    / _ \ / _` |/ _ \
%  ____) | || (_| | |  | |_  | (_) | |   | |__| |  __/ | | | | | (_) | | |___| (_) | (_| |  __/
% |_____/ \__\__,_|_|   \__|  \___/|_|   |_____/ \___|_| |_| |_|\___/   \_____\___/ \__,_|\___|
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Start%20of%20Demo%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Welcome to the demo code for the SafetyMetrics library! Please read the Instructions')

%% Set up vehicle parameters
vehicle_param.w_vehicle = 69.3/(12*3.281); % the width of the vehicle_param, [m] from 63.9 inches
vehicle_param.length = 106.3/(12*3.281); % the length of the vehicle_param, [m]
vehicle_param.tire_width =  12.5/(12*3.281);  % the width of the wheel [m], assuming 12.5 inch width and 3.281 feet in a meter
vehicle_param.tire_length = 33/(12*3.281);  % the diameter of the wheel [m], assuming 12.5 inch width and 3.281 feet in a meter
vehicle_param.a = 1; % Location from the CG to the front axle [m]
vehicle_param.b = 1; % Location from the CG to the rear axle [m]
vehicle_param.Lf = 1.3;% Length from origin to front bumper
vehicle_param.Lr = 1.3;% Length from origin to front bumper

% % Use a plain tire - no spokes (see fcn_drawTire for details)
% vehicle_param.tire_type = 3;
%
% % Fill in tire information
% starter_tire = fcn_tire_initTire;
% starter_tire.usage = []
% for i_tire = 1:4
%     vehicle_param.tire(i_tire)= starter_tire;
% end
% vehicle_param.yawAngle_radians = 0; % the yaw angle of the body of the vehicle_param [rad]
% vehicle_param.position_x = 0; % the x-position of the vehicle_param [m]
% vehicle_param.position_y =0; % the y-position of the vehicle_param [m]
% vehicle_param.steeringAngle_radians = 0; % the steering angle of the front tires [rad]

%% fcn_SafetyMetrics_showVehicleTrajandMetricInputs: Takes the real/simulation data as the input to perform SSM

figNum = 10001;
titleString = sprintf('fcn_SafetyMetrics_showVehicleTrajandMetricInputs: Takes the real/simulation data as the input to perform SSM');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;


lane_width = 12/3.281; % 12ft to m (12ft from FHWA highway)


time = 1:1:500;
time = time';


%Specify the x coordinates
x1 = 1:1:200;
x2 = 201:1:300;
x3 = 301:1:500;
xtotal = [x1,x2,x3];
%Specify the first y segments
y1 = zeros(1,200);
y2 = fcn_INTERNAL_modify_sigmoid(x2,201,300,0,lane_width,17,1);
y3 = zeros(1,200)+lane_width;
ytotal = [y1,y2,y3];

vehicleTraj = [xtotal' ytotal'];


%object flag
object = 1;
%Creating the lanes
x_lane = 1:1:xtotal(end);
y_lane_L_L = zeros(1,xtotal(end))+3/2*lane_width; % L_L furthest left lane
y_lane_L = zeros(1,xtotal(end))+lane_width/2;
y_lane_R = zeros(1,xtotal(end))-lane_width/2;

metricInputs = [x_lane', y_lane_L_L', x_lane', y_lane_L', x_lane', y_lane_R'];


[trajectory(:,1), trajectory(:,2), trajectory(:,3), trajectory(:,4), lanes, centerline, flag_object] = ...
fcn_SafetyMetrics_showVehicleTrajandMetricInputs(time, vehicleTraj, metricInputs, object, (figNum));


%% fcn_OSM2SHP_convertUTCToDatetime: Convert the timestamp of OSM State College roads from UTC format to date time format

figNum = 10002;
titleString = sprintf('fcn_OSM2SHP_convertUTCToDatetime: Convert the timestamp of OSM State College roads from UTC format to date time format');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

% Shape file string of PA highways 
shapeFileString = "state_college_roads.shp";

% Create a geospatial table
geospatial_table = fcn_OSM2SHP_loadShapeFile(shapeFileString, -1);

% Call the function
date_time = fcn_OSM2SHP_convertUTCToDatetime(geospatial_table, (figNum)); 

% Assertions
assert(isequal(class(date_time), 'datetime'))
assert(isequal(length(geospatial_table.timestamp(:,1)), length(date_time(:,1))))

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% fcn_OSM2SHP_extractLLFromGeospatialTable: Extract the LL coordinates of OSM State College road segments

figNum = 10003;
titleString = sprintf('fcn_OSM2SHP_extractLLFromGeospatialTable: Extract the LL coordinates of OSM State College road segments');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

% Shape file string of PA highways 
shapeFileString = "state_college_roads.shp";

% Create a geospatial table
geospatial_table = fcn_OSM2SHP_loadShapeFile(shapeFileString, -1);

% Call the function
[LLCoordinate_allSegments, LL_allSegments_cell] = fcn_OSM2SHP_extractLLFromGeospatialTable(geospatial_table, (figNum));

% Assertions
assert(length(LLCoordinate_allSegments(:,1)) > size(geospatial_table, 1)); 
assert(isequal(length(LL_allSegments_cell), size(geospatial_table, 1)));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§


%% function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
% Clear out the variables
clear global flag* FLAG*
clear flag*
clear path

% Clear out any path directories under Utilities
if ispc
    path_dirs = regexp(path,'[;]','split');
elseif ismac
    path_dirs = regexp(path,'[:]','split');
elseif isunix
    path_dirs = regexp(path,'[;]','split');
else
    error('Unknown operating system. Unable to continue.');
end

utilities_dir = fullfile(pwd,filesep,'Utilities');
for ith_dir = 1:length(path_dirs)
    utility_flag = strfind(path_dirs{ith_dir},utilities_dir);
    if ~isempty(utility_flag)
        rmpath(path_dirs{ith_dir})
    end
end

% Delete the Utilities folder, to be extra clean!
if  exist(utilities_dir,'dir')
    [status,message,message_ID] = rmdir(utilities_dir,'s');
    if 0==status
        error('Unable remove directory: %s \nReason message: %s \nand message_ID: %s\n',utilities_dir, message,message_ID);
    end
end

end % Ends fcn_INTERNAL_clearUtilitiesFromPathAndFolders


function y = fcn_INTERNAL_modify_sigmoid(t, t0, t1, y0, y1, a_factor, b_factor)

% MODIFY_SIGMOID computes a modified sigmoid function with adjustable parameters

% Compute the adjusted parameters
a = a_factor / (t1 - t0);
b = b_factor * (t0 + t1) / 2;

% Compute the modified sigmoid function
y = y0 + (y1 - y0) ./ (1 + exp(-a * (t - b)));

end % Ends fcn_INTERNAL_modify_sigmoid

