%% plot test performance of trained networks
close all
clear all
clc

attack_percentage = 1;

% choose attack policy
% "ramp", "pulse", "sin"
attack_type = "pulse";

Run_sim;
n_epoch = 10;
tot_test = 1000;

if attack_type == "ramp"
    thresh_1 = 0.05;  % threshold for stealthiness
    thresh_2 = 0.04;  % threshold for effectivness
elseif attack_type == "sin"  || attack_type =="pulse"
    thresh_1 = 0.05;  % threshold for stealthiness
    thresh_2 = 0.02;  % threshold for effectivness
end
thresholds = [thresh_1,thresh_2];


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
    [test_score_dis,test_score_sim,~,~,stealth_epoch(:,i_epoch), effect_epoch(:,i_epoch)] = Performance_evaluation(gen_net,stealth_net,effect_net,thresholds,tot_test,attack_percentage,policy_param,attack_type,false);
    disp("Testing score with discriminators = " + num2str(test_score_dis) )
    disp("Testing score with model simualtion = " + num2str(test_score_sim))

end

% withour train
random_test;

effect_index = effect_index/max(vecnorm(yc_nominal,2,2));
effect_epoch = effect_epoch/max(vecnorm(yc_nominal,2,2));

%% plot
% epoch_ax = linspace(0,n_epoch,n_epoch+1);

figure
subplot(1,2,1)
yline(thresh_1,'k')
stealth = [stealth_index(1:1000),stealth_epoch];
hold on, boxplot(stealth);
xlabel('Epoch')
ylabel('Stealthiness')
subplot(1,2,2)
yline(thresh_2/max(vecnorm(yc_nominal,2,2)),'k')
effect = [effect_index(1:1000),effect_epoch];
hold on, boxplot(effect);
xlabel('Epoch')
ylabel('Effectiveness')
ylim([0,0.5])




