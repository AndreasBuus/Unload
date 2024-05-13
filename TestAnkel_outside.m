clc; clear; close all; 

filefolder = struct;
filefolder.tigno = "C:/Users/BuusA/OneDrive/Documents/Delsys/Trigno Discover/Default Project/Default Subject/2024-03-26/"; 
filefolder.stair = "C:/Users/BuusA/Documents/Stair_Matlab_code";

outside = false; 

% Create 10 string that point to the tigno files

accX = 1; accY = 2; accZ = 3; 
gyroX = 4; gyroY = 5; gyroZ = 6; 

oriW = 1; oriX = 2; oriY = 3; oriZ = 4; 

data_tigno = cell(10,4); 
shoeAG = 1; 
shoeO = 2; 
ankelAG = 3;
ankelO = 4; 
time = 5; 

for sweep = 1:10
    % Calculate progress percentage
    progress = sweep / 10 * 100;
    
    % Format the progress message
    progressMessage = sprintf('%d pct', progress);
    
    % Determine the number of characters to delete
    deleteCount = numel(progressMessage) + 1; % Add 1 for space after progress
    
    % Print progress message with backspace characters to overwrite the previous line
    fprintf([repmat('\b', 1, deleteCount) '%s'], progressMessage);

    if outside == true 
        filenames = "outside Show 4 steps Redo_"+sweep+"/outside Show 4 steps Redo_"+sweep+".csv";
    else 
        filenames = "inside Show 4 steps_"+sweep+"/inside Show 4 steps_"+sweep+".csv";
    end 


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


% Load data from Mr.kick 
addpath(filefolder.stair +"/FunctionFiles")

if outside == true
    [SOL_, TA_, angle_, FSR_] = load_EMG_v2('test10step_outsideShoe.mat'); 
else 
    [SOL_, TA_, angle_, FSR_] = load_EMG_v2('test10step_insideShoe.mat'); 
end 

% Sensor abbreviation
SOL = 1; % Soleus 
TA  = 2; % Tibialis
ANG = 3; % Ankle position 
FSR = 4; % Force sensitiv resistor 

data_kick(SOL,:,:) = SOL_;      
data_kick(TA,:,:) = TA_; 
data_kick(ANG,:,:) = angle_; 
data_kick(FSR,:,:) = FSR_; 

%% Acquisition Set-Up
acquisition = struct; 

% frequency
acq.fs.O = 222.222;       % Samples per second [Hz]
acq.fs.AG    = 370.3704;  % Samples per second [Hz]
acq.fs.Kick = 2000;       % Samples per second [Hz]

% periode dt
acq.dt.O =  1/acq.fs.O;       % Samples per second [Hz]
acq.dt.AG =  1/acq.fs.AG;     % Samples per second [Hz]
acq.dt.Kick =  1/acq.fs.Kick; % Samples per second [Hz]

% pre-tiggrer
acq.pre_trig.kick = 4;  % sec
acq.pre_trig.AG = 0;    % sec
acq.pre_trig.O = 0;     % sec

for sweep = 1:10
    acq.N.AG(sweep) = length(data_tigno{sweep, shoeAG}(:,1));
    acq.N.O(sweep) = length(data_tigno{sweep, shoeO}(:,1));
    acq.N.Kick(sweep) = length(data_kick(1,sweep,:));

    acq.time_axis.AG{sweep} = linspace(acq.pre_trig.AG, acq.N.AG(sweep)*acq.dt.AG - acq.pre_trig.AG,  acq.N.AG(sweep) ); 
    acq.time_axis.O{sweep} = linspace(acq.pre_trig.O, acq.N.O(sweep)*acq.dt.O - acq.pre_trig.O, acq.N.O(sweep) ); 
    acq.time_axis.kick{sweep} = linspace(-acq.pre_trig.kick, acq.N.Kick(sweep)*acq.dt.Kick - acq.pre_trig.kick,  acq.N.Kick(sweep) ); 
end

%% Sweep
sweep = 7; 

% Ankel 
aqw = data_tigno{sweep,ankelO}(:,oriW);
aqx = data_tigno{sweep,ankelO}(:,oriX);
aqy = data_tigno{sweep,ankelO}(:,oriY);
aqz = data_tigno{sweep,ankelO}(:,oriZ);
q_ankel = quaternion(aqw,aqx,aqy,aqz); 

% Shoe
sqw = data_tigno{sweep,shoeO}(:,oriW);
sqx = data_tigno{sweep,shoeO}(:,oriX);
sqy = data_tigno{sweep,shoeO}(:,oriY);
sqz = data_tigno{sweep,shoeO}(:,oriZ);
q_shoe = quaternion(sqw,sqx,sqy,sqz); 

e_shoe = rad2deg(euler(q_shoe, 'ZYX', 'frame')); 
e_ankel = rad2deg(euler(q_ankel, 'ZYX', 'frame')); 

% Quaternion to EulerAngles
angles = struct;

