    %% Introduction to and Purpose of the Safety Metrics code
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



%% Revision History:
% 2023_06_05 - mvp5724@psu.edu
% -- converting what was done before to this documation structure.
% -- Adding the correct code to allow for dependecies 

%% Prep the workspace
close all
clc
clear all
%% Dependencies and Setup of the Code
% The code requires several other libraries to work, namely the following
% 
% * DebugTools - the repo can be found at: https://github.com/ivsg-psu/Errata_Tutorials_DebugTools
%   PlotWorkZone - the repor can be found at: https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotWorkZone
% List what libraries we need, and where to find the codes for each
clear library_name library_folders library_url

ith_library = 1;
library_name{ith_library}    = 'DebugTools_v2023_04_22';
library_folders{ith_library} = {'Functions','Data'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/Errata_Tutorials_DebugTools/archive/refs/tags/DebugTools_v2023_04_22.zip';

% ith_library = ith_library+1;
% library_name{ith_library}    = 'PathClass_v2023_02_01';
% library_folders{ith_library} = {'Functions'};                                
% library_url{ith_library}     = 'https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotWorkZone/archive/refs/heads/main.zip';

%% Clear paths and folders, if needed
if 1==0

   fcn_INTERNAL_clearUtilitiesFromPathAndFolders;

end

%% Do we need to set up the work space?
if ~exist('flag_Safetymetrics_Folders_Initialized','var')
    this_project_folders = {'Functions','Data'};
    fcn_INTERNAL_initializeUtilities(library_name,library_folders,library_url,this_project_folders);  
    flag_Safetymetrics_Folders_Initialized = 1;
end

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


%% test - fcn_SafetyMetrics_showVehicleTrajandMetricInputs

% This function takes the real/simulation data as the input to perform SSM

runthis = 1;

if runthis
clear trajectory

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
fcn_SafetyMetrics_showVehicleTrajandMetricInputs(time, vehicleTraj, metricInputs, object, 1);

end

%% Get the trajectory
% Trajectory has to be in the form of time, x, y, yaw angle, 
% clear trajectory
% 
% [trajectory(:,1),trajectory(:,2),trajectory(:,3),trajectory(:,4),lanes,centerline,flag_object]=fcn_SafetyMetrics_create_vehicleTraj(3,1);


% [trajectory(1,:),trajectory(2,:),trajectory(3,:),trajectory(4,:),flag_object]=fcn_SafetyMetrics_create_vehicleTraj(3,1);
figure(455)
plot3(trajectory(:,2),trajectory(:,3),trajectory(:,1));
grid on;
axis equal;
%% Plot the data
time_interval = 5; % How many points to plot. 1 means every point, 2 every other point 
[fig_num,car1_layers]=fcn_SafetyMetrics_plotTrajectoryXY(trajectory,vehicle_param,time_interval, 1);
car1_patch=fcn_PlotWZ_createPatchesFromNSegments(car1_layers); % Creates the 3d object of the car to use in SSMs that require a car infront
%% Plot objects
flag_barrel = 1; % Flag if a barrel will be used for the object
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
    [object]=fcn_SafetyMetrics_add_and_plot_object(trajectory,object_vertices,object_position,1,vehicle_param,fig_num);
end
%% Plot the lanes
num_of_lanes = size(lanes,2);
flag_plot_lanes = 1;
if flag_plot_lanes
    for j = 1:num_of_lanes
        [lane_patches(j)]=fcn_SafetyMetrics_plot_lanes(lanes(1,j),485);
    end
end
%% Calculate the unit vector for each point

[u,rear_axle]=fcn_SafetyMetrics_unit_vector(trajectory,vehicle_param,36363);
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

[TTC]=fcn_SafetyMetrics_TTC(u,trajectory,rear_axle,object)

%TLC
[TLC1,TLC2]=fcn_SafetyMetrics_TLC(u,trajectory,rear_axle,lane_patches)

%PET
[PET]=fcn_SafetyMetrics_PET(car1_patch,vehicle_param)

%DRAC
[DRAC]=fcn_SafetyMetrics_DRAC(u,trajectory,rear_axle,TTC,object,flag_object)

%SD
[SD,TA,slope_V_car3,rear_axle3,u3,car3_traj]=fcn_SafetyMetrics_SD(car1_patch,vehicle_param,trajectory)

%CSI
[CSI]=fcn_SafetyMetrics_CSI(car1_patch,TA,slope_V_car3,rear_axle3,u3,car3_traj)

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
path_dirs = regexp(path,'[;]','split');
utilities_dir = fullfile(pwd,filesep,'Utilities');
for ith_dir = 1:length(path_dirs)
    utility_flag = strfind(path_dirs{ith_dir},utilities_dir);
    if ~isempty(utility_flag)
        rmpath(path_dirs{ith_dir});
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

%% fcn_INTERNAL_initializeUtilities
function  fcn_INTERNAL_initializeUtilities(library_name,library_folders,library_url,this_project_folders)
% Reset all flags for installs to empty
clear global FLAG*

fprintf(1,'Installing utilities necessary for code ...\n');

% Dependencies and Setup of the Code
% This code depends on several other libraries of codes that contain
% commonly used functions. We check to see if these libraries are installed
% into our "Utilities" folder, and if not, we install them and then set a
% flag to not install them again.

% Set up libraries
for ith_library = 1:length(library_name)
    dependency_name = library_name{ith_library};
    dependency_subfolders = library_folders{ith_library};
    dependency_url = library_url{ith_library};

    fprintf(1,'\tAdding library: %s ...',dependency_name);
    fcn_INTERNAL_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url);
    clear dependency_name dependency_subfolders dependency_url
    fprintf(1,'Done.\n');
