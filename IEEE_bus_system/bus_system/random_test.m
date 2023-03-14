%% random test
% This file is used to 
% clear all
% clc

attack_percentage = 1;

% choose attack policy
% "ramp", "pulse", "sin"
attack_type = "pulse";

Run_sim;
N_test = 2000;

if attack_type == "ramp"
    Z_attack_data = rand(3*n_attacked_nodes,N_test);
    attack_data = ramp_attack_policy(policy_param,Z_attack_data);
elseif attack_type == "pulse"
    Z_attack_data = rand(4*n_attacked_nodes,N_test);
    attack_data = pulse_attack_policy(policy_param,Z_attack_data);
elseif attack_type == "sin"
    Z_attack_data = rand(4*n_attacked_nodes,N_test);
    attack_data = sin_attack_policy(policy_param,Z_attack_data);
end

sim_obj = [];

[sim_obj]  = get_simulation_object_sample_system(sim_obj,attack_data,attack_percentage,attack_type);
[effect_index,stealth_index] = get_error_from_nominal(sim_obj);

%%
figure,
subplot(121)
hold on, plot(stealth_index,'.')
title("Stealthiness")
set(gca,'FontSize',12)
subplot(122)
nominal_index = load("nominal_index.mat");
yc_nominal = nominal_index.yc_nominal;
hold on, plot(effect_index,'.')
title("Effectiveness")
set(gca,'FontSize',12)

