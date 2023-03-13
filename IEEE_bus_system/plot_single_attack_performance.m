attack_percentage = 1;
Run_sim;

% define attack parameters in simulation
if attack_type == "ramp" || attack_type == "pulse"
    if attack_type == "ramp"
        attack_data = ramp_attack_policy(policy_param,z_attack_data);
    elseif attack_type == "pulse"
        attack_data = pulse_attack_policy(policy_param,z_attack_data);
    end
    % for ramp and pulse attack
    attack_start_times      = attack_start_injection*ones(n_meas,1);
    attack_full_times       = attack_start_times +  100;
    attack_final_deviations = zeros(n_meas,1);
    
    attack_start_times(attack_indices)      = attack_data(1:n_attacked_nodes);
    attack_full_times(attack_indices)       = attack_start_times(attack_indices) + attack_data(n_attacked_nodes+1:2*n_attacked_nodes);
    attack_final_deviations(attack_indices) = attack_data(2*n_attacked_nodes+1:3*n_attacked_nodes);
elseif attack_type == "sin"
    attack_data = sin_attack_policy(policy_param,z_attack_data);
    % for sin attack
    attack_start_times      = attack_start_injection*ones(n_meas,1);
    attack_full_times       = attack_start_times +  100;
    attack_final_deviations = zeros(n_meas,2);
    
    attack_start_times(attack_indices)      = attack_data(1:n_attacked_nodes);
    attack_full_times(attack_indices)       = attack_start_times(attack_indices) + attack_data(n_attacked_nodes+1:2*n_attacked_nodes);
    attack_final_deviations(attack_indices,1) = attack_data(2*n_attacked_nodes+1:3*n_attacked_nodes);
    attack_final_deviations(attack_indices,2) = attack_data(3*n_attacked_nodes+1:4*n_attacked_nodes);
end

%% run simulation
out = sim("bus_system.slx");

%%
y = out.critical_measurement;
y_time = y.Time;
y_data = y.Data;

ya = out.attacked_measurement;
ya_time = ya.Time;
ya_data = ya.Data;
% ya_data = ya_data(:,1:n);

y_nominal = yc_nominal;


%% plot results
LW = 1.5;
FS = 1.5;
figure

%% attacked real plot
figure
for iter = 1:5
    subplot(5,1,iter);
    plot(y_time,y_data(:,iter),'r-',LineWidth=LW);
    hold on, plot(y_time,y_nominal(:,iter),'k--',LineWidth=LW);
    legend('Attacked','Nominal')
    grid on
    label_name = "\theta_"+num2str(iter);
    ylabel(label_name);
    set(gca,"FontSize",12)
end
title_name = "Effectiveness ="+num2str(100*effect_index(index_high_effect)/max(vecnorm(yc_nominal,2,2)))+"%";
sgtitle(title_name);
set(gca,"FontSize",12)

% BDD
figure
plot(out.residual.Time, out.residual.Data,'k-',LineWidth=LW);
hold on, yline(thresh_1,'r--',LineWidth=LW);
title('BDD Residual')
set(gca,"FontSize",12)

