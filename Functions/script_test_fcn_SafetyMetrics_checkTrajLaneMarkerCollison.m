
%% script_test_fcn_SafetyMetrics_checkTrajLaneMarkerCollison
% Exercises the function: fcn_SafetyMetrics_checkTrajLaneMarkerCollison

% REVISION HISTORY:
%
% 2026_02_15 by Aneesh Batchu, abb6486@psu.edu
% - wrote the code originally

% TO-DO:
% 

%% Set up the workspace

close all

%% Code demos start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____                              ____   __    _____          _
%  |  __ \                            / __ \ / _|  / ____|        | |
%  | |  | | ___ _ __ ___   ___  ___  | |  | | |_  | |     ___   __| | ___
%  | |  | |/ _ \ '_ ` _ \ / _ \/ __| | |  | |  _| | |    / _ \ / _` |/ _ \
%  | |__| |  __/ | | | | | (_) \__ \ | |__| | |   | |___| (_) | (_| |  __/
%  |_____/ \___|_| |_| |_|\___/|___/  \____/|_|    \_____\___/ \__,_|\___|
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Demos%20Of%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEMO figures start with 1
close all;
fprintf(1,'Figure: 1XXXX: DEMO cases\n');

%% DEMO case: Check for a collision between a straight lane marker and a vehicle going in a straight path

figNum = 10001;
titleString = sprintf('DEMO case: Check for a collision between a straight lane marker and a vehicle going in a straight path');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Generate Trajectory
vehicleTrajString = 'straight'; 
laneMarkerString = 'lane A'; 
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

% Call the function
laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',15);

% Assertions
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct.lane_marker_pathXY(:,1)),length(laneMarkerPath(:,1))));
assert(~laneCollisionStruct.did_intersect)
assert(isempty(laneCollisionStruct.intersections_pathXY))
assert(isempty(laneCollisionStruct.intersection_traj_vector_index))

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% DEMO case: Check for a collision between a straight lane marker and a vehicle going in a slant path (one intersection)

figNum = 10002;
titleString = sprintf('DEMO case: Check for a collision between a straight lane marker and a vehicle going in a slant path');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Generate Trajectory
vehicleTrajString = 'slant'; 
laneMarkerString = 'lane A'; 
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

% Call the function
laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',15);

% Assertions
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct.lane_marker_pathXY(:,1)),length(laneMarkerPath(:,1))));
assert(laneCollisionStruct.did_intersect)
assert(~isempty(laneCollisionStruct.intersections_pathXY))
assert(~isempty(laneCollisionStruct.intersection_traj_vector_index))

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% DEMO case: Check for a collision between a straight lane marker and a vehicle going in a curvy path (No intersection) 

% Sine curve: (1.8 + 1.2*sin(2*pi*xTraj3/100)) + 0.4 - Minimum distance
% from the trajectry to the lane marker path would be one

figNum = 10003;
titleString = sprintf('DEMO case: Check for a collision between a straight lane marker and a vehicle going in a curvy path');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Generate Trajectory
vehicleTrajString = 'curve'; 
laneMarkerString = 'lane A'; 
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

% Call the function
laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',10);

% Assertions
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct.lane_marker_pathXY(:,1)),length(laneMarkerPath(:,1))));
assert(~laneCollisionStruct.did_intersect)
assert(isempty(laneCollisionStruct.intersections_pathXY))
assert(isempty(laneCollisionStruct.intersection_traj_vector_index))

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% DEMO case: Check for a collision between a straight lane marker and a vehicle going in a more curvy path - crosses zero many times

figNum = 10004;
titleString = sprintf('DEMO case: Check for a collision between a straight lane marker and a vehicle going in a more curvy path - crosses zero many times');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Generate Trajectory
vehicleTrajString = 'manycurves'; 
laneMarkerString = 'lane A'; 
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

% Call the function
laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',10);

% Assertions
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct.lane_marker_pathXY(:,1)),length(laneMarkerPath(:,1))));
assert(laneCollisionStruct.did_intersect)
assert(~isempty(laneCollisionStruct.intersections_pathXY))
assert(~isempty(laneCollisionStruct.intersection_traj_vector_index))
assert(isequal(length(laneCollisionStruct.intersection_traj_vector_index(:,1)), length(laneCollisionStruct.intersections_pathXY(:,1))))

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% DEMO case: Check for a collision between multiple lane marker and a vehicle going in a straight path 

