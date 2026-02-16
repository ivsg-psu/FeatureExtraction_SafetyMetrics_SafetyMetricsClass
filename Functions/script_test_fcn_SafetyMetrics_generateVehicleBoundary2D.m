
%% script_test_fcn_SafetyMetrics_generateVehicleBoundary2D
% Exercises the function: fcn_SafetyMetrics_generateVehicleBoundary2D

% REVISION HISTORY:
%
% 2026_02_16 by Aneesh Batchu, abb6486@psu.edu
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

%% DEMO case: Straight line trajectory, yaw = 0

figNum = 10001;
titleString = sprintf('DEMO case: Straight line trajectory, yaw = 0');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

N = 30;
x = linspace(0,20,N)'; 
y = zeros(N,1);
yaw = zeros(N,1);

% Vehicle trajectory
vehicleTraj = [x y yaw];

% Call the function
vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',15);

% Assertions
assert(isequal(class(vehicle_boundary), 'struct'))
assert(isequal(size(vehicle_boundary.boundingBox), [N 5 2]));
assert(isequal(size(vehicle_boundary.rearLeft),   [N 2]));
assert(isequal(size(vehicle_boundary.rearRight),  [N 2]));
assert(isequal(size(vehicle_boundary.frontRight), [N 2]));
assert(isequal(size(vehicle_boundary.frontLeft),  [N 2]));
assert(isequal(size(vehicle_boundary.frontCenter),[N 2]));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% DEMO case: Straight line trajectory, yaw = pi/2

figNum = 10002;
titleString = sprintf('DEMO case: Straight line trajectory, yaw = pi/2');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

N = 30;
x = zeros(N,1);
y = linspace(0,20,N)';
yaw = (pi/2)*ones(N,1);

% Vehicle trajectory
vehicleTraj = [x y yaw];

% Call the function
vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',15);

% Assertions
assert(isequal(class(vehicle_boundary), 'struct'))
assert(isequal(size(vehicle_boundary.boundingBox), [N 5 2]));
assert(isequal(size(vehicle_boundary.rearLeft),   [N 2]));
assert(isequal(size(vehicle_boundary.rearRight),  [N 2]));
assert(isequal(size(vehicle_boundary.frontRight), [N 2]));
assert(isequal(size(vehicle_boundary.frontLeft),  [N 2]));
assert(isequal(size(vehicle_boundary.frontCenter),[N 2]));

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

%% TEST case: Bounding box around a simple sinusoidal trajectory

figNum = 20001;
titleString = sprintf('TEST case: Bounding box around a simple sinusoidal trajectory');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Vehicle parameters
vehicleParametersStruct.Lf = 1.5; % Length from origin to front bumper
vehicleParametersStruct.Lr = 1.2; % Length from origin to rear bumper
vehicleParametersStruct.w_vehicle = 1.8; % the width of the vehicle_param, [m]

% Simple trajectory: N x 3 [x y yaw]
N = 40;
x = linspace(0,20,N)';
y = 1.5*sin(0.25*x);
yaw = atan2([diff(y); y(end)-y(end-1)], [diff(x); x(end)-x(end-1)]); % approx heading

% Vehicle trajectory
vehicleTraj = [x y yaw];

% Call the function
vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',10);

% Assertions
assert(isequal(class(vehicle_boundary), 'struct'))
assert(isequal(size(vehicle_boundary.boundingBox), [N 5 2]));
assert(isequal(size(vehicle_boundary.rearLeft),   [N 2]));
assert(isequal(size(vehicle_boundary.rearRight),  [N 2]));
assert(isequal(size(vehicle_boundary.frontRight), [N 2]));
assert(isequal(size(vehicle_boundary.frontLeft),  [N 2]));
assert(isequal(size(vehicle_boundary.frontCenter),[N 2]));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


%% TEST case: More Curved path (sinusoid)

figNum = 20002;
titleString = sprintf('TEST case: More Curved path (sinusoid)');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

N = 80;
x = linspace(0,30,N)';
y = 2*sin(0.3*x);
yaw = atan2([diff(y); y(end)-y(end-1)], [diff(x); x(end)-x(end-1)]);

% Vehicle trajectory
vehicleTraj = [x y yaw];

% Call the function
vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',15);

% Assertions
assert(isequal(class(vehicle_boundary), 'struct'))
assert(isequal(size(vehicle_boundary.boundingBox), [N 5 2]));
assert(isequal(size(vehicle_boundary.rearLeft),   [N 2]));
assert(isequal(size(vehicle_boundary.rearRight),  [N 2]));
assert(isequal(size(vehicle_boundary.frontRight), [N 2]));
assert(isequal(size(vehicle_boundary.frontLeft),  [N 2]));
assert(isequal(size(vehicle_boundary.frontCenter),[N 2]));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% TEST case: Backward motion (x decreases)

figNum = 20003;
titleString = sprintf('TEST case: Backward motion (x decreases)');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

N = 40;
x = linspace(20,0,N)';   % moving backward in x
y = zeros(N,1);
yaw = pi*ones(N,1);      % facing negative x

% Vehicle trajectory
vehicleTraj = [x y yaw];

% Call the function
vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',15);

