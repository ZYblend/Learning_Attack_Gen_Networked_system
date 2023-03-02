attack_percentage = 1;
Run_sim;

attack_data = ramp_attack_policy(policy_param,z_attack_data);

% define attack parameters in simulation
attack_start_times      = attack_start_injection*ones(n_meas,1);
attack_full_times       = attack_start_times +  100;
attack_final_deviations = zeros(n_meas,1);

attack_start_times(attack_indices)      = attack_data(1:n_attacked_nodes);
attack_full_times(attack_indices)       = attack_start_times(attack_indices) + attack_data(n_attacked_nodes+1:2*n_attacked_nodes);
attack_final_deviations(attack_indices) = attack_data(2*n_attacked_nodes+1:3*n_attacked_nodes);

%% run simulation
out = sim("pipline_system.slx");

y = out.critical_measurement;
y_time = y.Time;
y_data = reshape(y.Data,size(y.Data,1),size(y.Data,3)).';

ya = out.attacked_measurement;
ya_time = ya.Time;
ya_data = reshape(ya.Data,size(ya.Data,1),size(ya.Data,3)).';
ya_data = ya_data(:,1:n);

y_nominal = yc_nominal;


%% plot results
LW = 1.5;
FS = 1.5;
figure

%% nominal plot
subplot(4,3,1);
plot(y_time,y_nominal(:,1),'k-',LineWidth=LW);
ylabel('p_1',FontSize=FS);
title('Nominal measurements');
hold on, yline(p_eq(1),'r--',LineWidth=LW);
% ylim([0 15])
grid on
set(gca,"FontSize",12)

subplot(4,3,4);
plot(y_time,y_nominal(:,2),'k-',LineWidth=LW);
ylabel('p_2',FontSize=FS);
hold on, yline(p_eq(2),'r--',LineWidth=LW);
% ylim([0 15])
grid on
set(gca,"FontSize",12)

subplot(4,3,7);
plot(y_time,y_nominal(:,3),'k-',LineWidth=LW);
ylabel('p_3',FontSize=FS);
% ylim([0 20])
grid on
hold on, yline(p_eq(3),'r--',LineWidth=LW);
set(gca,"FontSize",12)

subplot(4,3,10);
plot(y_time,y_nominal(:,4),'k-',LineWidth=LW);
ylabel('p_4',FontSize=FS);
% ylim([0 20])
grid on
hold on, yline(p_eq(4),'r--',LineWidth=LW);
set(gca,"FontSize",12)

%% attacked real plot
subplot(4,3,2);
plot(y_time,y_data(:,1),'k-',LineWidth=LW);
title('Real measurements')
% ylim([0 15])
hold on, yline(p_eq(1),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

subplot(4,3,5);
plot(y_time,y_data(:,2),'k-',LineWidth=LW);
% ylim([0 15])
hold on, yline(p_eq(2),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

subplot(4,3,8);
plot(y_time,y_data(:,3),'k-',LineWidth=LW);
% ylim([0 20])
hold on, yline(p_eq(3),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

subplot(4,3,11);
plot(y_time,y_data(:,4),'k-',LineWidth=LW);
% ylim([0 20])
hold on, yline(p_eq(4),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

%% attacked real plot
subplot(4,3,3);
plot(ya_time,ya_data(:,1),'k-',LineWidth=LW);
title('Attacked measurements');
hold on, yline(p_eq(1),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

% subplot(4,3,6);
% plot(ya_time(ya_time>detection_start),ya_data(ya_time>detection_start,2),'k-',LineWidth=LW);
% ylim([0 1.5])
% subplot(4,3,9);
% plot(ya_time(ya_time>detection_start),ya_data(ya_time>detection_start,3),'k-',LineWidth=LW);
% ylim([0 0.6])
subplot(4,3,6);
plot(ya_time,ya_data(:,2),'k-',LineWidth=LW);
hold on, yline(p_eq(2),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

subplot(4,3,9);
plot(ya_time,ya_data(:,3),'k-',LineWidth=LW);
hold on, yline(p_eq(3),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

subplot(4,3,12);
plot(ya_time,ya_data(:,4),'k-',LineWidth=LW);
hold on, yline(p_eq(4),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)