% clear 
% clc
% 
addpath('pipeline_system');

%% Simulation parameters
t_sim_stop = 200;  % total simulation time per incidence

%% system param
run_pipeline_system;

% attack location
% attack_percentage = 1.0;
n_attacked_nodes = round(attack_percentage*n_meas); % number of attacked nodes
try % make sure the attack support not change during a training process
    attack_indices = load('attack_support.mat').attack_indices;
catch
    attack_indices = sort(randperm(n_meas,n_attacked_nodes));  % inidices of nodes to attack;
    save attack_support.mat attack_indices
end

% attack policy parameters
attack_start_time_interval  = round([0.1 0.2]*t_sim_stop);
attack_time_span_max_rate   = 0.5;
attack_max = 0.5;
policy_param = {attack_start_time_interval, attack_time_span_max_rate, attack_max, t_sim_stop};

% getting nominal values
model = "pipline_system";
out = sim(model);


yc_nominal = out.critical_measurement.Data;
yc_nominal = reshape(yc_nominal,size(yc_nominal,1),size(yc_nominal,3)).';
r_nominal = out.residual.Data;

% save('nominal_index.mat','yc_nominal','r_nominal','-v7.3')



