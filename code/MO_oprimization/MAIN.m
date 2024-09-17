% Optimization of Antenna using ANN and NSGA-II for planar monopole
% Clear workspace and start timing
tic;
clc;
close all;
clear all;

% Number of attempts
pokusu = 1;

% Optimization loop for multiple attempts
for pokusu = 1:pokusu
    % Initialization
    E_history = [];
    E = [];
    fitness_history = [];
    resultRow = [];
    results = [];
    res = [];
    x = [];
    q = 0;
    cst_fitness = [];
    cst_fitness_history = [];
    simulaci = 0;
    num = 0;
    c_simulaci = 0;
    consecutive_generations = 0;
    itr_av_plot = [];
    o = 1;
    Fd = [];
    min = [];
    max = [];

    % Customization
    % Load the data files
    csvFileName = 'data2.csv';
    fitnes_file = 'fitnes_file.csv';

    min_freq = 2;
    max_freq = 12;
    vzorkovani = 11;

    % Define bounds for optimization variables
    lb = [4, -2, 4, 5, 1, 0.5, 0.5];
    ub = [15, 2, 15, 20, 10, 3.5, 5.5];
    
    % Number of optimization variables
    nvars = 7;
    
    % Frequency interval for searching values
    intervalStart = 6;
    intervalEnd = 8;

    % Maximum number of iterations for ANN training
    maxPocet = 24; 

    % Number of simulations per iteration
    numsim = 5; % Minimum 2!!!

    eliteCount = 2;

    % Convergence criteria
    convergence_threshold = 5e-2;
    max_consecutive_generations = 3; 

    % Averaging interval
    prumerovaciInterval = 3; % Must be the same!
    iteraceProPrumerovani = 3; % Must be the same

    % Clear and overwrite the existing data in the fitness file
    fileIDI = fopen(fitnes_file, 'w');
    fclose(fileIDI);

    % Load ANN networks
    load('ANN_Real_sit.mat');
    load('ANN_Imag_sit.mat');
    data = load(csvFileName);
    
    % Load frequencies and create frequency sequence
    pocet_cisel = (size(data,2) - 9) / 2;
    krok = (max_freq - min_freq) / (pocet_cisel - 1);
    frekvence = min_freq:krok:max_freq; 
    f = frekvence(:, 1:vzorkovani:end);

    % Optimization iterations
    for iterace = 1:maxPocet
        disp(['Running iteration number:', num2str(iterace), ', Total simulations performed:', num2str(c_simulaci)]);
        
        maxAttempts = 20;  % Maximum number of attempts
        for iter = 1:maxAttempts
            try
                [x, fval] = f_NSGA2(nvars, f, Net_imag, Net_real, lb, ub, intervalStart, intervalEnd);
                % Clean fval and prepare for further simulations and interpolation        
                fitness_history = [fval, x];
                clear min; clear max;
                % Remove duplicates
                unique_fitness_history = unique(fitness_history, 'rows');
                unique_fitness_history = sortrows(unique_fitness_history, 1);

                % Determine unique fitness values and their count
                [c, ~, ic] = unique(unique_fitness_history(:, 1));
                counts = accumarray(ic, 1);

                % Swap the second row with the last row
                second_row = unique_fitness_history(2, :);
                unique_fitness_history(2, :) = unique_fitness_history(end, :);
                unique_fitness_history(end, :) = second_row;
                break;
            catch
                disp(['Error in Pareto-front, restarting attempt.']);
            end
        end
        
        % Shuffle rows from the third row onwards
        random_permutation = randperm(size(unique_fitness_history, 1));
        shuffled_rows = randperm(size(unique_fitness_history, 1) - 2) + 2;
        shuffled_unique_fitness_history = unique_fitness_history;
        shuffled_unique_fitness_history(3:end, :) = unique_fitness_history(shuffled_rows, :);
        unique_fitness_history = shuffled_unique_fitness_history;

        numsim = round(size(fval,1) / 3); 
        for i = 1:numsim
            % Extract antenna design from sorted matrix
            design = unique_fitness_history(i, 3:(2 + nvars))';
            simulaci = simulaci + 1;
            c_simulaci = c_simulaci + 1;
            disp(['Running simulation number:', num2str(simulaci), '/', num2str(numsim)]);
            [S, maxS_CST] = f_calculate_resultsCST(design, intervalStart, intervalEnd, simulaci);
            disp(['Comparison results for design interval: <', num2str(i), '>']);
            disp(['Model:   max(S11) = ', num2str(fval(i, 2)), ' dB']);
            disp(['CST:    max(S11) = ', num2str(maxS_CST), ' dB']);
            cst_fitness(i,:) = [unique_fitness_history(i,1), (maxS_CST)];
            cst_fitness_history(c_simulaci,:) = [unique_fitness_history(i,1), (maxS_CST)];
    
            % Save CST data for model retraining
            resultRow = [];
            gain = 0;
            frez = 0;
            resultRow =  design';
            resultRow = [resultRow, S];
            results{i} = resultRow;
            fileID = fopen(csvFileName, 'a');
            fprintf(fileID, '%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,%.15f', frez, design, gain);
            fprintf(fileID, ',%.15f,%.15f', real(S), imag(S));
            fprintf(fileID, '\n');
            fclose(fileID);
        end
        
        % Save to CSV file after each iteration
        fitnesRow = unique_fitness_history(:, 1:2);            
        % Open the file in append mode
        fileIDI = fopen(fitnes_file, 'a'); 
        % Print the values to the file
        fprintf(fileIDI, '%.15f,%.15f\n', fitnesRow');
        % Close the file
        fclose(fileIDI);

        % Interpolation
        % Calculate minimum and maximum fitness values
        min_val = min(unique_fitness_history(:,1));
        max_val = max(unique_fitness_history(:,1));

        new_fitness = cst_fitness; % Initialize new fitness values        
        
        % Determine number of new values
        num_values = size(unique_fitness_history,1);
        % Calculate step size
        step = (max_val - min_val) / (num_values - 1);
        % Create new vector x-values for interpolation
        Fd = min_val:step:max_val;
        % Interpolate
        Fi = interp1(cst_fitness(:,1), cst_fitness(:,2), Fd, 'spline');
        min = [];
        max = [];
        
        % Sort values from CST and model
        ser_cst = sortrows([Fd', Fi'], 1);
        ser_mod = sortrows(unique_fitness_history(:,1:2), 1);

        % Calculate the difference
        E_history(iterace) = mean(mean(abs(ser_cst - ser_mod)));              

        % Plot optimization progress every few iterations and the first iteration
        if (mod(iterace, prumerovaciInterval) == 0) || (iterace == 1)
            if iterace == 1
                itr_av_plot(1, o) = iterace - 1;
                itr_av_plot(2, o) = 100;
            else
                itr_av_plot(1, o) = iterace;
                itr_av_plot(2, o) = mean(E_history((iterace - iteraceProPrumerovani + 1):iterace));
            end

            % Add data points to plot
            o = o + 1;
            
            % Close Pareto plot window (for 5 samples)
            close(figure(21));
           
            % Plot Pareto front vs CST
            graph = 30 + round(iterace / iteraceProPrumerovani);
            figure(graph)
            num = customParetoPlot(fval(:, 1), fval(:, 2), 1, num, iterace);
            hold on;
            customParetoPlot(cst_fitness_history(:, 1), cst_fitness_history(:, 2), 2, num, iterace);
            hold on;
            customParetoPlot(cst_fitness(:,1), cst_fitness(:, 2), 3, 3, iterace);

            % Plot convergence data
            figure(20);
            plot(itr_av_plot(1,:), itr_av_plot(2,:), 'o');
            hold on;
            plot(itr_av_plot(1,:), itr_av_plot(2,:));
            title('Convergence plot');
            xlabel('Iteration');
            ylabel('Approximated Average fitness value');
            grid on;
            hold on;
            xticks(0:iteraceProPrumerovani:iterace);
            
            % Retrain the model
            data = load(csvFileName);
            [Net_real, Net_imag] = f_reTrain(data, frekvence, nvars, vzorkovani);
        end
        simulaci = 0;
        iterace = iterace + 1;
    end
end    

% End timing
toc;
disp(['Elapsed time:', num2str(toc / 60), ' minutes']);