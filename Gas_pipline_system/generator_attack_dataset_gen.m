function [Z_attack_data,effect_index,stealth_index] = generator_attack_dataset_gen(gen_net,generate_data_flag,inp_size,n_sim_samples,attack_percentage,policy_param,topology)
%% function [sim_obj,Z_attack_data,effect_index,stealth_index] = generator_attack_dataset_gen(gen_net,i_epoch,generate_data_flag,inp_size,n_sim_samples,t_sim_stop)
% Description
%

if generate_data_flag == true
    %%% Attack data
    Z_train         = rand(inp_size,n_sim_samples,"single");   % uniformly random noise as input
    Z_train_dlarray = dlarray(Z_train,"CB");                     % covert to dlarray
    
    Z_attack_data = double(extractdata(forward(gen_net,Z_train_dlarray)));
    attack_data   = ramp_attack_policy(policy_param,Z_attack_data);

    % getting simulation object
    sim_obj = [];
    [sim_obj]  = get_simulation_object_sample_system(sim_obj,attack_data,attack_percentage,topology);
    [effect_index,stealth_index] = get_error_from_nominal(sim_obj);

%     save('generator_attack_data','effect_index','stealth_index','Z_attack_data','-v7.3');
    

else
    local_var_gen = load('generator_attack_data.mat');
%     sim_obj       = local_var_gen.sim_obj;
    Z_attack_data = local_var_gen.Z_attack_data;
    effect_index  = local_var_gen.effect_index;
    stealth_index = local_var_gen.stealth_index;
end