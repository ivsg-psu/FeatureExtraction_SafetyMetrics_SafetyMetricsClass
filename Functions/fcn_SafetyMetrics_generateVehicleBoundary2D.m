function vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, varargin)
%% fcn_SafetyMetrics_generateVehicleBoundary2D
% 
% This code will plot a vehicle boundary in 2D given the x,y,yaw, and
% vehicle parameters.
%
% FORMAT:
%
% vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, (figNum))
%
% INPUTS:
%
%     vehiclePosition: [x, y, yaw_angle] 1x3 vector
%
%     vehicleParametersStruct: sturcture containing
%       a: distance from origin to front axle (positive)
%       b: distance form origin to rear axle (positive)
%       Lf:Length from origin to front bumper
%       Lr:Length from origin to rear bumper
%       w_tire_tire: width from center of tire to center of tire
%       w_vehicle:width form outer most left side to outer most right side
%       tire_width: width of one tire
%       tire_length: diameter of one tire
% 
%      (OPTIONAL INPUTS)
%
%     figNum: a figure number to plot results. If set to -1, skips any
%     input checking or debugging, no figures will be generated, and sets
%     up code to maximize speed.
%
%
% OUTPUTS:
% 
%   vehicle_boundary: structure containing the 2D vehicle boundary geometry
%   evaluated at each pose in the input trajectory.
%
%     vehicle_boundary.boundingBox
%         N×5×2 array containing the vertices of the rectangular vehicle
%         boundary at each pose. For each ith_point = 1:N:
%
%             squeeze(vehicle_boundary.boundingBox(ith-point,:,:))  5×2 matrix
%
%         The 5 vertices define a closed polygon in the following order:
%             1. Rear Left
%             2. Rear Right
%             3. Front Right
%             4. Front Left
%             5. Rear Left (repeated to close the bouding box)
%
%         The third dimension stores:
%             (:,:,1) x-coordinates
%             (:,:,2) y-coordinates
%
%
%     vehicle_boundary.rearLeft
%         N×2 array containing the global [x y] trajectory of the rear-left
%         corner of the vehicle.
%
%     vehicle_boundary.rearRight
%         N×2 array containing the global [x y] trajectory of the rear-right
%         corner of the vehicle.
%
%     vehicle_boundary.frontRight
%         N×2 array containing the global [x y] trajectory of the front-right
%         corner of the vehicle.
%
%     vehicle_boundary.frontLeft
%         N×2 array containing the global [x y] trajectory of the front-left
%         corner of the vehicle.
%
%     vehicle_boundary.frontCenter
%         N×2 array containing the global [x y] trajectory of the center of
%         the front bumper (computed using Lf and vehicle heading).
%
% DEPENDENCIES:
%  
%     fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
% 
%       See the script:
%
%       script_test_fcn_SafetyMetrics_generateVehicleBoundary2D.m 
%
%       for a full test suite.
%
% This function was written on 2026_02_16 by Aneesh Batchu
% Questions or comments? contact abb6486@psu.edu or sbrennan@psu.edu

%
% REVISION HISTORY:
% 
% 2026_02_16 by Aneesh Batchu, abb6486@psu.edu
% - Wrote the code originally
%
% 2026_02_16 by Sean Brennan, sbrennan@psu.edu
% - In fcn_SafetyMetrics_generateVehicleBoundary2D
%   % * Removed dashed plotting style
%   % * Replaced OSM+2SHP flags with SAFETYMETRICS


