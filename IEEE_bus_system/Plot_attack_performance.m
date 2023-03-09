%% plot attack performance

clc
clear
close all

% detector_train_flag = 0;
% attack_percentage = 1;
% Run_sim;

%% get a generated attack
load('attack_support.mat');
load('test_performance/19/1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19/test_result.mat');
thresh_1 = 0.02;  % threshold for stealthiness
thresh_2 = 0.025;  % threshold for effectivness

%% test
% z_attack_data = Z_attack_data(:,51);  
% plot_single_attack_performance;

index_high_effect = find(effect_index == max(effect_index));
z_attack_data = Z_attack_data(:,index_high_effect);  % highest effectiveness probability 
plot_single_attack_performance;










