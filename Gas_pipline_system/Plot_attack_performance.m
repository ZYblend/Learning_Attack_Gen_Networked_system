%% plot attack performance

clc
clear
close all

% detector_train_flag = 0;
% attack_percentage = 1;
% Run_sim;

%% get a generated attack
load('attack_support.mat');
load('test_performance/7/1  2  3  4  5  6  7/test_result.mat');
thresh_1 = 0.2;  % threshold for stealthiness
thresh_2 = 10;  % threshold for effectivness


%% test
z_attack_data = Z_attack_data(:,51);  % lowest detection probability
plot_single_attack_performance;

index_low_detect = find(stealth_index == min(stealth_index));
z_attack_data = Z_attack_data(:,index_low_detect);  % highest detection probability 
plot_single_attack_performance;

% index_high_effect = find(effect_index == max(effect_index));
% z_attack_data = Z_attack_data(:,index_high_effect);  % highest effectiveness 
% plot_single_attack_performance;
% 
% index_low_effect = find(effect_index == min(effect_index));
% z_attack_data = Z_attack_data(:,index_low_effect);  % lowest effectiveness 
% plot_single_attack_performance;