end

% Set dependencies for this project specifically
fcn_DebugTools_addSubdirectoriesToPath(pwd,this_project_folders);

disp('Done setting up libraries, adding each to MATLAB path, and adding current repo folders to path.');
end % Ends fcn_INTERNAL_initializeUtilities


function fcn_INTERNAL_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url, varargin)
%% FCN_DEBUGTOOLS_INSTALLDEPENDENCIES - MATLAB package installer from URL
%
% FCN_DEBUGTOOLS_INSTALLDEPENDENCIES installs code packages that are
% specified by a URL pointing to a zip file into a default local subfolder,
% "Utilities", under the root folder. It also adds either the package
% subfoder or any specified sub-subfolders to the MATLAB path.
%
% If the Utilities folder does not exist, it is created.
% 
% If the specified code package folder and all subfolders already exist,
% the package is not installed. Otherwise, the folders are created as
% needed, and the package is installed.
% 
% If one does not wish to put these codes in different directories, the
% function can be easily modified with strings specifying the
% desired install location.
% 
% For path creation, if the "DebugTools" package is being installed, the
% code installs the package, then shifts temporarily into the package to
% complete the path definitions for MATLAB. If the DebugTools is not
% already installed, an error is thrown as these tools are needed for the
% path creation.
% 
% Finally, the code sets a global flag to indicate that the folders are
% initialized so that, in this session, if the code is called again the
% folders will not be installed. This global flag can be overwritten by an
% optional flag input.
%
% FORMAT:
%
%      fcn_DebugTools_installDependencies(...
%           dependency_name, ...
%           dependency_subfolders, ...
%           dependency_url)
%
% INPUTS:
%
%      dependency_name: the name given to the subfolder in the Utilities
%      directory for the package install
%
%      dependency_subfolders: in addition to the package subfoder, a list
%      of any specified sub-subfolders to the MATLAB path. Leave blank to
%      add only the package subfolder to the path. See the example below.
%
%      dependency_url: the URL pointing to the code package.
%
%      (OPTIONAL INPUTS)
%      flag_force_creation: if any value other than zero, forces the
%      install to occur even if the global flag is set.
%
% OUTPUTS:
%
%      (none)
%
% DEPENDENCIES:
%
%      This code will automatically get dependent files from the internet,
%      but of course this requires an internet connection. If the
%      DebugTools are being installed, it does not require any other
%      functions. But for other packages, it uses the following from the
%      DebugTools library: fcn_DebugTools_addSubdirectoriesToPath
%
% EXAMPLES:
%
% % Define the name of subfolder to be created in "Utilities" subfolder
% dependency_name = 'DebugTools_v2023_01_18';
%
% % Define sub-subfolders that are in the code package that also need to be
% % added to the MATLAB path after install; the package install subfolder
% % is NOT added to path. OR: Leave empty ({}) to only add 
% % the subfolder path without any sub-subfolder path additions. 
% dependency_subfolders = {'Functions','Data'};
%
% % Define a universal resource locator (URL) pointing to the zip file to
% % install. For example, here is the zip file location to the Debugtools
% % package on GitHub:
% dependency_url = 'https://github.com/ivsg-psu/Errata_Tutorials_DebugTools/blob/main/Releases/DebugTools_v2023_01_18.zip?raw=true';
%
% % Call the function to do the install
% fcn_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url)
%
% This function was written on 2023_01_23 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
% 2023_01_23:
% -- wrote the code originally
% 2023_04_20:
% -- improved error handling
% -- fixes nested installs automatically