figNum = 10005;
titleString = sprintf('DEMO case: Check for a collision between multiple lane marker and a vehicle going in a straight path ');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Generate Trajectory
vehicleTrajString = 'straight'; 
laneMarkerString = 'lane ABC'; 
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

% Call the function
laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',10);

% Assertions 
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct),3))

% Assertions - Lane marker A
assert(length(laneCollisionStruct(1).lane_marker_pathXY(:,1)) < length(laneMarkerPath(:,1)));
assert(~laneCollisionStruct(1).did_intersect)
assert(isempty(laneCollisionStruct(1).intersections_pathXY))
assert(isempty(laneCollisionStruct(1).intersection_traj_vector_index))


% Assertions - Lane marker B
assert(length(laneCollisionStruct(2).lane_marker_pathXY(:,1)) < length(laneMarkerPath(:,1)));
assert(~laneCollisionStruct(2).did_intersect)
assert(isempty(laneCollisionStruct(2).intersections_pathXY))
assert(isempty(laneCollisionStruct(2).intersection_traj_vector_index))

% Assertions - Lane marker C
assert(length(laneCollisionStruct(3).lane_marker_pathXY(:,1)) < length(laneMarkerPath(:,1)));
assert(laneCollisionStruct(3).did_intersect)
assert(~isempty(laneCollisionStruct(3).intersections_pathXY))
assert(~isempty(laneCollisionStruct(3).intersection_traj_vector_index))
assert(isequal(length(laneCollisionStruct(3).intersection_traj_vector_index(:,1)), length(laneCollisionStruct(3).intersections_pathXY(:,1))))

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


%% Test cases start here. These are very simple, usually trivial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _______ ______  _____ _______ _____
% |__   __|  ____|/ ____|__   __/ ____|
%    | |  | |__  | (___    | | | (___
%    | |  |  __|  \___ \   | |  \___ \
%    | |  | |____ ____) |  | |  ____) |
%    |_|  |______|_____/   |_| |_____/
%
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST figures start with 2

close all;
fprintf(1,'Figure: 2XXXXXX: TEST mode cases\n');

%% TEST case: Check for a collision between curvy lane marker and a vehicle going in a more curvy path

figNum = 20001;
titleString = sprintf('TEST case: Check for a collision between curvy lane marker and a vehicle going in a more curvy path');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Generate Trajectory
vehicleTrajString = 'manycurves'; 
laneMarkerString = 'lane C'; 
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

% Call the function
laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',10);

% Assertions
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct.lane_marker_pathXY(:,1)),length(laneMarkerPath(:,1))));
assert(laneCollisionStruct.did_intersect)
assert(~isempty(laneCollisionStruct.intersections_pathXY))
assert(~isempty(laneCollisionStruct.intersection_traj_vector_index))
assert(isequal(length(laneCollisionStruct.intersection_traj_vector_index(:,1)), length(laneCollisionStruct.intersections_pathXY(:,1))))

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


%% TEST case: Check for a collision between multiple lane markers and a vehicle going in a more curvy path

figNum = 20002;
titleString = sprintf('TEST case: Check for a collision between curvy lane marker and a vehicle going in a more curvy path');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Generate Trajectory
vehicleTrajString = 'manycurves'; 
laneMarkerString = 'lane ABC'; 
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

% Call the function
laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',10);

% Assertions 
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct),3))

% Assertions - Lane marker A
assert(length(laneCollisionStruct(1).lane_marker_pathXY(:,1)) < length(laneMarkerPath(:,1)));
assert(laneCollisionStruct(1).did_intersect)
assert(~isempty(laneCollisionStruct(1).intersections_pathXY))
assert(~isempty(laneCollisionStruct(1).intersection_traj_vector_index))
assert(isequal(length(laneCollisionStruct(1).intersection_traj_vector_index(:,1)), length(laneCollisionStruct(1).intersections_pathXY(:,1))))

