function [fitness] = f_evaluate_fitness_function(Net_db, design, f, intervalStart, intervalEnd, max_size)
    % Evaluate the fitness function for antenna design using a trained network.
    
    % Simulate antenna S11 parameter
    S11_dB = [];        % Initialize S11 dB result array
    f1 = [];            % Initialize array for interval starts
    f2 = [];            % Initialize array for interval ends
    [S11_dB, minS] = f_simulate_antenna_S11(Net_db, design, f, intervalStart, intervalEnd);
    
    % Initialize fitness with large values
    fitness = [1e6, 1e6];
        
    % First criterion - minimizing the antenna shape area
    area = f_calculate_shape(design'); % Calculate the shape area
    fitness(1) = area;  % Set the first fitness value based on shape area
    
    % Apply maximum size constraint on the area
    if area > max_size
        fitness(1) = 1e6;  % Penalize if the area exceeds the maximum size
    else
        fitness(1) = area;  % Otherwise, keep the calculated area as fitness(1)
    end

    % Second criterion - assign minimum S11 value as the second fitness value
    fitness(2) = minS;
end
