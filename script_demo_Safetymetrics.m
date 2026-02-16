%% Introduction to and Purpose of the Code
% This is a demonstration script to show the primary functionality of the
% safety Metrics code
%
% This is the explanation of the code that can be found by running
%
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
% 2026_02_04 by Aneesh Batchu, abb6486@psu.edu
% - Added auto Installer options
% - created this demo script from Marcus's old script
%
% 2026_02_07 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_generateVehicleTraj
%   % * Added DebugTools to check the inputs
%   % * Added switch cases to generate the trajectory
%   % * Created INTERNAL functions to generate the trajectories
%   % * Modified the code to output all the specified outputs for all
%   %   % trajectory types. Initially, the code was not outputting lanes,
%   %   % centerline for right and left hand turns.
%   % * Modifed name of the function to "fcn_SafetyMetrics_generateVehicleTraj"
%   %   % from "fcn_SafetyMetrics_create_vehicleTraj"
%
% 2026_02_07 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_plotTrajectoryXY
%   % * Fixed the code Trajectories 4 and 5.
%   % * Added DebugTools to check the inputs
%   % * Modified the function to latest format
%   % * Created the test script for this function
%
% 2026_02_10 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_checkTrajLaneMarkerCollison
%   % * Created this function to check for a collison between a vehicle
%   %   % trajectory and lane markers
%   % * Created a test script for the corresponding function as well
%
% 2026_02_16 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_generateVehicleBoundary2D
%   % * Created this function to generate a vehicle boundary in 2D
%   % * Created a test script for the corresponding function as well
% - In fcn_SafetyMetrics_computeTrajLaneDistance
%   % * Created this function to find distance betweeen lane marker and the
%   %   % vehicle trajectory
%   % * Seperated this function from
%   %   % "fcn_SafetyMetrics_checkTrajLaneMarkerCollisonAndDist"
% - In fcn_SafetyMetrics_checkTrajLaneMarkerCollison
%   % * Created this function to find intersection betweeen lane marker and
%   %   % the vehicle trajectory
%   % * Seperated this function from
%   %   % "fcn_SafetyMetrics_checkTrajLaneMarkerCollisonAndDist"%
% - In fcn_SafetyMetrics_checkTrajLaneCollisonAndDist
%   % * Renamed the function name from
%   %   % "fcn_SafetyMetrics_checkTrajLaneMarkerCollison"
%   % * This function calculates the distances from lane marker to
%   %   % trajectory and as well as finds the intersections between them.
%
% 2026_02_16 by Sean Brennan, sbrennan@psu.edu
% - In main folder
%   % * Moved old scripts into "Scripts_fromMarcus" folder
% - In script_demo_Safetymetrics (this script)
%   % * Fixed flag_OSM2SHP_Folders_Initialized
%   %   % Now: flag_SafetyMetrics_Folders_Initialized
% - In script_test_fcn_SafetyMetrics_generateVehicleBoundary2D
%   % * Added definitions of vehicleParametersStruct in each call to avoid
%   %   % throwing errors if user jumps into test case directly (which is normal)
% - In fcn_SafetyMetrics_generateVehicleBoundary2D
%   % * Removed dashed plotting style
%   % * Replaced OSM+2SHP flags with SAFETYMETRICS
% - In fcn_SafetyMetrics_computeTrajLaneDistance
%   % * Replaced OSM+2SHP flags with SAFETYMETRICS
% - In script_test_fcn_SafetyMetrics_showVehicleTrajandMetricInputs
%   % * Removed cl+c call
% - In fcn_SafetyMetrics_showVehicleTrajandMetricInputs
%   % * Formatted into standard form

% TO-DO:
%
% 2026_02_07 by Aneesh Batchu, abb6486@psu.edu
% - In demo script
%   % * Create a function to setup vehicle parameters
%
% 2026_02_16 by Sean Brennan, sbrennan@psu.edu
% - In fcn_SafetyMetrics_showVehicleTrajandMetricInputs
%   % * Need to explain purpose of code
%   % * Need assertion testing in test script

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

    flag_SafetyMetrics_Folders_Initialized = 1;
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

%% fcn_SafetyMetrics_generateVehicleTraj: Generates the trajectory

figNum = 10001;
titleString = sprintf('fcn_SafetyMetrics_generateVehicleTraj: Generates the trajectory');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);


% Trajectory string
TrajectoryTypeString = 'Half Lane Change'; % trajectories: 'Lane Change', 'Stopping at a Stop Sign', 'Half Lane Change', 'Right Hand Turn', 'Left Hand Turn'

% Call the function
[time, xTotal, yTotal, yaw, laneBoundaries, centerline, flagObject] = fcn_SafetyMetrics_generateVehicleTraj(TrajectoryTypeString, (figNum));

% Assertions
assert(isequal(length(time), 500))
assert(isequal(length(xTotal), length(time)))
assert(isequal(length(yTotal), length(time)))
assert(isequal(length(yaw), length(time)))
assert(isequal(flagObject, 1))
assert(isequal(length(laneBoundaries), 3))
assert(isequal(length(centerline), 2))
assert(isequal(class(laneBoundaries), 'cell'))
assert(isequal(class(centerline), 'cell'))

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% Plot the data

% Pre-allocate trajectory
trajectory = [time, xTotal, yTotal, yaw];

