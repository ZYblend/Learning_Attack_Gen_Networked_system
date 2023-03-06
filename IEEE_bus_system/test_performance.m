%% plot test performance of trained networks
close all
clear all
clc

attack_percentage = 1;
Run_sim;
n_epoch = 10;
tot_test = 100;

thresh_1 = 0.5;  % threshold for stealthiness
thresh_2 = 0.8;  % threshold for effectivness
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
    n_test = round(tot_test/nchoosek(n_meas,n_attacked_nodes));
    [test_score_dis,test_score_sim,~,~,stealth_epoch(:,i_epoch), effect_epoch(:,i_epoch)] = Performance_evaluation(gen_net,stealth_net,effect_net,thresholds,n_test,attack_percentage,policy_param,false);
    disp("Testing score with discriminators = " + num2str(test_score_dis) )
    disp("Testing score with model simualtion = " + num2str(test_score_sim))

end

%% plot
epoch_ax = linspace(1,n_epoch,n_epoch);

figure
subplot(1,2,1)
yline(thresh_1,'k')
hold on, boxplot([stealth_epoch(:,1),stealth_epoch(:,2),stealth_epoch(:,3),stealth_epoch(:,4),stealth_epoch(:,5)],'Notch','on','Labels',{'1','2','3','4','5'});
xlabel('Epoch')
ylabel('Stealthiness')
subplot(1,2,2)
yline(thresh_2,'k')
hold on, boxplot([effect_epoch(:,1),effect_epoch(:,2),effect_epoch(:,3),effect_epoch(:,4),effect_epoch(:,5)],'Notch','on','Labels',{'1','2','3','4','5'})
xlabel('Epoch')
ylabel('Effectiveness')




