% Simulace Anteny, kde lze v prvním FORu rozmítat velikosti anteny, 
clear all;
results = {};
tic;
clc;

% existující data z 'vysledky.mat' načtěte prvně, pokud existují
csvFileName = 'data_ver1.csv';

% kolik chceš provést simulací (SUDÁ ČÍSLA)
iter = 200;
% f_rez?
frez = 5;

i = 0;
dW = 0.5;               
dL = 0.5;
hsub = 1.6;
p = 1;
c0 = 299792458; 

x = 5; 
% x = (c0/((frez+0.757)*1e9)/4)*1e3;
W = (2*x + 2* dW);
W2 = W/2;
Lt = 1.5*x-dL+0.3;
L = 2*x+Lt+dL;
R = x/4;
Rr = x/2.225; 
G = Lt - p;
scyl = Lt + x - 0.2; 
siner = Lt+x-Rr-0.2;
sr = Lt+x-R-0.2+0.4;
w0 = 1.7 / 2; 
wcop = W / 2 + w0;
nwcop = W / 2 -w0;
Rpin = 0.39;
k = 6.86;
pport = (W/2) + w0 + (k*hsub); 
nport = (W/2) - w0 - (k*hsub);
hport = hsub + k*hsub;

%Start code
CST = CST_MicrowaveStudio(cd,'Antenna_orig.cst');
CST.setSolver('time');

%Vlozit promenne do CST
CST.addParameter('Lt',Lt);
CST.addParameter('dW',dW);
CST.addParameter('dL',dL);
CST.addParameter('x',x);
CST.addParameter('W',W);
CST.addParameter('L',L);
CST.addParameter('h_sub',hsub);
CST.addParameter('wcop',wcop);
CST.addParameter('nwcop',nwcop);
CST.addParameter('G',G);
CST.addParameter('W2',W2);
CST.addParameter('scyl',scyl);
CST.addParameter('siner',siner);
CST.addParameter('sr',sr);
CST.addParameter('Rr',Rr);
CST.addParameter('R',R);
CST.addParameter('pport',pport);
CST.addParameter('nport',nport);
CST.addParameter('hport',hport);


% Add material
CST.addNormalMaterial('dielectric',4.0,1,[0.8 0.1 0]);

% Build a structure
CST.addBrick({0 'W'},{0 'L'},{0 'h_sub'},'substrate','component1','dielectric');

% coplanar
CST.addBrick({'nwcop', 'wcop'},{0 'Lt'},{'h_sub' 'h_sub'},'trace','component1','PEC');

% Create big cylinder with ofset to up
CST.addCylinder('x',0,'z',{'W2'},{'scyl'},{'h_sub' 'h_sub'},'round','component1','PEC');

% Create biger hole 
CST.addCylinder('Rr',0,'z',{'W2'},{'siner'},{'h_sub' 'h_sub'},'space','component1','Vacuum');

% Create notch
CST.addCylinder('R',0,'z',{'W2'},{'sr'},{'h_sub' 'h_sub'},'notch','component1','PEC');
% CST substact 
insertObject(CST,'component1:round','component1:space')
insertObject(CST,'component1:trace','component1:space')
% GND_up
CST.addBrick({0 'W'},{0 'G'},{0 0},'GND_up','component1','PEC');

% Nastavení freq a pridaní portu
CST.addWaveguidePort('ymin',{'nport' 'pport'},{0 'L'},{0 'hport'});
CST.setFreq(2,15); 

% CST.runSimulation 
% [freq,S] = CST.getSParameters('S11');
% S_dB = 20 * log10(abs(S));

% Inicializace prázdných polí pro uchování intervalů a hodnot S11
intervals = [];
S11 = [];

% Kod pro vypocet GAINu

