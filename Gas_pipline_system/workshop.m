function workshop(attack_percentage,topology)
% clc
% clear
% close all

%% load system base parameters
Run_sim;

%% global training parameters
n_epoch         = 5;

generate_generator_data_flag = true;
n_random_sim_samples = 2000;  % Number of random attack dataset per epoch used to train descriminators
n_generator_sim_sample = round(n_random_sim_samples);

%% Initialize Generator network
alpha = 0.8;  % probability of success
% beta  = 1 - alpha;

thresh_1 = 0.025;  % threshold for stealthiness
thresh_2 = 55;  % threshold for effectivness
thresholds = [thresh_1,thresh_2];


inp_size = 10;
out_size = 3*n_attacked_nodes;  % dimension of smallest Eucliden space containing set S.

try
    load_nets = load("trained_network");
    gen_net = load_nets.gen_net;
    effect_net = load_nets.effect_net;
    stealth_net = load_nets.stealth_net;
catch
    activation_fcns_gen = ["relu","relu","tanh","sigmoid"];
    n_neurons_gen = [50*inp_size,100*inp_size,50*inp_size,out_size];
    gen_net = create_dl_network(inp_size,activation_fcns_gen,n_neurons_gen); % generator network

    inp_size_dis = out_size;
    activation_fcns_effect = ["relu","relu","relu","linear"];
    n_neurons_effect = [50*inp_size_dis,100*inp_size_dis,50*inp_size_dis,1];
    effect_net = create_dl_network(inp_size_dis,activation_fcns_effect,n_neurons_effect); % Effectiveness network

    activation_fcns_stealth = ["relu","relu","relu","linear"];
    n_neurons_stealth = [50*inp_size_dis,100*inp_size_dis,50*inp_size_dis,1];
    stealth_net = create_dl_network(inp_size_dis,activation_fcns_stealth,n_neurons_stealth); % stealthiness network
end
inp_size_dis = out_size;

%% loss curve Plot routine
loss_fig_gen = figure;
C = colororder;
genLossTrain = animatedline(Color=C(2,:));
ylim([0 inf])
xlabel("Iteration")
ylabel("Loss")
grid on


loss_fig_dis1 = figure;
dis1LossTrain = animatedline(Color=C(2,:));
ylim([0 inf])
xlabel("Iteration")
ylabel("Loss")
title('Effect net')
grid on

loss_fig_dis2 = figure;
dis2LossTrain = animatedline(Color=C(2,:));
ylim([0 inf])
xlabel("Iteration")
title('Stealth net')
ylabel("Loss")
grid on

start = tic;
loss_curve_param_gen = {loss_fig_gen,genLossTrain,start};
loss_curve_param_dis1 = {loss_fig_dis1,dis1LossTrain,start};
loss_curve_param_dis2 = {loss_fig_dis2,dis2LossTrain,start};

 %%% random attack dataset 
[Z_attack_data_rand,effect_index_rand,stealth_index_rand] = random_attack_dataset_gen(n_attacked_nodes,n_random_sim_samples,attack_percentage,policy_param,topology);
cache_dir_rand = "training_dataset/"+ num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/random_attack_data.mat" ;
save(cache_dir_rand, 'effect_index_rand','stealth_index_rand','Z_attack_data_rand','-v7.3');

%% Training
for i_epoch = 1:n_epoch
    %% prepare attack dataset for discriminator training
    %%% generator attack dataset
    cache_dir_gen = "training_dataset/"+ num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/generator_attack_data_epoch" + num2str(i_epoch) +".mat";
    try
        local_var_gen = load(cache_dir_gen);
        Z_attack_data_gen = local_var_gen.Z_attack_data_gen;
        effect_index_gen  = local_var_gen.effect_index_gen;
        stealth_index_gen = local_var_gen.stealth_index_gen;
    catch
        [Z_attack_data_gen,effect_index_gen,stealth_index_gen] = generator_attack_dataset_gen(gen_net,generate_generator_data_flag,inp_size,n_generator_sim_sample,attack_percentage,policy_param,topology);
        save(cache_dir_gen, 'effect_index_gen','stealth_index_gen','Z_attack_data_gen','-v7.3');
    end

    %%% compose training dataset for discriminator
%     sim_obj = [sim_obj_rand;sim_obj_gen];
    Z_attack_data = dlarray([Z_attack_data_rand,Z_attack_data_gen],'CB');
    effect_index = dlarray([effect_index_rand;effect_index_gen].','CB');
    stealth_index = dlarray([stealth_index_rand;stealth_index_gen].','CB');
    
%     save('sim_sample_system_data','sim_obj','effect_index','stealth_index','Z_attack_data','-v7.3');

    %% Train Discriminator network
    [effect_net,stealth_net] = training_discriminators(effect_net,stealth_net,Z_attack_data,effect_index,stealth_index,loss_curve_param_dis1,loss_curve_param_dis2,i_epoch);

    %% Training Generator with adam
    gen_net = training_generator(i_epoch,gen_net,stealth_net,effect_net,alpha,thresholds,loss_curve_param_gen);

    %% save intermediate networks
    dir_net_inter = "networks/"+num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/trained_network_Epoch"+num2str(i_epoch)+".mat";
    save(dir_net_inter,'gen_net','stealth_net','effect_net','-v7.3');

end

%% save discriminators' trainig loss curve
figure(loss_fig_dis1);
dir_dis1 = "training_performance/"+ num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/Dis1_loss_curve.fig";
savefig(dir_dis1)
figure(loss_fig_dis2);
dir_dis2 = "training_performance/"+ num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/Dis2_loss_curve.fig";
savefig(dir_dis2)

%% Testing performance
dir_net = "test_performance/"+num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/trained_network.mat";
save(dir_net,'gen_net','stealth_net','effect_net','-v7.3');

tot_test = 6000;
n_test = round(tot_test/nchoosek(n_meas,n_attacked_nodes));
[test_score_dis,test_score_sim,~,~,~,~] = Performance_evaluation(gen_net,stealth_net,effect_net,thresholds,n_test,attack_percentage,policy_param,topology,true);
disp("Testing score with discriminators = " + num2str(test_score_dis) + " ::: Target = " + num2str(alpha))
disp("Testing score with model simualtion = " + num2str(test_score_sim) + " ::: Target = " + num2str(alpha))

keyboard