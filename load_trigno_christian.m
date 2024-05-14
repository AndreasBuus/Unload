clc; clear; close all;

filefolder = struct;
filefolder.tigno = "C:/Users/BuusA/OneDrive/Documents/Delsys/Trigno Discover/Unload/Christian/2024-05-07"; 

filename = "/trial3__"; 

% variables 
trigno = struct; 

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

% sensor names
trigno.l_sol = 1; 
trigno.l_ta = 2; 
trigno.r_sol = 3; 
trigno.r_ta = 4; 
trigno.l_shoe = 5; 
trigno.l_ankel = 6; 
trigno.l_shoe_imu = 7; 
trigno.head_imu = 8; 
trigno.l_qf = 9; 
trigno.l_bf = 10; 
trigno.l_thigh = 11; 


% Exclude sweeps;
sweeps_recorded = 1:103; 
excluded_sweeps = [21]; 
sweeps_recorded(excluded_sweeps) = [];


for i = 1:length(sweeps_recorded)

    % Print progress message with backspace characters to overwrite the previous line
    progress = round(i / length(sweeps_recorded) * 100);                 % Calculate progress percentage
    progressMessage = sprintf('%d pct', progress);      % Format the progress message
    deleteCount = numel(progressMessage) + 1; %         % Determine the number of characters to delete 
    fprintf([repmat('\b', 1, deleteCount) '%s'], progressMessage);

    filenames = filename + sweeps_recorded(i) + filename+sweeps_recorded(i)+".csv";
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
    trigno.data{i, trigno.l_shoe}  = data(~y_qua, 9+[2,3,5,7,9]);
    trigno.data{i, trigno.l_ankel} = data(~y_qua, 19+[2,3,5,7,9]);
    trigno.data{i, trigno.l_thigh} = data(~y_qua, 57+[2,3,5,7,9]);

    % Store IMU
    clear x_imu y_imu
    x_imu = data(:, 21); 
    y_imu = isnan(x_imu(:,1));     % identify non-nan files
    trigno.data{i, trigno.l_shoe_imu} = data(~y_imu, 29+[0,1:2:11]);
    trigno.data{i, trigno.head_imu}   = data(~y_imu, 41+[0,1:2:11]);

    % Store EMG data
    clear x_emg y_emg
    x_emg = data(:, 33); 
    y_emg = isnan(x_emg(:,1));     % identify non-nan files
    trigno.data{i,trigno.l_sol} = data(~y_emg, 1+[0,1]); 
    trigno.data{i,trigno.l_ta}  = data(~y_emg, 3+[0,1]); 
    trigno.data{i,trigno.r_sol} = data(~y_emg, 5+[0,1]); 
    trigno.data{i,trigno.r_ta}  = data(~y_emg, 7+[0,1]); 
    trigno.data{i,trigno.l_qf}  = data(~y_emg, 53+[0,1]); 
    trigno.data{i,trigno.l_bf}  = data(~y_emg, 55+[0,1]); 


end 

deleteCount = numel(progressMessage) + 1; %         % Determine the number of characters to delete 
fprintf([repmat('\b', 1, deleteCount) '%s'], "done");

save('trigno_christian_data', "trigno")