% CST.addFieldMonitor('farfield',frez)
% Retrieve the Farfield and plot
% theta = 0:5:180;
% phi = 0:5:360;
% [Etheta_am] = CST.getFarField(num2str(frez),theta,phi,'units','gain');
% Gain = max(max(Etheta_am))

 
% začátek simulaci pro více iterací START
for (i = 1:iter)
    
    % Inicializace prázdného pole pro uchování intervalů
    intervals = [];
    new_freq = [];
    freq = [];
    
    
    frez = 5.5;
    x = unifrnd(5,12);
    R = unifrnd((x/6),(x/2.2));
    Rr = x/2.225;
    Lt = unifrnd(5,15);
    p = unifrnd(0.1,2);
    dW = unifrnd(0.3,1);
    dL = unifrnd(0.3,1);
    wpasek = unifrnd(1,2);

    % recalculate
    hsub = 1.6;
    c0 = 299792458; 
    W = (2*x + 2* dW);
    W2 = W/2;
    L = 2*x+Lt+dL;
    w0 = wpasek / 2; 
    wcop = W / 2 + w0;
    nwcop = W / 2 -w0;
    G = Lt - p;
    scyl = Lt + x - 0.2; 
    siner = Lt+x-Rr-0.2;
    sr = Lt+x-R-0.2+0.4;
    k = 6.86;
    pport = (W/2) + w0 + (k*hsub); 
    nport = (W/2) - w0 - (k*hsub);
    hport = hsub + k*hsub;

    CST.setUpdateStatus(false)
    %Vlozit promenne do CST
    CST.changeParameterValue('Lt',Lt);
    CST.changeParameterValue('dW',dW);
    CST.changeParameterValue('dL',dL);
    CST.changeParameterValue('x',x);
    CST.changeParameterValue('W',W);
    CST.changeParameterValue('L',L);
    CST.changeParameterValue('h_sub',hsub);
    CST.changeParameterValue('wcop',wcop);
    CST.changeParameterValue('nwcop',nwcop);
    CST.changeParameterValue('G',G);
    CST.changeParameterValue('W2',W2);
    CST.changeParameterValue('scyl',scyl);
    CST.changeParameterValue('siner',siner);
    CST.changeParameterValue('sr',sr);
    CST.changeParameterValue('Rr',Rr);
    CST.changeParameterValue('R',R);
    CST.changeParameterValue('pport',pport);
    CST.changeParameterValue('nport',nport);
    CST.changeParameterValue('hport',hport);
    
    CST.parameterUpdate
    
    CST.setUpdateStatus(true)
    CST.addFieldMonitor('farfield',frez)
   
    CST.runSimulation   

%     Získání nových hodnot S11
%     [freq,S] = CST.getSParameters('S11',i);
    [freq,S] = CST.getSParameters('S11');
    S_dB = 20 * log10(abs(S));

%     Retrieve the Farfield and plot
%     theta = 0:5:180;
%     phi = 0:5:360;
%     [Etheta_am] = CST.getFarField(num2str(frez),theta,phi,'units','gain');
%     Gain = max(max(Etheta_am));
    Gain = 0;
    
%     Přidání resultRow do cell array výsledků
    resultRow = [   ];
    resultRow = [p, x, Lt, R, Rr, dL, dW, wpasek];
    resultRow = [resultRow, S];
    results{i} = resultRow;
    SP(i,:) = S_dB;
    i

%     Open the CSV file for appending
    fileID = fopen(csvFileName, 'a');
%     Write the data to the file for this iteration
    fprintf(fileID, '%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,%.15f,%.15f', p, x, Lt, R, Rr, dL, dW, wpasek);
    fprintf(fileID, ',%.15f,%.15f', real(S), imag(S));
    fprintf(fileID, '\n');
%     Close the file for this iteration
    fclose(fileID);
end

time = toc/60
% plot s11 for all runs
% figure; hold on; ylabel('S-parameter (dB)'); xlabel('Frequency (GHz)'); grid on;
% L = plot(freq,SP);


CST.save;
CST.closeProject;
close all;