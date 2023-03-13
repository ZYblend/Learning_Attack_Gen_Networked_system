function [Z_attack_data,effect_index,stealth_index] = random_attack_dataset_gen(inp_size_dis,n_sim_samples,attack_percentage,policy_param,attack_type)
% generate random attack dataset for training discriminators
%
%

try
    local_var_rand = load('random_attack_data.mat');
%     sim_obj       = local_var_rand.sim_obj;
    Z_attack_data = local_var_rand.Z_attack_data;
    effect_index  = local_var_rand.effect_index;
    stealth_index = local_var_rand.stealth_index;
catch
    %% Attack data
    Z_attack_data    = rand(inp_size_dis,n_sim_samples);
    if attack_type == "ramp"
        attack_data = ramp_attack_policy(policy_param,Z_attack_data);
    elseif attack_type == "pulse"
        attack_data = pulse_attack_policy(policy_param,Z_attack_data);
    elseif attack_type == "sin"
        attack_data = sin_attack_policy(policy_param,Z_attack_data);
    end

    %% getting simulation object
    sim_obj = [];
    [sim_obj]  = get_simulation_object_sample_system(sim_obj,attack_data,attack_percentage,attack_type);
    [effect_index,stealth_index] = get_error_from_nominal(sim_obj);

    save('random_attack_data','effect_index','stealth_index','Z_attack_data','-v7.3');
end
end