% TO DO:
%
% - fill in to-do items here.

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 3; % The largest Number of argument inputs to the function
flag_max_speed = 0;
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
    flag_do_debug = 0; %     % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; %     % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG__FLAG_CHECK_INPUTS = getenv("MATLABFLAG_SAFETYMETRICS_FLAG_CHECK_INPUTS");
    MATLABFLAG__FLAG_DO_DEBUG = getenv("MATLABFLAG_SAFETYMETRICS_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG__FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG__FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG__FLAG_DO_DEBUG); 
        flag_check_inputs  = str2double(MATLABFLAG__FLAG_CHECK_INPUTS);
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

        % vehiclePosition should have 4 column of numbers
        fcn_DebugTools_checkInputsToFunctions(...
            vehicleTraj, '3column_of_numbers');

        % % vehicleParametersStruct is a structure
        % fcn_DebugTools_checkInputsToFunctions(...
        %     vehicleParametersStruct, 'likestructure');

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

% Get X, Y and Yaw angle of the vehicle trajectory 
xCoord_vehicle = vehicleTraj(:,1); 
yCoord_vehicle = vehicleTraj(:,2); 
psi_yawAngle = vehicleTraj(:,3);

% Assign the vehicle parameters
Lf_vehicle = vehicleParametersStruct.Lf; 
Lr_vehicle = vehicleParametersStruct.Lr;
w_vehicle = vehicleParametersStruct.w_vehicle;

% Length of the trajectory
N_trajPoints = length(xCoord_vehicle); 

% Predefine structure 
vehicle_boundary = struct( ...
    'boundingBox', zeros(N_trajPoints,5,2), ...
    'rearLeft',    zeros(N_trajPoints,2), ...
    'rearRight',   zeros(N_trajPoints,2), ...
    'frontRight',  zeros(N_trajPoints,2), ...
    'frontLeft',   zeros(N_trajPoints,2), ...
    'frontCenter', zeros(N_trajPoints,2), ...
    'CG', zeros(N_trajPoints,2));




% Vertices of vehicle bounding box
% Note: Vertex 1 and 5 are repeated to close the bounding box
bounding_box_localCoord = [-Lr_vehicle -w_vehicle/2;      % Rear left
           -Lr_vehicle  w_vehicle/2;                      % Rear right
            Lf_vehicle  w_vehicle/2;                      % Upper right
            Lf_vehicle -w_vehicle/2;                      % Upper left
           -Lr_vehicle -w_vehicle/2];                     % Rear left


% Seperate the X and Y vertices of the bounding box. Each bounding box
% contains five (5) X coordinates (vertices) and Y coordinates (vertices). 

% Simply: X and Y coordinates of the bounding box at each trajectory
% location in local coordinates
XCoord_boundingBox_local = repmat(bounding_box_localCoord(:,1)', N_trajPoints, 1);
YCoord_boundingBox_local = repmat(bounding_box_localCoord(:,2)', N_trajPoints, 1);

% cosine and sine of yaw angle
c = cos(psi_yawAngle); 
s = sin(psi_yawAngle);

% X and Y coordinates of the bounding box at each trajectory location in
% global coordinates
XCoord_boundingBox_global = (c.*XCoord_boundingBox_local - s.*YCoord_boundingBox_local) + xCoord_vehicle;
YCoord_boundingBox_global = (s.*XCoord_boundingBox_local + c.*YCoord_boundingBox_local) + yCoord_vehicle;

% Rotated vehicle bounding box
vehicle_boundary.boundingBox(:,:,1) = XCoord_boundingBox_global;
vehicle_boundary.boundingBox(:,:,2) = YCoord_boundingBox_global;

% Individual corner trajectories
vehicle_boundary.rearLeft   = [XCoord_boundingBox_global(:,1), YCoord_boundingBox_global(:,1)];
vehicle_boundary.rearRight  = [XCoord_boundingBox_global(:,2), YCoord_boundingBox_global(:,2)];
vehicle_boundary.frontRight = [XCoord_boundingBox_global(:,3), YCoord_boundingBox_global(:,3)];
vehicle_boundary.frontLeft  = [XCoord_boundingBox_global(:,4), YCoord_boundingBox_global(:,4)];

% Front center 
vehicle_boundary.frontCenter = [xCoord_vehicle + Lf_vehicle*cos(psi_yawAngle), yCoord_vehicle + Lf_vehicle*sin(psi_yawAngle)];


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

    temp_h = figure(figNum);
    flag_rescale_axis = 0;
    if isempty(get(temp_h,'Children'))
        flag_rescale_axis = 1;
    end

    figure(figNum); % open specific figure
    hold on
    axis equal; 
    grid on;

    % Plot the vehicle trajectory
    plot(xCoord_vehicle, yCoord_vehicle,'k-','LineWidth',5, ...
        'DisplayName','Vehicle Trajectory');


    colors.rearLeft    = [0 0.2 0.8];      % dark blue
    colors.rearRight   = [0 0.6 0.8];      % cyan-blue
    colors.frontRight  = [0.85 0.1 0.1];   % red
    colors.frontLeft   = [0.85 0.1 0.6];   % magenta-red
    colors.frontCenter = [0 0.9 0];        % green
    colors.boxColor = [0.7 0.7 0.7];       % gray
    colors.cgColor = [0.8 0 0.8];


    % Bounding boxes 
    Nboxes = size(vehicle_boundary.boundingBox,1);
    for ith_boundingBox = 1:Nboxes

        % Vertices of a bounding box
        V = squeeze(vehicle_boundary.boundingBox(ith_boundingBox,:,:)); % 5x2

        if ith_boundingBox == 1
            plot(V(:,1), V(:,2), '-', 'LineWidth',1.5, ...
                'Color', colors.boxColor, ...
                'DisplayName','Bounding Box');
        else
            plot(V(:,1), V(:,2), '-', 'LineWidth',1.5, ...
                'Color', colors.boxColor, ...
                'HandleVisibility','off'); % prevents repeated legend entries
        end

        % CG location
        xCG = xCoord_vehicle(ith_boundingBox,1);
        yCG = yCoord_vehicle(ith_boundingBox,1);

        % Front center location
        xFront = vehicle_boundary.frontCenter(ith_boundingBox,1);
        yFront = vehicle_boundary.frontCenter(ith_boundingBox,2);

        % Direction vector
        dx = xFront - xCG;
        dy = yFront - yCG;

        % Draw arrow
        quiver(xCG, yCG, dx, dy, ...
            0, ...                     % No scaling
            'Color', [0 0.3 0], ...     % dark green
            'LineWidth',0.5, ...
            'MaxHeadSize',0.6, ...
            'HandleVisibility','off');
    end


    plot(vehicle_boundary.rearLeft(:,1), ...
        vehicle_boundary.rearLeft(:,2), ...
        'LineStyle','-', ...
        'Color', colors.rearLeft, ...
        'LineWidth',3, ...
        'DisplayName','Rear Left');

    plot(vehicle_boundary.rearRight(:,1), ...
        vehicle_boundary.rearRight(:,2), ...
        'LineStyle','-', ...
        'Color', colors.rearRight, ...
        'LineWidth',3, ...
        'DisplayName','Rear Right');

    plot(vehicle_boundary.frontRight(:,1), ...
        vehicle_boundary.frontRight(:,2), ...
        'LineStyle','-', ...
        'Color', colors.frontRight, ...
        'LineWidth',2, ...
        'DisplayName','Front Right');

    plot(vehicle_boundary.frontLeft(:,1), ...
        vehicle_boundary.frontLeft(:,2), ...
        'LineStyle','-', ...
        'Color', colors.frontLeft, ...
        'LineWidth',2, ...
        'DisplayName','Front Left');

    plot(vehicle_boundary.frontCenter(:,1), ...
        vehicle_boundary.frontCenter(:,2), ...
        '.', ...
        'Color', colors.frontCenter, ...
        'MarkerSize',12, ...
        'DisplayName','Front Center');

    % Legend ON
    legend('show','Location','best');

    % Make axis slightly larger?
    if flag_rescale_axis
        temp = axis;
        axis_range_x = temp(2)-temp(1);
        axis_range_y = temp(4)-temp(3);
        percent_larger = 0.1;
        axis([temp(1)-percent_larger*axis_range_x, temp(2)+percent_larger*axis_range_x,  temp(3)-percent_larger*axis_range_y, temp(4)+percent_larger*axis_range_y]);
    end


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
