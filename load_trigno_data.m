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
left_ankel_quaternion = 8; 

right_foot_outside_IMU = 9; 
right_ankel_quaternion = 10; 
right_foot_inside_quaternion = 11; 

head_IMU = 12; 

for sweep = 1:23

    % Print progress message with backspace characters to overwrite the previous line
    progress = round(sweep / 23 * 100);                        % Calculate progress percentage
    progressMessage = sprintf('%d pct', progress);      % Format the progress message
    deleteCount = numel(progressMessage) + 1; %         % Determine the number of characters to delete 
    fprintf([repmat('\b', 1, deleteCount) '%s'], progressMessage);

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
    data_trigno{sweep, left_foot_inside_IMU}    = data(~y_imu, [9,10:2:20]);
    data_trigno{sweep, right_foot_outside_IMU}  = data(~y_imu, [51,52:2:62]);
    data_trigno{sweep, head_IMU}                = data(~y_imu, [83,84:2:94]);
    
    % Store quaterion
    data_trigno{sweep, left_foot_inside_quaternion}     = data(~y_qua, [23,24:2:30]);
    data_trigno{sweep, left_foot_outside_quaternion}    = data(~y_qua, [33,34:2:40]);
    data_trigno{sweep, left_ankel_quaternion}           = data(~y_qua, [43,44:2:50]);
    data_trigno{sweep, right_ankel_quaternion}          = data(~y_qua, [65,66:2:72]);
    data_trigno{sweep, right_foot_inside_quaternion}    = data(~y_qua, [75,76:2:82]);
end 
deleteCount = numel(progressMessage) + 1; %         % Determine the number of characters to delete 
fprintf([repmat('\b', 1, deleteCount) '%s'], "done");

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
