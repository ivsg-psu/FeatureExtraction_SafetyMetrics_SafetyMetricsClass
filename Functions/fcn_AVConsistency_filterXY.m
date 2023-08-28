function [new_x, new_y] = fcn_AVConsistency_filterXY(data, delta)
    % This function smoothens the lane change using a quadratic interpolation
    %
    % Inputs:
    % x - vehicle's x position
    % y - vehicle's y position
    % delta - the range around lane change points for smoothing. Represents how 'wide' the arc should be.
    %
    % Outputs:
    % new_x - new x positions after smoothing
    % new_y - new y positions after smoothing
    x = data.vehicle_x;
    y = data.vehicle_y;
    new_x = x;
    new_y = y;

    for i = 2:length(y) - 1
        if abs(y(i) - y(i-1)) > delta || abs(y(i) - y(i+1)) > delta

            % Detected a lane change
            x1 = x(i-1);
            y1 = y(i-1);
            x3 = x(i+1);
            y3 = y(i+1);
            x2 = (x1 + x3) / 2;
            y2 = y(i);

            % Quadratic interpolation
            X = [x1^2, x1, 1; x2^2, x2, 1; x3^2, x3, 1];
            Y = [y1; y2; y3];
            coeffs = X\Y;
% Determine start and end indices for the lane change in the new_x and new_y arrays
start_idx = i-1;
end_idx = find(x > x3, 1) - 1;  % find the index of the first value greater than x3

% Determine how many points to replace
n_points = end_idx - start_idx + 1;

% Quadratic interpolation
X = [x1^2, x1, 1; x2^2, x2, 1; x3^2, x3, 1];
Y = [y1; y2; y3];
coeffs = X\Y;

% Generate interpolated y values
xi = linspace(x1, x3, n_points);

yi = (coeffs(1)*xi.^2 + coeffs(2)*xi + coeffs(3))';
% Append to the new_x and new_y arrays
new_x = [new_x(1:start_idx-1); xi'; new_x(end_idx+1:end)];


new_y = [new_y(1:start_idx-1); yi; new_y(end_idx+1:end)];
        end
    end
end