% Set up vehicle parameters
vehicleParameters.w_vehicle = 69.3/(12*3.281); % the width of the vehicle_param, [m] from 63.9 inches
vehicleParameters.length = 106.3/(12*3.281); % the length of the vehicle_param, [m]
vehicleParameters.tire_width =  12.5/(12*3.281);  % the width of the wheel [m], assuming 12.5 inch width and 3.281 feet in a meter
vehicleParameters.tire_length = 33/(12*3.281);  % the diameter of the wheel [m], assuming 12.5 inch width and 3.281 feet in a meter
vehicleParameters.a = 1; % Location from the CG to the front axle [m]
vehicleParameters.b = 1; % Location from the CG to the rear axle [m]
vehicleParameters.Lf = 1.3;% Length from origin to front bumper
vehicleParameters.Lr = 1.3;% Length from origin to front bumper

timeInterval = 5; % How many points to plot. 1 means every point, 2 every other point
fig_num = 485;
car1_layers = fcn_SafetyMetrics_plotTrajectoryXY(trajectory, vehicleParameters, timeInterval, 1, fig_num);
car1_patch=fcn_PlotWZ_createPatchesFromNSegments(car1_layers); % Creates the 3d object of the car to use in SSMs that require a car infront

%% Plot objects - Only for "Half Lane Change" trajectory

flag_barrel = 1; % Flag if a barrel will be used for the object (Only for 'Half Lane Change' trajectory (flag_barrel = 1))
flag_object = flagObject;
if flag_barrel
    %object_position = [257,1.2];
    object_position = [257,0]; % X, Y location of the object [m]
    x = object_position(1,1);
    y = object_position(1,2);

    % generate the points of the object
    % the example shown will be a barrel using dimesions from FHWA.
    % DIA = 23"

    dia = 23/39.37; %[m];
    r = dia/2;
    theta = linspace(0,2*pi,50); % Createing the points along the circumference of a circle. 50 total points.

    x2 = r*sin(theta)+x;
    y2 = r*cos(theta)+y;
    object_vertices = [x2;y2];
end

if flag_object
    % Plot the object with a choice for slices or 3d Mesh. 1 being mesh, 2
    % being slices with that number being the 4th input.
    [object]=fcn_SafetyMetrics_add_and_plot_object(trajectory,object_vertices,object_position,1,vehicleParameters,fig_num);
end
%% Plot the laneBoundaries
num_of_lanes = size(laneBoundaries,2);
flag_plot_lanes = 1;
if flag_plot_lanes
    lane_patches = nan(size(laneBoundaries,2));
    for j = 1:num_of_lanes
        [lane_patches(j)]=fcn_SafetyMetrics_plot_lanes(laneBoundaries(1,j),485);
    end
end
%% Calculate the unit vector for each point

[u,rear_axle]=fcn_SafetyMetrics_unit_vector(trajectory,vehicleParameters,36363);
if flag_object
    % Plot the object in the unit vector plot
    patch(object)
end
% %% Calculate teh Rear Axle Location for each point.
% [rear_axle]=fcn_SafetyMetrics_rear_axle(trajectory,vehicle_param);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    _____ __  __ __  __
%   / ____|  \/  |  \/  |
%  | (___ | \  / | \  / |___
%   \___ \| |\/| | |\/| / __|
%   ____) | |  | | |  | \__ \
%  |_____/|_|  |_|_|  |_|___/
% http://patorjk.com/software/taag/#p=display&f=Big&t=SMMs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TTC

% set(0,'DefaultAxesFontName','Times New Roman');
% set(0,'DefaultTextFontName','Times New Roman');
% set(0,'DefaultAxesFontSize',16);
% set(0,'DefaultTextFontSize',16);
% set(0,'defaulttextinterpreter','latex');
% set(0,'defaultAxesTickLabelInterpreter','latex');
% set(0,'defaultLegendInterpreter','latex');

%% TTC

[TTC] = fcn_SafetyMetrics_TTC(u,trajectory,rear_axle,object);

%% TLC

%TLC
[TLC1,TLC2] = fcn_SafetyMetrics_TLC(u,trajectory,rear_axle,lane_patches);

%% PET

%PET
[PET] = fcn_SafetyMetrics_PET(car1_patch,vehicleParameters);

%% DRAC

%DRAC
[DRAC] = fcn_SafetyMetrics_DRAC(u,trajectory,rear_axle,TTC,object,flag_object);

%% SD

%SD

[SD,TA,slope_V_car3,rear_axle3,u3,car3_traj] = fcn_SafetyMetrics_SD(car1_patch,vehicleParameters,trajectory);

%% CSI
%CSI
[CSI] = fcn_SafetyMetrics_CSI(car1_patch,TA,slope_V_car3,rear_axle3,u3,car3_traj);

%% RLP

%RLP
% Can be calulated all the time, distance from centerline
RLP1 = trajectory(:,3) - centerline{1,1}(:,2);
RLP2 = trajectory(:,3) - centerline{1,2}(:,2);


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


% function y = fcn_INTERNAL_modify_sigmoid(t, t0, t1, y0, y1, a_factor, b_factor)
%
% % MODIFY_SIGMOID computes a modified sigmoid function with adjustable parameters
%
% % Compute the adjusted parameters
% a = a_factor / (t1 - t0);
% b = b_factor * (t0 + t1) / 2;
%
% % Compute the modified sigmoid function
% y = y0 + (y1 - y0) ./ (1 + exp(-a * (t - b)));
%
% end % Ends fcn_INTERNAL_modify_sigmoid

