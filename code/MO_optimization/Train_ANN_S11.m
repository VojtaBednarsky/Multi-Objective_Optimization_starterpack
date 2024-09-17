%% Bayesian regularization
clc;

vzorkovani = 11;
data = load('data.csv'); % Load data
nvars = 9; % Number of variables
poc_prom = nvars;

targetMSE = 3;  % MSE threshold
min_freq_simulace = 2; % Min simulation frequency
max_freq_simulace = 12; % Max simulation frequency

% Frequency setup
pocet_cisel = (size(data, 2) - poc_prom) / 2;
krok = (max_freq_simulace - min_freq_simulace) / (pocet_cisel - 1);
frekvence = min_freq_simulace:krok:max_freq_simulace;
frekvence = frekvence(:, 1:1001);
fv = frekvence(:, 1:vzorkovani:end);
min_freq_train = min_freq_simulace;
max_freq_train = max_freq_simulace;
interns = find(fv >= min_freq_train & fv <= max_freq_train);
fvi = (fv(interns));

% Data processing: design and frequency components
poc_prom = nvars;
design = data(:, 2:8);
freq = repmat(fvi, size(design, 1), 1);
X = [design, freq];

Yr = data(:, (poc_prom + 1):(1001 + poc_prom)); % Real part of data
Yc = data(:, (1002 + poc_prom:end)); % Imaginary part of data
Ss = complex(Yr, Yc);
S2 = abs(Ss);
Ss_dB2 = 20 * log10(S2); % Convert to dB

% Filter data by sampling
Yv = Ss_dB2(:, 1:vzorkovani:end);
Y = (Yv(:, interns));

iter = 1;
maxIter = 100; % Max iterations

while iter <= maxIter
    tic; % Start time
    
    % Random hidden layer size setup
    hiddenLayerSize = 10 * randi([1, 10], 1, 3); % 3 layers
    
    % Setup Bayesian regularization for each iteration
    net = feedforwardnet(hiddenLayerSize, 'trainbr'); % Neural network setup
    net.trainParam.epochs = 30; % Number of epochs
    net.trainParam.time = 900; % Max training time (in seconds)
    net.trainParam.showWindow = true; % Show training window
    net.trainParam.Goal = 1; % Desired performance goal
    
    % Performance function and regularization
    net.performFcn = 'mse'; % Mean Squared Error (MSE)
    net.performParam.regularization = 0.05 + 0.95 * rand(1, 1); % Regularization coefficient

    % Data splitting for training and testing
    percentTraining = 80;
    net.divideParam.trainRatio = percentTraining / 100;
    net.divideParam.testRatio = (100 - percentTraining) / 100;

    % Train the network
    net = train(net, X', Y', 'useGPU', 'no');

    % Validate the network
    Y_pred = net(X');
    MSE = mse(Y' - Y_pred); % Mean squared error

    % Display iteration results
    disp(['Iterace ', num2str(iter), ': MSE na validačním datasetu: ', num2str(MSE)]);
    disp(['Nastavené hodnoty - Počet neuronů: ', num2str(hiddenLayerSize), ', Regularizace: ', num2str(net.performParam.regularization)]);
    
    elapsedTime = toc; % End time
    disp(['Čas trvání iterace ', num2str(iter), ': ', num2str(elapsedTime), ' sekundy']);

    % Stop if MSE goal is achieved
    if MSE < targetMSE
        disp('Podmínka splněna. Ukončuji trénink.');
        break;
    end

    iter = iter + 1; % Increment iteration
end

% Save the trained model
Net_db = net;
save('ANN_dB.mat', 'Net_db');

%% Design test
clc;
close all;
load('ANN_Imag_sit.mat');
load('ANN_Real_sit.mat');
load('ANN_dB.mat'); % Load the trained networks
poc_prom = 9;
min_freq_train = 2;
max_freq_train = 12;
intervalStart = 5;
intervalEnd = 8;
vzorkovani = 11;

% Frequency setup for testing
pocet_cisel = (size(data, 2) - poc_prom) / 2;
krok = (max_freq_train - min_freq_train) / (pocet_cisel - 1);
frekvence = min_freq_train:krok:max_freq_train;
frekvence = frekvence(:, 1:1001);
f = frekvence(:, 1:vzorkovani:end);
interns = find(f >= min_freq_train & f <= max_freq_train);
f = (f(interns));

% Design for test simulation
design = [10.1509, -0.4189, 8.0731, 9.3480, 6.5147, 2.8992, 2.2990];
designn = [design, f];
S11_dB = sim(Net_db, designn'); % Simulate the ANN for S11

% Plot the results
plot(f, S11_dB');
ylabel('S11');
xlabel('frequency');
grid on;

%% Training comparison

clc;
close all;
poc_prom = 9;
load('ANN_Imag_sit.mat');
load('ANN_Real_sit.mat');
load('ANN_dB.mat'); % Load trained networks
data = load('data_ref.csv'); % Load reference data
min_freq_train = 2;
max_freq_train = 12;

intervalStart = 6;
intervalEnd = 8;
vzorkovani = 11;

% Frequency setup for comparison
pocet_cisel = (size(data, 2) - poc_prom) / 2;
krok = (max_freq_train - min_freq_train) / (pocet_cisel - 1);
frekvence = min_freq_train:krok:max_freq_train;

% Select random design for comparison
col = randi([1, size(data, 1)]);
X = data(col, 2:8);
frekvence = frekvence(:, 1:1001);
f = frekvence(:, 1:vzorkovani:end);
interns = find(f >= min_freq_train & f <= max_freq_train);
f = (f(interns));

% Process real and imaginary parts of the data
Yr = data(col, (poc_prom + 1):(1001 + poc_prom));
Yc = data(col, (1002 + poc_prom:end));
design = X;
Ss = complex(Yr, Yc);
S2 = abs(Ss);
S_dB2 = 20 * log10(S2); % Convert to dB

% Plot real data
figure(3);
plot(frekvence, S_dB2');
grid on;
hold on;

% Simulate with ANN
design = [design, f];
predicted_S = sim(Net_db, design');

% Plot predicted data
plot(f, predicted_S');
ylabel('S11');
xlabel('frequency');
grid on;
title('S11 parameter comparison');
legend('Real', 'Predict');

% Compare max S11 values
indicesInInterval = find(frekvence >= intervalStart & frekvence <= intervalEnd);
max_real = max(S_dB2(indicesInInterval));

indicesInInterval = find(f >= intervalStart & f <= intervalEnd);
max_model = max(predicted_S(indicesInInterval));

disp(['Predikce max S11 hodnoty z ANN modelu:', num2str(max_model), 'dB']);
disp(['Predikce max S11 hodnoty z CST MWS:', num2str(max_real), 'dB']);