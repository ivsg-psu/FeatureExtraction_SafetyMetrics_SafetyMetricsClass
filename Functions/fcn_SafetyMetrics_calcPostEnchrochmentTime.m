function PET_time =fcn_SafetyMetrics_calcPostEnchrochmentTime(car1SweptPatch, vehicleParametersStruct, varargin)
%% fcn_SafetyMetrics_PostEnchrochmentTime
% 
% This function creates a second vehicle trajectory (car2) and, at each
% timestep, casts a vertical ray along the negative time axis (−z) from the
% car2 rear-axle position at the current time. It computes intersections
% between these rays and the previous vehicle’s swept 3D patch
% (carPatch_previous) using TriangleRayIntersection. The Post-Encroachment
% Time (PET) is then calculated as the difference between the current car2
% time and the intersection time (z-coordinate) on the previous vehicle’s
% swept patch: PET(i) = t_car2(i) − t_intersection(i).
% 
%
% FORMAT:
%
% PET_time =fcn_SafetyMetrics_PostEnchrochmentTime(car1SweptPatch, vehicleParametersStruct, (figNum))
%
% INPUTS:
%
%    carPatch_previous: 1x1 stuct contaning the Vertices, Faces, FaceVertexCData,
%    FaceColor, EdgeColor, and LineWidth of the previosu vehicle.
% 
%    vehicleParametersStruct: sturcture containing
%       a: distance from origin to front axle (positive)
%       b: distance from origin to rear axle (positive)
%       Lf:Length from origin to front bumper
%       Lr:Length from origin to rear bumper
%       w_tire_tire: width from center of tire to center of tire
%       w_vehicle:width form outermost left side to outermost right side
%       tire_width: width of one tire
%       tire_length: diameter of one tire
%
%
% OUTPUTS:
%
%   PET_time : 1xn matrix of the Post-enchroachtment Time.
%
% DEPENDENCIES:
%
%
% TriangleRayIntersection.m
% fcn_SafetyMetrics_unit_vector
%
% This function was written on 2023_08_11 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu

%
% REVISION HISTORY:
%
% 2023_08_11 by Marcus Putz
% - first write of function
% 2026_02_18 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_TimeToLaneCollision
%   % * Renamed "fcn_SafetyMetrics_PET" to fcn_SafetyMetrics_PostEnchrochmentTime
%   % * Updated the function and variable names to match the latest format

% TO-DO:
%
% 2026_02_18 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_PostEnchrochmentTime
%   % * Remove hard-coded car2 trajectory generation and define a clear API
%   %   % * Delete the flag_car2 block and require car2_traj as an input.
%   % * Move all plots to debug section
%   % * Preallocate arrays
%   %   % * Preallocate xcoor_car1_points = NaN(N,3);
%   %   % * Avoid growing arrays in loops.
%   % * Handle “no intersection” correctly
%   %   % * Keep NaNs for intersection time.
%   %   % * Define how PET should behave: NaN vs Inf vs large number.
%   % * Use correct ray origin points
%   %   % * Right now you use rear_axle2. For generality, allow choosing ray origin:
%   %   % * rear axle / CG / front axle / polygon vertices
%   %   %   % across vehicle footprint.
%   % * Return richer outputs (not just PET_time)
%   %   % * Return struct with:
%   %   %   % * PET_time
%   %   %   % * intersection_points
%   %   %   % * intersection_time
%   %   %   % * did_intersect flags
%   %   %   % * indices/timestamps of events


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
        narginchk(2,MAX_NARGIN);
        

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

flag_car2 =1;
if flag_car2 == 1
    car2_x =1:1:500;
    car2_y = zeros(1,500)+3.657;
    car2_t = 500:1:999;
    car2_yaw = zeros(1,500)';
    
    car2_traj = [car2_t',flip(car2_x'),car2_y',car2_yaw];
    % Find the unit vector for this second vehicle
    [u2,rear_axle2]=fcn_SafetyMetrics_unit_vector(car2_traj,vehicleParametersStruct,36363);
    
    % Go through the same procedure to use 'TriangleRayIntersection'
    for i = 1:length(u2)
        dir = [0,0,-1];
        pos = [rear_axle2(i,1),rear_axle2(i,2),car2_traj(i,1)];
        
        vert1_car1 = car1SweptPatch.Vertices(car1SweptPatch.Faces(:,1),:);
        vert2_car1 = car1SweptPatch.Vertices(car1SweptPatch.Faces(:,2),:);
        vert3_car1 = car1SweptPatch.Vertices(car1SweptPatch.Faces(:,3),:);
        
        [~, ~, ~, ~, xcoor_car1] = TriangleRayIntersection(pos,dir, vert1_car1, vert2_car1, vert3_car1,'planeType','one sided');
        xcoor_car1 = rmmissing(xcoor_car1);
        if isempty(xcoor_car1) == 0
            xcoor_car1_points(i,:) = xcoor_car1;
            %dis_lane1{i_1,:}(i,:)  = dis_lane(find(intersect_lane));
        else
            xcoor_car1_points(i,:) = [NaN,NaN,NaN];
        end
    end
    figure(36363)
    for i = 1:length(xcoor_car1_points)
        %if xcoor_car1_points(i,1) ~=0
            plot3([car2_traj(i,2) xcoor_car1_points(i,1)],[car2_traj(i,3) xcoor_car1_points(i,2)],[car2_traj(i,1) xcoor_car1_points(i,3)],'b')
            hold on
        %end
        %     plot3(trajectory(j,2),trajectory(j,3),trajectory(j,1),'ro')
    end
    % Plot first car 3d mesh
    patch(car1SweptPatch)
    set(gca,'DataAspectRatio',[10 1 50])
    view(-40,40);
    % Calculate the PET use the thesis definition proving that PET is just
    % the height between the intersection point and the orgin of the ray
    PET_time = car2_traj(:,1)- xcoor_car1_points(:,3);

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

    % temp_h = figure(fig_num);
    % flag_rescale_axis = 0;
    % if isempty(get(temp_h,'Children'))
    %     flag_rescale_axis = 1;
    % end

    % Plot PET vs time
    figure(figNum)
    plot(PET_time, LineWidth=1.5)
    title('Post-encroachment Time (PET)')
    grid on
    xlabel('Timestep(s)');
    ylabel('PET(s)');
    box on

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

