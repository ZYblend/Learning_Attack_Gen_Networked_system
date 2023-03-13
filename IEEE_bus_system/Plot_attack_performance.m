%% plot attack performance

clc
clear
close all

% detector_train_flag = 0;
% attack_percentage = 1;
% Run_sim;

% choose attack policy
% "ramp", "pulse", "sin"
attack_type = "ramp";

%% get a generated attack
load('attack_support.mat');
load('test_performance/19/1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19/test_result.mat');
if attack_type == "ramp" || attack_type =="pulse"
    thresh_1 = 0.05;  % threshold for stealthiness
    thresh_2 = 0.04;  % threshold for effectivness
elseif attack_type == "sin"
    thresh_1 = 0.05;  % threshold for stealthiness
    thresh_2 = 0.02;  % threshold for effectivness
end

%% test
% z_attack_data = Z_attack_data(:,51);  
% plot_single_attack_performance;

index_high_effect = find(stealth_index == max(stealth_index(stealth_index<=thresh_1)));
z_attack_data = Z_attack_data(:,index_high_effect);  % highest effectiveness probability 
plot_single_attack_performance;










