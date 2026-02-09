function  rotated_rectangle = fcn_SafetyMetrics_plot3DVehicle(vehiclePosition, vehicleParametersStruct, varargin)
%% fcn_SafetyMetrics_plot3DVehicle
% 
% This code will plot a vehicle given the x,y,t,yaw, and vehicle parameters.
%
% FORMAT:
%
% rotated_rectangle = fcn_SafetyMetrics_plot3DVehicle(vehicle_position, vehicle_param, varargin)
%
% INPUTS:
%
%     vehicle_position: [time, x, y, yaw_angle] 1x4 vector
%
%     vehicle_param: sturcture containing
%       a: distnace from origin to front axel (positive)
%       b: distnace form origin to rear axel (positive)
%       Lf:Length from origin to front bumper
%       Lr:Length from origin to rear bumper
%       w_tire_tire: width from center of tire to center of tire
%       w_vehicle:width form outer most left side to outer most right side
%       tire_width: width of one tire
%       tire_length: diameter of one tire
% 
%      (OPTIONAL INPUTS)
% 
%     plot_style: matlab input plotting style such as 'b-'
%
%     figNum: a figure number to plot results. If set to -1, skips any
%     input checking or debugging, no figures will be generated, and sets
%     up code to maximize speed.
%
%
% OUTPUTS:
% 
%     rotated_rectangle: the current layer data points.
%
% DEPENDENCIES:
%  
%     fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
% 
%       See the script:
%
%       script_test_fcn_SafetyMetrics_plot3DVehicle.m 
%
%       for a full test suite.
%
% This function was written on 2023_05_19 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu

%
% REVISION HISTORY:
%
% 2023_05_17 by Marcus Putz and Sean Brennan
% - first write of function
% 
% 2026_02_08 by Aneesh Batchu, abb6486@psu.edu
% - Added DebugTools to check the inputs
% - Modified the function to latest format
% - Created the test script for this function


% TO DO:
%
% - fill in to-do items here.

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 4; % The largest Number of argument inputs to the function
flag_max_speed = 0;
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
    flag_do_debug = 0; %     % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; %     % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_SAFETYMETRICS_FLAG_CHECK_INPUTS");
    MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG = getenv("MATLABFLAG_SAFETYMETRICS_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG); 
        flag_check_inputs  = str2double(MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS);
    end
end

% flag_do_debug = 1;

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_figNum = 999978; %#ok<NASGU>
else
    debug_figNum = []; %#ok<NASGU>
end

%% check input arguments?
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


if 0 == flag_max_speed
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(2,MAX_NARGIN);

        % vehicle_position should have 4 column of numbers
        fcn_DebugTools_checkInputsToFunctions(...
            vehiclePosition, '4column_of_numbers');

        % % vehicle_param is a structure
        % fcn_DebugTools_checkInputsToFunctions(...
        %     vehicleParametersStruct, 'likestructure');

    end
end

% Does user want to specify the plot style?
plot_style = '-'; % Default is a line - changes color each time plot is called
if (0==flag_max_speed) && (MAX_NARGIN == nargin)
    temp = varargin{1};
    if ~isempty(temp)
        plot_style = temp;
    end
end

% Check to see if user specifies figNum?
flag_do_plots = 0; % Default is to NOT show plots
if (0==flag_max_speed) && (MAX_NARGIN == nargin)
    temp = varargin{end};
    if ~isempty(temp)
        figNum = temp;
        flag_do_plots = 1;
    end
end

% %% open figures
% if isempty(fig_num)
%     figure; % create new figure with next default index
% else
%     % check to see that the handle is an axis. If so, use it and don't just
%     % go to a new figure
%     if isgraphics(fig_num,'axes')
%         axes(fig_num);
%     else
%         figure(fig_num); % open specific figure
%     end
% end
% hold on % allow multiple plot calls

%% Start of main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%See: http://patorjk.com/software/taag/#p=display&f=Big&t=Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§

% Calculate the rectangle vertices
vertices = [
    -vehicleParametersStruct.Lr,-(vehicleParametersStruct.w_vehicle/2),vehiclePosition(1,1); %bottom left
     -vehicleParametersStruct.Lr,(vehicleParametersStruct.w_vehicle/2),vehiclePosition(1,1); %top left
     vehicleParametersStruct.Lf,(vehicleParametersStruct.w_vehicle/2),vehiclePosition(1,1); %top right
     vehicleParametersStruct.Lf,-(vehicleParametersStruct.w_vehicle/2),vehiclePosition(1,1); %bottom right
     -vehicleParametersStruct.Lr,-(vehicleParametersStruct.w_vehicle/2),vehiclePosition(1,1)%bottom left
    ];

% Connect the vertices to form the rectangle edges
edges = [
    1, 2;
    2, 3;
    3, 4;
    4, 5;
    5, 1;
    ];

% Yaw angle
theta = vehiclePosition(1,4);

% Create the rotation matrix
R = [cos(theta) -sin(theta),0; sin(theta) cos(theta),0;0,0,1];

% Rotate the translated rectangle
rotated_translated_rect = (R * vertices')';

% Translate the rotated rectangle to current location
rotated_rectangle = rotated_translated_rect + [vehiclePosition(1,2) vehiclePosition(1,3) 0];

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

    % temp_h = figure(fig_num);
    % flag_rescale_axis = 0;
    % if isempty(get(temp_h,'Children'))
    %     flag_rescale_axis = 1;
    % end
    
    figure(figNum); % open specific figure
    hold on

    plot3(rotated_rectangle(edges(:,1), 1), rotated_rectangle(edges(:,1), 2),rotated_rectangle(edges(:,1), 3), plot_style, 'LineWidth', 2);


    %plot3(rotated_rect(edges(:,2),1), rotated_rect(edges(:,2),2), rotated_rect(edges(:,2),3), 'r', 'LineWidth', 2);


     % % Make axis slightly larger?
    % if flag_rescale_axis
    %     temp = axis;
    %     axis_range_x = temp(2)-temp(1);
    %     axis_range_y = temp(4)-temp(3);
    %     percent_larger = 0.1;
    %     axis([temp(1)-percent_larger*axis_range_x, temp(2)+percent_larger*axis_range_x,  temp(3)-percent_larger*axis_range_y, temp(4)+percent_larger*axis_range_y]);
    % end


end % Ends the flag_do_plot if statement

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end


end % Ends the function

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
