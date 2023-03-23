%% plot test performance of trained networks
close all
clear all
clc

%% define hyperparameters
attack_percentage = 1;
% choose network topology: linear, tree, cyclic
topology = "linear";

Run_sim;
n_epoch = 5;
tot_test = 180;

thresh_1 = 0.02;  % threshold for stealthiness
thresh_2 = 65;  % threshold for effectivness
thresholds = [thresh_1,thresh_2];

%% Testing trained networks
stealth_epoch = zeros(tot_test,n_epoch);
effect_epoch = zeros(tot_test,n_epoch);

for i_epoch = 1:n_epoch
    % load trained networks
    dir_net_inter = "networks/"+num2str(length(attack_indices))+"/"+num2str(attack_indices)+"/trained_network_Epoch"+num2str(i_epoch)+".mat";
    load_nets = load(dir_net_inter);
    gen_net = load_nets.gen_net;
    effect_net = load_nets.effect_net;
    stealth_net = load_nets.stealth_net;

    % test with simulation
%     n_test = round(tot_test/nchoosek(n_meas,n_attacked_nodes));
    [test_score_dis,test_score_sim,~,~,stealth_epoch(:,i_epoch), effect_epoch(:,i_epoch)] = Performance_evaluation(gen_net,stealth_net,effect_net,thresholds,tot_test,attack_percentage,policy_param,topology,false);
    disp("Testing score with discriminators = " + num2str(test_score_dis) )
    disp("Testing score with model simualtion = " + num2str(test_score_sim))

end

%% plotting
figure
subplot(1,2,1)
yline(thresh_1,'k')
hold on, boxplot(stealth_epoch);
xlabel('Epoch')
ylabel('Stealthiness')
subplot(1,2,2)
yline(thresh_2,'k')
hold on, boxplot(effect_epoch)
xlabel('Epoch')
ylabel('Effectiveness')

save('test_performance.mat','effect_epoch','stealth_epoch','-v7.3');


