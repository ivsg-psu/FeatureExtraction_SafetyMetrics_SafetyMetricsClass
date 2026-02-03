function [h1,h2] = fcn_AVConsistency_plotStats(mean_data, upper_bound, lower_bound, x_values, keyword, fignum,yyplotFlag)
coe_mps2mph = 2.23694;
figure(fignum);


% Set the figure size and resolution
set(gcf, 'Units', 'inches', 'Position', [5, 5, 10, 5], 'PaperUnits', 'inches', 'PaperSize', [6, 3], 'color', 'w');
hold on;
% Find indices where NaNs are not present
notNaNIndices = ~isnan(upper_bound) & ~isnan(lower_bound);

if strcmp(keyword,'theme2')
    yyaxis left;
    % Re-plot the mean data to make sure it's on top
    h1 = plot(x_values(notNaNIndices ), mean_data(notNaNIndices), 'LineWidth', 2, ...
        'Color', [0 0.4470 0.7410] ,'LineStyle','-');

    % Fill the area between the upper and lower bounds
    h2 = fill([x_values(notNaNIndices ), fliplr(x_values(notNaNIndices ))], ...
        [upper_bound(notNaNIndices ), fliplr(lower_bound(notNaNIndices ))], ...
        [0 0.4470 0.7410], 'facealpha', 0.3, 'LineStyle', 'none'); % Light gray color

    if yyplotFlag
        yyaxis right;

        % Re-plot the mean data to make sure it's on top
        h3 = plot(x_values(notNaNIndices), mean_data(notNaNIndices)*coe_mps2mph, 'LineWidth', 2, ...
            'Color', [0 0.4470 0.7410],'LineStyle','-');

        % Fill the area between the upper and lower bounds
        h4 = fill([x_values(notNaNIndices), fliplr(x_values(notNaNIndices))], ...
            [upper_bound(notNaNIndices)*coe_mps2mph, fliplr(lower_bound(notNaNIndices)*coe_mps2mph)], ...
            [0 0.4470 0.7410], 'facealpha', 0.3, 'LineStyle', 'none'); % Light gray color
    end


elseif strcmp(keyword,'theme1')
    yyaxis left;

    % Re-plot the mean data to make sure it's on top
    h1 = plot(x_values(notNaNIndices), mean_data(notNaNIndices), 'LineWidth', 2, ...
        'Color', 'k', 'LineStyle','-');

    h2 = fill([x_values(notNaNIndices ), fliplr(x_values(notNaNIndices ))], [upper_bound(notNaNIndices ), fliplr(lower_bound(notNaNIndices ))], ...
        [0.8, 0.8, 0.8], 'LineStyle', 'none', 'facealpha', 0.5); % Light gray color

    if yyplotFlag
        yyaxis right;

        % Re-plot the mean data to make sure it's on top
        h3 = plot(x_values(notNaNIndices), mean_data(notNaNIndices)*coe_mps2mph, 'LineWidth', 2, ...
            'Color', 'k','LineStyle','-');

        h4 = fill([x_values(notNaNIndices), fliplr(x_values(notNaNIndices))], ...
            [upper_bound(notNaNIndices) * coe_mps2mph, fliplr(lower_bound(notNaNIndices)*coe_mps2mph)], ...
            [0.8, 0.8, 0.8], 'LineStyle', 'none', 'facealpha', 0.5); % Light gray color

    end

elseif strcmp(keyword,'theme3')
    yyaxis left;
    % y = 10
    % ylim([0 y]);

    % Re-plot the mean data to make sure it's on top
    h1 = plot(x_values(notNaNIndices), mean_data(notNaNIndices), 'LineWidth', 2, ...
        'Color', [0.4940 0.1840 0.5560], 'LineStyle','-');

    h2 = fill([x_values(notNaNIndices ), fliplr(x_values(notNaNIndices ))], [upper_bound(notNaNIndices ), fliplr(lower_bound(notNaNIndices ))], ...
        [0.4940 0.1840 0.5560], 'LineStyle', 'none', 'facealpha', 0.5); % Light gray color

    if yyplotFlag
        yyaxis right;
        % rightAxisLimit = y * coe_mps2mph;
        % ylim([0 rightAxisLimit]);
        % disp(['Right axis limits set to: [0, ' num2str(rightAxisLimit) ']']);
    
        % Re-plot the mean data to make sure it's on top
        h3 = plot(x_values(notNaNIndices), mean_data(notNaNIndices)*coe_mps2mph, 'LineWidth', 2, ...
            'Color', [0.4940 0.1840 0.5560],'LineStyle','-');
    
        h4 = fill([x_values(notNaNIndices), fliplr(x_values(notNaNIndices))], ...
            [upper_bound(notNaNIndices) * coe_mps2mph, fliplr(lower_bound(notNaNIndices)*coe_mps2mph)], ...
            [0.4940 0.1840 0.5560], 'LineStyle', 'none', 'facealpha', 0.5); % Light gray color

    end

elseif strcmp(keyword,'theme4')
    yyaxis left;

    % Re-plot the mean data to make sure it's on top
    h1 = plot(x_values(notNaNIndices), mean_data(notNaNIndices), 'LineWidth', 2, ...
        'Color', [0.9290 0.6940 0.1250], 'LineStyle','-');

    h2 = fill([x_values(notNaNIndices ), fliplr(x_values(notNaNIndices ))], [upper_bound(notNaNIndices ), fliplr(lower_bound(notNaNIndices ))], ...
        [0.9290 0.6940 0.1250], 'LineStyle', 'none', 'facealpha', 0.5); % Light gray color

    if yyplotFlag
        yyaxis right;

        % Re-plot the mean data to make sure it's on top
        h3 = plot(x_values(notNaNIndices), mean_data(notNaNIndices)*coe_mps2mph, 'LineWidth', 2, ...
            'Color', [0.9290 0.6940 0.1250],'LineStyle','-');

        h4 = fill([x_values(notNaNIndices), fliplr(x_values(notNaNIndices))], ...
            [upper_bound(notNaNIndices) * coe_mps2mph, fliplr(lower_bound(notNaNIndices)*coe_mps2mph)], ...
            [0.9290 0.6940 0.1250], 'LineStyle', 'none', 'facealpha', 0.5); % Light gray color

    end
end


if 0 == yyplotFlag
    % Get the current axes
    ax = gca;

    % Hide the right y-axis
    ax.YAxis(2).Color = 'none';

    % Additionally, if you want to remove the ticks and labels from the right y-axis, you can do:
    ax.YAxis(2).TickLabels = {};
end

% Customize the plot to make it publication quality
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman', 'linewidth', 2); % Font settings

% Tighten the axes for the plot
box on;
axis tight;


end