% roll (x-axis rotation) - ankel
sinr_cosp = 2 * (aqw .* aqx + aqy .* aqz);
cosr_cosp = 1 - 2 * (aqx .* aqx + aqy .* aqy);
angles.a_roll = atan2(sinr_cosp, cosr_cosp);

% pitch (y-axis rotation) - ankel
sinp = sqrt(1 + 2 * (aqw .* aqy - aqx .* aqz));
cosp = sqrt(1 - 2 * (aqw .* aqy - aqx .* aqz));
angles.a_pitch = 2 * atan2(sinp, cosp) - pi / 2;

% yaw (z-axis rotation) - ankel
siny_cosp = 2 * (aqw .* aqz + aqx .* aqy);
cosy_cosp = 1 - 2 * (aqy .* aqy + aqz .* aqz);
angles.a_yaw = atan2(siny_cosp, cosy_cosp); 

% roll (x-axis rotation) - shoe
sinr_cosp = 2 * (sqw .* sqx + sqy .* sqz);
cosr_cosp = 1 - 2 * (sqx .* sqx + sqy .* sqy);
angles.s_roll = atan2(sinr_cosp, cosr_cosp);

% pitch (y-axis rotation) - shoe
sinp = sqrt(1 + 2 * (sqw .* sqy - sqx .* sqz));
cosp = sqrt(1 - 2 * (sqw .* sqy - sqx .* sqz));
angles.s_pitch = 2 * atan2(sinp, cosp) - pi / 2;

% yaw (z-axis rotation) - shoe
siny_cosp = 2 * (sqw .* sqz + sqx .* sqy);
cosy_cosp = 1 - 2 * (sqy .* sqy + sqz .* sqz);
angles.s_yaw = atan2(siny_cosp, cosy_cosp);


% Quaterion 
deg_qa_roll_1 = angles.s_roll - angles.a_roll; % Nej
deg_qa_roll_2 = angles.s_roll*-1 - angles.a_roll; % Nej
deg_qa_roll_3 = angles.s_roll - angles.a_roll*-1; % Nej
deg_qa_roll_4 = angles.s_roll*-1 - angles.a_roll*-1; % nej

X = angles.a_pitch(50:700);
Fs = acq.fs.O;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(X);             % Length of signal
t = (0:L-1)*T;        % Time vector
Y = fft(X);
figure(2); 
xlim([0 25])
plot(Fs/L*(0:L-1),abs(Y),"LineWidth",1)
title("Complex Magnitude of fft Spectrum")
xlabel("f (Hz)")
ylabel("|fft(X)|")

fc = 100;                             % Cutoff frequency for LowPass filter
order = 1;                          % Filter order 
[b,a] = butter(order,fc/(222/ 2));    % Filter coefficient
angles.a_pitch_filtered = filter(b,a, angles.a_pitch);       

deg_qa_pitch_1 = angles.s_pitch - angles.a_pitch; % Nej
deg_qa_pitch_2 = angles.s_pitch*-1 - angles.a_pitch; % Nej
deg_qa_pitch_3 = angles.s_pitch - angles.a_pitch*-1; % Nej
deg_qa_pitch_4 = angles.s_pitch*-1 - angles.a_pitch*-1; % yes!
deg_qa_pitch_4_filt = angles.s_pitch*-1 - angles.a_pitch_filtered*-1; % yes!

deg_qa_yaw_1 = angles.s_yaw - angles.a_yaw; % Nej
deg_qa_yaw_2 = angles.s_yaw*-1 - angles.a_yaw; % Nej
deg_qa_yaw_3 = angles.s_yaw - angles.a_yaw*-1; % Nej
deg_qa_yaw_4 = angles.s_yaw*-1 - angles.a_yaw*-1; % nej


%% plot

xlim1 = -0.5; 
xlim2 = 4; 

figure(1); 
subplot(211); hold on; xlim([xlim1 xlim2])
plot(acq.time_axis.kick{sweep}, rescale(squeeze(data_kick(ANG, sweep,:)),-100,50), 'color', "blue",'LineWidth',1)

t = acq.time_axis.kick{sweep}; 
[val1, idx1] = min(abs(t - xlim1)); 
[val2, idx2] = min(abs(t - xlim2)); 
y1 = -100;%min(squeeze(data_kick(ANG, sweep,idx1:idx2)));
y2 = 50;%, max(squeeze(data_kick(ANG, sweep,idx1:idx2)));

plot(acq.time_axis.O{sweep}(50:700),e_shoe(50:700,2))
plot(acq.time_axis.O{sweep}(50:700),e_ankel(50:700,2))



euldist = rad2deg(dist(q_ankel(50:700,:),q_shoe(50:700,:)));

if ~outside == true 
    y_pitch = e_ankel(50:700,2) + e_shoe(50:700,2); 
    plot(acq.time_axis.O{sweep}(50:700), rescale(y_pitch, y1, y2), 'color',"black", 'LineWidth',1)
    plot(acq.time_axis.O{sweep}(50:700), rescale(euldist, y1, y2), 'color',"red", 'LineWidth',1)
