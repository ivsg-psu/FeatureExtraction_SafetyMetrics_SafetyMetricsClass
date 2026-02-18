function TTC_time = fcn_SafetyMetrics_calcTimeToCollision(unitVectors_vehicleTraj, vehicleTraj, rearAxle, objectPatch, varargin)
%% fcn_SafetyMetrics_TimeToCollision
% 
% This function computes a time-to-collision (TTC) signal between a moving
% vehicle and an obstacle represented as a triangulated surface (patch) by
% performing ray–triangle intersection at each trajectory sample.
%
% FORMAT:
%
% TTC_time = fcn_SafetyMetrics_TimeToCollision(unitVectors_vehicleTraj, vehicleTraj, rearAxle, objectPatch, (figNum))
%
% INPUTS:
%
%     unitVectors_vehicleTraj: a matrix with the unit vectors of the
%     vehicle trajectory. [time,x,y]
% 
%     vehicleTraj: [time,x,y,yaw_angle] 4x1 vector
% 
%     rearAxle: a matrix containing the points of where the center of the
%     rear axle is. [x,y]
% 
%     objectPatch : 1x1 stuct with Vertices, Faces, FacesVertexCData,
%     Facecolor, Edgecolor, LineWidth fo the object
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
%   TTC_time: a N x 1 matrix contaning TTC time
%
% DEPENDENCIES:
%
% fcn_DebugTools_checkInputsToFunctions
% TriangleRayIntersection.m
%
% This function was written on 2023_08_10 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu
%
% REVISION HISTORY:
%
% 2023_08_11 by Marcus Putz
% - first write of function
% 
% 2026_02_17 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_TimeToCollision
%   % * Renamed "fcn_SafetyMetrics_TTC" to fcn_SafetyMetrics_TimeToCollision
%   % * Added DebugTools to check the inputs
%   % * Updated the function and variable names to match the latest format


%
% TO DO:
%
% 2026_02_17 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_TimeToCollision
%   % * Preallocate outputs and always fill with NaN by default
%   %   % * Set TTC_time = NaN(N,1); upfront (where N = size(vehicleTraj,1)).
%   % * Avoid growing xcoor_1 dynamically and avoid “missing rows” changing length.
%   % * Use correct ray origin points
%   %   % * Right now you use rear_axle2. For generality, allow choosing ray origin:
%   %   % * rear axle / CG / front axle / polygon vertices 
%   %   %   % across vehicle footprint.
%   % * Return richer outputs (not just TTC_time)
%   %   % * Return struct with:
%   %   %   % * TTC_time (N×1, NaN if no hit)
%   %   %   % * did_intersect flags (N×1 logical)
%   %   %   % * intersection_points (N×2, NaN row if no hit)
%   %   %   % * intersection_time (N×1)
%   %   %   % * event indices (indices of key events; e.g., hit exists, TTC<threshold)
%   %   %   % * event timestamps (timestamps: (time column) vehicleTraj(event_indices,1))
%   % * Need a test script

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 5; % The largest Number of argument inputs to the function
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

if 0 == flag_max_speed
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(4,MAX_NARGIN);

        % unitVectors_vehicleTraj should have 3 column of numbers
        fcn_DebugTools_checkInputsToFunctions(...
            unitVectors_vehicleTraj, '3column_of_numbers');


        % vehicleTraj should have 4 column of numbers
        fcn_DebugTools_checkInputsToFunctions(...
            vehicleTraj, '4column_of_numbers');


        % rearAxle should have 2 column of numbers
        fcn_DebugTools_checkInputsToFunctions(...
            rearAxle, '2column_of_numbers');
        

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ith_step = 1:length(unitVectors_vehicleTraj(:,1))

    % Use the unit vector to determine the direction of the ray 
    dir = [unitVectors_vehicleTraj(ith_step,2),unitVectors_vehicleTraj(ith_step,3),unitVectors_vehicleTraj(ith_step,1)];
    
    % The orgin of the ray. Middle of the rear axel
    pos = [rearAxle(ith_step,1),rearAxle(ith_step,2),vehicleTraj(ith_step,1)];
    
    %Combine the vertices and the faces for use in the
    %'TriangleRayIntersection' function
    vert1_ob = objectPatch.Vertices(objectPatch.Faces(:,1),:);
    vert2_ob = objectPatch.Vertices(objectPatch.Faces(:,2),:);
    vert3_ob = objectPatch.Vertices(objectPatch.Faces(:,3),:);
    
    %Use 'TriangleRayIntersection' to determine if there is an intersection
    %between the mesh and the ray. 
    [~, ~, ~, ~, xcoor_ob] = TriangleRayIntersection(pos, dir, vert1_ob, vert2_ob, vert3_ob, 'planeType', 'one sided');

    % Delete the rows that don't have any data
    xcoor_ob = rmmissing(xcoor_ob);

    if isempty(xcoor_ob) == 0
        % Collect the points that contain the data
        xcoor_1(ith_step,:) = xcoor_ob;
        %dis_1(i,:)  = dis_ob(find(intersect_ob));

        % Plot the data by creating a line from center of rear axel to
        % intersection point
        % plot3([vehicleTraj(ith_vector,2) xcoor_ob(1)],[vehicleTraj(ith_vector,3) xcoor_ob(2)],[vehicleTraj(ith_vector,1) xcoor_ob(3)])
        hold on
    end
end


TTC_time = xcoor_1(:,3) - vehicleTraj(1:length(xcoor_1),1);

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

    figure(figNum)

    subplot(2,1,1)
    hold on
    grid on
    box on

    for j = 1:length(xcoor_1)

        plot3([vehicleTraj(j,2) xcoor_1(j,1)],[vehicleTraj(j,3) xcoor_1(j,2)],[vehicleTraj(j,1) xcoor_1(j,3)]) 
       %     plot3(vehicleTraj(j,2),vehicleTraj(j,3),vehicleTraj(j,1),'ro')
    end

    %Add in object to ray plot while scaling the axes
    patch(objectPatch)

    % set(gca,'DataAspectRatio',[.5 .01 50])
    view(3)


    
    % Plot the TTC result vs time
    subplot(2,1,2)

    grid on
    box on

    plot(TTC_time, 'b-', 'LineWidth',1.5)
    title('Time-To-Collision (TTC)');
    
    xlabel('Timestep(s)');
    ylabel('TTC(s)');
  

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

