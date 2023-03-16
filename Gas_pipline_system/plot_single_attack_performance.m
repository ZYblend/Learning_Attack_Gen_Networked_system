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
if topology == "linear"
    model = "pipline_system_linear";
elseif topology == "tree"
    model = "pipline_system_tree";
elseif topology == "cyclic"
    model = "pipline_system_cyclic";
end
out = sim(model);

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
for idx = 1:n-1
    subplot(round((n-1)/2),2,idx);
    plot(y_time,y_data(:,idx),'k-',LineWidth=LW);
    labelname = "p_"+num2str(idx);
    ylabel(labelname);
    hold on, yline(p_eq(idx),'r--',LineWidth=LW);
    grid on
    set(gca,"FontSize",12)
    ylim([6,80])
end

figure
plot(out.residual.Time, out.residual.Data,'k-',LineWidth=LW);
hold on, yline(thresh_1,'r--',LineWidth=LW);
title('BDD Residual')
set(gca,"FontSize",12)

save('time_series_test_data.mat','attack_data','z_attack_data','attack_start_times','attack_full_times','attack_final_deviations','out','-v7.3')