else 
    y_pitch = e_ankel(50:700,2) - e_shoe(50:700,2); 
    plot(acq.time_axis.O{sweep}(50:700), rescale(y_pitch, y1, y2), 'color',"black", 'LineWidth',1)
end

legend(["Goniometer", "Shoe", "Ankel", "Ankel - Shoe"]); 


subplot(212); hold on; xlim([xlim1 xlim2])
plot(acq.time_axis.kick{sweep}, squeeze(data_kick(FSR, sweep,:)))

%% Kalman filter 

% Create gyro and aceleromenter sim parameters 
rollTruek1 = 0.0; 
rollTruek  = 0.0; 
rollVelTrue = 0.0; 
gyroDriftTure = 1.0; 
gyroCalBiasTrure = 0.01; 
gyroSigmaNoise = 0.002; 
accelSigmaNoise = sqrt(0.03); 

accelMeask1 = 0.0; 
accelMeask = 0.0; 
gyroMeask1 = 0.0;
gyroMeask = 0.0; 

deltaT = 0.004; % Time step, 250 Hz
time = 0.0;     % Initial sim time
dataStore = zeros(5010,7);   % Data storage array

% Create complementary filter parameters

angelRollk1 = 0.0; 
angelRollk = 0.0; 

gainK1 = 0.90; % Gyro gain  
gainK2 = 0.10; % Gyro drift correction gain (via accelerometer)

% Create kalman filter parameters

xk = zeros(1,2); 
pk = [0.5 0 0 0.01]; 
k = zeros(1,2); 
ph1 = [1 deltaT 0 1];







%% build 3d object
%[verts, faces, cindex] = teapotGeometry;
% verts = verts*0.3;

% Define box edges 
footwidth = 0.6; %  % 
footheight = 0.7; % length
footlength = 0.2;

% Create box vertices 
footverts = [0 0 0; 
    footlength  0 0; 
    footlength  footheight  0; 
    0           footheight  0; 
    0           0           footwidth; 
    footlength  0           footwidth; 
    footlength  footheight  footwidth; 
    0           footheight  footwidth]; 

% Create box faces 
faces = [1 2 3 4; 2 6 7 3; 4 3 7 8; 1 5 8 4; 1 2 6 5; 5 6 7 8]; 


xlim1 = 0; 
xlim2 = 3.5; 
figure(2);
subplot(221); hold on; xlim([xlim1 xlim2])
    plot(acq.time_axis.kick{sweep}, squeeze(data_kick(ANG, sweep,:)), 'color', "blue",'LineWidth',1)
    
    y = acq.time_axis.kick{sweep}; 
    [val1, idx1] = min(abs(y - xlim1)); 
    [val2, idx2] = min(abs(y - xlim2)); 
    
    y1 = min(squeeze(data_kick(ANG, sweep,idx1:idx2)));
    y2 = max(squeeze(data_kick(ANG, sweep,idx1:idx2)));
    
    plot(acq.time_axis.O{sweep}(50:700),angles.s_pitch(50:700),0,1)
    plot(acq.time_axis.O{sweep}(50:700), angles.a_pitch(50:700))
    
    if ~outside == true 
        plot(acq.time_axis.O{sweep}(50:700), rescale(deg_qa_pitch_3(50:700), y1, y2), 'color','black', 'LineWidth',1)
    else 
        plot(acq.time_axis.O{sweep}(50:700), rescale(deg_qa_pitch_4(50:700), y1, y2), 'color',[0.8 0.8 0.8], 'LineWidth',1)
        plot(acq.time_axis.O{sweep}(50:700), rescale(deg_qa_pitch_4_filt(50:700), y1, y2), 'color','black', 'LineWidth',1)
    end

    subplot(223); hold on; xlim([-0.5 4])
    plot(acq.time_axis.kick{sweep}, squeeze(data_kick(FSR, sweep,:)))
for i = 50:700
    
    subplot(2,2,1); hold on 
    plot([acq.time_axis.O{sweep}(i),acq.time_axis.O{sweep}(i)],[-2,2], "color", [0 0 0.1 0.1])

    q_y = quaternion(cos(deg2rad(260)/2), 0, sin(deg2rad(260)/2), 0);
    q_x = quaternion(cos(deg2rad(45)/2), sin(deg2rad(45)/2), 0, 0);
    q_Z = quaternion(cos(deg2rad(90)/2), 0, 0, sin(deg2rad(90)/2));

    temp = rotatepoint(q_shoe(i,:), footverts);
    %temp = rotatepoint(q_ankel(i,:), footverts);
    temp = rotatepoint(q_y, temp);
    temp = rotatepoint(q_x, temp);
    vertfoot = rotatepoint(q_Z, temp);
    subplot(2,2,[2,4])
    if i > 50
         cla(p)
    end
    p = patch('Vertices', vertfoot, 'Faces', faces, 'FaceColor','red');  

    xlim([-1 1])
    ylim([-1 1])
    zlim([-1 1])
    
    view([1 -0.1 1]);

    pause(acq.dt.O) 
end 

%%



