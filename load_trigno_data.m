clc; clear; close all;

filefolder = struct;
filefolder.tigno = "C:/Users/BuusA/Documents/Delsys/Trigno Discover/Unload_test/Andreas/2024-04-15/"; 


left_soleus = 1; 
Left_tibialis_anterior = 2; 
rigth_soleus = 3; 
right_tibialis = 4; 

left_foot_inside_IMU = 5; 
left_foot_inside_quaternion = 6; 
left_foot_outside_quaternion = 7;



% accX = 1; accY = 2; accZ = 3; 
% gyroX = 4; gyroY = 5; gyroZ = 6; 
% 
% oriW = 1; oriX = 2; oriY = 3; oriZ = 4; 
% 
% data_tigno = cell(10,4); 
% shoeAG = 1; 
% shoeO = 2; 
% ankelAG = 3;
% ankelO = 4; 
% time = 5; 

sweep = 1; 
filenames = "trial_"+sweep+"/trial_"+sweep+".csv";
filepath = filefolder.tigno + filenames; 

clear  opts
opts = detectImportOptions(filepath);
opts.VariableNamingRule = 'preserve'; 
opts.DataLines = [8, inf]; 
numVariables = length(opts.VariableNames);
namesVariables = opts.VariableNames; 
opts.VariableTypes = repmat("double", 1 , numVariables);
opts = setvaropts(opts, 1:numVariables, "DecimalSeparator",".");
data_tabel = readtable(filepath, opts); 
data = table2array(data_tabel); 

% Identify nan values 
clear x_emg y_emg
x_emg = data(:, 1); 
y_emg = isnan(x_emg(:,1)); 

clear x_imu y_imu
x_imu = data(:, 9); 
y_imu = isnan(x_imu(:,1)); 

clear x_qua y_qua
x_qua = data(:, 23); 
y_qua = isnan(x_qua(:,1)); 

% Store EMG data
data_trigno{sweep,left_soleus}            = data(~y_emg, 1:2); 
data_trigno{sweep,Left_tibialis_anterior} = data(~y_emg, 3:4); 
data_trigno{sweep,rigth_soleus}           = data(~y_emg, 5:6); 
data_trigno{sweep,right_tibialis}         = data(~y_emg, 7:8); 

% Store IMU
data_trigno{sweep, left_foot_inside_IMU}  = data(~y_imu, [9,10:2:20]);

% Store quaterion
data_trigno{sweep, left_foot_inside_quaternion}  = data(~y_qua, [23,24:2:30]);
data_trigno{sweep, left_foot_outside_quaternion}  = data(~y_qua, [33,34:2:40]);





%%

for sweep = 1:23

    % Print progress message with backspace characters to overwrite the previous line
    progress = sweep / 10 * 100;                        % Calculate progress percentage
    progressMessage = sprintf('%d pct', progress);      % Format the progress message
    deleteCount = numel(progressMessage) + 1; %         % Determine the number of characters to delete 
    fprintf([repmat('\b', 1, deleteCount) '%s'], progressMessage);

    filenames = "trial_"+sweep+"/trial_"+sweep+".csv";


    filepath = filefolder.tigno + filenames; 

    clear  opts
    opts = detectImportOptions(filepath);
    opts.VariableNamingRule = 'preserve'; 
    opts.Delimiter = ";";
    opts.DataLines = [8, inf]; 
    numVariables = length(opts.VariableNames);
    opts.VariableTypes = repmat("double", 1 , numVariables);
    opts = setvaropts(opts, 1:numVariables, "DecimalSeparator",",");
    %opts.MissingRule = "omitrow";
    %getvaropts(opts,'Shoe1_81205_')
    data_tabel = readtable(filepath, opts); 

    data = table2array(data_tabel);
    
    data_tigno 

    clear x y
    x = data(:, 16); 
    y = isnan(x(:,1)); 

    data_tigno{sweep,shoeAG}  = data(~y, 2:2:12); 
    data_tigno{sweep,ankelAG} = data(~y, 24:2:34); 

    clear x y
    x = data(:, 16); 
    y = isnan(x(:,1)); 

    data_tigno{sweep,shoeO}   = data(~y, 16:2:22); 
    data_tigno{sweep,ankelO}  = data(~y, 38:2:44); 
end 
