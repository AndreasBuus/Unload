clc; clear; close all; 

% Load data
var = load('perturbation.mat'); % Load data 

% Create string array to call data from 'var'
emg_varStr = strings(1,var.Nsweep);        % Preallocation
data_varStr = strings(1,var.Nsweep);       % Preallocation

for i = 1:9
    emg_varStr(i) = "dath00" + i;
    data_varStr(i) = "datl00" + i;
    info_varStr(i) = "swp00" + i; 
end
for i = 10:99
    emg_varStr(i) = "dath0" + i;
    data_varStr(i) = "datl0" + i;
    info_varStr(i) = "swp0" + i; 
end 
for i = 100:var.Nsweep
    emg_varStr(i) = "dath" + i;
    data_varStr(i) = "datl" + i;
    info_varStr(i) = "swp" + i; 
end

kick = struct;

kick.names.sensors = ["force_ground", ...
    "FSR_palm", ...
    "FSR_hell", ...
    "force_stair", ...
    "stair_trig", ...
    "stair_pos"]; 


kick.force_ground = 1; 
kick.FSR_palm = 2; 
kick.FSR_hell = 3;
kick.force_stair = 4;
kick.stair_trig = 5;
kick.stair_pos = 6; 

% Exclude sweeps
included_sweeps = 1:var.Nsweep; 
excluded_sweeps = [12, 23];             % sweeps to be exlcuded
included_sweeps(excluded_sweeps) = [];  % exclude sweeps 

for i = 1:length(included_sweeps)
    data_kick = var.(data_varStr(included_sweeps(i))); 
    kick.swp_class(i) = var.(info_varStr(included_sweeps(i)))(3);
    
    kick.data{i,kick.force_ground}  = data_kick(:, 1); 
    kick.data{i,kick.FSR_palm}      = data_kick(:, 2);         
    kick.data{i,kick.FSR_hell}      = data_kick(:, 3); 
    kick.data{i,kick.force_stair}   = data_kick(:, 4); 
    kick.data{i,kick.stair_trig}    = data_kick(:, 5);
    kick.data{i,kick.stair_pos}     = data_kick(:, 9); 
end 

disp("done")
save('kick', "kick")