% clear 
% clc
% 
addpath('bus_system');

%% system param
run_bus_system;

%% Simulation parameters
t_sim_stop = T_final;  % total simulation time per incidence

% attack location
% attack_percentage = 1.0;
n_attacked_nodes = round(attack_percentage*n_meas); % number of attacked nodes
try % make sure the attack support not change during a training process
    attack_indices = load('attack_support.mat').attack_indices;
catch
    attack_indices = sort(randperm(n_meas,n_attacked_nodes));  % inidices of nodes to attack;
    save attack_support.mat attack_indices
end

% % attack policy parameters (for ramp, pulse attack)
if attack_type == "ramp"
    attack_start_time_interval  = round([0.1 0.2]*t_sim_stop);
    attack_time_span_max_rate   = 0.5;
    attack_max = 0.03;
    policy_param = {attack_start_time_interval, attack_time_span_max_rate, attack_max, t_sim_stop};
elseif attack_type =="pulse"
    attack_start_time_interval  = round([0.1 0.2]*t_sim_stop);
    attack_time_span_max_rate   = 1;
    a_attack_interval = [-0.04 0.04];
    b_attack_interval = [-5, 5];
    policy_param = {attack_start_time_interval, attack_time_span_max_rate, a_attack_interval, b_attack_interval, t_sim_stop};
elseif attack_type == "sin"
    % (for sin attack)
    attack_start_time_interval  = round([0.1 0.2]*t_sim_stop);
    attack_time_span_max_rate   = 1;
    a_attack_interval = [-0.05 0.05];
    b_attack_interval = [-5, 5];
    policy_param = {attack_start_time_interval, attack_time_span_max_rate, a_attack_interval, b_attack_interval, t_sim_stop};
end

% getting nominal values
model = "bus_system";
out = sim(model);


yc_nominal = out.critical_measurement.Data;
r_nominal = out.residual.Data;

% save('nominal_index.mat','yc_nominal','r_nominal','-v7.3')



