clc; clear; close all;

filefolder = struct;
%filefolder.tigno = "C:/Users/BuusA/Documents/Delsys/Trigno Discover/unload_50and350/Pegah/2024-05-01/"; 
filefolder.tigno = "D:/Delsys/Trigno Discover/unload_50and350/Pegah/2024-05-01/";
% variables 
trigno = struct; 

trigno.names.sensors = ["left_foot_QUA", ...
    "left_ankel_QUA", ... 
    "left_shoe_IMU", ... 
    "left_soleus_EMG", ...
    "left_tibialis_anterior_EMG", ...
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

% Kinomatik sensors
trigno.left_foot_quaternion = 1; 
trigno.left_ankel_quaternion = 2; 
trigno.left_foot_IMU = 3; 

% EMG sensors
trigno.left_soleus = 4; 
trigno.left_tibialis_anterior = 5; 

% Head sensor
trigno.head_IMU = 6; 
 
% Exclude sweeps;
sweeps_recorded = 1:105; 
excluded_sweeps = [12,22,42,43,44]; 
sweeps_recorded(excluded_sweeps) = []; 


for i = 1:length(sweeps_recorded)

    % Print progress message with backspace characters to overwrite the previous line
    progress = round(i / length(sweeps_recorded) * 100);                 % Calculate progress percentage
    progressMessage = sprintf('%d pct', progress);      % Format the progress message
    deleteCount = numel(progressMessage) + 1; %         % Determine the number of characters to delete 
    fprintf([repmat('\b', 1, deleteCount) '%s'], progressMessage);

    filenames = "test9__"+sweeps_recorded(i)+"/test9__"+sweeps_recorded(i)+".csv";
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
    
    
    % Store quaterion
    clear x_qua y_qua
    x_qua = data(:, 3); 
    y_qua = isnan(x_qua(:,1));     % identify non-nan files
    trigno.data{i, trigno.left_foot_quaternion}  = data(~y_qua, 1+[2,3,5,7,9]);
    trigno.data{i, trigno.left_ankel_quaternion} = data(~y_qua, 11+[2,3,5,7,9]);

    % Store IMU
    clear x_imu y_imu
    x_imu = data(:, 21); 
    y_imu = isnan(x_imu(:,1));     % identify non-nan files
    trigno.data{i, trigno.left_foot_IMU}         = data(~y_imu, 21+[0,1:2:11]);
    trigno.data{i, trigno.head_IMU}              = data(~y_imu, 37+[0,1:2:11]);

    % Store EMG data
    clear x_emg y_emg
    x_emg = data(:, 33); 
    y_emg = isnan(x_emg(:,1));     % identify non-nan files
    trigno.data{i,trigno.left_soleus}            = data(~y_emg, 33+[0,1]); 
    trigno.data{i,trigno.left_tibialis_anterior} = data(~y_emg, 35+[0,1]); 

end 
deleteCount = numel(progressMessage) + 1; %         % Determine the number of characters to delete 
fprintf([repmat('\b', 1, deleteCount) '%s'], "done");


%save('trigno_pegah_105', "trigno")
