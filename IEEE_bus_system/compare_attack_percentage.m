%% Compare different attack percentage
clear all
clc

%% Train generators for different attack percentage
Attack_percentage = linspace(0.05,0.95,18);
n_meas = 19;
tot_iter = 10;
Attack_indices = cell(n_meas,tot_iter);
for idx_attack = 1:n_meas
    for n_iter = 1:tot_iter
        delete("random_attack_data.mat");
        delete("test_result.mat");
        % create corresponding folders
        folder_name1 = "training_dataset/"+num2str(idx_attack);
        mkdir(folder_name1);
        folder_name2 = "training_performance/"+num2str(idx_attack);
        mkdir(folder_name2);
        folder_name3 = "test_performance/"+num2str(idx_attack);
        mkdir(folder_name3);
        folder_name4 = "networks/"+num2str(idx_attack);
        mkdir(folder_name4);
    
        % choose a random attack support
        delete('attack_support.mat');
        attack_percentage = Attack_percentage(idx_attack);
        Run_sim;
    
        % create corresponding subfolder
        subfolder1 = folder_name1 + "/" +num2str(attack_indices);
        mkdir(subfolder1);
        subfolder2 = folder_name2 + "/" +num2str(attack_indices);
        mkdir(subfolder2);
        subfolder3 = folder_name3 + "/" +num2str(attack_indices);
        mkdir(subfolder3);
        subfolder4 = folder_name4 + "/" +num2str(attack_indices);
        mkdir(subfolder4);
    
        % save attack_support
        Attack_indices{idx_attack,n_iter} = attack_indices;
    
        % Train generator and test
        workshop(attack_percentage);
    end
end
save('all_attack_support.mat', 'Attack_indices', '-v7.3');

%% test trained networks
Attack_percentage = linspace(0.05,1,19);
thresh_1 = 0.02;  % threshold for stealthiness
thresh_2 = 0.025;  % threshold for effectivness
thresholds = [thresh_1,thresh_2];

all_attack_support = load('all_attack_support.mat').Attack_indices;
[tot_iter1,tot_iter2] = size(all_attack_support);

tot_test = 1000;
stealth_epoch = zeros(tot_test,tot_iter2);
effect_epoch = zeros(tot_test,tot_iter2);

stealth_index = cell(1,tot_iter1);
effect_index = cell(1,tot_iter1);

for iter1 = 1:tot_iter1
    attack_percentage = Attack_percentage(iter1);
    for iter2 = 1:tot_iter2
        attack_indices = all_attack_support{iter1,iter2};
        save attack_support.mat attack_indices;
        Run_sim;
        % load trained networks
        dir_net_inter = "networks/"+num2str(iter1)+"/"+num2str(all_attack_support{iter1,iter2})+"/trained_network_Epoch5.mat";
        load_nets = load(dir_net_inter);
        gen_net = load_nets.gen_net;
        effect_net = load_nets.effect_net;
        stealth_net = load_nets.stealth_net;

        % test
        [test_score_dis,test_score_sim,~,~,stealth_epoch(:,iter2), effect_epoch(:,iter2)] = Performance_evaluation(gen_net,stealth_net,effect_net,thresholds,tot_test,attack_percentage,policy_param,false);
        disp("Testing score with discriminators = " + num2str(test_score_dis) )
        disp("Testing score with model simualtion = " + num2str(test_score_sim))

    end
    stealth_index{1,iter1} = stealth_epoch;
    effect_index{1,iter1} = effect_epoch;
end

%% plotting
figure
subplot(1,2,1)
yline(thresh_1,'k')
stealth = zeros(tot_iter1,tot_iter2*tot_test);
for iter3 = 1:tot_iter1
    stealth_percentage = stealth_index{1,iter3};
    stealth(iter3,:) = stealth_percentage(:);
end
hold on, boxplot(stealth.');
xlabel('Num of Attacks')
ylabel('Stealthiness')
ylim([0,0.025])

subplot(1,2,2)
yline(thresh_2,'k')
effect = zeros(tot_iter1,tot_iter2*tot_test);
for iter4 = 1:tot_iter1
    effect_percentage = effect_index{1,iter4};
    effect(iter4,:) = effect_percentage(:);
end
hold on, boxplot(effect.');
xlabel('Num of Attacks')
ylabel('Effectiveness')
ylim([0.01,0.03])