% TO DO
% -- Add input argument checking

flag_do_debug = 0; % Flag to show the results for debugging
flag_do_plots = 0; % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if flag_check_inputs
    % Are there the right number of inputs?
    narginchk(3,4);
end

%% Set the global variable - need this for input checking
% Create a variable name for our flag. Stylistically, global variables are
% usually all caps.
flag_varname = upper(cat(2,'flag_',dependency_name,'_Folders_Initialized'));

% Make the variable global
eval(sprintf('global %s',flag_varname));

if nargin==4
    if varargin{1}
        eval(sprintf('clear global %s',flag_varname));
    end
end

%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if ~exist(flag_varname,'var') || isempty(eval(flag_varname))
    % Save the root directory, so we can get back to it after some of the
    % operations below. We use the Print Working Directory command (pwd) to
    % do this. Note: this command is from Unix/Linux world, but is so
    % useful that MATLAB made their own!
    root_directory_name = pwd;

    % Does the directory "Utilities" exist?
    utilities_folder_name = fullfile(root_directory_name,'Utilities');
    if ~exist(utilities_folder_name,'dir')
        % If we are in here, the directory does not exist. So create it
        % using mkdir
        [success_flag,error_message,message_ID] = mkdir(root_directory_name,'Utilities');

        % Did it work?
        if ~success_flag
            error('Unable to make the Utilities directory. Reason: %s with message ID: %s\n',error_message,message_ID);
        elseif ~isempty(error_message)
            warning('The Utilities directory was created, but with a warning: %s\n and message ID: %s\n(continuing)\n',error_message, message_ID);
        end

    end

    % Does the directory for the dependency folder exist?
    dependency_folder_name = fullfile(root_directory_name,'Utilities',dependency_name);
    if ~exist(dependency_folder_name,'dir')
        % If we are in here, the directory does not exist. So create it
        % using mkdir
        [success_flag,error_message,message_ID] = mkdir(utilities_folder_name,dependency_name);

        % Did it work?
        if ~success_flag
            error('Unable to make the dependency directory: %s. Reason: %s with message ID: %s\n',dependency_name, error_message,message_ID);
        elseif ~isempty(error_message)
            warning('The %s directory was created, but with a warning: %s\n and message ID: %s\n(continuing)\n',dependency_name, error_message, message_ID);
        end

    end

    % Do the subfolders exist?
    flag_allFoldersThere = 1;
    if isempty(dependency_subfolders{1})
        flag_allFoldersThere = 0;
    else
        for ith_folder = 1:length(dependency_subfolders)
            subfolder_name = dependency_subfolders{ith_folder};
            
            % Create the entire path
            subfunction_folder = fullfile(root_directory_name, 'Utilities', dependency_name,subfolder_name);
            
            % Check if the folder and file exists that is typically created when
            % unzipping.
            if ~exist(subfunction_folder,'dir')
                flag_allFoldersThere = 0;
            end
        end
    end

    % Do we need to unzip the files?
    if flag_allFoldersThere==0
        % Files do not exist yet - try unzipping them.
        save_file_name = tempname(root_directory_name);
        zip_file_name = websave(save_file_name,dependency_url);
        % CANT GET THIS TO WORK --> unzip(zip_file_url, debugTools_folder_name);

        % Is the file there?
        if ~exist(zip_file_name,'file')
            error(['The zip file: %s for dependency: %s did not download correctly.\n' ...
                'This is usually because permissions are restricted on ' ...
                'the current directory. Check the code install ' ...
                '(see README.md) and try again.\n'],zip_file_name, dependency_name);
        end

        % Try unzipping
        unzip(zip_file_name, dependency_folder_name);

        % Did this work? If so, directory should not be empty
        directory_contents = dir(dependency_folder_name);
        if isempty(directory_contents)
            error(['The necessary dependency: %s has an error in install ' ...
                'where the zip file downloaded correctly, ' ...
                'but the unzip operation did not put any content ' ...
                'into the correct folder. ' ...
                'This suggests a bad zip file or permissions error ' ...
                'on the local computer.\n'],dependency_name);
        end

        % Check if is a nested install (for example, installing a folder
        % "Toolsets" under a folder called "Toolsets"). This can be found
        % if there's a folder whose name contains the dependency_name
        flag_is_nested_install = 0;
        for ith_entry = 1:length(directory_contents)
            if contains(directory_contents(ith_entry).name,dependency_name)
                if directory_contents(ith_entry).isdir
                    flag_is_nested_install = 1;
                    install_directory_from = fullfile(directory_contents(ith_entry).folder,directory_contents(ith_entry).name);
                    install_files_from = fullfile(directory_contents(ith_entry).folder,directory_contents(ith_entry).name,'*'); % BUG FIX - For Macs, must be *, not *.*
                    install_location_to = fullfile(directory_contents(ith_entry).folder);
                end
            end
        end

        if flag_is_nested_install
            [status,message,message_ID] = movefile(install_files_from,install_location_to);
            if 0==status
                error(['Unable to move files from directory: %s\n ' ...
                    'To: %s \n' ...
                    'Reason message: %s\n' ...
                    'And message_ID: %s\n'],install_files_from,install_location_to, message,message_ID);
            end
            [status,message,message_ID] = rmdir(install_directory_from);
            if 0==status
                error(['Unable remove directory: %s \n' ...
                    'Reason message: %s \n' ...
                    'And message_ID: %s\n'],install_directory_from,message,message_ID);
            end
        end

        % Make sure the subfolders were created
        flag_allFoldersThere = 1;
        if ~isempty(dependency_subfolders{1})
            for ith_folder = 1:length(dependency_subfolders)
                subfolder_name = dependency_subfolders{ith_folder};
                
                % Create the entire path
                subfunction_folder = fullfile(root_directory_name, 'Utilities', dependency_name,subfolder_name);
                
                % Check if the folder and file exists that is typically created when
                % unzipping.
                if ~exist(subfunction_folder,'dir')
                    flag_allFoldersThere = 0;
                end
            end
        end
         % If any are not there, then throw an error
        if flag_allFoldersThere==0
            error(['The necessary dependency: %s has an error in install, ' ...
                'or error performing an unzip operation. The subfolders ' ...
                'requested by the code were not found after the unzip ' ...
                'operation. This suggests a bad zip file, or a permissions ' ...
                'error on the local computer, or that folders are ' ...
                'specified that are not present on the remote code ' ...
                'repository.\n'],dependency_name);
        else
            % Clean up the zip file
            delete(zip_file_name);
        end

    end


    % For path creation, if the "DebugTools" package is being installed, the
    % code installs the package, then shifts temporarily into the package to
    % complete the path definitions for MATLAB. If the DebugTools is not
    % already installed, an error is thrown as these tools are needed for the
    % path creation.
    %
    % In other words: DebugTools is a special case because folders not
    % added yet, and we use DebugTools for adding the other directories
    if strcmp(dependency_name(1:10),'DebugTools')
        debugTools_function_folder = fullfile(root_directory_name, 'Utilities', dependency_name,'Functions');

        % Move into the folder, run the function, and move back
        cd(debugTools_function_folder);
        fcn_DebugTools_addSubdirectoriesToPath(dependency_folder_name,dependency_subfolders);
        cd(root_directory_name);
    else
        try
            fcn_DebugTools_addSubdirectoriesToPath(dependency_folder_name,dependency_subfolders);
        catch
            error(['Package installer requires DebugTools package to be ' ...
                'installed first. Please install that before ' ...
                'installing this package']);
        end
    end


    % Finally, the code sets a global flag to indicate that the folders are
    % initialized.  Check this using a command "exist", which takes a
    % character string (the name inside the '' marks, and a type string -
    % in this case 'var') and checks if a variable ('var') exists in matlab
    % that has the same name as the string. The ~ in front of exist says to
    % do the opposite. So the following command basically means: if the
    % variable named 'flag_CodeX_Folders_Initialized' does NOT exist in the
    % workspace, run the code in the if statement. If we look at the bottom
    % of the if statement, we fill in that variable. That way, the next
    % time the code is run - assuming the if statement ran to the end -
    % this section of code will NOT be run twice.

    eval(sprintf('%s = 1;',flag_varname));
end


%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots

    % Nothing to do!



end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends function fcn_DebugTools_installDependencies


function y = fcn_INTERNAL_modify_sigmoid(t, t0, t1, y0, y1, a_factor, b_factor)
% MODIFY_SIGMOID computes a modified sigmoid function with adjustable parameters

% Compute the adjusted parameters
a = a_factor / (t1 - t0);
b = b_factor * (t0 + t1) / 2;

% Compute the modified sigmoid function
y = y0 + (y1 - y0) ./ (1 + exp(-a * (t - b)));
end