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


%% attacked real plot
subplot(2,2,1);
plot(y_time,y_data(:,1),'k-',LineWidth=LW);
% ylim([0 15])
ylabel('p_1');
hold on, yline(p_eq(1),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

subplot(2,2,2);
plot(y_time,y_data(:,2),'k-',LineWidth=LW);
% ylim([0 15])
ylabel('p_2');
hold on, yline(p_eq(2),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

subplot(2,2,3);
plot(y_time,y_data(:,3),'k-',LineWidth=LW);
% ylim([0 20])
ylabel('p_3');
hold on, yline(p_eq(3),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

subplot(2,2,4);
plot(y_time,y_data(:,4),'k-',LineWidth=LW);
% ylim([0 20])
ylabel('p_4');
hold on, yline(p_eq(4),'r--',LineWidth=LW);
grid on
set(gca,"FontSize",12)

figure
plot(out.residual.Time, out.residual.Data,'k-',LineWidth=LW);
hold on, yline(thresh_1,'r--',LineWidth=LW);
title('BDD Residual')
set(gca,"FontSize",12)

