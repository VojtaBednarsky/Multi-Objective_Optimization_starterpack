function antennaShape = f_calculate_shape(design)
    % Calculate the antenna shape area based on the given design parameters.
    
    % Extract design parameters from the input 'design' vector
    a2 = design(3);   % Parameter a2 (third element)
    o3 = design(7);   % Parameter o3 (seventh element)
    lg = design(1);   % Parameter lg (first element)
    l1 = design(4);   % Parameter l1 (fourth element)
    w1 = design(6);   % Parameter w1 (sixth element)
    
    % Calculate dimensions of the antenna
    a1 = a2 + 2 * o3;  % Total width of the antenna (a2 + 2 * o3)
    b1 = lg + l1 + w1; % Total length of the antenna (lg + l1 + w1)
    
    % Calculate the area of the antenna in mm²
    area = a1 * b1;

    % Return the calculated area
    antennaShape = area;
end