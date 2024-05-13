clc; clear; close all; 

load("kick.mat")    % load data from Mr.Kick  
load('trigno.mat')  % load data from delsys trigno 

%% classes 

classes{1} = find(kick.swp_class == 0);
classes{2} = find(kick.swp_class == 1);
classes{3} = find(kick.swp_class == 2);

included_sweeps = 1:length(kick.swp_class); 

%% Align Kick and Trigno 

% Find trigger position 
x_axis = linspace(-4, 10 - 4,  20000 ); % from kick
for sweep = 1:length(included_sweeps)
    y_forceG = kick.data{sweep, kick.force_ground}; 
    threshld = mean(y_forceG(end/2:end))+ abs(mean(y_forceG(end/2:end))*0.10); 
    
    trig_positive = find(y_forceG > threshld == 1);
    trig_position_idx = trig_positive(1); % samples
    trig_position_sec(sweep) = x_axis(trig_position_idx);  % sec
end

figure; hold on 
plot(x_axis, y_forceG(:))
plot( [x_axis(trig_position_idx),x_axis(trig_position_idx)], [min(y_forceG),max(y_forceG)])

%% Acquisition Set-Up
acq = struct; % acq = acquisition

acq.sweeps = length(included_sweeps);

% frequency
acq.fs.O    = 222.222;   % Samples per second [Hz]
acq.fs.EMG  = 2148.1481; % Samples per second [Hz]
acq.fs.AG   = 370.3704;  % Samples per second [Hz]
acq.fs.Kick = 2000;      % Samples per second [Hz]

% periode dt
acq.dt.O  =  1/acq.fs.O;      % Seconds per sample [sec]
acq.dt.EMG  =  1/acq.fs.EMG;  % Seconds per sample [sec]
acq.dt.AG =  1/acq.fs.AG;     % Seconds per sample [sec]
acq.dt.Kick =  1/acq.fs.Kick; % Seconds per sample [sec]

% pre-tiggrer
acq.pre_trig.kick = 4;  % [sec]
acq.pre_trig.AG  = trig_position_sec;    % [sec]
acq.pre_trig.O   = trig_position_sec;    % [sec]
acq.pre_trig.EMG = trig_position_sec;    % [sec]

for sweep = 1:acq.sweeps
    acq.N.AG(sweep)   = length(trigno.data{sweep,trigno.left_foot_inside_IMU}(:,2));
    acq.N.O(sweep)    = length(trigno.data{sweep,trigno.left_foot_inside_quaternion}(:,2));
    acq.N.EMG(sweep)  = length(trigno.data{sweep,trigno.left_soleus}(:,2));
    acq.N.Kick(sweep) = length(kick.data{sweep,1});

    acq.time_axis.AG{sweep}   = trigno.data{sweep,trigno.left_foot_inside_IMU}(:,1) + trig_position_sec(sweep);
    acq.time_axis.ori{sweep}  = trigno.data{sweep,trigno.left_foot_inside_quaternion}(:,1) + trig_position_sec(sweep);
    acq.time_axis.EMG{sweep}  = trigno.data{sweep,trigno.left_soleus}(:,1) + trig_position_sec(sweep);
    acq.time_axis.kick{sweep} = linspace(-acq.pre_trig.kick, acq.N.Kick(sweep)*acq.dt.Kick - acq.pre_trig.kick, acq.N.Kick(sweep)); 
end


%% Degrees
 
for sweep = 1:acq.sweeps
    % ankel
    w = trigno.data{sweep, trigno.left_ankel_quaternion}(:, trigno.quat.w);
    x = trigno.data{sweep, trigno.left_ankel_quaternion}(:, trigno.quat.x);
    y = trigno.data{sweep, trigno.left_ankel_quaternion}(:, trigno.quat.y);
    z = trigno.data{sweep, trigno.left_ankel_quaternion}(:, trigno.quat.z);
    left_ankel = quaternion(w,x,y,z); 
    
    % foot
    w = trigno.data{sweep, trigno.left_foot_inside_quaternion}(:, trigno.quat.w);
    x = trigno.data{sweep, trigno.left_foot_inside_quaternion}(:, trigno.quat.x);
    y = trigno.data{sweep, trigno.left_foot_inside_quaternion}(:, trigno.quat.y);
    z = trigno.data{sweep, trigno.left_foot_inside_quaternion}(:, trigno.quat.z);
    left_shoe = quaternion(w,x,y,z); 
    
    % quaternion -> euler
    e_shoe = rad2deg(euler(left_shoe, 'ZYX', 'frame')); 
    e_ankel = rad2deg(euler(left_ankel, 'ZYX', 'frame')); 
    
    % difference
    data.left_ankel{sweep} = - e_ankel(:,2) - e_shoe(:,2); 