% Assertions - Lane marker B
assert(length(laneCollisionStruct(2).lane_marker_pathXY(:,1)) < length(laneMarkerPath(:,1)));
assert(~laneCollisionStruct(2).did_intersect)
assert(isempty(laneCollisionStruct(2).intersections_pathXY))
assert(isempty(laneCollisionStruct(2).intersection_traj_vector_index));

% Assertions - Lane marker C
assert(length(laneCollisionStruct(3).lane_marker_pathXY(:,1)) < length(laneMarkerPath(:,1)));
assert(laneCollisionStruct(3).did_intersect)
assert(~isempty(laneCollisionStruct(3).intersections_pathXY))
assert(~isempty(laneCollisionStruct(3).intersection_traj_vector_index))
assert(isequal(length(laneCollisionStruct(3).intersection_traj_vector_index(:,1)), length(laneCollisionStruct(3).intersections_pathXY(:,1))))

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% TEST case: Check for a collision between multiple lane markers and a vehicle going in a slant path

figNum = 20003;
titleString = sprintf('TEST case: Check for a collision between curvy lane marker and a vehicle going in a more curvy path');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Generate Trajectory
vehicleTrajString = 'slant'; 
laneMarkerString = 'lane ABC'; 
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

% Call the function
laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',10);

% Assertions 
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct),3))

% Assertions - Lane marker A
assert(length(laneCollisionStruct(1).lane_marker_pathXY(:,1)) < length(laneMarkerPath(:,1)));
assert(laneCollisionStruct(1).did_intersect)
assert(~isempty(laneCollisionStruct(1).intersections_pathXY))
assert(~isempty(laneCollisionStruct(1).intersection_traj_vector_index))
assert(isequal(length(laneCollisionStruct(1).intersection_traj_vector_index(:,1)), length(laneCollisionStruct(1).intersections_pathXY(:,1))))

% Assertions - Lane marker B
assert(length(laneCollisionStruct(2).lane_marker_pathXY(:,1)) < length(laneMarkerPath(:,1)));
assert(laneCollisionStruct(2).did_intersect)
assert(~isempty(laneCollisionStruct(2).intersections_pathXY))
assert(~isempty(laneCollisionStruct(2).intersection_traj_vector_index))
assert(isequal(length(laneCollisionStruct(2).intersection_traj_vector_index(:,1)), length(laneCollisionStruct(2).intersections_pathXY(:,1))))

% Assertions - Lane marker C
assert(length(laneCollisionStruct(3).lane_marker_pathXY(:,1)) < length(laneMarkerPath(:,1)));
assert(laneCollisionStruct(3).did_intersect)
assert(~isempty(laneCollisionStruct(3).intersections_pathXY))
assert(~isempty(laneCollisionStruct(3).intersection_traj_vector_index))
assert(isequal(length(laneCollisionStruct(3).intersection_traj_vector_index(:,1)), length(laneCollisionStruct(3).intersections_pathXY(:,1))))

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));



%% Fast Mode Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ______        _     __  __           _        _______        _
% |  ____|      | |   |  \/  |         | |      |__   __|      | |
% | |__ __ _ ___| |_  | \  / | ___   __| | ___     | | ___  ___| |_ ___
% |  __/ _` / __| __| | |\/| |/ _ \ / _` |/ _ \    | |/ _ \/ __| __/ __|
% | | | (_| \__ \ |_  | |  | | (_) | (_| |  __/    | |  __/\__ \ |_\__ \
% |_|  \__,_|___/\__| |_|  |_|\___/ \__,_|\___|    |_|\___||___/\__|___/
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Fast%20Mode%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FAST Mode figures start with 8

close all;
fprintf(1,'Figure: 8XXXXXX: TEST mode cases\n');

%% Basic example - NO FIGURE

figNum = 80001;
fprintf(1,'Figure: %.0f: FAST mode, empty figNum\n',figNum);
figure(figNum); close(figNum);

% Generate Trajectory
vehicleTrajString = 'straight'; 
laneMarkerString = 'lane A'; 
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

% Call the function
laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, ([]));

% Assertions
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct.lane_marker_pathXY(:,1)),length(laneMarkerPath(:,1))));
assert(~laneCollisionStruct.did_intersect)
assert(isempty(laneCollisionStruct.intersections_pathXY))
assert(isempty(laneCollisionStruct.intersection_traj_vector_index))


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% Basic fast mode - NO FIGURE, FAST MODE

figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, empty figNum\n',figNum);
figure(figNum); close(figNum);

% Generate Trajectory
vehicleTrajString = 'straight'; 
laneMarkerString = 'lane A'; 
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

% Call the function
laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (-1));

% Assertions
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct.lane_marker_pathXY(:,1)),length(laneMarkerPath(:,1))));
assert(~laneCollisionStruct.did_intersect)
assert(isempty(laneCollisionStruct.intersections_pathXY))
assert(isempty(laneCollisionStruct.intersection_traj_vector_index))

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% Compare speeds of pre-calculation versus post-calculation versus a fast variant

figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum); close(figNum);

% Generate Trajectory
vehicleTrajString = 'straight';
laneMarkerString = 'lane A';
[vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

Niterations = 10;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations

    % Call the function
    laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, ([]));


end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;

for ith_test = 1:Niterations

    % Call the function
    laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (-1));


end
fast_method = toc;

% Plot results as bar chart
figure(373737);
clf;
hold on;

X = categorical({'Normal mode','Fast mode'});
X = reordercats(X,{'Normal mode','Fast mode'}); % Forces bars to appear in this exact order, not alphabetized
Y = [slow_method fast_method ]*1000/Niterations;
bar(X,Y)
ylabel('Execution time (Milliseconds)')

