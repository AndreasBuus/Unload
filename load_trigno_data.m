clc; clear; close all;

filefolder = struct;
filefolder.tigno = "C:/Users/BuusA/Documents/Delsys/Trigno Discover/Unload_test/Andreas/2024-04-15/"; 

% variables 
trigno = struct; 

trigno.names.sensors = ["left_soleus", ...
    "Left_tibialis_anterior", ...
    "rigth_soleus", ...
    "right_tibialis", ...
    "left_foot_inside_IMU", ...
    "left_foot_inside_quaternion", ...
    "left_foot_outside_quaternion", ...
    "left_ankel_quaternion", ...
    "right_foot_outside_IMU", ...
    "right_ankel_quaternion", ...
    "right_foot_inside_quaternion", ...
    "head_IMU"]; 

trigno.names.IMU = ["time (s)", "acc x (G)", "acc y (G)", "acc z (G) ", "gyro X (deg/s)", "gyroY (deg/s)", "gyroZ (deg/s)"]; 
trigno.names.quaternion = ["time (s)", "oriW (Quaternion)", "oriX (Quaternion)", "oriY (Quaternion)","oriZ (Quaternion)" ]; 
trigno.names.EMG = ["time (s)", "EMG (mV)"]; 

trigno.time = 1; 

% Accelerometer
trigno.acc.x = 2; 
trigno.acc.y = 3;
trigno.acc.z = 4;

% Gyro
trigno.gyro.x = 5; 
trigno.gyro.y = 6; 
trigno.gyro.z = 7;

% Quaternion
trigno.quat.w = 2; 
trigno.quat.x = 3; 
trigno.quat.y = 4; 
trigno.quat.z = 5; 

% EMG sensors
trigno.left_soleus = 1; 
trigno.left_tibialis_anterior = 2; 
trigno.rigth_soleus = 3; 
trigno.right_tibialis = 4; 

% Left sensors
trigno.left_foot_inside_IMU = 5; 
trigno.left_foot_inside_quaternion = 6; 
trigno.left_foot_outside_quaternion = 7;
trigno.left_ankel_quaternion = 8; 

% Right sensors
trigno.right_foot_outside_IMU = 9; 
trigno.right_ankel_quaternion = 10; 
trigno.right_foot_inside_quaternion = 11; 

% Head sensor
trigno.head_IMU = 12; 


% Exclude sweeps
sweeps_recorded = 1:23; 
excluded_sweeps = [12, 23];          % sweeps to be exlcuded
sweeps_recorded(excluded_sweeps) = [];        % excluded sweeps are marked as 0


for i = 1:length(sweeps_recorded)

    % Print progress message with backspace characters to overwrite the previous line
    progress = round(i / length(sweeps_recorded) * 100);                 % Calculate progress percentage
    progressMessage = sprintf('%d pct', progress);      % Format the progress message
    deleteCount = numel(progressMessage) + 1; %         % Determine the number of characters to delete 
    fprintf([repmat('\b', 1, deleteCount) '%s'], progressMessage);

    filenames = "trial_"+sweeps_recorded(i)+"/trial_"+sweeps_recorded(i)+".csv";
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
    trigno.data{i,trigno.left_soleus}            = data(~y_emg, 1:2); 
    trigno.data{i,trigno.left_tibialis_anterior} = data(~y_emg, 3:4); 
    trigno.data{i,trigno.rigth_soleus}           = data(~y_emg, 5:6); 
    trigno.data{i,trigno.right_tibialis}         = data(~y_emg, 7:8); 
    
    % Store IMU
    trigno.data{i, trigno.left_foot_inside_IMU}    = data(~y_imu, [9,10:2:20]);
    trigno.data{i, trigno.right_foot_outside_IMU}  = data(~y_imu, [51,52:2:62]);
    trigno.data{i, trigno.head_IMU}                = data(~y_imu, [83,84:2:94]);
    
    % Store quaterion
    trigno.data{i, trigno.left_foot_inside_quaternion}     = data(~y_qua, [23,24:2:30]);
    trigno.data{i, trigno.left_foot_outside_quaternion}    = data(~y_qua, [33,34:2:40]);
    trigno.data{i, trigno.left_ankel_quaternion}           = data(~y_qua, [43,44:2:50]);
    trigno.data{i, trigno.right_ankel_quaternion}          = data(~y_qua, [65,66:2:72]);
    trigno.data{i, trigno.right_foot_inside_quaternion}    = data(~y_qua, [75,76:2:82]);
end 
deleteCount = numel(progressMessage) + 1; %         % Determine the number of characters to delete 
fprintf([repmat('\b', 1, deleteCount) '%s'], "done");


save('trigno', "trigno")
