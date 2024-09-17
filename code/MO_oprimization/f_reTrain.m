function [Net_db] = f_reTrain(data, frekvence, nvars, vzorkovani)
    % Initialize the number of variables
    poc_prom = nvars;

    % Split the data into X and Y for real numbers
    X = data(:, 2:8);

    % Limit frequency vector to 1001 values
    frekvence = frekvence(:, 1:1001);

    % Save every 11th value from the frequency vector
    f = frekvence(:, 1:vzorkovani:end);

    % Duplicate the frequency matrix using repmat
    freq = repmat(f, size(X, 1), 1);
    X = [X, freq];

    % Set the target Mean Squared Error (MSE) threshold
    targetMSE = 1.5;

    % Extract the real and imaginary parts from the dataset
    Yr = data(:, (poc_prom + 1):(1001 + poc_prom));
    Yc = data(:, (1002 + poc_prom:end));

    % Combine real and imaginary parts into complex numbers
    Ss = complex(Yr, Yc);

    % Convert to magnitude values
    S2 = abs(Ss);

    % Convert to dB scale
    Ss_dB2 = 20 * log10(S2);

    % Sample every 11th value for Y output
    Yv = Ss_dB2(:, 1:vzorkovani:end);
    Y = Yv;

    % Define the network architecture using Bayesian regularization
    hiddenLayerSize = [50, 30, 20]; % Number of neurons in hidden layers
    net = feedforwardnet(hiddenLayerSize, 'trainbr'); % 'trainbr' supports Bayesian regularization
    net.trainParam.epochs = 30; % Number of training epochs
    net.trainParam.showWindow = true; % Show the training progress window

    % Set performance function and Bayesian regularization
    net.performFcn = 'mse'; % Performance function (mean squared error)
    net.performParam.regularization = 0.01; % Regularization coefficient (experiment with this value)

    % Split data into training and testing sets
    percentTraining = 80; % Percentage of data for training
    net.divideParam.trainRatio = percentTraining / 100;
    net.divideParam.testRatio = (100 - percentTraining) / 100;

    % Train the neural network
    net = train(net, X', Y');

    % Validate the trained network
    Y_pred = net(X');
    MSE = mse(Y' - Y_pred);

    % Save the trained network model
    Net_db = net;
    save('ANN_dB.mat', 'Net_db');

    % Display the Mean Squared Error on the validation dataset
    disp(['MSE on the validation dataset: ', num2str(MSE)]);
end