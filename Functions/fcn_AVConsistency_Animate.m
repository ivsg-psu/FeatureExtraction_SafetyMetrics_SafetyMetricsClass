function fcn_AVConsistency_Animate(AVdata, otherVehData, roadCenterLine, numOfRightLanes, fignum, outputFileName)
% This function animates the trajectory of an autonomous vehicle (AV) and another vehicle.
% The animation is based on their positions over time and the road centerline.
%
% Parameters:
% AVdata           : A structure containing the AV's data. It should have fields for X and Y positions, and timestep_time.
% otherVehData     : A structure similar to AVdata, but for another vehicle.
% roadCenterLine   : A structure representing the road's centerline. It should have fields X and Y.
% numOfRightLanes  : The number of lanes to the right of the road centerline.
% fignum           : The figure number for plotting.
% outputFileName   : The name of the output video file (a string).

% Calculate lane offsets based on a standard lane width of 3.65 meters.
offsets = -3.65 .* (1:numOfRightLanes)';

% Convert the road centerline to a traversal structure.
reference_traversal = fcn_Path_convertPathToTraversalStructure(roadCenterLine);

% Generate offset traversals for each lane based on the road centerline.
offset_traversals = fcn_Path_fillOffsetTraversalsAboutTraversal(reference_traversal, offsets, []);

% Step 2: Extract Relevant Information
% Synchronize the start time of the AV and the other vehicle.
startTime = max(AVdata.timestep_time(1), otherVehData.timestep_time(1));
otherVehData = otherVehData(otherVehData.timestep_time >= startTime, :);

% Extract X and Y positions of the AV and the other vehicle.
AVx = AVdata.vehicle_x;
AVy = AVdata.vehicle_y;
otherVehx = otherVehData.vehicle_x;
otherVehy = otherVehData.vehicle_y;

% Step 3: Set Up the Plot
figure(fignum);
ax = axes;
hold on;
grid on;

% Plot the road centerline.
plot(reference_traversal.X, reference_traversal.Y, 'color', '#EDB120', 'LineWidth', 2);

% Plot lane boundaries.
for ii = 1:numOfRightLanes
    plot(offset_traversals.traversal{ii}.X, offset_traversals.traversal{ii}.Y, 'k', 'LineWidth', 1);
end

% Label the axes.
xlabel('X Position (meters)');
ylabel('Y Position (meters)');

% Set fixed axis limits.
xlim(ax, [min(AVx) - 20, max(AVx) + 20]);
ylim(ax, [min(AVy) - 20, max(AVy) + 20]);

% Initialize the plot points for the AV and the other vehicle.
h = plot(AVx(1), AVy(1), 'o', 'MarkerSize', 5, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'r');
h2 = plot(otherVehx(1), otherVehy(1), 'o', 'MarkerSize', 5, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'k');

% Add a legend.
legend([h, h2], {'Autonomous vehicle', 'Lead or following vehicle'}, 'Location', 'northwest');

% Determine the length of the shorter trajectory.
minLength = min(length(AVx), length(otherVehx));

% Step 4: Animate the Trajectory
% Set up the video writer.
v = VideoWriter(outputFileName, 'MPEG-4');
v.FrameRate = 10; % Adjust the frame rate as needed
open(v);

for k = 2:minLength
    set(h, 'XData', AVx(k), 'YData', AVy(k));
    set(h2, 'XData', otherVehx(k), 'YData', otherVehy(k));
    drawnow; % Update the plot
    frame = getframe(gcf);
    writeVideo(v, frame); % Add the frame to the video
    pause(0.1); % Pause to control the animation speed
end

% Step 5: Save or Show the Animation
close(v); % Close the video file
hold off;
end
