clc; clear; close all;

filefolder = struct;
filefolder.tigno = "C:/Users/BuusA/Documents/Delsys/Trigno Discover/Unload_test/Andreas/2024-04-15/"; 

% variables 
var = struct; 

var.names.sensors = ["left_soleus", ...
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

var.names.IMU = ["time (s)", "acc x (G)", "acc y (G)", "acc z (G) ", "gyro X (deg/s)", "gyroY (deg/s)", "gyroZ (deg/s)"]; 
var.names.quaternion = ["time (s)", "oriW (Quaternion)", "oriX (Quaternion)", "oriY (Quaternion)","oriZ (Quaternion)" ]; 
var.names.EMG = ["time (s)", "EMG (mV)"]; 

var.time = 1; 

% Accelerometer
var.acc.x = 2; 
var.acc.y = 3;
var.acc.z = 4;

% Gyro
var.gyro.x = 5; 
var.gyro.y = 6; 
var.gyro.z = 7;

% Quaternion
var.quat.w = 2; 
var.quat.x = 3; 
var.quat.y = 4; 
var.quat.z = 5; 


% EMG sensors
var.left_soleus = 1; 
var.Left_tibialis_anterior = 2; 
var.rigth_soleus = 3; 
var.right_tibialis = 4; 

% Left sensors
var.left_foot_inside_IMU = 5; 
var.left_foot_inside_quaternion = 6; 
var.left_foot_outside_quaternion = 7;
var.left_ankel_quaternion = 8; 

% Right sensors
var.right_foot_outside_IMU = 9; 
var.right_ankel_quaternion = 10; 
var.right_foot_inside_quaternion = 11; 

% Head sensor
var.head_IMU = 12; 

for sweep = 1:23

    % Print progress message with backspace characters to overwrite the previous line
    progress = round(sweep / 23 * 100);                 % Calculate progress percentage
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
    var.trigno{sweep,var.left_soleus}            = data(~y_emg, 1:2); 
    var.trigno{sweep,var.Left_tibialis_anterior} = data(~y_emg, 3:4); 
    var.trigno{sweep,var.rigth_soleus}           = data(~y_emg, 5:6); 
    var.trigno{sweep,var.right_tibialis}         = data(~y_emg, 7:8); 
    
    % Store IMU
    var.trigno{sweep, var.left_foot_inside_IMU}    = data(~y_imu, [9,10:2:20]);
    var.trigno{sweep, var.right_foot_outside_IMU}  = data(~y_imu, [51,52:2:62]);
    var.trigno{sweep, var.head_IMU}                = data(~y_imu, [83,84:2:94]);
    
    % Store quaterion
    var.trigno{sweep, var.left_foot_inside_quaternion}     = data(~y_qua, [23,24:2:30]);
    var.trigno{sweep, var.left_foot_outside_quaternion}    = data(~y_qua, [33,34:2:40]);
    var.trigno{sweep, var.left_ankel_quaternion}           = data(~y_qua, [43,44:2:50]);
    var.trigno{sweep, var.right_ankel_quaternion}          = data(~y_qua, [65,66:2:72]);
    var.trigno{sweep, var.right_foot_inside_quaternion}    = data(~y_qua, [75,76:2:82]);
end 
deleteCount = numel(progressMessage) + 1; %         % Determine the number of characters to delete 
fprintf([repmat('\b', 1, deleteCount) '%s'], "done");


save('var')