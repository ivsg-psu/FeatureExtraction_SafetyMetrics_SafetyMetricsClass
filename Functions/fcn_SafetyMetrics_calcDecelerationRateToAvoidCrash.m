function DRAC = fcn_SafetyMetrics_calcDecelerationRateToAvoidCrash(unitVectors_vehicleTraj, vehicleTraj, rearAxle, TimeToCollision_time, object, flagObject, varargin)
%% fcn_SafetyMetrics_calcDecelerationRateToAvoidCrash
%
% This function computes the Deceleration Rate to Avoid a Crash (DRAC) for a
% moving vehicle relative to an obstacle represented as a triangulated
% surface (patch). At each trajectory sample, the function casts a ray from
% the vehicle (e.g., rear axle center) in the direction of motion and finds
% the intersection point with the obstacle mesh using ray–triangle
% intersection. Using the provided time-to-collision (TTC) signal and a
% closing-speed estimate implied by the intersection geometry, the function
% computes a DRAC time history, where larger DRAC values indicate that more
% aggressive braking would be required to avoid impact.
%
%
% FORMAT:
%
%  DRAC = fcn_SafetyMetrics_calcDecelerationRateToAvoidCrash(unitVectors_vehicleTraj, vehicleTraj, rearAxle, TimeToCollision_time, object, flagObject, (figNum))
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
%     TimeToCollision_time: a N x 1 matrix contaning TTC time
% 
%     objectPatch : 1x1 stuct with Vertices, Faces, FacesVertexCData,
%     Facecolor, Edgecolor, LineWidth fo the object
% 
%     flagObject: Flag to check if an object exists
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
%   DRAC: 1 x N matrix contaning deceleration rate to avoid crash data
%
% DEPENDENCIES:
%
% fcn_DebugTools_checkInputsToFunctions
% TriangleRayIntersection.m
%
% This function was written on 2023_08_10 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu


% REVISION HISTORY:
%
% 2023_08_10 by Marcus Putz
% - first write of function
% 
% 2026_02_18 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_calcDecelerationRateToAvoidCrash
%   % * Renamed "fcn_SafetyMetrics_DRAC" to fcn_SafetyMetrics_calcDecelerationRateToAvoidCrash
%   % * Added DebugTools to check the inputs
%   % * Updated the function and variable names to match the latest format


% TO DO:
%
% 2026_02_18 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_calcDecelerationRateToAvoidCrash
%   % * Preallocate outputs and always fill with NaN by default
%   %   % * Set DRAC = NaN(N,1); upfront (where N = size(trajectory,1)).
%   % * Ensure TTC and DRAC are consistent-length vectors (N×1) and aligned by index.
%   %   % * Validate size(TTC,1) == N 
%   % * Use correct ray origin and allow selecting the origin point.
%   %   % * Add an optional setting to choose ray origin:
%   %   %   % * rear axle / CG / front axle / vehicle boundary vertices.
%   % * Robustly handle edge cases to prevent Inf/NaN explosions.
%   %   % * If no intersection: DRAC(i)=NaN.
%   %   % * If TTC(i)<=0: DRAC(i)=NaN (or Inf) and flag as invalid.
%   %   % * If distance_to_hit <= 0: ignore/NaN.
%   %   % * Guard against divide-by-zero in both TTC and distance/time terms.
%   % * Return richer outputs (not just DRAC).
%   %   % * Return a struct with:
%   %   %   % * DRAC (N×1)
%   %   %   % * did_intersect (N×1 logical)
%   %   %   % * intersection_points (N×3, NaN rows if no hit)
%   %   %   % * distance_to_hit (N×1)
%   %   %   % * closing_speed (N×1)
%   %   %   % * event indices/timestamps (e.g., DRAC > threshold, TTC < threshold)
%   % * Need a test script with multiple scenarios


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 7; % The largest Number of argument inputs to the function
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
        narginchk(6,MAX_NARGIN);

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
for i = 1:length(unitVectors_vehicleTraj)
    % Use the unit vector to determine the direction of the ray 
    dir = [unitVectors_vehicleTraj(i,2),unitVectors_vehicleTraj(i,3),unitVectors_vehicleTraj(i,1)];
    % The orgin of the ray. Middle of the rear axel
    pos = [rearAxle(i,1),rearAxle(i,2),vehicleTraj(i,1)];
    
    %Combine the vertices and the faces for use in the
    %'TriangleRayIntersection' function
    vert1_ob = object.Vertices(object.Faces(:,1),:);
    vert2_ob = object.Vertices(object.Faces(:,2),:);
    vert3_ob = object.Vertices(object.Faces(:,3),:);
    
    %Use 'TriangleRayIntersection' to determine if there is an intersection
    %between the mesh and the ray. 
    [~, ~, ~, ~, xcoor_ob] = TriangleRayIntersection(pos,dir, vert1_ob, vert2_ob, vert3_ob,'planeType','one sided');
    % Delete the rows that don't have any data
    xcoor_ob = rmmissing(xcoor_ob);
    if isempty(xcoor_ob) == 0
        % Collect the points that contain the data
        xcoor_1(i,:) = xcoor_ob;
        %dis_1(i,:)  = dis_ob(find(intersect_ob));
        
        % Plot the data by creating a line from center of rear axel to
        % intersection point
        figure(7182);
        plot3([vehicleTraj(i,2) xcoor_ob(1)],[vehicleTraj(i,3) xcoor_ob(2)],[vehicleTraj(i,1) xcoor_ob(3)])
        hold on
    end
end
%figure(675)




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

    if flagObject
        slope_V = (xcoor_1(:,3)-vehicleTraj(1:length(xcoor_1),1))./(xcoor_1(:,1)-vehicleTraj(1:length(xcoor_1),2));
        DRAC = slope_V./TimeToCollision_time;
        figure(figNum)
        plot(DRAC, LineWidth=1.5);
        title('Deceleration Rate to Avoid Crash (DRAC)');
        grid on
        xlabel('Timestep(s)');
        ylabel('DRAC(m/s^{2)}');
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