% Assertions
assert(isequal(class(vehicle_boundary), 'struct'))
assert(isequal(size(vehicle_boundary.boundingBox), [N 5 2]));
assert(isequal(size(vehicle_boundary.rearLeft),   [N 2]));
assert(isequal(size(vehicle_boundary.rearRight),  [N 2]));
assert(isequal(size(vehicle_boundary.frontRight), [N 2]));
assert(isequal(size(vehicle_boundary.frontLeft),  [N 2]));
assert(isequal(size(vehicle_boundary.frontCenter),[N 2]));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% TEST case: In-place rotation (same x,y, changing yaw)

figNum = 20004;
titleString = sprintf('TEST case: In-place rotation (same x,y, changing yaw)');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

N = 40;
x = 5*ones(N,1);
y = 3*ones(N,1);
yaw = linspace(-pi, pi, N)';   % rotate full circle

% Vehicle trajectory
vehicleTraj = [x y yaw];

% Call the function
vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, (figNum));

sgtitle(titleString, 'Interpreter','none','Fontsize',15);

% Assertions
assert(isequal(class(vehicle_boundary), 'struct'))
assert(isequal(size(vehicle_boundary.boundingBox), [N 5 2]));
assert(isequal(size(vehicle_boundary.rearLeft),   [N 2]));
assert(isequal(size(vehicle_boundary.rearRight),  [N 2]));
assert(isequal(size(vehicle_boundary.frontRight), [N 2]));
assert(isequal(size(vehicle_boundary.frontLeft),  [N 2]));
assert(isequal(size(vehicle_boundary.frontCenter),[N 2]));

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

N = 30;
x = linspace(0,20,N)'; 
y = zeros(N,1);
yaw = zeros(N,1);

% Vehicle trajectory
vehicleTraj = [x y yaw];

% Call the function
vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, ([]));

% Assertions
assert(isequal(class(vehicle_boundary), 'struct'))
assert(isequal(size(vehicle_boundary.boundingBox), [N 5 2]));
assert(isequal(size(vehicle_boundary.rearLeft),   [N 2]));
assert(isequal(size(vehicle_boundary.rearRight),  [N 2]));
assert(isequal(size(vehicle_boundary.frontRight), [N 2]));
assert(isequal(size(vehicle_boundary.frontLeft),  [N 2]));
assert(isequal(size(vehicle_boundary.frontCenter),[N 2]));


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% Basic fast mode - NO FIGURE, FAST MODE

figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, empty figNum\n',figNum);
figure(figNum); close(figNum);

N = 30;
x = linspace(0,20,N)'; 
y = zeros(N,1);
yaw = zeros(N,1);

% Vehicle trajectory
vehicleTraj = [x y yaw];

% Call the function
vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, (-1));

% Assertions
assert(isequal(class(vehicle_boundary), 'struct'))
assert(isequal(size(vehicle_boundary.boundingBox), [N 5 2]));
assert(isequal(size(vehicle_boundary.rearLeft),   [N 2]));
assert(isequal(size(vehicle_boundary.rearRight),  [N 2]));
assert(isequal(size(vehicle_boundary.frontRight), [N 2]));
assert(isequal(size(vehicle_boundary.frontLeft),  [N 2]));
assert(isequal(size(vehicle_boundary.frontCenter),[N 2]));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Compare speeds of pre-calculation versus post-calculation versus a fast variant

figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum); close(figNum);

N = 30;
x = linspace(0,20,N)'; 
y = zeros(N,1);
yaw = zeros(N,1);

% Vehicle trajectory
vehicleTraj = [x y yaw];

Niterations = 10;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations

    % Call the function
    vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, ([]));


end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;

for ith_test = 1:Niterations

    % Call the function
    vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, (-1));


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
assert(isequal(class(vehicle_boundary), 'struct'))
assert(isequal(size(vehicle_boundary.boundingBox), [N 5 2]));
assert(isequal(size(vehicle_boundary.rearLeft),   [N 2]));
assert(isequal(size(vehicle_boundary.rearRight),  [N 2]));
assert(isequal(size(vehicle_boundary.frontRight), [N 2]));
assert(isequal(size(vehicle_boundary.frontLeft),  [N 2]));
assert(isequal(size(vehicle_boundary.frontCenter),[N 2]));


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

    %% Should throw an error as the vehicleTraj should be a 3 column matrix

    figNum = 90001;
    fprintf(1,'Figure: %.0f:Bug case\n',figNum);
    figure(figNum); close(figNum);

    N = 30;
    x = linspace(0,20,N)';
    y = zeros(N,1);
    yaw = zeros(N,1);

    % Vehicle trajectory
    vehicleTraj = [x y];

    % Call the function
    vehicle_boundary = fcn_SafetyMetrics_generateVehicleBoundary2D(vehicleTraj, vehicleParametersStruct, (figNum));

    % Assertions
    assert(isequal(class(vehicle_boundary), 'struct'))
    assert(isequal(size(vehicle_boundary.boundingBox), [N 5 2]));
    assert(isequal(size(vehicle_boundary.rearLeft),   [N 2]));
    assert(isequal(size(vehicle_boundary.rearRight),  [N 2]));
    assert(isequal(size(vehicle_boundary.frontRight), [N 2]));
    assert(isequal(size(vehicle_boundary.frontLeft),  [N 2]));
    assert(isequal(size(vehicle_boundary.frontCenter),[N 2]));

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