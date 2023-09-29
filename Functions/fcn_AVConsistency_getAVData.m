function vehicleData = fcn_AVConsistency_getAVData(Data, vehicleID, varargin)
% fcn_getAVData queris AV speed from SUMO traffic simulation FCD outputs.
% Data stands for floating car data. It includes the following data:
%
%  timestep_time: The time step described by the values within this
% timestep-element, seconds
%  vehicle_angle: The angle of the vehicle in navigational standard (0-360
% degrees, going clockwise with 0 at the 12'o clock position), deg
%  vehicle_id: The id of the vehicle
%  vehicle_lane: The id of the current lane.
%  vehicle_pos: The running position of the vehicle measured from the
% start of the current lane, meters
%  vehicle_slope: The slope of the vehicle in degrees (equals the slope of
% the road at the current position), deg
%  vehicle_speed: The speed of the vehicle, m/s
%  vehicle_type: The name of the vehicle type
%  vehicle_x: The absolute X coordinate of the vehicle (center of front
%  bumper). The value depends on the given geographic projection, meters
%  vehicle_y: The absolute Y coordinate of the vehicle (center of front
%  bumper). The value depends on the given geographic projection, meters
%
% FORMAT: 
%
%       vehicleData = fcn_getAVData(Data, vehicleID, varargin)
%
% INPUTS:
%
%       Data: this is the read-in FCD data, usually in table format
%       vehicleID: the vehicle ID you want to query
%
% (optional)
%       varargin: figure number
%
% OUTPUTS:
%
%       vehicleData: the queried vehicle data

% DEPENDENCIES:
% NA
%
% EXAMPLES:
%
% See the script: script_test_fcn_getAVData.m
% for a full test suite.
%
% This function was written on 2023 07 23 by Wushuang Bai
% Questions or comments? contact wxb41@psu.edu
%
% REVISION HISTORY:
%
% 2023 07 23 first write of the code
% 2023 08 13 edited comments as per IVSG formats
% TO DO:
%
% -- fill in to-do items here.
flag_do_debug = 1; % Flag to show function info in UI
flag_do_plots = 0; % Flag to plot the final results
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

if flag_check_inputs == 1
    % Are there the right number of inputs?
    if nargin < 2 || nargin > 3
        error('Incorrect number of input arguments')
    end
end

% Does user want to show the plots?
if 3 == nargin
    fig_num = varargin{1};
    figure(fig_num);
    flag_do_plots = 1;
else
    if flag_do_debug
        fig = figure;
        fig_num = fig.Number;
        flag_do_plots = 1;
    end
end

%% Main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find the rows corresponding to the specified vehicle ID
vehicleRows = strcmp(Data.vehicle_id,vehicleID);

% Extract the data of the given vehicle
vehicleData  = Data(vehicleRows,:);


%% Any debugging?
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
if 1==flag_do_plots
figure(fig_num);
subplot(2,1,1);
plot(vehicleData.snapStation, vehicleData.vehicle_speed,'k.','linewidth',2);
hold on;
plot(vehicleData.snapStation, vehicleData.speed_filtered,'b.','linewidth',2)
xlabel('Station (m)');
ylabel('Speed (m/s)');
legend('raw','filtered');
subplot(2,1,2);
plot(vehicleData.vehicle_x,vehicleData.vehicle_y,'k','linewidth',2);
hold on;
plot(vehicleData.vehicle_x_filtered,vehicleData.vehicle_y_filtered,'b--','linewidth',2);
xlabel('X position (m)');
ylabel('Y position (m)');
legend('raw','filtered');
end
if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file); 
end
end