end

%% Find average 
offset_idx = 2000; 

for c = 1:3
    
    % Find largest start value (time) and smallest end value (time)
    first_time_value_EMG = []; last_time_value_EMG = [];     % EMG 
    first_time_value_ori = []; last_time_value_ori = [];     % Quaterion 
    for i = 1:length(classes{c})
        % EMG
        first_time_value_EMG(i) = acq.time_axis.EMG{classes{c}(i)}(1); 
        last_time_value_EMG(i)  = acq.time_axis.EMG{classes{c}(i)}(end); 
        % quaterion
        first_time_value_ori(i) = acq.time_axis.ori{classes{c}(i)}(1); 
        last_time_value_ori(i)  = acq.time_axis.ori{classes{c}(i)}(end); 
    end 
    start_time_EMG = max(first_time_value_EMG); % EMG start
    end_time_EMG = min(last_time_value_EMG);    % EMG end 
    start_time_ori = max(first_time_value_ori); % quaterion start
    end_time_ori = min(last_time_value_ori);    % quaterion end 


    % Find closest idx that match found values (time)
    closest_idx_start_EMG = []; closest_idx_end_EMG = []; % EMG
    closest_idx_start_ori = []; closest_idx_end_ori = []; % quaterion
    for i = 1:length(classes{c})
        % EMG
        [~,closest_idx_start_EMG(i)] = min(abs(acq.time_axis.EMG{classes{c}(i)}+abs(start_time_EMG)));
        [~,closest_idx_end_EMG(i)]   = min(abs(acq.time_axis.EMG{classes{c}(i)}-end_time_EMG)); 
        % quaterion
        [~,closest_idx_start_ori(i)] = min(abs(acq.time_axis.ori{classes{c}(i)}+abs(start_time_ori)));
        [~,closest_idx_end_ori(i)]   = min(abs(acq.time_axis.ori{classes{c}(i)}-end_time_ori)); 
    end 
    diff_between_EMG = []; 
    diff_between_EMG = closest_idx_end_EMG(:) - closest_idx_start_EMG(:); 
    diff_between_ori = []; 
    diff_between_ori = closest_idx_end_ori(:) - closest_idx_start_ori(:);


    %check for error
    if or((max(diff(unique(diff_between_EMG))) > 1),  numel(unique(diff_between_EMG)) > 2)
        error_message =  "Error in EMG mean. Big difference between included indexs sizes";
        errordlg(error_message , 'Error');
        error(error_message)
    end
    if or((max(diff(unique(diff_between_ori))) > 1),  numel(unique(diff_between_ori)) > 2)
        error_message =  "Error in ankel mean. Big difference between included indexs sizes";
        errordlg(error_message , 'Error');
        error(error_message)
    end


    % remove 1 sample diffrence
    for i = find(diff_between_EMG == max(diff_between_EMG))
        closest_idx_end_EMG(i) = closest_idx_end_EMG(i) - 1; 
    end 
    for i = find(diff_between_ori == max(diff_between_ori))
        closest_idx_end_ori(i) = closest_idx_end_ori(i) - 1; 
    end

    % create matrix to find mean 
    left_sol_matrix = []; left_ta_matrix = []; 
    left_palm = []; left_hell = []; 
    left_ankel_matrix = []; stair_pos = []; stair_force = []; 

    for i = 1:length(classes{c})
        % level ground
        left_sol_matrix(i,:) = abs(detrend(trigno.data{classes{c}(i),trigno.left_soleus}(closest_idx_start_EMG(i):closest_idx_end_EMG(i),2))); 
        left_ta_matrix(i,:) = abs(detrend(trigno.data{classes{c}(i),trigno.left_tibialis_anterior}(closest_idx_start_EMG(i):closest_idx_end_EMG(i),2))); 
        left_ankel_matrix(i,:) = data.left_ankel{classes{c}(i)}(closest_idx_start_ori(i):closest_idx_end_ori(i));
        
        stair_pos(i,:) = kick.data{classes{c}(i),kick.stair_pos}; 
        stair_force(i,:) = kick.data{classes{c}(i),kick.force_stair}; 

        left_palm(i,:) = kick.data{classes{c}(i),kick.FSR_palm}; 
        left_hell(i,:) = kick.data{classes{c}(i),kick.FSR_hell}; 
        left_hell(i,:) = kick.data{classes{c}(i),kick.FSR_hell}; 

    end 
    data.left_sol_class{c} = mean(left_sol_matrix,1); 
    data.left_ta_class{c} = mean(left_ta_matrix, 1);
    data.left_palm{c} = mean(left_palm,1); 
    data.left_hell{c} = mean(left_hell,1); 
    data.left_ankel_mean{c} = mean(left_ankel_matrix,1); 
    data.stair{c} = mean(stair_pos,1);
    data.stair_force{c} = mean(stair_force,1);
    
    % new time axis
    acq.time_axis.EMG_mean_class{c} = acq.time_axis.EMG{classes{c}(1)}(closest_idx_start_EMG(1):closest_idx_end_EMG(1));
    acq.time_axis.ori_mean_class{c} = acq.time_axis.ori{classes{c}(1)}(closest_idx_start_ori(1):closest_idx_end_ori(1));
