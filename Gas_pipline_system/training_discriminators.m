function [effect_net_trained,stealth_net_trained] = training_discriminators(effect_net,stealth_net,Z_attack_data,effect_index,stealth_index,loss_curve_param_dis1,loss_curve_param_dis2,i_epoch)
%% function [effect_net_trained,stealth_net_trained,effect_training_info,stealth_training_info] = training_discriminators(effect_net,stealth_net,Z_attack_data,effect_index,stealth_index, maxEpochs)
% train the two discriminator network (regression network) to learn the relationship from attack signal to effectiveness and stealthiness respectively
% Inputs:
%        - effect_net: the dl object
%        - stealth_net: the dl object
%        - Z_attack_data: [3-by-n_samples] training inputs (attack
%        parameters),
%        - effect_index : [1-by-n_samples] training output (effectiveness)
%        - stealth_index: [1-by-n_samples] training output (stealthiness)
%        - maxEpochs: maximum epoch number
% Outputs:
%        - effect_net_trained: updated dl object 
%        - stealth_net_trained: updated dl object
%        - effect_training_info: reference: https://www.mathworks.com/help/deeplearning/ref/trainnetwork.html#bu6sn4c-traininfo
%        - stealth_training_info: same as above
% Author: Olugbenga Moses Anubi, Florida state university
%         Yu Zheng, Florida state university
% 08/18/2022
%

%% load network
% try
%     load_nets = load("trained_network");
%     effect_net = load_nets.effect_net;
%     stealth_net = load_nets.stealth_net;
% catch
%     activation_fcns_effect = ["relu","relu","relu","linear"];
%     n_neurons_effect = [50*inp_size_dis,100*inp_size_dis,50*inp_size_dis,1];
%     effect_net = create_dl_network(inp_size_dis,activation_fcns_effect,n_neurons_effect); % Effectiveness network
% 
%     activation_fcns_stealth = ["relu","relu","relu","sigmoid"];
%     n_neurons_stealth = [50*inp_size_dis,100*inp_size_dis,50*inp_size_dis,1];
%     stealth_net = create_dl_network(inp_size_dis,activation_fcns_stealth,n_neurons_stealth);  % Stealthiness network
% end

%% effect network
% inp_size_dis = 3*n_attacked_nodes;
% activation_fcns_effect = ["relu","relu","relu","linear"];
% n_neurons_effect = [50*inp_size_dis,100*inp_size_dis,50*inp_size_dis,1];
% effect_net = create_dl_network(inp_size_dis,activation_fcns_effect,n_neurons_effect); % Effectiveness network

dataset_effect_net = {Z_attack_data,effect_index};
effect_net_trained = train_regression_network(effect_net,dataset_effect_net,loss_curve_param_dis1,i_epoch,"effect network ,");


%% stealth network
% activation_fcns_stealth = ["relu","tanh","relu","linear"];
% n_neurons_stealth = [50*inp_size_dis,100*inp_size_dis,50*inp_size_dis,1];
% stealth_net = create_dl_network(inp_size_dis,activation_fcns_stealth,n_neurons_stealth);  % Stealthiness network

dataset_stealth_net = {Z_attack_data,stealth_index};
stealth_net_trained = train_regression_network(stealth_net,dataset_stealth_net,loss_curve_param_dis2,i_epoch,"stealth network ,");


