clear all;
clc;
close all;

% Load datasets
load('ANN_Imag_sit.mat');
load('ANN_Real_sit.mat');
load('ANN_dB.mat');

% Parameters
poc_prom = 9;
csvFileName = 'data2.csv';
fitnes = load("fitnes_file.csv");
numIterations = 12;
pointsToPlot = 500; % Number of points to plot in the first iteration
dataset = pointsToPlot;

dataPointsPerIteration = floor(size(fitnes, 1) / numIterations);
intervalStart = 6;
intervalEnd = 8;
data = load(csvFileName);
columns = floor((size(data, 1) - pointsToPlot) / numIterations);

% Select columns for 'design' and 'EM_gain'
design = data(:, 2:8);

x = cell(1, numIterations);  % Store x values
y = cell(1, numIterations);  % Store y values
fy = cell(1, numIterations); % Store third fitness values

figureIndex = 1;  % Initial figure index
previousX = {};
previousY = {};

% Loop through each iteration
for p = 1:numIterations
    if p == 1
        % First iteration only
        figure(1);
        hold on;
        pointColor = 'k';  % Black for the first iteration
        title(['DATASET']);
        pcolums = 1:dataset;
    else
        figure(figureIndex);
        pcolums = round((dataset - columns + 2) + (p - 1) * columns):round((dataset - columns + 1) + p * columns);
        % Choose colors for subsequent iterations (blue, red)
        colors = {'b', 'r', 'y'};
        pointColor = colors{mod(p - 2, 2) + 1};
        pointsToPlot = pcolums;
        title(['Graph for iteration ' num2str(p)]);
    end

    pointSize = 20;

    x{p} = [];  % Initialize x values for the current iteration
    y{p} = [];  % Initialize y values for the current iteration
    fy{p} = [];

    for i = 1:pointsToPlot
        % Calculate fitness
        fitness(i, 1) = f_calculate_shape(design(i, :)');
        
        vzorkovani = 11;
        min_freq_simulace = 2;
        max_freq_simulace = 12;
        numValues = (size(data, 2) - poc_prom) / 2;
        step = (max_freq_simulace - min_freq_simulace) / (numValues - 1);
        frekvence = min_freq_simulace:step:max_freq_simulace;
        frekvence = frekvence(:, 1:1001);
        fv = frekvence(:, 1:vzorkovani:end);
        
        % Simulate antenna S11
        designn = [design(i, :), fv];
        S11_dB = sim(Net_db, designn');
        
        % Filter values below -10 dB
        indicesInInterval = find(fv >= intervalStart & fv <= intervalEnd);
        intervalSize = fv(max(indicesInInterval)) - fv(min(indicesInInterval));
        shrinkPercent = 0.0;  % 20 percent
        
        newIntervalEnd = fv(max(indicesInInterval)) - shrinkPercent * intervalSize;
        newIntervalStart = fv(min(indicesInInterval)) + (shrinkPercent * intervalSize);
        newIndices = find(fv >= newIntervalStart & fv <= newIntervalEnd);
        fitness(i, 2) = max(S11_dB(newIndices));
        
        % Calculate real S-parameters
        Yr = data(i, (poc_prom + 1):(1001 + poc_prom));
        Yc = data(i, (1002 + poc_prom:end));
        Ss = complex(Yr, Yc);
        S2 = abs(Ss);
        S_dB2 = 20 * log10(S2);
        realInterval = find(frekvence >= intervalStart & frekvence <= intervalEnd);
        max_real = max(S_dB2(realInterval));
        fitness(i, 3) = max_real; 
        
        x{p} = [x{p}; fitness(i, 1)];
        y{p} = [y{p}; fitness(i, 2)];
        fy{p} = [fy{p}; fitness(i, 3)];
    end

    % Store current points for the next iteration
    previousX{p} = x{p};
    previousY{p} = y{p};

    startIndex = (p - 1) * dataPointsPerIteration + 1;
    endIndex = min(p * dataPointsPerIteration, size(fitness, 1));
    subsetFitnes = fitness(startIndex:endIndex, :);

    % Plot results
    scatter(x{p}, y{p}, 20, pointColor, 'filled');
    hold on;
    
    % Plot Pareto front values for iteration 1
    scatter(subsetFitnes(:, 1), subsetFitnes(:, 2), 'Marker', 's', 'SizeData', 30, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'y');
    pause(1);
    hold on;
    scatter(x{p}, y{p}, pointSize, pointColor, 'filled');
    hold on;
    scatter(x{p}, fy{p}, pointSize, pointColor, 'd');
    xlabel('Fitness 1');
    ylabel('Fitness 2');
    axis([100, 600, -30, 0]);
    grid on;

    pause(3);
    
    % Increment figure index for the next iteration
    figureIndex = figureIndex + 1;
end

% Compute Mean Squared Error (MSE) between fitness columns
clc;
MSE = sum((fitness(:, 2) - fitness(:, 3)).^2) / size(fitness, 1);