% Assertions
assert(isequal(class(laneCollisionStruct), 'struct'))
assert(isequal(length(laneCollisionStruct.lane_marker_pathXY(:,1)),length(laneMarkerPath(:,1))));
assert(~laneCollisionStruct.did_intersect)
assert(isempty(laneCollisionStruct.intersections_pathXY))
assert(isempty(laneCollisionStruct.intersection_traj_vector_index))


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% BUG cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ____  _    _  _____
% |  _ \| |  | |/ ____|
% | |_) | |  | | |  __    ___ __ _ ___  ___  ___
% |  _ <| |  | | | |_ |  / __/ _` / __|/ _ \/ __|
% | |_) | |__| | |__| | | (_| (_| \__ \  __/\__ \
% |____/ \____/ \_____|  \___\__,_|___/\___||___/
%
% See: http://patorjk.com/software/taag/#p=display&v=0&f=Big&t=BUG%20cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All bug case figures start with the number 9

% close all;
% fprintf(1,'Figure: 9XXXXXX: TEST mode cases\n');

%% BUG

%% Fail conditions
if 1==0

    %% Should throw an error as the vehicleTrajectoryPath should be a 2 or 4 column matrix

    figNum = 90001;
    fprintf(1,'Figure: %.0f:Bug case\n',figNum);
    figure(figNum); close(figNum);

    % Generate Trajectory
    vehicleTrajString = 'straight';
    laneMarkerString = 'lane A';
    [vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

    % Call the function
    laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath(:,1), laneMarkerPath, (figNum));

    % Assertions
    assert(isequal(class(laneCollisionStruct), 'struct'))
    assert(isequal(length(laneCollisionStruct.lane_marker_pathXY(:,1)),length(laneMarkerPath(:,1))));
    assert(~laneCollisionStruct.did_intersect)
    assert(isempty(laneCollisionStruct.intersections_pathXY))
    assert(isempty(laneCollisionStruct.intersection_traj_vector_index))


    % Make sure plot did NOT open up
    figHandles = get(groot, 'Children');
    assert(~any(figHandles==figNum));

    %% Should throw an error as the laneMarkerPath should be a 2 column matrix

    figNum = 90002;
    fprintf(1,'Figure: %.0f:Bug case\n',figNum);
    figure(figNum); close(figNum);

    % Generate Trajectory
    vehicleTrajString = 'straight';
    laneMarkerString = 'lane A';
    [vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString);

    % Call the function
    laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath(:,1), (figNum));

    % Assertions
    assert(isequal(class(laneCollisionStruct), 'struct'))
    assert(isequal(length(laneCollisionStruct.lane_marker_pathXY(:,1)),length(laneMarkerPath(:,1))));
    assert(~laneCollisionStruct.did_intersect)
    assert(isempty(laneCollisionStruct.intersections_pathXY))
    assert(isempty(laneCollisionStruct.intersection_traj_vector_index))


    % Make sure plot did NOT open up
    figHandles = get(groot, 'Children');
    assert(~any(figHandles==figNum));


end

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [vehicleTrajectoryPath, laneMarkerPath] = fcn_INTERNAL_generateTrajAndLaneMarkerPath(vehicleTrajString, laneMarkerString)

% Lane marker A (y = 0)
xLaneA = (0:1:100)';
yLaneA = zeros(size(xLaneA));

% Lane marker B (y = 3.6) -----
xLaneB = (0:1:100)';
yLaneB = 3.6*ones(size(xLaneB));

% Lane marker C (curved) -----
xLaneC = (0:1:100)';
yLaneC = 1.8 + 1.2*sin(2*pi*xLaneC/100);  % sinusoidal curve centered at y=1.8


switch lower(erase(vehicleTrajString, " "))

    case 'straight'

        % Simple straight trajectory
        xTraj1 = (0:1:100)';
        yTraj1 = 1.0*ones(size(xTraj1));
        vehicleTrajectoryPath = [xTraj1 yTraj1];

    case 'slant'

        % y=-2 at x=0, y=4 at x=100 (crosses y=0 once)
        xTraj2 = (0:1:100)';
        yTraj2 = -2 + 0.06*xTraj2;
        vehicleTrajectoryPath = [xTraj2 yTraj2];


    case 'curve'

        % Sinusoidal 
        xTraj3 = (0:1:100)';
        yLaneC = 1.8 + 1.2*sin(2*pi*xTraj3/100);
        yTraj3 = yLaneC + 0.4;   % offset by 0.4 m
        vehicleTrajectoryPath = [xTraj3 yTraj3];

    case 'manycurves'

        % Sinusoidal
        xTraj4 = (0:0.5:100)';              % more points
        yTraj4 = 0.8*sin(2*pi*xTraj4/25);      % crosses y=0 many times
        vehicleTrajectoryPath = [xTraj4 yTraj4];


    otherwise
        error('Trajectory does not exist')

end

switch lower(erase(laneMarkerString, " "))

    case 'lanea'

        laneMarkerPath = [xLaneA yLaneA];
 
    case 'laneb'
        
        laneMarkerPath = [xLaneB yLaneB];

    case 'lanec'

        laneMarkerPath = [xLaneC yLaneC];

    case 'laneab'

        laneMarkerPath = [
            [xLaneA yLaneA];
            [NaN NaN];
            [xLaneB yLaneB];
            ];

    case 'laneac'

        laneMarkerPath = [
            [xLaneA yLaneA];
            [NaN NaN];
            [xLaneC yLaneC]
            ];
    case 'lanebc'


        laneMarkerPath = [
            [xLaneB yLaneB];
            [NaN NaN];
            [xLaneC yLaneC]
            ];

    case 'laneabc'

        laneMarkerPath = [
            [xLaneA yLaneA];
            [NaN NaN];
            [xLaneB yLaneB];
            [NaN NaN];
            [xLaneC yLaneC]
            ];
    otherwise
        error('Lane marker does not exist')

end

% figure; hold on; grid on; axis equal;
% plot(laneMarkerCoord(:,1), laneMarkerCoord(:,2), 'k.-'); % NaNs will break lines
% 
% plot(traj1XY(:,1), traj1XY(:,2), 'b-', 'LineWidth', 2);
% % plot(traj2XY(:,1), traj2XY(:,2), 'r-', 'LineWidth', 2);
% % plot(traj3XY(:,1), traj3XY(:,2), 'g-', 'LineWidth', 2);
% % plot(traj4XY(:,1), traj4XY(:,2), 'm-', 'LineWidth', 2);
% 
% % legend('Lane markers', 'Traj1 parallel', 'Traj2 cross once', 'Traj3 wavy', 'Traj4');
% title('Synthetic Lane Markers and Test Trajectories');
% xlabel('X (m)'); ylabel('Y (m)');

end

  



