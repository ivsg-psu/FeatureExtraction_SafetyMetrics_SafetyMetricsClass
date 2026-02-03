% Assuming your matrix is named 'dataMatrix' with columns [X, Y, S]
% Replace 'dataMatrix' with the actual name of your matrix variable


fig_num = 11;
pathXY = readtable('referenceline_20231016.csv');
pathXY = [pathXY.Var1,pathXY.Var2];
traversal = fcn_Path_convertPathToTraversalStructure(pathXY,fig_num);
simple_example.traversal{1} = traversal;

%fcn_Path_plotTraversalsXY(simple_example,fig_num);
new_stations = [0:10:1550]';
newtrav = fcn_Path_newTraversalByStationResampling(traversal, new_stations)
% Extract X, Y, and S columns
X = newtrav.X;
Y = newtrav.Y;
S = newtrav.Station;
% Define padding for the axes
padding = 50; % Adjust padding value as needed
xRange = range(X);
yRange = range(Y);
figure();
% Create a scatter plot of X and Y
scatter(X, Y, 'filled');
hold on; % Keep the scatter plot visible while we add text annotations

% Add text annotation for each S-coordinate
for i = 1:10:length(S)
    text(X(i), Y(i), num2str(S(i)), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right','FontSize',14);
end

% Labels for the axes
xlabel('X Position (m)');
ylabel('Y Position (m)');
% Set the axes limits with padding
xlim([min(X) - padding, max(X) + padding]);
ylim([min(Y) - padding, max(Y) + padding]);
grid on;
set(gcf, 'Units', 'inches', 'Position', [5, 5, 10, 6.2], 'PaperUnits', 'inches', 'PaperSize', [6, 3], 'color', 'w');
set(gca,'Box','on','LineWidth',2);

% Title for the plot
%title('Scatter Plot with S-coordinate Annotations');

% Optionally, set the axes limits if necessary
% xlim([min(X) max(X)]);
% ylim([min(Y) max(Y)]);
% Customize the plot to make it publication quality
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman', 'linewidth', 2); % Font settings

hold off; % Release the plot hold
print(gcf,'testtrack','-dsvg');