end

%% plot
stair_aligned = false; 

legend_name = ["Control [n="+num2str(numel(classes{1}))+"]",...
    "100 ms unload [n="+num2str(numel(classes{2}))+"]", ...
    "200 ms unload [n="+num2str(numel(classes{3}))+"]"]; 

xlimits_ground = [-5 10]; 


figure;
hold on;

subplot(6,1,1); hold on; 
title("Left Soleus")
plot(acq.time_axis.EMG_mean_class{1}, data.left_sol_class{1}, 'Color',[0.8 0.8 0.8],'LineWidth',2) 
plot(acq.time_axis.EMG_mean_class{2}, data.left_sol_class{2}, 'Color',"red",'LineWidth',1) 
plot(acq.time_axis.EMG_mean_class{3}, data.left_sol_class{3}, 'Color',"blue",'LineWidth',1) 
xlim(xlimits_ground)
legend(legend_name); 

subplot(6,1,2); hold on; 
title("Left Tibialis Anterior")
plot(acq.time_axis.EMG_mean_class{1}, data.left_ta_class{1}, 'Color',[0.8 0.8 0.8],'LineWidth',2) 
plot(acq.time_axis.EMG_mean_class{2}, data.left_ta_class{2}, 'Color',"red",'LineWidth',1) 
plot(acq.time_axis.EMG_mean_class{3}, data.left_ta_class{3}, 'Color',"blue",'LineWidth',1) 
xlim(xlimits_ground)


subplot(6,1,3); hold on; 
title("left ankel position")
plot(acq.time_axis.ori_mean_class{1}, data.left_ankel_mean{1}, 'Color',[0.8 0.8 0.8],'LineWidth',2) 
plot(acq.time_axis.ori_mean_class{2}, data.left_ankel_mean{2}, 'Color',"red",'LineWidth',1) 
plot(acq.time_axis.ori_mean_class{3}, data.left_ankel_mean{3}, 'Color',"blue",'LineWidth',1) 
xlim(xlimits_ground)


subplot(6,1,4); hold on; 
title("Stair step position")
plot(acq.time_axis.kick{1}, data.stair{1}, 'Color',[0.8 0.8 0.8],'LineWidth',2) 
plot(acq.time_axis.kick{1}, data.stair{2}, 'Color',"red",'LineWidth',1) 
plot(acq.time_axis.kick{1}, data.stair{3}, 'Color',"blue",'LineWidth',1) 
xlim(xlimits_ground)


subplot(6,1,5); hold on; 
title("stair force [z]")
plot(acq.time_axis.kick{1}, data.stair_force{1}, 'Color',[0.8 0.8 0.8],'LineWidth',2) 
plot(acq.time_axis.kick{1}, data.stair_force{2}, 'Color',"red",'LineWidth',1) 
plot(acq.time_axis.kick{1}, data.stair_force{3}, 'Color',"blue",'LineWidth',1) 
xlim(xlimits_ground)


subplot(6,1,6); hold on; 
title("Foot switch (palm)")
plot(acq.time_axis.kick{1}, data.left_palm{1}, 'Color',[0.8 0.8 0.8],'LineWidth',2) 
plot(acq.time_axis.kick{1}, data.left_palm{2}, 'Color',"red",'LineWidth',1) 
plot(acq.time_axis.kick{1}, data.left_palm{3}, 'Color',"blue",'LineWidth',1) 
xlim(xlimits_ground)




