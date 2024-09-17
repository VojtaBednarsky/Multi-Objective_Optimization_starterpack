function [S11_dB, minS] = f_simulate_antenna_S11(Net_real, Net_imag, design, f, intervalStart, intervalEnd)

    % Add frequency vector to the design parameters
    design = [design, f];

    % Simulate the real and imaginary parts of the S-parameters
    S11r = sim(Net_real, design')'; % Real part
    S11c = sim(Net_imag, design')'; % Imaginary part

    % Convert to complex numbers
    complex_numbers = complex(S11r, S11c);
    
    % Calculate magnitude of the complex S-parameters
    S = abs(complex_numbers);
    
    % Convert magnitude to dB scale
    S11_dB = 20 * log10(S);

    % Filter values within the desired frequency interval
    indicesInInterval = find(f >= intervalStart & f <= intervalEnd);
    filteredIndices = find(S11_dB(indicesInInterval) < -10); % Values below -10 dB

    % Check if there are filtered values below -10 dB
    if ~isempty(filteredIndices)
        indicesInIntervalFiltered = indicesInInterval(filteredIndices);
        filteredS11_dB = S11_dB(indicesInIntervalFiltered);

        % Update interval start based on filtered values
        newIntervalStart = f(indicesInIntervalFiltered(1));

        % Adjust the interval by 20% on both sides
        intervalSize = intervalEnd - newIntervalStart;
        shrinkPercent = 0.2; % Shrink by 20%

        newIntervalEnd = intervalEnd - shrinkPercent * intervalSize;
        newIntervalStart = intervalStart + shrinkPercent * intervalSize;

        % Find new indices within the updated interval
        newIndices = find(f >= newIntervalStart & f <= newIntervalEnd);
        minS = max(S11_dB(newIndices)); % Get the maximum S11 in the new interval
    else
        % If no values are below -10 dB, assign a high penalty value
        minS = 1e6;
    end
end