%% plot attack performance

clc
clear
close all

% detector_train_flag = 0;
% attack_percentage = 1;
% Run_sim;

%% get a generated attack
load('attack_support.mat');
load('test_result.mat');
index_high_detect = find(stealth_index == max(stealth_index));
z_attack_data = Z_attack_data(:,index_high_detect);  % highest detection probability 
plot_single_attack_performance;

index_low_detect = find(stealth_index == min(stealth_index));
z_attack_data = Z_attack_data(:,index_low_detect);  % lowest detection probability
plot_single_attack_performance;

index_high_effect = find(effect_index == max(effect_index));
z_attack_data = Z_attack_data(:,index_high_effect);  % highest effectiveness 
plot_single_attack_performance;

index_low_effect = find(effect_index == min(effect_index));
z_attack_data = Z_attack_data(:,index_low_effect);  % lowest effectiveness 
plot_single_attack_performance;

figure (1)
sgtitle(['Highest detection probability, effect = ', num2str(effect_index(index_high_detect)),', detection prob =', num2str(stealth_index(index_high_detect))]);
figure (2)
sgtitle(['lowest detection probability, effect = ', num2str(effect_index(index_low_detect)),', detection prob =', num2str(stealth_index(index_low_detect))]);
figure (3)
sgtitle(['Highest effectiveness, effect = ', num2str(effect_index(index_high_effect)),', detection prob =', num2str(stealth_index(index_high_effect))]);
figure (4)
sgtitle(['lowest effectiveness, effect = ', num2str(effect_index(index_low_effect)),', detection prob =', num2str(stealth_index(index_low_effect))]);








