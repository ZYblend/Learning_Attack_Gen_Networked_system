%% test generator

% initialization
detector_train_flag = 0;
Run_sim;

% prepare inputs, generate attack policy's inputs
inp_size = gen_net.Layers(1, 1).InputSize;

Z_test        = rand(inp_size,n_test,"single");   % uniformly random noise as input
Z_tet_dlarray = dlarray(Z_test,"CB");  

test_out = double(forward(gen_net,Z_tet_dlarray));

% testing
Z_attack_data = double(extractdata(test_out));
attack_data = ramp_attack_policy(policy_param,Z_attack_data);

sim_obj = [];

[sim_obj]  = get_simulation_object_sample_system(sim_obj,attack_data);
[effect_index,stealth_index] = get_error_from_nominal(sim_obj);


%% calculate score, save data
f1_out = stealth_index - thresh_1;
f2_out = thresh_2 - effect_index;
test_score_sim = sum((f1_out<=0) & (f2_out<=0))/n_test;

test_result = [effect_index,stealth_index];

