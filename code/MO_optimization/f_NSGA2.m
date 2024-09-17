function [x, fval] = f_NSGA2(nvars, f, Net_imag, Net_real, lb, ub, intervalStart, intervalEnd)

    % START
    % Define the optimization problem
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    nonlcon = [];

    % Define the fitness evaluation function for candidate designs
    fitness_function = @(design) f_evaluate_fitness_function(Net_real, Net_imag, design, f, intervalStart, intervalEnd);
    
    % Set options for NSGA-II (Non-dominated Sorting Genetic Algorithm II)
    options = optimoptions('gamultiobj', 'PopulationSize', 100, 'MaxGenerations', 50, 'PlotFcn', 'gaplotpareto');
    
    % Initialize fval to store the objective values
    fval = [];

    % Run NSGA-II algorithm
    [x, fval] = gamultiobj(fitness_function, nvars, A, b, Aeq, beq, lb, ub, nonlcon, options);
    
    % Remove rows with missing fitness values (where fitness = 1e6)
    badRows = any(fval == 1e6, 2);
    fval = fval(~badRows, :);
    x = x(~badRows, :);

end