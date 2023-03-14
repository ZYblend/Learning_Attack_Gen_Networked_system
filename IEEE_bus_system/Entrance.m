close all
clear all
clc

attack_percentage = 1;

% choose attack policy
% "ramp", "pulse", "sin"
attack_type = "pulse";

Run_sim;
workshop(attack_percentage, attack_type);