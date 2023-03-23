function [Z_attack_data,effect_index,stealth_index] = random_attack_dataset_gen(n_attacked_nodes,n_sim_samples,attack_percentage,policy_param,topology)
%% function [sim_obj,Z_attack_data,effect_index,stealth_index] = random_attack_dataset_gen(generate_data_flag,n_attacked_nodes,n_sim_samples,t_sim_stop)
% generate random attack dataset for training discriminators
%
%
%% Attack data
Z_attack_data    = rand(3*n_attacked_nodes,n_sim_samples);
attack_data = ramp_attack_policy(policy_param,Z_attack_data);

%% getting simulation object
sim_obj = [];
[sim_obj]  = get_simulation_object_sample_system(sim_obj,attack_data,attack_percentage,topology);
[effect_index,stealth_index] = get_error_from_nominal(sim_obj);

end