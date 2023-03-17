%% plot attack performance

clc
clear
close all

% detector_train_flag = 0;
% attack_percentage = 1;
% Run_sim;
% choose network topology: linear, tree, cyclic
topology = "linear";

%% get a generated attack
load('attack_support.mat');
if topology == "linear"
    load('test_performance/12/1   2   3   4   5   6   7   8   9  10  11  12/test_result.mat');
elseif topology == "tree"
    load('test_performance/14/1   2   3   4   5   6   7   8   9  10  11  12  13  14/test_result.mat');
elseif topology == "cyclic"
    load('test_performance/16/1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16/test_result.mat');
end


%% define hyperparameters
thresh_1 = 0.025;  % threshold for stealthiness
thresh_2 = 55;  % threshold for effectivness

attack_percentage = 1;


%% test
% z_attack_data = Z_attack_data(:,51);  % lowest detection probability
% plot_single_attack_performance;

index_low_detect = find(effect_index == max(effect_index));
z_attack_data = Z_attack_data(:,index_low_detect);  % highest detection probability 
plot_single_attack_performance;

% index_high_effect = find(effect_index == max(effect_index));
% z_attack_data = Z_attack_data(:,index_high_effect);  % highest effectiveness 
% plot_single_attack_performance;
% 
% index_low_effect = find(effect_index == min(effect_index));
% z_attack_data = Z_attack_data(:,index_low_effect);  % lowest effectiveness 
% plot_single_attack_performance;









