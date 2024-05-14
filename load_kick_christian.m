clc; clear; close all; 

% Load data
var = load('christian_unload'); % Load data 

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

kick.names.sensors = ["FSR_palm", ...
    "FSR_hell", ...
    "FSR_hell", ...
    "force_stair", ...
    "trig_stair", ...
    "pos_stair", ...
    "trig_level", ...
    "force_level"]; 

%kick.data = cell(var.Nsweep, length(kick.names.sensors));

% subject
kick.FSR_palm = 2; 
kick.FSR_hell = 3;

% stair
kick.force_stair = 4;
kick.trig_stair = 6;
kick.pos_stair = 9;

% level
kick.trig_level = 5;
kick.force_level = 1; 

% Exclude sweeps;
recorded_swp = 1:var.Nsweep; 
excluded_swp = [21]; 
recorded_swp(excluded_swp) = []; 


for i = 1:length(recorded_swp)

    data_kick = var.(data_varStr(recorded_swp(i))); 
    kick.swp_class(i) = var.(info_varStr(recorded_swp(i)))(3);

    % subject
    kick.data{i,kick.FSR_palm}      = data_kick(:, kick.FSR_palm);         
    kick.data{i,kick.FSR_hell}      = data_kick(:, kick.FSR_hell); 
    
    % stair
    kick.data{i,kick.force_stair}   = data_kick(:, kick.force_stair); 
    kick.data{i,kick.trig_stair}    = data_kick(:, kick.trig_stair);
    kick.data{i,kick.pos_stair}     = data_kick(:, kick.pos_stair); 

    % level
    kick.data{i,kick.trig_level}    = data_kick(:, kick.trig_level);
    kick.data{i,kick.force_level}    = data_kick(:, kick.force_level);

end 

disp("Done")
save('kick_christian', "kick")



