function [S, maxS_CST, gain] = f_calculate_resultsCST(design, intervalStart, intervalEnd, simulaci)
    % Extract dimensions from design array
    lg = design(1);
    g = design(2);
    a2 = design(3);
    l1 = design(4);
    l2 = design(5);
    w1 = design(6);
    o3 = design(7);

    % Calculate parameters
    lt = lg + g;
    a1 = a2 + 2 * o3;
    b1 = lt + a2 + 1;
    b11 = lg + l1 + w1;
    
    % Select the larger value for length
    if b1 > b11
        L = b1;
    else
        L = b11;
    end
    
    % Initialize constants
    hsub = 0.762;
    c0 = 299792458; 
    W = a1;
    W2 = W / 2;
    w0 = 1.7 / 2; 
    wcop = W / 2 + w0;
    nwcop = W / 2 - w0;
    Rpin = 0.39;
    k = 6.15;
    pport = (W / 2) + w0 + (k * hsub); 
    nport = (W / 2) - w0 - (k * hsub);
    hport = hsub + k * hsub;
    
    % Initialize CST simulation
    CST = CST_MicrowaveStudio(cd, 'Antenna.cst');
    CST.setSolver('time');
    
    % Set design parameters in CST
    CST.addParameter('lt', lt);
    CST.addParameter('lg', lg);
    CST.addParameter('g', g);
    CST.addParameter('a2', a2);
    CST.addParameter('W', W);
    CST.addParameter('L', L);
    CST.addParameter('h_sub', hsub);
    CST.addParameter('wcop', wcop);
    CST.addParameter('nwcop', nwcop);
    CST.addParameter('l1', l1);
    CST.addParameter('l2', W - l2 - w1);
    CST.addParameter('a1', a1);
    CST.addParameter('b1', b1);
    CST.addParameter('w1', W - w1);
    CST.addParameter('o3', o3);
    CST.addParameter('a22', W / 2 + a2 / 2);
    CST.addParameter('na22', W / 2 - a2 / 2);
    CST.addParameter('lta2', lt + a2);
    CST.addParameter('L_w1', L - w1);
    CST.addParameter('W2', W / 2);
    CST.addParameter('Rpin', Rpin);
    CST.addParameter('hRpin', hsub + Rpin);
    CST.addParameter('Lsma', -0.39);
    CST.addParameter('Lpin', 0.39);
    CST.addParameter('L1lg', l1 + lg);
    CST.addParameter('L_w1', l1 + lg + w1);
    CST.addParameter('pport', pport);
    CST.addParameter('nport', nport);
    CST.addParameter('hport', hport);
    
    % Add materials and build structure in CST
    CST.addNormalMaterial('dielectric', 3.5, 1, [0.8 0.1 0]);
    CST.addBrick({0, 'W'}, {0, 'L'}, {0, 'h_sub'}, 'substrate', 'component1', 'dielectric');
    CST.addBrick({'nwcop', 'wcop'}, {0, 'Lt'}, {'h_sub', 'h_sub'}, 'trace', 'component1', 'PEC');
    CST.addBrick({'na22', 'a22'}, {'Lt', 'Lta2'}, {'h_sub', 'h_sub'}, 'square', 'component1', 'PEC');
    CST.addBrick({0, 'W'}, {0, 'lg'}, {0, 0}, 'GND_1', 'component1', 'PEC');
    CST.addBrick({'w1', 'W'}, {'lg', 'L1lg'}, {0, 0}, 'Lko1', 'component1', 'PEC');
    CST.addBrick({'l2', 'W'}, {'L1lg', 'L_w1'}, {0, 0}, 'Lko2', 'component1', 'PEC');
    
    % Configure frequency and port settings in CST
    CST.addWaveguidePort('ymin', {'nport', 'pport'}, {0, 'L'}, {0, 'hport'});
    CST.setFreq(2.0, 12);  
    
    % Run simulation
    CST.setUpdateStatus(true);
    CST.runSimulation();
    
    % Get S-parameters (S11)
    [freq, S] = CST.getSParameters('S11');
    S_dB = 20 * log10(abs(S));
    
    % Find intervals where S11 is below -10 dB
    intervals = [];
    new_freq = [];
    for j = 1:length(freq)
        if S_dB(j) < -10
            if isempty(new_freq)
                new_freq = freq(j);
            end
        else
            if ~isempty(new_freq)
                intervals = [intervals; [new_freq, freq(j)]];
                new_freq = [];
            end
        end
    end
    
    % Include the last interval if it ends within range
    if ~isempty(new_freq)
        intervals = [intervals; [new_freq, freq(end)]];
    end
    
    % Find maximum S11 in the specified frequency range
    indicesInInterval = find(freq >= intervalStart & freq <= intervalEnd);
    maxS_CST = max(S_dB(indicesInInterval));
    
    % Plot S11 results if the simulation count is below 9
    if simulaci < 9
        figure(2); ylabel('S-parameter (dB)'); xlabel('Frequency (GHz)'); grid on;
        plot(freq, S_dB);
        hold on;
    end
    
    % Save and close CST project
    CST.setUpdateStatus(true);
    CST.save();
    CST.closeProject();
end